extends Node2D

const DEFAULT_PARTY := [
	"res://data/combatants/neuro.tres",
	"res://data/combatants/nere.tres",
]


func enter(args) -> void:
	PlayerManager.init(%PlayerRoot)
	LevelManager.init(%LevelRoot, GameState._transition_root)
	_ensure_party()
	PlayerManager.spawn_player()
	LevelManager.change_level("res://levels/ch1/neuros_home/neuro_room.tscn", "default")


## Seeds a starting party on a fresh game so entering combat has something to
## fight with. A real new-game flow would replace this.
func _ensure_party() -> void:
	if GameState.party == null or not GameState.party.members.is_empty():
		return
	for path in DEFAULT_PARTY:
		var member := load(path) as PartyMember
		if member != null:
			GameState.party.add_member(member)


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass
