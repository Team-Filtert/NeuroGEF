extends CharacterBody2D

## A fightable overworld NPC, for building a lineup of battles.
##
## Press interact while close to start the fight (the tree's StartCombat leaf
## does the rest). Configure each placed instance with the enemies it fields and,
## optionally, a victory key / quest.

@export var enemies: Array[EnemyData] = []
@export var victory_key: String
@export var quest: Quest
## Optional sprite override (a walking sheet, like the other NPCs).
@export var texture: Texture2D
## Sprite-sheet layout of [member texture]. The defaults match the 3x4 NPC sheets.
@export var sprite_hframes: int = 3
@export var sprite_vframes: int = 4
@export var sprite_frame: int = 1


func _ready() -> void:
	if texture != null:
		var sprite := $Sprite2D as Sprite2D
		sprite.texture = texture
		sprite.hframes = maxi(sprite_hframes, 1)
		sprite.vframes = maxi(sprite_vframes, 1)
		sprite.frame = sprite_frame

	var leaf := get_node("BeehaveTree/SequenceComposite/StartCombat")
	leaf.enemies = enemies
	leaf.victory_key = victory_key
	leaf.quest = quest


func _process(_delta: float) -> void:
	if global_position.y >= PlayerManager.get_player_position().y:
		z_index = PlayerManager.get_player_z_index() + 1
	else:
		z_index = 0
