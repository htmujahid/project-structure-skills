---
name: nextjs-domain-architecture
description: Use when creating, moving, or naming files in a full-stack Next.js App Router app organized by business domain, with route groups per domain, underscore-prefixed private folders (_components, _actions, _queries), server actions, and TanStack Query. Best for large apps and teams. Covers layout, import boundaries, data fetching, caching, route handler exceptions, tests, and growth.
license: MIT
---

# Next.js domain architecture

Full-stack Next.js App Router app, grouped by business domain. Each domain is a route group in `app/` that owns its pages and private `_` folders. Shared infrastructure lives in top-level `src/` folders (`components/`, `lib/`, `db/`, and so on), outside `app/`. Mutations use server actions. Use for large apps. For small apps, use `nextjs-layered-architecture`.

## Target version

Written for Next.js 16 (App Router, React 19, TypeScript, Cache Components) and TanStack Query v5 on 2026-10-30. Pages Router is out of scope.

## Follow the repo first

Read `src/app/` and the shared `src/` folders before creating files. If the project already has conventions (domain names, casing, aliases, lint boundaries), use them. Check `tsconfig.json` for aliases and `next.config.ts` for `cacheComponents`.

## Default directory layout

```
src/
  app/
    layout.tsx, global-error.tsx, not-found.tsx
    (auth)/                 # one route group per domain
    (invoices)/
      _components/          # UI shared by routes in this domain
      _actions/             # "use server" mutations and client-callable reads
      _queries/             # TanStack query keys, queryOptions, hooks
      _services/            # server-only business logic and db access
      _schemas/             # zod schemas shared by forms and actions
      _types/
      _public.ts            # the only file other domains may import
      invoices/
        page.tsx
        loading.tsx
        _components/        # private to this route
        [id]/page.tsx
    api/                    # route handlers, exceptions only (see below)
  components/               # shared, domain-free UI
    ui/                     # primitives (Button, Dialog)
    providers/              # client providers (query, theme)
  lib/                      # infrastructure and pure helpers
    auth/  query/           # auth setup, query client
  db/                       # client, schema, migrations
  hooks/                    # generic hooks
  config/                   # env parsing and constants
  types/  styles/  test/
```

Read [references/full-tree.md](references/full-tree.md) when you need the expanded tree.

- Underscore-prefixed folders are private and never routable. Use `_` for every non-route folder inside `app/`.
- Put a file at the lowest level that needs it: route `_components`, then domain `_components`, then `components/ui`.
- Start flat: skip `_types/` or `_schemas/` until a domain has more than a few of them.
- Route group names are domain nouns in kebab-case. They do not appear in the URL.

## Naming conventions

- Files and folders: kebab-case. Next special files keep their fixed names (`page.tsx`, `layout.tsx`, `route.ts`).
- Components: `InvoiceTable` in `invoice-table.tsx`. Named exports, except where Next requires a default export (pages, layouts).
- Actions: `create-invoice.action.ts`, exporting `createInvoiceAction`.
- Queries: `invoice.queries.ts`, exporting `invoiceKeys`, `invoiceListOptions`, `useCreateInvoice`.
- Services: `invoice.service.ts`. Schemas: `invoice.schema.ts`. Types: `invoice.types.ts`.
- Hooks: `use-thing.ts`.
- Imports: `@/` maps to `src/`. Within a domain use at most `../` or `../../`. Across domains use `@/app/(billing)/_public`.

## Dependency direction

```
page -> _components -> _queries -> _actions -> _services -> lib, db
```

- Shared folders (`components`, `hooks`, `lib`, `db`, `config`, `types`) never import from `app/`.
- `_services` import `db`, `lib`, `config`, `_schemas`, `_types`. Mark with `import 'server-only'`. Never import `_actions`, `_queries`, or components.
- `_actions` validate, authorize, call `_services`, then revalidate. No business logic.
- `_queries` call `_actions` only. They hold no server code.
- Server components may call `_services` directly for reads.
- Another domain imports only `_public.ts`. Never its `_` folders.

## Data and mutations

Read [references/data-fetching.md](references/data-fetching.md) when writing a read, a mutation, or a prefetch.

- Mutations: server actions. Use `useActionState` for plain forms. Use `useMutation` when the client cache must update.
- Server cache: `'use cache'` with `cacheTag` in `_services`. Actions call `updateTag` or `revalidateTag`.
- TanStack Query is for pagination, infinite scroll, lazy loading, polling, and client-side mutations. Do not use it for static, SEO-critical, or read-once data.
- Prefetch in the server page and wrap the client part in `HydrationBoundary`. Await only above-the-fold data. Stream the rest by not awaiting `prefetchQuery`.
- Query functions call server actions, not `fetch`.

## Route handlers: exceptions only

Add `app/api/<name>/route.ts` only for: an auth library endpoint (Better Auth), tRPC, webhooks, streaming or SSE endpoints, or endpoints for mobile and other platforms. Keep handlers thin and call `_services`. Everything else is a server action.

## Where things live

- Config: `config/env.ts` parses `process.env` with zod. Split server and `NEXT_PUBLIC_` vars. Read `process.env` nowhere else. List every var in `.env.example`.
- Query client: `lib/query/get-query-client.ts`. Provider in `components/providers/`.
- Auth, db client: `lib/auth/`, `db/`. Domain tables and queries stay in the domain's `_services`.
- Proxy (formerly middleware): `src/proxy.ts`.
- Client state: local first. Domain state in the domain. App-wide state in `lib/` or `hooks/`.

## Tests

- Put tests next to the file: `invoice.service.test.ts`.
- Put setup and helpers in `test/`.
- Test services and actions without rendering. Test components with a query client wrapper.
- Put end-to-end tests in `e2e/` at the repo root, grouped by domain.

## Structure at three sizes

Read [references/growth-stages.md](references/growth-stages.md) when deciding whether to restructure.

### Prototype

Use `nextjs-layered-architecture`. Do not start with domains.

### Mid-size

Use the shared folders plus 2 to 6 domains. Keep each domain flat. Signal to move up: a domain passes about 25 files, two teams edit one domain, or domains import each other's `_` folders.

### Large

Split domains in two. Enforce boundaries with lint rules. Signal to extract packages: a second app needs the shared folders, or a mobile app needs the API.

## Anti-patterns

Read [references/anti-patterns.md](references/anti-patterns.md) when reviewing a layout or before moving files.

- Do not put non-route folders in `app/` without a leading `_`.
- Do not import another domain's `_` folders. Use `_public.ts`.
- Do not put business logic in actions or components. Use `_services`.
- Do not add a route handler where a server action works.
- Do not call `fetch` to your own app from a server component.
- Do not write query keys inline. Use the key factory.
- Do not make a query for data a server component can render with `'use cache'`.
- Do not put domain code in `lib/`, `components/`, or `hooks/`, or create `shared/` or `common/`.
- Do not use PascalCase file names.
