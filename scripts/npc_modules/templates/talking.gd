@tool
class_name NpcTemplateTalking
extends NpcTemplateBase

var sprite_sheet: Npc8x2SpriteSheet
var foot_collider: NpcFootCollider

func _ready() -> void:
	if Engine.is_editor_hint() and get_children().size() == 0:
		scale = Vector2(2, 2)
		
		sprite_sheet = Npc8x2SpriteSheet.new()
		animation_player = NpcWalkingAnimationPlayer.new()
		animated_sprite = NpcWalkingAnimatedSprite.new()
		foot_collider = NpcFootCollider.new()
		var interact = NpcTriggerInteract.new()
		var dialog = NpcActionDialog.new()
		
		add_child(sprite_sheet)
		add_child(animation_player)
		add_child(animated_sprite)
		add_child(foot_collider)
		add_child(interact)
		interact.add_child(dialog)
		
		sprite_sheet.owner = get_tree().edited_scene_root
		animation_player.owner = get_tree().edited_scene_root
		animated_sprite.owner = get_tree().edited_scene_root
		foot_collider.owner = get_tree().edited_scene_root
		interact.owner = get_tree().edited_scene_root
		dialog.owner = get_tree().edited_scene_root
		
		sprite_sheet._set_defaults()
		animation_player._set_defaults()
		animated_sprite._set_defaults()
		foot_collider._set_defaults()
		
		interact.name = "NpcTriggerInteract"
		dialog.name = "NpcActionDialog"
		
	connect_nodes()

func _physics_process(delta: float) -> void:
	script_control(delta)
