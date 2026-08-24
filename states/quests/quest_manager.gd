class_name QuestManager
extends RefCounted

var quests: Dictionary[String, Quest] = {}

func add_quest(quest: Quest) -> void:
    quests[quest.id] = quest

func get_quest(id: String) -> Quest:
    return quests.get(id)

func is_complete(id: String) -> bool:
    var quest := get_quest(id)

    if quest == null:
        return false

    return quest.is_complete()

func get_quests() -> Dictionary[String, Quest]:
    return quests