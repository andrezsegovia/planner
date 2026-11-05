# Getting started

> A five-step walkthrough from an empty clone to a working first week. It is
> deliberately concrete: one fictional week, filled in end to end, in
> [`example/`](example/). The [README](../README.md) is the reference for
> commands, task syntax, sync and Vim.

## 0. Check the install

```bash
plan init
plan today
plan week
```

`plan init` is idempotent: it creates missing directories and starter files and
prints `planner ready: ...`. The other two commands open (or create) today's
file and this week's review. Quit with `:q` if you are in Vim.

If `plan: command not found`, the shell integration is not loaded:

```bash
exec bash                  # after ./install.sh
# or, without the installer:
export PATH="$PWD/bin:$PATH"
```

You should now have:

```
inbox.md   capture, one line per open loop
goals.md   2-3 outcomes for the quarter
projects/  one file per project; tasks live here
daily/     one file per day: focus, commitments, time, log
weekly/    one review per week
log/       time, one line per block
```

Nothing here is a database. Every command is a small shell script over these
files, so you can open, grep, edit, or delete them by hand.

## How the pieces fit

Work is planned at different horizons, and each horizon has exactly one home:

| Horizon | Where | Question |
|---|---|---|
| Year | project `outcome` + `deadline` | Why is this worth months? |
| Quarter | `goals.md` | What must be true in 90 days? |
| Month | project `## Milestones` | What verifiable checkpoint is next? |
| Week | weekly review | What moves that milestone? |
| Day | daily `## Focus` | What is the one thing today? |

The flow runs one way:

```
inbox → goals → projects → weekly review → daily plan → time log
```

Capture first, organize on Friday. The review chooses what next week is for.
The daily plan chooses what today is for. The log records what actually
happened.

Four rules matter more than the rest:

1. **One focus, three commitments per day.** After the third commitment,
   nothing new starts.
2. **A task lives in exactly one place** — its project file, or the inbox until
   it gets one. The daily note holds the day's plan, not a second backlog.
3. **At most three active projects.** A project is active only if it has an
   `outcome` and one concrete `Next action`.
4. **The Friday review is the system.** If you skip it twice, cut structure
   until you don't.

## Step 1 — Capture before you organize

Ten minutes, one line per open loop:

```bash
plan add "book a haircut"
plan add "ask Alex about the staging domain"
plan add "idea: version history for documents"
```

`plan add` writes `- [ ] ...` to `inbox.md`. Do not sort while capturing, and
do not act on anything that appears during the day — capture it and keep going.

The example inbox is at [`example/inbox.md`](example/inbox.md).

## Step 2 — Choose the quarter

Open `goals.md` with your editor:

```bash
$EDITOR goals.md
```

Write **two or three** outcomes for the next 90 days. Each one needs:

- **Outcome:** a finish line you can describe in one sentence.
- **Why:** what it buys you, in one line.
- **Deadline:** a real date.
- **Projects:** the project files that serve it.

For example (from [`example/goals.md`](example/goals.md)):

```markdown
## 1. Ship the Product v1 beta

- **Outcome:** v1 is deployed to staging and 10 beta users have created an account
- **Why:** prove people want it before building billing
- **Deadline:** 2026-12-18
- **Projects:** Product v1, Marketing site
```

If you cannot tell when an outcome is done, it is an area, not a goal. Put it
under `## Not now`. That section is not a graveyard; it is how you say no this
quarter without losing the idea.

## Step 3 — Turn goals into at most three projects

```bash
plan new "Product v1"
plan new "Marketing site"
plan new "10k base"
plan edit                  # pick a project (fzf); or: plan edit "Product v1"
```

In each project file, fill in the minimum that makes it active:

- `outcome:` and `deadline:` in the frontmatter;
- **Milestones** every 2-6 weeks — a demo, a measurement, a shippable slice;
- **Current milestone** — the first unchecked one;
- exactly one **Next action** — small enough to start today;
- only the current milestone's tasks under **Tasks**; everything else goes
  under **Later**.

Here is [`example/projects/product-v1.md`](example/projects/product-v1.md) with
the middle elided:

```markdown
---
type: project
status: active
outcome: v1 is deployed to staging and 10 beta users have created an account
deadline: 2026-12-18
created: 2026-10-01
---
# Product v1

## Milestones
- [x] M1 — Signup and login work on staging #milestone due:2026-11-04
- [ ] M2 — Create, save, and reopen a document #milestone due:2026-11-20
- [ ] M3 — Invite 10 beta users and collect feedback #milestone due:2026-12-11

## Current milestone
M2 — create, save and reopen a document

### Next action
- [ ] Save the document body to Postgres through the auth session #product due:2026-11-06

### Tasks
- [ ] Write the integration test that saves and reopens #product due:2026-11-06
- [ ] Load a saved document on open #product due:2026-11-10
- [ ] Wait for staging domain approval #product @waiting

## Later
- Password reset
- Billing
```

A project without an outcome or a next action is not active. Park it, or delete
it. More than three active projects means none of them moves.

## Step 4 — Review the week

```bash
plan week
```

Do this on Friday. If you are starting midweek, do it now anyway: it sets up
next week and catches what has already happened this week.

Answer the five sections honestly:

1. **What moved?** Concrete progress, not activity. Name the project.
2. **What stalled?** No judgement. Write the smallest next action.
3. **Goals check.** Open `goals.md`: did each goal get time this week?
4. **Next week's focus.** One focus per active project, capped at three.
5. **Housekeeping.** Process the inbox, update next actions, pause or archive
   dead projects, check the time log.

Then look at the data:

```bash
plan due 7          # tasks due in the next week, overdue first
plan projects       # status and open-task count per project
plan report week    # where the hours went
```

The filled-in example is
[`example/weekly/2026-W45.md`](example/weekly/2026-W45.md). The important line
is section 4: next week's focus is chosen *before* the week starts.

## Step 5 — Plan today

```bash
plan today
```

Morning, five minutes:

- **Focus** — one line. The thing that moves a goal today.
- **Commitments** — at most three checkboxes. The day's slice of project work.
- **Time** — rough blocks for the commitments.

From [`example/daily/2026-11-05.md`](example/daily/2026-11-05.md):

```markdown
## Focus
Ship the save endpoint so a document survives a reload on staging.

## Commitments
- [ ] Save the document body to Postgres #product
- [ ] Write the integration test that saves and reopens #product
- [ ] 30-minute easy run #10k

## Time
- 09:00-11:00 product save endpoint
- 11:15-12:00 product integration test
- 18:00-18:30 10k easy run
```

The commitment is today's version of the work; the task itself still lives in
the project file. Do not copy the whole backlog into the day.

## The daily loop

Morning, five minutes:

```bash
plan today
```

Write the focus, pick at most three commitments, sketch the time blocks.

During the day:

```bash
plan add "idea that just appeared"      # never act on it now
plan log 2h product save-endpoint       # when you stop
```

`plan log` appends one line to `log/YYYY-MM.md`, for example
`2026-11-05 2h product save-endpoint`. Durations can be `2h`, `1.5h`, `45m`, or
a clock range like `09:00-11:00`.

Evening, five minutes: fill `## Log` with what actually happened and why. Move
anything in `## Captured` to the inbox, then clear it. Commit if you want the
day synced:

```bash
plan sync
```

## The Friday loop

```bash
plan week                       # the five sections
plan inbox                      # process every captured line
plan due 7                      # what is due next week
plan stale 14                   # projects nobody touched
plan projects                   # status and open-task count
plan report week                # where the hours went
plan sync "weekly review"
```

What to do with each output:

- **`plan due 7`** — put a real date on anything that must land, or delete it.
- **`plan stale 14`** — a project that has not moved in two weeks is not active.
  Pause or archive it.
- **`plan projects`** — every active project needs exactly one next action.
- **`plan report week`** — compare the hours with what you said mattered. Slip
  is information, not a moral failure.

The review produces next week's focus. Nothing else in the system chooses the
week for you.

## Run the example

The files under [`example/`](example/) are inert. `bin/plan` excludes `docs/`
from every repo-wide search, so they never show up in `plan ls`, `plan due`,
`plan done`, or Vim's quickfix. `plan report` only reads `log/` at the planner
root, so the example log is inert too.

To run the commands against a throwaway copy:

```bash
tmp=$(mktemp -d)
PLANNER_DIR="$tmp" plan init
cp -r docs/example/{goals.md,inbox.md,projects,weekly,daily,log} "$tmp"/

PLANNER_DIR="$tmp" plan projects
PLANNER_DIR="$tmp" plan ls
PLANNER_DIR="$tmp" plan due 14
PLANNER_DIR="$tmp" plan report all
```

`plan report week` only shows the example during 2026-W45 (2-8 November 2026);
`plan report all` works at any time. You can safely try the write commands
against the copy:

```bash
PLANNER_DIR="$tmp" plan done "Write the integration test"
PLANNER_DIR="$tmp" plan projects
```

That checks the task off in `$tmp/projects/product-v1.md` and nowhere else.
Remove the sandbox with `rm -rf "$tmp"`.

## The first three weeks

Do not install the whole system on day one. The README's ramp is the fastest
path:

| Week | Use only |
|---|---|
| 1 | `inbox.md`, `daily/`, and the Friday review. No projects, no time log. |
| 2 | Add two or three projects, each with an outcome and one next action. |
| 3 | Start the time log and look at `plan report week` once. |

Anything you have not used in a month, delete. The system serves you, not the
other way around.

## Common mistakes

- **Four commitments and no focus.** The day becomes a list, not a decision.
- **Two backlogs.** A task in a project and a copy in today's note will drift.
  Keep the task in the project; keep today's slice in the daily note.
- **Projects without an outcome or a next action.** They look active and are
  not. Either supply both or move the file out of the way.
- **Planning the quarter in tasks.** Detail only the current milestone. A year
  of checkboxes is a backlog, not a plan.
- **Skipping the review twice.** The system degrades quietly. Cut structure
  until the Friday review happens.
- **Reconstructing the time log from memory at month end.** Log when you stop,
  one line; that is the whole point of it being cheap.

## Where to go next

- [Long projects](../README.md#long-projects) — milestones, re-estimating, and
  splitting phases.
- [Monthly review](../README.md#monthly-review) — the first Friday of the
  month.
- [Sync across machines](../README.md#sync-across-machines) — `plan sync` and
  conflicts.
- [Commands](../README.md#commands) and
  [Task syntax](../README.md#task-syntax) — the reference.
- [Vim](../README.md#vim) — `<leader>pt`, `<leader>pw`, `<leader>pl`, and the
  checkbox toggle.
