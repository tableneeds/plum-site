# Plum website

This is the Rails application behind [plumcms.org](https://plumcms.org). It is both Plum's marketing and documentation site and a production example of a content-first site built with [`plum-cms`](https://rubygems.org/gems/plum-cms).

The site deliberately keeps its content, editor, rendering, jobs, and SQLite databases in one conventional Rails application. The pages and documentation are seeded into Plum and then managed through its control panel.

## Development

The application requires Ruby 3.3.1 and SQLite.

```sh
bin/setup
bin/dev
```

Open <http://localhost:3000>. The development control-panel login at <http://localhost:3000/cp> is `admin@plumcms.org` / `password`.

Run the checks with:

```sh
bin/rails test
bin/rubocop
```

## Production image

Every push to `main` publishes a multi-platform image to:

```text
ghcr.io/tableneeds/plum-site:latest
```

The image follows the ONCE application contract:

- HTTP is served on port 80.
- Rails health is available at `/up`.
- SQLite databases and uploads live in `/rails/storage` (also mounted by ONCE at `/storage`).
- `/hooks/pre-backup` safely snapshots the live SQLite databases.
- `/hooks/post-restore` restores those snapshots after an ONCE restore.

Required production variables:

- `SECRET_KEY_BASE`
- `PLUM_ADMIN_EMAIL`
- `PLUM_ADMIN_PASSWORD`

Useful optional variables include `APP_HOST`, `SMTP_ADDRESS`, `SMTP_PORT`, `SMTP_USERNAME`, and `SMTP_PASSWORD`. Set `DISABLE_SSL=true` only when TLS is terminated by the host platform, as it is with ONCE.

Plum itself lives at [tableneeds/plum](https://github.com/tableneeds/plum).
