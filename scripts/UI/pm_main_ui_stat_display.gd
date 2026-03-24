extends Control


@onready var pm_name_tag: Label = $MarginContainer/HBoxContainer/VBoxContainer/pm_name_tag
@onready var pm_pfp: TextureRect = $MarginContainer/HBoxContainer/VBoxContainer/pm_pfp
@onready var pm_current_hp: Label = $MarginContainer/HBoxContainer/VBoxContainer2/pm_current_hp
@onready var pm_max_hp: Label = $MarginContainer/HBoxContainer/VBoxContainer2/pm_max_hp

@onready var party : Array[CombatantData] = PartyManager.combat_party
@export var pm_num : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var pm := party[pm_num]
	var pm_name := pm.display_name
	pm_name_tag.text = pm_name
	pm_current_hp.text = str(pm.health)
	pm_max_hp.text = str(pm.max_health)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var pm := party[pm_num]
	var pm_name := pm.display_name
	pm_name_tag.text = pm_name
	pm_current_hp.text = str(pm.health)
	pm_max_hp.text = str(pm.max_health)
