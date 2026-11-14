# Running this API in Postman

Two files in this repo are all you need:

| File | What it is |
|---|---|
| `brainixa_api_postman_collection.json` | **Import this one.** The whole API as a Postman collection with real nested folders: **who calls it** (Admin, Teacher, User, Parent, Landing, Shared) → **feature** (Content, Store, Live Classes...) → **part of the feature** (Zoom, Consultations...). Every folder and every request carries its explanation. Generated from the spec - do not edit it by hand. |
| `brainixa_postman_environment.json` | The environment: base URL, one token per role, and the ids the requests keep asking for. |

`brainixa_api_openapi.json` is the source both are made from. Importing it straight into Postman
also works, but Postman then makes one flat folder per tag ("Admin / Store / Products" as a single
name) instead of the tree. After changing the spec, rebuild the collection:

```
python tools/api_docs/build_postman_collection.py
```

### How the API is organised

- **User** is the student - the web dashboard and the mobile app share every endpoint, so they are
  documented once. The User folder's own description lists what matters on a phone (device-limited
  sign-in, the FCM token, Zoom inside the app).
- **Each request appears once.** Where the server also accepts it under another path or method (an
  alias kept for older clients), the request says so under *"The same request is also accepted at"*.
- **Every request starts with its history:** *Last changed in* (also in the field `x-last-update`),
  then *What changed, update by update* - one line per update, oldest first - then the full
  explanation. Update numbers live there now, not in the folder names.

And two hand-written collections, for the parts a generated one documents poorly:

| File | What it is |
|---|---|
| `brainixa_store_postman_collection.json` | The store — products and their categories, split into `admin/` and `user/`. Written by hand because the interesting part is not the field list but which values mean what: a null sale price is not a free product, a null stock is not a sold-out one, and `file_is_public` decides whether the shop front is handed the download link at all. A collection generated from the spec cannot say that in the place you read it. |
| `brainixa_reports_pricing_postman_collection.json` | **update-11 … update-15**: the attendance reports, the per-class ratings, homework aimed at particular students, pricing by country, and moving the base currency. Hand-written for the same reason — the field list is the easy half. Which rule decided a price, why a rating needs an attendance row behind it, and why a currency change can be refused outright are not things a generated collection says. |

## Setup, once

1. **Import** the collection and the environment (Postman → Import → drop them in).
2. Pick **Brainixa - Live** from the environment dropdown, top right.
3. Fill in the passwords. They are deliberately **empty in the file** — this repo is cloned by
   people who should not get a working admin login out of it.
4. Send the login request for whichever role you are testing. Paste the `access_token` from the
   response into `admin_token` / `teacher_token` / `student_token` / `parent_token`.

Then every request that needs that role works, because its Authorization header reads the
variable.

## Getting the token filled in for you

Paste this into the login request's **Scripts → Post-response** tab and it stops being a
copy-paste job. Change `admin` to the role the request signs in as:

```js
const body = pm.response.json();
const token = body?.data?.tokens?.access_token || body?.data?.access_token;
const refresh = body?.data?.tokens?.refresh_token || body?.data?.refresh_token;

if (token) {
  pm.environment.set("admin_token", token);
  if (refresh) pm.environment.set("admin_refresh_token", refresh);
  console.log("admin_token set");
} else {
  console.warn("No token in the response:", body?.message);
}
```

## Things worth knowing before you debug something that is not broken

- **A failure arrives as HTTP 200.** Business-logic errors come back with `status: "error"` in
  the body. Branch on `status`, never on the HTTP code.
- **Every path is prefixed `/brain-ixa`**, which is already part of `base_url` — so a request
  path reads `{{base_url}}/admin/books`, not `{{base_url}}/brain-ixa/admin/books`.
- **The four roles are different tokens.** An admin token on a teacher route is rejected; they
  are not interchangeable, and `AnyAuth` endpoints are the only ones that take whichever you have.
- **`slot_id` and `session_id` are different things.** A slot is a dated availability slot or a
  consultation; a session is a weekly recurring class. Their Zoom endpoints are separate too.
- **The API document covers what changed since the base version.** An endpoint untouched since
  the platform was built from the Najeh codebase is not described yet. To see what one update
  changed, search the collection for its name (`update-16`): every request lists its updates.
- **`POST /upload` now needs a token** (update-16). It used to accept a file from anyone at all.
  Any of the four roles works, so a signed-in caller is unaffected; an anonymous one is refused.
- **A third outcome exists beside success and error.** `severity: "warning"` means the write
  SUCCEEDED but could not do everything asked of it — a homework saved for students one of whom
  has no subscription, say. Treating it as a failure hides a change that did happen.

## Two places where the order of requests matters

**Base currency.** Send *Preview* → *Try it with no prices* → *Do it*. The first two change
nothing; the third is destructive and **cannot be undone by setting the currency back**, because
the figures themselves are rewritten. The preview tells you which items the third request will
refuse to proceed without.

**Class ratings.** A student can only rate a class the attendance register says they attended, and
the server checks it rather than trusting the request. So `GET /student/sessions/ratable` is where
a usable `session_id` and `occurrence_date` come from — inventing a pair gets a refusal, correctly.

## Testing the country pricing without a VPN

`GET /pricing/context` is the first thing to check whenever a price looks wrong. Its `source`
field names the rule that answered: `client` (an explicit `country=`), `edge` (a CDN header),
`geoip`, `student` (the country saved on the account) or `base`.

To pretend to be somewhere else, send `CF-IPCountry: DE` — the header Cloudflare sends, which the
code reads along with the Vercel, App Engine and Fastly equivalents. Or force it outright with
`?country=DE`, which outranks everything.

A price that falls back shows `is_country_price: false` and is quoted in the **base** currency —
never the base number relabelled with the local one.

## The store collection

Run it top to bottom and nothing needs pasting by hand: **Create product category** writes
`product_category_id` into the environment and **Create product** writes `product_id`, so every
request after them already points at something real.

- **`admin/` needs `manage_products`**, which is separate from `manage_books` on purpose —
  whoever prices the school bags is not necessarily whoever uploads the PDFs.
- **`user/` mostly needs nothing.** `/store` takes an optional student token: delete the
  Authorization header and it still answers, because a visitor must be able to see the shop.
  Signed in, the books in it additionally carry `own` and `is_locked`.
- **An id is unique only within its `item_type`.** `/store` returns products and books in one
  list, and product 7 is not book 7. Key on the pair.
- **Two folders contain requests that are meant to fail.** `Rejected: executable file` should be
  refused; if a `.php` ever uploads successfully, that is a finding, not a quirk to work around.
- **Needs migrations 127 and 128.** Without 127 the product endpoints say the table is missing
  and `/store` quietly returns only books; without 128 a product simply has no attachment.
