# Anti-patterns

## Non-private folders in app/

Bad: `app/invoices/components/`.
Cost: easy to turn into a route, and unclear what is routable.
Fix: prefix every non-route folder with `_`: `app/invoices/_components/`.

## Business logic in actions or components

Bad: pricing and status rules inside `create-invoice.action.ts`.
Cost: a webhook or route handler cannot reuse it, and it is hard to test.
Fix: put it in `services/invoice.service.ts`. Actions validate, authorize, call, revalidate.

## Route handler where an action works

Bad: `app/api/invoices/route.ts` called only by your own forms.
Cost: hand-written fetch, types, and validation for no reason.
Fix: use a server action. Keep route handlers for auth libraries, tRPC, webhooks, streaming, and external clients.

## Fetching your own API from a server component

Bad: `await fetch('/api/invoices')` in `page.tsx`.
Cost: extra network hop, lost types, no cache tags.
Fix: call the service directly.

## TanStack Query for everything

Bad: `useQuery` for a static settings page.
Cost: client bundle, spinners, and lost server caching.
Fix: render in a server component with `'use cache'`. Use the query client for pagination, infinite scroll, polling, and client mutations.

## Server code reaching the client

Bad: a client component imports `services/invoice.service.ts`.
Cost: build errors or leaked secrets.
Fix: call an action from a query hook. Mark services and db with `import 'server-only'`.

## Inline query keys

Bad: `useQuery({ queryKey: ['invoices', id], queryFn: ... })` in a component.
Cost: server prefetch and client keys drift, invalidation misses.
Fix: use `invoiceKeys` and the options factory from `queries/`.

## Unvalidated, unauthorized actions

Bad: an action that trusts its argument and the caller.
Cost: actions are public POST endpoints.
Fix: parse with zod and check the session inside every action.

## Single-use components in components/

Bad: `components/invoice-filters.tsx` used by one route.
Cost: the shared folder fills with one-offs.
Fix: keep it in `app/invoices/_components/` until a second route needs it.

## Mixed file casing

Bad: `InvoiceTable.tsx` beside `use-invoices.ts`.
Cost: case-insensitive file systems hide rename bugs that fail on Linux CI.
Fix: kebab-case for all files and folders.
