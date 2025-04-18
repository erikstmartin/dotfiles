---
name: code-review-excellence
description: Use when conducting code reviews or establishing review standards. Not for requesting or receiving review.
---

# Code Review Excellence

## 1. Pre-Review Preparation

1. **Read the PR description and linked issue first.** Understand the stated intent before touching the diff.
2. **Check PR size.** If >400 lines of non-generated code, request a split before investing review time.
3. **Verify CI is green.** If tests or lint are failing, leave a single comment asking the author to fix CI before proceeding. Do not review failing code.
4. **Identify review scope.** Note the affected subsystems (auth, data layer, UI, etc.) — this guides where to spend depth.
5. **Pull the branch locally** for any change touching security, concurrency, or data migrations. Read-only diffs miss runtime behavior.

---

## 2. Review Execution Workflow

Review in this order — coarse to fine. Stop escalating depth once you've found enough blocking issues.

### Pass 1 — Architecture (5 min)
- Does the approach fit the problem, or is there a simpler solution?
- Is it consistent with existing patterns in the codebase?
- Are new files placed correctly? Any duplication of existing modules?
- For large features: would staged PRs (interfaces first, then implementation) be clearer?

### Pass 2 — Tests (5 min)
- Tests exist for the new behavior?
- Do tests assert observable behavior, not internal state?
- Are edge cases and error paths covered (empty input, auth failure, nil/null)?
- Are test names descriptive enough to act as documentation?

### Pass 3 — Logic & Correctness (10–20 min, line-by-line)
Work through each changed file. Check in this order:

| Category | Specific checks |
|---|---|
| **Correctness** | Off-by-one errors, null/nil dereference, unchecked return values |
| **Error handling** | Every error path handled or explicitly ignored with a comment |
| **Concurrency** | Shared state accessed without synchronization, race conditions |
| **Security** | Unvalidated input, SQL interpolation, hardcoded secrets, missing authz checks |
| **Performance** | N+1 queries, O(n²) loops over large sets, blocking calls in hot paths |
| **Maintainability** | Magic numbers, unexplained complex logic, functions doing >1 thing |

### Pass 4 — Summary Decision (2 min)
Choose one and state it clearly:
- ✅ **Approve** — ready to merge
- 💬 **Comment** — suggestions only, author can merge at their discretion
- 🔄 **Request Changes** — specific blockers listed; re-review required

---

## 3. Feedback Delivery Workflow

**Label every comment by severity** so authors can triage:

| Label | Meaning |
|---|---|
| `[blocking]` | Must fix before merge |
| `[important]` | Strong recommendation; discuss if you disagree |
| `[nit]` | Style/clarity; not blocking |
| `[question]` | Seeking understanding, not requesting a change |
| `[praise]` | Explicitly noting good work |

**Format each comment:**
1. Label + one-sentence observation
2. Explanation of impact (why it matters)
3. Concrete suggestion or example

**Post a top-level summary** when leaving >3 comments. Include: what you reviewed, what worked well, what must change before merge.

**Resolve disagreements by escalating to data or a third party**, not by repeating the same point. If it's non-critical and working, approve it.

---

## 4. Comment Examples

### Example A — Security issue (blocking)

❌ Vague:
```
This is insecure.
```

✅ Actionable:
```
[blocking] This query interpolates `userId` directly into the SQL string, 
which allows SQL injection. Use a parameterized query instead:

    db.query('SELECT * FROM users WHERE id = ?', [userId])

Any unsanitized user input hitting the DB is a P0.
```

---

### Example B — Design suggestion (non-blocking)

❌ Commanding:
```
Extract this into a service class.
```

✅ Collaborative:
```
[nit] `calculateTotal()` currently handles tax, discounts, and DB writes. 
If we ever need to unit test the tax logic in isolation, that mix will be 
painful. Would it make sense to split the pure calculation out? Happy to 
pair on it if useful — not blocking this PR.
```

---

## 5. Common Pitfalls

- **Rubber-stamping** — approving without reading. If you don't have time, say so rather than leaving a meaningless LGTM.
- **Bike-shedding** — spending 80% of comments on naming and formatting. Automate style with linters; focus human review on logic and design.
- **Scope creep** — "while you're at it, can you also refactor X?" File a separate issue instead.
- **Delayed reviews** — PRs sitting >1 business day kill team flow. Time-box to the same day or explicitly hand off.
- **Ghosting after requesting changes** — if you requested changes, re-review within 24 hours of the author's response.
- **Inconsistent standards** — holding junior contributors to stricter standards than seniors. Apply the same checklist to everyone.
- **Blocking on non-blocking issues** — marking `[nit]` comments as required changes. Use `Request Changes` only for actual blockers.
