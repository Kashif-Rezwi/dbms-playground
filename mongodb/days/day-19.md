# Day 19 — Aggregation Pipeline: $match, $project, $sort

**Track:** MongoDB · **Stage:** 6 — Aggregation · **Difficulty:** 🟡

## 🎯 Goal

Think in pipelines — documents flowing through stages — and master the three workhorse stages.

## 🧠 Fundamentals

An **aggregation pipeline** is a list of **stages**; documents flow in, each stage transforms, results flow out:

```javascript
db.orders.aggregate([
  { $match: { status: 'delivered' } },           // like find's query — FILTER
  { $sort: { ordered_at: -1 } },
  { $limit: 5 },
  { $project: { user_id: 1, total_amount: 1 } }
])
```

**The three workhorses:**

- **$match** — the same query syntax as find. **Pipeline rule #1: $match FIRST** — every document filtered out early never reaches later stages.
- **$sort / $limit / $skip** — as expected.
- **$project** — projection **plus computed fields**:

```javascript
{ $project: {
    name: 1,
    price_with_tax: { $multiply: ['$price', 1.05] },     // computed!
    is_cheap: { $cond: [{ $lt: ['$price', 1000] }, true, false] },
    status_label: { $switch: { branches: [
        { case: { $eq: ['$status', 'delivered'] }, then: '✅' },
        { case: { $eq: ['$status', 'cancelled'] }, then: '🚫' } ],
        default: '🚚' } }
} }
```

Field references: `'$fieldname'` (the $ prefix). Operators: `$multiply $add $divide $cond $switch $concat $toUpper...` — SQL's expressions and CASE, pipeline-style.

**Why pipelines instead of find?** find answers "give me documents"; pipelines answer "give me **answers**" — groups, transformations, joins (Days 20–22).

## 🔍 Why It Matters

The aggregation pipeline is MongoDB's most powerful query tool — the analog of SQL's GROUP BY world, composable like Unix pipes. Real analytics codebases are pipelines.

## 💡 Mental Model

> The pipeline is a **factory conveyor of documents**: $match is the quality gate at the entrance (reject early = cheapest), $sort arranges, $project is the labeling station that can also *compute* labels. Each stage only sees what survived before it — which is why early filtering is the golden rule.

## 💻 Examples

```javascript
use ecommerce

db.orders.aggregate([
  { $match: { status: 'delivered' } },
  { $sort: { total_amount: -1 } },
  { $limit: 3 },
  { $project: { _id: 0, user_id: 1, total_amount: 1,
                big: { $gt: ['$total_amount', 5000] } } }
])

db.products.aggregate([
  { $match: { stock: { $gt: 0 } } },
  { $project: { name: 1, price: 1,
                tier: { $switch: { branches: [
                    { case: { $gte: ['$price', 5000] }, then: 'premium' },
                    { case: { $gte: ['$price', 1000] }, then: 'mid' } ],
                    default: 'budget' } } } },
  { $sort: { price: -1 } }
])
```

## 🛠️ Practice

🟢 **P1.** The example flow on delivered orders — type it, run it, read every stage's output mentally.
🟢 **P2.** $match-first discipline: run the pipeline with $match AFTER $project — same result, different cost. Explain why order matters for work, not correctness.
🟢 **P3.** Products with a computed `price_in_cents` ($multiply by 100) — then $match on price_in_cents works! (Stages see earlier stages' fields — feel the dataflow.)
🟡 **P4.** The $switch labeler on orders (delivered ✅ / cancelled 🚫 / else 🚚), sorted by label then date.
🟡 **P5. ⭐ Predict first:** `[$match: {rating: 5}, $count: 'n']` on reviews — what's the output SHAPE? (An array with ONE document `{ n: ... }` — never a bare number. Predict, verify.)
🟡 **P6. From memory:** delivered orders, newest 3, with computed `days_old` — the date-math idiom: `$divide: [{ $subtract: [new Date(), '$ordered_at'] }, 86400000]`.
🔴 **P7.** The SQL-translation drill: write "top 3 delivered orders' totals with an is_big flag" in SQL (you know it!), then as the pipeline. Write the mapping in your notes: WHERE→$match, ORDER/LIMIT→$sort/$limit, CASE→$switch.
🔴 **P8.** Pipeline debugging method: a pipeline returns empty — run stages one at a time, printing each; find where docs vanish. Do it on purpose by breaking P4's $switch.

## 🐛 Debugging

```javascript
// Bug 1: $project references 'price' (no $) — in expressions that's a
// string literal, not the field. Fix: $price.
// Bug 2: $match on a computed field BEFORE $project created it — nothing
// matches. Fix: stage order = field availability.
// Bug 3: "pipeline is slow" — the $match sits after $sort on a huge
// collection. One-line fix + the reason.
```

## 🧩 Combine Concepts

`db.products.aggregate([{$match:{category_id:3}}, {$project:{name:1,_id:0}}, {$sort:{name:1}}, {$limit:5}])` — explain() the aggregate: can the Day 16/18 compound index cover the whole thing? (Aggregations use indexes too — a leading $match is index-eligible. Write the one-line rule.)

## 🔁 Previous Knowledge

1. Covered query — what breaks coverage?
2. The profiler's role?
3. ESR rule?
4. TTL contract?

## 🧠 Recall

1. Pipeline rule #1 — and the cost reason?
2. $project's superpower beyond find's projection?
3. How do you reference fields inside expressions?
4. What shape does every pipeline return — even $count?

## 🎤 Interview Questions

1. "What is the aggregation pipeline vs find?" *(Composable stages; find = the $match-only subset.)*
2. "Why does $match stage order matter so much?"
3. "How do you compute new fields in a pipeline?"

## ✅ Completion Checklist

- [ ] Understand pipelines, $match-first, $project computations, dataflow
- [ ] Completed P1–P8 (P5 predicted first)
- [ ] Fixed all three bugs
- [ ] Wrote the SQL↔pipeline mapping table
- [ ] Answered recall without notes

