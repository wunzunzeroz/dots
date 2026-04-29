# Obsidian Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform `~/brain` into a strategic leadership ops layer: Action→Task→Project→Initiative hierarchy, inbox-based capture, command-center overview, daily-brief transclusion, weekly/monthly/quarterly reviews, Raycast + QuickAdd capture.

**Architecture:** Layer Obsidian plugins (Tasks, Dataview, Templater, QuickAdd, Periodic Notes, Advanced URI, Iconize, Homepage, Linter) over a minimal folder structure. Daily note becomes today's working surface; `overview.md` is the pinned command center built from queries. Capture splits between Raycast (global, no pickers) and in-vault QuickAdd (pickers). Brain vault is git-tracked; Raycast scripts live in `~/dots/bin/raycast-scripts/`.

**Tech Stack:** Obsidian (local markdown), Obsidian plugins (Tasks, Dataview, Templater, QuickAdd, Periodic Notes, Advanced URI, Iconize, Homepage, Linter), Raycast Script Commands (zsh), Minimal theme (already installed), Claude Code agents (existing, for `/daily-brief` scheduling).

**Notes on test-style verification:** This plan is configuration-heavy, not code-heavy. Each task ends with a concrete verification step (reload Obsidian, trigger a hotkey, open a file, etc.) that proves the change took effect — that's the test. Where file contents are written, the full content is given literally.

**Working directories:**
- `~/brain/` — the vault (its own git repo; commit here for vault changes)
- `~/dots/bin/raycast-scripts/` — Raycast scripts (committed to `~/dots` repo)
- `~/dots/docs/superpowers/` — this plan and spec

**Spec:** `~/dots/docs/superpowers/specs/2026-04-22-obsidian-workflow-design.md` (read this first for context on every decision's rationale).

---

## Task 1: Install community plugins

**Files:**
- Modify (via Obsidian UI, which will write these): `~/brain/.obsidian/community-plugins.json`, `~/brain/.obsidian/plugins/<id>/` folders

**Context:** Obsidian plugins must be installed via the UI (Settings → Community plugins → Browse). Scripting the download is fragile; the UI is 15 seconds per plugin. All 9 plugins are listed below with their exact community-store names and IDs.

- [ ] **Step 1: Open Obsidian to the brain vault**

Open Obsidian, ensure the active vault is `brain` (at `~/brain`).

- [ ] **Step 2: Enable community plugins (if disabled)**

Settings → Community plugins → if you see "Turn on community plugins", click it.

- [ ] **Step 3: Install all 9 plugins**

Settings → Community plugins → Browse. Install (not enable yet) each of:

| Name in store | Plugin ID |
|---|---|
| Tasks | `obsidian-tasks-plugin` |
| Dataview | `dataview` |
| Templater | `templater-obsidian` |
| QuickAdd | `quickadd` |
| Periodic Notes | `periodic-notes` |
| Advanced URI | `obsidian-advanced-uri` |
| Iconize | `obsidian-icon-folder` |
| Homepage | `homepage` |
| Linter | `obsidian-linter` |

- [ ] **Step 4: Enable all 9 plugins**

Settings → Community plugins. For each installed plugin above, toggle to enabled.

- [ ] **Step 5: Enable Properties core plugin**

Settings → Core plugins → toggle "Properties view" ON.

- [ ] **Step 6: Verify all plugins loaded**

Run:
```bash
cat ~/brain/.obsidian/community-plugins.json
```
Expected: JSON array containing all 9 plugin IDs plus the 2 existing (`calendar`, `obsidian-minimal-settings`).

- [ ] **Step 7: Commit**

```bash
cd ~/brain
git add .obsidian/community-plugins.json .obsidian/core-plugins.json .obsidian/plugins/
git commit -m "feat: install task, capture, and review plugins

Tasks, Dataview, Templater, QuickAdd, Periodic Notes, Advanced URI,
Iconize, Homepage, Linter. Enables strategic leadership ops layer."
```

---

## Task 2: Create seed file structure

**Files:**
- Create: `~/brain/inbox.md`
- Create: `~/brain/overview.md`
- Create: `~/brain/initiatives/README.md`
- Create: `~/brain/initiatives/enterprise-architecture.md`
- Create: `~/brain/initiatives/data-sovereignty.md`
- Create: `~/brain/initiatives/ai-first-dev.md`
- Create: `~/brain/_TEMPLATE/` (empty folder — populated in Task 3)
- Create: `~/brain/weekly-reviews/`, `~/brain/monthly-reviews/`, `~/brain/quarterly-reviews/` (empty folders)

- [ ] **Step 1: Create `inbox.md`**

Write `~/brain/inbox.md`:
```markdown
---
status: active
last_reviewed: 2026-04-22
---

# Inbox

Default home for Tasks and loose Actions without a Project home. Reviewed weekly — target: 0 unprocessed items by Friday EOD.

## Unprocessed
<!-- Raycast ⌥I and ⌘⇧I append here. Triage weekly. -->

## Tasks — no date
<!-- Triaged Tasks without a committed date. Pull from here into daily Priorities when scheduled. -->

## Scheduled
<!-- Tasks with a 📅 date — will surface automatically in dashboards. Listed here for the weekly scan. -->
```

- [ ] **Step 2: Create `overview.md`**

Write `~/brain/overview.md`:
```markdown
---
status: active
---

# Overview — Command Center

## 🎯 Active initiatives
```dataview
TABLE status, target, owner
FROM "initiatives"
WHERE status = "active"
```

## 🔥 Overdue & due today
```tasks
not done
(due before tomorrow) OR (scheduled before tomorrow)
sort by priority
limit 20
```

## 🎯 Due this week
```tasks
not done
due after today
due before in 7 days
sort by due, priority
limit 20
```

## 🚀 Active projects
```dataview
TABLE status, initiative, next_action, target
FROM "projects"
WHERE status = "active"
SORT priority DESC, last_reviewed ASC
```

## 📥 Inbox — Tasks (no date)
```tasks
not done
path includes inbox.md
no due date
no scheduled date
sort by priority
limit 15
```

## 📒 Waiting on others
```tasks
not done
tag includes #waiting
sort by priority
```
```

- [ ] **Step 3: Create `initiatives/README.md`**

```bash
mkdir -p ~/brain/initiatives
```

Write `~/brain/initiatives/README.md`:
```markdown
---
status: active
last_reviewed: 2026-04-22
---

# Initiatives

Multi-project strategic arcs, multi-quarter horizon. Each initiative file defines a north star, rationale, linked projects, and strategic (non-tactical) moves.

## Active
```dataview
TABLE status, target, owner
FROM "initiatives"
WHERE status = "active"
```

## Format

Each initiative file: `<slug>.md` with frontmatter `status`, `owner`, `target`, `last_reviewed`. Projects link back via frontmatter `initiative: <slug>`.
```

- [ ] **Step 4: Create three initiative files**

Write `~/brain/initiatives/enterprise-architecture.md`:
```markdown
---
status: active
owner: matt
target: 
last_reviewed: 2026-04-22
---

# Enterprise Architecture

## North Star
<!-- What "done" looks like at initiative level -->

## Why now

## Projects in this initiative
```dataview
TABLE status, target, next_action
FROM "projects"
WHERE initiative = "enterprise-architecture"
```

## Strategic moves
<!-- Big, non-tactical Tasks that sit at initiative level -->
- [ ] 

## Decisions
<!-- Links to decisions/ files -->
```

Write `~/brain/initiatives/data-sovereignty.md` and `~/brain/initiatives/ai-first-dev.md` with identical structure, substituting the slug in the Dataview query (`data-sovereignty`, `ai-first-dev`) and H1 title (`Data Sovereignty`, `AI-First Dev`).

- [ ] **Step 5: Create empty review and template folders**

```bash
mkdir -p ~/brain/_TEMPLATE ~/brain/weekly-reviews ~/brain/monthly-reviews ~/brain/quarterly-reviews
touch ~/brain/weekly-reviews/.gitkeep ~/brain/monthly-reviews/.gitkeep ~/brain/quarterly-reviews/.gitkeep
```

- [ ] **Step 6: Verify in Obsidian**

Reload Obsidian (Cmd+R). In the file explorer, verify:
- `inbox.md`, `overview.md` visible at root
- `initiatives/` contains 4 files (README + 3 initiatives)
- `_TEMPLATE/`, `weekly-reviews/`, `monthly-reviews/`, `quarterly-reviews/` visible

Open `overview.md` — the Dataview queries may show "No active initiatives" or similar; that's expected since initiative frontmatter has `status: active` but Dataview needs a moment to index. Reload once more if needed.

- [ ] **Step 7: Commit**

```bash
cd ~/brain
git add inbox.md overview.md initiatives/ _TEMPLATE/ weekly-reviews/ monthly-reviews/ quarterly-reviews/
git commit -m "feat: seed storage structure (inbox, overview, initiatives, reviews)"
```

---

## Task 3: Write Templater templates

**Files:**
- Create: `~/brain/_TEMPLATE/daily-note.md`
- Create: `~/brain/_TEMPLATE/weekly-review.md`
- Create: `~/brain/_TEMPLATE/monthly-review.md`
- Create: `~/brain/_TEMPLATE/quarterly-review.md`
- Create: `~/brain/_TEMPLATE/project.md`
- Create: `~/brain/_TEMPLATE/initiative.md`
- Create: `~/brain/_TEMPLATE/decision.md`
- Create: `~/brain/_TEMPLATE/1-1-agenda.md`

**Context:** Templater executes `<% ... %>` blocks when a template is inserted. `tp.date.now("...")` formats the current date with moment.js tokens. Templates are plain markdown files with Templater tags embedded.

- [ ] **Step 1: Daily note template**

Write `~/brain/_TEMPLATE/daily-note.md`:
````markdown
---
date: <% tp.date.now("YYYY-MM-DD") %>
weekday: <% tp.date.now("dddd") %>
---

## Brief
![[daily-briefs/<% tp.date.now("YYYY-MM-DD") %>]]

## Priorities (1–3)
<!-- Tasks/Projects being advanced today. Link to home file. Today-scoped sub-actions nested. -->
1. 

## Actions
<!-- Today-only atomic one-shots. Done/promoted/killed. No bleed. -->
- [ ] 

## Notes
<!-- Meetings, thinking, capture. -->

---

## Dashboard

### 🔥 Due / overdue today
```tasks
not done
(due before tomorrow) OR (scheduled before tomorrow)
sort by priority
limit 15
```

### 🚀 Active projects — next-ups
```dataview
TABLE status, next_action, target
FROM "projects"
WHERE status = "active"
SORT priority DESC
LIMIT 10
```

### 📥 Inbox — top 10
```tasks
not done
path includes inbox.md
sort by priority
limit 10
```

### 📒 Waiting on others
```tasks
not done
tag includes #waiting
```

---

## End-of-day close
- [ ] Roll unchecked `## Actions` (tmr / inbox / kill)
- [ ] Unfinished Priorities: add progress note, roll to tmr
- [ ] Any decisions → `decisions/`
- [ ] Update radar/project files if anything shifted
````

- [ ] **Step 2: Weekly review template**

Write `~/brain/_TEMPLATE/weekly-review.md`:
````markdown
---
week: <% tp.date.now("gggg-[W]ww") %>
---

# Week <% tp.date.now("ww") %>, <% tp.date.now("gggg") %>

## What moved this week
```dataview
TASK
FROM "daily-notes" OR "projects" OR "inbox.md"
WHERE completed AND completion >= date(today) - dur(7 days)
GROUP BY file.link
```

## What slipped
```tasks
not done
(due before today) OR (scheduled before today)
limit 30
```

## Inbox triage
<!-- Target: inbox at 0. For each: do now / schedule / promote to project / delete -->
![[inbox]]

## Team
- [ ] Michael — anything outstanding? next 1:1 prep?
- [ ] Sreeman
- [ ] Joanna
- [ ] Peter
- [ ] Olly

## Projects health
```dataview
TABLE status, last_reviewed, target
FROM "projects"
WHERE status = "active"
SORT last_reviewed ASC
```

## Initiatives pulse
```dataview
TABLE status, target
FROM "initiatives"
WHERE status = "active"
```

## Next week priorities
1. 
2. 
3. 
````

- [ ] **Step 3: Monthly review template**

Write `~/brain/_TEMPLATE/monthly-review.md`:
````markdown
---
month: <% tp.date.now("YYYY-MM") %>
---

# <% tp.date.now("MMMM YYYY") %>

## Initiative progress
```dataview
TABLE status, target, last_reviewed
FROM "initiatives"
WHERE status = "active"
```

## Project portfolio (oldest-reviewed first — flag anything >60 days stale)
```dataview
TABLE status, last_reviewed, target
FROM "projects"
WHERE status = "active"
SORT last_reviewed ASC
```

## Hiring pipeline
<!-- Pull from hiring/ -->

## Quarterly goal trajectory
<!-- Pull from me/goals.md -->

## Next month priorities
1. 
2. 
3. 
````

- [ ] **Step 4: Quarterly review template**

Write `~/brain/_TEMPLATE/quarterly-review.md`:
```markdown
---
quarter: <% tp.date.now("gggg-[Q]Q") %>
---

# <% tp.date.now("YYYY [Q]Q") %>

## Strategic alignment
<!-- Are initiatives still aligned with business priorities? -->

## Initiative re-prioritization
<!-- Promote / demote / sunset / introduce -->

## Team capacity & growth
<!-- Headcount, skill gaps, promotion trajectory -->

## Big bets for next quarter
1. 
2. 
3. 
```

- [ ] **Step 5: Project template**

Write `~/brain/_TEMPLATE/project.md`:
```markdown
---
status: active
initiative: 
owner: matt
target: 
last_reviewed: <% tp.date.now("YYYY-MM-DD") %>
jira_epic: 
next_action: 
priority: 
---

# <% tp.file.title %>

## Goal
<!-- What "done" looks like -->

## Why now

## Milestones
- [ ] 

## Tasks
<!-- Ongoing Tasks. Parent `- [ ]` with nested Actions under each. -->
- [ ] 

## Decisions
<!-- Link to decisions/ files or inline small ones -->

## Links
- Jira epic: 
- RFC: 
```

- [ ] **Step 6: Initiative template**

Write `~/brain/_TEMPLATE/initiative.md`:
````markdown
---
status: active
owner: matt
target: 
last_reviewed: <% tp.date.now("YYYY-MM-DD") %>
---

# <% tp.file.title %>

## North Star
<!-- What "done" looks like at initiative level -->

## Why now

## Projects in this initiative
```dataview
TABLE status, target, next_action
FROM "projects"
WHERE initiative = "<% tp.file.title.toLowerCase().replace(/ /g, "-") %>"
```

## Strategic moves
<!-- Big, non-tactical Tasks that sit at initiative level -->
- [ ] 

## Decisions
<!-- Links to decisions/ files -->
````

- [ ] **Step 7: Decision template**

Write `~/brain/_TEMPLATE/decision.md`:
```markdown
---
date: <% tp.date.now("YYYY-MM-DD") %>
status: decided
project: 
initiative: 
---

# <% tp.file.title %>

## Context

## Decision

## Alternatives considered

## Consequences
```

- [ ] **Step 8: 1-1 agenda template**

Write `~/brain/_TEMPLATE/1-1-agenda.md`:
```markdown
# Next 1:1 agenda — <% tp.file.folder() %>

<!-- Capture prep bullets here via ⌘⇧@. Rolls into dated 1:1 file on the day. -->

## Agenda
- 

## Followups from last time
- [ ] 

## Feedback
- Positive:
- Constructive:
```

- [ ] **Step 9: Point Templater at `_TEMPLATE/`**

In Obsidian: Settings → Templater → **Template folder location**: `_TEMPLATE`.

Also enable: **Trigger Templater on new file creation** → ON (needed for Task 5's daily note auto-template).

- [ ] **Step 10: Verify templates insertable**

Cmd+P → "Templater: Open Insert Template modal" → you should see all 8 templates listed. Close without inserting.

- [ ] **Step 11: Commit**

```bash
cd ~/brain
git add _TEMPLATE/ .obsidian/plugins/templater-obsidian/
git commit -m "feat: add Templater templates (daily, reviews, project, initiative, decision, 1:1)"
```

---

## Task 4: Configure Periodic Notes

**Files:**
- Modify (via UI): `~/brain/.obsidian/plugins/periodic-notes/data.json`

**Context:** Periodic Notes wraps daily/weekly/monthly/quarterly note creation, each with its own folder, filename format, and template.

- [ ] **Step 1: Open Periodic Notes settings**

Settings → Periodic Notes.

- [ ] **Step 2: Configure Daily Notes**

In Periodic Notes settings, Daily Notes section:
- **Enabled:** ON
- **Format:** `YYYY-MM-DD`
- **Template:** `_TEMPLATE/daily-note`
- **Folder:** `daily-notes`

- [ ] **Step 3: Configure Weekly Notes**

Weekly Notes section:
- **Enabled:** ON
- **Format:** `gggg-[W]ww`
- **Template:** `_TEMPLATE/weekly-review`
- **Folder:** `weekly-reviews`

- [ ] **Step 4: Configure Monthly Notes**

Monthly Notes section:
- **Enabled:** ON
- **Format:** `YYYY-MM`
- **Template:** `_TEMPLATE/monthly-review`
- **Folder:** `monthly-reviews`

- [ ] **Step 5: Configure Quarterly Notes**

Quarterly Notes section:
- **Enabled:** ON
- **Format:** `gggg-[Q]Q`
- **Template:** `_TEMPLATE/quarterly-review`
- **Folder:** `quarterly-reviews`

- [ ] **Step 6: Disable core Daily Notes plugin**

Settings → Core plugins → Daily notes → OFF. (Periodic Notes takes over cleanly.)

- [ ] **Step 7: Verify — create today's weekly review**

Cmd+P → "Periodic Notes: Open this week's weekly note". File `weekly-reviews/2026-W17.md` (or whichever week it is) should be created from the template, Templater should expand the date tokens.

- [ ] **Step 8: Verify — create today's daily note**

Cmd+P → "Periodic Notes: Open today's daily note". File `daily-notes/2026-04-22.md` (today) should open — but it already exists as a sparse note. **Don't overwrite it** — Matt may have content. Just verify the command works; if it opens the existing file, good.

- [ ] **Step 9: Commit**

```bash
cd ~/brain
git add .obsidian/plugins/periodic-notes/ .obsidian/core-plugins.json weekly-reviews/
git commit -m "feat: configure Periodic Notes for daily/weekly/monthly/quarterly"
```

---

## Task 5: Configure QuickAdd capture flows

**Files:**
- Modify (via UI): `~/brain/.obsidian/plugins/quickadd/data.json`

**Context:** QuickAdd "Choices" are named capture flows. Each can be a Template, Capture, or Macro. We configure 8 choices mapped to hotkeys. Hotkeys are assigned separately in Obsidian's hotkey settings once each choice is named `QuickAdd: <name>`.

- [ ] **Step 1: Open QuickAdd settings**

Settings → QuickAdd.

- [ ] **Step 2: Create "Action → today" capture**

Add Choice → Capture. Name: `Action today`.
- **Capture to active file:** OFF
- **File Name:** `daily-notes/{{DATE:YYYY-MM-DD}}`
- **Create file if it doesn't exist:** ON → template: `_TEMPLATE/daily-note`
- **Capture format:** ON
- **Insert after:** `## Actions`
- **Format:**
  ```
  - [ ] {{VALUE}}
  ```

- [ ] **Step 3: Create "Inbox item" capture**

Add Choice → Capture. Name: `Inbox`.
- **File Name:** `inbox.md`
- **Capture format:** ON
- **Insert after:** `## Unprocessed`
- **Format:**
  ```
  - [ ] {{VALUE}}
  ```

- [ ] **Step 4: Create "Project Task" capture**

Add Choice → Capture. Name: `Project task`.
- **File Name:** use QuickAdd's file suggester — set to `projects/` with active project filter (`WHERE status = active`). QuickAdd will prompt for picker at invocation time.
- **Capture format:** ON
- **Insert after:** `## Tasks`
- **Format:**
  ```
  - [ ] {{VALUE}}
  ```

*Note: If QuickAdd's native suggester doesn't support an "active projects only" filter, fall back to "all projects folder" — user will pick from the full list.*

- [ ] **Step 5: Create "Person Task" capture**

Add Choice → Capture. Name: `Person task`.
- **File Name:** use suggester for `team/{folder}/README.md` OR `team/{folder}/1-1s/next-agenda.md`. QuickAdd should prompt for which person, then which file.
- **Format:**
  ```
  - [ ] {{VALUE}}
  ```

- [ ] **Step 6: Create "New Project" template**

Add Choice → Template. Name: `New project`.
- **Template:** `_TEMPLATE/project`
- **File name format:** `projects/{{VALUE}}` (prompt for slug at invocation)
- **Open the file after creation:** ON

- [ ] **Step 7: Assign hotkeys**

Settings → Hotkeys. For each QuickAdd choice above, search `QuickAdd: <name>` and bind:

| QuickAdd Choice | Hotkey |
|---|---|
| Action today | `Cmd+Shift+A` |
| Inbox | `Cmd+Shift+I` |
| Project task | `Cmd+Shift+P` |
| Person task | `Cmd+Shift+@` (may need alternative — try `Cmd+Shift+T` if `@` conflicts) |
| New project | `Cmd+Shift+N` |

Also bind these Obsidian core commands:

| Command | Hotkey |
|---|---|
| Open daily note (Periodic Notes) | `Cmd+Shift+G` |
| Open `overview.md` (via bookmarks) | `Cmd+Shift+O` |
| Open `inbox.md` (via bookmarks) | `Cmd+Shift+B` |

*Note: `Cmd+Shift+P` conflicts with Obsidian's command palette. If that's a problem, swap to `Cmd+Shift+J` (for "Project") or similar. Matt's vim bindings (jk-escape) don't conflict with modifier-prefixed hotkeys. Tune as needed.*

- [ ] **Step 8: Bookmark overview.md and inbox.md**

Open `overview.md` → Cmd+P → "Bookmarks: Bookmark current file". Repeat for `inbox.md`. Then in Hotkeys, search "Bookmarks: <file>" and bind as above.

- [ ] **Step 9: Verify Action capture**

Press `Cmd+Shift+A`. Type "test action from quickadd". Enter.

Open today's daily note. Under `## Actions`, verify: `- [ ] test action from quickadd`.

Delete the test line after verifying.

- [ ] **Step 10: Verify Inbox capture**

Press `Cmd+Shift+I`. Type "test inbox item". Enter.

Open `inbox.md`. Under `## Unprocessed`, verify: `- [ ] test inbox item`.

Delete the test line after verifying.

- [ ] **Step 11: Commit**

```bash
cd ~/brain
git add .obsidian/plugins/quickadd/ .obsidian/hotkeys.json .obsidian/bookmarks.json
git commit -m "feat: configure QuickAdd capture flows and hotkeys"
```

---

## Task 6: Configure Homepage

**Files:**
- Modify (via UI): `~/brain/.obsidian/plugins/homepage/data.json`

- [ ] **Step 1: Open Homepage settings**

Settings → Homepage.

- [ ] **Step 2: Configure**

- **Homepage:** `daily-notes/{{date}}` format — specifically, select the option "Daily Note" (uses Periodic Notes config).
- **Open on startup:** ON
- **Open in:** Default
- **Use as default for new tabs:** OFF
- **Auto-create:** ON (creates today's daily note from template on first launch of day)

- [ ] **Step 3: Verify**

Close Obsidian fully (Cmd+Q). Reopen. Obsidian should open directly to today's daily note. If today's note doesn't exist yet, it's created from the `_TEMPLATE/daily-note` template.

- [ ] **Step 4: Commit**

```bash
cd ~/brain
git add .obsidian/plugins/homepage/
git commit -m "feat: configure Homepage to auto-open today's daily note"
```

---

## Task 7: Configure Iconize folder icons

**Files:**
- Modify (via UI): `~/brain/.obsidian/plugins/obsidian-icon-folder/data.json`

**Context:** Iconize lets you assign Lucide/Remix icons per folder for faster visual scanning in the file tree.

- [ ] **Step 1: Open Iconize settings**

Settings → Iconize. No global config needed — icons are set via right-click on folders.

- [ ] **Step 2: Assign folder icons**

In file explorer, right-click each folder → "Change icon" → pick from Lucide:

| Folder | Icon name |
|---|---|
| `initiatives` | `target` |
| `projects` | `rocket` |
| `team` | `users` |
| `hiring` | `user-plus` |
| `stakeholders` | `handshake` |
| `business` | `briefcase` |
| `product` | `package` |
| `tech` | `cpu` |
| `me` | `user` |
| `daily-notes` | `calendar-days` |
| `daily-briefs` | `newspaper` |
| `weekly-reviews` | `calendar-range` |
| `monthly-reviews` | `calendar` |
| `quarterly-reviews` | `calendar-clock` |
| `decisions` | `gavel` |
| `_TEMPLATE` | `file-code` |

Also assign emoji/icons to these root files:
| File | Icon |
|---|---|
| `inbox.md` | `inbox` |
| `overview.md` | `layout-dashboard` |
| `radar.md` | `radar` (will be deleted in Task 10 — skip if radar.md no longer exists) |
| `tools.md` | `wrench` |
| `processes.md` | `workflow` |

- [ ] **Step 3: Verify**

Visually scan the file tree — every folder and key root file should have an icon.

- [ ] **Step 4: Commit**

```bash
cd ~/brain
git add .obsidian/plugins/obsidian-icon-folder/
git commit -m "feat: assign folder and file icons via Iconize"
```

---

## Task 8: Configure Linter

**Files:**
- Modify (via UI): `~/brain/.obsidian/plugins/obsidian-linter/data.json`

**Context:** Linter enforces frontmatter consistency, YAML format, and whitespace rules on save. Keeps Dataview queries working reliably.

- [ ] **Step 1: Open Linter settings**

Settings → Linter.

- [ ] **Step 2: Enable core rules**

- **Lint on save:** ON
- **Display message when file changed:** OFF

- [ ] **Step 3: Configure YAML rules**

Under YAML tab, enable:
- **YAML Key Sort** — keep `status`, `date`, `owner`, `target`, `last_reviewed` at top
- **YAML Timestamp** — update `last_modified` (if present) on save
- **Format YAML Array** — single-line for short arrays

- [ ] **Step 4: Configure spacing rules**

Under Spacing tab:
- **Trailing spaces** — remove
- **Consecutive blank lines** — max 2
- **Empty line around headings** — ON

- [ ] **Step 5: Disable aggressive rules**

Do NOT enable:
- Auto-correct common misspellings (noisy)
- Heading level enforcement (we use flexible headings)
- Auto-add metadata to every file (adds bloat)

- [ ] **Step 6: Verify**

Open `inbox.md`, add two trailing blank lines at the end, save. Linter should trim to one. Add a trailing space after a word, save — should be removed.

- [ ] **Step 7: Commit**

```bash
cd ~/brain
git add .obsidian/plugins/obsidian-linter/
git commit -m "feat: configure Linter for frontmatter and whitespace"
```

---

## Task 9: Configure Tasks and Dataview plugins

**Files:**
- Modify (via UI): `~/brain/.obsidian/plugins/obsidian-tasks-plugin/data.json`
- Modify (via UI): `~/brain/.obsidian/plugins/dataview/data.json`

- [ ] **Step 1: Tasks plugin settings**

Settings → Tasks.

- **Global filter:** leave blank (all tasks)
- **Global query:** leave blank
- **Appearance → Priority:** Enable 🔺 (Highest), 🔼 (High), 🔽 (Low), ⏬ (Lowest)
- **Dates → Set created date on creation:** OFF (captured timestamp handles it)
- **Dates → Set done date on completion:** ON
- **Recurrence → Next date:** Next occurrence based on today (not scheduled date)
- **Statuses:** keep defaults (`[ ]`, `[x]`, `[-]` cancelled, `[/]` in progress)

- [ ] **Step 2: Dataview settings**

Settings → Dataview.

- **Enable JavaScript Queries:** ON (needed for any complex rollups)
- **Enable inline JavaScript queries:** ON
- **Automatic View Refreshing:** ON (every 2500ms is fine)
- **Task completion tracking:** ON
- **Use emoji shorthand for completion tracking:** ON (so `✅ date` works)
- **Enable Bases interop (if setting exists):** ON

- [ ] **Step 3: Verify**

Open `overview.md`. The Dataview and Tasks query blocks should render results (even if empty). If you see raw code blocks instead of rendered tables, Dataview isn't indexing — try Cmd+P → "Dataview: Force refresh all views".

- [ ] **Step 4: Commit**

```bash
cd ~/brain
git add .obsidian/plugins/obsidian-tasks-plugin/ .obsidian/plugins/dataview/
git commit -m "feat: tune Tasks and Dataview plugin settings"
```

---

## Task 10: Migrate `radar.md` to `inbox.md`

**Files:**
- Modify: `~/brain/inbox.md`
- Delete: `~/brain/radar.md`
- Modify: `~/brain/CLAUDE.md` (remove radar reference)

**Context:** `radar.md` content is "things on my mind" — a mix of Tasks and Actions without homes. That's exactly what `inbox.md` is for now. Triage each line: keep as-is (goes to Unprocessed or Tasks-no-date), promote to a Project file, delete if obsolete.

- [ ] **Step 1: Read current `radar.md`**

```bash
cat ~/brain/radar.md
```

Note the content — 7 bullet groups as of last check: Admiral, Architecture diagram, Tempo timesheets, Subscription expenses, Engineering billing, V1 vs V2 app store stats, Claude automatic bugfix PRs.

- [ ] **Step 2: Triage decisions**

For each top-level bullet, decide:

| Item | Action |
|---|---|
| Update Admiral with additional functionality | Task → `inbox.md` Tasks-no-date (could become a Project later) |
| Architecture diagram | Task → `inbox.md` Tasks-no-date |
| Using Tempo timesheets properly | Task → `inbox.md` Tasks-no-date |
| Subscription expenses | Task → `inbox.md` Tasks-no-date |
| Engineering billing | Task → `inbox.md` Tasks-no-date |
| V1 vs V2 app store stats | Action → could go to existing project `v1-turnoff.md` under Tasks, if it's V1-Turnoff related. Otherwise Tasks-no-date. |
| Claude automatic bugfix PRs | Task → `inbox.md` Tasks-no-date, tag `#initiative-ai-first-dev` (could promote to ai-first-dev initiative's strategic moves) |

*Execute the triage — Matt may prefer different targets for some items. Pause and ask if the executor is not Matt.*

- [ ] **Step 3: Append triaged items to `inbox.md`**

Edit `~/brain/inbox.md`. Under `## Tasks — no date`, append each item as a checkbox, preserving any nested sub-actions:

Example:
```markdown
## Tasks — no date
- [ ] Update Admiral with additional functionality
- [ ] Architecture diagram
- [ ] Using Tempo timesheets properly
- [ ] Subscription expenses
- [ ] Engineering billing
- [ ] V1 vs V2 app store stats
- [ ] Claude automatic bugfix PRs
    - [ ] Investigate routines
    - [ ] Setup bugfix workflow
```

- [ ] **Step 4: Delete `radar.md`**

```bash
rm ~/brain/radar.md
```

- [ ] **Step 5: Remove radar reference from `CLAUDE.md`**

Edit `~/brain/CLAUDE.md`. Find the row in the Areas table:
```markdown
| Radar | `radar.md` | Things on my mind — not yet full projects |
```

Replace with:
```markdown
| Inbox | `inbox.md` | Unprocessed tasks and loose actions without a project home |
```

Also update any other references in the file — do a full-text search for `radar` and adjust.

- [ ] **Step 6: Verify**

Open `inbox.md` in Obsidian — all 7 items present. Open `overview.md` — "Inbox Tasks (no date)" section shows them.

- [ ] **Step 7: Commit**

```bash
cd ~/brain
git add inbox.md CLAUDE.md
git rm radar.md
git commit -m "refactor: migrate radar.md to inbox.md and update router"
```

---

## Task 11: Extend project frontmatter

**Files:**
- Modify: `~/brain/projects/*.md`
- Modify: `~/brain/projects/README.md`

**Context:** Existing projects have minimal frontmatter. We extend to match the Project template (status, initiative, owner, target, last_reviewed, jira_epic, next_action, priority).

- [ ] **Step 1: List existing projects**

```bash
ls ~/brain/projects/*.md
```

Expected: `README.md`, `v1-turnoff.md`, plus any others.

- [ ] **Step 2: Update `v1-turnoff.md` frontmatter**

Edit `~/brain/projects/v1-turnoff.md`. Ensure frontmatter is:
```yaml
---
status: active
initiative: enterprise-architecture
owner: matt
target: 
last_reviewed: 2026-04-22
jira_epic: 
next_action: 
priority: 1
---
```

*Keep existing body content untouched.* If `target` is known, fill it.

- [ ] **Step 3: Update any other existing project files**

For each `projects/*.md` that isn't `README.md`, add/extend frontmatter to match the above shape. Set `status` based on reality (`active`, `paused`, `done`, `planned`). Leave `initiative` blank or fill if clear.

- [ ] **Step 4: Update `projects/README.md`**

Edit `~/brain/projects/README.md`. Replace the "Active" section with:
```markdown
## Active
```dataview
TABLE status, initiative, target, next_action
FROM "projects"
WHERE status = "active"
SORT priority DESC
```

## Paused
```dataview
TABLE status, last_reviewed
FROM "projects"
WHERE status = "paused"
```

## Done
```dataview
TABLE status, last_reviewed
FROM "projects"
WHERE status = "done"
```
```

- [ ] **Step 5: Verify**

Open `projects/README.md` — the Active table shows at least `v1-turnoff` with correct frontmatter fields. Open `initiatives/enterprise-architecture.md` — its Projects query now shows `v1-turnoff`.

- [ ] **Step 6: Commit**

```bash
cd ~/brain
git add projects/
git commit -m "refactor: extend project frontmatter (status, initiative, owner, target, etc)"
```

---

## Task 12: Create Raycast capture scripts

**Files:**
- Create: `~/dots/bin/raycast-scripts/brain-action.sh`
- Create: `~/dots/bin/raycast-scripts/brain-inbox.sh`
- Create: `~/dots/bin/raycast-scripts/brain-brief.sh`
- Modify (via UI): Raycast preferences — add script directory, assign hotkeys

**Context:** Raycast Script Commands are shell scripts with a header comment block that Raycast parses. They run when invoked via the Raycast bar. Arguments prompt the user for input. Scripts here do direct file writes to the vault — simpler and faster than Obsidian Advanced URI for append-only operations.

- [ ] **Step 1: Create script directory**

```bash
mkdir -p ~/dots/bin/raycast-scripts
```

- [ ] **Step 2: Write `brain-action.sh`**

Write `~/dots/bin/raycast-scripts/brain-action.sh`:
```bash
#!/bin/zsh

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Brain — Action (today)
# @raycast.mode compact
# @raycast.packageName Brain

# Optional parameters:
# @raycast.icon ✅
# @raycast.argument1 { "type": "text", "placeholder": "Action" }
# @raycast.description Append an action to today's daily note
# @raycast.author Matt Chapman

set -euo pipefail

text="$1"
vault="$HOME/brain"
today="$(date +%Y-%m-%d)"
file="$vault/daily-notes/$today.md"
template="$vault/_TEMPLATE/daily-note.md"
ts="$(date +%Y-%m-%dT%H:%M)"

# Parse priority prefixes (! !! !!!)
priority=""
if [[ "$text" == "!!! "* ]]; then priority="⏬"; text="${text#!!! }"; fi
if [[ "$text" == "!! "* ]]; then priority="🔼"; text="${text#!! }"; fi
if [[ "$text" == "! "* ]]; then priority="🔺"; text="${text#! }"; fi

# Parse due date prefix (d:mon, d:2026-04-28, d:+3)
due=""
if [[ "$text" =~ ^d:([^ ]+)\ (.*)$ ]]; then
  raw="${match[1]}"
  text="${match[2]}"
  case "$raw" in
    +*)
      days="${raw#+}"
      due="$(date -v+${days}d +%Y-%m-%d)"
      ;;
    mon|tue|wed|thu|fri|sat|sun)
      due="$(date -v+1d -v"${raw}" +%Y-%m-%d 2>/dev/null || date +%Y-%m-%d)"
      ;;
    *)
      due="$raw"
      ;;
  esac
fi

# Build task line
line="- [ ] $text"
[[ -n "$priority" ]] && line="$line $priority"
[[ -n "$due" ]] && line="$line 📅 $due"
line="$line <!-- captured $ts -->"

# Create file from template if missing
if [[ ! -f "$file" ]]; then
  mkdir -p "$(dirname "$file")"
  # Expand template date tokens manually (Templater won't run from CLI)
  sed -e "s/<% tp.date.now(\"YYYY-MM-DD\") %>/$today/g" \
      -e "s/<% tp.date.now(\"dddd\") %>/$(date +%A)/g" \
      "$template" > "$file"
fi

# Append under ## Actions heading
awk -v line="$line" '
  /^## Actions$/ { print; in_actions=1; next }
  in_actions && /^## / && !/^## Actions$/ { print line; in_actions=0 }
  { print }
  END { if (in_actions) print line }
' "$file" > "$file.tmp" && mv "$file.tmp" "$file"

echo "Added to today's Actions: $text"
```

- [ ] **Step 3: Write `brain-inbox.sh`**

Write `~/dots/bin/raycast-scripts/brain-inbox.sh`:
```bash
#!/bin/zsh

# @raycast.schemaVersion 1
# @raycast.title Brain — Inbox
# @raycast.mode compact
# @raycast.packageName Brain
# @raycast.icon 📥
# @raycast.argument1 { "type": "text", "placeholder": "Inbox item" }
# @raycast.description Append an item to the inbox
# @raycast.author Matt Chapman

set -euo pipefail

text="$1"
vault="$HOME/brain"
file="$vault/inbox.md"
ts="$(date +%Y-%m-%dT%H:%M)"

# Same priority/date prefix parsing as brain-action.sh
priority=""
if [[ "$text" == "!!! "* ]]; then priority="⏬"; text="${text#!!! }"; fi
if [[ "$text" == "!! "* ]]; then priority="🔼"; text="${text#!! }"; fi
if [[ "$text" == "! "* ]]; then priority="🔺"; text="${text#! }"; fi

due=""
if [[ "$text" =~ ^d:([^ ]+)\ (.*)$ ]]; then
  raw="${match[1]}"
  text="${match[2]}"
  case "$raw" in
    +*)
      days="${raw#+}"
      due="$(date -v+${days}d +%Y-%m-%d)"
      ;;
    mon|tue|wed|thu|fri|sat|sun)
      due="$(date -v+1d -v"${raw}" +%Y-%m-%d 2>/dev/null || date +%Y-%m-%d)"
      ;;
    *)
      due="$raw"
      ;;
  esac
fi

line="- [ ] $text"
[[ -n "$priority" ]] && line="$line $priority"
[[ -n "$due" ]] && line="$line 📅 $due"
line="$line <!-- captured $ts -->"

# Append under ## Unprocessed heading
awk -v line="$line" '
  /^## Unprocessed$/ { print; in_section=1; next }
  in_section && /^## / && !/^## Unprocessed$/ { print line; in_section=0 }
  { print }
  END { if (in_section) print line }
' "$file" > "$file.tmp" && mv "$file.tmp" "$file"

echo "Added to inbox: $text"
```

- [ ] **Step 4: Write `brain-brief.sh`**

Write `~/dots/bin/raycast-scripts/brain-brief.sh`:
```bash
#!/bin/zsh

# @raycast.schemaVersion 1
# @raycast.title Brain — Generate today's brief
# @raycast.mode fullOutput
# @raycast.packageName Brain
# @raycast.icon 📰
# @raycast.description Run /daily-brief on-demand
# @raycast.author Matt Chapman

set -euo pipefail

cd "$HOME/brain"
# Invoke Claude Code CLI with the daily-brief skill
claude --skill daily-brief 2>&1
```

*Note: the exact Claude Code CLI invocation to trigger a skill may need adjustment depending on Matt's Claude Code version. If `--skill` isn't the right flag, use `claude` interactively or adjust per docs.*

- [ ] **Step 5: Make scripts executable**

```bash
chmod +x ~/dots/bin/raycast-scripts/brain-*.sh
```

- [ ] **Step 6: Add script directory to Raycast**

Open Raycast preferences (`⌘,` from Raycast).
- Extensions tab → Script Commands → **+ Add Directory** → select `~/dots/bin/raycast-scripts/`.
- All three scripts should appear.

- [ ] **Step 7: Assign Raycast hotkeys**

In Raycast preferences, for each script, click into it and set:

| Script | Hotkey |
|---|---|
| Brain — Action (today) | `⌥A` |
| Brain — Inbox | `⌥I` |
| Brain — Generate today's brief | `⌥B` |

*If these conflict with existing macOS/app shortcuts, use `⌥⌘A`, `⌥⌘I`, `⌥⌘B` or similar.*

- [ ] **Step 8: Verify Action script**

Press `⌥A` (outside Obsidian — e.g., from a browser). Raycast prompts. Type `test raycast action`. Enter.

```bash
grep "test raycast action" ~/brain/daily-notes/$(date +%Y-%m-%d).md
```
Expected: one match showing the checkbox line with the captured timestamp comment.

Delete the test line:
```bash
sed -i '' '/test raycast action/d' ~/brain/daily-notes/$(date +%Y-%m-%d).md
```

- [ ] **Step 9: Verify Inbox script**

Press `⌥I`. Type `test raycast inbox`. Enter.

```bash
grep "test raycast inbox" ~/brain/inbox.md
```
Expected: one match under `## Unprocessed`.

Delete the test line.

- [ ] **Step 10: Verify priority parsing**

Press `⌥A`. Type `!! urgent test action`. Enter.

```bash
grep "urgent test action" ~/brain/daily-notes/$(date +%Y-%m-%d).md
```
Expected: line contains `🔼` (from `!!` parse) and does NOT contain literal `!!`.

Delete the test line.

- [ ] **Step 11: Commit**

```bash
cd ~/dots
git add bin/raycast-scripts/
git commit -m "feat(raycast): add brain capture scripts for action, inbox, brief"
```

---

## Task 13: Schedule the daily brief

**Files:**
- Create: `~/brain/projects/daily-brief-agent.json` (or equivalent depending on your scheduled agent tooling)

**Context:** Matt already has scheduled agents (`standup-bot-agent.json`, `weekly-summary-agent.json`). The daily-brief follows the same pattern — a Claude Code scheduled trigger that runs `/daily-brief` at 7:00am daily.

- [ ] **Step 1: Inspect existing scheduled agent format**

```bash
cat ~/brain/projects/standup-bot-agent.json
cat ~/brain/projects/weekly-summary-agent.json
```

Note the JSON shape — cron schedule, skill/command invoked, any metadata.

- [ ] **Step 2: Create `daily-brief-agent.json`**

Write `~/brain/projects/daily-brief-agent.json` following the exact same shape as `standup-bot-agent.json`, substituting:
- schedule: `0 7 * * *` (7:00am every day)
- command/skill: `/daily-brief` or equivalent
- output destination: `daily-briefs/` folder (existing behavior — should already be what the skill does)

*Match the exact schema your other agents use — do not invent fields.*

- [ ] **Step 3: Register the agent**

Use the same mechanism you registered the others. If it's via the `schedule` skill (`~/.claude/plugins/...`), run that from the brain directory.

- [ ] **Step 4: Verify**

List scheduled agents (however you normally do — `schedule list` or equivalent). Confirm `daily-brief-agent` appears with 7am schedule.

- [ ] **Step 5: Smoke test**

Run the brief manually once:
```bash
cd ~/brain
claude --skill daily-brief
```
or invoke via `⌥B` Raycast.

Verify: `~/brain/daily-briefs/$(date +%Y-%m-%d).md` is created/updated, content is a real brief.

Open today's daily note in Obsidian — the `## Brief` transclusion should render the brief inline.

- [ ] **Step 6: Commit**

```bash
cd ~/brain
git add projects/daily-brief-agent.json
git commit -m "feat: schedule daily-brief agent for 7am daily runs"
```

---

## Task 14: Verify full workflow end-to-end

**Context:** Smoke-test the whole system. No files change — this is a runtime verification pass.

- [ ] **Step 1: Fresh open verification**

Quit Obsidian (`⌘Q`). Reopen. Expected:
- Obsidian opens today's daily note automatically (Homepage)
- Brief transclusion renders at top (if brief file exists)
- Dashboard queries render with current state

- [ ] **Step 2: Capture round-trip**

From outside Obsidian: `⌥A`, type "e2e test action today", Enter. Switch to Obsidian (no reload needed — Obsidian watches the file). Verify the line appears under `## Actions`.

- [ ] **Step 3: Inbox round-trip**

`⌥I`, type "e2e inbox test item", Enter. Open `inbox.md`. Verify under `## Unprocessed`.

- [ ] **Step 4: Project task via picker**

In Obsidian: `⌘⇧P`. Pick `v1-turnoff`. Type "e2e project task test". Enter. Open `projects/v1-turnoff.md`. Verify under `## Tasks`.

- [ ] **Step 5: Priority parsing**

`⌥A`, type `! priority high test`, Enter. Open today's daily note. Line should contain `🔺`.

- [ ] **Step 6: Date parsing**

`⌥I`, type `d:+2 test task in 2 days`, Enter. Open `inbox.md`. Line should contain `📅 YYYY-MM-DD` where the date is today+2.

- [ ] **Step 7: Dashboard reflects captures**

Open `overview.md`. The test task from Step 6 should appear under "🎯 Due this week" (since it's due in 2 days).

- [ ] **Step 8: Clean up test entries**

Delete all lines containing "e2e test", "priority high test", "test task in 2 days" from: today's daily note, inbox.md, v1-turnoff.md.

- [ ] **Step 9: Periodic Notes verification**

`⌘P` → "Periodic Notes: Open this week's weekly note". Weekly review note should open/create from template. Queries at top render this week's completed tasks.

- [ ] **Step 10: Overview accuracy**

Open `overview.md`. Verify:
- Active initiatives section shows 3 rows (enterprise-architecture, data-sovereignty, ai-first-dev)
- Active projects section shows at least `v1-turnoff`
- Inbox section shows the 7 migrated items from Task 10

- [ ] **Step 11: Commit any residual changes**

```bash
cd ~/brain
git status
# If there are any workspace.json or similar changes from tab state:
git add .obsidian/workspace.json 2>/dev/null || true
git commit -m "chore: update workspace after e2e verification" 2>/dev/null || true
```

---

## Task 15: Write user-facing README

**Files:**
- Create or modify: `~/brain/README.md`

**Context:** A cheat-sheet for Matt (and future-Claude-Code) explaining how to use the new system. Not a spec — a quick reference.

- [ ] **Step 1: Write `~/brain/README.md`**

```markdown
---
status: active
last_reviewed: 2026-04-22
---

# Brain — How to use this

Matt's strategic leadership ops vault. Scope: drafting, deciding, reviewing, coordinating. **Not Jira.** Not personal life.

## The hierarchy

Action (atomic) → Task (multi-action) → Project (its own file) → Initiative (strategic arc).

Capture into the smallest viable home. Promote as it grows.

## Where things live

| Kind | Home |
|---|---|
| Today's work | `daily-notes/YYYY-MM-DD.md` |
| Unprocessed / no-home Tasks and Actions | `inbox.md` |
| Project (outcome with multiple tasks) | `projects/<slug>.md` |
| Initiative (multi-project strategic arc) | `initiatives/<slug>.md` |
| Person-specific Tasks | `team/<person>/README.md` or `team/<person>/1-1s/next-agenda.md` |
| Decision + rationale | `decisions/YYYY-MM-DD-<topic>.md` |
| Command center (pinned view) | `overview.md` |

## Capture — one keystroke

**Outside Obsidian (Raycast):**
| Hotkey | What | Where |
|---|---|---|
| `⌥A` | Action for today | `daily-notes/<today>.md` → `## Actions` |
| `⌥I` | Inbox item | `inbox.md` → `## Unprocessed` |
| `⌥B` | Generate today's brief on-demand | `daily-briefs/<today>.md` |

Prefix tricks (optional):
- `! text` → 🔺 highest / `!! text` → 🔼 high / `!!! text` → ⏬ lowest
- `d:+3 text` / `d:2026-05-01 text` / `d:mon text` → sets due date

**Inside Obsidian (QuickAdd):**
| Hotkey | What |
|---|---|
| `⌘⇧A` | Action for today |
| `⌘⇧I` | Inbox item |
| `⌘⇧P` | New Task in a project (picker) |
| `⌘⇧@` | New Task for a person (picker) |
| `⌘⇧N` | New Project (from template) |
| `⌘⇧G` | Go to today's daily note |
| `⌘⇧O` | Open overview |
| `⌘⇧B` | Open inbox |

## Daily loop

- **Morning (5–10min):** Obsidian opens to today's daily note. Brief is transcluded at top. Write 1–3 Priorities. Glance dashboard.
- **Through the day:** Capture via Raycast. Update Priority sub-actions as you work.
- **End of day (3min):** Triage `## Actions` (roll / inbox / kill). Roll unfinished Priorities with a progress note.

## Weekly / monthly / quarterly

- **Friday afternoon:** open this week's review (`⌘P` → "Periodic Notes: Open this week's..."). Target: inbox at 0 by EOD.
- **First Monday of month:** monthly review.
- **Start of quarter:** quarterly review.

## Priorities vs Actions

Daily note has both:

- **Priorities** = Tasks or Projects you're **advancing today**. Links to where they actually live. Today-scoped sub-actions nested. They bleed across days — the underlying Task/Project persists.
- **Actions** = atomic one-shots for today only. Done, promoted, or killed by EOD. No bleed.

## Dashboards

- `overview.md` — the full picture, all open actionable work.
- Daily note `## Dashboard` — today-filtered slice (due today, project next-ups, top inbox, waiting).

## Where NOT to put stuff

- Engineering execution work → Jira
- Personal life admin → whatever you use (Todoist, etc)
- Shared team docs → Confluence / Google Drive

## See also

- `CLAUDE.md` — router for Claude Code
- `docs/superpowers/specs/2026-04-22-obsidian-workflow-design.md` (in `~/dots`) — full design rationale
```

- [ ] **Step 2: Verify**

Open `~/brain/README.md` in Obsidian. Renders cleanly.

- [ ] **Step 3: Commit**

```bash
cd ~/brain
git add README.md
git commit -m "docs: add user-facing README cheat sheet"
```

---

## Task 16: Update CLAUDE.md router

**Files:**
- Modify: `~/brain/CLAUDE.md`

**Context:** The CLAUDE.md router currently references `Radar | radar.md | ...`. Task 10 already swapped that to Inbox. This task adds `initiatives/` and `overview.md` to the Areas table and tightens the Conventions section to reflect the new task model.

- [ ] **Step 1: Read current CLAUDE.md**

```bash
cat ~/brain/CLAUDE.md
```

- [ ] **Step 2: Update Areas table**

Edit `~/brain/CLAUDE.md`. In the Areas table, replace the existing list with:

```markdown
| Area | Path | When to read |
|------|------|--------------|
| Overview | `overview.md` | Quick command center — open tasks, active projects, active initiatives |
| Me | `me/` | Performance reviews, role context, goals |
| Business | `business/` | Market, ICP, competitors, strategy, commercial |
| Product | `product/` | Roadmap, features, backlog, releases |
| Tech | `tech/` | Repos, tech stack, architecture, infra |
| Team | `team/` | 1:1s, perf tracking, team planning |
| Hiring | `hiring/` | JDs, pipeline, headcount, interview process |
| Stakeholders | `stakeholders/` | Cross-functional work, key relationships, RACI |
| Tools | `tools.md` | Slack channels, Jira boards, key URLs |
| Processes | `processes.md` | Sprint cadence, rituals, how we operate |
| Initiatives | `initiatives/` | Multi-quarter strategic arcs |
| Projects | `projects/` | Project-level strategic work, spanning sprints |
| Inbox | `inbox.md` | Unprocessed Tasks/Actions without a project home |
| Decisions | `decisions/` | Past decisions and rationale |
| Daily notes | `daily-notes/` | Per-day working surface (priorities, actions, notes) |
| Daily briefs | `daily-briefs/` | AI-generated morning brief (read-only source for daily note transclusion) |
| Weekly / Monthly / Quarterly reviews | `weekly-reviews/`, `monthly-reviews/`, `quarterly-reviews/` | Retrospective / planning content |
```

- [ ] **Step 3: Add task model section**

Below the Areas table, insert a new section before Conventions:

```markdown
## Task model

Four levels:

- **Action** — atomic one-shot (`- [ ]`). Lives in today's daily note `## Actions` or nested under a Task/Project.
- **Task** — multi-action, no need for own file. Lives in `inbox.md`, a project file, or a person's file.
- **Project** — multi-task, outcome, own file in `projects/`. Has frontmatter `status`, `initiative`, `owner`, `target`, `last_reviewed`.
- **Initiative** — multi-project strategic arc, own file in `initiatives/`. Projects link back via `initiative: <slug>`.

**Priorities vs Actions in the daily note:**
- `## Priorities` lists 1–3 Tasks/Projects being advanced today (links to home files). Can bleed across days.
- `## Actions` lists today-only atomic one-shots. Do not bleed.

**Scope boundary:** This system covers Matt's strategic leadership work — drafting, deciding, reviewing, coordinating. It does **not** cover engineering execution (that's Jira) or personal life admin.
```

- [ ] **Step 4: Update Conventions**

In the Conventions section, append:

```markdown
- **Frontmatter conventions:**
  - Projects: `status`, `initiative`, `owner`, `target`, `last_reviewed`, optional `jira_epic`, optional `next_action`, optional `priority`
  - Initiatives: `status`, `owner`, `target`, `last_reviewed`
  - Daily/weekly/monthly/quarterly notes: `date`/`week`/`month`/`quarter`
- **Capture routing:** Raycast `⌥A` → daily note; `⌥I` → inbox. In-vault `⌘⇧A/I/P/@/N` → respective destinations via QuickAdd.
- **Task queries:** Tasks plugin for pure task queries, Dataview for cross-file aggregation, Bases for polished registers.
```

- [ ] **Step 5: Verify**

Re-read `~/brain/CLAUDE.md`. All references to `radar` should be gone. New sections render correctly in Obsidian preview.

- [ ] **Step 6: Commit**

```bash
cd ~/brain
git add CLAUDE.md
git commit -m "docs: update CLAUDE.md router for new structure and task model"
```

---

## Self-Review

**Spec coverage:**
- Purpose + scope → Task 15 (README), Task 16 (CLAUDE.md)
- Task hierarchy (Action→Task→Project→Initiative) → Tasks 2, 3, 10, 11, 15, 16
- Storage layout (inbox, overview, initiatives, projects, team, daily/weekly/monthly/quarterly) → Tasks 2, 4, 11
- Views (overview.md, daily note dashboard) → Tasks 2, 3, 9
- Priorities vs Actions model → Tasks 3 (template), 15 (README), 16 (CLAUDE.md)
- Raycast capture (⌥A, ⌥I, ⌥B) → Task 12
- In-vault QuickAdd capture (⌘⇧A/I/P/@/N/G/O/B) → Task 5
- Daily-brief transclusion + scheduling → Tasks 3 (template), 13 (schedule)
- Review cadence (daily/weekly/monthly/quarterly) → Tasks 3, 4
- Plugins (9 essentials + settings) → Tasks 1, 4, 5, 6, 7, 8, 9
- Templates (8 of them) → Task 3
- `inbox.md` and `overview.md` structures → Task 2
- radar.md migration → Task 10
- Project frontmatter extension → Task 11
- Initiative files with 3 slugs → Task 2
- User-facing documentation → Tasks 15, 16

All spec requirements have at least one task.

**Placeholder scan:**
- Task 5 Step 4 Note about picker filter fallback — this is contextual guidance, not a placeholder
- Task 5 Step 7 Note about hotkey conflicts — same
- Task 12 Step 4 Note about Claude CLI flag — honest uncertainty flagged, with fallback behavior specified
- Task 13 Step 2 "Match the exact schema your other agents use — do not invent fields" — correct guidance, not a placeholder; the executor reads the existing JSON first
- Task 10 Step 2 triage table — explicit decisions, not placeholders

No placeholders remaining.

**Type consistency:**
- Frontmatter field names are consistent across tasks: `status`, `initiative`, `owner`, `target`, `last_reviewed`, `jira_epic`, `next_action`, `priority`
- Hotkey assignments are consistent between Task 5 (QuickAdd) and Task 15 (README) and Task 16 (CLAUDE.md)
- Heading names consistent: `## Actions`, `## Unprocessed`, `## Tasks`, `## Priorities`, `## Brief`, `## Dashboard`

No type inconsistencies.

---

## Execution Order Notes

Tasks 1–2 are foundation (plugins + seed files). Tasks 3–9 configure the plugins. Tasks 10–11 migrate existing content. Task 12 adds the Raycast layer. Task 13 schedules the brief. Task 14 is end-to-end verification. Tasks 15–16 finalize user-facing documentation.

Parallelizable: Tasks 3 (templates) and 12 (Raycast scripts) don't depend on each other after Task 1. All others are sequential.
