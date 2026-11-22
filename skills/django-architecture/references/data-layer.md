# Data layer

## Models

- One model per class, fields first, then `Meta`, then `__str__`, `get_absolute_url`, domain properties, short methods.
- Always set `class Meta: ordering`/`indexes`/`constraints` explicitly. Prefer `CheckConstraint` and `UniqueConstraint` over validation only.
- Use `models.TextChoices` / `IntegerChoices` for enumerations, declared inside the model.
- Set `related_name` on every FK/M2M. Use `on_delete` deliberately (`PROTECT` for financial data).
- Shared fields come from abstract bases in `core/models.py`: `TimeStampedModel` (`created_at`, `updated_at`), `UUIDModel`, `SoftDeleteModel`.
- Reference users with `settings.AUTH_USER_MODEL` in FKs, `get_user_model()` at runtime.
- Keep models free of HTTP, email, and external calls. Short invariants are fine (`order.can_cancel`); multi-step processes belong in services.
- `save()` overrides only for invariants on that one row. Never send email or call APIs in `save()`.

## Managers and querysets

```python
# apps/orders/managers.py
class OrderQuerySet(models.QuerySet):
    def active(self): return self.exclude(status=Order.Status.CANCELLED)
    def for_user(self, user): return self.filter(user=user)

# apps/orders/models.py
objects = OrderQuerySet.as_manager()
```

Chainable query logic goes on the queryset; a manager class only when you must override `get_queryset()` or add `create_*` helpers (`UserManager.create_user`).

## Services and selectors

The business API of an app. Views, serializers, admin, tasks, and commands all call these.

```python
# services.py: writes
@transaction.atomic
def place_order(*, user: User, items: list[ItemInput]) -> Order: ...

# selectors.py: reads
def orders_for_user(*, user: User) -> QuerySet[Order]:
    return Order.objects.for_user(user).select_related("user").prefetch_related("items")
```

- Keyword-only arguments, type hints, no `request` objects.
- Services raise domain exceptions; the view layer maps them to responses.
- Services may call other apps' services, never their models directly.
- Side effects after commit: `transaction.on_commit(lambda: send_receipt.delay(order.pk))`.
- Package form when large: `services/checkout.py`, `selectors/order_lists.py`.

## Signals

- Only for decoupled cross-app reactions or framework hooks (`post_migrate`, `user_logged_in`).
- Receivers in `signals.py`, imported inside `AppConfig.ready()`; use `@receiver(..., dispatch_uid="...")`.
- Never rely on signals for same-app flow; they do not fire on `bulk_create`, `update()`, or `QuerySet.delete()` partially.

## Transactions

- `ATOMIC_REQUESTS` stays off; wrap writes in services with `transaction.atomic`.
- Use `select_for_update()` inside atomic blocks for concurrent counters or stock.

## Migrations

- Generate with `makemigrations <app>`; review and commit. Name data migrations: `0007_backfill_order_numbers.py`.
- Separate schema and data migrations. Data migrations use `apps.get_model`, never real models, and provide a reverse function or `RunPython.noop`.
- Zero-downtime: add nullable column -> backfill -> add constraint in later deploy; drop columns a release after code stops using them.
- Never edit applied migrations. `squashmigrations` only when all environments are current.
- Cross-app migration dependencies stay explicit and minimal; a cycle means the apps need restructuring.
- CI runs `makemigrations --check --dry-run` to catch missing migrations.

## Custom user

- Create `apps/users/` first. `class User(AbstractUser)`, even if empty, plus `AUTH_USER_MODEL = "users.User"` before the first `migrate`.
- Email login: set `USERNAME_FIELD = "email"`, custom `UserManager`, drop `username`.
- Profile data goes in a `Profile` one-to-one model, not on `User`, once it exceeds a few fields.

## Multiple databases

- Config in `DATABASES`; routers in `config/db_routers.py`. Apps stay unaware: routing is by `app_label`.
- Read replicas: router `db_for_read`; use `.using("default")` after writes when consistency matters.
