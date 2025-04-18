---
name: simplify
description: Use after manual code changes to improve clarity/readability without changing behavior. Not for AI slop cleanup.
---

# Simplify

Refine recently modified code for clarity and consistency without changing behavior.

## Workflow

1. **Identify scope** — only code modified in current session (unless told otherwise)
2. **Analyze** — look for: unnecessary nesting, redundant abstractions, unclear names, dead code, inconsistent style
3. **Refine** — apply project conventions, reduce complexity, improve names. Prefer clarity over brevity.
4. **Verify** — confirm behavior unchanged, run relevant tests

## Rules
- Never change functionality — only how it's expressed
- Avoid nested ternaries — prefer if/else or switch for multiple conditions
- Don't over-consolidate — helpful abstractions improve organization
- Don't optimize for fewer lines at the expense of readability
- Match existing project style (naming, imports, formatting)

## Example

Before:
```python
def proc(d):
    r = []
    for k in d:
        if d[k] is not None:
            if d[k] > 0:
                r.append(k)
    return r
```

After:
```python
def positive_keys(data: dict) -> list:
    return [key for key, value in data.items() if value is not None and value > 0]
```

The refactored version uses a descriptive name, type hints, and a single comprehension that reads as a sentence. Don't collapse further — splitting the condition across lines is acceptable if it aids readability.

## When to flatten nesting vs. extract a function

Flatten when nesting is purely defensive or structural:
```typescript
// Before — two levels of nesting for a simple guard
function process(items) {
  if (items) {
    if (items.length > 0) {
      return items.map(transform)
    }
  }
  return []
}

// After — early return eliminates nesting
function process(items) {
  if (!items?.length) return []
  return items.map(transform)
}
```

Extract when a block has a distinct purpose:
```typescript
// Before — mixed concerns in one function
function handleSubmit(form) {
  const errors = []
  if (!form.email.includes('@')) errors.push('Invalid email')
  if (form.password.length < 8) errors.push('Password too short')
  if (errors.length > 0) { showErrors(errors); return }
  submitToAPI(form)
}

// After — validation extracted with a clear name
function validateForm(form): string[] {
  const errors = []
  if (!form.email.includes('@')) errors.push('Invalid email')
  if (form.password.length < 8) errors.push('Password too short')
  return errors
}

function handleSubmit(form) {
  const errors = validateForm(form)
  if (errors.length > 0) { showErrors(errors); return }
  submitToAPI(form)
}
```

## Naming guidelines
- Functions: verb phrases describing what they do (`fetchUser`, `parseConfig`, `is_valid`)
- Booleans: `is_`/`has_`/`can_` prefix
- Avoid: `data`, `info`, `obj`, `temp`, `helper`, `utils` as primary names — qualify them (`orderData`, `configInfo`)
- Single-letter variables only in tiny, conventional scopes (`i` in a loop, `e` in a catch)

## Pitfalls
- Combining too many concerns into single functions
- Removing helpful comments that explain *why* (e.g., workarounds, non-obvious constraints)
- Making code "clever" instead of clear — a readable 3-liner beats an obscure 1-liner
- Refactoring untouched code without being asked
- Renaming things in a way that diverges from the rest of the codebase's conventions
