# Art Direction Preferences

This is your living file. The skill reads it before every generation session to pick up your personal or brand-specific preferences — models you like, composition rules you follow, a palette you reach for, metaphors you trust. Fill it in as you go. A good first pass takes 10 minutes; a great version compounds over months.

> **Note:** this template ships empty by design. Replace each section with your own.

---

## Preferred Models

Which fal.ai / xAI models do you reach for, and why? Examples of the kind of note that's useful here:

- **Go-to for photorealistic hero images:** `fal-ai/nano-banana-2` — best realism out of the box
- **Go-to for typography-heavy work:** `openai/gpt-image-2` — best Latin + CJK text rendering
- **Go-to for design / illustration:** `fal-ai/recraft/v4/pro/text-to-image`
- **Go-to for fast iterations:** `fal-ai/flux/schnell` or `fal-ai/z-image/turbo`
- **Go-to for video:** `fal-ai/wan/v2.2-a14b/image-to-video` (high fidelity) or `fal-ai/ltx-2/image-to-video/fast` (speed)

---

## Composition Rules

How do you want images framed by default?

- Aspect ratio: e.g. 16:9 for hero work, 1:1 for social, 9:16 for vertical video
- Subject placement: e.g. right-half with left empty for text overlay
- Empty-space rules: e.g. one flat color, never gradients or patterns
- Camera traditions: e.g. 90° top-down for flat lay, 30–45° oblique for isometric

---

## Color Palette

Name the colors you return to. Exact hex codes generate more reliably than descriptive names. A table works well:

| Name | Background | Text/Caption |
|------|-----------|-------------|
| _e.g. Your Brand Dark_ | `#05060B` | `#FFFFFF` |
| _e.g. Your Brand Warm_ | `#C89176` | `#05060B` |

---

## Image Lexicon (metaphors that work for you)

Over time, certain subjects reliably communicate the concepts you care about. Keep a running list so you (and the agent) don't re-discover them every session.

| Subject | Concept |
|---------|---------|
| _e.g. Toy soldiers in triangular formation_ | _Coordinated agents, orchestration_ |
| _e.g. Lobster claw intruding at corner_ | _Power partially revealed_ |

---

## Visual Metaphor Mechanisms

Pick one per concept when drafting prompts:

- **Substitution** — Replace one element with another that shares a quality. The absent thing is felt.
- **Fusion** — Merge two objects into a single hybrid. Both meanings coexist.
- **Juxtaposition** — Unrelated things placed together. Proximity creates meaning.
- **Tonal Dissonance** — Bright warm palette for dark topics. Mismatch > match.
- **Impossible Physicality** — Photorealistic objects that cannot exist but feel inevitable.
- **Material Contrast** — Soft/organic + mechanical/violent. Tension carries emotion.
- **Scale Disruption** — Miniaturise something powerful beside a known-scale reference.
- **Remove the Person** — Empty chair > portrait. Shoes > siblings. Let objects carry human weight.

---

## Never Use

What are the clichés you refuse to ship? Keep them here so the agent never drafts them:

- _e.g. robots, brains, lightbulbs, gears, puzzle pieces, handshakes, stock-photo teams_

---

## The Test (run before generating)

Questions to ask yourself before confirming a prompt:

1. Does the subject carry a double meaning?
2. Would you be proud to hang this in an office?
3. Is the background in tension with the content?
4. Can you name the absent thing?
5. Does it work without a caption?

---

## Critical Prompt Rules

- **No text baked into images** — if you use HTML/CSS overlays for captions, every prompt should end with: *"No text, no labels, no captions, no typographic elements of any kind."*
- **Never describe data meaning in prompts** — don't write *"junior roles declined 13%"*. Describe the physical objects; the model otherwise interprets conceptual language as text to render.
- **Specify exact hex codes** — `"seamless flat dark olive-green surface (#3D491D)"` hits the right colour reliably.
- **Specify dimensions for miniatures** — `"each approximately 15mm tall"` gives the model a concrete scale reference.
- **Rendering default:** photorealistic. Fine surface texture, authentic wear and patina. No illustration, no low-poly, no CGI-toy look (unless that's the brief).

---

*Update this file whenever you find yourself re-explaining a preference to the agent. Every entry here is a preference you won't have to re-specify next session.*
