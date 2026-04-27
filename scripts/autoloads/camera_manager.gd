extends Node

@onready var pcam: PhantomCamera2D = $/root/Root/PhantomCamera2D

func follow_player():
	pcam.follow_target = PartyManager.overworld_party[0]
