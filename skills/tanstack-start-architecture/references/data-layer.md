# Data layer

Server code is in `server/`. Client-safe data code is in `lib/queries`, `lib/mutations`, `lib/collections`. Each file covers one resource.

## Server functions

```ts
// server/functions/invoice.functions.ts
export const listInvoicesFn = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])
  .inputValidator(invoiceFiltersSchema)
  .handler(({ data, context }) => invoiceService.list(context.userId, data))

export const createInvoiceFn = createServerFn({ method: 'POST' })
  .middleware([authMiddleware])
  .inputValidator(createInvoiceSchema)
  .handler(({ data, context }) => invoiceService.create(context.userId, data))
```

- Validate input with a schema from `lib/schemas/`. Authorize in middleware.
- Handlers call a service. Business rules live in `server/services/`.
- Server functions are safe to import from client code. Services and db are not.

## Queries

```ts
// lib/queries/invoice.queries.ts
export const invoiceKeys = {
  all: ['invoices'] as const,
  list: (f: InvoiceFilters) => [...invoiceKeys.all, 'list', f] as const,
  detail: (id: string) => [...invoiceKeys.all, 'detail', id] as const,
}

export const invoiceListOptions = (f: InvoiceFilters) =>
  queryOptions({ queryKey: invoiceKeys.list(f), queryFn: () => listInvoicesFn({ data: f }) })
```

## Loaders and SSR

```ts
// routes/_authed/invoices/index.tsx
export const Route = createFileRoute('/_authed/invoices/')({
  validateSearch: invoiceSearchSchema,
  loaderDeps: ({ search }) => search,
  loader: async ({ context: { queryClient }, deps }) => {
    void queryClient.prefetchQuery(invoiceStatsOptions())            // stream
    await queryClient.ensureQueryData(invoiceListOptions(deps))      // block
  },
  component: InvoiceList,
})
```

- Create the query client in `router.tsx` per request and connect it with the Router SSR-query integration so prefetched and pending queries are dehydrated and streamed to the client.
- Await what the first paint or SEO needs. Do not await the rest.
- Components read with `useSuspenseQuery` wrapped in `<Suspense>`. Use `useQuery` for lazy data and `useInfiniteQuery` for infinite lists.
- Use TanStack Query for pagination, infinite scroll, lazy loading, polling, and client mutations. For a one-off read that never changes on the client, a plain loader return value is enough.

## Mutations

```ts
// lib/mutations/invoice.mutations.ts
export function useCreateInvoice() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (data: CreateInvoice) => createInvoiceFn({ data }),
    onSuccess: () => qc.invalidateQueries({ queryKey: invoiceKeys.all }),
  })
}
```

Keep invalidation in the mutation file. Call `router.invalidate()` only when loader data outside Query changes.

## Collections (TanStack DB)

```ts
// lib/collections/invoice.collection.ts
export const invoiceCollection = createCollection(
  queryCollectionOptions({
    queryKey: invoiceKeys.all,
    queryFn: () => listInvoicesFn({ data: {} }),
    queryClient,
    getKey: (i) => i.id,
    onInsert: async ({ transaction }) => { /* call a server function */ },
  }),
)
```

- Collections live on the client. Routes that read them with `useLiveQuery` should set `ssr: false` (or `'data-only'`) unless the collection is preloaded in the loader.
- Use a collection for normalized data shared by many views, instant optimistic writes, or live queries across collections. Use a plain query for one-off reads. Do not mirror one resource in both.
- Writes go through server functions. Never import `server/` from a collection file.

## Forms and tables

- Forms: set up `createFormHook` in `lib/forms/form.ts`, field components in `components/forms/`. Reuse the schema from `lib/schemas/` on the client and in the server function. Submit with a mutation.
- Tables: generic table in `components/tables/`. Column definitions beside the owning route in `-components/`. Keep pagination, sort, and filters in route search params and pass them to the loader.

## Server routes

Place under `routes/api/`. Parse and verify, then call a `server/services` function. Do not duplicate business rules in the handler.
