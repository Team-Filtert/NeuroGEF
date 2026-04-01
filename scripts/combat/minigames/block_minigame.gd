extends MiniGameBase
class_name BlockMinigame

@export var error_spread: float = 10
@export var indicator: Control
@export var weak_success_indicator: Control
@export var strong_success_indicator: Control

@export var animation_player: AnimationPlayer

@onready var input_handler: InputComponent = InputComponent.new()


var is_lost_by_time = true

func do_minigame(action: CombatantAction) -> void:
	minigame_completed.connect(handle_block_success.bind(action))
	animation_player.play("play")
	await animation_player.animation_finished

	if is_lost_by_time:
		complete_minigame(false, 0) # default to failure if player doesn't respond in time

func _check_indicator_in_weak_success() -> bool:
	var timing = indicator.get_rect().get_center().x
	# check if timing in weak success rect
	var weak_rect = weak_success_indicator.get_rect()
	return timing >= weak_rect.position.x - error_spread and timing <= weak_rect.position.x + weak_rect.size.x + error_spread

func _check_indicator_in_strong_success() -> bool:
	var timing = indicator.get_rect().get_center().x
	# check if timing in strong success rect
	var strong_rect = strong_success_indicator.get_rect()
	return timing >= strong_rect.position.x - error_spread and timing <= strong_rect.position.x + strong_rect.size.x + error_spread

func _input(event: InputEvent) -> void:
	if not input_handler:
		return

	if input_handler.get_accept_input(event):
		is_lost_by_time = false

		var weak_success = _check_indicator_in_weak_success()
		var strong_success = _check_indicator_in_strong_success()

		if strong_success:
			animation_player.play("success")
			await animation_player.animation_finished
			complete_minigame(true, 2)
		elif weak_success:
			animation_player.play("success")
			await animation_player.animation_finished
			complete_minigame(true, 1)
		else:
			complete_minigame(false, 0)

func handle_block_success(success: bool, value: int, action: BasicAttackAction):
	if success:
		action.target.set_blocking(true)
		action.attack_multiplier /= value
		action.action_result()
		action.attack_multiplier *= value
		action.target.set_blocking(false)
	else:
		action.action_result()
