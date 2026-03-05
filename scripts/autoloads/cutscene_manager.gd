extends Node

signal done_action(node_name: StringName)

var direction_str_int: Dictionary[String, int] = {
	"up": 0,
	"down": 1,
	"left": 2,
	"right": 3
}

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_siganl)

func  _on_dialogic_siganl(argument: String):
	var args: PackedStringArray = argument.split(" ")
	var command: String =  args[0]
	args.remove_at(0)
	match command:
		"start_follow":
			start_follow(args)
		"stop_follow":
			stop_follow(args)
		"start_loop":
			start_loop(args)
		"stop_loop":
			stop_loop(args)
		"play_animation":
			play_animation(args)
		"move":
			move(args)
		_:
			push_error(command, " is not a command")

func start_follow(args: Array[String]):
	var npc: NpcStandardTemplate = get_node(args[0])
	npc.start_follow()

func stop_follow(args: Array[String]):
	var npc: NpcStandardTemplate = get_node(args[0])
	npc.stop_follow()

func start_loop(args: Array[String]):
	var npc: NpcStandardTemplate = get_node(args[0])
	var loop_name: StringName = args[1]
	npc.start_loop(loop_name)

func stop_loop(args: Array[String]):
	var npc: NpcStandardTemplate = get_node(args[0])
	var loop_name: StringName = args[1]
	npc.stop_loop(loop_name)

func play_animation(args: Array[String]):
	var npc: NpcStandardTemplate = get_node(args[0])
	var animation: StringName = args[1]
	var is_loop = "t" == args[2]
	npc.play_animation(animation, is_loop)
	if not is_loop:
		await npc.done_animation
		done_action.emit(npc.name)

func move(args: Array[String]):
	var npc: NpcStandardTemplate = get_node(args[0])
	var direction: int = direction_str_int[args[1]]
	var distance: float = float(args[2])
	var speed: float = float(args[3])
	npc.move(direction, distance, speed)
	await npc.done_moving
	done_action.emit(npc.name)
