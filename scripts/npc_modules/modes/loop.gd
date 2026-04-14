class_name NpcModeLoop
extends NpcModeBase

var actions: Array[NpcActionBase]

func _ready() -> void:
	for node in get_children():
		if node is NpcActionBase:
			actions.append(node)

func _activate() -> void:
	is_active = true
	while is_active:
		for action in actions:
			action._preform_action()
			if action.wait:
				await action.done_action

func _deactivate() -> void:
	is_active = false
