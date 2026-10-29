---
name: react-layered-architecture
description: Use when creating, moving, or naming files in a plain React app (Vite or similar SPA, no Next.js/Remix) organized by technical layer (pages, components, hooks, queries). Best for small to mid-size apps. Covers layout, naming, import direction, config, tests, and when to move to react-domain-architecture.
license: MIT
---

# React layered architecture

Plain React single-page app, grouped by technical role. Server data is handled with TanStack Query (or a similar query client) in `queries/`. Use for small to mid-size projects.

## Target version

Written for React 19 with TypeScript and Vite on 2026-10-29. Applies to any client-only React setup. Not for meta-frameworks (Next.js, Remix), which have their own routing layout.

## Follow the repo first

Read `src/` before creating files. If the project already has conventions (folder names, casing, import alias), use them. Check `tsconfig.json` for path aliases and the lint config for import rules.

## Default directory layout

```
src/
  main.tsx        # entry: mounts <App />
  app.tsx         # providers and router
  pages/          # one component per route
  components/     # shared UI used by 2+ pages
    ui/           # generic primitives (Button, Modal)
  hooks/          # shared custom hooks
  queries/        # query and mutation hooks, query keys, request functions
  store/          # global client state
  utils/          # pure helper functions
  types/          # shared types
  config/         # env parsing and constants
  styles/         # global CSS and tokens
  test/           # test setup and shared test helpers
```

Read [references/full-tree.md](references/full-tree.md) when you need the expanded tree with every subfolder.

## Naming conventions

- Files and folders: kebab-case for everything, such as `user-card.tsx` and `use-users.ts`. Do not mix casing.
- Exports: use named exports. Avoid default exports.
- Components: one component per file. The export is PascalCase and the file is its kebab-case form: `UserCard` in `user-card.tsx`.
- Hooks: `use-thing.ts`, exporting `useThing`.
- Queries: `user.queries.ts`, one per backend resource. Exports hooks (`useUsers`, `useCreateUser`) and a key factory (`userKeys`).
- Types: `user.types.ts`.
- Routes: pages are `user-list-page.tsx`. URL paths are kebab-case.
- Tests: `user-card.test.tsx` next to the file under test.
- Imports: use the `@/` alias for `src/`. Never import with `../../..`.

## Dependency direction

Higher layers may import lower layers. Lower layers never import higher ones.

```
pages -> components -> queries, hooks -> utils -> types
```

- `pages` import from any layer below.
- `components` import `queries`, `hooks`, `utils`, `types`, and other components. Never `pages`.
- `queries` import `utils`, `types`, `config`, and `queries/api-client.ts`. Never `components`, `pages`, or `store`.
- `hooks` hold UI and generic logic. They may import `queries`, `store`, `utils`, `types`.
- `utils` and `types` import nothing from the app.

## Where things live

- Config: `src/config/`. Read `import.meta.env` only in `config/env.ts`.
- Env vars: prefix with `VITE_`. List every var in `.env.example` at the repo root.
- Shared types: `src/types/`. Keep a type next to its only user until a second file needs it.
- Global state: `src/store/`. Keep server data in the query cache, not in `store/`. Keep UI state local.
- Query client: create it in `src/config/query-client.ts`. Mount the provider in `app.tsx`.
- HTTP client: `src/queries/api-client.ts`. Only `queries/` files call it.

## Tests

- Put unit and component tests next to the file: `button.tsx`, `button.test.tsx`.
- Put test setup and shared helpers in `src/test/`.
- Put end-to-end tests in `e2e/` at the repo root.

## Structure at three sizes

Read [references/growth-stages.md](references/growth-stages.md) when deciding whether to restructure.

### Prototype

Use `main.tsx`, `app.tsx`, and `components/`. Add `hooks/` and `queries/` on first use.
Signal to move up: a second page, or an API call.

### Mid-size

Use the default layout above. Add subfolders inside a layer when it passes about 10 files, for example `components/forms/`.
Signal to move up: `components/` or `hooks/` passes about 30 files, one feature change touches 4+ top-level folders, or several people collide in the same folders.

### Large

Switch to the `react-domain-architecture` skill. Move one feature at a time. Do not rewrite.

## Anti-patterns

Read [references/anti-patterns.md](references/anti-patterns.md) when reviewing a layout or before moving files.

- Do not call `fetch` or an API client inside a component. Use a hook from `queries/`.
- Do not write query keys inline. Use the key factory from the resource's `queries/` file.
- Do not import React components in `queries/` or `utils/`.
- Do not import `pages/` from `components/`.
- Do not put a component in `components/` if only one page uses it. Keep it next to that page.
- Do not create a `common/`, `misc/`, or `helpers/` folder.
- Do not add an `index.ts` barrel to every folder.
- Do not copy query data into `useState` or `store/`.
- Do not use deep relative imports. Use `@/`.
- Do not use PascalCase or camelCase file names, or rename a file only to change its case.
