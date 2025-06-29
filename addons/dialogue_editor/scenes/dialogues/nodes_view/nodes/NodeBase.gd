# Base node for DialogueEditor: MIT License
# @author Vladimir Petrenko
@tool
extends GraphNode

var _data: DialogueData
var _node: DialogueNode
var _dialogue: DialogueDialogue

func node() -> DialogueNode:
	return _node

func set_data(node: DialogueNode, dialogue: DialogueDialogue, data: DialogueData) -> void:
	_node = node
	_dialogue = dialogue
	_data = data
	_change_name()
	_init_connections()
	_update_view()

func _change_name() -> void:
	name = _node.uuid

func _init_connections() -> void:
	if not dragged.is_connected(_on_node_dragged):
		dragged.connect(_on_node_dragged)
	if not _node.node_position_changed.is_connected(_on_node_position_changed):
		_node.node_position_changed.connect(_on_node_position_changed)

func _on_node_dragged(from: Vector2, to: Vector2) -> void:
	_node.change_position(from, to)

func _on_node_position_changed(node: DialogueNode) -> void:
	if _node == node:
		_position_draw()

func _update_view() -> void:
	_title_draw()
	_slots_draw()
	_position_draw()

func _title_draw() -> void:
	title = _node.title

func _position_draw() -> void:
	position_offset = _node.position

func _slots_draw() -> void:
	set_slot(0, false, 0, Color(1, 1, 1), false, 0, Color(1, 1, 1))

func selected_slot() -> Vector2:
	return Vector2.ZERO

func global_position() -> Vector2:
	return _to_global_position(position_offset)

func _to_global_position(graph_position : Vector2) -> Vector2:
	return graph_position * get_parent().zoom - get_parent().scroll_offset
