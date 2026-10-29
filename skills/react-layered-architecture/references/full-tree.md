# Full tree

A mid-size layered React app (Vite, TypeScript).

```
.
├── .env.example                 # every VITE_ var, no secrets
├── index.html
├── package.json
├── tsconfig.json                # "@/*" -> "src/*"
├── vite.config.ts
├── e2e/                         # end-to-end tests
│   └── login.spec.ts
├── public/                      # static files served as-is
└── src/
    ├── main.tsx                 # mounts <App />
    ├── app.tsx                  # providers + router
    ├── pages/
    │   ├── home-page.tsx
    │   ├── login-page.tsx
    │   └── users/               # group pages by area when > ~10
    │       ├── user-list-page.tsx
    │       └── user-detail-page.tsx
    ├── components/
    │   ├── ui/                  # generic primitives
    │   │   ├── button.tsx
    │   │   └── button.test.tsx
    │   ├── forms/               # subfolder once a layer grows
    │   │   └── text-field.tsx
    │   └── user-card/           # folder when a component has CSS/subparts
    │       ├── user-card.tsx
    │       ├── user-card.module.css
    │       └── user-card.test.tsx
    ├── hooks/
    │   └── use-debounce.ts      # generic hooks only; data hooks go in queries/
    ├── queries/
    │   ├── api-client.ts        # shared HTTP client
    │   └── user.queries.ts      # userKeys, fetchers, useUsers, useCreateUser
    ├── store/
    │   └── auth-store.ts
    ├── utils/
    │   └── format-date.ts
    ├── types/
    │   └── user.types.ts
    ├── config/
    │   ├── env.ts               # only place that reads import.meta.env
    │   └── query-client.ts      # QueryClient defaults
    ├── styles/
    │   └── global.css
    └── test/
        └── setup.ts
```

Notes:

- A component used by one page lives next to that page, not in `components/`.
- Add a subfolder inside a layer only when the layer passes about 10 files.
