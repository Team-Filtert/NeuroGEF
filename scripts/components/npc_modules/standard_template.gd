@tool
class_name NpcStandardTemplate
extends CharacterBody2D

func _ready() -> void:
	if Engine.is_editor_hint() and get_children().size() == 0:
		scale = Vector2(2, 2)
		
		var sprite_sheet = Npc8x2SpriteSheet.new()
		var animation_player = NpcWalkingAnimationPlayer.new()
		var animated_sprite = NpcWalkingAnimatedSprite.new()
		var foot_collider = NpcFootCollider.new()
		
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
