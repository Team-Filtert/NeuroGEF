extends Resource
class_name CombatAction

@export var action_name: String = "New Action"

func execute_action(_cur_char: Character, _target: Character):
    push_error("execute_action not implemented")
    pass

func is_valid_target(_cur_char: Character, _target: Character) -> bool:
    return true
