extends Resource
class_name CharacterResource

@export var char_name: String
@export var stats: Stat
@export var actions: Array[MeleeCombatAction]
@export var magic: Array[MagicCombatAction]

@export var battle_sprite: Texture2D
@export var animation_library: AnimationLibrary
