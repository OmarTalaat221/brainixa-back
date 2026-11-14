# -*- coding: utf-8 -*-
"""brainixa_api_openapi.json -> brainixa_api_postman_collection.json, with REAL nested folders.

Postman's own OpenAPI import makes one flat folder per tag. The spec's tags are paths
("Admin / Store / Products"), so this builds the tree they describe: Admin > Store > Products.

Run it after every change to the spec, from the repo root:

    python tools/api_docs/build_postman_collection.py

Folder names, their order and their descriptions live in taxonomy.py beside this file.
"""
import io
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from taxonomy import FOLDERS, ROLE_ORDER, ROLES, folder_rank  # noqa: E402

REPO = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..')
spec = json.load(io.open(os.path.join(REPO, 'brainixa_api_openapi.json'), encoding='utf-8'))
ENV_KEYS = {v['key'] for v in json.load(io.open(os.path.join(REPO, 'brainixa_postman_environment.json'),
                                                encoding='utf-8'))['values']}
METHODS = ('get', 'post', 'put', 'patch', 'delete')
TOKEN_VAR = {'AdminAuth': 'admin_token', 'TeacherAuth': 'teacher_token', 'StudentAuth': 'student_token',
             'ParentAuth': 'parent_token', 'AnyAuth': 'admin_token'}


def resolve(node, depth=0):
    while isinstance(node, dict) and '$ref' in node and depth < 20:
        ref = node['$ref']
        if not ref.startswith('#/'):
            return {}
        cur = spec
        for part in ref[2:].split('/'):
            cur = cur.get(part.replace('~1', '/').replace('~0', '~'), {})
        node, depth = cur, depth + 1
    return node or {}


def example_of(schema, depth=0):
    schema = resolve(schema)
    if depth > 6 or not isinstance(schema, dict):
        return None
    if 'example' in schema:
        return schema['example']
    if 'default' in schema:
        return schema['default']
    if 'enum' in schema and schema['enum']:
        return schema['enum'][0]
    for key in ('allOf', 'oneOf', 'anyOf'):
        if schema.get(key):
            if key == 'allOf':
                merged = {}
                for s in schema['allOf']:
                    v = example_of(s, depth + 1)
                    if isinstance(v, dict):
                        merged.update(v)
                return merged
            return example_of(schema[key][0], depth + 1)
    t = schema.get('type')
    if t == 'object' or 'properties' in schema:
        props = schema.get('properties') or {}
        # a body built from a bare schema would be all zeros, and 0 is a real value here (a price of
        # 0 means FREE). Keep the required fields and the ones the spec gives a value for.
        wanted = set(schema.get('required') or []) | {
            k for k, v in props.items() if any(x in resolve(v) for x in ('example', 'default', 'enum'))}
        if wanted:
            return {k: example_of(v, depth + 1) for k, v in props.items() if k in wanted}
        # nothing to go on: name each field's type, so nothing is sent by accident (0 and null both mean
        # something here) and the reader fills in what they need, then deletes the rest
        return {k: placeholder(v) for k, v in props.items()}
    if t == 'array':
        v = example_of(schema.get('items', {}), depth + 1)
        return [] if v is None else [v]
    return {'integer': 0, 'number': 0, 'boolean': False, 'string': ''}.get(t)


def placeholder(schema):
    schema = resolve(schema)
    t = schema.get('type', 'string')
    if t == 'array':
        return [placeholder(schema.get('items', {}))]
    if t == 'object':
        return {k: placeholder(v) for k, v in (schema.get('properties') or {}).items()}
    return '<%s%s>' % (t, ' or null' if schema.get('nullable') else '')


def env_value(name, fallback):
    return '{{%s}}' % name if name in ENV_KEYS else fallback


def build_request(path, method, op):
    sec = op.get('security')
    if sec:
        name = list(sec[0])[0] if sec[0] else None
        auth = {'type': 'bearer', 'bearer': [{'key': 'token', 'value': '{{%s}}' % TOKEN_VAR.get(name, 'admin_token'), 'type': 'string'}]} \
            if name else {'type': 'noauth'}
    else:
        auth = {'type': 'noauth'}

    query, headers = [], []
    for prm in [resolve(p) for p in op.get('parameters', [])]:
        if not prm.get('name'):
            continue
        ex = prm.get('example', example_of(prm.get('schema', {})))
        value = env_value(prm['name'], '' if ex is None else (json.dumps(ex) if isinstance(ex, (dict, list)) else str(ex)))
        entry = {'key': prm['name'], 'value': value, 'description': prm.get('description', '')}
        # optional filters start switched off, so the request runs as-is; tick one to use it
        if not prm.get('required') and prm['name'] not in ('page', 'limit'):
            entry['disabled'] = True
        if prm.get('in') == 'query':
            query.append(entry)
        elif prm.get('in') == 'header':
            headers.append({**entry, 'type': 'text'})

    body = None
    rb = resolve(op.get('requestBody', {}))
    content = rb.get('content', {})
    if 'application/json' in content:
        c = content['application/json']
        ex = c.get('example')
        if ex is None and c.get('examples'):
            ex = resolve(next(iter(c['examples'].values()))).get('value')
        if ex is None:
            ex = example_of(c.get('schema', {}))
        body = {'mode': 'raw', 'raw': json.dumps(ex if ex is not None else {}, ensure_ascii=False, indent=2),
                'options': {'raw': {'language': 'json'}}}
        headers.append({'key': 'Content-Type', 'value': 'application/json', 'type': 'text'})
    elif 'multipart/form-data' in content:
        schema = resolve(content['multipart/form-data'].get('schema', {}))
        form = []
        for k, v in (schema.get('properties') or {}).items():
            v = resolve(v)
            if v.get('format') == 'binary' or (v.get('type') == 'array' and resolve(v.get('items', {})).get('format') == 'binary'):
                form.append({'key': k, 'type': 'file', 'src': [], 'description': v.get('description', '')})
            else:
                ex = example_of(v)
                form.append({'key': k, 'type': 'text', 'value': '' if ex is None else (json.dumps(ex, ensure_ascii=False) if isinstance(ex, (dict, list)) else str(ex)),
                             'description': v.get('description', '')})
        body = {'mode': 'formdata', 'formdata': form}

    raw = '{{base_url}}' + path
    if query:
        raw += '?' + '&'.join('%s=%s' % (q['key'], q['value']) for q in query if not q.get('disabled'))
        raw = raw.rstrip('?')
    req = {
        'method': method.upper(),
        'header': headers,
        'auth': auth,
        'url': {'raw': raw, 'host': ['{{base_url}}'], 'path': [s for s in path.split('/') if s], 'query': query},
        'description': op.get('description', ''),
    }
    if body:
        req['body'] = body

    responses = []
    for code, r in (op.get('responses') or {}).items():
        r = resolve(r)
        js = (r.get('content') or {}).get('application/json', {})
        ex = js.get('example')
        if ex is None and js.get('examples'):
            ex = resolve(next(iter(js['examples'].values()))).get('value')
        if ex is not None:
            responses.append({'name': '%s - %s' % (code, r.get('description', '')[:60] or 'example'),
                              'originalRequest': {k: req[k] for k in ('method', 'header', 'url')},
                              'status': 'OK' if code.startswith('2') else 'Example', 'code': int(code) if code.isdigit() else 200,
                              '_postman_previewlanguage': 'json',
                              'header': [{'key': 'Content-Type', 'value': 'application/json'}],
                              'body': json.dumps(ex, ensure_ascii=False, indent=2)})
    item = {'name': op.get('summary') or '%s %s' % (method.upper(), path), 'request': req, 'response': responses}

    # A sign-in request reads its email and password from the environment and writes the token it
    # gets back into it, so every other request of that role works straight after.
    role = LOGIN_ROLES.get((method, path))
    if role:
        if body and body.get('mode') == 'raw':
            try:
                sent = json.loads(body['raw'])
            except ValueError:
                sent = {}
            sent['email'] = '{{%s_email}}' % role
            sent['password'] = '{{%s_password}}' % role
            body['raw'] = json.dumps(sent, ensure_ascii=False, indent=2)
        item['event'] = [{'listen': 'test', 'script': {'type': 'text/javascript', 'exec': [
            'const body = pm.response.json();',
            'const token = body?.data?.tokens?.access_token || body?.data?.access_token;',
            'const refresh = body?.data?.tokens?.refresh_token || body?.data?.refresh_token;',
            'if (token) {',
            '  pm.environment.set("%s_token", token);' % role,
            '  if (refresh) pm.environment.set("%s_refresh_token", refresh);' % role,
            '  console.log("%s_token saved");' % role,
            '} else {',
            '  console.warn("No token in the response:", body?.message);',
            '}',
        ]}}]
    return item


LOGIN_ROLES = {
    ('post', '/admin/auth/login'): 'admin',
    ('post', '/teacher/auth/login'): 'teacher',
    ('post', '/user/student/auth/login'): 'student',
    ('post', '/parent/auth/login'): 'parent',
}


# ---- the tree
root = {}


def node_for(parts):
    cur = root
    for i, part in enumerate(parts):
        key = ' / '.join(parts[:i + 1])
        cur = cur.setdefault(part, {'__key': key, '__items': [], '__children': {}})
        if i < len(parts) - 1:
            cur = cur['__children']
    return cur


for path, item in spec['paths'].items():
    for m, op in item.items():
        if m not in METHODS:
            continue
        node_for(op['tags'][0].split(' / '))['__items'].append((path, m, op))

M_ORDER = {'get': 0, 'post': 1, 'put': 2, 'patch': 3, 'delete': 4}


def emit(name, node):
    key = node['__key']
    desc = ROLES.get(key) or FOLDERS.get(key)
    if not desc:
        raise SystemExit('Folder "%s" has no description: add it to FOLDERS in taxonomy.py' % key)
    items = [build_request(p, m, o) for p, m, o in sorted(node['__items'], key=lambda x: (x[0], M_ORDER[x[1]]))]
    children = [emit(n, c) for n, c in sorted(node['__children'].items(), key=lambda kv: folder_rank(kv[1]['__key']))]
    # sub-folders first, then the folder's own requests
    return {'name': name, 'description': desc, 'item': children + items}


collection = {
    'info': {
        'name': 'Brainixa Platform API',
        'description': spec['info']['description'],
        'schema': 'https://schema.getpostman.com/json/collection/v2.1.0/collection.json',
        'version': spec['info']['version'],
    },
    'item': [emit(r, root[r]) for r in ROLE_ORDER if r in root],
}

out = os.path.join(REPO, 'brainixa_api_postman_collection.json')
io.open(out, 'w', encoding='utf-8', newline='\n').write(json.dumps(collection, ensure_ascii=False, indent=2) + '\n')


def count(items):
    f = r = 0
    for it in items:
        if 'request' in it:
            r += 1
        else:
            f += 1
            a, b = count(it['item'])
            f, r = f + a, r + b
    return f, r


print('postman folders: %d, requests: %d' % count(collection['item']))
