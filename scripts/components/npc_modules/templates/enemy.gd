@tool
class_name NpcTemplateEnemy
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
		var close = NpcTriggerClose.new()
		var combat =  NpcActionCombat.new()
		var loop = NpcModeLoop.new()
		var move1 = NpcActionMove.new()
		var move2 = NpcActionMove.new()
		
		add_child(sprite_sheet)
		add_child(animation_player)
		add_child(animated_sprite)
		add_child(foot_collider)
		add_child(close)
		close.add_child(combat)
		add_child(loop)
		loop.add_child(move1)
		loop.add_child(move2)
		
		sprite_sheet.owner = get_tree().edited_scene_root
		animation_player.owner = get_tree().edited_scene_root
		animated_sprite.owner = get_tree().edited_scene_root
		foot_collider.owner = get_tree().edited_scene_root
		close.owner = get_tree().edited_scene_root
		combat.owner = get_tree().edited_scene_root
		loop.owner = get_tree().edited_scene_root
		move1.owner = get_tree().edited_scene_root
		move2.owner = get_tree().edited_scene_root
		
		sprite_sheet._set_defaults()
		animation_player._set_defaults()
		animated_sprite._set_defaults()
		foot_collider._set_defaults()
		
		close.name = "NpcTriggerClose"
		combat.name = "NpcActionCombat"
		loop.name = "NpcModeLoop"
		move1.name = "NpcActionMove1"
		move2.name = "NpcActionMove2"
		
		loop.is_active = true
		move1.template = self
		move2.template = self
		
	connect_nodes()

func _physics_process(delta: float) -> void:
	script_control(delta)
