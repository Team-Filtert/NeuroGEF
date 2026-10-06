extends CharacterBody2D

## A fightable overworld NPC, for building a lineup of battles.
##
## Press interact while close to start the fight (the tree's StartCombat leaf
## does the rest). Configure each placed instance with the enemies it fields and,
## optionally, a victory key / quest.

@export var enemies: Array[EnemyData] = []
@export var victory_key: String
@export var quest: Quest
## Optional sprite override (a 3x4 walking sheet, like the other NPCs).
@export var texture: Texture2D


func _ready() -> void:
	if texture != null:
		$Sprite2D.texture = texture

	var leaf := get_node("BeehaveTree/SequenceComposite/StartCombat")
	leaf.enemies = enemies
	leaf.victory_key = victory_key
	leaf.quest = quest


func _process(_delta: float) -> void:
	if global_position.y >= PlayerManager.get_player_position().y:
		z_index = PlayerManager.get_player_z_index() + 1
	else:
		z_index = 0
