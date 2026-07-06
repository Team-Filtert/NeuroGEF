# I think the player stuff being here for now is fine.
# Will reconsider once this gets larger.
extends Node

const PLAYER_SCENE := preload("res://characters/player.tscn")

var _entity_root: Node2D = null
var player: CharacterBody2D = null

func initialize(entity_root: Node2D) -> void:
	_entity_root = entity_root

func spawn_player(at_position := Vector2.ZERO) -> void:
	if is_instance_valid(player):
		return

	player = PLAYER_SCENE.instantiate()
	_entity_root.add_child(player)
	player.global_position = at_position

func despawn_player() -> void:
	if not is_instance_valid(player):
		return

	player.queue_free()
	player = null

func reposition_player(at_position: Vector2) -> void:
	if not is_instance_valid(player):
		return
	
	player.global_position = at_position

func set_player_active(active: bool) -> void:
	if is_instance_valid(player):
		player.set_physics_process(active)
