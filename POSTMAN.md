# Running this API in Postman

Two files in this repo are all you need:

| File | What it is |
|---|---|
| `brainixa_api_openapi.json` | The API. Import it and Postman builds a collection out of it. |
| `brainixa_postman_environment.json` | The environment: base URL, one token per role, and the ids the requests keep asking for. |

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
