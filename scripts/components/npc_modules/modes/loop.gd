class_name NpcLoop
extends Node

var is_looping: bool

var actions: Array[NpcActionBase]

func _ready() -> void:
	for node in get_children():
		if node is NpcActionBase:
			actions.append(node)

func start_loop() -> void:
	is_looping = true
	while is_looping:
		for action in actions:
			action._preform_action()
			if action.wait:
				await action.done_action

func stop_loop() -> void:
	is_looping = false
