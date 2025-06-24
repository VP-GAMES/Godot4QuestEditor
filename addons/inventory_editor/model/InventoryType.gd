# Inventory type of items for InventoryEditor: MIT License
# @author Vladimir Petrenko
@tool
extends Resource
class_name InventoryType

# ***** EDITOR_PLUGIN BOILERPLATE *****
var _editor
var _undo_redo

func set_editor(editor) -> void:
	_editor = editor
	for item in items:
		item.set_editor(_editor)
	if _editor:
		_undo_redo = _editor.get_undo_redo()
# ***** EDITOR_PLUGIN_END *****

signal name_changed(name)
signal icon_changed

@export var uuid: String
@export var name: String
@export var icon: String
@export var items: Array
@export var selected: Resource

func change_name(new_name: String):
	name = new_name
	name_changed.emit()

func set_icon(new_icon_path: String) -> void:
	icon = new_icon_path
	icon_changed.emit()

func sort_items_by_name() -> void:
	items.sort_custom(func(a, b): return a.name < b.name)
