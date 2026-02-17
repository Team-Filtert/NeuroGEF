@tool
class_name NpcStandardBase
extends CharacterBody2D

func _ready() -> void:
	if Engine.is_editor_hint() and get_children().size() == 0:
		scale = Vector2(2, 2)
		var sprite_sheet = Npc8x2SpriteSheet.new()
		var animations = NpcWalkingAnimations.new()
		var foot_collider = NpcFootCollider.new()
		add_child(sprite_sheet)
		add_child(animations)
		add_child(foot_collider)
		sprite_sheet.owner = get_tree().edited_scene_root
		animations.owner = get_tree().edited_scene_root
		foot_collider.owner = get_tree().edited_scene_root
		sprite_sheet._set_defaults()
		animations._set_defaults()
		foot_collider._set_defaults()
