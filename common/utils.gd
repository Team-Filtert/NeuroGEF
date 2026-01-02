class_name Utils


static func get_all_children(node: Node) -> Array[Node]:
	var nodes : Array[Node] = []

	for N in node.get_children():
		if N.get_child_count() > 0:
			nodes.append(N)
			nodes.append_array(get_all_children(N))
		else:
			nodes.append(N)

	return nodes
