extends Node

const PLAYER_SCENE := preload("res://characters/player.tscn")

var _player_root: Node2D = null
var _player: Player = null

func init(player_root: Node2D) -> void:
	_player_root = player_root
	
func spawn_player() -> void:
	if is_instance_valid(_player):
		return
		
	_player = PLAYER_SCENE.instantiate()
	_player_root.add_child(_player)
	
func despawn_player() -> void:
	if not is_instance_valid(_player):
		return
		
	_player.queue_free()
	_player = null