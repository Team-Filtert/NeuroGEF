# Level & Scene Authoring

How levels, transitions, NPCs and encounters are put together.

---

## 1. What a level is

A level is a `Node2D` scene under `res://levels/`. It is instantiated by `LevelManager`
under `LevelRoot` (a `Node2D`) whenever the game changes level, and freed when it changes
again.

> The root **must be a `Node2D`/`CanvasItem`** — the state stack hides the level by calling
> `hide()` on it. A plain `Node` root can't be hidden.

The game boots: `main.tscn` → `starting_screen` → `main_menu` → `levels/level_manager.tscn`
(`level_manager_start.gd`) → a level. `level_manager_start.gd` also seeds the default party
and inventory on a fresh game.

---

## 2. Spawn points

`SpawnPoint` (`levels/objects/spawn_point.gd`, scene `spawn_point.tscn`) is a `Marker2D`
that registers itself in the `"spawn_points"` group.

```gdscript
@export var spawn_id: String
@export var facing_direction: FacingDirection   # UP/LEFT/DOWN/RIGHT
```

`LevelManager.change_level(path, spawn_id)` finds the point whose `spawn_id` matches and
places + faces the player there. Give each level one with `spawn_id = "default"` for the
initial spawn, plus one per incoming transition.

---

## 3. Transitions between levels

There are two layers:

- **`TransitionTrigger`** (`levels/objects/level_trigger.gd`) — an `Area2D` that, on
  `body_entered`, calls
  `LevelManager.change_level(target_scene, spawn_id, transition_scene)`.
- **`Transition`** (`levels/objects/transtiston.gd`, scene `transtiston.tscn`) — an
  `@tool` `Node2D` that **builds** a child `SpawnPoint` + `TransitionTrigger` +
  `CollisionShape2D` for you in the editor, positioned by `facing_direction`.

Exports on `Transition`:

| Export | Meaning |
| --- | --- |
| `Transition_ID` | becomes the trigger's `spawn_id` (which spawn the destination uses) |
| `target_scene` | the level to load |
| `transition_scene` | the wipe to play (default `fade_transition.tscn`) |
| `hit_box_size` | the trigger area size |
| `facing_direction` | which way the player faces on arrival; positions the spawn |

> Naming quirk: the file is `transtiston.gd` (typo) but the class is `Transition`.

Typical usage: drop a `Transition` at a door, set `target_scene` to the next room and
`Transition_ID` to a matching `SpawnPoint.spawn_id` in that room, and give the destination
a `SpawnPoint` with that same id.

---

## 4. NPCs

An NPC is a `CharacterBody2D` (usually with a `Sprite2D`, a `CollisionShape2D`, an `Area2D`
for interaction, and a `BeehaveTree`). Behaviour is a Beehave tree built from the project's
leaves (`addons/beehave_additions/`) — see `quests_and_persistence.md` §3 for the leaf
reference.

Common pattern (from `characters/ch1/evil.tscn`):

```
Evil (CharacterBody2D)
├── Sprite2D
├── CollisionShape2D
├── AnimationPlayer / AnimationTree
├── Area2D                     <- the interaction area the Interacted leaf watches
└── BeehaveTree
    └── SequenceComposite
        ├── Interacted
        ├── AddQuest
        ├── StartTimeline
        └── StartCombat
```

`Interacted`/`EnteredArea` detect the player by `body.name == "Player"`, so keep the player
node named `Player`.

Some NPCs (e.g. `ved_ai_1.gd`) expose `timeline`/`key`/`texture` as exports on the root
and push them into the tree's leaves in `_ready()` — a convenient wrapper when you want to
configure a placed instance from the inspector.

---

## 5. A lineup of fights

`characters/ch1/combat_npc.tscn` (`combat_npc.gd`) is a ready-made fightable NPC. Exports:

```gdscript
@export var enemies: Array[EnemyData]
@export var victory_key: String
@export var quest: Quest
@export var texture: Texture2D
```

Place several and give each different `enemies` to build a lineup.
`levels/ch1/other/combat_demo.tscn` is an example with three (`Fight1..3`).

For an ambush instead of an interaction, use an `EncounterArea` (see `combat.md`) or an
`EnteredArea`-driven tree.

---

## 6. Dialogue

Timelines live in `data/timelines/` and characters (`*.dch`) in `characters/`. A
`StartTimeline` leaf starts one by reference. Dialogic is configured in `project.godot`
under `[dialogic]`.

> Known issue: the Dialogic directory lists some `res://old-version/...` characters and
> timelines. `old-version/` is a symlink Godot does not scan, so those entries are likely
> broken — point them at `characters/` / `data/timelines/` or remove them. See
> `development.md` §6.

---

## 7. Z-ordering

The NPCs sort themselves against the player every frame for a fake top-down depth:

```gdscript
func _process(_delta):
    z_index = PlayerManager.get_player_z_index() + 1 \
        if global_position.y >= PlayerManager.get_player_position().y else 0
```

Copy this into new overworld characters.

---

## 8. Checklist for a new level

1. New `Node2D` scene under `levels/`. Add tiles (`TileMapLayer`s) and decor.
2. Add a `SpawnPoint` with `spawn_id = "default"` (initial spawn).
3. For every incoming exit, add a `Transition` whose `Transition_ID` matches the
   destination's spawn id, or a `SpawnPoint` with that id.
4. Add NPCs / encounters as needed.
5. Wire it into the graph: a `Transition` in another level must point `target_scene` here.
6. Play-test the path both ways (transitions are one-directional; each side needs its
   own).
