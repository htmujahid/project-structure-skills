# Full tree

A mid-size TanStack Start app (Vite, TypeScript).

```
.
├── .env.example
├── package.json
├── tsconfig.json                    # "@/*" -> "src/*"
├── vite.config.ts                   # tanstackStart() plugin, then react()
├── drizzle.config.ts                # or your ORM's config
├── e2e/
└── src/
    ├── router.tsx
    ├── routeTree.gen.ts             # generated
    ├── start.ts                     # global middleware
    ├── routes/
    │   ├── __root.tsx
    │   ├── index.tsx
    │   ├── login.tsx
    │   ├── _authed/                 # pathless layout, beforeLoad guard
    │   │   ├── route.tsx
    │   │   └── invoices/
    │   │       ├── route.tsx
    │   │       ├── index.tsx        # loader: prefetch + ensureQueryData
    │   │       ├── $invoiceId.tsx
    │   │       └── -components/
    │   │           ├── invoice-filters.tsx
    │   │           └── invoice-list.tsx
    │   └── api/                     # exceptions only
    │       ├── auth/$.ts            # auth library handler
    │       ├── webhooks/stripe.ts
    │       └── events.ts            # streaming / SSE
    ├── components/
    │   ├── ui/
    │   ├── forms/
    │   ├── tables/
    │   └── providers/
    │       ├── app-providers.tsx
    │       └── devtools.tsx
    ├── hooks/
    ├── lib/                         # client-safe
    │   ├── queries/
    │   │   └── invoice.queries.ts
    │   ├── mutations/
    │   │   └── invoice.mutations.ts
    │   ├── collections/
    │   │   └── invoice.collection.ts
    │   ├── forms/form.ts
    │   ├── schemas/invoice.schema.ts
    │   ├── auth/session.ts
    │   └── utils/format-date.ts
    ├── server/                      # server-only
    │   ├── env.ts                   # process.env, validated
    │   ├── functions/
    │   │   ├── invoice.functions.ts
    │   │   └── auth.functions.ts
    │   ├── middleware/
    │   │   ├── auth.middleware.ts
    │   │   └── logging.middleware.ts
    │   ├── services/
    │   │   ├── invoice.service.ts
    │   │   └── invoice.service.test.ts
    │   └── db/
    │       ├── client.ts
    │       ├── schema/
    │       └── migrations/
    ├── config/env.ts                # import.meta.env only
    ├── types/
    ├── styles/global.css
    └── test/setup.ts
```
