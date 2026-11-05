# Planner

A plain-markdown planning system for one person, a terminal, and Vim.

The point is not to collect tasks. The point is to decide, in advance, what
"moving forward" means this week — and then to notice when it didn't happen.

Everything is `.md` files. There is no database, no server, no plugin lock-in.
`bin/plan` is a small bash script over `rg` and `awk`; delete it and the files
still make sense.

The repository **is** the planner: configuration and plans live in the same
checkout. Clone your own copy, run the installer, and commit/push to keep it in
sync across machines.

> Use your own repository (fork it or create your own copy). Do not push your
> daily notes to the upstream template.

New here? [`docs/getting-started.md`](docs/getting-started.md) is a five-step
walkthrough with a filled-in week you can run in a scratch directory.

## Install

```bash
git clone git@github.com:<you>/planner.git ~/reps/planner
cd ~/reps/planner
./install.sh
exec bash                 # or open a new terminal
plan init
```

`install.sh` is idempotent. It does three things:

1. Creates any missing planner directories and starter files (`plan init`).
2. Adds a managed block to `~/.vimrc` that sources
   `integrations/vim/planner.vim`.
3. Adds a managed block to `~/.bashrc` that sources
   `integrations/shell/planner.sh` (adds `bin/` to `PATH`).

Nothing else is touched. `./uninstall.sh` removes the two blocks and leaves
your plans alone.

The clone can live anywhere, not just `~/reps/planner`: the script, Vim file,
shell file, and installer all derive their paths from their own location. If
you move or re-clone it, run `./install.sh` again so the two source lines in
your dotfiles point at the new path.

If you cloned this repository without making it your own, point it at your own
remote before your first commit:

```bash
git remote set-url origin git@github.com:<you>/planner.git
```

### Without the installer

```bash
export PATH="$PWD/bin:$PATH"          # add to ~/.bashrc
plan init
```

and in Vim: `:source /path/to/planner/integrations/vim/planner.vim`.

## Sync across machines

`plan sync` pulls (rebase), commits everything, and pushes:

```bash
plan sync
plan sync "weekly review"
```

Manual equivalent:

```bash
git add -A
git commit -m "plans: $(date +%F)"
git push
```

On a second machine, clone and install once, then `git pull` (or `plan sync`)
to bring the plans over.

A nightly sync from cron:

```cron
0 22 * * * cd ~/reps/planner && ./bin/plan sync >/dev/null 2>&1
```

Notes:

- `plan sync` commits **everything** in the repository, config changes included.
- Sync often (daily, or after the weekly review). Long gaps mean bigger rebase
  conflicts. Conflicts are ordinary markdown; resolve them, then
  `git rebase --continue`.
- If `origin` is still the upstream template, `plan sync` will try to push
  there. Check with `git remote -v`.
- If you do not want to sync, simply do not commit. To keep plan files out of
  `git status` without changing the repository, use `.git/info/exclude`:

```bash
printf '/daily/\n/weekly/\n/log/\n/projects/\n/archive/\n/inbox.md\n/goals.md\n' \
  >> .git/info/exclude
```

## Layout

```
planner/
├── bin/plan                    the CLI (all paths relative to the repo)
├── templates/                  starters: daily, weekly, project, inbox, goals
├── integrations/
│   ├── vim/planner.vim         mappings and functions
│   └── shell/planner.sh        adds bin/ to PATH
├── docs/                       getting-started walkthrough and worked example
├── install.sh
├── uninstall.sh
├── inbox.md                    capture
├── goals.md                    2–3 outcomes per quarter
├── projects/                   one file per project, tasks live here
├── daily/YYYY-MM-DD.md         the day's plan and log
├── weekly/YYYY-Www.md          the Friday review
├── log/YYYY-MM.md              time, one line per block
└── archive/                    finished or abandoned, out of the way
```

`PLANNER_DIR` overrides the planner directory (default: the repo root; useful
for testing). `EDITOR` overrides the editor (default `vim`).

## Fresh start

Because plans are tracked, a clone brings the plans with it. To reset an
existing planner:

```bash
rm -rf daily weekly log projects archive inbox.md goals.md
plan init
git add -A && git commit -m "reset planner"
```

For a completely new, unrelated planner, create a new repository from this one
(GitHub's "Use this template", or clone upstream into a new repo), then clone
that new repository and run `./install.sh`.

## The rules

1. **One focus, three commitments per day.** The focus is the thing that moves
   a goal. After the third commitment, nothing new starts.
2. **A task lives in exactly one place** — its project file, or the inbox until
   it gets one. Daily notes hold the plan and the log, not copies of tasks.
3. **At most three active projects.** A project is active only if it has an
   `outcome` and one concrete `Next action`.
4. **Capture goes to the inbox**, one line, no organizing. Process it on Friday.
5. **The weekly review is the system.** If you skip it twice, cut structure
   until you don't.

## Every day

Morning, 5 minutes:

```bash
plan today
```

- Write the one focus.
- Pick at most three commitments.
- Block time for them (write the blocks under `## Time`, or log as you go).

During the day:

```bash
plan add "idea that just appeared"    # never act on it now
plan log 2h website sitemap           # one line when you stop
```

Evening, 5 minutes: fill `## Log` with what actually happened and why. Then
sync if you work from another machine later:

```bash
plan sync
```

## Every Friday

```bash
plan week
```

Answer the five sections honestly. Then:

```bash
plan due 7          # what is due in the next week
plan stale 14       # projects nobody touched
plan projects       # status and open-task count
plan report week    # where the hours went
plan sync "weekly review"
```

The review produces next week's focus per project. If a project has no outcome
or no movement for two weeks, pause or archive it.

## Long projects

Plan on a rolling horizon: the year loosely, the quarter in `goals.md`, the next
milestone in detail, the day in one focus.

| Horizon | Where | Question |
|---|---|---|
| Year | project `outcome` + `deadline` | Why is this worth months? |
| Quarter | `goals.md` | What must be true in 90 days? |
| Month | project `## Milestones` | What verifiable checkpoint is next? |
| Week | weekly review | What moves that milestone? |
| Day | daily `## Focus` | What is the one thing today? |

Rules for work that lasts months:

1. **Outcome, not activity.** "v1 is deployed and 10 people signed up", not
   "work on the app". If you cannot tell when it is done, it is an area, not a
   project.
2. **Milestones every 2–6 weeks.** Each one is a demo, a measurement, or a
   shippable slice. The first unchecked milestone is the current one.
3. **Only detail the current milestone.** Everything else goes under `Later`.
   A year of tasks in the file is a backlog, not a plan.
4. **One next action.** If it takes more than a day, split it.
5. **Re-estimate monthly.** Slip is information: cut scope, move dates, or
   pause the project. Do not quietly carry stale milestones.
6. **Split phases into projects.** A year-long effort usually becomes 3–5
   sequential projects; archive each one when its outcome is true.

### Example: a software project

```markdown
---
type: project
status: active
outcome: v1 is deployed and 10 people have created an account
deadline: 2027-03-31
created: 2026-11-05
---
# Product v1

## Milestones
- [ ] M1 — Signup and login work on staging #milestone due:2026-11-30
- [ ] M2 — Create, save and reopen a document #milestone due:2026-12-31
- [ ] M3 — 10 beta users invited and giving feedback #milestone due:2027-02-15
- [ ] M4 — Public launch #milestone due:2027-03-31

## Current milestone
M1 — signup and login on staging

### Next action
- [ ] Add session-cookie handling to the login route #product due:2026-11-08

### Tasks
- [ ] Write the auth integration test #product
- [ ] Add staging env vars #product @waiting

## Later
- Password reset
- Billing
- Mobile layout

## Log
- 2026-11-05 chose session cookies over JWT
```

At the weekly review, ask only: did the current milestone move? If not, is the
next action wrong?

### Example: learning a language

Language learning is a long-lived area with recurring practice, not a single
project. Model it as:

- a sequence of projects with finish lines (A2, B1, B2, "20-minute
  conversation");
- a weekly practice target tracked in the review;
- time in the log.

```markdown
---
type: project
status: active
outcome: hold a 20-minute conversation about work and daily life
deadline: 2027-06-30
created: 2026-11-05
---
# Spanish B1 conversation

## Milestones
- [ ] M1 — 500 most common words, present tense #milestone due:2026-12-15
- [ ] M2 — 10 tutoring sessions, past tense #milestone due:2027-02-28
- [ ] M3 — 5 conversations with native speakers #milestone due:2027-04-30
- [ ] M4 — 20 minutes without switching to English #milestone due:2027-06-30

## Current milestone
M1 — core vocabulary and present tense

### Next action
- [ ] Book the first tutoring session #spanish due:2026-11-07

### Tasks
- [ ] Finish unit 3 of the textbook #spanish

## Weekly target
- 4 × 45 min study sessions
- 2 × 30 min listening

## Later
- Read a short novel
- Watch a series without subtitles

## Log
- 2026-11-05 started; textbook + Anki + tutor
```

Habits (Anki, listening) do not belong as checkboxes; they belong in the daily
commitments and the weekly target. The project tracks the finish line, the
habit keeps the volume. Track the practice with
`plan log 45m spanish anki` and look at `plan report month`.

### Monthly review

On the first Friday of the month, in addition to the weekly review:

- `plan report month` — where did the hours actually go?
- `plan due 30` — what is due this month?
- `plan stale 21` — what has not moved?
- For each active project: is the current milestone still the right one? Is its
  date credible? Cut scope before moving the date.
- Update `goals.md` if the quarter changed.

## Commands

| Command | What it does |
|---|---|
| `plan init` | create missing dirs and starter files |
| `plan sync [message]` | pull, commit everything, push |
| `plan` / `plan today` | open or create today's file |
| `plan week [-1]` | open this week's review (or another week) |
| `plan inbox` | open the inbox |
| `plan add <text>` | append a captured task to the inbox |
| `plan new "<title>"` | create a project from the template |
| `plan edit [query]` | open a project (`fzf` when no query) |
| `plan projects` | list projects with status and open-task count |
| `plan ls [project]` | list open tasks |
| `plan due [days]` | tasks due in N days (default 7), overdue first |
| `plan stale [days]` | projects untouched for N days (default 14) |
| `plan done <text>` | check off the single matching task |
| `plan log <dur> <project> [desc]` | log time (`2h`, `1.5h`, `45m`, `09:00-11:00`) |
| `plan report [week\|month\|all]` | sum logged time by project |
| `plan qf` | same tasks as quickfix (used by Vim) |
| `plan path <kind>` | print a path, creating the file if needed |

## Task syntax

```markdown
- [ ] Fix sitemap generator #website due:2026-11-08 est:2h
- [ ] Wait for DNS reply #website @waiting
- [x] Deploy preview build
- [-] Drop the old RSS experiment
```

- One line, starts with a verb.
- `#project` tag is optional but useful for cross-project searches.
- `due:YYYY-MM-DD` only when there is a real deadline.
- `@waiting` for things blocked on someone else.
- No sub-tasks. If a task needs steps, it is a project, or it gets split.
- Empty checkboxes (`- [ ] ` with no text) are ignored by the CLI.

## Vim

Mappings installed by `install.sh`:

| Key | Action |
|---|---|
| `<leader>pt` | today's plan |
| `<leader>pw` | weekly review |
| `<leader>pi` | inbox |
| `<leader>pn` | new project |
| `<leader>pf` | fuzzy-find any planner file (needs fzf.vim) |
| `<leader>pl` | open tasks in the quickfix list |
| `<leader>tc` | toggle the checkbox on the current line |

`<leader>` is whatever you set in your vimrc. The quickfix list uses absolute
paths, so `<leader>pl` works from any directory.

## Configuration lives here

| What | Where |
|---|---|
| CLI behaviour | `bin/plan` |
| File templates | `templates/` |
| Vim mappings and functions | `integrations/vim/planner.vim` |
| Shell `PATH` integration | `integrations/shell/planner.sh` |
| Dotfile installation | `install.sh`, `uninstall.sh` |

The dotfiles only contain one `source` line each, inside a marked block. All
the real configuration is versioned in this repository.

## Uninstall

```bash
./uninstall.sh
```

Removes the Vim and shell blocks. Your plans remain in the repository.

## If it feels heavy

- Week 1: only `inbox.md`, `daily/`, and the Friday review. No projects, no
  time log, no script.
- Week 2: add two or three projects with an outcome and one next action each.
- Week 3: start the time log and look at `plan report week` once.
- Anything you have not used in a month, delete. The system serves you, not the
  other way around.
