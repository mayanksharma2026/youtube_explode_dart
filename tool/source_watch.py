#!/usr/bin/env python3
"""Generate a read-only report for registered upstream and fork revisions.

The source registry intentionally uses a constrained YAML shape. This script
extracts only top-level source lists and their scalar ``repo``, ``branch``,
``reviewed_commit``, and ``role`` fields; it is not a general YAML parser.
"""

from __future__ import annotations

import argparse
import ast
import dataclasses
import datetime as dt
import json
import os
import pathlib
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from collections.abc import Callable, Iterable
from typing import Any

_GITHUB_API = "https://api.github.com"
_TOP_LEVEL_RE = re.compile(r"^([a-z][a-z0-9_]*):\s*$")
_TOP_LEVEL_SCALAR_RE = re.compile(r"^[a-z][a-z0-9_]*:\s+.+$")
_SOURCE_START_RE = re.compile(r"^  - repo:\s*(.+?)\s*$")
_SOURCE_FIELD_RE = re.compile(r"^    ([a-z][a-z0-9_]*):\s*(.*?)\s*$")


@dataclasses.dataclass(frozen=True, slots=True)
class Source:
    category: str
    repo: str
    branch: str
    reviewed_commit: str | None
    role: str | None


@dataclasses.dataclass(frozen=True, slots=True)
class Head:
    sha: str
    committed_at: str | None
    message: str | None
    html_url: str | None


@dataclasses.dataclass(frozen=True, slots=True)
class Inspection:
    source: Source
    status: str
    head: Head | None
    error: str | None = None


def _scalar(raw: str) -> str:
    value = raw.strip()
    if not value:
        return ""
    if value[0] in {"'", '"'}:
        parsed = ast.literal_eval(value)
        if not isinstance(parsed, str):
            raise ValueError(f"Expected string scalar, received: {raw!r}")
        return parsed
    return value.split(" #", 1)[0].strip()


def parse_registry(path: pathlib.Path) -> list[Source]:
    """Read source entries from the repository's constrained YAML registry."""

    sources: list[Source] = []
    category: str | None = None
    current: dict[str, str] | None = None

    def finish_current() -> None:
        nonlocal current
        if current is None:
            return
        repo = current.get("repo", "").strip()
        if not repo:
            current = None
            return
        branch = current.get("branch", "").strip()
        if not branch:
            raise ValueError(f"Source {repo!r} is missing a branch")
        if category is None:
            raise ValueError(f"Source {repo!r} is not inside a top-level section")
        sources.append(
            Source(
                category=category,
                repo=repo,
                branch=branch,
                reviewed_commit=current.get("reviewed_commit") or None,
                role=current.get("role") or None,
            )
        )
        current = None

    for line_number, line in enumerate(
        path.read_text(encoding="utf-8").splitlines(),
        1,
    ):
        if not line.strip() or line.lstrip().startswith("#"):
            continue

        top_level = _TOP_LEVEL_RE.match(line)
        if top_level:
            finish_current()
            category = top_level.group(1)
            continue

        if _TOP_LEVEL_SCALAR_RE.match(line):
            finish_current()
            category = None
            continue

        source_start = _SOURCE_START_RE.match(line)
        if source_start:
            finish_current()
            current = {"repo": _scalar(source_start.group(1))}
            continue

        source_field = _SOURCE_FIELD_RE.match(line)
        if source_field and current is not None:
            key, raw_value = source_field.groups()
            if key in {"branch", "reviewed_commit", "role"}:
                current[key] = _scalar(raw_value)
            continue

        # Other nested YAML belongs to notes, inspect lists, policy, or
        # exclusions and is deliberately ignored by this constrained reader.
        if line.startswith("  "):
            continue

        raise ValueError(
            f"Unsupported registry syntax at line {line_number}: {line}"
        )

    finish_current()

    if not sources:
        raise ValueError(f"No source entries found in {path}")

    seen: set[tuple[str, str]] = set()
    for source in sources:
        key = (source.repo.lower(), source.branch)
        if key in seen:
            raise ValueError(
                f"Duplicate source entry for {source.repo}@{source.branch}"
            )
        seen.add(key)

    return sources


def fetch_head(
    source: Source,
    *,
    token: str | None = None,
    timeout_seconds: float = 20.0,
    attempts: int = 3,
) -> Head:
    """Fetch the current head commit for one public GitHub repository branch."""

    repo_path = "/".join(
        urllib.parse.quote(part, safe="") for part in source.repo.split("/")
    )
    branch = urllib.parse.quote(source.branch, safe="")
    url = f"{_GITHUB_API}/repos/{repo_path}/commits/{branch}"
    headers = {
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
        "User-Agent": "youtube-explode-dart-source-watch/1.0",
    }
    if token:
        headers["Authorization"] = f"Bearer {token}"

    last_error: Exception | None = None
    for attempt in range(1, attempts + 1):
        request = urllib.request.Request(url, headers=headers)
        try:
            with urllib.request.urlopen(
                request,
                timeout=timeout_seconds,
            ) as response:
                payload = json.load(response)
            sha = payload.get("sha")
            if not isinstance(sha, str) or not sha:
                raise ValueError(
                    f"GitHub returned no SHA for {source.repo}@{source.branch}"
                )
            commit = payload.get("commit") or {}
            committer = commit.get("committer") or {}
            message = commit.get("message")
            html_url = payload.get("html_url")
            return Head(
                sha=sha,
                committed_at=(
                    committer.get("date") if isinstance(committer, dict) else None
                ),
                message=(
                    message.splitlines()[0] if isinstance(message, str) else None
                ),
                html_url=html_url if isinstance(html_url, str) else None,
            )
        except urllib.error.HTTPError as error:
            last_error = error
            retryable = error.code == 429 or error.code >= 500
            if not retryable or attempt == attempts:
                break
            retry_after = error.headers.get("Retry-After") if error.headers else None
            try:
                delay = float(retry_after) if retry_after else 2 ** (attempt - 1)
            except ValueError:
                delay = 2 ** (attempt - 1)
            time.sleep(min(delay, 30.0))
        except (
            urllib.error.URLError,
            TimeoutError,
            ValueError,
            json.JSONDecodeError,
        ) as error:
            last_error = error
            if attempt == attempts:
                break
            time.sleep(min(2 ** (attempt - 1), 10))

    if isinstance(last_error, urllib.error.HTTPError):
        raise RuntimeError(
            f"GitHub returned HTTP {last_error.code} for "
            f"{source.repo}@{source.branch}"
        ) from last_error
    raise RuntimeError(
        f"Could not fetch {source.repo}@{source.branch}: {last_error}"
    ) from last_error


def inspect_sources(
    sources: Iterable[Source],
    fetcher: Callable[[Source], Head],
) -> list[Inspection]:
    inspections: list[Inspection] = []
    for source in sources:
        try:
            head = fetcher(source)
        except Exception as error:  # report each source independently
            inspections.append(
                Inspection(
                    source=source,
                    status="error",
                    head=None,
                    error=str(error),
                )
            )
            continue

        if source.reviewed_commit is None:
            status = "unreviewed"
        elif head.sha == source.reviewed_commit:
            status = "current"
        else:
            status = "changed"
        inspections.append(Inspection(source=source, status=status, head=head))
    return inspections


def _short_sha(value: str | None) -> str:
    return value[:12] if value else "—"


def _escape_table(value: str | None) -> str:
    if not value:
        return "—"
    return value.replace("|", "\\|").replace("\n", " ").strip()


def render_markdown(
    inspections: Iterable[Inspection],
    generated_at: str,
) -> str:
    rows = list(inspections)
    changed = sum(item.status == "changed" for item in rows)
    unreviewed = sum(item.status == "unreviewed" for item in rows)
    errors = sum(item.status == "error" for item in rows)

    output = [
        "# Source intelligence report",
        "",
        f"Generated: `{generated_at}`",
        "",
        f"Sources: **{len(rows)}** · Changed: **{changed}** · "
        f"Unreviewed: **{unreviewed}** · Errors: **{errors}**",
        "",
        "> This report is read-only. A changed head is a research signal, "
        "not an approved patch.",
        "",
        "| Status | Category | Repository | Branch | Reviewed | Current | "
        "Latest commit |",
        "| --- | --- | --- | --- | --- | --- | --- |",
    ]

    status_icons = {
        "current": "✅ current",
        "changed": "🔎 changed",
        "unreviewed": "🟡 unreviewed",
        "error": "❌ error",
    }
    for item in rows:
        source = item.source
        current = _short_sha(item.head.sha if item.head else None)
        latest = item.error or (item.head.message if item.head else None)
        output.append(
            "| {status} | `{category}` | `{repo}` | `{branch}` | "
            "`{reviewed}` | `{current}` | {latest} |".format(
                status=status_icons[item.status],
                category=_escape_table(source.category),
                repo=_escape_table(source.repo),
                branch=_escape_table(source.branch),
                reviewed=_short_sha(source.reviewed_commit),
                current=current,
                latest=_escape_table(latest),
            )
        )

    changed_rows = [item for item in rows if item.status == "changed"]
    if changed_rows:
        output.extend(["", "## Review queue", ""])
        for item in changed_rows:
            assert item.head is not None
            output.append(
                f"- `{item.source.repo}@{item.source.branch}` moved from "
                f"`{_short_sha(item.source.reviewed_commit)}` to "
                f"`{_short_sha(item.head.sha)}`. Compare commits and classify "
                "the change before updating the registry."
            )

    return "\n".join(output) + "\n"


def render_json(
    inspections: Iterable[Inspection],
    generated_at: str,
) -> str:
    rows = list(inspections)
    payload: dict[str, Any] = {
        "schema_version": 1,
        "generated_at_utc": generated_at,
        "summary": {
            "sources": len(rows),
            "current": sum(item.status == "current" for item in rows),
            "changed": sum(item.status == "changed" for item in rows),
            "unreviewed": sum(
                item.status == "unreviewed" for item in rows
            ),
            "errors": sum(item.status == "error" for item in rows),
        },
        "sources": [],
    }
    for item in rows:
        payload["sources"].append(
            {
                "category": item.source.category,
                "repo": item.source.repo,
                "branch": item.source.branch,
                "role": item.source.role,
                "reviewed_commit": item.source.reviewed_commit,
                "status": item.status,
                "current_head": (
                    dataclasses.asdict(item.head) if item.head else None
                ),
                "error": item.error,
            }
        )
    return json.dumps(payload, indent=2, sort_keys=True) + "\n"


def _utc_now() -> str:
    return (
        dt.datetime.now(dt.UTC)
        .replace(microsecond=0)
        .isoformat()
        .replace("+00:00", "Z")
    )


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--registry",
        type=pathlib.Path,
        default=pathlib.Path("docs/maintenance-sources.yaml"),
    )
    parser.add_argument(
        "--output-dir",
        type=pathlib.Path,
        default=pathlib.Path("source-watch-report"),
    )
    parser.add_argument(
        "--github-token",
        default=os.environ.get("GITHUB_TOKEN"),
        help="Optional token used only for read-only GitHub API requests.",
    )
    args = parser.parse_args(argv)

    try:
        sources = parse_registry(args.registry)
    except (OSError, ValueError) as error:
        print(f"Registry error: {error}", file=sys.stderr)
        return 2

    inspections = inspect_sources(
        sources,
        lambda source: fetch_head(source, token=args.github_token),
    )
    generated_at = _utc_now()
    args.output_dir.mkdir(parents=True, exist_ok=True)
    markdown_path = args.output_dir / "source-intelligence.md"
    json_path = args.output_dir / "source-intelligence.json"
    markdown_path.write_text(
        render_markdown(inspections, generated_at),
        encoding="utf-8",
    )
    json_path.write_text(
        render_json(inspections, generated_at),
        encoding="utf-8",
    )

    print(markdown_path)
    print(json_path)

    return 1 if any(item.status == "error" for item in inspections) else 0


if __name__ == "__main__":
    raise SystemExit(main())
