# Art Direction Preferences

Your living art-direction file. The skill reads this before every generation session to pick up the preferences you've built up — models, palette, composition, visual vocabulary, the kinds of prompts that reliably produce work you're happy with.

This file **ships empty on purpose**. The sections below are scaffolding. Fill them with your own taste, your own brand, your own conventions. A first pass takes 10 minutes; a mature version compounds over months of use. The emptier it starts, the more honestly your own judgment shapes the output.

> Delete this intro block once you've started filling the file in. The scaffold is for the first few sessions; after that, it's your document.

---

## 1. Pre-flight direction-setting

What do you want your agent to nail down *before* it writes a prompt? Common categories:

- **Subject** — what single idea does this image need to communicate?
- **Feeling** — name the emotion before the content.
- **Tradition / visual lineage** — what school or body of work does this image belong to?
- **Constraint** — what are you deliberately limiting (palette, element count, composition)?

Replace the prompts above with your own checklist, or delete this section if you don't use one.

---

## 2. Preferred models

Which fal.ai / xAI models do you reach for, and for what? Fill in as you settle on go-tos:

- **Photorealistic hero work:** _your choice_
- **Typography-heavy:** _your choice_
- **Design / illustration:** _your choice_
- **Fast iteration / draft:** _your choice_
- **Video (high fidelity):** _your choice_
- **Video (fast):** _your choice_

See `model-catalog.md` for what's currently on fal.ai and xAI.

---

## 3. Default composition rules

Your defaults for aspect ratio, subject placement, negative space, camera traditions. Examples of the *kind* of thing that belongs here:

- Default aspect ratio for hero / social / video
- Where the subject sits in the frame
- What the empty space is doing (flat colour? gradient? patterned?)
- Camera angles you return to (top-down, oblique, corner intrusion, etc.)

Fill as you develop defaults.

---

## 4. Colour palette

Name the colours you return to. Exact hex codes generate more reliably than descriptive names.

| Name | Background | Text / Caption | Notes |
|------|-----------|---------------|-------|
|      |           |               |       |

---

## 5. Visual metaphor mechanisms

The moves you use to translate a concept into an image. Keep your own definitions here — pick your own names, your own examples.

| Mechanism | How it works | Example |
|-----------|-------------|---------|
|           |             |         |

---

## 6. Visual lineages / traditions you reference

When you want a specific look, which schools or artists do you cite by name in prompts? A one-liner per lineage noting when it's the right tool.

| Lineage / reference | When to reach for it |
|--------------------|---------------------|
|                    |                     |

---

## 7. Image lexicon (your recurring visual vocabulary)

Subjects and compositions that reliably communicate specific concepts for you. Build this over time — by session six, you'll have repeats.

| Subject / composition | Concept it carries |
|----------------------|-------------------|
|                      |                   |

---

## 8. Mood → palette / composition / texture

If you work across multiple moods, keep a table so the agent doesn't re-derive it every time.

| Mood | Palette | Composition | Texture |
|------|---------|-------------|---------|
|      |         |             |         |

---

## 9. Never do this

Your refusals. Clichés you won't ship, defaults you want the agent to avoid, phrases you never want in a prompt.

- _your first refusal here_
- _your next refusal here_

---

## 10. Quality check (run before confirming a prompt)

Write your own short checklist of questions. Three to five is the right number. Examples of the *kind* of question that works here:

- Does the subject carry more than one meaning?
- Could the same image illustrate ten different topics? (If yes, start over.)
- Does it survive in black and white?
- Would you be proud to print it?

Replace with your own.

---

## 11. Prompt construction rules

Structural rules for every prompt — things that should be in or out regardless of subject. Examples of the *kind* of rule that belongs here:

- Whether text is ever baked into images (or always overlaid in HTML/CSS)
- Whether hex codes are required for colour references
- Default rendering style (photorealistic / illustrated / collage / etc.)
- Required negative-prompt language (what to always exclude)

Fill as you discover them.

---

*Update this file whenever you find yourself re-explaining a preference to the agent. Every entry here is a preference you won't have to re-specify next session.*
