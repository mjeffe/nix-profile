# Pi Subagent Architecture

Multi-model delegation system for [pi](https://github.com/badlogic/pi-coding-agent), modeled after [Amp](https://ampcode.com)'s subagent design.

## Concept

The main agent (DeepSeek V4 Pro, high thinking) delegates tasks to specialized subagents running cheaper/faster models or the same model with different system prompts and thinking levels. Each subagent runs in an isolated `pi` process with its own model, tools, and context window.

Same-model differentiation: system prompt + thinking level create different "personas" from the same model (e.g., Oracle vs Librarian both use V4 Pro but one reasons deeply, the other retrieves efficiently).

## Agents

| Agent | Model | Thinking | Cost/M tok (out) | Tools | Role |
|-------|-------|----------|-------------------|-------|------|
| `rush` | V4 Flash | off | ~$0.18 | read, write, edit, grep, find, ls, bash | Fast cheap tasks: formatting, docstrings, boilerplate, lint fixes, simple refactors, test stubs, single-file changes |
| `oracle` | V4 Pro | high | ~$0.87 | read, grep, find, ls, bash | Complex reasoning: architecture design, debugging hard problems, evaluating tradeoffs, planning refactors |
| `librarian` | V4 Flash | off | ~$0.18 | read, grep, find, ls | Research: find usage patterns, audit code, gather context across many files |
| `review` | V3.2 | — | ~$0.34 | read, grep, find, ls, bash | Code review: bugs, logic errors, security issues, edge cases |

Oracle and Librarian are read-only — they analyze and report but don't edit code.

## Files

```
~/.pi/agent/
├── extensions/subagent/
│   ├── index.ts          # Extension: registers `subagent` tool, spawns pi subprocesses
│   └── agents.ts         # Agent discovery + config parsing (supports `thinkingLevel`)
├── agents/
│   ├── rush.md           # V4 Flash, thinking off
│   ├── oracle.md         # V4 Pro, thinking high, read-only
│   ├── librarian.md      # V4 Flash, thinking off, read-only
│   └── review.md         # V3.2, read-only
└── skills/subagents/
    └── SKILL.md          # Teaches main agent when/how to delegate
```

## Agent Definition Format

```markdown
---
name: rush
description: What this agent does (shown in tool descriptions)
tools: read, write, edit, grep, find, ls, bash
model: deepseek/deepseek-v4-flash
thinking: off
---

System prompt goes here. This is the subagent's instructions.
```

Fields: `name`, `description` (required). `tools`, `model`, `thinking` (optional).

## Skill: subagents

The `subagents` skill loads when tasks match its description. It teaches the main agent:

- Which agent to pick for which task type
- How to compose single, parallel, and chained invocations
- That subagents have isolated context (include all needed info in the task)
- Oracle/Librarian are analysts only — use Rush or the main agent for implementation

## Usage Examples

```
"Use rush to add JSDoc comments to all exported functions in src/utils.ts"

"Have oracle evaluate approaches for adding Redis caching to the API layer"

"Use librarian to find every place we read from process.env and what vars are used"

"Run rush to format src/components/ and librarian to find all TODO comments"

"Have oracle plan the auth refactor, then rush implement it"
```

## Adding Agents

Drop a `.md` file in `~/.pi/agent/agents/` with YAML frontmatter. Discovered at runtime — no restart needed.

For project-specific agents (team conventions, repo-specific patterns):

```
.pi/agents/
└── my-agent.md
```

Set `agentScope: "both"` or `"project"` in subagent invocations to include them.

## Extension Modification

The subagent extension was forked from pi's example to add `thinkingLevel` support:

- `agents.ts`: Added `thinkingLevel` field to `AgentConfig`, parsed from `thinkingLevel` or `thinking` frontmatter key
- `index.ts`: Added `--thinking <level>` flag to subprocess invocation when agent specifies a thinking level