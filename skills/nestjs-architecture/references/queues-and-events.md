# Queues, events, and scheduling

Background work in three forms: BullMQ queues (retryable jobs), the event emitter (in-process decoupling), and cron jobs (time-driven).

## BullMQ queues (`@nestjs/bullmq`)

Connection and names are infrastructure; queues and workers belong to their owner.

```
infra/queue/
  queue.config.ts        # registerAs('queue', ...): Redis connection, defaults
  queue.constants.ts     # export const MAIL_QUEUE = 'mail'
  queue.module.ts        # BullModule.forRootAsync, exported for reuse

infra/mailer/            # the module that owns the mail queue
  mail-queue.module.ts   # BullModule.registerQueue({ name: MAIL_QUEUE })
  mail.queue.ts          # facade: typed enqueue methods, injected by others
  mail.processor.ts      # @Processor(MAIL_QUEUE) extends WorkerHost
  mails/                 # one payload builder per mail type
  templates/
```

- Queue names live once in `queue.constants.ts`. Never inline a queue name string.
- Other modules inject the facade (`MailQueue`), never the raw `Queue`, so payload types stay in one place.
- Processor = worker. It is thin like a controller: parse the job, call a service. Name job payload types next to the facade.
- A feature-owned queue follows the same trio inside its feature module: `modules/reports/{reports-queue.module,reports.queue,reports.processor}.ts`.

## Event emitter (`@nestjs/event-emitter`)

For in-process "this happened" decoupling, not for durable work (that is a queue).

- `EventEmitterModule.forRoot()` in `app.module.ts`.
- The event class lives with its publisher: `modules/auth/user/user-deleted.event.ts` exports `UserDeletedEvent` with a static `eventName` (or a const) — the single source of the event string.
- Listeners live with the subscriber: `modules/notifications/user-deleted.listener.ts` uses `@OnEvent(UserDeletedEvent.eventName)`. The subscriber imports only the event class.
- Services emit after the state change commits. Listeners must tolerate replays and failures; anything that must not be lost goes through a queue instead.

## Scheduling (`@nestjs/schedule`)

- `ScheduleModule.forRoot()` in `app.module.ts`.
- A cron provider lives in the module that owns the data it touches, suffixed by purpose: `mfa.cleanup.ts`, `contact.cleanup.ts` with `@Cron(CronExpression.EVERY_DAY_AT_3AM)`.
- A cleanup file holds the schedule and delegates the actual deletion to the module's service or repository.
- In multi-instance deployments guard each job with a distributed lock (Redis) or run schedules only in the worker instance.

## Splitting out a worker

When queue load or deploy cadence demands a separate worker process, keep one codebase:

1. Add `src/main.worker.ts` creating an application context with a `WorkerModule` that imports infra + the processor-owning modules, no controllers. Or, in a monorepo, `nest g app worker` and move processors there.
2. Gate processors out of the API process (worker module membership, not env-var `if`s inside processors).
3. Facades (enqueue side) stay in the API; processors move with the worker. The queue constants stay in shared infra so both sides agree on names.
