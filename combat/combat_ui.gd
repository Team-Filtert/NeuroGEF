extends CanvasLayer
class_name CombatUIManager

@export var game_manager: GameManager

@export var character_selection_menu: HorizontalSelectableElements
@export var input_manager: InputComponent

@export var character_options_menu: HorizontalSelectableElements

@export var melee_menu: GridSelectableElements
@export var magic_menu: GridSelectableElements
@export var item_menu: GridSelectableElements

var in_melee_menu = false
var in_magic_menu = false
var in_item_menu = false

@export var melee_child_prefab: PackedScene

@export var item_child_prefab: PackedScene
func get_item_from_inventory(index: int):
	if game_manager.inventory.items.size() <= index:
		return null
	var item: Item = game_manager.inventory.items[index]

	var item_opt_prefab = item_child_prefab.instantiate() as SelectableButton
	item_opt_prefab.contained_object = item
	item_opt_prefab.text = item.item_name
	return item_opt_prefab


var selected_character: Character = null
var selected_action: CombatAction = null
var selected_target: Character = null
var selected_item: Item = null


##
## Combat Menu Route controllers
##

func character_selection():
	# Player selects charatcer to act
	character_selection_menu.init(func (player_char: Character):
		return player_char.is_player and player_char.stats.get_health() > 0
	)

	character_selection_menu.on_selected_element.connect(on_character_selected)
	# character_selection_menu.on_discarded.connect(on_character_discarded)

	var _is_discarded = await character_selection_menu.wait_for_selection_or_discarded()
	# await character_selection_menu.wait_for_selection()
	character_selection_menu.on_selected_element.disconnect(on_character_selected)
	# character_selection_menu.on_discarded.disconnect(on_character_discarded)

	if _is_discarded:
		selected_character = null
		# dont let the player softlock by immediately discarding character selection
		await character_selection()
	else:
		await option_selection()

func option_selection():
	# Player selects attack, items, magic, etc.
	character_options_menu.init()
	character_options_menu.on_selected_element.connect(on_option_selected)
	# await character_options_menu.wait_for_selection()
	# character_options_menu.on_discarded.connect(on_option_discarded)
	# var _is_discarded = await character_options_menu.wait_for_selection_or_discarded()
	var _is_discarded = await character_options_menu.wait_for_selection()
	character_options_menu.on_selected_element.disconnect(on_option_selected)
	# character_options_menu.on_discarded.disconnect(on_option_discarded)
	
	if _is_discarded:
		pass
		# Deprecated
		# await character_selection()
	else:
		if in_melee_menu:
			await melee_menu_selection()
		elif in_magic_menu:
			await magic_menu_selection()
		elif in_item_menu:
			await item_menu_selection()

func melee_menu_selection():
	melee_menu.init(func (index: int):
		if index >= selected_character.actions.size():
			return null
		var action = selected_character.actions[index]
		var melee_opt_prefab = melee_child_prefab.instantiate() as SelectableButton
		melee_opt_prefab.contained_object = action
		melee_opt_prefab.text = action.action_name
		return melee_opt_prefab
	)
	melee_menu.on_selected_element.connect(on_melee_option_selected)
	var _is_discarded = await melee_menu.wait_for_selection_or_discarded()
	melee_menu.on_selected_element.disconnect(on_melee_option_selected)

	melee_menu.clear_children()

	if _is_discarded:
		in_melee_menu = false
		character_options_menu.visible = true
		await option_selection()
		return
	
	if selected_action:
		await target_selection(melee_menu_selection, melee_menu)
		return

func magic_menu_selection():
	magic_menu.init(func (index: int):
		if index >= selected_character.magic.size():
			return null
		var magic_action = selected_character.magic[index]
		var magic_opt_prefab = melee_child_prefab.instantiate() as SelectableButton
		magic_opt_prefab.contained_object = magic_action
		magic_opt_prefab.text = magic_action.action_name
		return magic_opt_prefab
	)
	magic_menu.on_selected_element.connect(on_magic_option_selected)
	var _is_discarded = await magic_menu.wait_for_selection_or_discarded()
	magic_menu.on_selected_element.disconnect(on_magic_option_selected)

	magic_menu.clear_children()

	if _is_discarded:
		in_magic_menu = false
		character_options_menu.visible = true
		await option_selection()
		return
	
	if selected_action:
		await target_selection(magic_menu_selection, magic_menu)
		return

func item_menu_selection():
	item_menu.init(get_item_from_inventory)
	item_menu.on_selected_element.connect(on_item_option_selected)
	var _is_discarded = await item_menu.wait_for_selection_or_discarded()
	item_menu.on_selected_element.disconnect(on_item_option_selected)

	item_menu.clear_children()

	if _is_discarded:
		in_item_menu = false
		character_options_menu.visible = true
		await option_selection()
		return
	
	if selected_item:
		await item_target_selection(item_menu_selection, item_menu)
		return

func target_selection(prev_menu_selection: Callable, prev_menu_node: Control):
	character_selection_menu.visible = true
	character_selection_menu.init(func (target_char: Character):
		return selected_action.is_valid_target(selected_character, target_char)
	)
	character_selection_menu.on_selected_element.connect(on_target_selected)
	var _is_discarded = await character_selection_menu.wait_for_selection_or_discarded()
	character_selection_menu.on_selected_element.disconnect(on_target_selected)

	if _is_discarded:
		selected_target = null
		prev_menu_node.visible = true
		character_selection_menu.visible = false
		await prev_menu_selection.call()
		return

	selected_character.selected_action = selected_action.execute_action.bind(\
		selected_character, \
		selected_target, \
	)

func item_target_selection(prev_menu_selection: Callable, prev_menu_node: Control):
	character_selection_menu.visible = true
	character_selection_menu.init(func (target_char: Character):
		return selected_item.is_valid_target(selected_character, target_char)
	)
	character_selection_menu.on_selected_element.connect(on_target_selected)
	var _is_discarded = await character_selection_menu.wait_for_selection_or_discarded()
	character_selection_menu.on_selected_element.disconnect(on_target_selected)

	if _is_discarded:
		selected_target = null
		prev_menu_node.visible = true
		character_selection_menu.visible = false
		await prev_menu_selection.call()
		return

	selected_character.selected_action = selected_item.battle_use.bind(\
		selected_character, \
		selected_target, \
	)


##
## Main Input Functions
##

func get_user_input(character: Character = null):
	selected_character = null
	selected_action = null
	selected_target = null

	# character_selection_menu.visible = true
	# await input_manager.wait_accept_input()
	
	if not character:
		character_selection_menu.visible = true
		await character_selection()
	else:
		selected_character = character
		character_options_menu.visible = true
		await option_selection()
	

func get_bot_input(cur_char: Character):
	# get players from selectable children of character selection menu
	var all_children = Utils.get_all_children(character_selection_menu)
	var selectable_elements = all_children.filter(func (child): return child is Selectable)
	var player_characters = selectable_elements.map(func (el):
		var char_info: CharacterInfoPanel = el.selectable_node
		return char_info.character
	).filter(func (character): return character.is_player)

	cur_char.selected_action = cur_char.actions.pick_random().execute_action.bind(\
		cur_char, \
		player_characters.pick_random()
	)



##
## Signal Handlers
##

func on_character_selected(selected_el: Selectable):
	var char_info: CharacterInfoPanel = selected_el.selectable_node
	selected_character = char_info.character
	print("selected char player: " + str(selected_character.is_player))
	character_selection_menu.visible = false
	character_options_menu.visible = true

func on_character_discarded():
	selected_character = null
	await get_tree().create_timer(0.1).timeout
	await character_selection()

func on_option_selected(selected_el: Selectable):
	var option_button: SelectableButton = selected_el.selectable_node
	print("selected option: " + option_button.text)
	character_options_menu.visible = false
	if option_button.text == "MELEE":
		melee_menu.visible = true
		in_melee_menu = true
	elif option_button.text == "MAGIC":
		magic_menu.visible = true
		in_magic_menu = true
	elif option_button.text == "ITEMS":
		item_menu.visible = true
		in_item_menu = true
	elif option_button.text == "FLEE":
		# attempt to flee combat
		print("Attempting to flee combat...")
		# for now just end turn
		selected_character.selected_action = func ():
			print("Fled the battle!")
			return 1
	else:
		print("Unknown option selected")

func on_option_discarded():
	character_options_menu.visible = false
	character_selection_menu.visible = true
	selected_character = null

func on_melee_option_selected(selected_el: Selectable):
	var melee_button: SelectableButton = selected_el.selectable_node
	selected_action = melee_button.contained_object as MeleeCombatAction
	print("selected melee option: " + selected_action.action_name)
	in_melee_menu = false
	melee_menu.visible = false

func on_magic_option_selected(selected_el: Selectable):
	var magic_button: SelectableButton = selected_el.selectable_node
	selected_action = magic_button.contained_object as MagicCombatAction
	print("selected magic option: " + selected_action.action_name)
	in_magic_menu = false
	magic_menu.visible = false

func on_item_option_selected(selected_el: Selectable):
	var item_button: SelectableButton = selected_el.selectable_node
	print("selected item option: " + (item_button.contained_object as Item).item_name)
	selected_item = item_button.contained_object as Item
	in_item_menu = false
	item_menu.visible = false

func on_target_selected(selected_el: Selectable):
	var target_info: CharacterInfoPanel = selected_el.selectable_node
	selected_target = target_info.character
	print("selected target: " + str(selected_target.stats.get_health()))
	character_selection_menu.visible = false

# func on_target_discarded():
# 	selected_target = null
# 	character_selection_menu.visible = false
