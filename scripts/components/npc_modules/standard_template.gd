@tool
class_name NpcStandardTemplate
extends CharacterBase

var sprite_sheet: Npc8x2SpriteSheet
var foot_collider: NpcFootCollider
var follower: NpcFollow
var loops: Array[NpcLoop] = []

func _ready() -> void:
	if Engine.is_editor_hint() and get_children().size() == 0:
		scale = Vector2(2, 2)
		
		sprite_sheet = Npc8x2SpriteSheet.new()
		animation_player = NpcWalkingAnimationPlayer.new()
		animated_sprite = NpcWalkingAnimatedSprite.new()
		foot_collider = NpcFootCollider.new()
		
		add_child(sprite_sheet)
		add_child(animation_player)
		add_child(animated_sprite)
		add_child(foot_collider)
		
		sprite_sheet.owner = get_tree().edited_scene_root
		animation_player.owner = get_tree().edited_scene_root
		animated_sprite.owner = get_tree().edited_scene_root
		foot_collider.owner = get_tree().edited_scene_root
		
		sprite_sheet._set_defaults()
		animation_player._set_defaults()
		animated_sprite._set_defaults()
		foot_collider._set_defaults()
	
	connect_animation_nodes()
	follower = get_children().filter(func(node): return node is NpcFollow).front()
	for node in get_children():
		if node is NpcLoop:
			loops.push_back(node)

func _physics_process(delta: float) -> void:
	script_control(delta)

func toggle_follow() -> void:
	if follower == null:
		push_error("follow node is missing")
	elif follower.is_following:
		follower.stop_follow()
	else:
		follower.start_follow()

func toggle_loop(loop_name: StringName) -> void:
	var loop: NpcLoop = loops.filter(func(node): return node.name == loop_name).front()
	if loop == null:
		push_error("loop node ", loop_name,  " is missing")
	elif loop.is_looping:
		loop.stop_loop()
	else:
		loop.start_loop()
