# 🏗️ P7 — Bank Transfer (Mongo)

**Milestone:** Mongo Day 24 · **Time:** ~75 min · **Requires:** `rs.initiate()` (Day 23)

## Objective

The transaction project, MongoDB edition — with the track's signature design question front and center.

## The Design Question First (write before any code)

Two account models:

- **A — one doc per account** (balances split across documents): transfers NEED multi-document transactions
- **B — one doc per user with `balances: { checking, savings }`** (or the account-pair doc): transfers within it are SINGLE-DOCUMENT atomic — no transaction!

For a real bank: when is B legitimate (internal transfers), when is A forced (transfers between different customers)? **Implement BOTH** and prove each one's atomicity story.

## Requirements

1. `accounts` (schema A) + `accounts_pair` demo (schema B) with CHECK-free but guard-by-filter updates
2. **safeTransfer with retries** (Day 24's template): guard-first + session ops + commit + retry loop
3. **The filter-carried guard version**: `updateOne({ _id, balance: { $gte: amount } }, { $inc: ... })` + modifiedCount check — prove an overdraw attempt is rejected by the guard
4. **Failure theater** (all proving rollback): (a) abort mid-transfer → both balances + the log row unchanged; (b) a transfer to a ghost account → aborts, nothing written; (c) the stray-db-call demo (outside the session — survives, oops) — then fix the template
5. **Schema B demo**: the same transfer on one document (both balances) — one updateOne, no transaction. Prove atomicity and write the 2-line lesson.

## Required Queries

6. Per-account flow report (transfers log aggregated — app-side or... you know $group by now: pipeline the log!)
7. The conservation check: SUM of balances = seed total (predict the number FIRST); plus a deliberate sabotage + detection

## Challenge ⭐

8. The ghost-reference audit: transfers referencing missing accounts — a $lookup pipeline with `{$size: 0}` (Day 22 P5's tool, applied to your own bank)

## Bonus 🔴

9. **Write concern**: critical transfers with `w: 'majority'` — one line on what durability claim changes; and the "when would w:1 be acceptable here" answer.

## Self-Review

- Which model (A/B) for which real-world case — your final table?
- What did the stray-call demo teach about the template's fragility?
- Compare to SQL-track P5 and PG-track P4: which paradigm made the *invariant* cheapest to enforce — and why?

> ✅ [solutions/07-bank-transfer.md](solutions/07-bank-transfer.md)
