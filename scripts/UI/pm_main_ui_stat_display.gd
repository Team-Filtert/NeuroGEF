extends Control


@onready var pm_name_tag: Label = $MarginContainer/HBoxContainer/VBoxContainer/pm_name_tag
@onready var pm_pfp: TextureRect = $MarginContainer/HBoxContainer/VBoxContainer/pm_pfp
@onready var hp_label: Label = $"MarginContainer/HBoxContainer/VBoxContainer3/HP Label"
@onready var hp_bar: ProgressBar = $"MarginContainer/HBoxContainer/VBoxContainer3/HP bar"
@onready var mp_label: Label = $"MarginContainer/HBoxContainer/VBoxContainer3/MP Label"
@onready var mp_bar: ProgressBar = $"MarginContainer/HBoxContainer/VBoxContainer3/MP bar"
@onready var box2: VBoxContainer = $MarginContainer/HBoxContainer/VBoxContainer3

@onready var party : Array[CombatantData] = PartyManager.combat_party
@export var pm_num : int = 0

var is_expanded : bool = false

func _ready() -> void:
	var pm := party[pm_num]
	if pm.is_initialized:
		show()
	else:
		hide()
		return
	var pm_name := pm.display_name
	
	pm_name_tag.text = pm_name
	var texture := pm.texture
	pm_pfp.texture = resize_to_fit(texture,Vector2i(30,30))
	hp_bar.max_value = pm.max_health
	hp_bar.value = pm.health
	hp_label.text = 'HP: ' + str(pm.health) + "/" + str(pm.max_health)
	mp_bar.max_value = pm.max_mana
	mp_bar.value = pm.mana
	mp_label.text = 'MP: ' + str(pm.mana) + "/" + str(pm.max_mana)

func _process(_delta: float) -> void:
	var pm := party[pm_num]
	if pm.is_initialized:
		show()
	else:
		hide()
		return
	var pm_name := pm.display_name

	pm_name_tag.text = pm_name
	var texture := pm.texture
	pm_pfp.texture = resize_to_fit(texture,Vector2i(30,30))
	hp_bar.max_value = pm.max_health
	hp_bar.value = pm.health
	hp_label.text = 'HP: ' + str(pm.health) + "/" + str(pm.max_health)
	mp_bar.max_value = pm.max_mana
	mp_bar.value = pm.mana
	mp_label.text = 'MP: ' + str(pm.mana) + "/" + str(pm.max_mana)


func resize_to_fit(texture: Texture2D, max_size: Vector2i) -> Texture2D:
	var image = texture.get_image()
	var temp_size = image.get_size()

	var cur_scale = min(
		float(max_size.x) / temp_size.x,
		float(max_size.y) / temp_size.y,
		1.0  # prevents upscaling (important)
  )

	var new_size = Vector2i(temp_size.x * cur_scale, temp_size.y * cur_scale)

	image.resize(new_size.x, new_size.y, Image.INTERPOLATE_BILINEAR)

	return ImageTexture.create_from_image(image)
