# Development

How to run the project, run the tests, and the conventions/quirks to know about.

---

## 1. Requirements

- **Godot 4.7.x** (the project's `config/features` is `4.7`, Forward+). The snapshot was
  taken on 4.7.2.
- Editor plugins are enabled in `project.godot`: **TileMapDual**, **Beehave**,
  **Dialogic**.

---

## 2. Running

- Open the folder in the Godot editor and press **F5**, or from a shell:
  ```sh
  godot --path .
  ```
- The main scene is `res://main.tscn`, which pushes `res://ui/ui_scenes/starting_screen.tscn`.

Internal resolution is 512x288, stretched to a 1280x720 window (`canvas_items` / `expand`).

---

## 3. Importing (important after adding code)

New `class_name` globals are not known to the engine until the project is imported. After
adding a script with a `class_name`, run a headless import before running/testing, or you
get "Could not resolve class" errors:

```sh
godot --headless --path . --editor --quit
```

Hand-authored `.tres`/`.tscn` are fine, but the class cache must be regenerated.

---

## 4. Tests

The combat system has a headless regression suite:

```sh
godot --headless --path . res://tests/combat_tests.tscn
```

- It prints one `PASS`/`FAIL` line per check, a `TEST_SUMMARY`, and `TEST_RESULT: OK|FAILED`,
  and **exits non-zero on failure**, so it can gate CI.
- It travels through the real scenes/singletons and drives a **full battle to completion**,
  including stack suspension and the camera. Current coverage (114 checks): resources,
  timing grades, the QTE bar, challenge selection, the combatant runtime, actions,
  serialization, statuses, combo/ult gating, a full battle, stack + camera, manager
  rewards, overworld followers, equipment, inventory, leveling, status application, items
  in combat, and the boss ult gauge.
- **Keep and extend it.** Add a `_check("name", condition)` case for anything you add; see
  `tests/combat_tests.gd`.

There is no CI workflow yet (`.github/` only holds issue templates) — the suite is run by
hand.

---

## 5. Conventions

- **Typed GDScript.** Type variables, params and returns (`Array[Combatant]`, `-> void`).
- **`class_name`** on most scripts so they are globally available; use `[method]`/`[member]`
  BBCode in `##` doc comments.
- **Data is resources.** New enemies/actions/statuses/items are `.tres`, not code. Only
  subclass when the *formula* differs.
- **State roots implement `enter(args)`** — that's the state's constructor (see
  `architecture.md` §2). `_ready` should not read push args.
- **Go through managers.** `PlayerManager` for the player, `LevelManager` for levels,
  `CombatManager` for battles, `QuestManager`/`PersistenceKeys` for progress — don't reach
  into nodes/containers directly.
- **Data containers expose `to_dict`/`from_dict`.** Keep that up when adding fields, so
  saving stays a walk of the owners.
- Comments explain *why*, not *what*.

---

## 6. Known issues / cleanups

Concrete things worth fixing (see also `current_state.md` §8):

1. **Duplicate autoload.** `project.godot` declares `Game` and `GameState` on the same
   script uid (`game_state.gd`). Two instances exist and `Game` is unused — remove it.
2. **Stale Dialogic paths.** `project.godot` `[dialogic]` references
   `res://old-version/characters/*.dch` and `res://old-version/dialogue/*.dtl`.
   `old-version/` is a symlink Godot does not scan, so those entries are likely broken.
3. **No save/load.** The `to_dict` methods exist but nothing calls them; the main menu's
   "Load Game" starts a new game.
4. **No audio.** A `BGMPlayer` exists on the `BGM` bus and tracks ship in `assets/bgm/`,
   but no code plays anything.
5. **Weapons design conflict.** `Meeting.md` says weapons were cut, but the model still has
   a `WEAPON` slot and the demo characters use weapons — see `items_and_inventory.md` §3.
6. **Temp/placeholder UI.** `starting_screen` advances on any key; `main_menu` buttons are
   marked "temp code"; UI strings are English-only despite translations being registered.
7. **`poped_result`** in `game_state.gd` is a typo for `popped_result` (cosmetic; it is the
   public name used by callers).

---

## 7. `old-version/`

`old-version/` is a **symlink** to the previous game's project
(`/home/lukasderbaum/Projekte/NeuroGEF-old-version`). Godot does not scan through the
symlink, so its scripts/resources are not part of the build and its `class_name`s (e.g.
`Arena`, `Combatant`) do **not** collide with the rewrite's. Treat it as read-only
reference material; don't import files from it blindly (see
`old_version_porting_plan.md`).

---

## 8. Where to look next

| Topic | Doc |
| --- | --- |
| Overall architecture | `architecture.md` |
| Combat system | `combat.md` |
| Items & equipment | `items_and_inventory.md` |
| Quests, keys, dialogue/Beehave | `quests_and_persistence.md` |
| Building levels & NPCs | `level_authoring.md` |
| What's built / missing, risks | `current_state.md` |
| Porting from the old game | `old_version_porting_plan.md` |
