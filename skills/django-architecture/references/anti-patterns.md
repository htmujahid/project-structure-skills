# Anti-patterns

## Business logic in views, serializers, or `save()`

Bad: order total calculation inside `OrderViewSet.create`, or inside `Order.save()` along with emails.
Cost: the Celery task, admin action, and management command cannot reuse it; tests need HTTP; `save()` runs on every bulk-looking path and surprises.
Fix: `services.create_order(user, items)` in `services.py`, wrapped in `transaction.atomic`. Views and serializers validate and call it.

## Fat app or one app per model

Bad: a single `main` app with 40 models; or `apps/order`, `apps/order_item`, `apps/order_status`.
Cost: no boundaries, migration conflicts, circular imports between fragments.
Fix: one app per domain noun or capability, owning its related models. Split when two domains change independently.

## Reaching into another app

Bad: `from apps.users.views import ...`, or `orders` querying `User.objects.filter(...)` everywhere.
Cost: the owner can no longer change storage or rules.
Fix: call `users.selectors` and `users.services`. Use string FKs (`"users.User"`) or `settings.AUTH_USER_MODEL`, not model imports, to avoid cycles.

## Signals as control flow

Bad: `post_save` on `Order` creates an invoice, sends an email, and updates stock.
Cost: hidden order of side effects, invisible in the call stack, skipped by `bulk_create` and `update()`.
Fix: call the service explicitly. Reserve signals for decoupled, cross-app reactions; register them in `AppConfig.ready()` from `signals.py`; use `transaction.on_commit` for side effects.

## N+1 queries

Bad: a serializer or template touching `order.items.all` or `order.user.name` per row.
Cost: hundreds of queries per page.
Fix: selectors return querysets with `select_related` / `prefetch_related` / `annotate`. Assert counts with `django_assert_num_queries`.

## Mixing view styles

Bad: `OrderViewSet` beside `@api_view` functions and `APIView` classes in one app, FBV and CBV HTML mixed.
Cost: three ways to do auth, throttling, and schema; reviewers cannot predict where code is.
Fix: choose one style per project (see drf-api.md). A documented exception for one endpoint is fine.

## Default User model

Bad: starting with `django.contrib.auth.models.User` and swapping later.
Cost: swapping after the first migration means rewriting tables and FKs by hand.
Fix: `users.User(AbstractUser)` with `AUTH_USER_MODEL = "users.User"` before the first `migrate`.

## Editing shipped migrations

Bad: changing `0003_*.py` after it ran in staging, or deleting migrations to "reset".
Cost: drifted schemas, broken deploys.
Fix: add a new migration. Squash only with `squashmigrations` once every environment is current. Keep data migrations separate from schema migrations.

## Settings sprawl

Bad: one `settings.py` with `if DEBUG:` branches and `os.environ` calls everywhere, or imports of `settings` modules directly.
Cost: production-only bugs, untestable config.
Fix: `settings/base.py` plus per-environment files; read env only there; elsewhere use `from django.conf import settings`.

## utils.py / common.py / helpers.py

Bad: a root `utils.py` with date, string, and permission helpers.
Cost: import magnet with no owner.
Fix: put it beside its main user; promote to a named `core/` module (`core/validators.py`) on the second consumer.

## Logic in templates and template tags

Bad: `{% for o in orders %}{{ o.items.count }}` or tags that query and mutate.
Cost: hidden queries, untestable presentation rules.
Fix: compute in selectors (annotate), pass finished data to the template; tags only format.

## Hardcoded URLs and untranslated strings

Bad: `href="/orders/5/"`, `redirect("/login")`.
Cost: breaks on any URL change.
Fix: `{% url 'orders:detail' pk=o.pk %}`, `reverse("orders:detail")`, namespaced with `app_name`.

## Returning raw models from the API

Bad: `JsonResponse(model_to_dict(user))`.
Cost: password hashes and internal columns leak.
Fix: explicit serializer with `fields = [...]`, never `"__all__"` on models with sensitive columns.
