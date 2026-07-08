extends Node

# Followers only - the player itself is owned by PlayerManager, not tracked
# here, since the new Player (characters/playable/player.gd) isn't a
# CharacterBase and doesn't live under a pre-placed scene node anymore.
var party_container: Node2D

var combat_party: Array[CombatantData] = []
var overworld_party: Array[Node2D] = []

func _ready() -> void:
	party_container = Node2D.new()
	party_container.name = "PartyContainer"
	add_child(party_container)

	# PlayerManager needs a root to spawn into, but actual spawning stays
	# tied to game start (save_menu_handler), same as before when the
	# player only existed in the tree once a save slot was loaded/started.
	var player_root := Node2D.new()
	player_root.name = "PlayerRoot"
	add_child(player_root)
	PlayerManager.init(player_root)

	var player_data: CombatantData = preload("res://data/combatants/player_base.tres")
	combat_party.append(player_data)

func add_member(member: CombatantData, character: Node2D) -> void:
	if overworld_party.size() >= 3:
		return

	combat_party.append(member)
	overworld_party.append(character)
	party_container.add_child(character)

func remove_member(member: CombatantData, character: Node2D) -> void:
	combat_party.erase(member)
	overworld_party.erase(character)
	party_container.remove_child(character)
