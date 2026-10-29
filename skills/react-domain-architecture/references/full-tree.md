# Full tree

A large domain-based React app (Vite, TypeScript).

```
.
├── .env.example
├── index.html
├── package.json
├── tsconfig.json                # "@/*" -> "src/*"
├── vite.config.ts
├── e2e/
│   ├── invoices/
│   └── auth/
└── src/
    ├── main.tsx
    ├── app.tsx
    ├── core/                    # no business logic, never imports modules/
    │   ├── app/
    │   │   ├── app-providers.tsx
    │   │   ├── router.tsx       # composes each module's routes
    │   │   └── app-layout.tsx
    │   ├── api/
    │   │   ├── http-client.ts
    │   │   ├── query-client.ts
    │   │   └── api-error.ts
    │   ├── config/
    │   │   └── env.ts           # only place that reads import.meta.env
    │   ├── ui/
    │   │   ├── button/
    │   │   │   ├── button.tsx
    │   │   │   └── button.test.tsx
    │   │   └── modal.tsx
    │   ├── hooks/
    │   │   └── use-debounce.ts
    │   ├── lib/
    │   │   └── format-date.ts
    │   ├── store/
    │   │   └── session-store.ts
    │   ├── types/
    │   │   └── pagination.types.ts
    │   ├── styles/
    │   │   └── global.css
    │   └── test/
    │       └── setup.ts
    └── modules/
        ├── auth/                # small module: flat
        │   ├── index.ts
        │   ├── routes.tsx
        │   ├── login-page.tsx
        │   └── auth.queries.ts
        └── invoices/            # large module: subfolders
            ├── index.ts         # public API
            ├── routes.tsx
            ├── pages/
            │   ├── invoice-list-page.tsx
            │   └── invoice-detail-page.tsx
            ├── components/
            │   ├── invoice-table.tsx
            │   └── invoice-table.test.tsx
            ├── hooks/
            │   └── use-invoice-filters.ts
            ├── queries/
            │   └── invoice.queries.ts
            └── types/
                └── invoice.types.ts
```

Notes:

- Only `index.ts` is importable from outside a module.
- Keep a module flat until it passes about 8 files.
