# typesafe-ai

## What it does

Builds and runs typed AI decisions — judgments (`noul`), choices (`choice`),
and scores (`score`) — against the Typesafe System One (Jev) models. Decisions
come back structured, so code can combine them instead of parsing free-form
LLM output.

## When to use it

- A feature needs programmable common sense, or an LLM prompt-and-parse step
  could become a structured decision.
- Routing, ranking, extraction, verification, or interactions driven by
  typed judgments.

## When not to use it

- Free-form text generation, chat, or anything needing a full conversation loop.
- Hosts without bash, curl, and jq.

## Bundled CLI

`jev` — bash + curl + jq, no other dependencies.

| command | purpose |
|---|---|
| `jev models` | list available models |
| `jev evaluate <file> [args]` | run a decision tree from JSON |
| `jev check <file>` | validate a decision tree (no API key needed) |
| `jev init [out]` | scaffold a decision tree from a template |
| `jev docs` | print API and CLI reference |

Flags: `-m/--model`, `-s/--state <file>`, `-a/--answer <id>`, `--dry-run`
(render payload, no key needed), `-v/--verbose`, `--timeout <s>` (default 10),
`--retries <n>` (default 2).

Templates via `jev init`: `noul_single`, `choice_routing`, `score_rubric`,
`fanout_mixed`. Worked example at `assets/customer_support.json`.

## Requirements

- bash, curl, jq
- `TYPESAFE_API_KEY` for `models` / `evaluate` (`check` and `--dry-run` need no key)
- Optional env: `TYPESAFE_BASE_URL` (default `https://api.typesafe.ai`),
  `TYPESAFE_DEFAULT_MODEL` (default `jev-latest`), `TYPESAFE_LOG_LEVEL=debug`
- Reads the nearest `.env` walking up from the script

## Package

Version, checksum, and the versioned archive: see the catalog at
[skills.md](/skills.md).

Install (global):

    curl -fsSL https://isandburn.github.io/skills/typesafe-ai.zip | unzip -o -d ~/.config/opencode/skills

Install (project-local):

    curl -fsSL https://isandburn.github.io/skills/typesafe-ai.zip | unzip -o -d .opencode/skills

Source: [github.com/isandburn/jev-test](https://github.com/isandburn/jev-test),
path `.opencode/skills/typesafe-ai`.
