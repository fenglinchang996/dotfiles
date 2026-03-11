---
name: skill-creator
description: >-
  Creates and iterates on agent skills that follow the Agent Skills open standard (agentskills.io).
  Produces skills compatible with 30+ agents including Claude Code, OpenCode, Cursor, GitHub Copilot, Gemini CLI, Goose, Roo Code, and more.
  Use when asked to create a new skill, write a skill, build a skill, or improve an existing skill.
license: MIT
compatibility: Works with any agent that supports the Agent Skills standard (agentskills.io)
---

# Skill Creator

You are an expert skill author. When the user asks you to create, write, build, or improve an agent skill, follow this guide precisely.

## Workflow

1. **Clarify the intent** — Ask what the skill should do, when it should trigger, and what agents/projects it targets. If the user already provided enough detail, skip to step 2.
2. **Choose placement** — Decide where the skill lives:
   - `<project>/.agents/skills/<name>/` — cross-agent, project-scoped (recommended default)
   - `~/.agents/skills/<name>/` — cross-agent, user-global
   - `~/.config/opencode/skills/<name>/` — OpenCode only, user-global
   - `<project>/.claude/skills/<name>/` — Claude Code only, project-scoped
3. **Write the SKILL.md** — Follow the specification and quality standards below.
4. **Add scripts if needed** — Create reusable helpers in `scripts/` when instructions would otherwise require complex, repeated, or error-prone commands. Keep script interfaces non-interactive, include `--help`, and provide runnable examples in `SKILL.md`.
5. **Add references if needed** — Move detailed supporting material to `references/` (domain rules, decision trees, long examples, checklists) so the main body stays concise and follows progressive disclosure.
6. **Implement referenced files** — If `SKILL.md` references script or reference paths, create those files and ensure paths are correct and one level deep from the skill root.
7. **Review against the checklist** — Verify every item in the Quality Checklist section.
8. **Optional: Evaluate reliability** — If the user asks for testing/evaluation, or if trigger/output reliability is a concern, run the workflows in `references/skill-evaluation-guide.md`.

## `SKILL.md` Specification

### Frontmatter (YAML)

The frontmatter requires `name` and `description`. All other fields are optional. For exact field constraints, naming rules, and validation examples, see [references/skill-spec-reference.md](references/skill-spec-reference.md).

```yaml
---
name: my-skill-name
description: >-
  Does X when Y happens. Use when the user asks to do Z.
license: MIT
compatibility: Requires Node.js 18+.
metadata:
  version: "1.0"
allowed-tools: Bash(git:*) Read
---
```

### Body Content

The body after the frontmatter contains the skill instructions. Keep it **under 500 lines** and **under 5000 tokens**. Split longer content into referenced files.

Recommended sections:

```markdown
# Skill Title

Brief one-line purpose statement.

## Instructions

Step-by-step instructions for the agent. Write in second person imperative
("Do X", "Always Y", "Never Z").

## Examples (optional)

Concrete input/output examples wrapped in fenced code blocks.

## Common Edge Cases (optional)

Known pitfalls or boundary conditions to handle.
```

### Directory Structure

```
<skill-name>/
  SKILL.md              # Required. Metadata + instructions.
  scripts/              # Optional. Executable code.
  references/           # Optional. Additional documentation.
  assets/               # Optional. Templates, resources.
```

For details on what each optional directory contains, see [references/skill-spec-reference.md](references/skill-spec-reference.md).

### File References

Reference other files using relative paths from the skill root. Keep references one level deep.

```markdown
See [the reference guide](references/REFERENCE.md) for details.

Run the extraction script:
scripts/extract.py
```

### Scripts in `SKILL.md`

If a skill includes `scripts/`, include a short "Available scripts" list and runnable examples.

Create scripts when they improve reliability, especially for multi-step transformations, repeated workflows, or commands that are hard to run correctly on the first try.

- Use relative paths from the skill root (for example `scripts/process.py`).
- Keep scripts non-interactive (no prompts); pass all inputs via args/env/stdin.
- Prefer parseable stdout (JSON/CSV/TSV) and send diagnostics to stderr.
- Provide `--help` and document key flags (`--input`, `--output`, `--dry-run`, `--apply`).
- Use safe defaults for destructive actions (`--dry-run` or explicit `--apply`).

## Writing Quality Standards

For detailed guidance on description writing, instruction style, degrees of freedom, naming, and anti-patterns, see [references/skill-authoring-guide.md](references/skill-authoring-guide.md).

For optional trigger evaluation and output-quality benchmarking workflows (use when requested or when tuning skill reliability), see [references/skill-evaluation-guide.md](references/skill-evaluation-guide.md).

For script interface, safety, and reliability guidance, see [references/skill-scripts-guide.md](references/skill-scripts-guide.md).

Key principle: **Progressive Disclosure** — the description must be self-sufficient for matching, the body must be self-sufficient for execution, and detailed reference material belongs in separate files. See [references/skill-spec-reference.md](references/skill-spec-reference.md) for tier budgets.

## Cross-Agent Compatibility Notes

The Agent Skills standard (agentskills.io) is supported by 30+ agents. To maximize compatibility:

- Use `.agents/skills/` as the directory convention (the interoperability standard)
- Keep SKILL.md as pure markdown — no agent-specific tool calls or syntax in the body
- Do not assume any specific tool is available (e.g., don't reference `present_files`, `claude -p`, etc.)
- Write instructions as behavioral guidance, not tool invocations
- If a skill genuinely needs agent-specific behavior, document it in a clearly-labeled section
- Test that the skill makes sense if you strip all agent-specific context — the core instructions should still be actionable

## Quality Checklist

Before finalizing any skill, verify both categories:

### Spec Compliance

These can be validated mechanically — use `skills-ref validate ./my-skill` when available, or check against [references/skill-spec-reference.md](references/skill-spec-reference.md).

- [ ] `name` matches directory name, lowercase letters/numbers/hyphens only, no leading/trailing/consecutive hyphens
- [ ] `name` is max 64 characters
- [ ] `description` is max 1024 characters
- [ ] Body is under 500 lines
- [ ] Body is under ~5000 tokens (rough guide: under 3500 words)
- [ ] All file paths use POSIX format
- [ ] Frontmatter YAML is valid
- [ ] Directory structure follows the standard layout

### Authoring Judgment

These require human/agent judgment — no tool can verify them automatically.

- [ ] `description` is third person and includes trigger keywords
- [ ] `description` states both what and when
- [ ] Instructions use imperative mood
- [ ] No agent-specific tool references in core instructions
- [ ] No knowledge the model already has (no teaching basic syntax)
- [ ] File references are at most one level deep from `SKILL.md`
- [ ] If `scripts/` is used, `SKILL.md` includes an "Available scripts" list and runnable examples
- [ ] If `SKILL.md` references a script path, that script file exists and is runnable as documented
- [ ] If scripts mutate state, instructions include dry-run/apply safety guidance

## Iteration Process

When improving an existing skill:

1. Read the current SKILL.md fully before making changes.
2. Identify what's working and what's not — ask the user for specific pain points.
3. Check against the Quality Checklist above.
4. Make targeted edits rather than full rewrites unless the skill is fundamentally broken.
5. After editing, re-verify the checklist.
6. Optional: If reliability is part of the goal, run trigger/output evaluations and compare results with the prior iteration.

Evaluation and benchmarking are optional follow-up activities, not required outputs for every skill-creation request.
