@tool
class_name NpcClose
extends NpcTriggerBase

func _ready() -> void:
	if Engine.is_editor_hint() and get_children().size() == 0:
		var body_area: NpcBodyArea = NpcBodyArea.new()
		add_child(body_area)
		body_area.owner = get_tree().edited_scene_root
		body_area._set_defaults()
		body_area.body_entered.connect(_on_body_entered, CONNECT_PERSIST)
	else:
		connect_actions()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		trigger_actions()
