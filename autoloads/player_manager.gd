extends Node

const PLAYER_SCENE: PackedScene = preload("res://characters/playable/player.tscn")

var _player_root: Node2D
var _player: CharacterBody2D

func init(player_root: Node2D) -> void:
	_player_root = player_root

func spawn_player(position := Vector2.ZERO) -> void:
	if is_instance_valid(_player):
		return
		
	_player = PLAYER_SCENE.instantiate()
	_player.global_position = position
	_player_root.add_child(_player)

func despawn_player() -> void:
	if not is_instance_valid(_player):
		return
		
	_player.queue_free()
	_player = null

func set_player_active(active: bool) -> void:
	_player.set_active(active)
	
func set_player_position(position: Vector2) -> void:
	if not is_instance_valid(_player):
		return
	
	_player.global_position = position
	
func get_player_position() -> Vector2:
	return _player.global_position if is_instance_valid(_player) else Vector2.ZERO
	
func get_player_z_index() -> int:
	return _player.z_index
	
func set_player_facing(facing: Vector2) -> void:
	if not is_instance_valid(_player):
		return
		
	_player.set_facing(facing)
