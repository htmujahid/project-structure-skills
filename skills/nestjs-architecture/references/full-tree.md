# Full tree

A large NestJS app (REST + a gateway + queues), single deployable.

```
.
├── .env.example
├── nest-cli.json
├── package.json
├── tsconfig.json
├── tsconfig.build.json
├── test/
│   ├── app.e2e-spec.ts
│   └── auth.e2e-spec.ts
└── src/
    ├── main.ts                        # bootstrap: adapter, swagger, listen
    ├── app.module.ts                  # ConfigModule.forRoot + infra + modules
    ├── common/
    │   ├── decorators/
    │   │   ├── current-user.decorator.ts
    │   │   └── public.decorator.ts    # SetMetadata, read by auth guard
    │   ├── errors/
    │   │   ├── duplicate-value.exception.ts
    │   │   └── maintenance.exception.ts
    │   ├── filters/
    │   │   ├── all-exceptions.filter.ts
    │   │   ├── all-exceptions.filter.spec.ts
    │   │   └── query-failed.filter.ts # maps DB errors to 409/400
    │   ├── guards/
    │   │   └── fresh-session.guard.ts # used by auth + admin modules
    │   ├── interceptors/
    │   │   ├── response-envelope.interceptor.ts
    │   │   └── skip-envelope.decorator.ts  # opt-out metadata decorator
    │   ├── middleware/
    │   │   └── request-id.middleware.ts
    │   └── pipes/
    │       └── trim-strings.pipe.ts
    ├── infra/
    │   ├── database/
    │   │   ├── database.config.ts     # registerAs('database', ...)
    │   │   ├── database.module.ts     # TypeOrmModule.forRootAsync
    │   │   └── migrations/
    │   ├── queue/
    │   │   ├── queue.config.ts
    │   │   ├── queue.constants.ts     # queue name constants
    │   │   └── queue.module.ts        # BullModule.forRootAsync
    │   ├── mailer/
    │   │   ├── mailer.config.ts
    │   │   ├── mailer.module.ts
    │   │   ├── mail-queue.module.ts   # registers the mail queue
    │   │   ├── mail.queue.ts          # facade services call to enqueue
    │   │   ├── mail.processor.ts      # BullMQ worker
    │   │   ├── mails/                 # one builder per mail
    │   │   │   ├── password-reset.mail.ts
    │   │   │   └── verify-email.mail.ts
    │   │   └── templates/
    │   │       ├── password-reset.html
    │   │       └── verify-email.html
    │   ├── redis/
    │   │   ├── redis.config.ts
    │   │   └── redis.module.ts
    │   ├── rate-limit/
    │   │   ├── rate-limit.config.ts
    │   │   ├── rate-limit.module.ts   # ThrottlerModule + APP_GUARD
    │   │   └── redis-throttler.storage.ts
    │   ├── storage/
    │   │   ├── storage.config.ts
    │   │   └── storage.module.ts
    │   └── websocket/
    │       └── redis-io.adapter.ts    # multi-instance socket.io adapter
    ├── modules/
    │   ├── core/
    │   │   └── health/
    │   │       ├── health.module.ts
    │   │       ├── health.controller.ts
    │   │       └── redis.health.ts    # custom health indicator
    │   ├── auth/                      # large feature split into submodules
    │   │   ├── auth.module.ts         # imports the submodules below
    │   │   ├── auth.config.ts
    │   │   ├── common/                # shared inside auth only
    │   │   │   ├── common.module.ts
    │   │   │   ├── session.entity.ts
    │   │   │   ├── session-auth.provider.ts
    │   │   │   └── session.view.ts    # safe serialization of the entity
    │   │   ├── password/
    │   │   │   ├── password.module.ts
    │   │   │   ├── password.controller.ts
    │   │   │   ├── password.dto.ts
    │   │   │   └── password-reset.mailer.ts
    │   │   ├── mfa/
    │   │   │   ├── mfa.module.ts
    │   │   │   ├── mfa.controller.ts
    │   │   │   ├── mfa.dto.ts
    │   │   │   ├── mfa.entities.ts
    │   │   │   └── mfa.cleanup.ts     # cron: purge expired challenges
    │   │   ├── oidc/
    │   │   │   ├── oidc.module.ts
    │   │   │   ├── oidc.controller.ts
    │   │   │   └── oidc-redirect.filter.ts  # module-local filter
    │   │   ├── token/
    │   │   │   ├── token.module.ts
    │   │   │   ├── token.controller.ts
    │   │   │   ├── token.dto.ts
    │   │   │   ├── jwt-auth.provider.ts
    │   │   │   └── refresh-token.entity.ts
    │   │   └── user/
    │   │       ├── user.module.ts
    │   │       ├── user.controller.ts
    │   │       ├── user.dto.ts
    │   │       ├── user.entity.ts
    │   │       ├── user.policy.ts     # authorization rules, unit-tested
    │   │       ├── users.repository.ts
    │   │       ├── credentials.service.ts
    │   │       ├── user-deleted.event.ts   # emitted here, handled elsewhere
    │   │       └── username.util.ts
    │   ├── admin/
    │   │   ├── admin.module.ts
    │   │   ├── admin-users.controller.ts
    │   │   └── admin.dto.ts
    │   ├── contact/                   # small feature: flat, no submodules
    │   │   ├── contact.module.ts
    │   │   ├── contact.controller.ts
    │   │   ├── contact.dto.ts
    │   │   ├── contact.entity.ts
    │   │   ├── contact.policy.ts
    │   │   ├── contact.repository.ts
    │   │   ├── contact.types.ts
    │   │   └── contact.cleanup.ts
    │   ├── desk/                      # module group: related features
    │   │   ├── notes/
    │   │   │   ├── notes.module.ts
    │   │   │   ├── notes.controller.ts
    │   │   │   ├── notes.repository.ts
    │   │   │   ├── note.dto.ts
    │   │   │   ├── note.entity.ts
    │   │   │   └── note.types.ts
    │   │   ├── projects/
    │   │   └── tasks/
    │   └── notifications/
    │       ├── notifications.module.ts
    │       ├── notifications.gateway.ts    # WebSocket gateway, thin
    │       ├── notifications.service.ts
    │       ├── notifications.events.ts     # event name constants
    │       └── user-deleted.listener.ts    # @OnEvent handler
    └── i18n/
        ├── translations.ts
        ├── en/
        │   ├── auth.json
        │   ├── errors.json
        │   └── validation.json
        └── de/
```

Spec files (`*.spec.ts`) sit next to every tested file; most are omitted above.
