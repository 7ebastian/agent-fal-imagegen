---
name: fal-imagegen
description: Use when generating images, videos, or audio via fal.ai API. Triggers on requests for AI image generation, text-to-video, image editing, upscaling, or any fal.ai model usage.
---

# fal.ai Image & Video Generation

Generate images, videos, and audio using fal.ai's 600+ model catalog.

This skill is written for **any coding agent with bash + file tools** — Claude Code (auto-loads via the SKILL.md frontmatter above), ChatGPT Codex, Gemini CLI, Cursor agent, and similar. Non-Claude agents don't parse the frontmatter; they just read this file as Markdown instructions when pointed at it.

**Companion skills (optional):** if you have your own brand / art-direction skill, read it before this one so creative direction is set. This skill handles the mechanics; a brand skill handles *what* to create.

## CRITICAL: User Approval Required

**Every generation costs money. NEVER submit a generation request without explicit user confirmation.**

Before generating, always present:
1. **Model recommendation** with rationale — but ask the user's preference (they are an art director with strong opinions on model choice)
2. **Prompt draft** — show the full prompt you'll send and invite edits
3. **Settings summary** — resolution, aspect ratio, number of images, estimated cost
4. **Save location** — confirm where files will be saved (see Output Location below)
5. **Explicit confirmation** — wait for a clear "go" / "yes" / "generate it" before calling the API

For batch generation (multiple images), present the full list of prompts and get approval for all before submitting any.

## Output Location

**Ask where to save at the start of each generation session.** Don't assume.

The user's context determines the right location:
- **Working in a project** → save into the project (e.g., `./assets/`, `./generated/`, or a descriptive subfolder)
- **Quick one-off generation** → save to `~/Downloads/fal-imagegen/`
- **Building a collection** → create a named subfolder (e.g., `~/Downloads/fal-imagegen/brand-concepts/` or `./assets/hero-images/`)

Present the proposed path and confirm before generating. If generating multiple images in a session, establish the output directory once at the start — don't re-ask for every image unless the context changes.

## File Naming

```
YYYYMMDD_project_descriptor_v001.ext
```

```
20260305_brand-hero_mountain-vista_v001.png     ← first attempt
20260305_brand-hero_mountain-vista_v002.png     ← iteration (same descriptor, bump version)
20260305_brand-hero_city-aerial_v001.png        ← different subject, same project
20260305_quick_cat-on-roof_v001.png             ← one-off (use "quick" as project)
20260305_social-ads_product-demo_v001.mp4       ← video
```

Lowercase, no spaces, underscores between elements, hyphens within. Versions always 3 digits. Propose filename in the confirmation step.

## Setup

Requires `FAL_KEY` in the shell environment. How you store it is up to you — the skill only cares that `$FAL_KEY` resolves to a valid key at runtime.

**For a new user**, walk them through the options in the README's *"Storing `FAL_KEY` — security tiers"* section. Default recommendation by OS:

- **macOS:** Tier 2 (Keychain) — `security add-generic-password -s fal.ai -a FAL_KEY -w '<key>' -U`, then `export FAL_KEY=$(security find-generic-password -s fal.ai -a FAL_KEY -w 2>/dev/null)` in `~/.zshrc`.
- **Linux with libsecret:** Tier 2 (libsecret) — `echo -n '<key>' | secret-tool store --label='fal.ai' service fal.ai account FAL_KEY`, then `export FAL_KEY=$(secret-tool lookup service fal.ai account FAL_KEY 2>/dev/null)` in `~/.zshrc` / `~/.bashrc`.
- **Any OS, quick start:** Tier 1 plain env var — `export FAL_KEY="..."` in the rc file. Less secure but zero setup. Flag the security trade-off honestly: plaintext on disk, inherited by every subshell.
- **Multi-project dev:** Tier 3 (direnv + per-project `.env` with strict `.gitignore`).
- **Team / enterprise:** Tier 4 (1Password CLI or similar vault).

Offer the better tier first; fall back to simpler tiers only if the user declines or the platform doesn't support it.

Optional: `XAI_API_KEY` for xAI/Grok Imagine — store the same way.

## Quick Start — Helper Scripts

### fal-generate.sh — Generate images/video
```bash
# Image generation
./fal-generate.sh fal-ai/nano-banana-2 \
  '{"prompt":"A sunset over mountains","resolution":"1K"}' ./output

# Image editing (requires public image_url)
./fal-generate.sh fal-ai/nano-banana-2/edit \
  '{"prompt":"Make it night time","image_url":"https://...","resolution":"1K"}' ./output

# Video generation
./fal-generate.sh fal-ai/kling-video/v3/pro/text-to-video \
  '{"prompt":"A timelapse of clouds","duration":"5"}' ./output
```

Handles: submit to queue, poll status, download files, embed metadata into PNGs, append to generation log.

### fal-upload.sh — Upload local files to get public URLs
```bash
# Upload a local file → returns public URL on stdout
./fal-upload.sh ./photo.jpg
# → https://v3b.fal.media/files/.../photo.jpg

# Use in scripts — capture the URL
URL=$(./fal-upload.sh ./photo.jpg)
```

Uses 2-step signed URL flow (initiate → PUT) to preserve file extensions. Required for any model that needs `image_url` or `image_urls` input from local files.

### Automatic metadata
- **PNG metadata**: prompt, model, parameters, seed, date embedded as tEXt chunks (like ComfyUI)
- **Generation log**: `_generation-log.md` created/appended in the output directory with every run

## Parallel Generation via Background Subagents

For batches of 3+ images, video jobs (slow), or any time you want the main chat to stay responsive, spawn each generation as a **background subagent** instead of running scripts inline.

**When to use:**
- Batch of images — spawn one agent per image, all in parallel
- Video generation — takes 60–180s, don't block the conversation
- Mixed fal.ai + xAI jobs running simultaneously

**Pattern — spawn in a single message (true parallelism):**

```
Agent tool call 1: run_in_background=true — handles image A
Agent tool call 2: run_in_background=true — handles image B
Agent tool call 3: run_in_background=true — handles image C
```

All three spawn simultaneously. Main chat stays available immediately.

**Subagent prompt template (fal.ai):**

```
Generate an image using fal.ai. Task:
1. Write this JSON to /tmp/<unique-name>.json using Python:
   { "prompt": "...", "aspect_ratio": "16:9", "resolution": "1K", "output_format": "png" }
2. Run: bash "$FAL_SKILL_DIR/fal-generate.sh" \
     "<model-id>" "$(cat /tmp/<unique-name>.json)" "<output-dir>" "<filename-base>"
   (where $FAL_SKILL_DIR is the absolute path to the folder where you unzipped this skill)
3. If the job fails with a parameter error, check the error message and retry with corrected params.
4. Wait for completion (up to 5 minutes).
5. Report back: success/failure, filename saved, any errors.
```

**Subagent prompt template (xAI / Grok — synchronous):**

```
Generate an image using the xAI Grok API. Task:
1. Write payload JSON to /tmp/<unique-name>.json using Python (handles special characters safely).
2. Run: curl -s https://api.x.ai/v1/images/generations \
     -H "Authorization: Bearer $XAI_API_KEY" \
     -H "Content-Type: application/json" \
     -d @/tmp/<unique-name>.json
3. Extract the image URL from the response (data[0].url).
4. Download it: curl -s -o "<output-path>/<filename>" "<url>"
5. Append a log entry to <output-dir>/_generation-log.md (create with "# Generation Log" header if missing).
6. Report back: success/failure, filename saved, URL, any errors.
```

**Rules:**
- Give each subagent a unique temp file path (e.g., `/tmp/nb2_job1.json`, `/tmp/nb2_job2.json`) to avoid collisions
- Upload shared reference images BEFORE spawning subagents — pass the resulting public URL in the prompt
- Subagents auto-notify when complete — do not poll or check on them manually

## Workflows

Multi-step pipelines are defined as natural language recipes in `workflows/`. Each file documents inputs, steps, API call shape, and tips.

Available workflows:
- **[virtual-try-on.md](workflows/virtual-try-on.md)** — Person photo + 2 garment photos → dressed result (FLUX Klein 9B + LoRA)

To run a workflow: read the workflow file, follow its steps, use `fal-upload.sh` for local files and `fal-generate.sh` for model calls.

## API Pattern

All models use the same queue pattern. Use `queue.fal.run` (NOT `fal.run`).

```
POST https://queue.fal.run/{model-id}     → submit (returns request_id)
GET  .../requests/{id}/status              → poll (IN_QUEUE/IN_PROGRESS/COMPLETED/FAILED)
GET  .../requests/{id}                     → fetch result
PUT  .../requests/{id}/cancel              → cancel job
```

Auth header: `Authorization: Key $FAL_KEY` (not Bearer).

## xAI / Grok Imagine API

Separate from fal.ai — uses xAI's own REST API directly (no queue polling needed).

**Key:** `XAI_API_KEY` in env (set in your shell config).

**Auth:** `Authorization: Bearer $XAI_API_KEY` (not `Key`)

### Endpoints

```
POST https://api.x.ai/v1/images/generations   → text-to-image
POST https://api.x.ai/v1/images/edits         → image editing / multi-image compositing
```

### Text-to-Image

```bash
curl https://api.x.ai/v1/images/generations \
  -H "Authorization: Bearer $XAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "grok-imagine-image",
    "prompt": "...",
    "n": 1,
    "aspect_ratio": "16:9",
    "resolution": "1k",
    "response_format": "url"
  }'
```

### Image Editing (single or multi-image reference)

```bash
curl https://api.x.ai/v1/images/edits \
  -H "Authorization: Bearer $XAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "grok-imagine-image",
    "prompt": "Make it night time",
    "image_url": "https://...",
    "n": 1
  }'
```

For up to 3 reference images (style transfer, compositing):
```json
{
  "model": "grok-imagine-image",
  "prompt": "...",
  "image_urls": ["https://...", "https://...", "https://..."]
}
```

### xAI Parameters

| Param | Values | Default |
|-------|--------|---------|
| `model` | `grok-imagine-image`, `grok-imagine-image-pro` | required |
| `prompt` | string | required |
| `n` | 1–10 | 1 |
| `aspect_ratio` | `1:1`, `16:9`, `9:16`, `4:3`, `3:4`, `3:2`, `2:3`, `2:1`, `1:2`, `19.5:9`, `9:19.5`, `20:9`, `9:20`, `auto` | `auto` |
| `resolution` | `1k`, `2k` | `1k` |
| `response_format` | `url` | `url` |
| `image_url` | public URL or base64 data URI | — (edit only) |
| `image_urls` | array of up to 3 URLs | — (edit only) |

**Pricing:** $0.02/image (`grok-imagine-image` standard) | $0.07/image (`grok-imagine-image-pro`). Same price whether via fal.ai or direct xAI API — no markup. fal.ai charges extra $0.002 per input image on edits.
**Note:** Response URLs are temporary — download immediately. Cost returned as `cost_in_usd_ticks` — divide by **10,000,000,000** (10B) to get USD. E.g. `cost_in_usd_ticks: 200000000` = **$0.02** (we previously divided by 1B and got $0.20 — that was wrong).
**Correct model name:** `grok-imagine-image` (NOT `grok-2-image` — that model doesn't exist on this account).

### Using Local Files as References

Two options — base64 is simpler (no upload needed):

**Upload to fal.ai for a public URL (required — base64 blocked by Cloudflare WAF)**
```bash
URL=$("$FAL_SKILL_DIR/fal-upload.sh" ./photo.jpg)
# Then use $URL as image_url in the xAI request
```
Note: base64 data URIs are documented as supported but Cloudflare blocks large JSON payloads (error 1010). Always use fal-upload.sh.

### Generation Log (Manual — xAI bypasses the script)

`fal-generate.sh` writes the log automatically **but does not include cost**. After every generation — fal.ai or xAI — you must manually append a `- **Cost:**` line to the last log entry. Look up the cost from the model table above.

When using the xAI API directly via curl, the entire log entry must be written manually. Append to `_generation-log.md` in the output directory:

```markdown
### 20260311_project_descriptor_v001.jpg
- **Model:** `grok-imagine-image`
- **Prompt:** `<full prompt>`
- **Settings:** `aspect_ratio=16:9, resolution=1k`
- **Cost:** $0.02
- **Date:** 2026-03-11
```

For fal.ai jobs (auto-logged by fal-generate.sh), append cost after the script completes:
```markdown
- **Cost:** $0.08
```

For video: multiply duration × per-second rate (e.g. 6s × $0.04/s = `$0.24`).
For unknown pricing (Wan, etc.): use `TBD (pricing not published)`.

Create the file with `# Generation Log` header if it doesn't exist yet.

---

## Model Selection

The script works with **any fal.ai model** — just pass the model ID.

**Read `references/model-catalog.md` when selecting a model or when the user asks about available models.** It contains tables for: Image Generation, Image Editing, Video Generation, Audio & Voice, Video Post-Production, and Utility & Tools with model IDs and pricing.

## Model-Specific Parameters

For detailed input schemas, query Context7:
```
Context7 library: /websites/fal_ai_models
Query: "<model-name> API input parameters"
```

### Common params (most image models)

| Param | Values | Default |
|-------|--------|---------|
| `prompt` | string (required) | — |
| `num_images` | 1-4 | 1 |
| `aspect_ratio` | auto, 21:9, 16:9, 3:2, 4:3, 5:4, 1:1, 4:5, 3:4, 2:3, 9:16 | auto |
| `resolution` | 0.5K, 1K, 2K, 4K | 1K |
| `output_format` | png, jpeg, webp | png |
| `seed` | integer | random |

Resolution pricing multiplier: 0.5K=0.75x, 1K=1x, 2K=1.5x, 4K=2x.

### Seedream 4.5 params (bytedance/seedream/v4.5)

| Param | Values | Default |
|-------|--------|---------|
| `prompt` | string (required) | — |
| `image_size` | square_hd, square, portrait_4_3, portrait_16_9, landscape_4_3, landscape_16_9, auto_2K, auto_4K, or `{"width":W,"height":H}` | auto_2K |
| `num_images` | integer | 1 |
| `seed` | integer | random |

Note: Seedream uses `image_size` (not `resolution` + `aspect_ratio`). Custom sizes: width/height between 1920-4096px.

### GPT-Image-2 params (openai/gpt-image-2 and /edit)

Best-in-class text rendering — use when the image needs legible text, signage, handwriting, or CJK characters. Does NOT use `resolution` or `aspect_ratio` — uses `image_size` + `quality`.

| Param | Values | Default | Notes |
|-------|--------|---------|-------|
| `prompt` | string (required) | — | Describe image (t2i) or edit (edit endpoint) |
| `image_size` | `square_hd` (1024×1024), `square` (512×512), `portrait_4_3` (768×1024), `portrait_16_9` (576×1024), `landscape_4_3` (1024×768), `landscape_16_9` (1024×576), `auto`, or `{"width":W,"height":H}` | `landscape_4_3` (t2i) / `auto` (edit) | Custom: both dims multiples of 16, 655360–8294400 total px, max side 4000px, max aspect 3:1 |
| `quality` | `low`, `medium`, `high` | `high` | **Major cost lever** — see pricing matrix below. Use `low` for cheap iteration passes |
| `num_images` | integer ≥ 1 | 1 | |
| `output_format` | `png`, `jpeg`, `webp` | `png` | |
| `sync_mode` | boolean | `false` | If true, returns data URIs inline (excluded from history) |
| `openai_api_key` | string | — | BYOK — route billing through your own OpenAI account |
| `image_urls` | array of URLs or data URIs | — | **Edit endpoint only, required.** One or more reference images. Upload local files via `fal-upload.sh` first |
| `mask_image_url` | URL or data URI | null | **Edit endpoint only, optional.** White = editable region, black = preserve. Must match input image dimensions exactly |

**Pricing by resolution × quality (per image):**

| Resolution | Low | Medium | High (default) |
|---|---|---|---|
| 1024×768 | $0.01 | $0.04 | $0.15 |
| 1024×1024 | $0.01 | $0.06 | $0.22 |
| 1024×1536 | $0.01 | $0.05 | $0.17 |
| 1920×1080 | $0.01 | $0.04 | $0.16 |
| 2560×1440 | $0.01 | $0.06 | $0.23 |
| 3840×2160 | $0.02 | $0.11 | $0.41 |

Edit endpoint shares the same price matrix. Longer prompts and more complex requests (world knowledge, reasoning) push cost toward the high end of each tier.

**Gotchas:**
- Edit takes `image_urls` (array) — NOT the singular `image_url` that some fal models use
- Default is `quality=high` — explicitly pass `"quality":"low"` for $0.01 test renders
- Mask must be exact same dimensions as the input image, or it'll fail silently/return weird results
- Streaming (`fal.stream()`) is supported on the edit endpoint but not text-to-image

### Seedance 2.0 params (bytedance/seedance-2.0 — all 6 variants)

ByteDance's flagship video model (released 2026-04). 720p native with synchronized audio, 6 aspect ratios, 4–15s clips. Six variants share a common parameter base with variant-specific inputs.

**Common params (all 6 variants):**

| Param | Values | Default | Notes |
|-------|--------|---------|-------|
| `prompt` | string (required) | — | Scene description. **Put spoken dialogue in double quotes** for native audio |
| `resolution` | `480p`, `720p` | `720p` | 720p is default; 480p cheaper |
| `duration` | `"auto"` or `"4"`–`"15"` (string in seconds) | `"auto"` (≈10s) | |
| `aspect_ratio` | `auto`, `21:9`, `16:9`, `4:3`, `1:1`, `3:4`, `9:16` | `auto` | |
| `generate_audio` | boolean | `true` | Native sync audio generation (not post-production) |
| `seed` | integer | random | Reproducibility |
| `end_user_id` | string | — | **Required for B2B access** — unique end-customer ID |

**Image-to-video variants** (`/image-to-video` and `/fast/image-to-video`) add:

| Param | Values | Required | Notes |
|-------|--------|----------|-------|
| `image_url` | URL (jpg, jpeg, png, webp, gif, avif) | **Yes** | Start frame |
| `end_image_url` | URL (same formats) | No | Optional final frame — enables interpolated animation with motion prompt |

**Reference-to-video variants** (`/reference-to-video` and `/fast/reference-to-video`) add:

| Param | Values | Required | Notes |
|-------|--------|----------|-------|
| `image_urls` | array of URLs (up to 9) | No | Reference images — labeled `[Image1]`, `[Image2]`... in the prompt |
| `video_urls` | array of URLs (up to 3) | No | Reference video clips — labeled `[Video1]`... **Triggers 40% price discount** |
| `audio_urls` | array of URLs (up to 3) | No | Reference audio tracks — labeled `[Audio1]`... |

Note: reference-to-video is NOT image-to-video with multiple images. It's a multimodal compositing endpoint — reference media inform style/motion/audio, but you still describe the output in the prompt. Use it for brand-consistent characters, style transfer across clips, or audio-driven generation.

**Pricing (per second of 720p output):**

| Variant | Base rate | With video refs | Token rate |
|---|---|---|---|
| Pro text-to-video | $0.3034/s | — | $0.014/1k tok |
| Pro image-to-video | $0.3024/s | — | $0.014/1k tok |
| Pro reference-to-video | $0.3024/s | **$0.1814/s** (−40%) | $0.014/1k tok |
| Fast text-to-video | $0.2419/s | — | $0.0112/1k tok |
| Fast image-to-video | $0.2419/s | — | $0.0112/1k tok |
| Fast reference-to-video | $0.2419/s | **$0.14515/s** (−40%) | $0.0112/1k tok |

Fast tier ≈ 20% cheaper than Pro at equivalent settings. Token formula: `(height × width × duration × 24) / 1024` (for ref-to-v, `duration` = input_duration + output_duration).

**720p pixel dimensions by aspect ratio:**
`21:9` 1470×630 · `16:9` 1280×720 · `4:3` 1112×834 · `1:1` 960×960 · `3:4` 834×1112 · `9:16` 720×1280

**480p pixel dimensions by aspect ratio:**
`21:9` 992×432 · `16:9` 864×496 · `4:3` 752×560 · `1:1` 640×640 · `3:4` 560×752 · `9:16` 496×864

**Cost examples (Pro, 720p, 10s):**
- text-to-video: ≈ $3.03
- image-to-video: ≈ $3.02
- reference-to-video with only image refs: ≈ $3.02
- reference-to-video with a video reference: ≈ $1.81

**Gotchas:**
- Duration is a **string** (`"10"`) not an integer on the text-to-video variant — other variants accept int. Pass as string to be safe.
- `image_url` (i2v) vs `image_urls` (ref-to-v) — different keys, easy to mix up.
- For dialogue in videos, wrap spoken lines in double quotes inside the prompt, e.g. `A woman says "welcome back" while walking toward camera`.
- Video reference discount only applies when `video_urls` is populated. Pure image+audio refs stay at full price.
- Default `generate_audio=true` on most variants — set false for silent clips if you plan to composite your own audio.

### Grok Imagine Video params (all 5 fal.ai video variants)

xAI's video family on fal.ai. All variants share a common base; each adds 1–2 unique params for its input mode.

**Common params (all 5 variants):**

| Param | Values | Default | Notes |
|-------|--------|---------|-------|
| `prompt` | string (required) | — | Scene/motion description |
| `resolution` | `480p`, `720p` | `720p` | Cost scales linearly with resolution |
| `duration` | numeric seconds | — | Range undocumented on fal.ai pages; 6s is the canonical example |
| `aspect_ratio` | `16:9` (documented) | `16:9` | Other ratios may work — not confirmed on fal.ai |

**Per-variant unique params:**

| Variant | Endpoint | Unique input | Notes |
|---|---|---|---|
| Text-to-video | `xai/grok-imagine-video/text-to-video` | — | Prompt only |
| Image-to-video | `xai/grok-imagine-video/image-to-video` | `image_url` (required) | Single start-frame image |
| Reference-to-video | `xai/grok-imagine-video/reference-to-video` | `image_urls` array (required) | Multiple reference images as visual anchors — NOT start frame |
| Edit-video | `xai/grok-imagine-video/edit-video` | `video_url` (required) | Re-renders/edits input video following prompt |
| Extend-video | `xai/grok-imagine-video/extend-video` | `video_url` (required, mp4/mov/webm/m4v/gif) | Generates continuation from the end of the source video |

**Pricing (per second of output):**

| Variant | 480p | 720p | Input fees |
|---|---|---|---|
| text-to-video | $0.05/s | $0.07/s | — |
| image-to-video | $0.05/s | $0.07/s | +$0.002 flat per image input |
| reference-to-video | $0.05/s | $0.07/s | +$0.002 flat per image input |
| edit-video | $0.05/s | $0.07/s | +$0.01/s of source video → effective $0.06/$0.08 |
| extend-video | $0.05/s | $0.07/s | +$0.01/s of source video |

**Output:** 24fps MP4. Output schema includes `url`, `content_type`, `file_name`, `file_size`, `width`, `height`, `fps`, `duration`, `num_frames`.

**Gotchas:**
- Reference-to-video ≠ image-to-video. Ref-to-v uses images as **style/subject anchors**, not as the first frame. For a specific start frame, use image-to-video.
- Edit-video and extend-video both charge $0.01/s for the source video on top of the output rate — factor that into cost estimates.
- `grok-imagine-image-pro` (the $0.07/image photorealistic tier) is **only** available via xAI's direct API, not via fal.ai. Use the xAI section above for that endpoint.
- Max source-video duration for edit/extend is not documented on fal.ai — if a long input fails, split it.

Edit models (other than gpt-image-2/edit) also require `image_url` (must be publicly accessible URL, not local path).
Image-to-video models require `image_url` plus `prompt`.

## Staying Fresh (self-maintenance)

The fal.ai + xAI landscape moves weekly. This skill has two built-in mechanisms to compound knowledge instead of going stale:

**1. Model catalog refresh.** The top of `references/model-catalog.md` has a `Last updated:` date. Before recommending a model, check that date. If it's **older than 30 days**, or if the user mentions a model not in the catalog, do this before proceeding:

1. WebFetch `https://fal.ai/models` and `https://docs.fal.ai/models`
2. Diff what you find against `references/model-catalog.md`
3. Propose additions/removals/price updates to the user as a unified patch
4. Apply the accepted changes + update the `Last updated:` date

Never silently rewrite the catalog. Always show the proposed diff first.

**2. Learnings log.** `references/learnings.md` is an append-only compound file that captures real session outcomes — model gotchas, prompt patterns that worked, failed generations and why. Two obligations:

- **Before drafting a prompt**, read `references/learnings.md` end-to-end. Apply any applicable lessons.
- **After a surprising result** — a generation that failed, a model that underperformed, a prompt pattern that worked unexpectedly well — append a dated one-liner under the right section. Keep each entry to ~15 words max.

Over time the file becomes the skill's accumulated field intelligence. Do not prune aggressively — even "old" lessons often stay relevant. Archive obvious rot (e.g., models that no longer exist) during the catalog refresh pass.

## Prompt Engineering

### Step 1: Read the learnings log

Read `references/learnings.md`. If any entry touches the model, prompt style, or subject you're about to work with, apply the lesson.

### Step 2: Load model-specific guidance

Before drafting prompts, fetch the prompt guide for the chosen model:

```
WebFetch: https://fal.ai/learn/devs/<model-slug>-prompt-guide
```

Key slugs: `nano-banana-2-api-developer-guide`, `flux-2-prompt-guide`, `veo3-prompt-guide-master-google-video-generation`, `kling-2-6-pro-prompt-guide`, `how-to-write-prompts-sora-2`

### Step 3: Read user preferences

Read `references/art-direction.md` inside this skill. Treat it as a living file — update it when the user expresses new preferences during a session. The template version shipped with this zip is minimal on purpose; fill it with your own palette, composition rules, lexicon, and model preferences as you go.

### Step 4: Draft and present prompts

The user is an expert prompt engineer and art director. They may provide direction via:
- Natural language description of what they want
- Reference images (uploaded or linked) to match a style
- A mix of styles from multiple references
- Direct prompt text to use or refine

**Always show the exact prompt for every image/video generated.** The user needs to see, review, and manually edit prompts. Never summarize, paraphrase, or hide the prompt — present it in a copyable code block.

When presenting for approval, format as:

```
Model: fal-ai/nano-banana-2
Prompt: "<the full exact prompt>"
Settings: 1K, 16:9, png
File: 20260305_project_descriptor_v001.png
Save to: ~/Downloads/fal-imagegen/
Est. cost: $0.08
```

Draft prompt → show in full → user reviews/edits → confirm → generate.

## Local Background Removal

Remove backgrounds locally using BiRefNet via `rembg`. Free, no API calls, ~15s per image on M2 Max.

```bash
source ./.venv-rembg/bin/activate
python3 ./remove-bg.py <input-image> <output-png>
```

Models (set in script): `birefnet-general` (default, all subjects) or `birefnet-portrait` (optimized for people). First run downloads ~970MB model weights to `~/.u2net/`.

Venv: `./.venv-rembg/` (rembg[cpu] + pillow + onnxruntime). Not included in the repo — recreate it with:

```bash
python3 -m venv ./.venv-rembg
source ./.venv-rembg/bin/activate
pip install 'rembg[cpu]' pillow onnxruntime
```

## Common Mistakes

- Using `fal.run` instead of `queue.fal.run` — sync endpoint rejects this key type
- Forgetting `Authorization: Key` prefix (not `Bearer`)
- Not polling — queue jobs take time, especially video (30-120s)
- Passing local file path as `image_url` — must be a public URL
- **Generating without user approval** — always confirm before spending money
- **xAI:** Using `grok-2-image` — correct model is `grok-imagine-image`
- **xAI:** Using `Authorization: Key` — xAI requires `Bearer`, unlike fal.ai
- **xAI:** Trying to poll a queue — xAI is synchronous, response comes directly
- **xAI:** Passing local file paths as `image_url` — must be a public URL or base64 data URI
