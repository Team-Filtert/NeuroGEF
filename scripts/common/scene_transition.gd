@tool

class_name SceneTransition
extends Node2D


func _ready():
	if Engine.is_editor_hint() and get_children().size() == 0:
		var sprite = Sprite2D.new()
		sprite.texture = PlaceholderTexture2D.new()
		(sprite.texture as PlaceholderTexture2D).size = Vector2(32, 32)
		sprite.name = "Sprite2D"

		var coll_shape: CollisionShape2D = CollisionShape2D.new()
		coll_shape.shape = RectangleShape2D.new()
		(coll_shape.shape as RectangleShape2D).size = Vector2(32, 32)
		coll_shape.name = "CollisionShape2D"

		var coll_area = Area2D.new()
		coll_area.collision_layer = 2
		coll_area.collision_mask = 1
		coll_area.add_child(coll_shape)
		coll_area.name = "Area2D"

		var stc = SceneTransitionComponent.new()
		stc.collision_area = coll_area
		stc.name = "SceneTransitionComponent"

		add_child(sprite)
		sprite.owner = get_tree().edited_scene_root
		add_child(coll_area)
		coll_area.owner = get_tree().edited_scene_root
		coll_shape.owner = get_tree().edited_scene_root
		add_child(stc)
		stc.owner = get_tree().edited_scene_root
