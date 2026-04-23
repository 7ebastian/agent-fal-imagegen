# agent-fal-imagegen

A **coding-agent + CLI skill** that wires your agent to **fal.ai** (600+ image, video, and audio models) plus direct **xAI Grok Imagine** access and local background removal.

Works with any coding agent that can run bash and read local files:

- **[Claude Code](https://claude.com/claude-code)** — the native target. Auto-loads via `SKILL.md` frontmatter.
- **[ChatGPT Codex](https://github.com/openai/codex)** — works; point it at `SKILL.md` when starting a session.
- **[Gemini CLI](https://github.com/google-gemini/gemini-cli)** — works; same pattern.
- **[Cursor](https://cursor.com) agent / [Windsurf](https://windsurf.com) / etc.** — works anywhere a coding agent can run a shell command and read a Markdown file.

In any of these, you can then say things like:

- *"Generate a photorealistic image of a dog wearing sunglasses on a Hawaiian beach. 16:9. Use Nano Banana 2."*
- *"Take this headshot and generate three variations at sunset, in comic style, and as a line drawing."*
- *"Generate a 6-second video of the dog walking along the beach. Use Seedance 2."*
- *"Remove the background from this image."*

The agent handles the API mechanics — queue submission, polling, downloads, PNG metadata, generation logs — and asks you to confirm every generation before it spends money.

---

## Installation

### Easy mode — Claude Code (paste this into a fresh session)

Open Claude Code and paste this. Claude does the rest.

> Install agent-fal-imagegen: run `git clone --single-branch --depth 1 https://github.com/7ebastian/agent-fal-imagegen.git ~/.claude/skills/fal-imagegen`. Then help me set the `FAL_KEY` environment variable by opening `~/.zshrc` (or `~/.bashrc`), adding `export FAL_KEY="your-key-from-fal.ai-dashboard"`, and reminding me to restart my terminal or `source` the file. Ask whether I also want to set `XAI_API_KEY` (optional — enables xAI Grok Imagine models). Then confirm the skill installed correctly by listing `~/.claude/skills/fal-imagegen/SKILL.md`, and finally ask if I want to add a short "fal-imagegen" section to this project's `CLAUDE.md` so teammates know about the skill.

Claude clones the repo, helps you configure your API key, verifies the install, and optionally documents it for your teammates.

### Easy mode — ChatGPT Codex

In a Codex session, paste this:

> Install agent-fal-imagegen: run `git clone --single-branch --depth 1 https://github.com/7ebastian/agent-fal-imagegen.git ~/.codex/skills/fal-imagegen`. Then help me add `export FAL_KEY="..."` to my shell config using my fal.ai dashboard key. Optionally set `XAI_API_KEY` for Grok Imagine. Then read `~/.codex/skills/fal-imagegen/SKILL.md` and follow its instructions whenever I ask you to generate imagery, video, or audio in this session. Finally, ask if I want to add a "fal-imagegen" section to this project's `AGENTS.md` (or equivalent) so teammates know about the skill.

### Easy mode — Gemini CLI

In a Gemini CLI session:

> Install agent-fal-imagegen: run `git clone --single-branch --depth 1 https://github.com/7ebastian/agent-fal-imagegen.git ~/.gemini/skills/fal-imagegen`. Help me add `export FAL_KEY="..."` to my shell config. Optionally set `XAI_API_KEY`. Then read `~/.gemini/skills/fal-imagegen/SKILL.md` and follow its instructions when I ask you to generate images, videos, or audio. Finally ask if I want to add a "fal-imagegen" section to `GEMINI.md` (or the project's equivalent) for teammate visibility.

### Too-scared-to-paste-something-into-a-terminal mode (get ChatGPT to hand-hold you first)

If you've never used an API key or a terminal, paste this into ChatGPT (or Claude.ai web) first:

> I want to install a coding-agent skill called **agent-fal-imagegen** that lets me generate images and videos by talking to my coding assistant (Claude Code, ChatGPT Codex, or Gemini CLI). Walk me through it like I've never used a terminal before. The GitHub URL is `https://github.com/7ebastian/agent-fal-imagegen`. I also need to sign up at fal.ai, load $10 of credits, generate an API key in the fal.ai dashboard, and save that key as an environment variable on my Mac/Windows machine. Please give me the exact steps, one at a time, and wait for me to confirm before moving to the next.

Then paste the appropriate easy-mode block above into your agent once ChatGPT has you set up.

---

## Manual install

1. **Clone the repo** to a location your agent can find. Suggested defaults:
   - Claude Code: `~/.claude/skills/fal-imagegen`
   - ChatGPT Codex: `~/.codex/skills/fal-imagegen`
   - Gemini CLI: `~/.gemini/skills/fal-imagegen`
   - Anywhere else: pick a stable path; you'll tell the agent about it.

   ```bash
   git clone --single-branch --depth 1 https://github.com/7ebastian/agent-fal-imagegen.git ~/.claude/skills/fal-imagegen
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

5. **Optional — local background removal.** Create a Python venv inside the skill directory:
   ```bash
   cd ~/.claude/skills/fal-imagegen
   python3 -m venv ./.venv-rembg
   source ./.venv-rembg/bin/activate
   pip install 'rembg[cpu]' pillow onnxruntime
   ```

6. **First test** — in your agent, say:
   > Generate a photorealistic image of a lobster sitting on a wooden pier at sunset. Use Nano Banana 2. Save to `~/Downloads/fal-imagegen/`.

   The agent will propose the prompt, show estimated cost, and wait for your confirmation before it spends money.

---

## How agents actually load this

| Agent | Auto-loads? | How to point it at this skill |
|---|---|---|
| **Claude Code** | Yes | Drop the folder in `~/.claude/skills/`. The YAML frontmatter in `SKILL.md` handles trigger-detection. |
| **ChatGPT Codex** | No | Tell it: *"Read `<path>/SKILL.md` and follow those instructions for any image/video/audio generation request this session."* |
| **Gemini CLI** | Partial | Same as Codex. `GEMINI.md` in the project root can mention the skill's path so it's loaded each session. |
| **Cursor / Windsurf / other** | No | Same as Codex. If your agent has a persistent system-prompt slot, paste a pointer to `SKILL.md` there. |

Non-Claude agents ignore the frontmatter (it's harmless Markdown to them). They just follow the instructions in the body of `SKILL.md` when pointed at it.

---

## What's in this repo

```
SKILL.md                        ← the agent instructions; read by any coding agent
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

**1. Model catalog refresh.** `references/model-catalog.md` carries a `Last updated:` date. When the agent reads the skill, it checks that date — if it's older than 30 days, or if you mention a model not in the catalog, it'll WebFetch fal.ai's model pages, diff against the file, and propose updates for your review. No silent rewrites.

**2. Learnings log.** `references/learnings.md` is an append-only compound file. Every time the agent hits a surprising result — a prompt pattern that worked, a model gotcha, a cost surprise — it appends a one-liner. Next session it reads the log first and applies the lesson. Over months it becomes personalised field intelligence that no public doc captures.

Both mechanisms are described in detail in `SKILL.md` under "Staying Fresh."

---

## Tailoring it for your brand

`references/art-direction.md` ships empty on purpose. Every time you find yourself re-explaining a preference to the agent ("always use 16:9", "my brand color is `#3D491D`", "camera angles at 35° above horizontal"), add it to that file. The skill reads it before every session, so preferences compound instead of being re-specified each time.

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

Pull requests welcome. The two highest-leverage places to contribute:

- **Model catalog updates** — fal.ai launches new models weekly. If you spot a missing or outdated entry in `references/model-catalog.md`, open a PR.
- **Learnings** — if you find a model gotcha, prompt pattern, or failure mode that repeats, submit it to `references/learnings.md`. Short entries (under 15 words). Keep the date.

Issues welcome for anything: API changes, broken auth, pricing surprises, script bugs, agent-compatibility weirdness.

---

## License

Apache 2.0. See `LICENSE`.

---

## Credit

Originally built for the [Haavn' Fun](https://haavn.ai/fun) workshop on generative imagery and video. The Haavn-specific art-direction layer has been stripped for public release.
