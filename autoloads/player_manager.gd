extends Node

const PLAYER_SCENE: PackedScene = preload("res://characters/playable/player.tscn")
const FOLLOWER_SCENE: PackedScene = preload("res://characters/playable/party_follower.tscn")

var _player_root: Node2D
var _player: CharacterBody2D
var _followers: Array[Node2D] = []

func init(player_root: Node2D) -> void:
	_player_root = player_root
	print("PlayerManager initialized", _player_root)

func spawn_player(position := Vector2.ZERO) -> void:
	if is_instance_valid(_player):
		return
		
	_player = PLAYER_SCENE.instantiate()
	_player.global_position = position
	_player_root.add_child(_player)
	_spawn_followers()

func despawn_player() -> void:
	if not is_instance_valid(_player):
		return
		
	_clear_followers()
	_player.queue_free()
	_player = null

func set_player_active(active: bool) -> void:
	if not is_instance_valid(_player):
		return

	_player.set_active(active)
	for follower in _followers:
		if is_instance_valid(follower):
			follower.set_physics_process(active)
	
func set_player_position(position: Vector2) -> void:
	if not is_instance_valid(_player):
		return
	
	_player.global_position = position
	_player.reset_trail()
	for follower in _followers:
		if is_instance_valid(follower):
			follower.global_position = position
	
func get_player_position() -> Vector2:
	return _player.global_position if is_instance_valid(_player) else Vector2.ZERO
	
func get_player_z_index() -> int:
	return _player.z_index
	
func set_player_facing(facing: Vector2) -> void:
	if not is_instance_valid(_player):
		return
		
	_player.set_facing(facing)

func get_player() -> CharacterBody2D:
	return _player

func follower_count() -> int:
	return _followers.size()


## Spawns one follower per extra party member (party[1..]).
func _spawn_followers() -> void:
	_clear_followers()
	if GameState.party == null:
		return
	var members := GameState.party.members
	for i in range(1, members.size()):
		var follower: Node2D = FOLLOWER_SCENE.instantiate()
		follower.setup(_player, i, members[i].texture)
		follower.global_position = _player.global_position
		_player_root.add_child(follower)
		_followers.append(follower)


func _clear_followers() -> void:
	for follower in _followers:
		if is_instance_valid(follower):
			follower.queue_free()
	_followers.clear()
