# Growth stages

## Prototype

```
src/
  main.tsx
  router.tsx
  routes/
  components/
  lib/
```

Stay here while there are a few routes and one or two API calls.
Move up when: you add the second resource or the first mutation.
Moves: add `lib/api/`, `lib/queries/`, `lib/mutations/` as you need them. Do not create empty folders.

## Mid-size

The default layout in SKILL.md.
Stay here while one feature change touches at most 3 to 4 top-level folders.
Move up when any of these is true:

- A `lib/` subfolder passes about 10 files.
- `components/` passes about 30 files.
- Several people collide in the same folders.

## Large

There is no domain variant for this stack. Stay layered and group by feature inside each layer:

```
lib/queries/billing/invoice.queries.ts
lib/mutations/billing/invoice.mutations.ts
lib/collections/billing/invoice.collection.ts
routes/_authed/billing/
components/billing/
```

1. Create the feature subfolder in one layer and move that resource's files.
2. Mirror the feature name in the other layers.
3. Add lint rules: no `components -> routes`, no `lib -> components`.
4. Add `React.lazy` or route-level code splitting for heavy features (`autoCodeSplitting` in the plugin).
5. The app builds after each step.
