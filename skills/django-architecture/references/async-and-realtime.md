# Async work and realtime

## Background tasks

Pick one runner and keep it consistent: Celery (default for heavy workloads), Django's built-in tasks framework (Django 6, simple jobs), or RQ/Dramatiq.

### Celery layout

```
config/celery.py        # app = Celery("config"); config_from_object("django.conf:settings", namespace="CELERY"); autodiscover_tasks()
config/__init__.py      # from .celery import app as celery_app
apps/orders/tasks.py    # tasks, auto-discovered
```

- Tasks are thin: accept ids and primitives, load the object, call a service.
- Naming: `send_receipt`, `sync_inventory`; name explicitly `@shared_task(name="orders.send_receipt")` when queues are routed.
- Idempotent, retried with `autoretry_for`, `retry_backoff`; set time limits.
- Trigger after commit: `transaction.on_commit(lambda: task.delay(pk))`.
- Routing: `CELERY_TASK_ROUTES` in settings; one queue per workload (`default`, `emails`, `heavy`).
- Beat schedules: `CELERY_BEAT_SCHEDULE` in settings or `django-celery-beat` (DB-backed, editable in admin).
- Worker and beat run as separate processes from the same codebase (`celery -A config worker`).

### Django tasks (6.0)

`@task` in `tasks.py`, `.enqueue()` from services; configure `TASKS` backend in settings. Same thin-task rules.

## Periodic jobs without a scheduler

A management command in the owning app invoked by cron/Kubernetes CronJob. Prefer this for one or two jobs.

## Async views

`async def` views and async ORM (`aget`, `afilter`, `async for`) for I/O-heavy endpoints under ASGI. Wrap sync-only code with `sync_to_async`. Never mix blocking calls into async views.

## Channels (WebSockets)

```
config/asgi.py          # ProtocolTypeRouter({"http": django_asgi, "websocket": AuthMiddlewareStack(URLRouter(routing.websocket_urlpatterns))})
config/routing.py       # aggregates app routing lists
apps/chat/consumers.py  # AsyncJsonWebsocketConsumer subclasses
apps/chat/routing.py    # websocket_urlpatterns = [path("ws/chat/<room>/", ChatConsumer.as_asgi())]
```

- Consumers authenticate in `connect`, call services/selectors via `database_sync_to_async`, group-send updates.
- Event names as constants (`chat.message`); message schemas validated with serializers or pydantic.
- `CHANNEL_LAYERS` uses Redis in production. Run under Daphne/Uvicorn.
- Services publish to groups after commit; consumers never hold business rules.

## Server-sent events and streaming

`StreamingHttpResponse` or async generator views for SSE; keep generators in the app's `streams.py`.

## Caching and rate limiting

Cache in selectors; throttle via DRF throttles or `django-ratelimit` decorators; Redis config in settings.

## Email and notifications

`services.send_*` builds messages; templates in `templates/<app>/emails/*.html|txt`; sending dispatched as a task. Backend set by settings (console locally, SMTP/provider in production).
