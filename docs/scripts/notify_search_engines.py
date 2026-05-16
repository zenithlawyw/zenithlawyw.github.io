#!/usr/bin/env python3
"""Notify search engines after deployment.

Supports:
- Bing IndexNow URL submission (recommended for fast Bing recrawl)
- Bing Webmaster sitemap submission (optional)
- Google Search Console sitemap submission (optional)

The script is safe to run when credentials are missing: it logs skip messages and exits 0.
"""

from __future__ import annotations

import base64
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET


def log(message: str) -> None:
    print(f"[notify-search] {message}")


def normalize_site_url(url: str) -> str:
    return url.rstrip("/")


def http_json_post(url: str, payload: dict, headers: dict[str, str] | None = None) -> tuple[int, str]:
    body = json.dumps(payload).encode("utf-8")
    req_headers = {
        "Content-Type": "application/json; charset=utf-8",
        "User-Agent": "zenithlaw-search-notifier/1.0",
    }
    if headers:
        req_headers.update(headers)

    request = urllib.request.Request(url, data=body, headers=req_headers, method="POST")
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            text = response.read().decode("utf-8", errors="replace")
            return response.status, text
    except urllib.error.HTTPError as exc:
        text = exc.read().decode("utf-8", errors="replace") if exc.fp else ""
        return exc.code, text


def http_form_post(url: str, form_data: dict[str, str]) -> tuple[int, str]:
    body = urllib.parse.urlencode(form_data).encode("utf-8")
    request = urllib.request.Request(
        url,
        data=body,
        headers={
            "Content-Type": "application/x-www-form-urlencoded",
            "User-Agent": "zenithlaw-search-notifier/1.0",
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            text = response.read().decode("utf-8", errors="replace")
            return response.status, text
    except urllib.error.HTTPError as exc:
        text = exc.read().decode("utf-8", errors="replace") if exc.fp else ""
        return exc.code, text


def http_get(url: str, headers: dict[str, str] | None = None) -> tuple[int, str]:
    req_headers = {
        "User-Agent": "zenithlaw-search-notifier/1.0",
    }
    if headers:
        req_headers.update(headers)

    request = urllib.request.Request(url, headers=req_headers, method="GET")
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            text = response.read().decode("utf-8", errors="replace")
            return response.status, text
    except urllib.error.HTTPError as exc:
        text = exc.read().decode("utf-8", errors="replace") if exc.fp else ""
        return exc.code, text


def http_put(url: str, headers: dict[str, str] | None = None) -> tuple[int, str]:
    req_headers = {
        "User-Agent": "zenithlaw-search-notifier/1.0",
    }
    if headers:
        req_headers.update(headers)

    request = urllib.request.Request(url, data=b"", headers=req_headers, method="PUT")
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            text = response.read().decode("utf-8", errors="replace")
            return response.status, text
    except urllib.error.HTTPError as exc:
        text = exc.read().decode("utf-8", errors="replace") if exc.fp else ""
        return exc.code, text


def fetch_sitemap_urls(sitemap_url: str) -> list[str]:
    request = urllib.request.Request(
        sitemap_url,
        headers={"User-Agent": "zenithlaw-search-notifier/1.0"},
        method="GET",
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        xml_text = response.read().decode("utf-8", errors="replace")

    root = ET.fromstring(xml_text)
    namespace = "{http://www.sitemaps.org/schemas/sitemap/0.9}"
    urls: list[str] = []

    for loc in root.findall(f".//{namespace}url/{namespace}loc"):
        if loc.text:
            urls.append(loc.text.strip())

    # If namespace-aware search found nothing, fallback to non-namespaced tags.
    if not urls:
        for loc in root.findall(".//url/loc"):
            if loc.text:
                urls.append(loc.text.strip())

    return urls


def submit_indexnow(site_url: str, sitemap_urls: list[str]) -> None:
    indexnow_key = os.getenv("INDEXNOW_KEY", "").strip()
    if not indexnow_key:
        log("Skipping IndexNow: INDEXNOW_KEY is not configured.")
        return

    if not sitemap_urls:
        log("Skipping IndexNow: no URLs were parsed from sitemap.")
        return

    host = urllib.parse.urlparse(site_url).netloc
    key_location = os.getenv("INDEXNOW_KEY_LOCATION", "").strip() or f"{site_url}/{indexnow_key}.txt"
    max_urls = int(os.getenv("INDEXNOW_MAX_URLS", "10000"))
    url_batch = sitemap_urls[:max_urls]

    payload = {
        "host": host,
        "key": indexnow_key,
        "keyLocation": key_location,
        "urlList": url_batch,
    }

    status, body = http_json_post("https://api.indexnow.org/indexnow", payload)
    if 200 <= status < 300:
        log(f"IndexNow success: submitted {len(url_batch)} URLs (status {status}).")
    else:
        log(f"IndexNow failed with status {status}. Response: {body[:1000]}")


def submit_bing_sitemap(site_url: str, sitemap_url: str) -> None:
    api_key = os.getenv("BING_WEBMASTER_API_KEY", "").strip()
    if not api_key:
        log("Skipping Bing Webmaster sitemap submit: BING_WEBMASTER_API_KEY is not configured.")
        return

    endpoint = "https://ssl.bing.com/webmaster/api.svc/json/SubmitSiteMap"
    query = urllib.parse.urlencode(
        {
            "apikey": api_key,
            "siteUrl": site_url,
            "siteMap": sitemap_url,
        }
    )
    request_url = f"{endpoint}?{query}"

    # Bing SubmitSiteMap endpoint expects GET semantics for query-style submission.
    status, body = http_get(request_url)
    if status == 405:
        # Some edge environments may enforce POST instead of GET.
        status, body = http_form_post(
            endpoint,
            {
                "apikey": api_key,
                "siteUrl": site_url,
                "siteMap": sitemap_url,
            },
        )

    if 200 <= status < 300:
        log(f"Bing Webmaster sitemap submit success (status {status}).")
    else:
        log(f"Bing Webmaster sitemap submit failed with status {status}. Response: {body[:1000]}")


def load_google_service_account_info() -> dict | None:
    raw_json = os.getenv("GOOGLE_SERVICE_ACCOUNT_JSON", "").strip()
    raw_b64 = os.getenv("GOOGLE_SERVICE_ACCOUNT_JSON_B64", "").strip()

    if raw_json:
        try:
            return json.loads(raw_json)
        except json.JSONDecodeError as exc:
            log(f"Invalid GOOGLE_SERVICE_ACCOUNT_JSON: {exc}")
            return None

    if raw_b64:
        try:
            decoded = base64.b64decode(raw_b64).decode("utf-8")
            return json.loads(decoded)
        except Exception as exc:  # noqa: BLE001
            log(f"Invalid GOOGLE_SERVICE_ACCOUNT_JSON_B64: {exc}")
            return None

    return None


def get_google_access_token_from_oauth_refresh() -> str | None:
    client_id = os.getenv("GOOGLE_CLIENT_ID", "").strip()
    client_secret = os.getenv("GOOGLE_CLIENT_SECRET", "").strip()
    refresh_token = os.getenv("GOOGLE_REFRESH_TOKEN", "").strip()
    token_uri = os.getenv("GOOGLE_OAUTH_TOKEN_URI", "").strip() or "https://oauth2.googleapis.com/token"

    if not client_id or not client_secret or not refresh_token:
        return None

    status, body = http_form_post(
        token_uri,
        {
            "client_id": client_id,
            "client_secret": client_secret,
            "refresh_token": refresh_token,
            "grant_type": "refresh_token",
        },
    )

    if status < 200 or status >= 300:
        log(f"Google OAuth refresh-token flow failed with status {status}. Response: {body[:1000]}")
        return None

    try:
        payload = json.loads(body)
    except json.JSONDecodeError:
        log("Google OAuth refresh-token flow returned non-JSON response.")
        return None

    access_token = str(payload.get("access_token", "")).strip()
    if not access_token:
        log("Google OAuth refresh-token flow succeeded but access_token is missing.")
        return None

    return access_token


def get_google_access_token() -> tuple[str | None, str | None]:
    service_account_info = load_google_service_account_info()
    if service_account_info:
        try:
            from google.auth.transport.requests import Request  # type: ignore
            from google.oauth2 import service_account  # type: ignore
        except Exception as exc:  # noqa: BLE001
            log(f"Google service-account flow unavailable because google-auth dependency failed ({exc}).")
        else:
            credentials = service_account.Credentials.from_service_account_info(
                service_account_info,
                scopes=["https://www.googleapis.com/auth/webmasters"],
            )
            credentials.refresh(Request())
            token = str(credentials.token or "").strip()
            if token:
                return token, "service-account"
            log("Google service-account flow returned an empty access token.")

    oauth_token = get_google_access_token_from_oauth_refresh()
    if oauth_token:
        return oauth_token, "oauth-refresh-token"

    return None, None


def submit_google_sitemap(site_url: str, sitemap_url: str) -> None:
    access_token, auth_method = get_google_access_token()
    if not access_token:
        log(
            "Skipping Google sitemap submit: no usable Google auth method found "
            "(service account or OAuth refresh-token)."
        )
        return

    google_site_url = os.getenv("GOOGLE_SITE_URL", "").strip() or f"{site_url}/"
    # Search Console siteUrl must be URL-encoded exactly as property key.
    encoded_site = urllib.parse.quote(google_site_url, safe="")
    encoded_sitemap = urllib.parse.quote(sitemap_url, safe="")
    endpoint = f"https://www.googleapis.com/webmasters/v3/sites/{encoded_site}/sitemaps/{encoded_sitemap}"

    status, body = http_put(
        endpoint,
        headers={
            "Authorization": f"Bearer {access_token}",
        },
    )
    if 200 <= status < 300:
        log(f"Google Search Console sitemap submit success via {auth_method} (status {status}).")
    else:
        log(f"Google Search Console sitemap submit failed with status {status}. Response: {body[:1000]}")


def main() -> int:
    site_url = normalize_site_url(os.getenv("SITE_URL", "https://zenithlaw.com"))
    sitemap_url = os.getenv("SITEMAP_URL", "").strip() or f"{site_url}/sitemap.xml"

    log(f"Using site URL: {site_url}")
    log(f"Using sitemap URL: {sitemap_url}")

    sitemap_urls: list[str] = []
    try:
        sitemap_urls = fetch_sitemap_urls(sitemap_url)
        log(f"Parsed {len(sitemap_urls)} URLs from sitemap.")
    except Exception as exc:  # noqa: BLE001
        log(f"Failed to fetch/parse sitemap: {exc}")

    submit_indexnow(site_url, sitemap_urls)
    submit_bing_sitemap(site_url, sitemap_url)
    submit_google_sitemap(site_url, sitemap_url)
    return 0


if __name__ == "__main__":
    sys.exit(main())