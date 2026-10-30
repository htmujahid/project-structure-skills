# Growth stages

## Prototype

Do not use domains yet. Use the `nextjs-layered-architecture` skill.
Move up when: there are 3+ distinct business areas, or more than one team works on the app.

## Mid-size

```
src/
  app/
    (auth)/
    (invoices)/
    (customers)/
  components/  lib/  db/  hooks/  config/  ...
```

Use 2 to 6 domains. Keep `_` folders to the ones you use. Add `_services/` as soon as a second caller (action, page, or handler) needs the same logic.
Move up when any of these is true:

- A domain passes about 25 files.
- Two teams edit the same domain.
- Domains import each other's `_` folders.

## Large

- Split a domain that holds two business areas into two route groups.
- Enforce boundaries with lint rules: no shared-folder `-> app`, no cross-domain `_` imports except `_public.ts`.
- Add `app/api/` handlers only when a mobile app or third party needs them. Back them with the same `_services`.
- Extract the shared folders into a workspace package only when a second app needs them.

Moves, one at a time:

1. Move business logic from actions into `_services`.
2. Add `_public.ts` per domain and switch cross-domain imports to it.
3. Add the lint rules and fix violations.
4. Split the domain. Move files, then update imports.
5. The app builds and runs after each step.

## From layered

1. Pick one feature. Create its route group with `_components`, `_actions`, `_queries`, `_services`.
2. Move that feature's files out of top-level `components/`, `actions/`, `queries/`, `services/`.
3. Keep generic code (`db/`, `lib/`, `config/`, `components/ui/`) out of the feature and into the top-level folders.
4. Repeat per feature. Do not rewrite everything at once.
