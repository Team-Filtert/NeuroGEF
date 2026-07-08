class_name PartyState
extends RefCounted

var player_pos: Vector2:
	get:
		return PlayerManager._player.position
	set(value):
		PlayerManager._player.position = value

var player_sprites: Texture2D:
	get:
		return PlayerManager._player.get_node("Sprite2D").texture
	set(value):
		PlayerManager._player.get_node("Sprite2D").texture = value
