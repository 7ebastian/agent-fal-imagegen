# Learnings Log

Append-only compound file. Every entry is a short lesson from a real session — a model gotcha, a prompt pattern that worked, a failure mode worth remembering. The skill reads this file before drafting prompts so lessons compound instead of getting re-discovered every session.

**Format:** one bullet per entry. Start with the date (`YYYY-MM-DD`). Under 15 words. State the lesson, not the story.

Examples (delete after your first real entry):

```
- 2026-04-23 · Nano Banana 2 adds a 6th person when asked for "exactly 5" — constraint doesn't stick.
- 2026-04-23 · fal.ai/hidream/v1/fast fails on prompts over ~400 chars; truncate or switch model.
- 2026-04-23 · Grok Imagine Pro reliably nails data-chart geometry where Nano Banana drifts off-axis.
```

---

## Model gotchas

_What a model silently does wrong, what it refuses, where it lies about its own capabilities._

(empty — add as you discover)

---

## Prompt patterns that worked

_Structural patterns, phrasings, or ordering that reliably produced the result you wanted._

(empty — add as you discover)

---

## Prompt patterns that failed

_What sounds like it should work but doesn't, and the model-specific reason if you know it._

(empty — add as you discover)

---

## Cost surprises

_Generations that billed more than expected. Resolution-multiplier edge cases. Hidden per-second rates on edit/extend endpoints._

(empty — add as you discover)

---

## Integration notes

_Shell, Claude Code, subagent, or tooling lessons — not about the models themselves._

(empty — add as you discover)

---

*Prune cautiously. Archive only entries tied to models that no longer exist on fal.ai. Lessons about prompt structure and model families usually stay relevant across specific model versions.*
