# WebSockets

Layout for `@nestjs/websockets` gateways (socket.io by default, or the ws adapter).

## Per-module layout

A gateway is a controller for socket events. It lives in the feature module it serves:

```
modules/notifications/
  notifications.module.ts
  notifications.gateway.ts     # @WebSocketGateway({ namespace: 'notifications' })
  notifications.service.ts     # business logic, also used by REST/listeners
  notifications.events.ts      # event name constants + payload types
  notification.dto.ts          # validated inbound message bodies

infra/websocket/
  redis-io.adapter.ts          # socket.io Redis adapter for multi-instance
  ws.config.ts                 # CORS origins, path
```

## Naming

- `*.gateway.ts` exporting `NotificationsGateway`. One gateway per feature, one namespace per gateway (`namespace: 'notifications'`).
- Event names and payload types in `*.events.ts` as constants (`NOTIFICATION_CREATED = 'notification.created'`). Never inline event strings in `emit`/`@SubscribeMessage` — the client must match them.

## Rules

- Gateways are thin: authenticate, validate, delegate to the service. No business logic, no repository access.
- Inbound messages are DTOs validated by the global `ValidationPipe`; errors must be thrown as `WsException` (an exception filter in `common/filters/` can translate `HttpException` to `WsException` once, globally for gateways).
- Guards work on gateways via `context.switchToWs()`; authenticate in `handleConnection` (handshake token) and attach the user to the socket, then lightweight guards read it per message.
- Emitting from elsewhere in the app: other modules do not inject the gateway. They emit a domain event (`@nestjs/event-emitter`) and a listener in the websocket-owning module pushes to sockets. This keeps `modules -> modules` coupling out and lets the worker process emit too (via the Redis adapter).
- Rooms: join in the gateway on connection or subscribe messages; room-name builders live in `*.events.ts` (`userRoom(id)`), not as inline template strings.

## Adapter and scaling

- Custom adapter class in `infra/websocket/`, applied in `main.ts` (`app.useWebSocketAdapter(new RedisIoAdapter(app))`). This is one of the few legitimate `main.ts` jobs.
- With more than one instance, the Redis adapter is mandatory; without it `server.emit` only reaches sockets on one instance.
- The `ws` library adapter (`@nestjs/platform-ws`) swaps in through the same adapter seam; gateway code and layout do not change.
