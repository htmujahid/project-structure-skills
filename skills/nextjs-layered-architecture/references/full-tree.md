# Full tree

A mid-size layered Next.js app (App Router, TypeScript).

```
.
├── .env.example
├── next.config.ts                # cacheComponents: true
├── package.json
├── tsconfig.json                 # "@/*" -> "src/*"
├── e2e/
└── src/
    ├── proxy.ts
    ├── app/
    │   ├── layout.tsx            # mounts providers
    │   ├── global-error.tsx
    │   ├── not-found.tsx
    │   ├── page.tsx
    │   ├── (auth)/login/
    │   │   ├── page.tsx
    │   │   └── _components/login-form.tsx
    │   ├── invoices/
    │   │   ├── page.tsx          # prefetch + HydrationBoundary
    │   │   ├── loading.tsx
    │   │   ├── _components/
    │   │   │   └── invoice-list.tsx   # "use client"
    │   │   └── [id]/page.tsx
    │   └── api/                  # exceptions only
    │       ├── auth/[...all]/route.ts
    │       ├── trpc/[trpc]/route.ts
    │       ├── webhooks/stripe/route.ts
    │       └── events/route.ts
    ├── components/
    │   ├── ui/
    │   │   ├── button.tsx
    │   │   └── dialog.tsx
    │   ├── providers/
    │   │   ├── app-providers.tsx
    │   │   └── query-provider.tsx    # "use client"
    │   └── invoice-status-badge.tsx
    ├── hooks/
    │   └── use-debounce.ts
    ├── queries/
    │   ├── invoice.queries.ts    # keys, queryOptions, mutation hooks
    │   └── user.queries.ts
    ├── actions/
    │   ├── create-invoice.action.ts   # "use server"
    │   ├── list-invoices.action.ts    # read, called by queryFn
    │   └── sign-in.action.ts
    ├── services/
    │   ├── invoice.service.ts    # server-only, 'use cache'
    │   └── user.service.ts
    ├── db/
    │   ├── client.ts
    │   ├── schema/
    │   └── migrations/
    ├── schemas/
    │   ├── invoice.schema.ts
    │   └── auth.schema.ts
    ├── lib/
    │   ├── auth/
    │   │   ├── auth.ts
    │   │   └── auth-client.ts
    │   ├── query/
    │   │   └── get-query-client.ts
    │   ├── action-result.ts
    │   └── format-date.ts
    ├── config/
    │   └── env.ts                # only place that reads process.env
    ├── types/
    ├── styles/global.css
    └── test/setup.ts
```
