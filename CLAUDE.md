# Portfolio site — update instructions

This repo hosts a static page (`index.html`) showing my equity holdings and recent
transactions. It reads two data files: `positions.json` and `transactions.json`.

## Helper files in this repo

- `merge.ps1` — merges the newest CSV in `imports/` into `transactions.json` (my accounts only, buy/sell only, de-duplicated).
- `update.bat` — one-click: runs `merge.ps1`, then commits and pushes. I double-click this after dropping a new CSV in `imports/`. It handles transactions only, not holdings or the return figures.

## My accounts (IMPORTANT)

I hold power of attorney over other people's portfolios in Montrose too. Only my OWN accounts
belong on this site. My accounts are **2100477** and **2329738**. Ignore every other account
(e.g. 2734366 is not mine) for both holdings and transactions.

## When I say "update portfolio" (or "uppdatera portföljen"), do this:

1. **Positions** — Use the **Montrose MCP** (`get_user_accounts`, then `get_holdings` per account) to fetch
   holdings for my accounts **2100477 and 2329738 only**. Combine them into one book. First work out the total
   book value = equity market value + cash (sum the currency balances / `valutasaldon` across my two accounts,
   converted to SEK). For each equity holding write: ticker, company name, unrealised return (%), and
   `weight_pct` = its market value as a share of the TOTAL book (so equity weights + `cash_pct` sum to ~100).
   Write `cash_pct` = cash / total book × 100. Do NOT write any absolute money amounts.
   Overwrite `positions.json` in the exact schema below. Set `"updated"` to today's date.

   The Montrose MCP does NOT expose portfolio returns, so I read them from the Montrose app and tell you.
   If I give you a YTD number, write it as `ytd_return_pct`; if I give you a since-start number, write it as `total_return_pct`.
   Both are percentages (e.g. 113.11). If I don't mention one, keep whatever value is already in the file.

2. **Transactions** — Run `merge.ps1` (`powershell -ExecutionPolicy Bypass -File .\merge.ps1`). It reads the
   newest CSV in `imports/`, keeps only my accounts (2100477 / 2329738) and only buy/sell rows, converts them
   to the schema below, and merges into `transactions.json` (newest first, de-duplicated on
   date+ticker+side+shares+price). If `imports/` has no new file, skip this step.
   Use `merge.ps1` here, NOT `update.bat` — `update.bat` also commits and pushes (it's my manual double-click),
   so running it inside this flow would double up with step 3.
   Never rebuild the merge as one long inline command — the shell caps commands at ~965 bytes; always run it as
   a script file. (Spec, in case `merge.ps1` must be regenerated: buy = Köp, sell = Sälj, shares = |Antal|;
   skip deposits, withdrawals, interest, dividends, tax, and any account other than mine.)

3. **Publish** — Then run: `git add -A && git commit -m "Update portfolio <date>" && git push`.

Always show me the diff of the JSON files before pushing.

## Schemas

`positions.json`:
```json
{
  "owner": "Ludvig",
  "tagline": "Current holdings and recent transactions, updated by hand. Not investment advice.",
  "updated": "YYYY-MM-DD",
  "currency": "SEK",
  "ytd_return_pct": 113.11,
  "total_return_pct": 154.50,
  "cash_pct": 62,
  "positions": [
    { "ticker": "EXS", "name": "Exsitec Holding", "return_pct": 3.00, "weight_pct": 19.5 }
  ]
}
```

`transactions.json`:
```json
{
  "transactions": [
    { "date": "YYYY-MM-DD", "ticker": "INVE B", "name": "Investor B", "side": "buy", "shares": 40, "price": 312.40, "currency": "SEK" }
  ]
}
```

`side` is either `"buy"` or `"sell"`. Numbers are plain (no thousands separators).
