# Full tree

A large domain-based Next.js app (App Router, TypeScript).

```
.
├── .env.example
├── next.config.ts                # cacheComponents: true
├── package.json
├── tsconfig.json                 # "@/*" -> "src/*"
├── e2e/
│   ├── invoices/
│   └── auth/
└── src/
    ├── proxy.ts                  # optimistic auth redirects, headers
    ├── app/
    │   ├── layout.tsx            # mounts components/providers
    │   ├── global-error.tsx
    │   ├── not-found.tsx
    │   ├── (marketing)/
    │   │   └── page.tsx
    │   ├── (auth)/
    │   │   ├── _components/
    │   │   │   └── login-form.tsx
    │   │   ├── _actions/
    │   │   │   └── sign-in.action.ts
    │   │   ├── _schemas/
    │   │   │   └── auth.schema.ts
    │   │   ├── _public.ts
    │   │   └── login/page.tsx
    │   ├── (invoices)/
    │   │   ├── _components/
    │   │   │   ├── invoice-status-badge.tsx
    │   │   │   └── invoice-form.tsx          # "use client"
    │   │   ├── _actions/
    │   │   │   ├── create-invoice.action.ts  # "use server"
    │   │   │   ├── list-invoices.action.ts   # read, called by queryFn
    │   │   │   └── delete-invoice.action.ts
    │   │   ├── _queries/
    │   │   │   ├── invoice.queries.ts        # keys, queryOptions, mutations
    │   │   │   └── invoice.queries.test.ts
    │   │   ├── _services/
    │   │   │   ├── invoice.service.ts        # server-only, 'use cache'
    │   │   │   └── invoice.service.test.ts
    │   │   ├── _schemas/
    │   │   │   └── invoice.schema.ts
    │   │   ├── _types/
    │   │   │   └── invoice.types.ts
    │   │   ├── _public.ts                    # e.g. InvoiceStatusBadge
    │   │   └── invoices/
    │   │       ├── page.tsx                  # prefetch + HydrationBoundary
    │   │       ├── loading.tsx
    │   │       ├── _components/
    │   │       │   ├── invoice-list.tsx      # "use client", useSuspenseInfiniteQuery
    │   │       │   └── invoice-filters.tsx
    │   │       ├── new/page.tsx
    │   │       └── [id]/
    │   │           ├── page.tsx
    │   │           └── _components/invoice-detail.tsx
    │   └── api/                              # exceptions only
    │       ├── auth/[...all]/route.ts        # Better Auth
    │       ├── trpc/[trpc]/route.ts
    │       ├── webhooks/stripe/route.ts
    │       └── events/route.ts               # streaming / SSE
    ├── components/                           # shared, domain-free UI
    │   ├── ui/
    │   │   ├── button.tsx
    │   │   └── dialog.tsx
    │   └── providers/
    │       ├── app-providers.tsx
    │       └── query-provider.tsx            # "use client"
    ├── hooks/
    │   └── use-debounce.ts
    ├── lib/
    │   ├── auth/
    │   │   ├── auth.ts                       # server config
    │   │   └── auth-client.ts
    │   ├── query/
    │   │   └── get-query-client.ts           # React cache() on server
    │   ├── action-result.ts                  # shared action return type
    │   └── format-date.ts
    ├── db/
    │   ├── client.ts
    │   ├── schema/
    │   └── migrations/
    ├── config/
    │   └── env.ts                            # only place that reads process.env
    ├── types/
    ├── styles/
    │   └── global.css
    └── test/
        └── setup.ts
```

Notes:

- Only `_public.ts` is importable from outside a domain.
- Shared folders have no business logic and never import `app/`.
- Keep a domain flat until it passes about 8 files per `_` folder concept.
- `page.tsx` and `layout.tsx` stay thin: compose, prefetch, render.
