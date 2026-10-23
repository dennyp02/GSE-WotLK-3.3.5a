# Agent Rules — GSE WotLK 3.3.5a Addon Project

Rules the agent MUST follow. The user has explicitly stated these.

## Trust the user — they are not a liar

- The user is the sole authority on what they see on their own screen and what the addon does/doesn't do.
- If the user describes a behavior (e.g. "tabs are vertical"), that is fact. Never contradict it with the vision agent's description or your own inference.
- If your analysis or the vision agent disagrees with the user, the user is right and your analysis is wrong.
- If you are unsure what the user means or see something inconsistent, **stop and ask** — do not assume and do not implement.
- The vision subagent is a tool to assist, not an authority over the user.

## Planning first — ALWAYS ask before implementing

- **Plan mode is the default.** Investigate and report findings FIRST. Do NOT edit any code until the user explicitly gives the go-ahead (e.g. "yes", "proceed", "do it").
- State the suspected root cause and the proposed fix clearly before touching files.
- If the user says "stop" or "wait", stop immediately — do not finish the current edit or start new work.
- Roll back any unapproved changes without being asked.

## No assumptions about ElvUI

- **Assume the addon must work identically with and without ElvUI.** Never assume a behavior or fix applies only to one configuration unless the user explicitly tells you so.
- When the user reports a bug, assume it occurs in BOTH configurations unless they say otherwise.

## Use the vision agent for UI work

- For any UI/layout/sizing issue, read the actual in-game screenshots with the vision subagent (`opencode-go/deepseek-v4.1-flash`, launched via `task` with `subagent_type= "general"`). Do not guess about visual rendering from code alone.
- Verify UI fixes with the vision agent after implementing, before reporting done.

## Use available reference tools

- The Milkyway Codex MCP is available for WoW 3.3.5a API reference (functions, events, widgets, CVars, data types, combat log, secure templates). Use it to verify correct API usage and widget structure instead of guessing.

## Changelog hygiene — log only real changes

- Log only features and fixes that are genuine changes from the original backport baseline.
- Do NOT log "bugs we introduced and then fixed" — those are not changes to the original addon, they are the agent's own mistakes.
- Be honest about what was a regression vs. a fix.

## Communication

- Be direct and concise. Do not pad with explanations of what you did unless asked.
- When the user corrects you, acknowledge it plainly and adjust — do not defend the previous action.
