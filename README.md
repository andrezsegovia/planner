# Planner

A plain-markdown planning system for one person, a terminal, and Vim.

The point is not to collect tasks. The point is to decide, in advance, what
"moving forward" means this week — and then to notice when it didn't happen.

Everything is `.md` files. There is no database, no server, no plugin lock-in.
`bin/plan` is a small bash script over `rg` and `awk`; delete it and the files
still make sense.

The repository is a **template**: all configuration is versioned here, all
personal data lives in `data/` and is gitignored. Clone it anywhere, run the
installer, and start clean.

## Install

```bash
git clone git@github.com:andrezsegovia/planner.git ~/reps/planner
cd ~/reps/planner
./install.sh
exec bash                 # or open a new terminal
plan init
```

`install.sh` is idempotent. It does three things:

1. Creates the data directories and starter files (`plan init`).
2. Adds a managed block to `~/.vimrc` that sources
   `integrations/vim/planner.vim`.
3. Adds a managed block to `~/.bashrc` that sources
   `integrations/shell/planner.sh` (adds `bin/` to `PATH`).

Nothing else is touched. `./uninstall.sh` removes the two blocks and keeps your
data.

The clone can live anywhere, not just `~/reps/planner`: the script, Vim file,
shell file, and installer all derive their paths from their own location. If
you move or re-clone the repository, run `./install.sh` again so the two source
lines in your dotfiles point at the new path.

### Without the installer

```bash
export PATH="$PWD/bin:$PATH"          # add to ~/.bashrc
plan init
```

and in Vim: `:source /path/to/planner/integrations/vim/planner.vim`.

## Fresh start

`data/` is ignored by git, so a fresh clone is already empty. To reset an
existing planner without losing the old one:

```bash
mv data "data.$(date +%F)"
plan init
```

Or, if you are sure:

```bash
rm -rf data && plan init
```

## Layout

```
planner/
├── bin/plan                    the CLI (all paths relative to the repo)
├── templates/                  starters: daily, weekly, project, inbox, goals
├── integrations/
│   ├── vim/planner.vim         mappings and functions
│   └── shell/planner.sh        adds bin/ to PATH
├── install.sh
├── uninstall.sh
└── data/                       gitignored, created by `plan init`
    ├── inbox.md
    ├── goals.md
    ├── projects/
    ├── daily/
    ├── weekly/
    ├── log/
    └── archive/
```

`PLANNER_DATA` overrides the data directory (useful for testing or keeping one
clone's data elsewhere). `EDITOR` overrides the editor (default `vim`).

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

Evening, 5 minutes: fill `## Log` with what actually happened and why.

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
```

The review produces next week's focus per project. If a project has no outcome
or no movement for two weeks, pause or archive it.

## Commands

| Command | What it does |
|---|---|
| `plan init` | create data dirs and starter files |
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

## Backups

`data/` is deliberately untracked, so cloning the repo never brings old plans
along. That also means git does not back it up. Pick one:

- `rsync` or `tar` `data/` somewhere on a schedule;
- keep a second private repository that contains only `data/`;
- or remove `/data/` from `.gitignore` and commit your plans in your own fork,
  accepting that clones are no longer clean.

The repository itself is the reusable part.

## Uninstall

```bash
./uninstall.sh            # remove Vim/shell integration, keep data/
./uninstall.sh --purge    # also delete data/, with confirmation
```

## If it feels heavy

- Week 1: only `inbox.md`, `daily/`, and the Friday review. No projects, no
  time log, no script.
- Week 2: add two or three projects with an outcome and one next action each.
- Week 3: start the time log and look at `plan report week` once.
- Anything you have not used in a month, delete. The system serves you, not the
  other way around.
