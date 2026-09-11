extends Control

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		GameState.push("res://ui/ui_scenes/main_menu.tscn")

func enter(args) -> void:
	pass # Replace with function body.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
