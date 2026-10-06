class_name EnemyAI
extends Node

## Chooses an action (with a target) for one enemy.
##
## Kept deliberately simple and data driven: healing is used when an ally is
## hurt, otherwise the strongest affordable attack is chosen, and the target is a
## weighted random roll over the action's [AIActionWeights]. Override
## [method choose_action] for a smarter enemy type.


func choose_action(actor: Combatant, arena: Arena) -> ActionBase:
	var usable: Array[ActionBase] = []
	for action in actor.actions:
		if action.is_available(actor):
			usable.append(action)

	if usable.is_empty():
		return null

	var healer := _first_heal(usable)
	if healer != null:
		var wounded := _most_wounded(arena.get_alive_enemies(), actor)
		if wounded != null:
			healer.source = actor
			healer.target = wounded
			return healer

	var attack := _strongest_attack(usable, actor)
	if attack == null:
		return null

	attack.source = actor
	attack.target = _pick_target(arena.get_alive_party(), attack, actor)
	return attack


func _first_heal(actions: Array[ActionBase]) -> ActionBase:
	for action in actions:
		if action.type == ActionBase.Type.HEAL:
			return action
	return null


func _strongest_attack(actions: Array[ActionBase], actor: Combatant) -> ActionBase:
	var best: ActionBase = null
	for action in actions:
		if action.type != ActionBase.Type.ATTACK:
			continue
		if best == null or action.get_value(actor) > best.get_value(actor):
			best = action
	return best


## The ally with the lowest HP ratio, or null if everyone is at full health.
func _most_wounded(allies: Array[Combatant], _actor: Combatant) -> Combatant:
	var best: Combatant = null
	var best_ratio := 1.0
	for ally in allies:
		var ratio := float(ally.get_health()) / float(maxi(ally.get_max_health(), 1))
		if ratio < best_ratio:
			best_ratio = ratio
			best = ally
	return best if best_ratio < 1.0 else null


func _pick_target(targets: Array[Combatant], action: ActionBase, actor: Combatant) -> Combatant:
	if targets.is_empty():
		return null

	var weights := action.ai_weights
	if weights == null:
		return targets.pick_random()

	var scores: Array[float] = []
	var total := 0.0
	for target in targets:
		var score := 0.0
		if weights.target_low_hp:
			var hp_ratio := float(target.get_health()) / float(maxi(target.get_max_health(), 1))
			score += (1.0 - hp_ratio) * weights.hp_weight
		if weights.target_low_attack:
			var attack_ratio := float(target.get_attack()) / float(maxi(actor.get_attack(), 1))
			score += (1.0 - minf(attack_ratio, 1.0)) * weights.attack_weight
		score = maxf(score, 0.001)
		scores.append(score)
		total += score

	var roll := randf() * total
	var accumulated := 0.0
	for i in targets.size():
		accumulated += scores[i]
		if roll <= accumulated:
			return targets[i]

	return targets.back()
