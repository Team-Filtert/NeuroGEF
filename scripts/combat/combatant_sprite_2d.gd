@tool
extends Sprite2D

@export var whiteout_index: float = 0.0 :
	set(value):
		whiteout_index = value
		# if not combatant_shader:
		# 	combatant_shader = self.material.duplicate()

		combatant_shader.set_shader_parameter("white_out_index", whiteout_index)

@onready var combatant_shader: ShaderMaterial = self.material
