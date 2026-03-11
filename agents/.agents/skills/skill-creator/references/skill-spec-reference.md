# Skills Spec Guide

Source: agentskills.io/specification (Agent Skills Open Standard)

## Frontmatter Fields

| Field           | Required | Max Length | Notes                                                                                                         |
| --------------- | -------- | ---------- | ------------------------------------------------------------------------------------------------------------- |
| `name`          | Yes      | 64 chars   | Lowercase letters, numbers, hyphens only. No leading/trailing/consecutive hyphens. Must match directory name. |
| `description`   | Yes      | 1024 chars | Describes what the skill does and when to use it. Include trigger keywords.                                   |
| `license`       | No       | —          | License name or reference to a bundled license file.                                                          |
| `compatibility` | No       | 500 chars  | Environment requirements (intended product, system packages, network access, etc.).                           |
| `metadata`      | No       | —          | Arbitrary key-value mapping for additional metadata.                                                          |
| `allowed-tools` | No       | —          | Experimental. Space-delimited list of pre-approved tools the skill may use.                                   |

## Progressive Disclosure

| Level | Content                                    | Budget                    | Loaded When                      |
| ----- | ------------------------------------------ | ------------------------- | -------------------------------- |
| 1     | Metadata (name + description)              | ~100 tokens               | Always (startup), for all skills |
| 2     | Instructions (`SKILL.md` body)             | < 5000 tokens recommended | When the skill is activated      |
| 3     | Resources (scripts/, references/, assets/) | As needed                 | Only when required               |

## Body Content

- Standard markdown (CommonMark)
- No format restrictions on content structure
- Keep under 500 lines
- Keep under 5000 tokens for level 2 budget compliance
- Consider splitting longer content into referenced files

## Directory Structure

```
skills/
  <skill-name>/          # Name must match frontmatter `name`
    SKILL.md             # Required — metadata + instructions
    scripts/             # Optional — executable code
    references/          # Optional — additional documentation
    assets/              # Optional — templates, resources
```

### `scripts/`

Contains executable code that agents can run. Scripts should:

- Be self-contained or clearly document dependencies
- Include helpful error messages
- Handle edge cases gracefully

Supported languages depend on the agent implementation. Common options include Python, Bash, and JavaScript.

### `references/`

Contains additional documentation that agents can read when needed:

- `REFERENCE.md` — Detailed technical reference
- `FORMS.md` — Form templates or structured data formats
- Domain-specific files (`finance.md`, `legal.md`, etc.)

Keep individual reference files focused. Agents load these on demand, so smaller files mean less use of context.

### `assets/`

Contains static resources:

- Templates (document templates, configuration templates)
- Images (diagrams, examples)
- Data files (lookup tables, schemas)

## File References

- Use relative paths from the skill root
- Keep file references one level deep from `SKILL.md`
- Avoid deeply nested reference chains

## Discovery Paths (where agents look for skills)

### Project-Level

- `<project>/.agents/skills/*/SKILL.md` — Cross-agent standard
- `<project>/.claude/skills/*/SKILL.md` — Claude Code
- `<project>/.<client>/skills/*/SKILL.md` — Client-specific

### User-Level (Global)

- `~/.agents/skills/*/SKILL.md` — Cross-agent standard
- `~/.claude/skills/*/SKILL.md` — Claude Code
- `~/.config/opencode/skills/*/SKILL.md` — OpenCode
- `~/.config/<client>/skills/*/SKILL.md` — Client-specific

## Compatible Agents (as of 2025)

The following agents support the Agent Skills standard:

Amp, Aider, Amazon Q Developer, Augment Code, Claude Code, Cline, Codex, Continue,
Copilot (VS Code), Cursor, Databricks, Gemini CLI, GitHub Copilot, Goose, Junie
(JetBrains), Kilo Code, Melty, Mistral Vibe, OpenCode, OpenHands, PearAI, Qodo,
Replit Agent, Roo Code, Sourcegraph Cody, Tabnine, Trae, Void, Windsurf, Zed

### Compatibility Notes

- GitHub Copilot also reads `copilot-instructions.md`, `AGENTS.md`, `.instructions.md`
- Cursor also reads `.cursor/rules/` and `.cursorrules`
- These are agent-specific formats, not part of the Agent Skills standard
- For maximum reach, use `.agents/skills/` and the standard SKILL.md format

## Name Validation Examples

| Name            | Valid | Reason                          |
| --------------- | ----- | ------------------------------- |
| `my-skill`      | Yes   | Lowercase + hyphens             |
| `skill123`      | Yes   | Lowercase + numbers             |
| `my-cool-skill` | Yes   | Multiple hyphens OK             |
| `MySkill`       | No    | Uppercase not allowed           |
| `my_skill`      | No    | Underscores not allowed         |
| `my--skill`     | No    | Consecutive hyphens not allowed |
| `-my-skill`     | No    | Cannot start with hyphen        |
| `my-skill-`     | No    | Cannot end with hyphen          |

## Validation

Use `skills-ref validate ./my-skill` (from [skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref)) to validate frontmatter and naming conventions.
