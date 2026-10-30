# Growth stages

## Prototype

```
src/
  router.tsx
  routes/
  components/
  lib/
  server/
    functions/
```

Stay here while there are a few routes and no database.
Move up when: you add a database or the second mutation.
Moves: add `server/db/`, `server/services/`, `server/middleware/`, `lib/queries/`, `lib/mutations/` as you need them. Do not create empty folders.

## Mid-size

The default layout in SKILL.md.
Stay here while one feature change touches at most 3 to 5 top-level folders.
Move up when any of these is true:

- A `lib/` or `server/` subfolder passes about 10 files.
- `components/` passes about 30 files.
- Several people collide in the same folders.
- A mobile app or third party needs your API (add `routes/api/` handlers backed by the same services).

## Large

There is no domain variant for this stack. Stay layered and group by feature inside each layer:

```
lib/queries/billing/invoice.queries.ts
lib/mutations/billing/invoice.mutations.ts
server/functions/billing/invoice.functions.ts
server/services/billing/invoice.service.ts
routes/_authed/billing/
components/billing/
```

1. Create the feature subfolder in one layer and move that resource's files.
2. Mirror the feature name in the other layers.
3. Add lint rules: no `components -> routes`, no client-side import of `server/` except `server/functions`.
4. Enable route code splitting for heavy features.
5. The app builds after each step.
