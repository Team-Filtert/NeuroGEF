# Save / Load — Implementation Plan

Short plan for persisting overworld progress. Nothing here is implemented yet.

## Goal

Save the game to numbered slots **only at save points placed in the world**, and restore
the player exactly where they saved.

## When you can save

Saving is **checkpoint-based — there is no save-anywhere menu or hotkey.**

- A **save point** is an interactable placed in levels. Interacting with it writes the
  save. This is the *only* way to save.
- The **main menu** can still start a new game and load any existing slot.
- `SaveManager.save_to_slot()` is only ever called by a save point. It still refuses while
  in combat as a defensive check, but there is no other caller.

## What gets saved

| Part | Source | Notes |
| --- | --- | --- |
| Party | `GameState.party.to_dict()` | stats, HP/MP, level/xp, action paths, equipment paths — already exists |
| Inventory | `GameState.inventory.to_dict()` | money + item stacks (by resource path) — already exists |
| Keys | `GameState.keys.get_all()` | all persistence flags/counters — already exists |
| Quests | `QuestManager` | **needs `to_dict`/`from_dict`** (store quest resource paths) |
| World | level scene path + save-point id | player respawns at the save point |

**Not saved:** active combat, transitions, enemies, settings. `GameSettings` already
persists itself; combat is transient.

Because saves happen at a save point, the world is stored as **which level and which save
point**, not the player's arbitrary position — so loading always puts the player back on the
checkpoint (and survives small level edits).

## Slot file shape

```gdscript
{
    "version": 1,
    "saved_at": "2026-10-06T21:00:00",
    "world": {
        "scene": "res://levels/ch1/neuros_home/neuro_room.tscn",
        "save_point_id": "neuro_room_bed",
    },
    "party": <Party.to_dict()>,
    "inventory": <Inventory.to_dict()>,
    "keys": <PersistenceKeys.get_all()>,
    "quests": <QuestManager.to_dict()>,
}
```

Write it with `var_to_str` / `str_to_var` to `user://saves/slot_N.save` (preserves
`int` vs `float`, unlike JSON). JSON is fine too if numbers are coerced on load.

## Prerequisites (small additions)

1. **`QuestManager.to_dict()/from_dict()`** — map entries to `quest.resource_path`; rebuild
   with `load(path)`, skipping missing files. Completion stays derived from keys, so no
   extra state.
2. **`GameState.reset()`** — replace `party`/`inventory`/`keys`/`quests` with fresh
   instances (used by New Game).
3. **`LevelManager.current_level_path()`** — expose the `_current_level` scene path (store
   it in `change_level`).
4. **Restore at a save point** — add `LevelManager.restore_level(scene, save_point_id)` that
   loads the scene and places the player at the matching save point (fall back to a stored
   position if the point is gone).
5. **`Player.get_facing()`** — expose `_last_facing_direction` so the save point can record
   the facing (or just use the save point's own facing).
6. **`level_manager_start.enter(args)`** — read an optional
   `{scene, save_point_id}` from `args`; default to `neuro_room` when absent.
7. **Fix `_ensure_party()`** — use `load(path).duplicate(true)`. `load()` returns a cached
   resource and combat writes HP/xp back into it, so a second New Game would inherit old
   stats.

## New: save points

The lightest option that fits the existing patterns: a Beehave leaf.

- Add **`SaveGame`** (`addons/beehave_additions/save_game.gd`, `ActionLeaf`) that calls
  `SaveManager.save_to_slot(SaveManager.current_slot)` and returns SUCCESS.
- Build a save point like any NPC: `CharacterBody2D`/`Area2D` +
  `BeehaveTree/SequenceComposite` with **`Interacted` → `SaveGame`**.
- Give each point an `@export var save_point_id: String` and register it in a
  `"save_points"` group (same idea as `SpawnPoint`), so loading can find it.
- Place them in levels (the project already has a `SpawnPoint`/`Transition` pattern to
  copy).

Alternatively a standalone `SavePoint` `Area2D` script that connects `Interacted`-style
input directly — same behaviour, less reusable.

## New autoload: `SaveManager` (`autoloads/save_manager.gd`)

```gdscript
const SAVE_VERSION := 1
const SLOTS := 3
const DIR := "user://saves/"

var current_slot: int = -1              # the slot this playthrough saves into

func new_game(slot: int = -1) -> void   # GameState.reset(); bind current_slot
func save_to_slot(slot: int) -> bool    # called by save points; refuse in combat
func load_from_slot(slot: int) -> bool  # restore containers; caller navigates
func has_slot(slot: int) -> bool
func delete_slot(slot: int) -> void
func slot_info(slot: int) -> Dictionary # timestamp / leader name / level, for the menu
func can_save() -> bool                 # not in combat / not mid-transition
```

`save_to_slot` gathers the dict above (including the level path and the active save point)
and writes it. `load_from_slot` reads, checks `version`, calls the `from_dict` methods, and
returns whether it worked. It does **not** change scenes; the caller decides.

`current_slot` is set by New Game (first empty slot, or a chosen one) and by loading. Save
points always write into it.

## Flows

**New game**
`main_menu` → `SaveManager.new_game()` → `GameState.push("res://levels/level_manager.tscn")`
→ default level.

**Save (only at a save point)**
Player interacts with a save point → `Interacted` succeeds → `SaveGame` leaf →
`SaveManager.save_to_slot(current_slot)` → optional "Saved!" feedback.

**Load**
`main_menu` → `SaveManager.load_from_slot(n)` → if `ok`, push `level_manager.tscn` with
`{scene, save_point_id}` → `level_manager_start` restores that level and places the player
at the save point.

## Minimal UI

- `main_menu`: wire **Load Game** to a small slot list instead of starting a new game;
  **New Game** picks a slot (or the first empty one).
- A simple slot list: three rows showing "empty" or `leader name · Lv · timestamp`, with
  Load / Delete.
- **No save UI** — saving is the save point's job. A short "Saved" message is enough.

## Edge cases

- Missing/corrupt file → return `false`, show a message, never crash.
- Version mismatch → refuse (add migrations later).
- Save point missing on load → fall back to the stored scene's `"default"` spawn point.
- Saving during combat → refused (save points also can't be reached then).
- A missing quest/equipment/action path on load → skip that entry, keep going.
- Old saves after adding fields → read with `data.get(key, default)` in `from_dict`.

## Tests

Extend `tests/combat_tests.gd` (or add `tests/save_tests.gd`):

- round-trip each container: `to_dict` → `from_dict` equals the original.
- `SaveManager` write → read a temp slot restores party/inventory/keys/quests.
- `new_game()` clears the containers and binds a slot.
- `SaveGame` leaf writes a slot; `can_save()` is false in combat.
- `level_manager_start` restores the saved scene/save point when given args.

## Order

1. `QuestManager` serialization + `GameState.reset()`.
2. `SaveManager` (data only) + tests.
3. Save-point object (`SaveGame` leaf) + level/player restore hooks.
4. Menu wiring + slot list.
5. Polish (feedback, delete, optional in-game load).
