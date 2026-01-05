extends CanvasLayer
class_name DialogueUIManager

@export var dialogue_manager: DialogueManager

@export var text_label: RichTextLabel
@export var text_type_timer: Timer
@export var default_font_size: int = 46
@export var visible_line_count: int = 2
@export var next_line_indicator: NextLineIndicator

@export var left_character_sprite: TextureRect
@export var right_character_sprite: TextureRect

@export var input_component: InputComponent

var current_dialogue_scene: DialogueScene

var current_text_line: String = ""
var current_line: int = 0

var scene_line_count: int:
	get:
		if current_dialogue_scene == null:
			return 0
		return current_dialogue_scene.lines.size()

var current_scene_line_index: int = 0

@export var debug_dialogue_scene: DialogueScene

func init(dscene: DialogueScene = null):
	if dscene == null:
		# current_text_line = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
		current_dialogue_scene = debug_dialogue_scene
	else:
		current_dialogue_scene = dscene

	if not text_type_timer.is_connected("timeout", _on_text_type_timer_timeout):
		text_type_timer.connect("timeout", _on_text_type_timer_timeout)
	
	current_scene_line_index = -1
	new_line_process()

func new_line_process():
	current_scene_line_index += 1
	if current_scene_line_index >= scene_line_count:
		# End of dialogue scene
		print("End of dialogue scene reached")
		dialogue_manager.finish_dialogue()
		return

	var current_line_data: DialogueLine = current_dialogue_scene.lines[current_scene_line_index]	

	if current_line_data.character_left != null:
		left_character_sprite.visible = true
		left_character_sprite.texture = current_line_data.character_left.sprite
	else:
		left_character_sprite.visible = false

	if current_line_data.character_right != null:
		right_character_sprite.visible = true
		right_character_sprite.texture = current_line_data.character_right.sprite
	else:
		right_character_sprite.visible = false
	
	current_text_line = current_line_data.text

	current_line = 0
	next_line_indicator.is_next_line_ready = false

	# RichTextLabel is weird
	# text_label.clear()
	# text_label.add_text("*")
	text_label.text = ""
	# text_label.push_context()
	# text_label.text
	text_label.text = "[font_size=" + str(default_font_size) + "]"
	# text_label.bbcode_text = ""
	
	text_type_timer.start()

func _on_text_type_timer_timeout():
	if current_text_line.length() > 0:
		var next_char: String = current_text_line.substr(0, 1)
		current_text_line = current_text_line.substr(1, current_text_line.length() - 1)
		text_label.append_text(next_char)
	else:
		text_type_timer.stop()
		text_label.append_text("[/font_size]")
		next_line_indicator.is_next_line_ready = true

func _process(_delta):
	if not visible:
		return
	
	var scroll_up = input_component.get_directional_input(true).y < 0
	var scroll_down = input_component.get_directional_input(true).y > 0

	var next_line_input = input_component.get_accept_input()
	
	if next_line_input:
		if text_type_timer.is_stopped() == false:
			# Finish text instantly
			text_label.append_text(current_text_line)
			current_text_line = ""
			text_type_timer.stop()
			next_line_indicator.is_next_line_ready = true
		else:
			var line_count: int = text_label.get_line_count() - 1
			# Scroll down if player didn't see all text
			if current_line < line_count - 1:
				current_line = clamp(current_line + visible_line_count, 0, line_count)
				text_label.scroll_to_line(current_line)
			elif next_line_indicator.is_next_line_ready:
				new_line_process()
	
	if scroll_down:
		var line_count: int = text_label.get_line_count() - 1
			# Scroll down if player didn't see all text
		if current_line < line_count:
			current_line = clamp(current_line + visible_line_count, 0, line_count)
			text_label.scroll_to_line(current_line)
	
	if scroll_up:
		var line_count: int = text_label.get_line_count() - 1
		if current_line > 0:
			current_line = clamp(current_line - visible_line_count, 0, line_count)
			text_label.scroll_to_line(current_line)
	
	# if next_line_input and next_line_indicator.is_next_line_ready:
	# 	new_line_process()
