class_name CombatantAction
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


#type      weights & target slecction   display name    base values  
#"TYPE": int
#"HP_WEIGHT": float
#"TARGET_LOW_HP": bool
#"ATTACK_WEIGHT": float
#"TARGET_LOW_ATTACK": bool
#"DISPLAY_NAME": string
#"BASE_DAMAGE": float
#"BASE_HEALING": float
#var skill = CombatantAction.action_dict[CombatantAction.Action.BASIC_ATTACK]


static var action_dict: Dictionary = {
	Action.BLANK: {
	"TYPE": Type.NONE
	},
	Action.BASIC_ATTACK: {
	"TYPE": Type.ATTACK, 
	"HP_WEIGHT": 1.0,
	"TARGET_LOW_HP": true, 
	"ATTACK_WEIGHT": 0.0,
	"TARGET_LOW_ATTACK": true,
	"DISPLAY_NAME": "Coolest attack",
	"BASE_DAMAGE": 1.0
	},
	Action.BASIC_HEAL: {
	"TYPE": Type.HEAL, 
	"HP_WEIGHT": 4.0,
	"TARGET_LOW_HP": true, 
	"ATTACK_WEIGHT": 0.0,
	"TARGET_LOW_ATTACK": true,
	"DISPLAY_NAME": "Coolest heal",
	"BASE_HEALING": 1.0
	}
	
}

var display_name: String
var type: Type
var source: Combatant
var target: Combatant

var process_func: Callable
