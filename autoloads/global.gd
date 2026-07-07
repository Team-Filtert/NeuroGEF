extends Node

const PLAYER_SCENE := preload("res://characters/player.tscn")

var _player_root: Node2D = null
var player: Player = null

func init(player_root: Node2D) -> void:
	_player_root = player_root
	
func spawn_player() -> void:
	if is_instance_valid(player):
		return
		
	player = PLAYER_SCENE.instantiate()
	_player_root.add_child(player)