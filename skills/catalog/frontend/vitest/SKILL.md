---
name: vitest
description: Use for Vitest tests: mocking, coverage, fixtures, filtering, and setup. Not for non-Vitest testing frameworks.
---

# Vitest

Vitest 3.x testing workflow — Jest-compatible API with Vite-native transforms.

## Workflow

1. **Setup** — `vitest.config.ts` or inline in `vite.config.ts` with `test` key
2. **Write tests** — `describe`/`it`/`expect` (Jest-compatible), use `.test.ts` or `.spec.ts`
3. **Mock** — `vi.mock()` for modules, `vi.fn()` for functions, `vi.spyOn()` for methods
4. **Run** — `vitest` (watch), `vitest run` (CI), `vitest run --reporter=verbose`
5. **Coverage** — `vitest run --coverage` (V8 provider default)

## Config Example

```ts
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./tests/setup.ts'],
    coverage: { provider: 'v8', include: ['src/**'] },
  },
})
```

If you already have a `vite.config.ts`, merge the `test` key in there instead of a separate file — Vitest reads either.

## Mocking Example

```ts
import { describe, it, expect, vi, afterEach } from 'vitest'
import { fetchUser } from './api'

vi.mock('./api', () => ({
  fetchUser: vi.fn(),
}))

describe('UserProfile', () => {
  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('displays user name', async () => {
    vi.mocked(fetchUser).mockResolvedValue({ name: 'Alice' })
    const result = await fetchUser('1')
    expect(result.name).toBe('Alice')
  })

  it('throws on network failure', async () => {
    vi.mocked(fetchUser).mockRejectedValue(new Error('Network error'))
    await expect(fetchUser('1')).rejects.toThrow('Network error')
  })
})
```

## Common Patterns

**Timers** — freeze time for interval/timeout logic:
```ts
vi.useFakeTimers()
myDebounce(() => {}, 300)
vi.advanceTimersByTime(300)
expect(callback).toHaveBeenCalledOnce()
vi.useRealTimers()
```

**Spy on a method without replacing the module**:
```ts
const spy = vi.spyOn(console, 'warn').mockImplementation(() => {})
doSomething()
expect(spy).toHaveBeenCalledWith('expected warning')
```

**Snapshots** — useful for generated output or complex objects:
```ts
expect(result).toMatchSnapshot()              // stored in __snapshots__
expect(result).toMatchInlineSnapshot(`"foo"`) // inline, auto-updated
```

**Custom fixtures** — share setup across tests without `beforeEach` duplication:
```ts
const test = base.extend<{ db: Database }>({
  db: async ({}, use) => {
    const db = await Database.connect(':memory:')
    await use(db)
    await db.close()
  },
})

test('query returns rows', async ({ db }) => {
  const rows = await db.query('SELECT 1')
  expect(rows).toHaveLength(1)
})
```

**Filtering tests** at the command line:
```bash
vitest run -t "displays user"   # match by test name
vitest run src/api              # match by file path
vitest run --project web        # match by project name (monorepos)
```

Or in code: `it.only(...)`, `describe.skip(...)`.

## Pitfalls
- Forgetting `vi.restoreAllMocks()` (or setting `restoreMocks: true` in config) — stale mocks leak between tests and cause false positives
- Using `globals: true` without adding `/// <reference types="vitest/globals" />` or `"types": ["vitest/globals"]` in `tsconfig.json` — TypeScript won't know about `describe`/`it`/`expect`
- Module mock hoisting — `vi.mock()` is hoisted to the top of the file at compile time, so it can't reference variables defined in the same file. Use `vi.hoisted()` for dynamic values:
  ```ts
  const mockFn = vi.hoisted(() => vi.fn())
  vi.mock('./module', () => ({ fn: mockFn }))
  ```
- `jsdom` missing modern Web APIs (e.g., `ResizeObserver`, `IntersectionObserver`) — switch to `happy-dom` for broader coverage, or manually polyfill in `setupFiles`
- Running `vitest` in CI without `vitest run` — watch mode hangs the process
