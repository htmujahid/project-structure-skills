# CQRS

Layout for `@nestjs/cqrs`. Use it per module, not app-wide: adopt it in a module whose writes have real workflow complexity (multi-step, event-driven, audited). Plain controller -> service modules stay as they are and can live beside CQRS modules.

## Module layout

```
modules/orders/
  orders.module.ts           # registers handlers + sagas as providers
  orders.controller.ts       # dispatches to CommandBus / QueryBus
  order.entity.ts
  order.dto.ts               # HTTP DTOs stay at the edge
  orders.repository.ts
  commands/
    create-order.command.ts  # class CreateOrderCommand, data only
    create-order.handler.ts  # @CommandHandler(CreateOrderCommand)
    cancel-order.command.ts
    cancel-order.handler.ts
  queries/
    get-order.query.ts
    get-order.handler.ts     # may read via a lean read model, not the write repo
    list-orders.query.ts
    list-orders.handler.ts
  events/
    order-created.event.ts
    order-created.handler.ts # @EventsHandler: side effects (mail, projection)
  sagas/
    orders.saga.ts           # event stream -> follow-up commands
  models/
    order.model.ts           # AggregateRoot, only if using event publishing
```

## Naming

- One command/query/event per file, kebab-case, verb-first for commands (`create-order.command.ts`), and its handler beside it with the same stem.
- Classes: `CreateOrderCommand`, `CreateOrderHandler`, `OrderCreatedEvent` (past tense), `OrdersSaga`.
- Collect exports in `commands/index.ts` only to feed the module's providers array; do not deep-import handlers from other modules.

## Rules

- Controllers (or resolvers/gateways) only construct a command/query from the DTO and dispatch. Authorization happens in guards or in the handler, not in the controller.
- Command handlers mutate; query handlers read. A query handler never writes, a command handler returns at most an id/ack, not a view.
- Events carry facts (`OrderCreatedEvent`), named in past tense. Handlers for another module's event live in the subscribing module, importing only the event class the publisher exports.
- Sagas return commands; they contain no I/O beyond the event stream.
- Keep DTO (transport) separate from command (intent). The controller maps one to the other; handlers never see HTTP types.

## When not to use it

CRUD with validation is not CQRS territory. If every handler is three lines calling the repository, delete the buses and go back to a service. The folder convention makes this reversible: handlers collapse into service methods one file at a time.
