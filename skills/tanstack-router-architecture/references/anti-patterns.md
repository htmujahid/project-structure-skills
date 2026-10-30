# Anti-patterns

## Fetching in components

Bad: `fetch('/api/invoices')` or `client.get` inside a component or `useEffect`.
Cost: no cache, no dedupe, waterfalls, and no loader prefetch.
Fix: write a `queryOptions` factory in `lib/queries/`, prefetch it in the loader, read with `useSuspenseQuery`.

## Inline query keys

Bad: `useQuery({ queryKey: ['invoices', id], queryFn })` in a component.
Cost: loader and component keys drift, invalidation misses.
Fix: use `invoiceKeys` and the options factory.

## Mixing queries and mutations in one file

Bad: `lib/invoice.ts` with reads, writes, and collection setup.
Cost: unclear ownership, circular imports.
Fix: split into `lib/queries/invoice.queries.ts`, `lib/mutations/invoice.mutations.ts`, `lib/collections/invoice.collection.ts`.

## Two sources of truth

Bad: the same resource in a query and a TanStack DB collection.
Cost: stale and conflicting copies.
Fix: pick one per resource. Back the collection with the query keys if both are needed.

## Fat routes

Bad: a route file with forms, tables, and fetch logic.
Cost: slow to read, impossible to reuse.
Fix: keep the route to path, search schema, loader, and composition. Move UI to `-components/`.

## Non-route files in routes/

Bad: `routes/invoices/invoice-table.tsx` without a prefix.
Cost: the plugin treats it as a route.
Fix: name it `-components/invoice-table.tsx`, or put it in `components/`.

## Editing routeTree.gen.ts

Bad: hand-editing or ignoring the generated file.
Cost: edits are overwritten, and build breaks on a stale tree.
Fix: let the plugin generate it and commit it.

## Component importing routes

Bad: `components/` imports from `routes/`.
Cost: cycles with the route tree.
Fix: pass data by props, or use `getRouteApi('/path')` for typed hooks.

## Backend code in the app

Bad: ORM or secret keys in `src/`.
Cost: leaks secrets, wrong boundary.
Fix: keep the backend elsewhere. Use `lib/api/` only. Use `tanstack-start-architecture` for full-stack.

## Mixed file casing

Bad: `InvoiceTable.tsx` beside `use-invoices.ts`.
Cost: case-insensitive file systems hide rename bugs that fail on Linux CI.
Fix: kebab-case for every file and folder.
