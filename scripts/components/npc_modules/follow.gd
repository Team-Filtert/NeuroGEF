class_name NpcFollow
extends Node

const speed: float = 200
const pref_dif: float = 70

enum Axis {X, Y}

@export var template: NpcStandardTemplate
@export var animation_player: NpcWalkingAnimationPlayer
@export var animated_sprite: NpcWalkingAnimatedSprite
@export var collider: NpcFootCollider
@export var target: Node2D

var points: Array[Point]

func _ready() -> void:
	collider.disabled = true
	var target_x_dif: float = target.position.x - template.position.x
	var target_y_dif: float = target.position.y - template.position.y
	if abs(target_x_dif) > abs(target_y_dif):
		if target_x_dif < 0:
			points.push_back(Point.new(target.position.x, target.position.y, Point.Direction.LEFT))
		else:
			points.push_back(Point.new(target.position.x, target.position.y, Point.Direction.RIGHT))
		template.position.y = target.position.y
	else:
		if target_y_dif < 0:
			points.push_back(Point.new(target.position.x, target.position.y, Point.Direction.UP))
		else:
			points.push_back(Point.new(target.position.x, target.position.y, Point.Direction.DOWN))
		template.position.x = target.position.x

func _physics_process(delta: float) -> void:
	var target_x_dif: float = target.position.x - template.position.x
	var target_y_dif: float = target.position.y - template.position.y
	var target_dif_abs: float = abs(target_x_dif) + abs(target_y_dif)
	
	if points.back().direction_to in [Point.Direction.UP, Point.Direction.DOWN]:
		if points.back().position.x > target.position.x:
			points.push_back(Point.new(target.position.x, target.position.y, Point.Direction.LEFT))
		elif points.back().position.x < target.position.x:
			points.push_back(Point.new(target.position.x, target.position.y, Point.Direction.RIGHT))
		elif points.back().direction_to == Point.Direction.UP \
		and points.back().position.y < target.position.y:
			points.pop_back()
			points.push_back(Point.new(target.position.x, target.position.y, Point.Direction.DOWN))
		elif points.back().direction_to == Point.Direction.DOWN \
		and points.back().position.y > target.position.y:
			points.pop_back()
			points.push_back(Point.new(target.position.x, target.position.y, Point.Direction.UP))
		else:
			points.back().position.y = target.position.y
	else:
		if points.back().position.y > target.position.y:
			points.append(Point.new(target.position.x, target.position.y, Point.Direction.UP))
		elif points.back().position.y < target.position.y:
			points.append(Point.new(target.position.x, target.position.y, Point.Direction.DOWN))
		elif points.back().direction_to == Point.Direction.LEFT \
		and points.back().position.x < target.position.x:
			points.pop_back()
			points.push_back(Point.new(target.position.x, target.position.y, Point.Direction.RIGHT))
		elif points.back().direction_to == Point.Direction.RIGHT \
		and points.back().position.x > target.position.x:
			points.pop_back()
			points.push_back(Point.new(target.position.x, target.position.y, Point.Direction.LEFT))
		else:
			points.back().position.x = target.position.x
	
	if points.front().direction_to in [Point.Direction.UP, Point.Direction.DOWN]:
		if points.front().position.y == template.position.y and points.size() > 1:
			points.pop_front()
	else:
		if points.front().position.x == template.position.x and points.size() > 1:
			points.pop_front()
	
	if target_dif_abs > pref_dif:
		match points.front().direction_to:
			Point.Direction.UP:
				move_up(points.front().position.y, delta)
			Point.Direction.DOWN:
				move_down(points.front().position.y, delta)
			Point.Direction.LEFT:
				move_left(points.front().position.x, delta)
			Point.Direction.RIGHT:
				move_right(points.front().position.x, delta)
	else:
		dont_move()

func move_up(point_pos: float, delta: float) -> void:
	var point_dif_abs: float = abs(point_pos - template.position.y)
	if speed * delta < point_dif_abs:
		template.velocity = Vector2.UP * speed
		template.move_and_slide()
	else:
		template.position.y = points.front().position.y
	if animation_player == null:
		animated_sprite.play("move_up")
	else:
		animation_player.play("move_up")

func move_down(point_pos: float, delta: float) -> void:
	var point_dif_abs: float = abs(point_pos - template.position.y)
	if speed * delta < point_dif_abs:
		template.velocity = Vector2.DOWN * speed
		template.move_and_slide()
	else:
		template.position.y = points.front().position.y
	if animation_player == null:
		animated_sprite.play("move_down")
	else:
		animation_player.play("move_down")

func move_left(point_pos: float, delta: float) -> void:
	var point_dif_abs: float = abs(point_pos - template.position.x)
	if speed * delta < point_dif_abs:
		template.velocity = Vector2.LEFT * speed
		template.move_and_slide()
	else:
		template.position.x = points.front().position.x
	if animation_player == null:
		animated_sprite.play("move_left")
	else:
		animation_player.play("move_left")

func move_right(point_pos: float, delta: float) -> void:
	var point_dif_abs: float = abs(point_pos - template.position.x)
	if speed * delta < point_dif_abs:
		template.velocity = Vector2.RIGHT * speed
		template.move_and_slide()
	else:
		template.position.x = points.front().position.x
	if animation_player == null:
		animated_sprite.play("move_right")
	else:
		animation_player.play("move_right")

func dont_move() -> void:
	template.velocity = Vector2.ZERO
	if animation_player == null:
		animated_sprite.play("idle_" + animated_sprite.animation.get_slice("_", 1))
	elif animation_player.current_animation != "":
		animation_player.play("idle_" + animation_player.current_animation.get_slice("_", 1))
