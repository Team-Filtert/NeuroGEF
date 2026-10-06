# Documentation Index

Start here depending on what you're doing.

### New to the codebase

1. **[Architecture](architecture.md)** — how the whole thing fits together (the state
   stack, autoloads, world/player, data containers). Read this first.
2. **[Current state](current_state.md)** — what's actually built, what's playable, what's
   missing and risky.

### Working on a subsystem

| Topic | Doc |
| --- | --- |
| Combat (arena, turns, timing/QTE, statuses, AI, rewards) | [combat.md](combat.md) |
| Items, equipment & inventory | [items_and_inventory.md](items_and_inventory.md) |
| Quests, persistence keys, Beehave & Dialogic integration | [quests_and_persistence.md](quests_and_persistence.md) |
| Building levels, transitions, NPCs, encounter lineups | [level_authoring.md](level_authoring.md) |

### Workflow

| Topic | Doc |
| --- | --- |
| Running the project, tests, conventions, known issues | [development.md](development.md) |
| API reference (signatures) | [api_reference.md](api_reference.md) |
| Porting from the old game | [old_version_porting_plan.md](old_version_porting_plan.md) |

### Design content

| Topic | Doc |
| --- | --- |
| Chapter-1 items, character stats, action roster (from the notes) | [content_plan.md](content_plan.md) |

### Reference / history

| File | Status |
| --- | --- |
| [Meeting.md](Meeting.md) | Team notes / current design goals. |
| [architecture_design_rough.txt](architecture_design_rough.txt) | Early design scratch notes; **out of date** — superseded by [architecture.md](architecture.md). |
| [some_old_notes.txt](some_old_notes.txt) | Old team chat extracts (stats, types, status timing). Historical. |

---

## Conventions used in these docs

- Paths are project-relative (`res://...` in code, `combat/arena.gd` in prose).
- Mermaid diagrams render on GitHub and in editors that support it.
- "Not done yet" lists are honest about the gap; see [current_state.md](current_state.md)
  for the full picture.
