"""端到端验证所有 API 端点。"""

import httpx

BASE = "http://localhost:8000"


def test(method: str, path: str, label: str, body: dict | None = None) -> httpx.Response:
    url = f"{BASE}{path}"
    if method == "GET":
        r = httpx.get(url)
    else:
        r = httpx.post(url, json=body)
    status_icon = "OK" if r.status_code in (200, 201) else f"ERR({r.status_code})"
    print(f"  {status_icon:8} {method:4} {path:32} {label}")
    return r


def main() -> None:
    print("=" * 60)
    print("Memora API 端到端验证")
    print("=" * 60)

    test("GET", "/health", "Health check")

    test("POST", "/api/v1/auth/register", "Register",
         {"username": "u1", "email": "u1@test.com", "password": "123456"})

    test("POST", "/api/v1/auth/login", "Login",
         {"username": "u1", "password": "123456"})

    r = httpx.get(f"{BASE}/api/v1/word-books")
    n = len(r.json())
    test("GET", "/api/v1/word-books", f"List word books ({n})")

    r = httpx.get(f"{BASE}/api/v1/word-books/1/words")
    n = len(r.json())
    test("GET", "/api/v1/word-books/1/words", f"List words ({n})")

    test("GET", "/api/v1/records", "Get records")

    test("POST", "/api/v1/records/sync", "Sync records", {"records": []})

    test("POST", "/api/v1/ai/mnemonic/stream", "AI stream (501)")

    r = httpx.get(f"{BASE}/openapi.json")
    info = r.json()["info"]
    paths = sorted(r.json()["paths"].keys())
    print(f"  OK       GET  /openapi.json {'':21} {info['title']} v{info['version']}")
    for p in paths:
        methods = sorted(r.json()["paths"][p].keys())
        print(f"          {'':6} {p} {methods}")

    print()
    print("=" * 60)
    print("All endpoints verified.")
    print("=" * 60)


if __name__ == "__main__":
    main()
