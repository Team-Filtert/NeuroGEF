class_name CombatantData
extends Resource

## Shared definition of a fighter (party member or enemy).
##
## Everything is exported so it can be authored in the inspector. The live
## HP/MP live here too, so a party member's state survives between battles and
## [PartyMember] can serialize it.
##
## Stats follow the design notes: HP, MP, speed, attack, magic, defense, accuracy.
## An action is physical, magic or both depending on which stat it scales off.

@export var display_name: StringName = &"Fighter"
@export var texture: Texture2D
## Sprite-sheet layout of [member texture]; leave at 1x1 for a single image.
@export var sprite_hframes: int = 1
@export var sprite_vframes: int = 1
@export var sprite_frame: int = 0

@export_group("Stats")
@export var max_health: int = 10
@export var max_mana: int = 10
@export var attack: int = 1
@export var magic: int = 1
@export var defense: int = 1
@export var speed: int = 1
## Makes the timing window wider (active mode) / better results likelier
## (relaxed mode).
@export var accuracy: int = 0

@export_group("Actions")
@export var actions: Array[ActionBase] = []

# Live values. Kept out of the inspector so the editor edits the "max" values.
var health: int = 0
var mana: int = 0
var _initialized := false


## Fills HP/MP on first use. Party members keep whatever they had; see [Combatant].
func ensure_initialized() -> void:
	if _initialized:
		return
	health = max_health
	mana = max_mana
	_initialized = true


func has_ult() -> bool:
	return actions.any(func(action: ActionBase) -> bool: return action is Ultimate)
