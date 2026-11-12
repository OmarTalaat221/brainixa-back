# Running this API in Postman

Two files in this repo are all you need:

| File | What it is |
|---|---|
| `brainixa_api_openapi.json` | The API. Import it and Postman builds a collection out of it. |
| `brainixa_postman_environment.json` | The environment: base URL, one token per role, and the ids the requests keep asking for. |

And one hand-written collection, for the part a generated one documents poorly:

| File | What it is |
|---|---|
| `brainixa_store_postman_collection.json` | The store — products and their categories, split into `admin/` and `user/`. Written by hand because the interesting part is not the field list but which values mean what: a null sale price is not a free product, a null stock is not a sold-out one, and `file_is_public` decides whether the shop front is handed the download link at all. A collection generated from the spec cannot say that in the place you read it. |

## Setup, once

1. **Import** both files (Postman → Import → drop them in).
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
- **The spec is a changelog, not a full reference.** Tags read `<batch> / <Role> / <Feature>`,
  and an endpoint untouched since the base version is deliberately absent. Filter by `update-7`
  to see only what the latest batch added or changed.

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
