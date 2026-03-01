class_name NpcTriggerDialogicSignal
extends NpcTriggerBase

@export var signal_argument: String

func _ready() -> void:
	Dialogic.signal_event.connect(_on_signal)
	connect_actions()

func _on_signal(argument: String):
	if argument == signal_argument:
		trigger_actions()
