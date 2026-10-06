class_name AIActionWeights
extends Resource

## Tuning for the enemy AI's target scoring.
##
## Each enabled criterion contributes to a per-target score, and the AI picks a
## target with a weighted random roll over those scores, so enemies are not fully
## predictable. Set a weight to 0 (or the boolean to false) to ignore a criterion.

@export var hp_weight: float = 1.0
## Prefer targets that are low on health.
@export var target_low_hp: bool = true

@export var attack_weight: float = 0.0
## Prefer targets with a low attack stat.
@export var target_low_attack: bool = false
