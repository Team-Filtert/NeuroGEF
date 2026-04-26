@tool
class_name NpcTemplateChest
extends NpcTemplateBase

var sprite_sheet: Npc8x2SpriteSheet
var tile_collider: NpcTileCollider

func _ready() -> void:
	if Engine.is_editor_hint() and get_children().size() == 0:
		
		sprite_sheet = Npc8x2SpriteSheet.new()
		animation_player = NpcWalkingAnimationPlayer.new()
		animated_sprite = NpcWalkingAnimatedSprite.new()
		tile_collider = NpcTileCollider.new()
		audio_player = NpcAudioPlayer.new()
		var interact = NpcTriggerInteract.new()
		var transaction = NpcActionTransaction.new()
		
		add_child(sprite_sheet)
		add_child(animation_player)
		add_child(animated_sprite)
		add_child(tile_collider)
		add_child(audio_player)
		add_child(interact)
		interact.add_child(transaction)
		
		sprite_sheet.owner = get_tree().edited_scene_root
		animation_player.owner = get_tree().edited_scene_root
		animated_sprite.owner = get_tree().edited_scene_root
		tile_collider.owner = get_tree().edited_scene_root
		audio_player.owner = get_tree().edited_scene_root
		interact.owner = get_tree().edited_scene_root
		transaction.owner = get_tree().edited_scene_root
		
		sprite_sheet._set_defaults()
		animation_player._set_defaults()
		animated_sprite._set_defaults()
		tile_collider._set_defaults()
		audio_player._set_defaults()
		
		interact.name = &"NpcTriggerInteract"
		transaction.name = &"NpcActionTransaction"
		
	setup()

func _physics_process(delta: float) -> void:
	script_control(delta)
