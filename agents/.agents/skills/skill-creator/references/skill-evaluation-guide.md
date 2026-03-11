# Skill Evaluation Guide

Distilled from Agent Skills guidance on optimizing descriptions and evaluating skill outcomes.

## Testing Trigger Accuracy

Source: agentskills.io/skill-creation/optimizing-descriptions

Build about 20 eval queries (roughly half should-trigger and half should-not-trigger):

- Should-trigger queries should vary phrasing, explicitness, and complexity.
- Should-not-trigger queries should be near-misses that share keywords but need a different skill.
- Include realistic noise: file paths, personal context, casual language, and typos.

Run each query at least three times and compute trigger rate:

- Should-trigger passes if rate > 0.5.
- Should-not-trigger passes if rate < 0.5.

### Train/Validation Split

Split queries about 60/40 to avoid overfitting. Use only train-set failures to drive edits. Use validation performance to select the best iteration.

### Trigger Optimization Loop

1. Evaluate current description on train and validation sets.
2. Diagnose train failures (too narrow, too broad, or ambiguous trigger language).
3. Revise using generalized fixes, not keyword patching.
4. Repeat until train performance plateaus (often around five iterations).
5. Select the iteration with the best validation pass rate.

## Evaluating Skill Output Quality

Source: agentskills.io/skill-creation/evaluating-skills

Use structured evals to improve output quality, not just triggering.

### Test Cases

Store test cases in `evals/evals.json` inside the skill directory:

```json
{
  "skill_name": "my-skill",
  "evals": [
    {
      "id": 1,
      "prompt": "Realistic user message...",
      "expected_output": "Human-readable description of success.",
      "files": ["evals/files/input.csv"],
      "assertions": [
        "The output includes X",
        "Y is correctly formatted",
        "Z count matches expected"
      ]
    }
  ]
}
```

Start with 2-3 cases. Vary phrasing, detail, and edge cases. Add assertions after the first run when success criteria are clearer.

### Grading

Grade each assertion as PASS or FAIL with concrete evidence:

```json
{
  "assertion_results": [
    {
      "text": "Both axes are labeled",
      "passed": false,
      "evidence": "Y-axis labeled but X-axis has no label"
    }
  ],
  "summary": { "passed": 3, "failed": 1, "total": 4, "pass_rate": 0.75 }
}
```

Use scripts for mechanical checks (valid JSON, file existence, row counts). Use LLM grading for semantic checks (for example, whether summaries include recommendations).

### Benchmarking

Run each test case with and without the skill (or old vs new version). Record `total_tokens` and `duration_ms`. Aggregate into `benchmark.json`:

```json
{
  "run_summary": {
    "with_skill": { "pass_rate": { "mean": 0.83 }, "tokens": { "mean": 3800 } },
    "without_skill": {
      "pass_rate": { "mean": 0.33 },
      "tokens": { "mean": 2100 }
    },
    "delta": { "pass_rate": 0.5, "tokens": 1700 }
  }
}
```

The delta shows what the skill costs (tokens and time) versus what it buys (quality and reliability).

### Output Iteration Loop

1. Give failed assertions, human feedback, and execution transcripts to an LLM with the current SKILL.md.
2. Apply improvements that generalize from failures while keeping instructions lean.
3. Rerun all test cases in a new `iteration-<N+1>/` directory.
4. Regrade and compare benchmark deltas. Repeat until improvement plateaus.
