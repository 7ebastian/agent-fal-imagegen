# claude-fal-ai-skill

A Claude Code skill that wires your agent to **fal.ai** (600+ image, video, and audio models) plus direct **xAI Grok Imagine** access and local background removal.

In Claude Code, you can then say things like:

- *"Generate a photorealistic image of a dog wearing sunglasses on a Hawaiian beach. 16:9. Use Nano Banana 2."*
- *"Take this headshot and generate three variations at sunset, in comic style, and as a line drawing."*
- *"Generate a 6-second video of the dog walking along the beach. Use Seedance 2."*
- *"Remove the background from this image."*

Claude handles the API mechanics — queue submission, polling, downloads, PNG metadata, generation logs — and asks you to confirm every generation before it spends money.

---

## Installation

### Easy mode (paste this into Claude Code)

Open Claude Code and paste this. Claude does the rest.

> Install claude-fal-ai-skill: run `git clone --single-branch --depth 1 https://github.com/7ebastian/claude-fal-ai-skill.git ~/.claude/skills/fal-ai`. Then help me set the `FAL_KEY` environment variable by opening `~/.zshrc` (or `~/.bashrc`), adding `export FAL_KEY="your-key-from-fal.ai-dashboard"`, and reminding me to restart my terminal or `source` the file. Ask whether I also want to set `XAI_API_KEY` (optional — enables xAI Grok Imagine models). Then confirm the skill installed correctly by listing `~/.claude/skills/fal-ai/SKILL.md`, and finally ask if I want to add a short "fal-ai" section to this project's `CLAUDE.md` so teammates know about the skill.

That's it. Claude clones the repo, helps you configure your API key, verifies the install, and optionally documents it for your teammates.

### Too-scared-to-paste-something-into-a-terminal mode (paste this into ChatGPT first)

If you've never used an API key or a terminal, paste this into ChatGPT (or Claude.ai) first:

> I want to install a Claude Code skill called **claude-fal-ai-skill** that lets me generate images and videos by talking to my coding assistant. Walk me through it like I've never used a terminal before. The GitHub URL is `https://github.com/7ebastian/claude-fal-ai-skill`. I also need to sign up at fal.ai, load $10 of credits, generate an API key in the fal.ai dashboard, and save that key as an environment variable on my Mac/Windows machine. Please give me the exact steps, one at a time, and wait for me to confirm before moving to the next.

Then paste the easy-mode instruction above into Claude Code once ChatGPT has you set up.

---

## Manual install (if you prefer the old-fashioned way)

1. **Clone the repo** to `~/.claude/skills/fal-ai`:
   ```bash
   git clone --single-branch --depth 1 https://github.com/7ebastian/claude-fal-ai-skill.git ~/.claude/skills/fal-ai
   ```

2. **Sign up at [fal.ai](https://fal.ai)** and load $10 of credits (that's 50–100 images or 15–20 short videos). Generate an API key in the dashboard.

3. **Export the key** in your shell config (`~/.zshrc` or `~/.bashrc`):
   ```bash
   export FAL_KEY="your-key-here"
   ```
   Then restart your terminal or `source ~/.zshrc`.

4. **Optional — xAI / Grok Imagine.** If you want the xAI models (good for charts and photorealism), get a key from [console.x.ai](https://console.x.ai) and add:
   ```bash
   export XAI_API_KEY="your-xai-key-here"
   ```

5. **Optional — local background removal.** If you want to remove backgrounds locally (free, no API calls), create a Python venv inside the skill directory:
   ```bash
   cd ~/.claude/skills/fal-ai
   python3 -m venv ./.venv-rembg
   source ./.venv-rembg/bin/activate
   pip install 'rembg[cpu]' pillow onnxruntime
   ```

6. **First test** — in Claude Code, say:
   > Generate a photorealistic image of a lobster sitting on a wooden pier at sunset. Use Nano Banana 2. Save to `~/Downloads/fal-ai/`.

   Claude will propose the prompt, show estimated cost, and wait for your confirmation.

---

## What's in this repo

```
SKILL.md                        ← the skill itself; Claude reads this first
fal-generate.sh                 ← image/video generation helper (curl + queue polling)
fal-upload.sh                   ← upload local files → public fal URLs
remove-bg.py                    ← local background removal (needs the venv)
references/
  art-direction.md              ← your living preferences file (edit as you go)
  model-catalog.md              ← popular models + pricing (auto-refreshable)
  learnings.md                  ← compound log of model gotchas + prompt patterns
workflows/
  virtual-try-on.md             ← example multi-step recipe
README.md                       ← this file
LICENSE                         ← Apache 2.0
```

---

## Self-maintenance (how the skill stays fresh)

The fal.ai + xAI model landscape moves weekly. This skill has two built-in mechanisms to compound knowledge instead of going stale:

**1. Model catalog refresh.** `references/model-catalog.md` carries a `Last updated:` date. When Claude reads the skill, it checks that date — if it's older than 30 days, or if you mention a model not in the catalog, it'll WebFetch fal.ai's model pages, diff against the file, and propose updates for your review. No silent rewrites.

**2. Learnings log.** `references/learnings.md` is an append-only compound file. Every time Claude hits a surprising result — a prompt pattern that worked, a model gotcha, a cost surprise — it appends a one-liner. Next session it reads the log first and applies the lesson. Over months it becomes personalised field intelligence that no public doc captures.

Both mechanisms are described in detail in `SKILL.md` under "Staying Fresh."

---

## Tailoring it for your brand

`references/art-direction.md` ships empty on purpose. Every time you find yourself re-explaining a preference to Claude ("always use 16:9", "my brand color is `#3D491D`", "camera angles at 35° above horizontal"), add it to that file. The skill reads it before every session, so preferences compound instead of being re-specified each time.

---

## Cost expectations

Rough math for what $10 of credits buys:

| Model | Cost | Units |
|---|---|---|
| Nano Banana 2 | ~$0.08/image | ~125 images |
| Grok Imagine (standard) | ~$0.02/image | ~500 images |
| Z-Image Turbo | ~$0.005/MP | very many |
| Kling video (pro) | ~$0.10–$0.24 per 5s clip | 40–100 short videos |
| Seedance 2 video | varies | see `references/model-catalog.md` |

Every generation appends an entry to `_generation-log.md` in the output directory, so you can audit spend.

---

## Contributing

Pull requests welcome. The two most useful places to contribute:

- **Model catalog updates** — fal.ai launches new models weekly. If you spot a missing or outdated entry in `references/model-catalog.md`, open a PR.
- **Learnings** — if you find a model gotcha, prompt pattern, or failure mode that repeats, submit it to `references/learnings.md`. Short entries only (under 15 words). Keep the date.

Issues welcome for anything: API changes, broken auth, pricing surprises, script bugs.

---

## License

Apache 2.0. See `LICENSE`.

---

## Credit

Originally built for the [Haavn' Fun](https://haavn.ai/fun) workshop on generative imagery and video. The Haavn-specific art-direction layer has been stripped for public release.
