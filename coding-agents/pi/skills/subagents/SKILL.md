---
name: subagents
description: Delegate coding tasks to specialized subagents (rush, oracle, librarian, review). Rush for fast cheap tasks, Oracle for complex reasoning/planning, Librarian for codebase research, Review for code review. Use when offloading work to save context or use cheaper/faster models.
---

# Subagents

Delegate tasks to specialized subagents with isolated context and model selection.

## Available Agents

| Agent | Model | Thinking | Best for |
|-------|-------|----------|----------|
| `rush` | V4 Flash | off | Fast cheap tasks: formatting, docstrings, boilerplate, lint fixes, simple refactors, test stubs, single-file changes |
| `oracle` | V4 Pro | high | Complex reasoning: architecture design, debugging hard problems, evaluating tradeoffs, planning multi-step refactors |
| `librarian` | V4 Flash | off | Research: find where things are used, audit patterns, gather context across many files, answer "how does X work?" |
| `review` | V3.2 | — | Code review: find bugs, logic errors, security issues, edge cases before merging |

## Usage

### Single task
```
subagent({ agent: "rush", task: "Format all TypeScript files in src/components/" })
subagent({ agent: "oracle", task: "Evaluate approaches for adding caching to the API layer. Current code is in src/api/" })
subagent({ agent: "librarian", task: "Find every place in the codebase that reads from process.env and report what env vars are used" })
subagent({ agent: "review", task: "Review the changes in src/auth.ts and src/middleware/auth.ts for security issues" })
```

### Parallel
Run multiple independent tasks concurrently (max 8, 4 at a time):
```
subagent({ tasks: [
  { agent: "rush", task: "Add JSDoc to exported functions in src/utils/" },
  { agent: "librarian", task: "Find all TODO/FIXME comments in src/" },
  { agent: "rush", task: "Run prettier on src/components/" }
] })
```

### Chain
Pass output between agents:
```
subagent({ chain: [
  { agent: "oracle", task: "Plan how to refactor src/auth.ts to support multiple providers" },
  { agent: "rush", task: "Implement this plan: {previous}" }
] })
```

## Decision Guide

| Task type | Agent | Why |
|-----------|-------|-----|
| Formatting, lint fixes, docstrings | `rush` | Trivial, just needs speed |
| Simple refactors (rename, extract) | `rush` | Well-scoped, minimal reasoning needed |
| Bug fix in a single file | `rush` | Straightforward, isolated change |
| Multi-file refactor or feature | Main agent | Needs full context and coordination |
| Hard debugging problem | `oracle` first | Plan before coding |
| Before a big refactor | `oracle` | Understand implications first |
| "Where is X used?" | `librarian` | Search-and-report, no editing |
| "Audit all error handling in X" | `librarian` | Pattern finding across codebase |
| Before merging a PR | `review` | Catch issues early |
| Security-sensitive code | Main agent | Never delegate auth/crypto |

## Important

Subagents have ISOLATED context — they cannot see the main conversation. Include ALL needed context in the task description: file paths, conventions, specific instructions.

When a subagent finishes, review its output. If it failed or missed something, retry with clearer instructions or handle it yourself. Oracle and librarian only analyze — they don't edit code. Use rush or the main agent for implementation.