---
name: nestjs-architecture
description: Use when creating, moving, or naming files in a NestJS backend organized as feature modules (modules/) with shared infrastructure (infra/) and framework plumbing (common/). Covers module layout, naming, DI boundaries, placement of pipes, guards, middleware, filters, and interceptors, config, GraphQL, CQRS, queues, websockets, tests, and growth from prototype to monorepo.
license: MIT
---

# NestJS architecture

Server-side NestJS app organized by feature module. Business features live in `modules/`, cross-cutting technical capabilities in `infra/`, reusable framework plumbing in `common/`. One app can serve REST, GraphQL, WebSockets, and background workers from this layout.

## Target version

Written for NestJS 11 and 12 (TypeScript, Express adapter by default) on 2026-11-02. v12 changes packaging (ESM) and adds Standard Schema DTO validation; it does not change layout.

## Follow the repo first

Read `src/` before creating files. Check `nest-cli.json` for `sourceRoot` and monorepo mode, `app.module.ts` for how modules are registered, and existing file suffixes. If the project keeps modules directly under `src/`, follow that until the move described in growth stages.

## Default directory layout

```
src/
  main.ts              # bootstrap only: create app, adapter setup, listen
  app.module.ts        # root module: ConfigModule + infra + feature modules
  common/              # framework plumbing used by 2+ modules, no business logic
    decorators/        # param and metadata decorators (CurrentUser, Public)
    errors/            # shared HttpException subclasses
    filters/           # exception filters (all-exceptions, query-failed)
    guards/            # guards used across modules
    interceptors/      # logging, serialization, response envelope
    middleware/        # request-id, request logging
    pipes/             # custom validation and transform pipes
  infra/               # technical capability modules, one folder per concern
    database/          # ORM module + database.config.ts
    queue/             # BullMQ connection, queue names
    mailer/            # mail module, queue + processor, mails/, templates/
    redis/  storage/  rate-limit/
  modules/             # feature modules, one folder per business capability
    users/
      users.module.ts
      users.controller.ts
      users.service.ts
      users.repository.ts
      user.entity.ts
      user.dto.ts
  i18n/                # translation catalogs, one folder per locale
test/                  # e2e specs only; unit tests are colocated
```

Read [references/full-tree.md](references/full-tree.md) when you need the expanded tree.

- Add a folder on first use. Do not create empty ones.
- A guard, filter, pipe, or interceptor used by one module lives in that module, not in `common/`.
- A large feature nests submodules: `modules/auth/{password,mfa,oidc}/`, each with its own `*.module.ts`.

## Naming conventions

- Files and folders: kebab-case with a role suffix: `users.controller.ts`, `users.service.ts`, `users.repository.ts`, `users.module.ts`.
- Plural for module, controller, service, repository; singular for data shapes: `user.entity.ts`, `user.dto.ts`, `user.types.ts`.
- One suffix per Nest concept: `.guard.ts`, `.pipe.ts`, `.filter.ts`, `.interceptor.ts`, `.middleware.ts`, `.decorator.ts`, `.exception.ts`, `.gateway.ts`, `.resolver.ts`, `.processor.ts`, `.listener.ts`, `.event.ts`, `.config.ts`.
- Classes: PascalCase with the suffix spelled out: `UsersController`, `CreateUserDto`, `AllExceptionsFilter`, `JwtAuthGuard`.
- DTOs: one `user.dto.ts` per resource exporting `CreateUserDto`, `UpdateUserDto`; split per use case only when the file passes ~5 DTOs.
- Tests: `users.service.spec.ts` next to the file. E2e: `test/users.e2e-spec.ts`.

## Dependency direction

```
modules -> infra -> common
```

- A module reaches another module only through `@Module` imports and exported providers. Never import another module's repository, entity, or internal service directly.
- Inside a module: controller -> service -> repository. Controllers hold no business logic; repositories hold no business rules.
- `common/` imports nothing from `modules/` or `infra/`.
- Export from a module only what other modules need. Everything else stays private.
- A circular dependency between two modules means a concept is missing. Extract a third module instead of reaching for `forwardRef`.

## Request lifecycle plumbing

Read [references/request-lifecycle.md](references/request-lifecycle.md) when adding or placing middleware, guards, interceptors, pipes, filters, or custom decorators.

- Execution order: middleware -> guards -> interceptors (pre) -> pipes -> handler -> interceptors (post) -> filters.
- Bind global plumbing with `APP_PIPE`, `APP_GUARD`, `APP_FILTER`, `APP_INTERCEPTOR` providers in `app.module.ts` so it gets DI. Use `app.useGlobal*` in `main.ts` only when nothing needs injection.

## Beyond REST

Read the matching reference before adding the first file of each kind:

- [references/graphql.md](references/graphql.md): resolvers, object types, inputs, dataloaders (code-first).
- [references/cqrs.md](references/cqrs.md): `commands/`, `queries/`, `events/`, `sagas/` inside a module with `@nestjs/cqrs`.
- [references/queues-and-events.md](references/queues-and-events.md): BullMQ queues and processors, event emitter listeners, `@nestjs/schedule` cron jobs.
- [references/websockets.md](references/websockets.md): gateways, adapters, event name constants.

## Where things live

- Config: `<name>.config.ts` colocated with its module using `registerAs` (`database.config.ts` in `infra/database/`, `auth.config.ts` in `modules/auth/`). `ConfigModule.forRoot` in `app.module.ts` loads and validates them. Read `process.env` nowhere else. List every var in `.env.example`.
- Entities: in the owning module, next to its repository. `infra/database/` only sets up the connection and registers migrations.
- Auth: a feature module (`modules/auth/`). It exports its guards and providers; truly app-wide guards go in `common/guards/`.
- Scheduled data cleanup: `<thing>.cleanup.ts` in the module that owns the data.
- Pure helpers: `<name>.util.ts` next to the main user. Move to `common/` on the second user, never pre-emptively.

## Tests

- Unit tests colocated: `users.service.spec.ts`. Build the unit with `Test.createTestingModule` and mock at module seams.
- E2e tests in `test/` at the app root: `*.e2e-spec.ts` booting the real `AppModule`.
- Test services, policies, and pipes directly without HTTP. Test controllers and guards through e2e.

## Structure at three sizes

Read [references/growth-stages.md](references/growth-stages.md) when deciding whether to restructure.

### Prototype

CLI default: feature folders directly under `src/` (`src/users/`), no `common/` or `infra/`.
Signal to move up: a second cross-cutting concern appears (a queue, a mailer, a guard used by two modules).

### Mid-size

The default layout above.
Signal to move up: a module passes ~15 files, or several modules form an obvious group.

### Large

Group related modules (`modules/desk/{notes,projects,tasks}/`) and split big ones into submodules (`modules/auth/{mfa,oidc}/`). For a second deployable (worker, admin API), switch to nest-cli monorepo mode with `apps/` and `libs/`.

## Anti-patterns

Read [references/anti-patterns.md](references/anti-patterns.md) when reviewing a layout or before moving files.

- Do not put business logic in controllers, resolvers, or gateways. Use services.
- Do not inject another module's repository or entity. Import the module and use its exported service.
- Do not use `forwardRef` as a routine fix. Restructure.
- Do not mark modules `@Global()` by default.
- Do not put a single-module guard, filter, or interceptor in `common/`.
- Do not read `process.env` outside `*.config.ts` files.
- Do not return entities from controllers. Map to a DTO or serialized view.
- Do not create `utils/`, `helpers/`, or a providerless `SharedModule` dumping ground.
- Do not register the same pipe globally in both `main.ts` and `APP_PIPE`.
