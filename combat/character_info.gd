extends MarginContainer
class_name CharacterInfoPanel

@export var char_name_label: Label
@export var health_bar: ProgressBar
@export var mana_bar: ProgressBar

@export var select_indicator: Control

@export var character: Character

var is_valid: bool = true
func get_is_valid():
	return is_valid

func init(validate_func: Callable = Callable()):
	health_bar.max_value = character.stats.max_hp
	health_bar.value = character.stats.get_health()
	mana_bar.max_value = character.stats.max_mp
	mana_bar.value = character.stats.get_mana()
	if validate_func.is_valid():
		self.is_valid = validate_func.call(character)

	if not character.on_health_changed.is_connected(health_changed):
		character.on_health_changed.connect(health_changed)
	if not character.on_mana_changed.is_connected(mana_changed):
		character.on_mana_changed.connect(mana_changed)
	
	if not get_is_valid():
		modulate = Color(1, 1, 1, 0.5)
	else:
		modulate = Color(1, 1, 1, 1)

func set_selected(is_select: bool):
	select_indicator.visible = is_select

func get_selected():
	return select_indicator.visible

func health_changed(health: int):
	print("health changed: " + str(health))
	health_bar.value = health

func mana_changed(mana: int):
	mana_bar.value = mana

func select_process():
	print("selected character")
