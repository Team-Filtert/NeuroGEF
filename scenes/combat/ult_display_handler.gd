class_name UltDisplayHandler
extends Node

@onready var party_ult_lable: Label = $"../PlayerUltLabel"
@onready var party_ult_bar: ProgressBar = $"../PlayerUltBar"
@onready var boss_ult_lable: Label = $"../BossUltLabel"
@onready var boss_ult_bar: ProgressBar = $"../BossUltBar"

var party_max_charge: int
var boss_max_charge: int

func setup(player_charge: int, player_max: int,
		boss_max: int, is_boss: bool) -> void:
	_setup_party(player_charge, player_max)
	_setup_boss(boss_max , is_boss)

func update(charge: int, is_boss) -> void:
	if is_boss:
		_update_boss(charge)
	else:
		_update_party(charge)

func _setup_party(charge: int, max_charge: int) -> void:
	party_max_charge = max_charge
	party_ult_bar.max_value = party_max_charge
	_update_party(charge)

func _setup_boss(max_charge: int, is_boss: bool) -> void:
	if is_boss:
		boss_max_charge = max_charge
		boss_ult_bar.max_value = boss_max_charge
		_update_boss(0)
	boss_ult_lable.visible = is_boss
	boss_ult_bar.visible = is_boss

func _update_party(charge: int) -> void:
	party_ult_lable.text = "ult: %d / %d" % [charge, party_max_charge]
	party_ult_bar.value = charge

func _update_boss(charge: int) -> void:
	boss_ult_lable.text = "ult: %d / %d" % [charge, boss_max_charge]
	boss_ult_bar.value = charge
