# Growth stages

## Prototype

The CLI default: feature folders directly under `src/`.

```
src/
  main.ts
  app.module.ts
  users/
    users.module.ts
    users.controller.ts
    users.service.ts
    user.dto.ts
```

Stay here with one or two modules and no cross-cutting plumbing.
Move up when: a second cross-cutting concern appears — a queue, a mailer, a global filter, or a guard used by two modules.
Moves: create `modules/` and `git mv` each feature folder into it; create `common/` and `infra/` only when the first shared file exists.

## Mid-size

The default layout in SKILL.md: `common/` + `infra/` + `modules/`.
Stay here while each module fits in one folder and one person can hold a module in their head.
Move up when any of these is true:

- A module passes ~15 files in one folder.
- Several modules form an obvious group that ships together (notes, projects, tasks).
- Two modules keep importing each other's exports for one workflow.
- A second deployable is needed (worker, admin API, cron runner).

## Large, one deployable

Restructure inside `src/`, one module at a time:

1. Split a fat module into submodules: `modules/auth/{common,password,mfa,oidc,token,user}/`, each with its own `*.module.ts`; the parent `auth.module.ts` only imports them and re-exports the public ones. Code shared only inside the feature goes in `modules/auth/common/`, not the top-level `common/`.
2. Group related modules under a domain folder: `modules/desk/{notes,projects,tasks}/`. The group folder has no module file of its own unless the group needs shared providers.
3. Keep `common/` and `infra/` flat; they grow by concern, not by domain.

The app compiles after each step; imports are the only change.

## Large, multiple deployables

Switch to nest-cli monorepo mode when a worker or second API must deploy separately:

1. `nest g app worker` — the CLI moves the current app to `apps/<name>/` and updates `nest-cli.json`.
2. Move code both apps need into `libs/`: `nest g library shared`. Start with `infra/` modules (database, queue, redis, config) and `common/`; feature modules move only if both apps import them.
3. Processors and cron providers move to the worker app; queue facades stay with the API; queue name constants live in the shared lib.
4. Path aliases (`@app/shared`) come from the generated `tsconfig`; never deep-import across `apps/`.

Extract a true microservice (own repo/deploy, `@nestjs/microservices` transport) only when a team boundary demands it; the module layout inside each service stays this same skill.
