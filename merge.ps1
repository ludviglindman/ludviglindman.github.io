# merge.ps1 - merge newest Montrose CSV export into transactions.json
# Run it from the repo root:
#   powershell -ExecutionPolicy Bypass -File .\merge.ps1
# Filters to my own accounts, keeps only buy/sell, de-duplicates, preserves history.
# Written ASCII-only so Windows PowerShell reads it correctly regardless of file encoding.

$repo   = $PSScriptRoot
$txPath = Join-Path $repo "transactions.json"
$mine   = @("2100477","2329738")   # my accounts only

# --- pick the newest CSV in imports\ ---
$csvFile = Get-ChildItem (Join-Path $repo "imports\*.csv") -ErrorAction SilentlyContinue |
           Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $csvFile) { Write-Error "No CSV found in imports\"; exit 1 }
Write-Host "Using CSV: $($csvFile.Name)"

# Import-Csv -Encoding UTF8 reads the CSV data (and its accented values) correctly.
$csv = Import-Csv -Path $csvFile.FullName -Encoding UTF8

$new = foreach ($r in $csv) {
    if ($mine -notcontains $r.Konto) { continue }

    # Type: buy starts with K (Kop), sell starts with S (Salj).
    # No other Montrose type starts with K or S, so this is unambiguous and needs no accents.
    if     ($r.Typ -like 'K*') { $side = 'buy'  }
    elseif ($r.Typ -like 'S*') { $side = 'sell' }
    else   { continue }

    if ([string]::IsNullOrWhiteSpace($r.Ticker)) { continue }

    # Name column is the accented "Vardepapper / Beskr." - match it by wildcard so we
    # never type the accented header literally.
    $nameProp = $r.PSObject.Properties | Where-Object { $_.Name -like 'V*rdepapper*' } | Select-Object -First 1
    $nm = if ($nameProp) { $nameProp.Value } else { $r.Ticker }

    $sh = [Math]::Abs([double]($r.Antal -replace ',','.'))
    if ($sh -eq [Math]::Floor($sh)) { $sh = [int]$sh }

    [PSCustomObject]@{
        date     = $r.Datum
        ticker   = $r.Ticker
        name     = $nm
        side     = $side
        shares   = $sh
        price    = [double]($r.Kurs -replace ',','.')
        currency = $r.Kursvaluta
    }
}

# --- load existing history ---
$existing = @()
if (Test-Path $txPath) {
    $existing = (Get-Content $txPath -Raw -Encoding UTF8 | ConvertFrom-Json).transactions
}

# --- de-duplicate by date|ticker|side|shares|price ---
$seen = @{}
foreach ($t in $existing) { $seen["$($t.date)|$($t.ticker)|$($t.side)|$($t.shares)|$($t.price)"] = $true }
$added = 0
$toAdd = foreach ($t in $new) {
    $k = "$($t.date)|$($t.ticker)|$($t.side)|$($t.shares)|$($t.price)"
    if (-not $seen.ContainsKey($k)) { $seen[$k] = $true; $added++; $t }
}

# --- combine (newest first) and write back as UTF-8 without BOM ---
$all  = @($toAdd) + @($existing) | Sort-Object -Property date -Descending
$json = [PSCustomObject]@{ transactions = $all } | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($txPath, $json, (New-Object System.Text.UTF8Encoding($false)))

Write-Host "existing=$($existing.Count)  added=$added  total=$($all.Count)"
