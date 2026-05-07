class_name Point
extends Node2D

enum Direction {UP, DOWN, LEFT, RIGHT}

var direction_to: Direction

func _init(x: float, y: float, d: Direction) -> void:
	direction_to = d
	position = Vector2(x, y)
