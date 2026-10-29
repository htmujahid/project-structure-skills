---
name: react-domain-architecture
description: Use when creating, moving, or naming files in a plain React app (Vite or similar SPA, no Next.js/Remix) organized by business domain, with a modules/ folder and a core/ folder outside it. Best for mid to large apps and teams. Covers module layout, public APIs, import boundaries, config, tests, and growth.
license: MIT
---

# React domain architecture

Plain React single-page app, grouped by business domain. Server data is handled with TanStack Query (or a similar query client). Each domain is a module. Shared infrastructure lives in `core/`, outside `modules/`.

## Target version

Written for React 19 with TypeScript and Vite on 2026-10-29. Applies to any client-only React setup. Not for meta-frameworks (Next.js, Remix). For small apps, use `react-layered-architecture` instead.

## Follow the repo first

Read `src/modules/` and `src/core/` before creating files. If the project already has conventions (module names, casing, import alias, lint boundaries), use them. Check `tsconfig.json` for aliases and the lint config for import rules.

## Default directory layout

```
src/
  main.tsx          # entry: mounts <App />
  app.tsx           # composes core providers and the router
  core/             # infrastructure with no business logic
    app/            # providers, router, route composition
    api/            # HTTP client, QueryClient setup, error types
    config/         # env parsing and constants
    ui/             # design-system primitives (Button, Modal)
    hooks/          # generic hooks (useDebounce)
    lib/            # pure helpers
    store/          # app-wide client state (auth session, theme)
    types/          # shared generic types
    styles/         # global CSS and tokens
    test/           # test setup and shared helpers
  modules/          # one folder per business domain
    <module>/
```

Read [references/full-tree.md](references/full-tree.md) when you need the expanded tree, including module internals.

### Module layout

```
modules/invoices/
  index.ts          # public API: the only file others may import
  routes.tsx        # route objects for this module
  pages/            # route-level components
  components/       # module-private UI
  hooks/            # module-private hooks
  queries/          # query and mutation hooks, query keys, request functions
  types/            # module types
```

- Start flat: put files in the module root. Add subfolders once the module passes about 8 files.
- Export from `index.ts` only what other modules or `core/app` need.

## Naming conventions

- Modules: kebab-case domain nouns, such as `invoices` or `user-profile`.
- Files and folders: kebab-case for everything, such as `invoice-table.tsx` and `use-invoices.ts`. Do not mix casing.
- Components: the export is PascalCase and the file is its kebab-case form: `InvoiceTable` in `invoice-table.tsx`.
- Exports: use named exports. Avoid default exports.
- Hooks: `use-thing.ts` for UI logic. Data hooks go in queries, not `hooks/`. Queries: `invoice.queries.ts`, exporting `invoiceKeys`, `useInvoices`, `useCreateInvoice`. Types: `invoice.types.ts`.
- Routes: pages are `invoice-list-page.tsx`. URL paths are kebab-case.
- Do not repeat the module name in file names inside the module, unless the name is the domain entity.
- Imports: use `@/core/...` and `@/modules/...`. Never use `../../..`.

## Dependency direction

```
main -> core/app -> modules -> core
```

- `core` never imports from `modules`.
- A module imports `core` freely.
- A module imports another module only through that module's `index.ts`.
- Never import another module's internal files.
- Prefer composing two modules in a page in `core/app` over coupling them. Avoid circular module imports.
- Move code to `core` only when 3+ modules need it and it has no domain meaning.

## Where things live

- Config: `core/config/`. Read `import.meta.env` only in `core/config/env.ts`.
- Env vars: prefix with `VITE_`. List every var in `.env.example` at the repo root.
- Shared types: generic ones in `core/types/`. Domain types in the owning module's `types/`.
- Query client: create it in `core/api/query-client.ts`. Mount the provider in `core/app`.
- Global state: app-wide state in `core/store/`. Domain state in the owning module. Keep UI state local.

## Tests

- Put tests next to the file: `invoice-table.tsx`, `invoice-table.test.tsx`.
- Put test setup and shared helpers in `core/test/`.
- Test a module through its public API when possible.
- Put end-to-end tests in `e2e/` at the repo root, grouped by module name.

## Structure at three sizes

Read [references/growth-stages.md](references/growth-stages.md) when deciding whether to restructure.

### Prototype

Use `react-layered-architecture` or a flat `src/`. Do not start with modules for a single screen.

### Mid-size

Use `core/` plus 2 to 6 flat modules.
Signal to move up: a module passes about 20 files, two teams edit one module, or modules import each other's internals.

### Large

Give big modules subfolders. Enforce boundaries with lint rules. Split a module into submodules when it holds two domains.
Signal to extract packages: a second app needs `core/`.

## Anti-patterns

Read [references/anti-patterns.md](references/anti-patterns.md) when reviewing a layout or before moving files.

- Do not import `modules/` from `core/`.
- Do not deep-import `modules/x/components/Y`. Import from `modules/x`.
- Do not create a `shared/` or `common/` folder inside or beside `modules/`.
- Do not put domain logic in `core/`.
- Do not create a module per page. A module is a domain.
- Do not re-export everything from `index.ts`.
- Do not share state between modules through globals. Pass it through props or `core/store`.
- Do not write query keys inline. Use the module's key factory.
- Do not copy query data into `useState` or `core/store`.
- Do not use deep relative imports. Use aliases.
- Do not use PascalCase or camelCase file names, or rename a file only to change its case.
