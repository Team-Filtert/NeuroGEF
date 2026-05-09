class_name UltDisplayHandler
extends Node

@onready var ult_lable: Label = $"../UltLabel"
@onready var ult_bar: ProgressBar = $"../UltBar"

var max_charge: int

func setup(charge: int, limit: int) -> void:
	max_charge = limit
	ult_bar.max_value = limit
	update(charge)

func update(charge: int):
	ult_lable.text = "ult charge: %d / %d" % [charge, max_charge]
	ult_bar.value = charge
