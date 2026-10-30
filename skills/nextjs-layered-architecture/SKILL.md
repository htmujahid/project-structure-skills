---
name: nextjs-layered-architecture
description: Use when creating, moving, or naming files in a full-stack Next.js App Router app organized by technical layer (components, actions, services, queries, db). Best for small to mid-size apps. Covers layout, naming, import direction, server actions, TanStack Query, route handler exceptions, tests, and when to move to nextjs-domain-architecture.
license: MIT
---

# Next.js layered architecture

Full-stack Next.js App Router app, grouped by technical role. Routes stay thin in `app/`. Mutations use server actions. Use for small to mid-size projects. For large apps and teams, use `nextjs-domain-architecture`.

## Target version

Written for Next.js 16 (App Router, React 19, TypeScript, Cache Components) and TanStack Query v5 on 2026-10-30. Pages Router is out of scope.

## Follow the repo first

Read `src/` before creating files. If the project already has conventions (folder names, casing, aliases), use them. Check `tsconfig.json` for aliases and `next.config.ts` for `cacheComponents`.

## Default directory layout

```
src/
  app/              # routes only: page, layout, loading, route.ts
    _components/    # UI used by one route; nest per route as needed
    api/            # route handlers, exceptions only (see below)
  components/       # shared UI used by 2+ routes
    ui/             # generic primitives (Button, Dialog)
    providers/      # client providers (query, theme)
  hooks/            # shared client hooks
  queries/          # TanStack query keys, queryOptions, mutation hooks
  actions/          # "use server" mutations and client-callable reads
  services/         # server-only business logic
  db/               # client, schema, migrations
  schemas/          # zod schemas shared by forms and actions
  lib/              # infrastructure and pure helpers
    auth/  query/   # auth setup, query client
  config/           # env parsing and constants
  types/
  styles/
  test/
```

Read [references/full-tree.md](references/full-tree.md) when you need the expanded tree.

- Add a folder on first use. Do not create empty ones.
- Put a component in `app/<route>/_components/` until a second route uses it, then move it to `components/`.
- Every non-route folder inside `app/` starts with `_`.

## Naming conventions

- Files and folders: kebab-case. Next special files keep their fixed names.
- Components: `UserCard` in `user-card.tsx`. Named exports, except where Next requires a default export (pages, layouts).
- Actions: `create-user.action.ts`, exporting `createUserAction`.
- Queries: `user.queries.ts`, exporting `userKeys`, `userListOptions`, `useCreateUser`.
- Services: `user.service.ts`. Schemas: `user.schema.ts`. Types: `user.types.ts`.
- Hooks: `use-thing.ts`.
- Tests: `user.service.test.ts` next to the file.
- Imports: `@/` maps to `src/`. Never use `../../..`.

## Dependency direction

```
app -> components -> hooks, queries -> actions -> services -> db -> lib
```

- `app` may import any layer below.
- `components` import `hooks`, `queries`, `lib`, `types`. Never `app`, `services`, or `db`.
- `queries` call `actions` only. No server code.
- `actions` validate with `schemas`, authorize, call `services`, then revalidate. No business logic.
- `services` and `db` import `server-only`. Server components may call `services` directly for reads.
- `lib` and `types` import nothing from the app.

## Data and mutations

Read [references/data-fetching.md](references/data-fetching.md) when writing a read, a mutation, or a prefetch.

- Mutations: server actions. Use `useActionState` for plain forms. Use `useMutation` when the client cache must update.
- Server cache: `'use cache'` with `cacheTag` in `services/`. Actions call `updateTag` or `revalidateTag`.
- TanStack Query is for pagination, infinite scroll, lazy loading, polling, and client-side mutations. Do not use it for static, SEO-critical, or read-once data.
- Prefetch in the server page and wrap the client part in `HydrationBoundary`. Await above-the-fold data. Stream the rest by not awaiting.
- Query functions call server actions, not `fetch`.

## Route handlers: exceptions only

Add `app/api/<name>/route.ts` only for: an auth library endpoint (Better Auth), tRPC, webhooks, streaming or SSE endpoints, or endpoints for mobile and other platforms. Keep handlers thin and call `services/`. Everything else is a server action.

## Where things live

- Config: `config/env.ts` parses `process.env` with zod. Split server and `NEXT_PUBLIC_` vars. Read `process.env` nowhere else. List every var in `.env.example`.
- Query client: `lib/query/get-query-client.ts`. Provider in `components/providers/`.
- Auth: `lib/auth/`. Proxy (formerly middleware): `src/proxy.ts`.
- Shared types: `types/`. Keep a type next to its only user until a second file needs it.
- Client state: local first. Keep server data in the query cache or server cache, not in a store.

## Tests

- Put tests next to the file.
- Put setup and helpers in `test/`.
- Test services and actions without rendering. Test components with a query client wrapper.
- Put end-to-end tests in `e2e/` at the repo root.

## Structure at three sizes

Read [references/growth-stages.md](references/growth-stages.md) when deciding whether to restructure.

### Prototype

Use `app/`, `components/`, and `lib/`. Add `actions/`, `services/`, `db/` on first use.
Signal to move up: a database, or a second mutation.

### Mid-size

Use the default layout. Add subfolders inside a layer past about 10 files, for example `services/billing/`.
Signal to move up: a layer passes about 30 files, one feature change touches 4+ top-level folders, or people collide in the same folders.

### Large

Switch to `nextjs-domain-architecture`. Move one feature at a time.

## Anti-patterns

Read [references/anti-patterns.md](references/anti-patterns.md) when reviewing a layout or before moving files.

- Do not put non-route folders in `app/` without a leading `_`.
- Do not put business logic in actions or components. Use `services/`.
- Do not add a route handler where a server action works.
- Do not call `fetch` to your own app from a server component.
- Do not write query keys inline. Use the key factory.
- Do not use a query for data a server component can render with `'use cache'`.
- Do not import `services/` or `db/` from client components.
- Do not create `common/`, `misc/`, or `helpers/` folders.
- Do not use PascalCase file names.
