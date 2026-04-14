# Caveman Evaluation Guide

This folder contains a lightweight setup for testing **[Caveman](https://github.com/JuliusBrussee/caveman)** in the `pixel_weather_app` workflow.

The goal is to evaluate whether Caveman improves the day-to-day developer experience **without** disrupting the existing workflow.

---

## What we are testing

Caveman appears to be most useful as a **response compression / terse communication layer** for AI coding agents.

For this repo, the most promising use cases are:

1. **Short review comments**
2. **Short commit message suggestions**
3. **Short branch / diff summaries**
4. **Optional compression of agent-facing instruction docs**

We are **not** treating Caveman as the main implementation/debugging workflow yet.

---

## Recommended evaluation strategy

Start small and compare output quality between:
- **normal assistant mode**
- **Caveman mode**

Focus on whether Caveman is:
- faster to read
- still accurate
- still actionable
- too lossy for this project

---

## Suggested evaluation phases

### Phase 1 — Manual prompt comparison
Run the same task twice:
- once in normal mode
- once in Caveman mode

Recommended tasks:
- summarize current branch changes
- review a diff
- propose commit messages
- summarize failing tests

### Phase 2 — Real repo use
If Phase 1 looks good, use Caveman for:
- review summaries
- commit message drafting
- branch summaries

Keep normal mode for:
- implementation
- Flutter debugging
- Riverpod/controller work
- CI troubleshooting
- native widget/platform issues

### Phase 3 — Optional deeper integration
If the results are consistently useful, consider:
- adding a repo usage note
- adding helper scripts
- adding a `.codex` integration if needed
- testing compressed agent docs

---

## Evaluation checklist

Use this checklist for each experiment:

- [ ] Output is shorter than normal mode
- [ ] Important technical details are preserved
- [ ] Output is still easy to follow
- [ ] Output is actionable
- [ ] Output is not overly cryptic
- [ ] Output saves time in real workflow

If most boxes are checked, Caveman is a good fit for that task type.

---

## Prompts to test

See the prompts in [`docs/caveman/prompts.md`](./prompts.md).

---

## Recommended first conclusion criteria

Caveman is likely worth keeping **if** it improves at least two of these reliably:
- PR/diff review readability
- commit message generation
- short branch status summaries

If it only makes answers shorter but less useful, keep it as an occasional tool only.

---

## Suggested repo-specific recommendation

For `pixel_weather_app`, the likely best long-term setup is:

### Good candidates
- on-demand review mode
- on-demand commit mode
- short branch summaries

### Not recommended as default (yet)
- always-on ultra terse mode for implementation
- primary debugging mode
- primary architecture/design mode

---

## Notes

This experiment is intentionally lightweight.

The point is to learn whether Caveman adds value to this repo before adding any deeper integration or automation.
