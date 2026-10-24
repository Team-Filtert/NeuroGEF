extends Node2D

## One overworld party member trailing the leader in a line.
##
## Followers don't run their own movement; they sample the leader's position
## history, so the party snakes along the leader's path. Spawned by
## [PlayerManager]; [member frames_per_step] sets how far behind each one walks.

@export var frames_per_step := 24

var leader: Node2D
var index := 1


func setup(p_leader: Node2D, p_index: int, p_texture: Texture2D) -> void:
	leader = p_leader
	index = p_index
	var sprite := $Sprite2D as Sprite2D
	if p_texture != null:
		sprite.texture = p_texture


func _physics_process(_delta: float) -> void:
	if leader == null or not is_instance_valid(leader):
		return
	global_position = leader.get_trail_position(index * frames_per_step)
	z_index = leader.z_index
