# Caveman Test Prompts

Use these prompts to compare **normal mode** vs **Caveman mode** in this repo.

---

## 1. Branch summary

### Prompt
```text
Summarize the current branch changes for pixel_weather_app.
Keep it short and developer-focused.
Mention risks, affected areas, and likely reviewer focus.
```

### What to evaluate
- Is it shorter?
- Is it still clear?
- Does it mention the right files/areas?

---

## 2. Review comments

### Prompt
```text
Review the current diff for pixel_weather_app.
Give short review comments only.
Focus on correctness, regressions, maintainability, and test risk.
```

### What to evaluate
- Are comments useful?
- Are they too vague?
- Do they point to real risk?

---

## 3. Commit message generation

### Prompt
```text
Write 5 short conventional commit message options for the current changes.
Keep them precise and repo-appropriate.
```

### What to evaluate
- Are they concise?
- Are they accurate?
- Are they actually better than normal suggestions?

---

## 4. Failing test summary

### Prompt
```text
Summarize the failing test output.
List probable root cause, affected files, and fastest fix path.
Keep it compact.
```

### What to evaluate
- Is the diagnosis still understandable?
- Is it missing important nuance?
- Would this save time during CI fixes?

---

## 5. PR summary draft

### Prompt
```text
Write a short PR summary in markdown for these changes.
Include what changed, why it matters, and any validation notes.
```

### What to evaluate
- Is it reviewer-friendly?
- Is it too compressed?
- Would you paste it into a PR as-is?

---

## 6. Doc compression experiment

### Prompt
```text
Compress this developer-facing instruction document while preserving technical meaning, commands, file paths, and critical constraints.
```

### Good candidates for this repo
- `AGENT.md`
- internal workflow notes
- long AI-facing instruction files

### Avoid using first
- README intended for general users
- polished PR descriptions
- public-facing docs that should remain human-friendly

---

## 7. Architecture summary

### Prompt
```text
Summarize the architecture of pixel_weather_app in a very compact but still readable way.
Cover presentation, domain, data, state management, and testing.
```

### What to evaluate
- Is the compressed explanation still accurate?
- Is it useful for onboarding?
- Is it too terse to be practical?

---

## Suggested scoring

For each prompt, score 1–5 on:
- **clarity**
- **accuracy**
- **brevity**
- **actionability**

If Caveman improves brevity without hurting clarity/accuracy too much, it is a strong candidate for that task type.
