# Growth stages

## Prototype

```
src/
  main.tsx
  app.tsx
  components/
```

Stay here while there is one screen and no backend calls.
Move up when: you add a second page or the first API call.
Moves: add `pages/`, `hooks/`, `queries/` as you need them. Do not create empty folders.

## Mid-size

The default layout in SKILL.md.
Stay here while one feature change touches at most 2 to 3 top-level folders.
Move up when any of these is true:

- `components/` or `hooks/` passes about 30 files.
- A typical feature change touches 4+ top-level folders.
- Several people regularly conflict in the same folders.

Moves inside this stage: add subfolders in crowded layers, for example `components/forms/`, `pages/users/`.

## Large

Switch to the `react-domain-architecture` skill. Migrate one feature at a time:

1. Create `src/core/` and move `config/`, `utils/`, `components/ui/`, and generic hooks into it.
2. Create `src/modules/<domain>/` for one feature.
3. Move that feature's page, components, hooks, queries, and types into the module.
4. Add `index.ts` exposing only what other code uses. Update imports.
5. Repeat per feature. The app keeps working after each step.
