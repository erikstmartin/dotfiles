---
name: vite
description: Use for Vite config, plugins, SSR, or Vite 8/Rolldown migration. Not for Vitest testing.
---

# Vite

Vite 6+ frontend build tool — native ESM dev server + optimized production builds.

## Workflow

1. **Configure** — `vite.config.ts` with `defineConfig`. Always use TypeScript + ESM.
2. **Develop** — `vite` starts dev server with instant HMR
3. **Build** — `vite build` for production, `vite preview` to test output locally
4. **Deploy** — output in `dist/`, set `base` option for non-root paths (e.g. GitHub Pages)

## Config Example

```ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  resolve: { alias: { '@': '/src' } },
  server: {
    port: 3000,
    proxy: { '/api': 'http://localhost:8080' },
  },
  build: {
    target: 'esnext',
    outDir: 'dist',
  },
})
```

Use `defineConfig` with a function for environment-conditional config:
```ts
export default defineConfig(({ command, mode }) => ({
  plugins: [react()],
  define: {
    __DEV__: command === 'serve',
  },
}))
```

## Key Features

**Glob imports** — dynamically load matching modules:
```ts
const modules = import.meta.glob('./modules/*.ts')
// eager: true loads all immediately instead of lazy
const eager = import.meta.glob('./locale/*.json', { eager: true })
```

**Asset queries** — import assets with transform hints:
```ts
import url from './img.png?url'       // resolves to public URL string
import raw from './shader.glsl?raw'   // resolves to file contents as string
import worker from './worker.ts?worker' // wraps as Web Worker
```

**Env variables** — only `VITE_`-prefixed vars are exposed to client code:
```ts
// .env
VITE_API_URL=https://api.example.com
SECRET_KEY=do-not-expose   // NOT accessible in client

// in source
const url = import.meta.env.VITE_API_URL
```

**CSS Modules** — auto-enabled for `.module.css` files:
```ts
import styles from './app.module.css'
// styles.container → scoped class name
```

## Plugin Authoring

Vite plugins extend Rollup's plugin interface with additional Vite-specific hooks:
```ts
import type { Plugin } from 'vite'

function myPlugin(): Plugin {
  return {
    name: 'my-plugin',
    // Vite hook: runs before Rollup
    configResolved(config) {
      console.log('resolved base:', config.base)
    },
    // Rollup hook: transform source files
    transform(code, id) {
      if (!id.endsWith('.custom')) return
      return { code: transformCustom(code), map: null }
    },
  }
}
```

Plugin ordering: `enforce: 'pre'` runs before framework plugins, `enforce: 'post'` runs after.

## SSR

```bash
vite build --ssr src/entry-server.ts   # build server bundle
vite build                              # build client bundle separately
```

In dev, use `server.ssrLoadModule` to load modules through Vite's pipeline:
```ts
const { render } = await viteDevServer.ssrLoadModule('/src/entry-server.ts')
```

## Official Plugins

- `@vitejs/plugin-vue` — Vue 3 SFC support
- `@vitejs/plugin-react` — React with Babel/Oxc (Vite 8+)
- `@vitejs/plugin-react-swc` — React with SWC (faster transforms)
- `@vitejs/plugin-legacy` — transpile for older browsers with `@babel/preset-env`

## Pitfalls
- `process.env` does not work in client code — use `import.meta.env` instead
- Forgetting the `VITE_` prefix on env vars — they will be `undefined` in the browser with no warning
- CJS-only dependencies fail at runtime in the browser — add them to `optimizeDeps.include` so Vite pre-bundles them as ESM
- HMR not triggering for a module — the module needs to call `import.meta.hot.accept()` or have an ancestor that does; otherwise Vite does a full reload
- Large glob imports without `{ eager: false }` (the default) add lazy dynamic imports; with `eager: true` they all land in the initial bundle
