# Anti-patterns

## Non-private folders in app/

Bad: `app/(invoices)/components/`.
Cost: easy to turn into a route by adding a `page.tsx`, and unclear what is routable.
Fix: prefix every non-route folder with `_`: `_components/`.

## Reaching into another domain

Bad: `import { InvoiceTable } from '@/app/(invoices)/invoices/_components/invoice-table'`.
Cost: internals become public, so refactors break other domains.
Fix: export it from `(invoices)/_public.ts` and import that.

## Business logic in actions or components

Bad: pricing and status rules inside `create-invoice.action.ts`.
Cost: logic cannot be reused by a webhook or route handler, and is hard to test.
Fix: put it in `_services/invoice.service.ts`. Actions validate, authorize, call, revalidate.

## Route handler where an action works

Bad: `app/api/invoices/route.ts` called only by your own forms.
Cost: hand-written fetch, types, and validation for no reason.
Fix: use a server action. Keep route handlers for auth libraries, tRPC, webhooks, streaming, and external clients.

## Fetching your own API from a server component

Bad: `await fetch('/api/invoices')` in `page.tsx`.
Cost: extra network hop, lost types, no cache tags.
Fix: call the `_service` directly.

## TanStack Query for everything

Bad: `useQuery` for a static settings page.
Cost: client bundle, loading spinners, and lost server caching.
Fix: render in a server component with `'use cache'`. Use the query client for pagination, infinite scroll, polling, and client mutations.

## Awaiting every prefetch

Bad: `await` on five `prefetchQuery` calls in one page.
Cost: the slowest query blocks the whole page.
Fix: await only above-the-fold data. Call the rest with `void` and a Suspense boundary.

## Inline query keys and options

Bad: `useQuery({ queryKey: ['invoices', id], queryFn: ... })` in a component.
Cost: server prefetch and client keys drift, invalidation misses.
Fix: use `invoiceKeys` and `invoiceDetailOptions` from `_queries/`.

## Unvalidated, unauthorized actions

Bad: an action that trusts its argument and the caller.
Cost: actions are public POST endpoints.
Fix: parse with zod and check the session inside every action.

## Domain code in shared folders

Bad: `lib/calculate-invoice-total.ts`, or a `shared/` folder.
Cost: `lib/` becomes a second app with no rules.
Fix: move it to the owning domain's `_services`.

## Mixed file casing

Bad: `InvoiceTable.tsx` beside `use-invoices.ts`.
Cost: case-insensitive file systems hide rename bugs that fail on Linux CI.
Fix: kebab-case for all files and folders. PascalCase only for component names in code.
