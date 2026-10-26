# Documentation Index

Start here depending on what you're doing. Current docs live at the top level; plans,
audits and historical notes are grouped into subfolders.

## Start here

1. **[Architecture](architecture.md)** — how the whole thing fits together (state stack,
   autoloads, world/player, data containers). Read this first.
2. **[Current state](current_state.md)** — what's built, what's playable, what's missing
   and risky.

## Subsystems

| Topic | Doc |
| --- | --- |
| Combat (arena, turns, timing/QTE, statuses, AI, rewards) | [combat.md](combat.md) |
| Items, equipment & inventory | [items_and_inventory.md](items_and_inventory.md) |
| Quests, persistence keys, Beehave & Dialogic integration | [quests_and_persistence.md](quests_and_persistence.md) |
| Building levels, transitions, NPCs, encounter lineups | [level_authoring.md](level_authoring.md) |

## Workflow & reference

| Topic | Doc |
| --- | --- |
| Running the project, tests, conventions, known issues | [development.md](development.md) |
| API reference (signatures) | [api_reference.md](api_reference.md) |

## Plans (`plans/`)

| Topic | Doc |
| --- | --- |
| Save/load implementation plan | [plans/save_load_plan.md](plans/save_load_plan.md) |
| Porting from the old game | [plans/old_version_porting_plan.md](plans/old_version_porting_plan.md) |
| Chapter-1 items, stats, action roster (from the notes) | [plans/content_plan.md](plans/content_plan.md) |

## Audits (`audits/`)

| Topic | Doc |
| --- | --- |
| Hardcoded assumptions that affect save/load | [audits/save_load_interference_audit.md](audits/save_load_interference_audit.md) |

## Notes & history (`notes/`)

| File | Status |
| --- | --- |
| [notes/Meeting.md](notes/Meeting.md) | Team notes / current design goals. |
| [notes/some_old_notes.txt](notes/some_old_notes.txt) | Old team chat extracts (stats, types, status timing). Historical. |
| [notes/architecture_design_rough.txt](notes/architecture_design_rough.txt) | Early design scratch notes; **out of date** — superseded by [architecture.md](architecture.md). |

---

## Folder layout

```
doc/
├── README.md              this index
├── architecture.md        current architecture
├── current_state.md       snapshot / health assessment
├── development.md         running, tests, conventions, known issues
├── api_reference.md       API signatures
├── combat.md              combat system
├── items_and_inventory.md item model / inventory / equipment
├── quests_and_persistence.md  keys, quests, Beehave & Dialogic glue
├── level_authoring.md     levels, transitions, NPCs
├── plans/                 forward-looking plans
├── audits/                analysis / audits
└── notes/                 historical notes & scratch design
```

## Conventions

- Paths are project-relative (`res://...` in code, `combat/arena.gd` in prose).
- Mermaid diagrams render on GitHub and in editors that support it.
- "Not done yet" lists are honest about the gap; see [current_state.md](current_state.md)
  for the full picture.
