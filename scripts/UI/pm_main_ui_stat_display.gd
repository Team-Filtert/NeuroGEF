extends Control


@onready var pm_name_tag: Label = $MarginContainer/HBoxContainer/VBoxContainer/pm_name_tag
@onready var pm_pfp: TextureRect = $MarginContainer/HBoxContainer/VBoxContainer/pm_pfp
@onready var pm_current_hp: Label = $MarginContainer/HBoxContainer/VBoxContainer2/pm_current_hp
@onready var pm_max_hp: Label = $MarginContainer/HBoxContainer/VBoxContainer2/pm_max_hp

@onready var party : Array[CombatantData] = PartyManager.combat_party
@export var pm_num : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var pm := party[pm_num]
	if pm.is_initialized:
		show()
	else:
		hide()
	var pm_name := pm.display_name
	if pm_num > 0:
		scale = Vector2(0.9, 0.9)
	pm_name_tag.text = pm_name
	pm_current_hp.text = str(pm.health)
	pm_max_hp.text = str(pm.max_health)
	var texture := pm.texture
	pm_pfp.texture = resize_to_fit(texture,Vector2i(30,30))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var pm := party[pm_num]
	if pm.is_initialized:
		show()
	else:
		hide()
	var pm_name := pm.display_name
	if pm_num > 0:
		scale = Vector2(0.9, 0.9)
	pm_name_tag.text = pm_name
	pm_current_hp.text = str(pm.health)
	pm_max_hp.text = str(pm.max_health)
	var texture := pm.texture
	pm_pfp.texture = resize_to_fit(texture,Vector2i(30,30))


func resize_to_fit(texture: Texture2D, max_size: Vector2i) -> Texture2D:
	var image = texture.get_image()
	var size = image.get_size()
	# print(size)

	var scale = min(
		float(max_size.x) / size.x,
		float(max_size.y) / size.y,
		1.0  # prevents upscaling (important)
  )

	var new_size = Vector2i(size.x * scale, size.y * scale)

	image.resize(new_size.x, new_size.y, Image.INTERPOLATE_BILINEAR)

	return ImageTexture.create_from_image(image)
