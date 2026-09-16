from __future__ import annotations

import io
import json
import pathlib
import tempfile
import unittest
import urllib.error
from contextlib import redirect_stdout
from unittest import mock

from tool.source_watch import (
    Head,
    Source,
    fetch_head,
    inspect_sources,
    main,
    parse_registry,
    render_json,
    render_markdown,
)


class ParseRegistryTest(unittest.TestCase):
    def test_parses_only_registered_source_entries(self) -> None:
        content = '''\
schema_version: 1
policy:
  notes:
    - "ignored"
canonical_dart:
  - repo: "Hexer10/youtube_explode_dart"
    branch: "master"
    reviewed_commit: "abc123"
    role: "upstream"
    inspect:
      - "issues"
watch_only:
  - repo: "example/watch"
    branch: "dev"
    role: "watch"
exclusions:
  - pattern: "mirror"
    reason: "ignored"
'''
        with tempfile.TemporaryDirectory() as temp_dir:
            path = pathlib.Path(temp_dir) / "sources.yaml"
            path.write_text(content, encoding="utf-8")
            sources = parse_registry(path)

        self.assertEqual(
            sources,
            [
                Source(
                    category="canonical_dart",
                    repo="Hexer10/youtube_explode_dart",
                    branch="master",
                    reviewed_commit="abc123",
                    role="upstream",
                ),
                Source(
                    category="watch_only",
                    repo="example/watch",
                    branch="dev",
                    reviewed_commit=None,
                    role="watch",
                ),
            ],
        )

    def test_rejects_duplicate_repo_and_branch(self) -> None:
        content = '''\
first:
  - repo: "owner/repo"
    branch: "main"
second:
  - repo: "OWNER/repo"
    branch: "main"
'''
        with tempfile.TemporaryDirectory() as temp_dir:
            path = pathlib.Path(temp_dir) / "sources.yaml"
            path.write_text(content, encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "Duplicate source"):
                parse_registry(path)

    def test_chameleon_registry_uses_verified_main_branch(self) -> None:
        # Run 34825002484 failed because this entry incorrectly tracked master.
        registry = (
            pathlib.Path(__file__).resolve().parents[1]
            / "docs/maintenance-sources.yaml"
        )
        sources = [
            source
            for source in parse_registry(registry)
            if source.repo == "souravkaushik-dev/chameleon"
        ]
        self.assertEqual(len(sources), 1)
        self.assertEqual(sources[0].branch, "main")


class InspectSourcesTest(unittest.TestCase):
    def test_classifies_current_changed_and_unreviewed(self) -> None:
        sources = [
            Source("one", "a/current", "main", "same", "primary"),
            Source("two", "b/changed", "main", "old", "fork"),
            Source("three", "c/new", "dev", None, "watch"),
        ]
        heads = {
            "a/current": Head(
                "same",
                "2026-09-03T00:00:00Z",
                "same",
                None,
            ),
            "b/changed": Head(
                "new",
                "2026-09-03T00:00:00Z",
                "changed",
                None,
            ),
            "c/new": Head(
                "first",
                "2026-09-03T00:00:00Z",
                "first",
                None,
            ),
        }

        result = inspect_sources(sources, lambda source: heads[source.repo])

        self.assertEqual(
            [item.status for item in result],
            ["current", "changed", "unreviewed"],
        )

    def test_records_fetch_errors_without_aborting_other_sources(self) -> None:
        sources = [
            Source("one", "a/good", "main", "same", None),
            Source("two", "b/bad", "main", "old", None),
        ]

        def fetch(source: Source) -> Head:
            if source.repo == "b/bad":
                raise RuntimeError("not found")
            return Head("same", None, "ok", None)

        result = inspect_sources(sources, fetch)

        self.assertEqual(result[0].status, "current")
        self.assertEqual(result[1].status, "error")
        self.assertEqual(result[1].error, "not found")


class FetchHeadTest(unittest.TestCase):
    def test_missing_branch_is_not_retried_or_silently_replaced(self) -> None:
        source = Source(
            "production_downstream_copies",
            "souravkaushik-dev/chameleon",
            "master",
            None,
            "downstream-signal",
        )
        url = (
            "https://api.github.com/repos/"
            "souravkaushik-dev/chameleon/commits/master"
        )
        error = urllib.error.HTTPError(
            url, 422, "No commit found for SHA: master", None, None,
        )
        with (
            mock.patch(
                "tool.source_watch.urllib.request.urlopen", side_effect=error,
            ) as urlopen,
            mock.patch("tool.source_watch.time.sleep") as sleep,
        ):
            with self.assertRaisesRegex(
                RuntimeError,
                r"^GitHub returned HTTP 422 for "
                r"souravkaushik-dev/chameleon@master$",
            ):
                fetch_head(source)

        urlopen.assert_called_once()
        self.assertEqual(urlopen.call_args.args[0].full_url, url)
        sleep.assert_not_called()


class MainTest(unittest.TestCase):
    def test_exit_status_and_complete_reports_with_and_without_errors(self) -> None:
        registry_text = '''\
tracked:
  - repo: "owner/first"
    branch: "main"
    reviewed_commit: "same"
  - repo: "owner/changed"
    branch: "main"
    reviewed_commit: "old"
  - repo: "owner/unreviewed"
    branch: "dev"
'''
        error_message = "GitHub returned HTTP 422 for owner/first@main"
        for has_error in (False, True):
            with self.subTest(has_error=has_error):
                with tempfile.TemporaryDirectory() as temp_dir:
                    registry = pathlib.Path(temp_dir) / "sources.yaml"
                    registry.write_text(registry_text, encoding="utf-8")
                    output_dir = pathlib.Path(temp_dir) / "reports"
                    first = (
                        RuntimeError(error_message) if has_error
                        else Head("same", None, "current", None)
                    )
                    with (
                        mock.patch(
                            "tool.source_watch.fetch_head",
                            side_effect=[
                                first,
                                Head("new", None, "changed", None),
                                Head("first", None, "unreviewed", None),
                            ],
                        ) as fetcher,
                        mock.patch(
                            "tool.source_watch._utc_now",
                            return_value="2026-09-16T00:00:00Z",
                        ),
                        redirect_stdout(io.StringIO()),
                    ):
                        result = main([
                            "--registry", str(registry),
                            "--output-dir", str(output_dir),
                            "--github-token", "",
                        ])

                    self.assertEqual(result, 1 if has_error else 0)
                    self.assertEqual(fetcher.call_count, 3)
                    payload = json.loads(
                        (output_dir / "source-intelligence.json").read_text(
                            encoding="utf-8",
                        )
                    )
                    markdown = (output_dir / "source-intelligence.md").read_text(
                        encoding="utf-8",
                    )
                    self.assertEqual(payload["schema_version"], 1)
                    self.assertEqual(payload["summary"], {
                        "sources": 3,
                        "current": 0 if has_error else 1,
                        "changed": 1,
                        "unreviewed": 1,
                        "errors": 1 if has_error else 0,
                    })
                    self.assertEqual(
                        [row["status"] for row in payload["sources"]],
                        [
                            "error" if has_error else "current",
                            "changed",
                            "unreviewed",
                        ],
                    )
                    self.assertIn("Review queue", markdown)
                    for repo in (
                        "owner/first", "owner/changed", "owner/unreviewed",
                    ):
                        self.assertIn(repo, markdown)
                    if has_error:
                        self.assertIn(error_message, markdown)
                        self.assertEqual(
                            payload["sources"][0]["error"], error_message,
                        )
                        self.assertIsNone(payload["sources"][0]["current_head"])
                    self.assertEqual(
                        registry.read_text(encoding="utf-8"), registry_text,
                    )


class RenderTest(unittest.TestCase):
    def setUp(self) -> None:
        source = Source(
            "forks",
            "owner/repo",
            "main",
            "old-sha",
            "active-fork",
        )
        self.inspections = inspect_sources(
            [source],
            lambda _: Head(
                "new-sha",
                "2026-09-03T00:00:00Z",
                "fix: changed | safely",
                "https://github.com/owner/repo/commit/new-sha",
            ),
        )

    def test_markdown_contains_summary_and_review_queue(self) -> None:
        rendered = render_markdown(
            self.inspections,
            "2026-09-03T00:00:00Z",
        )
        self.assertIn("Changed: **1**", rendered)
        self.assertIn("Review queue", rendered)
        self.assertIn("fix: changed \\| safely", rendered)

    def test_json_is_machine_readable(self) -> None:
        payload = json.loads(
            render_json(self.inspections, "2026-09-03T00:00:00Z")
        )
        self.assertEqual(payload["summary"]["changed"], 1)
        self.assertEqual(
            payload["sources"][0]["current_head"]["sha"],
            "new-sha",
        )


if __name__ == "__main__":
    unittest.main()
