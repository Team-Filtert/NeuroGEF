# Save / Load — Implementation Plan

Short plan for persisting overworld progress. Nothing here is implemented yet.

## Goal

Save the game to numbered slots and restore it exactly where the player left off.

## What gets saved

| Part | Source | Notes |
| --- | --- | --- |
| Party | `GameState.party.to_dict()` | stats, HP/MP, level/xp, action paths, equipment paths — already exists |
| Inventory | `GameState.inventory.to_dict()` | money + item stacks (by resource path) — already exists |
| Keys | `GameState.keys.get_all()` | all persistence flags/counters — already exists |
| Quests | `QuestManager` | **needs `to_dict`/`from_dict`** (store quest resource paths) |
| World | level scene path, player position, facing | small additions needed |

**Not saved:** active combat, transitions, enemies, settings. `GameSettings` already
persists itself; combat is transient.

## Slot file shape

```gdscript
{
    "version": 1,
    "saved_at": "2026-10-06T21:00:00",
    "world": {
        "scene": "res://levels/ch1/neuros_home/neuro_room.tscn",
        "position": [x, y],
        "facing": [x, y],
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
4. **Restore placement** — either add optional `position`/`facing` args to
   `change_level`, or a `LevelManager.restore_level(scene, position, facing)` that skips
   the spawn-point lookup.
5. **`Player.get_facing()`** — expose `_last_facing_direction` (or track it in
   `PlayerManager`).
6. **`level_manager_start.enter(args)`** — read an optional `{scene, position, facing}`
   from `args`; default to `neuro_room` when absent.
7. **Fix `_ensure_party()`** — use `load(path).duplicate(true)`. `load()` returns a cached
   resource and combat writes HP/xp back into it, so a second New Game would inherit old
   stats.

## New autoload: `SaveManager` (`autoloads/save_manager.gd`)

```gdscript
const SAVE_VERSION := 1
const SLOTS := 3
const DIR := "user://saves/"

func save_to_slot(slot: int) -> bool     # refuse while CombatManager.is_in_combat()
func load_from_slot(slot: int) -> bool   # restore containers; caller navigates
func new_game() -> void                  # GameState.reset()
func has_slot(slot: int) -> bool
func delete_slot(slot: int) -> void
func slot_info(slot: int) -> Dictionary  # timestamp / leader name / level, for the menu
```

`save_to_slot` gathers the dict above and writes it. `load_from_slot` reads, checks
`version`, calls the `from_dict`/`load_from_dict` methods, and returns whether it worked.
It does **not** change scenes; the caller decides.

## Flows

**New game**
`main_menu` → `SaveManager.new_game()` → `GameState.push("res://levels/level_manager.tscn")`
→ default level.

**Save**
A menu button or hotkey → `SaveManager.save_to_slot(n)`. (Optional later: autosave on
level change.)

**Load**
`main_menu` → `SaveManager.load_from_slot(n)` → if `ok`, push `level_manager.tscn` with
`{scene, position, facing}` → `level_manager_start` restores that level and spot.

**Load from inside the game** (if added later)
`load_from_slot(n)` then `LevelManager.restore_level(scene, position, facing)` directly.

## Minimal UI

- `main_menu`: wire **Load Game** to a small slot list instead of starting a new game.
- A simple `save_slots` scene: three rows showing "empty" or
  `leader name · Lv · timestamp`, with Load / Delete.
- Save can reuse the same scene (Save / Load mode) or be a single "Save" button for now.

## Edge cases

- Missing/corrupt file → return `false`, show a message, never crash.
- Version mismatch → refuse (add migrations later).
- Saving during combat → refuse.
- A missing quest/equipment/action path on load → skip that entry, keep going.
- Old saves after adding fields → read with `data.get(key, default)` in `from_dict`.

## Tests

Extend `tests/combat_tests.gd` (or add `tests/save_tests.gd`):

- round-trip each container: `to_dict` → `from_dict` equals the original.
- `SaveManager` write → read a temp slot restores party/inventory/keys/quests.
- `new_game()` clears the containers.
- `level_manager_start` picks the saved scene when given args.

## Order

1. `QuestManager` serialization + `GameState.reset()`.
2. `SaveManager` (data only) + tests.
3. Level/player restore hooks (current path, position/facing, `enter(args)`).
4. Menu wiring + slot list.
5. Optional: autosave and slots polish.
