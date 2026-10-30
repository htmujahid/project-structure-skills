# Data fetching and mutations

Choose per use case. Server components and server cache are the default. TanStack Query is added where the client owns the data.

| Case | Use |
| ---- | --- |
| Static or SEO data, read once | Server component calling `_services`, with `'use cache'` |
| Per-user page data, no client interaction | Server component, streamed with `<Suspense>` |
| Pagination, infinite scroll, filters, polling, lazy panels | TanStack Query, prefetched on the server |
| Plain form submit | Server action with `useActionState` |
| Mutation that updates a client list or optimistic UI | `useMutation` calling a server action |
| Webhook, auth library, tRPC, SSE, mobile client | Route handler |

## Service with server cache

```ts
// _services/invoice.service.ts
import 'server-only'
import { cacheLife, cacheTag } from 'next/cache'

export async function getInvoice(id: string) {
  'use cache'
  cacheTag(`invoice:${id}`)
  cacheLife('minutes')
  return db.query.invoices.findFirst({ where: eq(invoices.id, id) })
}
```

## Server action with zod

```ts
// _actions/create-invoice.action.ts
'use server'
import { updateTag } from 'next/cache'

export async function createInvoiceAction(input: unknown) {
  const session = await requireSession()
  const parsed = createInvoiceSchema.safeParse(input)
  if (!parsed.success) return { ok: false as const, errors: parsed.error.flatten() }
  const invoice = await invoiceService.create(session.userId, parsed.data)
  updateTag('invoices')
  return { ok: true as const, data: invoice }
}
```

- Validate every action input with the schema from `_schemas/`. The same schema validates the client form.
- Authorize inside every action. Treat actions as public endpoints.
- Return a typed result for expected errors. Throw only for unexpected ones.
- Use `updateTag` for read-your-own-writes, `revalidateTag` for background refresh.
- Reads called from `queryFn` live in `_actions/` too (`list-invoices.action.ts`). Actions run one at a time per client, so keep these for pagination and lazy loads, not for parallel waterfalls.

## Query options factory

```ts
// _queries/invoice.queries.ts
export const invoiceKeys = {
  all: ['invoices'] as const,
  list: (filters: InvoiceFilters) => [...invoiceKeys.all, 'list', filters] as const,
  detail: (id: string) => [...invoiceKeys.all, 'detail', id] as const,
}

export const invoiceListOptions = (filters: InvoiceFilters) =>
  infiniteQueryOptions({
    queryKey: invoiceKeys.list(filters),
    queryFn: ({ pageParam }) => listInvoicesAction({ ...filters, cursor: pageParam }),
    initialPageParam: null as string | null,
    getNextPageParam: (last) => last.nextCursor,
  })

export function useCreateInvoice() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: createInvoiceAction,
    onSuccess: () => qc.invalidateQueries({ queryKey: invoiceKeys.all }),
  })
}
```

Use the same options object on the server and the client so keys never drift.

## Query client

```ts
// lib/query/get-query-client.ts
export const getQueryClient = cache(() => new QueryClient({
  defaultOptions: {
    queries: { staleTime: 60_000 },
    dehydrate: { shouldDehydrateQuery: (q) => defaultShouldDehydrateQuery(q) || q.state.status === 'pending' },
  },
}))
```

On the client, keep one instance in `query-provider.tsx` (create in state or a module singleton in the browser). Set `staleTime` above 0 so hydrated data is not refetched at once.

## Prefetch and streaming

```tsx
// invoices/page.tsx (server component)
export default async function Page({ searchParams }) {
  const filters = parseFilters(await searchParams)
  const qc = getQueryClient()

  await qc.prefetchInfiniteQuery(invoiceListOptions(filters)) // critical: await
  void qc.prefetchQuery(invoiceStatsOptions())                // non-critical: stream

  return (
    <HydrationBoundary state={dehydrate(qc)}>
      <InvoiceList filters={filters} />   {/* useSuspenseInfiniteQuery */}
    </HydrationBoundary>
  )
}
```

- Await the query when the first paint needs it or it matters for SEO.
- Do not await to stream it. The pending promise is dehydrated and resolves on the client. Wrap the consumer in `<Suspense>`.
- Client components use `useSuspenseQuery` or `useSuspenseInfiniteQuery` for prefetched data. Use `useQuery` with `enabled` for lazy, interaction-driven data that is not prefetched.
- Lazy loading: skip prefetch, load with `useQuery` when the panel opens.

## Route handlers

Place under `app/api/<name>/route.ts`. Parse and verify, then call a `_service`. Do not duplicate business rules in the handler.
