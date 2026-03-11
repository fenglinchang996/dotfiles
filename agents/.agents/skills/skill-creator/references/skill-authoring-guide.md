# Skill Authoring Guide

Distilled from Anthropic's skill authoring guidance (platform.claude.com) and the Agent Skills open standard (agentskills.io). Kept cross-agent with no Claude-specific details.

## Golden Rule and Scope

Only include information the agent does not already know. Large language models already know programming languages, common frameworks, and standard patterns.

Prioritize:

- Project-specific conventions (naming, file structure, architecture decisions)
- Domain-specific constraints (business rules, regulatory requirements)
- Workflow-specific procedures (deploy flow, review checklist, testing strategy)
- Preferences that differ from common defaults

Keep SKILL.md focused and move depth to `references/` and `scripts/`:

- If SKILL.md exceeds ~3500 words, move details out of the body.
- If the body approaches 5000 tokens, split content to avoid activation bloat.
- Keep descriptions concise; hard limit is 1024 characters.

## Degrees of Freedom

Match instruction specificity to task fragility.

### Low Freedom (Brittle or High-Stakes)

Use for security-critical code, data migrations, API contracts, and compliance checks. Give exact steps, exact formats, and explicit validation rules.

```markdown
## Rules

- Always use parameterized queries. Never concatenate user input into SQL strings.
- Validate all input against `references/input-schema.json` before processing.
- Log every mutation with timestamp, user ID, and previous value.
```

### Medium Freedom (Standard Delivery)

Use for feature implementation, refactoring, and standard CRUD work. Define patterns and constraints, then let the agent fill in implementation details.

```markdown
## Instructions

Follow the repository's endpoint pattern:

- Controllers in `src/controllers/`, services in `src/services/`
- Use `BaseController` for consistent error handling
- Write integration tests alongside implementation
```

### High Freedom (Creative or Exploratory)

Use for prototyping, exploration, and brainstorming. State the goal and quality bar, then allow latitude in approach.

```markdown
## Instructions

Generate a proof-of-concept for real-time collaboration. Optimize for clarity
and simplicity over production readiness.
```

## Body Instruction Style

- Use imperative mood: "Always validate input before processing," not "You should validate input."
- Prefer concrete instructions: include exact paths, commands, and patterns.
- Keep one concept per bullet in rules sections.
- Front-load action before rationale.

## Writing Descriptions That Trigger Reliably

Source: agentskills.io/skill-creation/optimizing-descriptions

Use this formula:

```
[Action verb, third person] + [what it does] + [when to use it]
```

Practical pattern:

- Sentence 1: third-person capability statement.
- Sentence 2: imperative trigger context, usually starting with "Use this skill when..."

Optimize for trigger accuracy:

- Focus on user intent, not internal implementation.
- Explicitly list contexts where the skill should activate, including implicit phrasing.
- Be specific enough to avoid false triggers, broad enough to catch realistic phrasing.

Good examples:

- "Enforces the team's TypeScript style guide and naming conventions. Use this skill when writing or reviewing TypeScript code in this project."
- "Generates database migration files from schema changes. Use this skill when modifying the data model."
- "Scaffolds new React components with tests, stories, and proper directory structure. Use this skill when creating new UI components."

Bad examples:

- "Helps with code" (too vague)
- "I help you write better TypeScript" (first person, vague)
- "TypeScript helper" (fragment, no trigger context)

## Skill Naming Conventions

These conventions apply to the skill's name (for example, the skill directory/identifier), not to code symbols inside implementation files.

Prefer these patterns:

- Gerund form: `processing-pdfs`, `generating-reports`, `reviewing-code`
- Noun phrase: `api-patterns`, `test-standards`, `deploy-checklist`
- Action-oriented: `create-component`, `fix-imports`, `validate-schema`

## Common Mistakes

1. Teaching model basics instead of project-specific rules.
2. Presenting many options without a recommended default.
3. Using nested references (`references/a.md` -> `references/b.md` -> `references/c.md`).
4. Using platform-specific paths where POSIX paths would be portable.
5. Letting instructions go stale as APIs and directories change.
6. Writing vague triggers (for example, "use for coding tasks").

## Evaluation and Benchmarking

Testing trigger accuracy and evaluating skill output quality are covered in
`references/skill-evaluation-guide.md`.
