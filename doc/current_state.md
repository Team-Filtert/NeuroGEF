# Current State of the Game (NeuroGEF)

_Snapshot: branch `more_new_stuff` (HEAD `d8e6bb4` "ported the old combat"), Godot 4.7.2,_
_project name "NeuroGEF", 512x288 internal resolution (1280x720 window), Forward+ / Jolt Physics._

This is a working snapshot, not a roadmap. It answers three questions: what runs today,
how it is put together, and what is missing or risky.

---

## 1. Snapshot / metrics

| Area | Count | Notes |
| --- | --- | --- |
| Gameplay scripts (excl. addons) | 65 `.gd`, ~3,670 lines | |
| Scenes | 41 `.tscn` | 25 are levels |
| Resources | 38 `.tres` | fighters, actions, statuses, items, themes, quests |
| Combat subsystem | 30 scripts, ~1,725 lines | `res://combat/` |
| Headless test suite | 1 scene, 114 checks | `tests/combat_tests.tscn` — **passing 114/114** |
| Old version (reference) | 105 `.gd`, ~4,560 lines | `old-version/` (symlink, not scanned by Godot) |

The rewrite is roughly the same size as the old game but reorganized, data-driven and
covered by a headless suite. Combat is the most built-out system; audio, saving and menus
are the least.

---

## 2. What you can actually play right now

1. `main.tscn` (`main.gd`) pushes `res://ui/ui_scenes/starting_screen.tscn`.
2. Any key press -> `main_menu.tscn` (New Game / Load Game both currently start a new game).
3. -> `res://levels/level_manager.tscn` (`levels/level_manager_start.gd`): initialises
   `PlayerManager` + `LevelManager`, seeds the default party (`neuro`, `nere`) and a
   starting inventory (potions/tonics), spawns the leader, then loads
   `res://levels/ch1/neuros_home/neuro_room.tscn`.
4. In `neuro_room` the **Evil** NPC runs a Beehave tree
   `Interacted -> AddQuest -> StartTimeline -> StartCombat` (with `victory_key =
   "drones_defeated"` and `quest = defeat_drones.tres`). A transition leads to
   `levels/ch1/other/combat_demo.tscn`, a three-NPC fight lineup.

So the **playable loop is: walk around -> talk/trigger -> fight a drone -> win -> quest
completes**. Everything past that is scaffolding.

Known rough edges in that loop:

- `starting_screen` advances on **any** key (`InputEventKey`), including the Esc/menu keys.
- **New Game and Load Game do the same thing** (`main_menu.gd` — "temp code").
- There is no pause/settings screen; `GameSettings.qte_mode` (active/relaxed) can only be
  changed from code or `user://settings.cfg`.

---

## 3. Architecture at a glance

### Autoloads (`project.godot`)

| Name | Script | Role |
| --- | --- | --- |
| `LevelManager` | `autoloads/level_manager.gd` | owns `LevelRoot`, swaps level scenes, places the player at spawn points |
| `PlayerManager` | `autoloads/player_manager.gd` | owns the player + followers on a separate `PlayerRoot` |
| `GameState` | `autoloads/game_state.gd` | global state (`party`, `inventory`, `keys`, `quests`) **and** the scene stack |
| `GameSettings` | `autoloads/game_settings.gd` | active vs relaxed timing mode, persisted to `user://settings.cfg` |
| `CombatManager` | `autoloads/combat_manager.gd` | entry point for battles + victory rewards |
| `Dialogic`, Beehave metrics/debugger | addons | narrative + behaviour trees |

`GameState` is the heart: `push(path, args, render_underlying)` / `pop(result)` manage a
stack of scene-states, hiding and `PROCESS_MODE_DISABLED`-ing whatever is underneath
(which freezes the player and NPCs, not just stops input). Transitions
(`transitions/fade_transition.tscn`) are played around pushes/pops. This is what lets
combat, dialogue and levels layer cleanly.

### World, player, party

- The player lives on `PlayerRoot`, separate from `LevelRoot`, so it survives level swaps
  and is just repositioned. All access goes through `PlayerManager` methods.
- The party walks as a **line**: `PlayerManager` spawns one `party_follower` per extra
  `GameState.party.members` entry (party[1..]); followers trail a recorded position
  history from the leader (`Player._trail`) and park whenever the leader does.
- Level transitions (`levels/objects/transtiston.gd`) are `@tool` nodes that build their
  own `SpawnPoint` + trigger; `LevelManager._find_spawn_point` matches by `spawn_id`.

### State containers

`Party` / `PartyMember` / `Inventory` / `PersistenceKeys` / `QuestManager` are plain data
objects under `states/`, each with `to_dict()` / `from_dict()`, so saving is "walk the
owners". **Nothing calls them yet** (see §8).

---

## 4. Combat system

Entered through `CombatManager.start_combat(enemies, victory_key, quest)`, which pushes
`res://combat/arena.tscn` onto the `GameState` stack with `render_underlying = false`
(level hidden + frozen, player parked, arena takes over the camera).

- **Arena** (`combat/arena.gd`) is the hub: it spawns combatants into `Marker2D` slots,
  owns the action queue and the ult gauges, and its direct-child states drive the turn
  loop: `ActionSelect -> TargetSelect -> QueueEnemyActions -> ActionResolve -> EndTurn`.
- **Turn model**: the player queues one action per living member, the AI queues one per
  enemy, then everything resolves in **speed order**. Actions are the old "no real turns"
  model — actions are queued, then taken in an order.
- **Data model** (`combat/data/`): `CombatantData` (stats, sprite sheet, actions,
  equipment) with `PartyMember` (+level/xp/serialization) and `EnemyData` (+is_boss/
  xp_reward). `Combatant` is the runtime node (live HP/MP, statuses, movement, equipment-
  aware stat getters).
- **Actions**: `ActionBase` + `Attack` / `Heal` / `Combo` / `Ultimate` / `ItemAction` /
  `StatusAction`. An action is physical or magic by `damage_type`; it can carry a
  `status` applied on hit (this is how Fireball = damage + burn). `get_value()` scales off
  attack or magic; `execute()` multiplies by the timing grade.
- **Timing**: `TimingChallenge.create()` returns `Active` (the QTE `qte_bar.tscn`: a marker
  sweeps once, bands are colored per grade, `accuracy` widens them) or `Relaxed` (no
  input, a roll biased by `accuracy`). This is the single seam for the active/relaxed
  design goal and is easy to extend.
- **Statuses** (`combat/data/status/`): `DamageOverTime`, `HealOverTime`, `StatModifier`,
  fired at START_OF_TURN / END_OF_TURN / END_OF_ROUND in priority order.
- **Items in combat**: consumables in `GameState.inventory` become `ItemAction`s in the
  Items tab and are spent on use.
- **Equipment**: `CombatantData.weapon/armors/artifacts` feed `Combatant.get_*()`.
- **UI** (`combat/ui/arena_ui.gd` + the existing `arena.tscn`): actor panel, party ult bar,
  boss ult gauge (boss fights only), action tabs with descriptions in the info panel, the
  QTE mount, and a level-up overlay (`level_up_panel.tscn`).
- **Enemy AI** (`combat/ai/enemy_ai.gd`): heals when hurt, otherwise strongest affordable
  attack, weighted-random target; an enemy ultimate is gated on the boss gauge.
- **Rewards**: `Arena` awards XP and computes level-ups on victory; `CombatManager.finish()`
  sets the `victory_key` persistence key and starts the reward quest. The design is nice:
  rewards are applied by the manager, not by whichever tree happened to be ticking.

Coverage: the headless suite (`tests/combat_tests.tscn`) drives timing, the QTE, the
combatant runtime, actions, serialization, statuses, combo/ult gating, a **full battle to
completion**, stack suspension + camera, manager rewards, followers, equipment, inventory,
leveling, items-in-combat and the boss gauge.

---

## 5. Quests, persistence & narrative tooling

- **Persistence keys** (`states/persistence_keys.gd`) are the source of truth for progress;
  quest goals read them.
- **Quests** (`states/quests/`): a `Quest` has a goal tree of `PersistenceGoal` /
  `AllGoal` / `AnyGoal` / `SequenceGoal`, all exposing `is_completed()` and `progress()`.
  Two example quests exist: `quests/defeat_drones.tres`, `quests/quest_1_test.tres`.
- **Beehave additions** (`addons/beehave_additions/`): `Interacted`, `EntersArea`,
  `StartCombat`, `StartTimeline`, `AddQuest`, `HideNode` — the building blocks NPCs use.
- **Dialogic additions** (`addons/dialogic_additions/`): quest/key events
  (`event_key`, `event_if_key`, `event_quest`, `event_if_quest`) so timelines can read and
  write game state.
- Timelines under `data/timelines/` (`chest`, `town_npc_1`, `ved_ai_1`, `npc1`/`npc2`).

---

## 6. Content inventory

- **Levels** (25): `ch1/starting_area` (house interior), `ch1/neuros_home`, `ch1/town`,
  `ch1/forest` (+lake), `ch1/mountains` (cave, foot, site), `ch1/other` (city,
  `combat_demo`). Roughly a third are chained by transitions; the rest are unconnected
  scenes.
- **Characters**: Neuro (playable, `.dch`), Nere (playable/follower), Evil NPC, a
  generic `combat_npc`, `ved_ai_1`, Swarm Drone (`.dch`).
- **Fighters**: `neuro`, `nere`, `swarm_drone`, `swarm_queen` (boss).
- **Actions**: basic attack, healing touch, overclock (ult), fireball (burn), anvil smash,
  magic blast, fire it up (party buff), queen slam (boss ult).
- **Items**: potion, mana tonic, spark wand, training sword, leather vest.
- **Statuses**: burn, regeneration, attack up.
- **Assets**: sprites (neuro, nere, evil, trees), tilesets, backgrounds, 7 BGM tracks,
  5 UI themes, walk-cycle animations.
- **Localization**: `de.de.translation`, `en.en.translation` are registered, but UI strings
  are hard-coded English.

---

## 7. Health assessment — what's solid

- **The state-stack architecture is good and load-bearing.** Transitions, level swaps,
  combat and dialogue all compose through it without special-casing.
- **Combat is genuinely data-driven.** New enemies/actions/statuses/items are authored as
  `.tres`, not code; the "damage + status on one action" and "item = action" models keep
  the class count down.
- **The active/relaxed seam is clean.** One `TimingChallenge.create()` switch plus
  subclasses; nothing else knows which mode is active.
- **There is a real regression suite** (114 checks) that drives a full battle headless.
  This is unusually good for a game at this stage and makes the combat work safe to change.
- **Docs are current and useful**: `doc/combat.md`, `doc/old_version_porting_plan.md`,
  `doc/architecture_design_rough.txt`.

---

## 8. Gaps & risks (actionable)

Ordered roughly by impact.

1. **No save/load.** Not one caller touches the `to_dict` methods. The main menu's
   "Load Game" starts a new game, and Dialogic autosave is off. This blocks any notion of
   progression.
2. **No audio wiring.** `main.tscn` has a `BGMPlayer` on the `BGM` bus and 7 tracks ship in
   `assets/bgm/`, but no code plays anything. `AudioManager` was never ported.
3. **Duplicate autoload.** `project.godot` declares both `Game` and `GameState` on the
   **same script uid** (`uid://bpxsua0hwtlj6` = `game_state.gd`). Two instances exist;
   nothing references `Game.`. Remove the duplicate.
4. **Stale Dialogic paths into `old-version/`.** `project.godot`'s `[dialogic]`
   directories reference `res://old-version/characters/*.dch` and `res://old-version/
   dialogue/*.dtl`. `old-version/` is a symlink Godot does not scan, so those entries are
   likely broken in the Dialogic editor. Point them at `characters/` / `data/timelines/`
   or delete them.
5. **Weapons design conflict.** `doc/Meeting.md` says *"weapons got cut, we only have armor
   and artefacts now"*, but `ItemEquipable.Slot` still has `WEAPON` and both demo
   characters are equipped with weapons (`spark_wand`, `training_sword`). Decide one way
   and make the model match.
6. **Level-up diverges from the old design.** `Leveling.apply_level_ups()` auto-applies a
   flat `GROWTH` table; the old game let the player pick a stat to raise by a random bonus
   (`LevelUpUI`/`LevelUpManager`). The new `LevelUpPanel` only reports. Decide whether
   player choice comes back.
7. **`doc/architecture_design_rough.txt` is out of date.** It says
   "INVENTORY: leaving this for later" (done now) and refers to a `battle_visual` /
   `overworld_visual` split that does not exist — `CombatantData` uses one `texture` +
   sprite-sheet layout for both.
8. **Level graph is partially disconnected.** ~25 scenes exist but only some are chained;
   worth an audit and a "start -> ... -> end of chapter" path. Transition targets are
   stored as uids, which makes the graph hard to read by hand.
9. **Placeholder tuning.** Accuracy window, `TimingGrade.MULTIPLIERS`, the XP curve, enemy
   stats and item values are all first-pass. Fine for now, but they are not balanced.
10. **Leftovers:** `main.gd` has commented-out legacy init; `starting_screen` advances on
    any key; `main_menu` buttons are marked "temp code"; combat has no flee-to-level
    confirmation despite a Flee button; UI strings are not localized.
11. **Content roster gaps.** The chapter-1 design list in the notes (`content_plan.md`)
    needs mechanics the model doesn't have yet: percentage-based item/status effects,
    revive items, a shield/damage-absorb status, and an `Evil` fighter resource.

---

## 9. Suggested next steps

1. **Save/load** — a `SaveManager` autoload that walks `GameState.party/inventory/keys/
   quests/quests` through their `to_dict`, plus slot + version. Highest-leverage missing
   system.
2. **Audio** — a small `AudioManager` (BGM crossfade + one-shots on `SFX`) and hook battle
   tracks to combat start/end; assets already exist.
3. **Cleanups** — drop the duplicate `Game` autoload, fix the Dialogic `old-version`
   paths, resolve the weapons decision, refresh `architecture_design_rough.txt`.
4. **A real new-game flow** — New vs Load, a start scene, and (optionally) the skill-tree
   style level-up choice.
5. **Content pass** — wire the level graph, then rebalance using the test suite as a
   safety net.

---

_Generated from a read of the repository at the snapshot above. Metrics are approximations
from `find`/`wc` over the non-addon, non-`old-version` tree._
