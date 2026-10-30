---
name: tanstack-start-architecture
description: Use when creating, moving, or naming files in a full-stack TanStack Start app (file-based routes, server functions) that also uses TanStack Query, Form, Table, DB, and Devtools, organized by technical layer. Covers routes, server/ (functions, middleware, services, db), lib/queries, lib/mutations, lib/collections, SSR prefetching, server route exceptions, tests, and growth. For frontend-only, use tanstack-router-architecture.
license: MIT
---

# TanStack Start architecture

Full-stack React app with TanStack Start (TanStack Router plus server functions), grouped by technical role. Same client layers as `tanstack-router-architecture`, plus a top-level `server/` folder. Data code lives in `lib/queries`, `lib/mutations`, and `lib/collections`, and calls server functions. For a frontend-only app, use `tanstack-router-architecture`.

## Target version

Written for TanStack Start (`@tanstack/react-start`, Vite-based), Router v1, Query v5, Form, Table, DB, and Devtools on 2026-10-30. Start's API still changes between releases, so check the installed version for the router entry file and server route syntax.

## Follow the repo first

Read `src/` before creating files. If the project already has conventions (folder names, casing, aliases), use them. Check `vite.config.ts` for the Start plugin and `tsconfig.json` for aliases.

## Default directory layout

```
src/
  router.tsx            # createRouter, query client, SSR-query integration
  routeTree.gen.ts      # generated. Commit it. Never edit it.
  start.ts              # global middleware and start config
  routes/               # file-based routes, thin
    __root.tsx          # document shell, providers, devtools
    index.tsx
    invoices/
      route.tsx
      index.tsx
      $invoiceId.tsx
      -components/      # route-private UI (the - prefix is ignored by the router)
    api/                # server routes: exceptions only (see below)
  components/
    ui/  forms/  tables/  providers/
  hooks/
  lib/                  # client-safe code
    queries/            # query keys and queryOptions, call server functions
    mutations/          # mutationOptions and useMutation hooks
    collections/        # TanStack DB collections
    forms/  schemas/  auth/  utils/
  server/               # server-only code
    functions/          # createServerFn handlers
    middleware/         # auth, logging, validation middleware
    services/           # business logic
    db/                 # ORM client, schema, migrations
  config/               # client env and constants
  types/  styles/  test/
```

Read [references/full-tree.md](references/full-tree.md) when you need the expanded tree. Read [references/data-layer.md](references/data-layer.md) when writing server functions, queries, mutations, collections, loaders, forms, or tables.

- Add a folder on first use. Do not create empty ones.
- Keep a component in the route's `-components/` until a second route uses it.
- Route files do routing only: path, search schema, loader, composition.

## Naming conventions

- Files and folders: kebab-case. Route files follow router conventions.
- Components: `InvoiceTable` in `invoice-table.tsx`. Named exports, except route files, which export `Route`.
- Server functions: `invoice.functions.ts`, exporting `listInvoicesFn`, `createInvoiceFn`.
- Middleware: `auth.middleware.ts`. Services: `invoice.service.ts`.
- Queries: `invoice.queries.ts`. Mutations: `invoice.mutations.ts`. Collections: `invoice.collection.ts`.
- Schemas: `invoice.schema.ts`. Types: `invoice.types.ts`. Hooks: `use-thing.ts`.
- Tests: next to the file. Imports: `@/` maps to `src/`.

## Dependency direction

```
routes -> components -> hooks -> lib/{queries,mutations,collections} -> server/functions -> server/services -> server/db
```

- `lib/queries`, `lib/mutations`, `lib/collections` call `server/functions` only. They never import `server/services` or `server/db`.
- `server/functions` validate input with `lib/schemas`, apply `server/middleware`, call `server/services`. No business logic.
- `server/services` and `server/db` are imported only by `server/` files and server routes. Never by components or `lib/`.
- `components` never import `routes`. `lib/utils`, `lib/schemas`, and `types` are shared by both sides and import nothing from the app.

## Server routes: exceptions only

Add `routes/api/<name>.ts` only for: webhooks, an auth library handler, streaming or SSE endpoints, or endpoints for mobile and other platforms. Keep handlers thin and call `server/services`. Everything else is a server function.

## Where things live

- Env: client vars in `config/env.ts` (`import.meta.env`, `VITE_` prefix). Server secrets in `server/env.ts` (`process.env`), validated at startup. Never import `server/env.ts` from client code. List vars in `.env.example`.
- Query client: create per request in `router.tsx`, pass through router context, and connect with the Router SSR-query integration.
- Devtools: mount Router, Query, and DB devtools in `routes/__root.tsx`, dev only.
- Auth: session helpers in `lib/auth/` (client-safe), session reading and guards in `server/middleware/auth.middleware.ts`. Guard routes with `beforeLoad` in a layout route.
- Client state: prefer search params and the query cache.

## Tests

- Put tests next to the file. Put setup and helpers in `test/`.
- Test services and server function handlers without rendering. Test components with a router and query client wrapper.
- Put end-to-end tests in `e2e/` at the repo root.

## Structure at three sizes

Read [references/growth-stages.md](references/growth-stages.md) when deciding whether to restructure.

### Prototype

Use `routes/`, `components/`, `lib/`. Add `server/functions` and `server/db` on first use.

### Mid-size

Use the default layout. Past about 10 files in a layer, group by resource inside it (`server/services/billing/`).

### Large

Keep the layers. Group by feature inside each layer and mirror it in `routes/`. Enforce boundaries with lint rules.

## Anti-patterns

Read [references/anti-patterns.md](references/anti-patterns.md) when reviewing a layout or before moving files.

- Do not import `server/services` or `server/db` from client code.
- Do not put business logic in server functions or routes.
- Do not add a server route where a server function works.
- Do not write query keys inline. Use the key factory.
- Do not fetch in `useEffect`. Use a loader plus `ensureQueryData`.
- Do not trust server function input. Validate it and check auth in middleware.
- Do not put non-route files in `routes/` without a `-` prefix.
- Do not use PascalCase file names.
