# Bringing Live Azure Pricing Into Copilot — Building the azure-pricing Skill

Cost estimation in architecture work has always been awkward. You tab out to the Pricing Calculator, hope your memory of last quarter's rates is still accurate, or drop a rough figure into a design doc with a disclaimer that nobody reads. It holds together until someone actually holds you to the number — or until the workload scales and it looks embarrassingly wrong in hindsight.

I wanted to fix this properly. Not by building a better spreadsheet, but by pulling live pricing directly into the engineering conversation, right where architecture decisions get made. The `azure-pricing` skill is the result — part of my [GitHub Copilot agent skills repo](https://github.com/thomast1906/github-copilot-agent-skills) — and this post covers how it works, what makes it genuinely useful in practice, and a handful of Azure Retail Prices API quirks that will quietly give you wrong data if you don't account for them.

---

## The friction that builds up over time

When you're designing a solution — a Terraform module, a Bicep template, a high-level architecture — the question "roughly how much will this cost?" comes up constantly. The friction of switching context means it often doesn't get answered properly until much later. By then, you've already settled on a service tier, a region, or a deployment pattern that may not survive contact with the budget conversation.

The other issue is drift. Pricing knowledge has a shelf life. A figure that was accurate six months ago might not be now — tiers change, introductory rates end, regional pricing adjusts. You can't reliably keep this in your head, and writing it down in documentation means it's stale almost immediately.

What I wanted was for Copilot to be able to answer "what does this actually cost?" mid-conversation, using live data, without leaving VS Code. That was the actual goal.

---

## Skills as a knowledge distribution layer

Before the pricing specifics, it's worth stepping back on how Copilot skills work here, because that's where the more interesting platform engineering angle sits.

A `SKILL.md` file is a structured instruction document that lives in `.github/skills/` and tells Copilot how to behave within a domain. It's not just documentation — it's operational context. When Copilot picks up a skill, it gets tool invocation patterns, error handling logic, output format expectations, and real-world gotchas embedded directly. The skill shapes how Copilot reasons about the problem, not just what it says.

The practical effect: every engineer working in the repo gets the same behaviour. Nobody has to figure out the OData filter syntax from scratch. Nobody has to discover that `P2v3` returns nothing but `P2 v3` with a space works fine. That knowledge lives in the skill file, and the skill travels with the codebase. It's version-controlled, reviewable, and improveable — the same way you'd treat any shared platform tooling.

That holds for a single team. Once you start distributing this across multiple teams or repos, ``.github`` stops feeling like a config folder and starts behaving more like a distribution layer for engineering knowledge. The problem isn't getting this working once — it's keeping it consistent and maintained as more people build on top of it.

---

## How the skill actually works

The pricing data comes from the Azure Retail Prices API, surfaced through the Azure VS Code extension (`ms-azuretools.vscode-azure-github-copilot`), which registers an MCP pricing tool automatically. No `mcp.json` configuration needed — the extension handles tool registration.

The skill discovers the tool at runtime via `tool_search_tool_regex` rather than hardcoding the tool name. That's a deliberate choice: tool names can drift between extension versions, and a hardcoded name would silently break. Runtime discovery keeps it stable without tight coupling to a specific version.

From there, the skill calls the tool with parameters matched to the user's request and interprets the response into something structured and actionable — price tables, monthly estimates, Reservation comparisons, Hybrid Benefit callouts. Simple enough in principle. In practice, the Azure Retail Prices API has several behaviours that will give you quietly wrong results if you don't handle them.

---

## What the API does when you're not looking

### SKU name spacing is inconsistent

This one caught me immediately. Query with `sku: "P2v3"` for App Service and you get nothing back. Not an error — empty results, silently. The API stores App Service SKUs with a space: `P2 v3`. Query without the space and it returns zero rows as if the SKU doesn't exist.

The fix is an OData `filter` fallback:

```
filter: skuName eq 'P2 v3' and serviceName eq 'Azure App Service'
```

The skill documents a two-step pattern: try the `sku` parameter first, and if results come back empty, fall back to OData querying `skuName` directly. Once you know this, it's straightforward. The problem is that there's no obvious signal — empty results look just like "this SKU doesn't exist in this region," which sends you on a different debugging path entirely.

### Reservation prices are lump sums, not hourly rates

This one is genuinely misleading. Query Reservation pricing and the response includes `unitOfMeasure: "1 Hour"` on every row. That strongly implies the price is hourly. It isn't. The `retailPrice` field on Reservation rows is the total commitment cost for the full term — not a per-hour rate.

To compare fairly against Consumption, you divide by 8,760 for a 1-year reservation, or 26,280 for 3-year. The skill handles this and makes it explicit in the output. Miss it, and your savings percentage looks wrong by an order of magnitude.

### SQL Database needs two queries, not one

Azure SQL Database is represented in the API as separate meters. Compute (vCore pricing) and storage are distinct product entries. A single query for `SQL Database` in a region returns both compute and storage rows interleaved unless you filter by `productName`. For anything resembling a real cost estimate, you need two targeted calls — one for compute, one for storage — rather than trying to parse a merged result set.

For a General Purpose Gen5 4-vCore database in `uksouth` at time of writing: ~£0.5623/hr for compute, ~£0.0977/GB/month for storage. The skill handles the two-call pattern automatically.

### The SQL `skuName` doesn't match the ARM SKU format

The ARM resource identifier for a GP Gen5 4vCore SQL database is `GP_Gen5_4`. In the Retail Prices API, that's stored as `skuName: "4 vCore"` under a `productName` containing `General Purpose - Compute Gen5`. Not the ARM format. Plain English.

The problem: `4 vCore` appears under Business Critical and DC-Series tiers too. Query by `skuName` alone and you get General Purpose (£0.5623/hr), Business Critical (£1.12/hr), and DC-Series rows all in the same response. You need to filter on both `skuName` and `productName` to isolate what you actually want.

These quirks are the kind of thing you only find by running real queries against the live API. I've documented all of them in the skill's Gotchas section so that nobody else has to rediscover them from scratch.

---

## Running it against a real scenario

To test the skill properly, I asked Copilot to price a standard two-tier web app in `uksouth`: an App Service P2v3 plan with an Azure SQL Database GP Gen5 4 vCore.

Live queries came back with:

| Resource | Rate | Monthly est. |
|----------|------|-------------|
| App Service P2v3 (Linux) | £0.2556/hr | ~£187/month |
| App Service P2v3 (Windows) | £0.4921/hr | ~£359/month |
| SQL Database GP Gen5 4 vCore | £0.5623/hr | ~£411/month |
| SQL Storage (GP) | £0.0977/GB/month | varies |

A Linux stack lands around £608/month at Consumption rates. Windows takes it to roughly £780/month — a £172/month difference that's entirely down to OS licensing and easy to miss if you haven't explicitly compared the two.

The skill surfaces all of this and then goes further: it flags Azure Hybrid Benefit (40%+ reduction on Windows VMs and SQL Server with existing licences), notes that 1-year reservations exist for both services, and prompts you to check the AHB calculator for accurate figures rather than guessing. These aren't optional — they're built into the output because they're the questions that come up in the next breath after the initial number lands.

---

## Currency defaults matter more than they look like they should

The Azure Retail Prices API defaults to USD if no currency is specified. For UK-based teams that's an immediate ambiguity — every estimate needs manual conversion, which introduces rounding inconsistencies and the occasional awkward correction mid-meeting.

The skill passes `currency: GBP` explicitly on every call. It's a small thing to implement and a quietly significant thing in practice. When you're sharing cost estimates in a design review or attaching figures to a budget request, arriving with the right currency before anyone has to ask for it removes a category of friction that shouldn't exist.

---

## Where it sits in the broader skills ecosystem

The `azure-pricing` skill was always designed to compose with the others rather than stand alone. Combined with [`architecture-design`](https://github.com/thomast1906/github-copilot-agent-skills/tree/main/.github/skills/architecture-design) and [`cost-optimization`](https://github.com/thomast1906/github-copilot-agent-skills/tree/main/.github/skills/cost-optimization), Copilot can size a solution, estimate what it costs at current retail rates, and identify where the spend is inefficient — all within a single conversation.

The `cost-optimization` skill uses the same `tool_search_tool_regex` runtime discovery pattern at Step 0. It picks up the live pricing data source without duplicating logic. That was a deliberate decision during design: each skill should know when to defer rather than trying to embed pricing reasoning everywhere. The alternative is drift — two skills with slightly different approaches to the same query, and nobody quite sure which one is right.

---

## The OData fallback as a general pattern

One thing that became clear building this: for services where the API `skuName` format doesn't match what you'd expect from the portal or ARM, the `filter` parameter with OData expressions is more reliable than the named `sku` parameter.

The pattern that holds up: try `sku` first. If results are empty, fall back to OData with `skuName` and `serviceName`. If `skuName` format is unknown, drop it from the first query and inspect what values the API actually returns for that service, then narrow. It's a two-step discovery process for unfamiliar SKUs. Tedious the first time. Automatic once it's encoded in the skill.

The broader lesson is that the API's mental model for SKU naming doesn't always match the operator's mental model, and the discrepancy is silent — empty results, not errors. Documenting the correct names in the skill prevents this from being rediscovered every time.

---

## What this changes about how cost conversations happen

What I find more interesting than the API mechanics is the shift this creates in how cost enters design conversations. When you're several turns deep in a Copilot architecture discussion, the question "but what does that actually cost?" used to mean pausing, switching context, coming back with a rough figure from memory or the pricing calculator. Now it's part of the conversation flow.

That's a meaningful change in timing. Instead of cost being a check you run at the end — or worse, something you estimate once and never revisit — it becomes something you check alongside each significant decision: service selection, tier choice, region. That's the right point in the process to be doing it. Cost surprises in architecture tend to come from decisions that seemed minor at the time. Checking early is how you catch them.

The skills model is what makes that viable as something shared rather than personal. The OData quirks, the GBP default, the AHB callout, the Reservation conversion logic — none of that needs to be rediscovered or re-reasoned each time. It lives in the skill, travels with the repo, and gives every engineer working in that context the same consistent behaviour.

The repo is open: [github.com/thomast1906/github-copilot-agent-skills](https://github.com/thomast1906/github-copilot-agent-skills). The `azure-pricing` skill and all the others live in `.github/skills/`. If you run into additional API quirks, contributions are welcome — the list is definitely not exhaustive.
