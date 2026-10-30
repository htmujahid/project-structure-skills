# Data layer

Queries, mutations, and collections are separate folders in `lib/`. Each file covers one resource. Only `lib/api/` talks to the backend.

## API

```ts
// lib/api/invoice.api.ts
export const listInvoices = (filters: InvoiceFilters) =>
  client.get('/invoices', { params: filters }).then(invoiceListSchema.parse)
```

## Queries

```ts
// lib/queries/invoice.queries.ts
export const invoiceKeys = {
  all: ['invoices'] as const,
  list: (f: InvoiceFilters) => [...invoiceKeys.all, 'list', f] as const,
  detail: (id: string) => [...invoiceKeys.all, 'detail', id] as const,
}

export const invoiceListOptions = (f: InvoiceFilters) =>
  queryOptions({ queryKey: invoiceKeys.list(f), queryFn: () => listInvoices(f) })
```

Use the same options object in loaders and components.

## Loaders

```ts
// routes/_authed/invoices/index.tsx
export const Route = createFileRoute('/_authed/invoices/')({
  validateSearch: invoiceSearchSchema,
  loaderDeps: ({ search }) => search,
  loader: ({ context: { queryClient }, deps }) =>
    queryClient.ensureQueryData(invoiceListOptions(deps)),
  component: InvoiceList,
})
```

- Return the promise from `ensureQueryData` to block navigation on critical data.
- Call `queryClient.prefetchQuery` without returning it to start a fetch and not block.
- The component reads with `useSuspenseQuery(invoiceListOptions(deps))`. Use `useQuery` for lazy or interaction-driven data.
- Use `useInfiniteQuery` for infinite lists and keep previous data for pagination.

## Mutations

```ts
// lib/mutations/invoice.mutations.ts
export function useCreateInvoice() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: createInvoice,
    onSuccess: () => qc.invalidateQueries({ queryKey: invoiceKeys.all }),
  })
}
```

Keep invalidation in the mutation file, not in the component.

## Collections (TanStack DB)

```ts
// lib/collections/invoice.collection.ts
export const invoiceCollection = createCollection(
  queryCollectionOptions({
    queryKey: invoiceKeys.all,
    queryFn: () => listInvoices({}),
    queryClient,
    getKey: (i) => i.id,
    onInsert: async ({ transaction }) => { /* call lib/api */ },
  }),
)
```

- Use a collection when many views need the same normalized data, instant optimistic writes, or cross-collection live queries.
- Use a plain query for one-off server-state reads. Do not mirror the same resource in both.
- Read with `useLiveQuery` in a hook under `hooks/` or in the component. Preload in the route loader with `collection.preload()` when needed.
- Share the `queryClient` instance from one module.

## Forms (TanStack Form)

- Set up `createFormHook` once in `lib/forms/form.ts` with field components from `components/forms/`.
- Put the schema in `lib/schemas/` and pass it as the form validator.
- The submit handler calls a mutation from `lib/mutations/`.

## Tables (TanStack Table)

- Generic table in `components/tables/data-table.tsx`.
- Column definitions next to the route that owns them (`-components/invoice-columns.tsx`). Move to `components/tables/` on second use.
- Table state (pagination, sorting, filters) lives in route search params, not local state, when it should survive reloads and links.
