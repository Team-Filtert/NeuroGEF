class_name QueuePartyActions
extends ArenaStateBase

@export var ui: Control

@export var attack_button: Button
@export var combo_button: Button
@export var item_button: Button
@export var flee_button: Button

@export var attack_menu: VBoxContainer
@export var combo_menu: VBoxContainer
@export var item_menu: VBoxContainer

func enter() -> void:
	attack_menu.visible = false
	combo_menu.visible = false
	item_menu.visible = false
	
	ui.visible = true

func exit() -> void:
	ui.visible = false

func _on_attack_button_pressed() -> void:
	attack_menu.visible = true
	combo_menu.visible = false
	item_menu.visible = false

func _on_combo_button_pressed() -> void:
	attack_menu.visible = false
	combo_menu.visible = true
	item_menu.visible = false

func _on_item_button_pressed() -> void:
	attack_menu.visible = false
	combo_menu.visible = false
	item_menu.visible = true

func _on_flee_button_pressed() -> void:
	pass # Replace with function body.
