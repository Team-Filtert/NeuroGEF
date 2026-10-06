# API Reference

The APIs you'll actually reach for, with real signatures.

Three kinds of global:

- **Autoloads** — singletons accessed by name (`GameState`, `PlayerManager`, ...).
- **`class_name` globals** — available anywhere after import (`Combatant`, `Inventory`,
  `TimingGrade`, ...).
- **Resources** — authored `.tres`, instantiated as objects.

> After adding a `class_name`, run `godot --headless --path . --editor --quit` so the
> engine knows it (see `development.md` §3).

---

## 1. Autoloads

### `GameState` — `autoloads/game_state.gd`

The global data holder **and** the scene stack.

```gdscript
# Data (always present)
var party: Party
var inventory: Inventory
var keys: PersistenceKeys
var quests: QuestManager

# Stack
var state_stack: Array[Node]
var current_state: Node
var poped_result: Variant           # result passed to the last pop()

func init(state_manager: Node, transition_root: Node) -> void

func push(state_path: String, args = null, render_underlying := false,
          transition_path := "res://transitions/fade_transition.tscn") -> void
func pop(result = null,
          transition_path := "res://transitions/fade_transition.tscn") -> void
```

- `push` calls **`enter(args)`** on the new state's root. The scene root must implement it.
- Unless `render_underlying` is true, the state below is hidden and
  `PROCESS_MODE_DISABLED` (which also stops its input). The root must be a `CanvasItem` to
  be hidden.
- Pass `transition_path = ""` to skip the wipe.

### `LevelManager` — `autoloads/level_manager.gd`

```gdscript
func init(level_root: Node2D, transition_root: Control) -> void
func change_level(level_path: String, spawn_id := "", transition_path := "") -> void
```

Swaps the level under `LevelRoot`, parks/re-enables the player, and places it at the
`SpawnPoint` whose `spawn_id` matches.

### `PlayerManager` — `autoloads/player_manager.gd`

```gdscript
func init(player_root: Node2D) -> void
func spawn_player(position := Vector2.ZERO) -> void
func despawn_player() -> void
func set_player_active(active: bool) -> void
func set_player_position(position: Vector2) -> void
func get_player_position() -> Vector2
func get_player_z_index() -> int
func set_player_facing(facing: Vector2) -> void
func get_player() -> CharacterBody2D
func follower_count() -> int
```

Access the player only through this.

### `GameSettings` — `autoloads/game_settings.gd`

```gdscript
enum QTEMode { ACTIVE, RELAXED }
signal qte_mode_changed(mode: QTEMode)

var qte_mode: QTEMode            # setter emits qte_mode_changed

func is_active_mode() -> bool
func load_settings() -> void     # user://settings.cfg
func save_settings() -> void
```

### `CombatManager` — `autoloads/combat_manager.gd`

```gdscript
var last_victory := false        # result of the most recent battle

func start_combat(enemies: Array, victory_key := "", quest: Quest = null) -> void
func is_in_combat() -> bool
func finish(victory: bool) -> void   # called by Arena; applies rewards
```

Rewards (`victory_key` as a persistence key, `quest` started) are applied here on victory,
so callers don't observe the battle themselves.

---

## 2. Data containers

### `Party` — `states/party.gd`

```gdscript
var ult_charge: int
var members: Array[PartyMember]

static func from_dict(data: Dictionary) -> Party
func to_dict() -> Dictionary
func add_member(member: PartyMember) -> void
func has_member_named(name: String) -> bool
```

### `PartyMember extends CombatantData` — `states/party_member.gd`

```gdscript
var level: int
var xp: int

static func from_dict(data: Dictionary) -> PartyMember   # restores stats, HP/MP, level,
                                                          # action paths, equipment paths
func to_dict() -> Dictionary
```

### `CombatantData extends Resource` — `combat/data/combatant_data.gd`

Shared definition of a fighter (party member or enemy).

```gdscript
# Identity / visuals
var display_name: StringName
var texture: Texture2D
var sprite_hframes: int
var sprite_vframes: int
var sprite_frame: int

# Stats
var max_health: int
var max_mana: int
var attack: int
var magic: int
var defense: int
var speed: int
var accuracy: int          # widens the QTE window / improves the relaxed roll

# Actions / equipment
var actions: Array[ActionBase]
var weapon: ItemEquipable
var armors: Array[ItemEquipable]
var artifacts: Array[ItemEquipable]

# Live values
var health: int
var mana: int

func ensure_initialized() -> bool   # true the first time (fills HP/MP)
func has_ult() -> bool
```

### `EnemyData extends CombatantData` — `combat/data/enemy_data.gd`

```gdscript
var is_boss: bool
var xp_reward: int
```

### `Inventory` — `states/inventory.gd`

```gdscript
var money: int

func add(item: Item, amount := 1) -> void
func remove(id: StringName, amount := 1) -> bool
func count(id: StringName) -> int
func has(id: StringName) -> bool
func get_item(id: StringName) -> Item
func items() -> Array[Item]
func equipables() -> Array[ItemEquipable]
func consumables() -> Array[Consumable]
func use_consumable(id: StringName, member: CombatantData) -> bool
func to_dict() -> Dictionary
func from_dict(data: Dictionary) -> void
```

### `PersistenceKeys` — `states/persistence_keys.gd`

```gdscript
signal key_changed(key: String, new_value: Variant, old_value: Variant)
signal key_erased(key: String)

func set_value(key: String, value: Variant = true) -> void
func increment(key: String, amount: Variant = 1) -> Variant
func erase(key: String) -> bool
func clear() -> void
func has(key: String) -> bool
func get_value(key: String, default: Variant = null) -> Variant
func value(key: String) -> Variant                 # alias of get_value
func is_true(key: String) -> bool
func get_number(key: String, default := 0.0) -> float
func get_string(key: String, default := "") -> String
func equals(key: String, expected: Variant) -> bool
func at_least(key: String, minimum: float) -> bool
func get_all() -> Dictionary
func keys_with_prefix(prefix: String) -> Array[String]
func load_from_dict(data: Dictionary, replace := true) -> void
```

### `QuestManager` — `states/quests/quest_manager.gd`

```gdscript
var quests: Dictionary[String, Quest]

func add_quest(quest: Quest) -> void
func get_quest(id: String) -> Quest
func is_completed(id: String) -> bool
func get_quests() -> Dictionary[String, Quest]
```

### `Leveling` — `states/leveling.gd` (static helpers)

```gdscript
const GROWTH: Dictionary     # { "max_health": 4, "max_mana": 2, "attack": 2, ... }

static func xp_requirement(level: int) -> int                # 5 * 2^level
static func apply_level_ups(member: PartyMember) -> Dictionary   # spends xp, raises level(s),
                                                                 # returns total gains ({} if none)
```

---

## 3. Items

### `Item extends Resource` — `items/item.gd`

```gdscript
var id: StringName        # stable key: stacking + saves use this
var display_name: String
var description: String
var texture: Texture2D
```

### `ItemEquipable extends Item` — `items/equipable.gd`

```gdscript
enum Slot { WEAPON, ARMOR, ARTIFACT }
var slot: Slot

var max_health_modifier: int
var max_mana_modifier: int
var attack_modifier: int
var magic_modifier: int
var defense_modifier: int
var speed_modifier: int
var accuracy_modifier: int
```

### `Consumable extends Item` — `items/consumable.gd`

```gdscript
var heal: int                 # applied out of combat
var mana: int                 # applied out of combat
var combat_action: ItemAction

func use_out_of_combat(member: CombatantData) -> void
```

---

## 4. Quests

### `Quest extends Resource` — `states/quests/quest.gd`

```gdscript
var id: String
var name: String
var type: String
var description: String
var root: QuestNode

func is_completed() -> bool
func progress() -> float      # 0.0 .. 1.0
```

### `QuestNode extends Resource` — `states/quests/quest_node.gd`

```gdscript
func is_completed() -> bool
func progress() -> float
```

| Subclass | Fields |
| --- | --- |
| `PersistenceGoal` | `key: String`, `expected_value: Variant = true` |
| `AllGoal` | `children: Array[QuestNode]` |
| `AnyGoal` | `children: Array[QuestNode]` |
| `SequenceGoal` | `children: Array[QuestNode]`, `get_current_child() -> QuestNode` |

---

## 5. Combat

### `Arena extends Node2D` — `combat/arena.gd`

The battlefield + turn hub. Reached through `CombatManager.start_combat()`.

```gdscript
signal battle_ended(victory: bool)

# Exports / config
var first_state: ArenaStateBase
var max_party_ult_charge: int
var max_boss_ult_charge: int

# Live
var current_state: ArenaStateBase
var party: Array[Combatant]
var enemies: Array[Combatant]
var action_queue: Array[ActionBase]
var pending_action: ActionBase
var is_boss: bool
var party_ult_charge: int
var boss_ult_charge: int
var target_indicator: TargetIndicator
var ui: ArenaUI          # %UI
var ai: EnemyAI          # %AI

# Stack hook
func enter(args) -> void                 # args = Array[EnemyData]
func start_battle(enemy_data: Array) -> void

# Turn flow
func change_state(new_state: ArenaStateBase) -> void
func get_current_combatant() -> Combatant
func submit_action(action: ActionBase) -> void
func submit_action_player(action: ActionBase) -> void
func check_player_turn_over() -> bool
func reset_turn_state() -> void
func start_over() -> void
func perform_action(action: ActionBase) -> void      # await; the per-action pipeline

# Targets / actions
func targets_for(action: ActionBase, actor: Combatant) -> Array[Combatant]
func targets_on_side(action: ActionBase, actor: Combatant) -> Array[Combatant]
func available_actions_for(actor: Combatant) -> Array[ActionBase]
func is_party_ult_full() -> bool
func is_boss_ult_full() -> bool

# Combatants
func get_alive_party() -> Array[Combatant]
func get_alive_enemies() -> Array[Combatant]
func get_all_alive_combatants() -> Array[Combatant]

# Ult / end
func change_ult_charge(amount: int, is_boss_side: bool) -> void
func has_battle_ended() -> bool
func end_battle(victory: bool) -> void
func refresh_ui() -> void
```

Internal helpers worth knowing: `_tick_statuses(combatant, timing)`, `_apply_action(action,
grade)`, `_item_actions_for(actor)`, `_combo_available(combo)`, `_collect_level_ups()`.

### `ArenaStateBase extends Node` — `combat/states/arena_state_base.gd`

```gdscript
@onready var arena: Arena = get_parent()
func enter() -> void
func exit() -> void
```

States are direct children of the arena. The five are `ActionSelectState`,
`TargetSelectState`, `QueueEnemyActionsState`, `ActionResolveState`, `EndTurnState`.

### `Combatant extends Node2D` — `combat/combatant.gd`

Runtime wrapper around a `CombatantData`.

```gdscript
signal died(combatant: Combatant)
signal damaged(amount: int)

var data: CombatantData
var actions: Array[ActionBase]
var is_player_controlled: bool
var is_blocking: bool
var resting_position: Vector2
var status_effects: Array[StatusEffect]

func setup(p_data: CombatantData, p_position: Vector2, p_player_controlled: bool) -> void
                                  # call AFTER add_child (@onready deps)

# Stats (equipment- and status-aware)
func get_attack() -> int
func get_magic() -> int
func get_defense() -> int
func get_speed() -> int
func get_accuracy() -> int
func get_max_health() -> int
func get_max_mana() -> int
func get_health() -> int
func get_mana() -> int
func get_display_name() -> String
func has_ult() -> bool
func is_alive() -> bool

# Health / mana
func take_damage(amount: int, piercing := false) -> int   # returns damage actually dealt
func receive_heal(amount: int) -> int
func receive_mana(amount: int) -> int
func spend_mana(amount: int) -> void

# State
func set_blocking(value: bool) -> void
func add_status(effect: StatusEffect) -> void
func remove_status(effect: StatusEffect) -> void
func set_selected(selected: bool) -> void
func refresh() -> void
func save_to_data() -> void            # writes live HP/MP back to data

# Movement (await)
func move_to(target_position: Vector2, duration := 0.25) -> void
func move_home(duration := 0.25) -> void
```

### `ActionBase extends Resource` — `combat/data/action_base.gd`

```gdscript
enum Type { ATTACK, HEAL, BLOCK, BUFF }
enum DamageType { PHYSICAL, MAGIC }
enum TargetSide { ENEMY, ALLY, SELF }

var display_name: StringName
var description: String
var type: Type
var damage_type: DamageType
var target_side: TargetSide
var mana_cost: int
var power: float
var piercing: bool
var uses_timing: bool
var hits_all: bool
var status: StatusEffect        # applied to each victim on hit
var ai_weights: AIActionWeights

# Runtime (set by the arena)
var source: Combatant
var target: Combatant

func is_available(actor: Combatant) -> bool
func get_value(actor: Combatant) -> int
func execute(actor: Combatant, victim: Combatant, grade: int) -> int
```

| Subclass | Adds |
| --- | --- |
| `Attack` | — (defaults to physical, enemy) |
| `Heal` | defaults to magic, ally |
| `Combo extends Attack` | `required_characters_names: Array[StringName]` |
| `Ultimate extends Attack` | `ult_charge_cost: int` |
| `ItemAction` | `item_id: StringName`, `heal: int`, `mana: int` (targets ally, no timing) |
| `StatusAction` | applies `status` only (targets enemy, no timing, power 0) |

### `StatusEffect extends Resource` — `combat/data/status_effect.gd`

```gdscript
enum Timing { START_OF_TURN, END_OF_TURN, END_OF_ROUND }

var display_name: StringName
var timing: Timing
var priority: int          # lower fires first; equal priority should be order-independent
var duration: int          # rounds; <= 0 never expires

func tick(target: Combatant) -> void
```

| Subclass | Field | Effect |
| --- | --- | --- |
| `DamageOverTime` | `damage: int` | deals `damage` (ignores defense) |
| `HealOverTime` | `heal: int` | restores `heal` |
| `StatModifier` | `stat: StringName`, `amount: int` | buff/debuff to a stat while active |

### `AIActionWeights extends Resource` — `combat/data/ai_action_weights.gd`

```gdscript
var hp_weight: float = 1.0
var target_low_hp: bool = true
var attack_weight: float = 0.0
var target_low_attack: bool = false
```

### `EnemyAI extends Node` — `combat/ai/enemy_ai.gd`

```gdscript
func choose_action(actor: Combatant, arena: Arena) -> ActionBase   # sets source/target
```

Heals a hurt ally if it can, else the strongest affordable attack; holds an enemy
`Ultimate` until `arena.is_boss_ult_full()`.

### `TimingGrade` — `combat/timing/timing_grade.gd` (static)

```gdscript
enum Grade { FAIL, BAD, OK, GOOD, SUPER, PERFECT }
const MULTIPLIERS: Dictionary
const COLORS: Dictionary

static func multiplier(grade: int) -> float
static func color(grade: int) -> Color
static func label(grade: int) -> String     # the enum name, e.g. "PERFECT"
```

### `TimingChallenge extends Node` — `combat/timing/timing_challenge.gd`

```gdscript
static func create() -> TimingChallenge      # Active or Relaxed, from GameSettings
func run(host: Control, source: Combatant, action: ActionBase) -> int   # await -> Grade
```

`Active` runs the QTE; `Relaxed` rolls from accuracy. Add a mode as a subclass + a
`create()` case.

### `QteBar extends Control` — `combat/qte/qte_bar.gd`

```gdscript
func setup(accuracy: int) -> void
func play() -> int                  # await; returns a TimingGrade.Grade
func grade_for(progress: float) -> int

var sweep_time: float
var band_perfect: float
var band_super: float
var band_good: float
var band_ok: float
var band_bad: float
var accuracy_window_bonus: float
```

### `ArenaUI extends Control` — `combat/ui/arena_ui.gd`

```gdscript
var timing_host: Control                     # mount point for the QTE

func show_action_menu(actions: Array[ActionBase], on_chosen: Callable, on_flee: Callable) -> void
func clear_action_menu() -> void
func set_actor(actor: Combatant) -> void
func refresh_all(combatants: Array) -> void
func show_message(text: String) -> void
func show_grade(grade: int) -> void
func setup_ult(max_party: int, max_boss: int, is_boss: bool) -> void
func update_ult(charge: int, is_boss: bool) -> void
func show_level_ups(entries: Array) -> void
func show_banner(text: String) -> void       # await
func wait_for_accept() -> void               # await
```

### `TargetIndicator extends Node2D` — `combat/ui/target_indicator.gd`

```gdscript
func choose(candidates: Array[Combatant]) -> Combatant   # await; null on cancel
```

---

## 6. World / level objects

### `SpawnPoint extends Marker2D` — `levels/objects/spawn_point.gd`

```gdscript
var spawn_id: String
var facing_direction: FacingDirection        # enum UP/LEFT/DOWN/RIGHT
func get_facing_vector() -> Vector2
```

### `Transition extends Node2D` (`@tool`) — `levels/objects/transtiston.gd`

```gdscript
var Transition_ID: String
var target_scene: String
var transition_scene: String
var hit_box_size: Vector2
var facing_direction: FacingDirection
```

Builds its own child `SpawnPoint` + `TransitionTrigger` + `CollisionShape2D` in-editor.

### `TransitionTrigger extends Area2D` (`@tool`) — `levels/objects/level_trigger.gd`

```gdscript
var spawn_id: String
var target_scene: String
var transition_scene: String
# body_entered -> LevelManager.change_level(target_scene, spawn_id, transition_scene)
```

### `EncounterArea extends Area2D` — `combat/encounter_area.gd`

```gdscript
var enemies: Array[EnemyData]
var victory_key: String
var quest: Quest
var one_shot: bool = true
# starts the battle when the Player walks in
```

### `combat_npc` (`characters/ch1/combat_npc.gd`, no `class_name`, extends `CharacterBody2D`)

```gdscript
var enemies: Array[EnemyData]
var victory_key: String
var quest: Quest
var texture: Texture2D
# pushes these into its Beehave StartCombat leaf in _ready()
```

---

## 7. Beehave leaves (`addons/beehave_additions/`)

All implement `tick(actor: Node, blackboard: Blackboard) -> int`.

| Class | Type | Exports |
| --- | --- | --- |
| `Interacted` | `ConditionLeaf` | `area: Area2D` |
| `EnteredArea` (in `enters_area.gd`) | `ConditionLeaf` | `area: Area2D`, `interaction_key: String` |
| `StartCombat` | `ActionLeaf` | `enemies: Array[EnemyData]`, `victory_key: String`, `quest: Quest` |
| `StartTimeline` | `ActionLeaf` | `timeline: DialogicTimeline`, `key: String` |
| `AddQuest` | `ActionLeaf` | `quest: Quest` |
| `HideNode` | `ActionLeaf` | `node: Node` |

---

## 8. Dialogic subsystems (`addons/dialogic_additions/`)

Access via `Dialogic.get_subsystem("Keys")` / `Dialogic.get_subsystem("Quests")`.

### Keys — `PersistenceKeys/subsystem_keys.gd`

```gdscript
signal key_changed(key, new_value, old_value)
signal key_erased(key)

func set_value(key: String, value: Variant = true) -> void
func increment(key: String, amount: Variant = 1) -> Variant
func erase(key: String) -> bool
func has(key: String) -> bool
func get_value(key: String, default = null) -> Variant
func is_true(key: String) -> bool
func get_number(key: String, default := 0.0) -> float
func get_string(key: String, default := "") -> String
func equals(key: String, expected: Variant) -> bool
func at_least(key: String, minimum: float) -> bool
func get_all() -> Dictionary
func keys_with_prefix(prefix: String) -> Array
```

### Quests — `Quest/subsystem_quests.gd`

```gdscript
signal quest_started(quest_id: String)
signal quest_completed(quest_id: String)

func start_quest(quest: Variant) -> bool
func has_quest(quest_id: String) -> bool
func get_quest(quest_id: String) -> Resource
func is_complete(quest_id: String) -> bool
func is_active(quest_id: String) -> bool
func get_progress(quest_id: String) -> float
func get_progress_percent(quest_id: String) -> int
func get_quest_ids() -> Array
func get_active_quest_ids() -> Array
func get_completed_quest_ids() -> Array
func refresh() -> void
func set_key(key: String, value: Variant = true) -> void
func has_key(key: String) -> bool
func get_key(key: String, default: Variant = false) -> Variant
```

Timeline events: `[key]`, `[if_key]`, `[quest]`, `[if_quest]`.
