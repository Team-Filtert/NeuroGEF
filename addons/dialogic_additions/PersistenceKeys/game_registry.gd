@tool
extends RefCounted

## Editor side lookup of the quest ids and key names that exist in the project.
##
## The dropdowns of the Key, If Key and If Quest events use this, so those can be picked
## from a list instead of typed from memory. Keys have no central definition, so they are
## collected from the places that mention them: the quest goals that check them and the
## timelines that set them.
##
## None of this runs in the game. It reads project files, which only makes sense while
## editing, and the results are cached for a moment because a dropdown asks for
## suggestions on every keystroke.


## How long a scan result is reused before the project is looked at again.
const CACHE_SECONDS := 3.0

## Matches the key name of a `[key ...]` or `[if_key ...]` event in a timeline file.
const KEY_EVENT_PATTERN := r'\[(?:key|if_key)\s[^\]]*\bname="(?<name>[^"]*)"'

static var _quests: Dictionary = {}
static var _keys: Dictionary = {}
static var _scanned_at := -INF


## Returns all quests in the project as `{quest_id: {"name": String, "path": String}}`.
static func get_quests() -> Dictionary:
	_scan()
	return _quests


## Returns the names of all keys that are mentioned anywhere in the project.
static func get_keys() -> Array:
	_scan()
	return _keys.keys()


## Throws away the cache, so the next lookup reads the project again.
static func invalidate() -> void:
	_scanned_at = -INF


#region SCANNING

static func _scan() -> void:
	if not Engine.is_editor_hint():
		return

	var now := Time.get_ticks_msec() / 1000.0
	if now - _scanned_at < CACHE_SECONDS:
		return
	_scanned_at = now

	_quests = {}
	_keys = {}
	_scan_quests()
	_scan_timelines()


## Finds every Quest resource and remembers its id and the keys its goals check.
static func _scan_quests() -> void:
	var script_path := _get_class_path("Quest")
	if script_path.is_empty():
		return

	var script_uid := _get_uid(script_path)

	for path: String in DialogicResourceUtil.list_resources_of_type(".tres"):
		if path.begins_with("res://addons/"):
			continue

		# Checking the file header first avoids loading every resource in the project.
		if not _mentions(path, script_path, script_uid):
			continue

		var quest: Resource = load(path)
		if quest == null or not ("id" in quest):
			continue

		var quest_id := str(quest.get("id"))
		if quest_id.is_empty():
			continue

		_quests[quest_id] = {
			"name": str(quest.get("name")),
			"path": path,
		}
		_collect_keys(quest.get("root"))


## Finds the keys that timelines set or check.
static func _scan_timelines() -> void:
	var regex := RegEx.create_from_string(KEY_EVENT_PATTERN)

	for path: String in DialogicResourceUtil.list_resources_of_type(".dtl"):
		if path.begins_with("res://addons/"):
			continue

		for result in regex.search_all(FileAccess.get_file_as_string(path)):
			var key := result.get_string("name")
			if not key.is_empty():
				_keys[key] = true


## Walks a goal tree and remembers every key a goal checks.
static func _collect_keys(goal: Variant, depth := 0) -> void:
	if goal == null or depth > 16:
		return

	if "key" in goal:
		var key := str(goal.get("key"))
		if not key.is_empty():
			_keys[key] = true

	if "children" in goal:
		for child: Variant in goal.get("children"):
			_collect_keys(child, depth + 1)

	if "root" in goal:
		_collect_keys(goal.get("root"), depth + 1)

#endregion


#region HELPERS

## Path of the script that registers [param class_name_to_find] as a global class,
## or an empty string if the project doesn't have such a class.
static func _get_class_path(class_name_to_find: String) -> String:
	for global_class: Dictionary in ProjectSettings.get_global_class_list():
		if global_class.get("class") == class_name_to_find:
			return str(global_class.get("path", ""))
	return ""


static func _get_uid(path: String) -> String:
	var uid := ResourceLoader.get_resource_uid(path)
	if uid == ResourceUID.INVALID_ID:
		return ""
	return ResourceUID.id_to_text(uid)


## Returns `true` if the resource file references the given script, by path or by uid.
static func _mentions(path: String, script_path: String, script_uid: String) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false

	# Resource files list their dependencies at the top, so the header is enough.
	var header := file.get_buffer(2048).get_string_from_utf8()
	if script_path in header:
		return true
	return not script_uid.is_empty() and script_uid in header

#endregion
