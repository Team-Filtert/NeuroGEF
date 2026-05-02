class_name NpcModeFollow
extends NpcModeBase

const speed: float = 200
const pref_dif: float = 70

@export var template: NpcTemplateBase
@export var collider: NpcFootCollider
@export var target: Node2D

var points: Array[Point]

func _ready() -> void:
	start()

func _activate() -> void:
	if target == null:
		push_error("target is not set")
		return
	
	is_active = true
	collider.disabled = true
	
	var target_x_dif: float = target.position.x - template.position.x
	var target_y_dif: float = target.position.y - template.position.y
	if abs(target_x_dif) > abs(target_y_dif):
		if target_x_dif < 0:
			points.push_back(Point.new(target.position.x, target.position.y, Point.Direction.LEFT))
		else:
			points.push_back(Point.new(target.position.x, target.position.y, Point.Direction.RIGHT))
		if target_y_dif < 0:
			points.push_back(Point.new(target.position.x, target.position.y, Point.Direction.UP))
		else:
			points.push_back(Point.new(target.position.x, target.position.y, Point.Direction.DOWN))
	else:
		if target_y_dif < 0:
			points.push_back(Point.new(target.position.x, target.position.y, Point.Direction.UP))
		else:
			points.push_back(Point.new(target.position.x, target.position.y, Point.Direction.DOWN))
		if target_x_dif < 0:
			points.push_back(Point.new(target.position.x, target.position.y, Point.Direction.LEFT))
		else:
			points.push_back(Point.new(target.position.x, target.position.y, Point.Direction.RIGHT))

func _deactivate() -> void:
	is_active = false
	collider.disabled = false

func _physics_process(delta: float) -> void:
	if not is_active or target == null:
		return
	
	var target_x_dif: float = target.position.x - template.position.x
	var target_y_dif: float = target.position.y - template.position.y
	var target_dif_abs: float = abs(target_x_dif) + abs(target_y_dif)
	
	#add or update point
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
	
	#remove point if needed
	if points.size() > 1:
		match points.front().direction_to:
			Point.Direction.UP when points.front().position.y >= template.position.y:
				points.pop_front()
				template.position.y = points.front().position.y
			Point.Direction.DOWN when points.front().position.y <= template.position.y:
				points.pop_front()
				template.position.y = points.front().position.y
			Point.Direction.LEFT when points.front().position.x >= template.position.x:
				points.pop_front()
				template.position.x = points.front().position.x
			Point.Direction.RIGHT when points.front().position.x <= template.position.x:
				points.pop_front()
				template.position.x = points.front().position.x
	
	#move towards point
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
	template.animate("move_up")

func move_down(point_pos: float, delta: float) -> void:
	var point_dif_abs: float = abs(point_pos - template.position.y)
	if speed * delta < point_dif_abs:
		template.velocity = Vector2.DOWN * speed
		template.move_and_slide()
	else:
		template.position.y = points.front().position.y
	template.animate("move_down")

func move_left(point_pos: float, delta: float) -> void:
	var point_dif_abs: float = abs(point_pos - template.position.x)
	if speed * delta < point_dif_abs:
		template.velocity = Vector2.LEFT * speed
		template.move_and_slide()
	else:
		template.position.x = points.front().position.x
	template.animate("move_left")

func move_right(point_pos: float, delta: float) -> void:
	var point_dif_abs: float = abs(point_pos - template.position.x)
	if speed * delta < point_dif_abs:
		template.velocity = Vector2.RIGHT * speed
		template.move_and_slide()
	else:
		template.position.x = points.front().position.x
	template.animate("move_right")

func dont_move() -> void:
	template.velocity = Vector2.ZERO
	template.animate("idle_" + template.current_animation.get_slice("_", 1))
