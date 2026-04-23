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

Open Claude Code and paste the block below. Claude walks through the whole setup — what the skill does, fal.ai signup, API key, secure storage, install, verification.

> I want to install **agent-fal-imagegen**, a coding-agent skill that lets me generate images, videos, and audio via fal.ai (600+ models including Nano Banana 2, Seedance 2, Veo 3, GPT Image 2) and xAI Grok Imagine. Every generation will cost money from my fal.ai account and you will always ask me to confirm before spending.
>
> Walk me through this step-by-step. Stop and wait for my confirmation between each step.
>
> **Step 1 — Check if I already have a fal.ai API key.** Ask me. If yes, skip to Step 3. If no, go to Step 2.
>
> **Step 2 — Get a fal.ai key.** Tell me to:
> 1. Sign up at https://fal.ai (free, Google/GitHub/email).
> 2. Go to the Billing page and load at least $10 of credits. ($10 is roughly 125 Nano Banana 2 images or 500 Grok Imagine images.)
> 3. Go to https://fal.ai/dashboard/keys and click "Create API Key". Copy it somewhere safe (like a password manager) — you can't view it again later.
>
> Wait for me to confirm I have the key before moving on.
>
> **Step 3 — Install the skill.** Run `git clone --single-branch --depth 1 https://github.com/7ebastian/agent-fal-imagegen.git ~/.claude/skills/fal-imagegen`. Verify `~/.claude/skills/fal-imagegen/SKILL.md` exists.
>
> **Step 4 — Store the key securely.** Detect my OS and recommend the best tier for me:
> - **macOS (recommended):** use the Keychain. Run `security add-generic-password -s fal.ai -a FAL_KEY -w '<MY-KEY>' -U`. Then add this line to `~/.zshrc`: `export FAL_KEY=$(security find-generic-password -s fal.ai -a FAL_KEY -w 2>/dev/null)`. This keeps the key encrypted at rest — the plaintext never touches a rc file.
> - **Linux:** if `secret-tool` (libsecret) is installed, use it the same way. Otherwise fall back to `export FAL_KEY="<MY-KEY>"` in `~/.bashrc` or `~/.zshrc` with a note that this is less secure.
> - **Windows:** suggest the Credential Manager via PowerShell, or a plain env var in the appropriate shell config.
>
> Show me the exact commands, ask me to run them, then verify: open a new shell and check that `echo $FAL_KEY` prints a non-empty value.
>
> **Step 5 — Optional: xAI Grok Imagine.** Ask if I want this. If yes, walk me through getting an `XAI_API_KEY` from https://console.x.ai and storing it the same way (Keychain preferred).
>
> **Step 6 — Test it.** Offer to run a $0.08 test generation: a simple photorealistic image via `~/.claude/skills/fal-imagegen/fal-generate.sh`. Wait for me to confirm before spending.
>
> **Step 7 — Optional: tell teammates.** Ask if I want to add a short "fal-imagegen" section to this project's `CLAUDE.md` so teammates know the skill is available.

### Easy mode — ChatGPT Codex

In a Codex session, paste the same block but with the path adjusted:

> I want to install **agent-fal-imagegen**, a coding-agent skill that lets me generate images, videos, and audio via fal.ai and xAI Grok Imagine. Every generation costs money from my fal.ai account and you must always ask me to confirm before spending.
>
> Follow the same 7-step walkthrough as the Claude Code version (see https://github.com/7ebastian/agent-fal-imagegen#easy-mode--claude-code-paste-this-into-a-fresh-session), but:
> - Clone the skill to `~/.codex/skills/fal-imagegen` instead of `~/.claude/skills/fal-imagegen`.
> - After cloning, read `~/.codex/skills/fal-imagegen/SKILL.md` and follow its instructions whenever I ask you to generate imagery, video, or audio this session. You don't parse the YAML frontmatter; treat the body as plain instructions.
> - When asking about the teammates step, offer `AGENTS.md` instead of `CLAUDE.md`.

### Easy mode — Gemini CLI

In a Gemini CLI session:

> I want to install **agent-fal-imagegen**, a coding-agent skill that lets me generate images, videos, and audio via fal.ai and xAI Grok Imagine. Every generation costs money from my fal.ai account and you must always ask me to confirm before spending.
>
> Follow the same 7-step walkthrough as the Claude Code version (see https://github.com/7ebastian/agent-fal-imagegen#easy-mode--claude-code-paste-this-into-a-fresh-session), but:
> - Clone to `~/.gemini/skills/fal-imagegen`.
> - After cloning, read `~/.gemini/skills/fal-imagegen/SKILL.md` and follow its instructions for any image/video/audio generation request this session.
> - When asking about the teammates step, offer `GEMINI.md` instead of `CLAUDE.md`.

### Too-scared-to-paste-something-into-a-terminal mode (get a chat assistant to hand-hold you first)

If you've never used an API key or a terminal, paste the prompt below into **Claude** ([claude.ai](https://claude.ai)) or **ChatGPT** ([chatgpt.com](https://chatgpt.com)) — either works. Any modern chat assistant will do, including Gemini, Grok, or Perplexity.

> I want to install a coding-agent skill called **agent-fal-imagegen** that lets me generate images and videos by talking to my coding assistant (Claude Code, ChatGPT Codex, or Gemini CLI). Walk me through it like I've never used a terminal before. The GitHub URL is `https://github.com/7ebastian/agent-fal-imagegen`. I also need to sign up at fal.ai, load $10 of credits, generate an API key in the fal.ai dashboard, and save that key as an environment variable on my Mac/Windows machine. Please give me the exact steps, one at a time, and wait for me to confirm before moving to the next.

Once the chat assistant has you set up (account created, key exported, terminal ready), paste the appropriate easy-mode block above into your coding agent.

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

3. **Store the key.** Pick a security tier below. The easy-mode paste-into-agent flow above recommends Tier 2 on macOS.

4. **Optional — xAI / Grok Imagine.** If you want the xAI models (good for charts and photorealism), get a key from [console.x.ai](https://console.x.ai) and store it the same way as `FAL_KEY`, but under the name `XAI_API_KEY`.

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

## Storing `FAL_KEY` — security tiers

The skill scripts read `FAL_KEY` from the environment. *How* you get it there is up to you. Pick a tier; you can upgrade later without changing anything in the skill itself.

**Industry backdrop:** [Claude's own API-key guidance](https://support.claude.com/en/articles/9767949-api-key-best-practices-keeping-your-keys-safe-and-secure) and this [community write-up on Claude-skill credentials](https://medium.com/ducky-ai/the-credential-conundrum-managing-api-keys-in-claude-skills-430c41b21aa8) both call out that ~90% of API key leaks are human error — keys accidentally committed, inherited by random subprocesses, or left plaintext in places backup tools can read. Picking the right tier matters more than most people think.

### Tier 1 — plain env var in rc file (easiest, least secure)

```bash
# in ~/.zshrc or ~/.bashrc
export FAL_KEY="your-key-here"
```

Pros: zero tooling, one line. Cons: plaintext on disk; every subshell, npm postinstall, and Docker container that inherits your env can read it. Fine for a personal laptop with no shared accounts. Not fine if you run untrusted tools or ship your laptop to repair.

### Tier 2 — macOS Keychain (recommended default on Mac)

Store the key once:

```bash
security add-generic-password -s fal.ai -a FAL_KEY -w 'your-key-here' -U
```

Fetch it at shell start:

```bash
# in ~/.zshrc
export FAL_KEY=$(security find-generic-password -s fal.ai -a FAL_KEY -w 2>/dev/null)
```

Pros: encrypted at rest by the OS; plaintext never hits a config file; can require auth for access. Cons: macOS-only. To rotate, rerun the first command with the new key.

### Tier 2 (Linux) — libsecret via `secret-tool`

```bash
# store once
echo -n 'your-key-here' | secret-tool store --label='fal.ai' service fal.ai account FAL_KEY

# fetch in ~/.bashrc or ~/.zshrc
export FAL_KEY=$(secret-tool lookup service fal.ai account FAL_KEY 2>/dev/null)
```

Works on most Linux distros with GNOME Keyring or KDE KWallet. Install with `sudo apt install libsecret-tools` if missing.

### Tier 3 — direnv with per-project `.env` (best for multi-project devs)

Install [direnv](https://direnv.net). In the project where you use fal:

```bash
# .envrc (not .env — direnv reads this one)
dotenv

# .env (gitignored!)
FAL_KEY=your-key-here
```

`.env` is plaintext but scoped — only loaded when you `cd` into the project directory. Great when you want separate keys per project. **Add `.env` to `.gitignore` before you add anything to it.** 90% of leaks start with a mis-configured `.gitignore`.

### Tier 4 — password-manager CLI (highest security)

Using the 1Password CLI (similar commands exist for Bitwarden, `pass`, etc.):

```bash
# in ~/.zshrc
export FAL_KEY=$(op read "op://Personal/fal.ai/credential" 2>/dev/null)
```

Zero plaintext anywhere on disk; the key fetches on shell start (requires `op signin`). Best for teams and enterprise. Requires a paid/open-source vault.

### Tier ∞ — interactive prompt (no persistence)

If you don't want the key persisted at all, you can modify the skill's entry point to prompt for it each session and keep it in memory only. The [Medium article](https://medium.com/ducky-ai/the-credential-conundrum-managing-api-keys-in-claude-skills-430c41b21aa8) describes this pattern in detail. This skill doesn't currently ship that pattern — open a PR if you want it.

### Which tier should I pick?

- **Hobbyist on personal Mac:** Tier 2 (Keychain) — same one-time setup cost as Tier 1, much better security.
- **Hobbyist on Linux:** Tier 2 (libsecret) if your distro has it; Tier 1 otherwise with strict `chmod 600 ~/.zshrc`.
- **Multi-project developer:** Tier 3 (direnv) so different projects can have different budgets or keys.
- **Team / enterprise:** Tier 4 (password-manager CLI) so keys rotate through your vault's audit log.

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
