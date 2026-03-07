@tool
extends Sprite2D

@export var whiteout_index: float = 0.0 :
	set(value):
		whiteout_index = value
		if not combatant_shader:
			combatant_shader = self.material
		combatant_shader.set_shader_parameter("white_out_index", whiteout_index)

@export var toggle_off_shader: bool = false :
	set(value):
		toggle_off_shader = value
		if not combatant_shader:
			combatant_shader = self.material
		combatant_shader.set_shader_parameter("toggle_off", toggle_off_shader)

@onready var combatant_shader: ShaderMaterial = self.material
