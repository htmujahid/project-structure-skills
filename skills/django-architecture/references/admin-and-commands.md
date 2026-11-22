# Admin, management commands, checks, fixtures

## Admin

- `admin.py` per app. Register with `@admin.register(Order)`; subclass `ModelAdmin`.
- Set `list_display`, `list_filter`, `search_fields`, `list_select_related`, `readonly_fields`, `autocomplete_fields`, `date_hierarchy`, `ordering`.
- Inlines: `TabularInline`/`StackedInline` in the same file; extract to `admin/` package past ~300 lines (`admin/order.py`, `admin/__init__.py` importing them).
- Admin actions call services (`@admin.action`) rather than updating querysets silently.
- Custom user: `UserAdmin` subclass with your fields in `apps/users/admin.py`.
- Custom admin site or branding: `config/admin.py` with `AdminSite` subclass, mounted in `config/urls.py`. Use `django.contrib.admin.apps.SimpleAdminConfig` only when replacing the site.
- Staff-only UI belongs in admin; customer-facing UI never does.

## Management commands

```
apps/orders/management/
  __init__.py
  commands/
    __init__.py
    expire_stale_orders.py
```

```python
class Command(BaseCommand):
    help = "Cancel unpaid orders older than N hours"
    def add_arguments(self, parser):
        parser.add_argument("--hours", type=int, default=24)
        parser.add_argument("--dry-run", action="store_true")
    def handle(self, *args, **opts):
        count = services.expire_stale_orders(hours=opts["hours"], dry_run=opts["dry_run"])
        self.stdout.write(self.style.SUCCESS(f"Expired {count}"))
```

- File name is the command name (snake_case). Commands are thin: parse args, call a service, print.
- Idempotent and re-runnable. Support `--dry-run` for destructive ones.
- Project-wide commands (`seed_dev_data`, `check_env`) live in `core/management/commands/`.
- Test with `call_command(...)`.

## Custom system checks

`checks.py` in the app, `@register(Tags.security)`, imported in `ready()`. Run via `manage.py check`. Use for config validation (required settings, deploy sanity).

## Fixtures and seed data

- `fixtures/*.json` for small static reference data loaded by `loaddata` and tests. Large demo data: a seed command using factories.
- Data needed in production (roles, lookups) goes in data migrations, not fixtures.

## Sitemaps, feeds, flatpages

`sitemaps.py` / `feeds.py` in the app that owns the content; registered in `config/urls.py`.

## Contrib apps worth wiring

`auth`, `contenttypes`, `sessions`, `messages`, `staticfiles`, `sites` (multi-site), `sitemaps`, `postgres` (full-text, array, JSON), `humanize`. Add to `DJANGO_APPS` only when used.
