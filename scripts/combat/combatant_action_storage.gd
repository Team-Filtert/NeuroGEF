class_name CombatantActionStorage
extends RefCounted

enum Type {
	NONE,
	ATTACK,
	BLOCK,
	HEAL
}

enum Action {
	BLANK = 0,
	BASIC_ATTACK = 1,
	BASIC_HEAL = 2
}

enum Action_data {
	TYPE,#: int type
	HP_WEIGHT,# float
	TARGET_LOW_HP,# bool target slecction
	ATTACK_WEIGHT,# float
	TARGET_LOW_ATTACK,# bool target slecction
	DISPLAY_NAME,# string
	BASE_DAMAGE,# float
	BASE_HEALING# float
}

#var skill = CombatantActionStorage.action_dict[CombatantActionStorage.Action.BASIC_ATTACK][Action_data.TYPE]
#AI logic is in QueueEnemyActionsState

static var action_dict: Dictionary = {
	Action.BLANK: {
	"TYPE": Type.NONE
	},
	Action.BASIC_ATTACK: {
	Action_data.TYPE : Type.ATTACK, 
	Action_data.HP_WEIGHT: 1.5,
	Action_data.TARGET_LOW_HP: true, 
	Action_data.ATTACK_WEIGHT: 1.0,
	Action_data.TARGET_LOW_ATTACK: true,
	Action_data.DISPLAY_NAME: "Coolest attack",
	Action_data.BASE_DAMAGE: 1.0
	},
	Action.BASIC_HEAL: {
	Action_data.TYPE: Type.HEAL, 
	Action_data.HP_WEIGHT: 4.0,
	Action_data.TARGET_LOW_HP: true, 
	Action_data.ATTACK_WEIGHT: 0.0,
	Action_data.TARGET_LOW_ATTACK: true,
	Action_data.DISPLAY_NAME: "Coolest heal",
	Action_data.BASE_HEALING: 1.0
	}
	
}
