extends Node

signal combat_triggered(enemies: Array[CombatantData], music: AudioStream)

signal change_scene_triggered(scene_name: String, scene_dir: String, cur_trans: SceneTransitionComponent)

# for events that happen on enter new scene (level)
# data doesn't have spicific type
signal scene_entered(data)
