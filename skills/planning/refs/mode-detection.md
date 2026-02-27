# Mode Detection Criteria

## Direct Mode (Specific)

Use Direct if any of the following apply:

- A specific filename is mentioned ("modify UserService.ts")
- A specific feature name is given ("add logout feature")
- A clear action is defined ("end session on button click")
- Already sufficiently detailed from previous conversation

## Interview Mode (Ambiguous)

Use Interview if any of the following apply:

- Vague verbs used ("improve", "refactor", "optimize")
- Spans 3 or more areas ("I want to fix things overall")
- No specific file or feature mentioned
- Expressions like "I want to do something"

## No Arguments

Analyze conversation history:
- Specific ideas emerged in previous conversation → Direct
- Previous conversation is ambiguous or absent → Interview
- Cannot determine → AskUserQuestion

```json
{
  "question": "What task would you like to plan?",
  "header": "Planning",
  "multiSelect": false,
  "options": [
    { "label": "Continue previous conversation", "description": "Turn recent discussion into a plan" },
    { "label": "New task", "description": "Plan a new feature or improvement" }
  ]
}
```
