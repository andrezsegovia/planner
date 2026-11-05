# Worked example

A complete planner for one fictional week: 2026-W45 (2-8 November 2026). It
mirrors the real layout:

```
goals.md
inbox.md
projects/
daily/
weekly/
log/
```

The dates are fixed so the files stay internally consistent with each other.
Copy the shape, not the dates.

## These files are inert

`bin/plan` excludes `docs/` from every repo-wide search, so the example never
appears in `plan ls`, `plan due`, `plan done`, or Vim's quickfix list. `plan
report` only reads the root `log/` directory, so the example log is inert too.

To run the commands against a throwaway copy, see
[Run the example](../getting-started.md#run-the-example).

## Reading order

1. [`goals.md`](goals.md) — two outcomes for Q4.
2. [`projects/`](projects/) — three active projects, each with a current
   milestone and one next action.
3. [`weekly/2026-W45.md`](weekly/2026-W45.md) — the Friday review that chooses
   next week's focus.
4. [`daily/2026-11-05.md`](daily/2026-11-05.md) and
   [`daily/2026-11-06.md`](daily/2026-11-06.md) — a working day and the review
   day.
5. [`log/2026-11.md`](log/2026-11.md) — the same week as one line per block.
6. [`inbox.md`](inbox.md) — capture waiting to be processed on Friday.

The order of events is deliberately visible: the weekly review on Friday
turns project next actions into next week's focus, and the daily files spend
that focus one day at a time.
