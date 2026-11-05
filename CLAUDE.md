# Brainixa — backend (brain-ixa)

PHP API (no framework) for the Brainixa learning platform. Built as a white-label twin of the
Najeh platform: same codebase lineage, same schema, different brand, database, and base URL.

## Working rules (carried over from the Najeh sessions — these override default behaviour)

1. **Report every DB change and every touched file.** Name exact paths, proactively, in every
   reply that involves code or DB work. Flag schema/data changes separately and clearly — the
   user edits files by hand in parallel and needs to know what was touched by whom.
2. **Push this backend repo freely; ask before pushing any frontend.** Standing permission was
   given on 2026-10-07 for `brain-ixa` only: commit and push backend work without asking. The
   Brainixa frontends (`brainixa-dash-admin`, `-teacher`, `-student-new`) still need the user's
   go-ahead every time. Still report what was pushed, and still never push a parked file.
3. **Reply in formal Arabic (الفصحى)**, not Egyptian colloquial. Keep technical terms, paths,
   function names, SQL and code verbatim.
4. **Don't ask for permission before routine work.** Write, edit, run, build — then report. Use
   `AskUserQuestion` only for genuine product/design decisions.
5. **A backend feature isn't finished until the admin dashboard is wired to it.** When adding an
   admin-facing endpoint, also implement the UI call in `../brainixa-dash-admin`.
6. **Never copy real Najeh data into Brainixa.** Structure and reference/lookup data only. The
   user was explicit about this.

## Layout

| Piece | Path |
|---|---|
| Backend (this repo) | `D:\CampCode\brain-ixa` → https://github.com/OmarTalaat221/brainixa-back |
| Admin dashboard | `D:\CampCode\brainixa-dash-admin` (Next.js) |
| Teacher dashboard | `D:\CampCode\brainixa-dash-teacher` (Next.js) |
| Student dashboard | `D:\CampCode\brainixa-dash-student-new` (and `-old`) |
| Upstream reference | `D:\CampCode\najeh-back` + `Najeh-dash` + `Najeh-dash-Teacher` |

Najeh is the upstream source of truth for features. When something here looks odd, compare with
the Najeh file of the same path before changing it.

## Deployment

- Live API: `https://camp-coding.online/brain-ixa` — welcome route returns
  `{"status":"ok","message":"Welcome to Brainixa Platform API"}`.
- Server: cPanel account `campcod1` on `sv22`, deployed at `~/public_html/brain-ixa` via
  `git clone`. Updates are `git pull` in that directory (the stored remote carries a token).
- Database: `campcod1_brain-ixa` (user and password match the DB name; see `config/connection.php`).
- Both the backend and the browser-based cPanel Terminal are reachable by the user, not by Claude.
  Hand them exact commands to paste rather than trying to run them here.

## Conventions

- **Route prefix is `/brain-ixa/`**, not `/najeh/`. Every route string in `index.php` carries it.
- `index.php` is one big route table: `["method" => ..., "path" => ..., "handler" => fn]`.
  Handlers live under `app/<role>/<area>/manage.php` and are guarded with
  `if (!function_exists(...))`.
- Handlers read input with `read_json_body()`, use `mysqli_prepare` + bind (never interpolate),
  and return `['status' => ..., 'message' => ..., 'data' => ...]`. Errors come back with HTTP 200.
- Migrations: `migrations/NNN_name.sql`, applied by hand. Write them idempotently
  (`CREATE TABLE IF NOT EXISTS`, `ADD COLUMN IF NOT EXISTS` — MariaDB 10.11 supports it, and
  guarded `INSERT`s). They get replayed against databases in different states.
- API spec: `brainixa_api_openapi.json`. Tags follow `<batch> / <Role> / <Feature>`
  (e.g. `update-3 / Teacher / Attendance & Wallet`), where `old` means "never changed since the
  base version". Keep new endpoints tagged the same way.
- `updates-for-project/` holds the per-update change summaries (update-2, update-3).

## Current state (2026-10-07)

Done:
- Backend rebuilt from Najeh, rebranded, and deployed live. DB connection verified.
- `campcod1_brain-ixa` rebuilt from a fresh Najeh export: 124 tables, all indexes and
  constraints, **reference/lookup data only** (subjects, academic years, schools, school types,
  languages, roles, permissions, currencies, countries, site settings, HR policy) — no Najeh
  accounts, content, or transactions.
- Test data was seeded into the live database and the seed files then deleted (2026-10-08) — the
  data is applied, the scripts were clutter. **Every test account's password is `12345678`**:
  `admin@brainixa.cloud`, `teacher1..3@brainixa.cloud`, `student1..3@brainixa.cloud`. There is
  also a question bank of 7 folders / 169 questions, owned across the admin and teachers 1-3.
  Regenerate a seed only if the database is rebuilt.
- Zoom: `ZOOM_INTEGRATION.md` is the integration guide handed to the mobile developer (three
  live-class paths, endpoints, entitlement rules, account limits). `seed_zoom_test_student2005.sql`
  prepares the Zoom test account `student2005@example.com` / `12345678` — package
  `package-zoom-test-2026` with `teacher1@brainixa.cloud`, booked and open slots, consultations,
  and weekly `class_sessions`. Idempotent; run it on the server by hand.

Pending / known gaps:
- Admin and teacher dashboards are rebuilt locally but **not committed or pushed** yet
  (~193 and ~118 changed files). They need the user's go-ahead.
- Firebase (chat + push) still points at Najeh's project `najeh-e3ef7` in all three frontends,
  marked with TODO comments. Swap once a Brainixa Firebase project exists.
- `hero_slides` is deliberately excluded from this codebase (parked feature on the Najeh side), and
  the admin dashboard's dead hero-slides screen was removed on 2026-10-08.
- `rebuild_database.sql` sits at the repo root, untracked, and is the ONLY record of the live
  schema — do not delete it. The `migrations/` files have been shown to disagree with it (column
  types and nullability differ), so when the two conflict, the dump is what the database actually
  looks like.
- Payments: EasyKash is fully integrated and the student dashboard now calls it. Several verified
  defects were deliberately deferred by the user — see the `payment-known-gaps` memory before
  touching payment code, so they are not rediscovered or mistaken for regressions.

## Files that are not Claude's to push

Anything the user has parked. If a deferred change shares a file with an intended one, back the
file up, `git checkout` it, re-apply only the intended edit, commit, then restore the backup.
