extends Control

func _process(_delta: float) -> void:
	if Game.state:
		$PanelContainer/MarginContainer/Label.text = JSON.stringify(Game.state.to_dict(), "\t")
	else:
		$PanelContainer/MarginContainer/Label.text = "null"

func _on_test_pressed() -> void:
	pass
	#if not Game.state:
		#return

	#var health_potion: ConsumableItem = preload("res://experiments/data/consumables/health_potion.tres").duplicate()
	#var shiny_stone: CollectableItem = preload("res://experiments/data/collectables/shiny_stone.tres").duplicate()
	#var evil: PartyMember = preload("res://experiments/data/party_members/evil.tres").duplicate()

	# Might have to add helper methods to the Inventory and Party classes
	#Game.state.inventory.consumables.append(health_potion)
	#Game.state.inventory.collectables.append(shiny_stone)
	#Game.state.party.members.append(evil)

func _on_save_pressed() -> void:
	SaveManager.save()

# Null checks should be replaced with proper game phase checks
# I'll think of something, idk
# They do the trick at this stage though
func _on_level_1_pressed() -> void:
	pass
	#if not Game.state:
		#return

	#SceneManager.change_scene_to(preload("res://experiments/levels/level_01.tscn"))

func _on_level_2_pressed() -> void:
	pass
	#if not Game.state:
		#return

	#SceneManager.change_scene_to(preload("res://experiments/levels/level_02.tscn"))

func _on_menu_pressed() -> void:
	pass
	#if not Game.state:
		#return

	#SaveManager.save()
	# Maybe add a helper method for this too
	#Game.state = null
	#SceneManager.clear_ui()
	#SceneManager.clear_scene()
	#SceneManager.push_ui(preload("res://experiments/ui/main_menu.tscn"))
