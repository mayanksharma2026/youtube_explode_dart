from __future__ import annotations

import json
import pathlib
import tempfile
import unittest

from tool.source_watch import (
    Head,
    Source,
    inspect_sources,
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
