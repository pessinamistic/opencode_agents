# Contributing to Scuderia

Thanks for pulling into the garage. This project is a set of agent
definitions mirrored across four harnesses (OpenCode, Claude Code, Codex,
Antigravity/Gemini) from a single source of truth — so most of the rules
below exist to keep those mirrors from drifting.

## The one rule that matters most

**`agents/*.md` is the single source of truth. Never hand-edit a generated
mirror.**

- `.claude/agents/*.md`, `.codex/agents/*.toml` are **generated**. Every file
  carries a `GENERATED … do not hand-edit` header.
- To change an agent: edit its `agents/<role>.md` source, then regenerate:

  ```bash
  node scripts/sync-agents.mjs         # → .claude/agents/
  node scripts/sync-codex-agents.mjs   # → .codex/agents/*.toml
  ```

- A hand-edited mirror will be flagged by the sync `--check` gate and
  silently overwritten on the next regenerate.

## Before you open a PR

Run the gate. CI runs exactly this, so green locally means green in CI:

```bash
node scripts/validate.mjs --platform all      # contract checks across all harnesses
node scripts/sync-agents.mjs --check          # mirrors are current
node scripts/sync-codex-agents.mjs --check    # codex TOML is current
```

`validate.mjs` must exit clean **except** for the known baseline: the
`config/opencode.personal.jsonc` model IDs only resolve on a machine where
`opencode models` lists them, and `config/*.work.jsonc` ships as `TODO`
placeholders by design. Don't "fix" those by guessing model IDs.

## House rules

- **Zero runtime dependencies.** Everything runs on Node ≥ 20 stdlib + bash.
  Adding an npm dependency is a design decision — open an issue first, don't
  slip it into a PR.
- **Model IDs live in `config/*.jsonc` profiles, never in agent frontmatter.**
  `validate.mjs` rejects an `agents/*.md` that grows a `model:` key. This is
  what lets the same prompts run on a Copilot machine and a local-Ollama
  machine unchanged. See [docs/model-routing.md](docs/model-routing.md).
- **New skills** go in `.claude/skills/<name>/SKILL.md` (one directory serves
  both OpenCode and Claude Code). See
  [docs/adding-a-skill.md](docs/adding-a-skill.md).
- **Match the surrounding style.** These are prompt files and small,
  dependency-free scripts — imitate the file you're changing.

## Changing an agent's behavior vs. its voice

The roster wears a Scuderia persona (Race Engineer, Technical Director,
Mechanic, Tyre Tech, Scrutineer, Telemetry Engineer), but the persona is
**voice only** — it sits on top of each agent's functional contract. If you
touch an `agents/*.md`, keep the behavioral rules, triage boundaries, and
escalation logic intact; theme the prose, not the semantics.

## Adding or changing a harness mirror

Each harness has a generator and a section in the root README. If you extend
one, update: the generator (`scripts/sync-*.mjs` or `antigravity/install.sh`),
the validator coverage in `scripts/validate.mjs`, the relevant `docs/`, and
the README. A mirror without validator coverage is a mirror that will rot.

## Reporting issues

Include which harness you're on (OpenCode / Claude Code / Codex /
Antigravity), the output of `bash scripts/doctor.sh`, and — for a routing
problem — which profile loaded and which model actually ran (the OpenCode TUI
shows the model per session).

*Forza Ferrari.* 🐎
