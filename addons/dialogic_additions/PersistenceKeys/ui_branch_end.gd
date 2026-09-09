@tool
extends HBoxContainer

## End branch control for the If Key and If Quest events.
## Shows what the branch above it was checking, like Dialogic's own condition end does.

var parent_resource: DialogicEvent = null


func refresh() -> void:
	if parent_resource == null or not parent_resource.has_method("get_branch_end_text"):
		hide()
		return

	$Label.text = "End of " + parent_resource.get_branch_end_text()
