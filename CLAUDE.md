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
   holdings for my accounts **2100477 and 2329738 only**. Combine them into one book and compute each
   holding's weight as a share of that combined book. For each holding write: ticker, company name,
   unrealised return (%), and weight (% of book). Do NOT write any absolute money amounts.
   Overwrite `positions.json` in the exact schema below. Set `"updated"` to today's date.

   The Montrose MCP does NOT expose portfolio returns, so I read them from the Montrose app and tell you.
   If I give you a YTD number, write it as `ytd_return_pct`; if I give you a since-start number, write it as `total_return_pct`.
   Both are percentages (e.g. 88.10). If I don't mention one, keep whatever value is already in the file.

2. **Transactions** — The Montrose MCP can NOT fetch trade history, so I export it manually.
   If there is a new export file in `./imports/`, parse it and keep ONLY rows whose account (Konto)
   is 2100477 or 2329738, and only Köp/Sälj (buy/sell) rows — skip deposits, withdrawals, interest,
   dividends, tax, and any other account. Convert them into the schema below (shares are the absolute
   value of Antal; buy = Köp, sell = Sälj) and merge into `transactions.json` (newest first, no
   duplicates by date+ticker+shares). If `./imports/` is empty, leave `transactions.json` unchanged.

   IMPORTANT: the shell rejects commands longer than ~965 bytes, so do NOT build the merge as one big
   inline command. Either run the committed `merge.ps1` (`powershell -ExecutionPolicy Bypass -File .\merge.ps1`),
   or write the merge logic to a small script file first and then execute that file.

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
  "positions": [
    { "ticker": "INVE B", "name": "Investor B", "return_pct": 22.02, "weight_pct": 32.5 }
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
