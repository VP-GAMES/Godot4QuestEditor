# Inventory for InventoryEditor: MIT License
# @author Vladimir Petrenko
@tool
extends Resource
class_name InventoryInventory

# ***** EDITOR_PLUGIN BOILERPLATE *****
var _editor
var _undo_redo

func set_editor(editor) -> void:
	_editor = editor
	if _editor:
		_undo_redo = _editor.get_undo_redo()
# ***** EDITOR_PLUGIN_END *****

signal name_changed(name)
signal stacks_changed
signal icon_changed
signal scene_changed

@export var uuid: String
@export var name: String
@export var stacks: int
@export var icon: String
@export var scene: String

func change_name(new_name: String):
	name = new_name
	name_changed.emit()

func set_stacks(new_stacks: int) -> void:
	stacks = new_stacks
	stacks_changed.emit()

func set_icon(new_icon_path: String) -> void:
	icon = new_icon_path
	icon_changed.emit()

func set_scene(new_scene_path: String) -> void:
	scene = new_scene_path
	scene_changed.emit()
