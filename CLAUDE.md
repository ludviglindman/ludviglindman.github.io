# Portfolio site — update instructions

This repo hosts a static page (`index.html`) showing my equity holdings and recent
transactions. It reads two data files: `positions.json` and `transactions.json`.

## When I say "update portfolio" (or "uppdatera portföljen"), do this:

1. **Positions** — Use the **Montrose MCP** to fetch my current holdings. For each
   holding, write: ticker, company name, unrealised return (%), and weight (% of book).
   Overwrite `positions.json` in the exact schema below. Set `"updated"` to today's date.

2. **Transactions** — The Montrose MCP can NOT fetch trade history, so I export it
   manually. If there is a new export file in `./imports/` (CSV or xlsx), parse it,
   convert new trades into the schema below, and merge them into `transactions.json`
   (newest first, no duplicates by date+ticker+shares). If `./imports/` is empty,
   leave `transactions.json` unchanged.

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
