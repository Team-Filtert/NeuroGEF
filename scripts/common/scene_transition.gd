@tool

class_name SceneTransition
extends Node2D


var default_dir : String




@export_group("Transition Target")
@export var transition_id : String:
	set(value):
		transition_id = value
		up_all()
@export var transition_to_id : String:
	set(value):
		transition_to_id = value
		up_all()
@export_dir var scene_directory: String = "":
	set(value):
		if value == "" and Engine.is_editor_hint():
			if get_tree():
				default_dir = get_tree().edited_scene_root.scene_file_path.get_base_dir()
				if ! default_dir.ends_with("/"):
					default_dir += "/"
				scene_directory = default_dir
		else:
			scene_directory = value
		up_all()
@export var to_scene_name: String:
	set(value):
		to_scene_name = value
		up_all()
@export_enum("Up:0", "Down:2", "Left:3","Right:1") var dir: int = 0:
	set(value):
		dir = value
		up_all()
@export_group("Texture")
@export var show_texture : bool = true:
	set(value):
		show_texture = value
		up_all()
@export var texture: Resource:
	set(value):
		texture = value
		up_all()
@export var lock_hit_bot_to_texture_size : bool:
	set(value):
		lock_hit_bot_to_texture_size = value
		if lock_hit_bot_to_texture_size:
			hit_box_size = texture_size
@export var texture_size = Vector2(32, 32):
	set(value):
		texture_size = value
		if lock_hit_bot_to_texture_size and hit_box_size != value:
			hit_box_size = value
		up_all()
@export var hit_box_size = Vector2(32, 32):
	set(value):
		hit_box_size = value
		if lock_hit_bot_to_texture_size and texture_size != value:
			texture_size = value
		up_all()
@export_group("")

func up_stc(stc:SceneTransitionComponent):
	stc.transition_id = transition_id
	stc.transition_to_id = transition_to_id
	stc.to_scene_name = to_scene_name
	stc.scene_directory = scene_directory
	stc.dir = dir


func up_sprite(sprite:Sprite2D):
	if show_texture:
		sprite.show()
	else:
		sprite.hide()
	if texture:
		sprite.texture = texture
	else:
		sprite.texture = PlaceholderTexture2D.new()
	(sprite.texture as PlaceholderTexture2D).size = texture_size

func up_area(area:Area2D):
	var box : CollisionShape2D = area.get_children()[0]
	box.shape = RectangleShape2D.new()
	(box.shape as RectangleShape2D).size = hit_box_size


func up_all():
	for child in get_children():
		if child.name == "SceneTransitionComponent":
			up_stc(child)
		elif child.name == "Sprite2D":
			up_sprite(child)
		elif child.name == "Area2D":
			up_area(child)

func _ready():
	if Engine.is_editor_hint() and get_children().size() == 0:
		var sprite = Sprite2D.new()
		up_sprite(sprite)
		sprite.name = "Sprite2D"

		var coll_shape: CollisionShape2D = CollisionShape2D.new()
		coll_shape.shape = RectangleShape2D.new()
		(coll_shape.shape as RectangleShape2D).size = hit_box_size
		coll_shape.name = "CollisionShape2D"

		var coll_area = Area2D.new()
		coll_area.collision_layer = 2
		coll_area.collision_mask = 1
		coll_area.add_child(coll_shape)
		coll_area.name = "Area2D"

		var stc = SceneTransitionComponent.new()
		stc.collision_area = coll_area
		up_stc(stc)
		stc.name = "SceneTransitionComponent"

		add_child(sprite)
		sprite.owner = get_tree().edited_scene_root
		add_child(coll_area)
		coll_area.owner = get_tree().edited_scene_root
		coll_shape.owner = get_tree().edited_scene_root
		add_child(stc)
		stc.owner = get_tree().edited_scene_root
	else:
		for child in get_children():
			if child.name == "SceneTransitionComponent":
				up_stc(child)
				child._ready()
			elif child.name == "Sprite2D":
				up_sprite(child)
			elif child.name == "Area2D":
				up_area(child)
