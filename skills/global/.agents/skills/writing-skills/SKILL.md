---
name: writing-skills
description: Use when creating new skills, editing existing skills, or evaluating whether an existing skill is effective
---

# Writing Skills

## 1. Skill Analysis Workflow

Diagnose an existing skill before touching it.

**Step 1 — Count token waste.** Run `wc -w SKILL.md`. Over 500 words? Identify every sentence that restates what Claude already knows.

**Step 2 — Test the description.** Ask: does this description describe *triggering conditions* only, or does it summarize the workflow? If it summarizes the workflow, Claude will follow the description as a shortcut and skip the body.

**Step 3 — Test discovery.** Give a fresh agent the skill. Present a realistic scenario without naming the skill. Does the agent load it? Does it follow the right steps? If not, the description keywords are wrong.

**Step 4 — Rate each section.** For every section, answer: "Would Claude fail this task without this section?" If no → cut it.

**Step 5 — Check for loopholes** (discipline-enforcing skills only). Run a pressure scenario: sunk cost + time pressure + exhaustion. Document the exact rationalization the agent uses when it violates the rule. Every rationalization that appears must be named and blocked explicitly.

---

## 2. Skill Structure Workflow

**Frontmatter rules (enforced):**
- Only `name` and `description` fields
- `name`: letters, numbers, hyphens only
- `description`: third person, starts "Use when...", NO workflow summary, ≤500 chars
- Never summarize the skill's steps in the description — Claude will take that as a shortcut

**SKILL.md body:**
```
# Skill Name

## When to Use
Bullet symptoms. Include "When NOT to use."

## Core Pattern / Workflow
Steps or before/after. Not prose.

## Quick Reference
Table or bullets for scanning.

## Common Mistakes
What goes wrong + fix. Not theory.
```

**Progressive disclosure — when to split files:**
- Reference material >100 lines → separate `.md` file, link from SKILL.md
- Reusable scripts → separate file, instruct to *execute* not read
- Keep all linked files ONE level deep from SKILL.md (nested refs get partially read)

**Token targets:**
- Frequently-loaded skills: <200 words total
- Other skills: <500 words
- Use `wc -w` to verify

---

## 3. Testing / Validation Workflow

> SkillsBench (2025) shows self-generated skills reduce task success by ~1.8pp vs. human-assisted. Human review of each iteration is not optional.

### For discipline-enforcing skills (TDD, verification requirements, etc.)

**RED — establish baseline:**
1. Run scenario WITHOUT skill loaded
2. Record exact rationalization verbatim (not "agent failed" — the actual words)
3. Run 3+ combined pressures: time + sunk cost + exhaustion is the standard combo

**GREEN — write minimal skill:**
4. Address only the specific rationalizations from step 2
5. Run same scenario WITH skill. Agent must comply.

**REFACTOR — close loopholes:**
6. Agent violated despite skill? Add explicit negation of that exact rationalization
7. Build rationalization table (see example below)
8. Re-test. Repeat until no new rationalizations appear.

**Done when:** Agent cites skill sections as justification, acknowledges the temptation, still follows rule.

### For reference/technique skills

1. Present retrieval scenario: agent must find specific info from skill
2. Present application scenario: agent must correctly use what it found
3. Identify gaps: what did the agent ask for that wasn't in the skill?

### Meta-test (when GREEN isn't working)

Ask the agent: *"You had the skill loaded and chose the wrong option. How should the skill have been written to make the right answer obvious?"*

Three responses, three fixes:
- "The skill was clear, I chose to ignore it" → add foundational principle up front
- "The skill should have said X" → add X verbatim
- "I didn't see section Y" → restructure, make key points earlier

---

## 4. Examples: Before/After Skill Improvement

### Example A — Description that defeats itself

**Before:**
```yaml
description: Use when executing implementation plans - dispatches one subagent per task with code review between tasks
```
**Problem:** The description summarizes the two-stage review workflow. Claude follows the description as a shortcut, doing ONE review instead of two.

**After:**
```yaml
description: Use when executing implementation plans with independent tasks in the current session
```
**Why it works:** No workflow summary. Claude reads the skill body, finds the flowchart showing two reviews, follows it correctly.

---

### Example B — Discipline skill with loopholes vs. without

**Before:**
```markdown
Write code before test? Delete it.
```
**Problem:** Agent rationalizes "I'll keep it as reference while writing tests." Loophole exploited.

**After:**
```markdown
Write code before test? Delete it. Start over.

**No exceptions:**
- Don't keep it as "reference"
- Don't "adapt" it while writing tests  
- Don't look at it
- Delete means delete

| Rationalization | Reality |
|----------------|---------|
| "I'll keep as reference" | You'll adapt it. That's testing after. Delete means delete. |
| "Tests after achieve same goals" | Tests-first = what should this do. Tests-after = what does this do. Different. |
| "Being pragmatic not dogmatic" | The spirit of TDD is the letter of TDD. |
```
**Why it works:** Each loophole is named. Agent can't rationalize around unnamed exceptions.

---

## 5. Common Pitfalls

| Pitfall | Symptom | Fix |
|---------|---------|-----|
| Description summarizes workflow | Agent does fewer steps than skill specifies | Remove all process details from description |
| Testing only academic scenarios | Skill passes quiz, fails under pressure | Add 3+ combined-pressure scenarios |
| Generic rationalization counter ("don't cheat") | Agent ignores it | Use verbatim rationalization from baseline test |
| Nested file references | Claude partially reads, misses content | All links one level deep from SKILL.md |
| Over-explaining what Claude knows | Bloated skill, key content buried | Challenge each sentence: "Does Claude need this?" |
| Writing skill before baseline test | Skill addresses imagined problems | Always run RED phase first |
| Multiple mediocre examples | Diluted impact | One complete, runnable, real-scenario example |
