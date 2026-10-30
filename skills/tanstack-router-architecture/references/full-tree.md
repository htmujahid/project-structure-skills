# Full tree

A mid-size TanStack Router app (Vite, TypeScript).

```
.
├── .env.example
├── index.html
├── package.json
├── tsconfig.json                    # "@/*" -> "src/*"
├── vite.config.ts                   # tanstackRouter() plugin before react()
├── e2e/
└── src/
    ├── main.tsx
    ├── router.tsx
    ├── routeTree.gen.ts             # generated
    ├── routes/
    │   ├── __root.tsx               # createRootRouteWithContext, devtools
    │   ├── index.tsx
    │   ├── login.tsx
    │   ├── _authed/                 # pathless layout, beforeLoad guard
    │   │   ├── route.tsx
    │   │   ├── invoices/
    │   │   │   ├── route.tsx
    │   │   │   ├── index.tsx        # loader: ensureQueryData(invoiceListOptions)
    │   │   │   ├── $invoiceId.tsx
    │   │   │   └── -components/
    │   │   │       ├── invoice-filters.tsx
    │   │   │       └── invoice-list.tsx
    │   │   └── settings.tsx
    ├── components/
    │   ├── ui/
    │   │   ├── button.tsx
    │   │   └── dialog.tsx
    │   ├── forms/
    │   │   ├── text-field.tsx
    │   │   └── submit-button.tsx
    │   ├── tables/
    │   │   ├── data-table.tsx
    │   │   └── data-table-pagination.tsx
    │   └── providers/
    │       ├── app-providers.tsx
    │       └── devtools.tsx
    ├── hooks/
    │   ├── use-debounce.ts
    │   └── use-invoice-table.ts
    ├── lib/
    │   ├── queries/
    │   │   ├── invoice.queries.ts
    │   │   └── customer.queries.ts
    │   ├── mutations/
    │   │   └── invoice.mutations.ts
    │   ├── collections/
    │   │   ├── invoice.collection.ts
    │   │   └── index.ts
    │   ├── api/
    │   │   ├── client.ts
    │   │   ├── api-error.ts
    │   │   └── invoice.api.ts
    │   ├── forms/
    │   │   └── form.ts              # createFormHook, contexts
    │   ├── schemas/
    │   │   └── invoice.schema.ts
    │   ├── auth/
    │   │   └── session.ts
    │   └── utils/
    │       └── format-date.ts
    ├── config/
    │   └── env.ts
    ├── types/
    ├── styles/global.css
    └── test/setup.ts
```
