<!--
TEMPLATE for ONE clarification question. Ask in the user's language.
Preferred: AskUserQuestion (max 4 questions per call; max 5 per /sdd-clarify run in total).
  - header: <=12 chars, the topic ("Roles", "Validation", "Errors", "Scope")
  - question: one concrete sentence ending in "?", never two questions joined by "and"
  - options: 2-4 mutually exclusive answers, the recommended one FIRST with "(Recommended)"
  - option description: the consequence for the behavior or ACs
Fallback when AskUserQuestion is unavailable: print the block below, numbered, and wait for the reply.
Delete these comments from the output.
-->

### Q<n> — <topic> (affects AC-<n>[, AC-<m>] · <gap type>)

**Context:** <where the gap is: quote the scenario or requirement in <=1 line, or name the contradiction>

**Question:** <one concrete, answerable question>

| Option | Answer | Consequence |
|---|---|---|
| A (Recommended) | <answer> | <what the spec will say / which AC changes> |
| B | <answer> | <…> |
| C | <answer> | <…> |

**Why A:** <one sentence: consistency with the code, an existing spec, AGENTS.md or the safest default>

*Reply with a letter, or write your own answer.*
