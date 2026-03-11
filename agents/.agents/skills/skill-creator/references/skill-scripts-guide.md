# Skill Scripts Guide

Use this guide when writing or invoking files in `scripts/` within a skill.

## When to Use Scripts vs One-Off Commands

- Use a one-off command in `SKILL.md` when the command is short and reliable.
- Use a bundled script when logic is multi-step, reused, or easy to get wrong.
- Pin tool versions for reproducibility (for example `npx eslint@9.0.0`).
- State runtime prerequisites in frontmatter `compatibility` and in usage notes.

## Referencing Scripts from SKILL.md

- Always reference scripts with paths relative to the skill root (for example `scripts/process.py`).
- List available scripts in `SKILL.md` so agents know they exist.
- Keep command examples copy-pastable and minimal.

Example:

````markdown
## Available scripts

- `scripts/validate.sh` - validates input config
- `scripts/process.py` - transforms validated data

## Workflow

1. Validate input:
   ```bash
   bash scripts/validate.sh "$INPUT_FILE"
   ```
2. Process data:
   ```bash
   python3 scripts/process.py --input results.json
   ```
````

## How to Write Scripts for Agents

### Non-Interactive by Design

- Never require TTY prompts, menus, or password input.
- Accept all input via flags, environment variables, or stdin.
- If required input is missing, fail immediately with a clear usage hint.

### Interface and Help

- Implement `--help` with purpose, required/optional flags, and examples.
- Use stable flag names (`--input`, `--output`, `--format`, `--dry-run`, `--apply`).
- Document exit codes (`0` success, non-zero failures with meanings).

### Output Contract

- Emit parseable primary output (JSON/CSV/TSV) to stdout.
- Emit diagnostics and progress to stderr.
- Keep output deterministic and bounded; support pagination/limits for large output.

### Safety and Reliability

- Validate inputs before side effects.
- Make retries safe (idempotent behavior where practical).
- For destructive actions, default to preview mode and require explicit apply/confirm flags.
- Check dependencies and preconditions up front with actionable remediation.

## Self-Contained Dependency Patterns

Prefer script-local dependency declarations when the ecosystem supports them:

- Python: PEP 723 inline metadata, run with `uv run scripts/<file>.py`.
- Deno: `npm:`/`jsr:` imports directly in script.
- Bun: versioned imports (for example `pkg@1.2.3`) when appropriate.
- Ruby: `bundler/inline` for script-local gems.

If inline dependencies are not available, document setup and versions near the script.

## Python Template (Agent-Friendly)

```python
#!/usr/bin/env python3
import argparse
import json
import sys


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Process an input file.")
    parser.add_argument("--input", required=True, help="Input file path")
    parser.add_argument("--apply", action="store_true", help="Apply changes")
    return parser


def main() -> int:
    args = build_parser().parse_args()
    mode = "apply" if args.apply else "dry-run"
    result = {"input": args.input, "mode": mode}
    print(json.dumps(result))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
```

## Bash Template (Agent-Friendly)

```bash
#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s --input <path> [--apply]\n' "$0" >&2
}

input=''
apply='false'

while [[ $# -gt 0 ]]; do
  case "$1" in
    --input) input="${2:-}"; shift 2 ;;
    --apply) apply='true'; shift ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown argument: %s\n' "$1" >&2; usage; exit 2 ;;
  esac
done

if [[ -z "$input" ]]; then
  printf 'Error: --input is required\n' >&2
  usage
  exit 2
fi

mode='dry-run'
if [[ "$apply" == 'true' ]]; then
  mode='apply'
fi

printf '{"input":"%s","mode":"%s"}\n' "$input" "$mode"
```

## Script Checklist

- Non-interactive operation only
- Clear `--help` and examples
- Structured stdout, diagnostics on stderr
- Input validation before side effects
- Safe defaults for destructive actions
- Documented dependencies and exit codes
