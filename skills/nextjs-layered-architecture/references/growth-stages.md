# Growth stages

## Prototype

```
src/
  app/
  components/
  lib/
```

Stay here while there is no database and one or two pages.
Move up when: you add a database or the second mutation.
Moves: add `db/`, `actions/`, `services/` as you need them. Do not create empty folders.

## Mid-size

The default layout in SKILL.md.
Stay here while one feature change touches at most 2 to 4 top-level folders.
Move up when any of these is true:

- A layer passes about 30 files.
- One feature change touches 4+ top-level folders.
- Several people collide in the same folders.
- A mobile app or third party needs your API.

## Large

Switch to `nextjs-domain-architecture`, one feature at a time:

1. Create `app/(feature)/` with `_components`, `_actions`, `_queries`, `_services`, `_schemas`.
2. Move that feature's files out of the top-level layers and update imports.
3. Leave generic code (`db/`, `lib/`, `config/`, `components/ui/`, `components/providers/`) where it is. It is already shared.
4. Repeat per feature. The app builds after each step.
