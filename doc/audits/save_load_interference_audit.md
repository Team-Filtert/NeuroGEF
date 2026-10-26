# Save/Load Interference Audit

Every hardcoded assumption or shared reference that will affect a save/load system, where
it lives, and how bad it is.

**Verdict:** the lead is right that there is a lot hardcoded, but only a handful of items
actually *block* save/load. Most of the rest is either visual wiring (leader/follower
sprites) or tuning constants that don't matter for persistence. The two real landmines are
**shared, mutated `.tres` resources** and **container identity** (replacing objects other
systems cached).

Severity: **Blocker** = load is wrong or impossible · **High** = silent data loss/corruption
· **Medium** = feature works but is fragile/misleading · **Low** = polish.

---

## 1. Container identity & reset

| # | Location | Hardcoded assumption | Why it breaks save/load | Fix | Sev |
|---|---|---|---|---|---|
| 1 | `autoloads/game_state.gd:3-6` | `party`/`inventory`/`keys`/`quests` are created once, never reset | "New Game" after playing (or after a Load) keeps the old state; the autoload outlives every scene | `GameState.reset()` that clears **in place** (see #2) | Blocker |
| 2 | `addons/dialogic_additions/Quest/subsystem_quests.gd:_post_install` | connects `key_changed`/`key_erased` **once**, to the object it grabbed at startup | If load does `GameState.keys = PersistenceKeys.new()`, the quest subsystem keeps listening to the *old* keys — auto quest-completion silently stops | mutate keys in place via `load_from_dict`; or make the subsystem reconnect by identity (the Keys subsystem already does) | Blocker |
| 3 | `states/quests/quest_manager.gd` | no `to_dict`/`from_dict` at all | quests can't be saved | add path-based serialization | Blocker |
| 4 | `levels/world.gd:24-26` | seeding guarded only by "is it empty?" | with #1, New Game never reseeds; and an intentionally empty saved inventory gets reseeded | seed only when `enter(args)` says new game | High |

> Prefer **in-place** reset/load for all four containers. Replacing `party` is probably
> safe today (only read live), but replacing `keys` is not (see #2), and keeping one rule is
> simpler.

---

## 2. Shared, mutated resources (the big one)

`load("res://data/combatants/neuro.tres")` returns the **cached** `.tres`. Combat writes
into it: `Combatant.save_to_data()` writes `health`/`mana`, `Arena._award_xp()` writes `xp`,
and `Leveling.apply_level_ups()` writes `level`/stats. So the cached template is dirty after
one battle.

| # | Location | Problem | Fix | Sev |
|---|---|---|---|---|
| 5 | `levels/world.gd:28,33` | New Game re-`load()`s the dirty cached member/item, so stats/HP/xp leak between playthroughs | `ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)` to read a pristine copy from disk. **`duplicate(true)` is not enough** — it copies the dirty state too. | Blocker |
| 6 | `states/party_member.gd:55-58` | actions/equipment saved by `resource_path`; runtime-created ones have `""` | skip empty paths, or support inline data | High (future) |
| 7 | `states/party_member.gd:12` | `load("")` when `texture_path` is empty | guard before loading | Low |
| 8 | `states/inventory.gd:87` | `load("")` path is silently skipped → item lost | skip with a warning / inline fallback | Medium |
| 9 | `quests/*.tres`, `data/items/*.tres` | also cached resources, but read-only today | duplicate if they ever gain state | Low |

This also explains why the test suite can leak state between cases (it loads and mutates the
same resources).

---

## 3. World scene & restore path

| # | Location | Hardcoded | Why it breaks save/load | Fix | Sev |
|---|---|---|---|---|---|
| 10 | `levels/world.gd:19` | start scene `neuro_room.tscn`, spawn `"default"`; `enter(args)` ignores `args` | a save can't say "resume in the forest at point X" | read `{scene, save_point_id}` from `args` | Blocker |
| 11 | `levels/world.gd:24-35` | seeds `DEFAULT_PARTY`/`DEFAULT_ITEMS` whenever they're empty | empty saved inventory gets seeded | only on new game | High |
| 12 | `autoloads/level_manager.gd` | `_current_level` is private; no `current_level_path()` | saving can't record where the player is | track + expose the path | Blocker |
| 13 | `autoloads/level_manager.gd:14-52` | only `_find_spawn_point`; missing spawn just warns and leaves the player put; `_busy` guard silently returns | load at a save point has nothing to target; a bad id leaves the player misplaced; a load during a transition is dropped | add `restore_level(scene, save_point_id)` with a `"save_points"` group + explicit fallback; make `change_level` return success | Blocker |
| 14 | `ui/ui_scenes/main_menu.gd:9-15` | both New and Load push `world.tscn` ("temp code") | Load cannot load; New cannot reset | wire `SaveManager` | Blocker |
| 15 | `autoloads/player_manager.gd:3-4` | `preload`ed player/follower scenes | can't swap the player visual per chapter or per saved party; can't test with stubs | parameterize via `init(...)` or settable properties | Low (Medium for character swaps) |
| 16 | `levels/world.gd:3-11` | `DEFAULT_PARTY` / `DEFAULT_ITEMS` inline | starting loadout lives in code, not data | move to a new-game profile resource | Medium |

---

## 4. Player state (capturing/restoring)

| # | Location | Problem | Fix | Sev |
|---|---|---|---|---|
| 17 | `characters/playable/player.gd:9` | `_last_facing_direction` is private; no `get_facing()` | add a getter, or store facing on the save point | Medium |
| 18 | `autoloads/player_manager.gd:14-21` | `spawn_player` early-returns if a player exists; followers only spawn once; no `refresh_party()` | add `refresh_party()`; call after an in-game load or party change | High (in-game load) |
| 19 | `autoloads/player_manager.gd:50` | `get_player_position()` returns `Vector2.ZERO` with no player | `can_save()` should require a valid player | Medium |
| 20 | `characters/playable/player.tscn:20-23` | leader sprite baked to `neuro.png` (3x4, frame 2); `party[0]` ignored | apply `party[0]`'s visual on spawn | Medium (visual) |
| 21 | `characters/playable/party_follower.tscn:9-11` | fixed 3x4/frame 1; `setup()` only receives `texture` | pass the member's `sprite_hframes/vframes/frame` too | Low |

---

## 5. Async & guards

| # | Location | Problem | Fix | Sev |
|---|---|---|---|---|
| 22 | `autoloads/game_state.gd:22` | `push` is a coroutine (awaits the fade) | the Load handler must `await` it | Medium |
| 23 | `autoloads/level_manager.gd:15` | `_busy` makes `change_level` silently no-op | return a bool / await, don't drop loads | Medium |
| 24 | `autoloads/combat_manager.gd` | `_busy` is only cleared in `finish()` | reset on new game/load; `can_save()` checks `is_in_combat()` | Medium |
| 25 | `autoloads/game_settings.gd` | the active/relaxed flag now lives in `SaveSettings` (`states/save_settings.gd`) | include `save_settings.to_dict()` in the save if it should be per-slot; keep it global otherwise | Info |

---

## 6. Autoload / project config

| # | Location | Problem | Fix | Sev |
|---|---|---|---|---|
| 26 | `project.godot [autoload]` | `Game` and `GameState` both point at `game_state.gd` (two instances) | remove `Game` | Medium |
| 27 | `project.godot [dialogic]` | character/timeline paths into `old-version/` (not scanned) | repoint or delete; broken dialogue can't set keys/quests | Medium |
| 28 | `addons/.../game_state_access.gd` | autoload name defaults to `"GameState"`, overridable via `dialogic/game_state_autoload` | if you rename the autoload, set that project setting | Info |

---

## 7. Serialization robustness (once `SaveManager` exists)

| # | Location | Problem | Fix | Sev |
|---|---|---|---|---|
| 29 | `states/party.gd:11-13` | indexes `data["ult_charge"]`, `data["members"]` directly | use `data.get(key, default)` | High |
| 30 | `states/party_member.gd:11-23` | indexes every field directly | `get` with defaults; tolerate old/new saves | High |
| 31 | (new) `SaveManager` | no `version` field yet | include `version`; validate before mutating `GameState` | Blocker |

---

## Hardcoded, but **not** a save/load problem

These turn up in a grep but don't affect persistence — leave them unless you're cleaning up:

- **Tuning constants:** `Player.SPEED/SPRINT/TRAIL_LENGTH`, `QteBar` bands,
  `TimingGrade.MULTIPLIERS/COLORS`, `Leveling.GROWTH` and the XP curve. (Curve *changes*
  between save versions only affect how stored `xp` levels up — document it, don't fix it.)
- **Scene/UI wiring:** `CombatManager.ARENA_SCENE`, `Arena`'s `preload`s, theme paths, all
  the `$Node/Path` HUD lookups in `arena_ui.gd`.
- **Overworld wiring:** `body.name == "Player"` in `Interacted`/`EnteredArea`;
  `combat_npc.gd:20`, `ved_ai_1.gd:9`, `temp.gd:8-9` hardcoded Beehave node paths;
  `HideNode` casting to `TileMapLayer`.
- **Cosmetic:** debug `print()` in `player_manager.gd:12`, `level_manager.gd:12`,
  `start_timeline.gd:23`; the `poped_result` typo.

---

## Minimal blocking set (do these first)

1. `GameState.reset()` that clears the containers **in place**; add `Party.clear()`,
   `Inventory.clear()`, `QuestManager.clear()`.
2. `QuestManager.to_dict()` / `from_dict()` (resource paths; skip missing).
3. New-game seeding via `CACHE_MODE_IGNORE` loads, only when `args == null`.
4. `LevelManager.current_level_path()` + `restore_level(scene, save_point_id)` and a
   `"save_points"` group.
5. Wire `main_menu` to `SaveManager` (New = reset + push, Load = restore + push with args),
   `await` the push.
6. Make `Party.from_dict`/`PartyMember.from_dict` defensive (`get` + version check).

Then the "important but not blocking" batch: keys in place (#2), `get_facing` (#17),
`refresh_party` (#18), leader visual (#20), `can_save` guards (#19/#23/#24).

---

## How this affects the save file

Because the dirty-cache problem (#5) is real, a save must **not** be treated as "the party
resource serialized". It is a **snapshot of live values** (`health`, `mana`, `xp`, `level`,
stats, equipment paths) taken from the `Combatant`/`PartyMember` in memory. On load, build
**new** `PartyMember` instances from that snapshot (don't `load()` the template), which
`PartyMember.from_dict` already does. Keep the `.tres` files as *templates only*.
