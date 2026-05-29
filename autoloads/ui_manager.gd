extends Node

var ui_layer: CanvasLayer
var ui_stack: Array[Node] = []

func push_ui(scene: PackedScene) -> void:
	if not ui_stack.is_empty():
		ui_stack.back().hide()
		
	var node := scene.instantiate()

	ui_layer.add_child(node)
	ui_stack.append(node)

func pop_ui() -> void:
	if ui_stack.is_empty():
		return

	ui_stack.back().queue_free()
	ui_stack.pop_back()
	
	# TODO: Do something about this being hardcoded
	if not ui_stack.is_empty():
		ui_stack.back().show()

func clear_ui() -> void:
	if ui_stack.is_empty():
		return

	for node in ui_stack:
		node.queue_free()
		
	ui_stack.clear()
