# Anti-patterns

## Server code reaching the client

Bad: a component or `lib/queries` file imports `server/services/invoice.service.ts` or `server/db`.
Cost: build errors, or secrets and the ORM in the client bundle.
Fix: call a server function from `lib/queries`. Only `server/` files and server routes import services and db.

## Business logic in server functions

Bad: pricing and status rules in `invoice.functions.ts`.
Cost: a webhook or server route cannot reuse it, and it is hard to test.
Fix: move it to `server/services/invoice.service.ts`. Functions validate, authorize, call.

## Unvalidated or unauthorized server functions

Bad: a handler that trusts `data` and the caller.
Cost: server functions are public endpoints.
Fix: `.inputValidator(schema)` and an auth middleware on every function.

## Server route where a server function works

Bad: `routes/api/invoices.ts` called only by your own UI.
Cost: hand-written fetch, types, and validation.
Fix: use a server function. Keep server routes for webhooks, auth handlers, streaming, and external clients.

## Fetching in components

Bad: server function or `fetch` called in `useEffect`.
Cost: no cache, waterfalls, no SSR data.
Fix: `queryOptions` in `lib/queries/`, prefetch in the loader, read with `useSuspenseQuery`.

## Awaiting every prefetch

Bad: `await` on five `ensureQueryData` calls in a loader.
Cost: the slowest query blocks navigation and first byte.
Fix: await only critical data. Use `void queryClient.prefetchQuery` for the rest with a Suspense boundary.

## Inline query keys

Bad: `useQuery({ queryKey: ['invoices', id], queryFn })` in a component.
Cost: loader and component keys drift, invalidation misses.
Fix: use `invoiceKeys` and the options factory.

## Collection importing server code

Bad: `lib/collections/invoice.collection.ts` imports `server/db`.
Cost: server code in the client bundle.
Fix: use a server function in `onInsert`, `onUpdate`, and `queryFn`.

## Two sources of truth

Bad: the same resource in a query and a TanStack DB collection.
Cost: stale and conflicting copies.
Fix: pick one per resource. Back the collection with the query keys if both are needed.

## Non-route files in routes/

Bad: `routes/invoices/invoice-table.tsx` without a prefix.
Cost: the plugin treats it as a route.
Fix: name it `-components/invoice-table.tsx`, or put it in `components/`.

## Mixed file casing

Bad: `InvoiceTable.tsx` beside `use-invoices.ts`.
Cost: case-insensitive file systems hide rename bugs that fail on Linux CI.
Fix: kebab-case for every file and folder.
