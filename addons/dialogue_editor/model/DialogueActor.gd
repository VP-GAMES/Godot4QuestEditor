# Dialogue actor for DialogueEditor: MIT License
# @author Vladimir Petrenko
@tool
extends Resource
class_name DialogueActor
# TODO @icon("res://addons/dialogue_editor/icons/Actor.png")

# ***** EDITOR_PLUGIN BOILERPLATE *****
var _editor
var _undo_redo

func set_editor(editor) -> void:
	_editor = editor
	_undo_redo = _editor.get_undo_redo()

const UUID = preload("res://addons/dialogue_editor/uuid/uuid.gd")
# ***** EDITOR_PLUGIN_END *****

signal name_changed(name)
signal uiname_changed(uiname)
signal resource_added(resource)
signal resource_removed(resource)
signal resource_name_changed(resource)
signal resource_path_changed(resource)
signal resource_selection_changed(resource)

@export var uuid: String
@export var name: String = ""
@export var uiname = ""
@export var resources: Array = [] # List of Resources
var _resource_selected = null

func change_name(new_name: String):
	name = new_name
	changed.emit()
	name_changed.emit()

func change_uiname(new_uiname: String):
	uiname = new_uiname
	changed.emit()
	uiname_changed.emit()

func add_resource() -> void:
	var resource = _create_resource()
	if _undo_redo != null:
		_undo_redo.create_action("Add actor resource")
		_undo_redo.add_do_method(self, "_add_resource", resource)
		_undo_redo.add_undo_method(self, "_del_resource", resource)
		_undo_redo.commit_action()
	else:
		_add_resource(resource)

func _create_resource():
	return {"uuid": UUID.v4(), "name": "", "path": ""}

func _add_resource(resource, position = resources.size()) -> void:
	resources.insert(position, resource)
	changed.emit()
	resource_added.emit(resource)
	select_resource(resource)

func del_resource(resource) -> void:
	if _undo_redo != null:
		var index = resources.find(resource)
		_undo_redo.create_action("Del actor resource")
		_undo_redo.add_do_method(self, "_del_resource", resource)
		_undo_redo.add_undo_method(self, "_add_resource", resource, index)
		_undo_redo.commit_action()
	else:
		_del_resource(resource)

func _del_resource(resource) -> void:
	var index = resources.find(resource)
	if index > -1:
		resources.remove_at(index)
		changed.emit()
		resource_removed.emit(resource)
		var resource_selected = selected_resource()
		select_resource(resource_selected)

func change_resource_name(resource: Dictionary, name: String) -> void:
	var old_name = resource.name
	if _undo_redo != null:
		_undo_redo.create_action("Change actor resource name")
		_undo_redo.add_do_method(self, "_change_resource_name", resource, name, true)
		_undo_redo.add_undo_method(self, "_change_resource_name", resource, old_name)
		_undo_redo.commit_action()
	else:
		_change_resource_name(resource, name)

func _change_resource_name(resource: Dictionary, name: String, sendSignal = false) -> void:
	resource.name = name
	changed.emit()
	if sendSignal:
		resource_name_changed.emit(resource)

func change_resource_path(resource: Dictionary, path: String) -> void:
	var old_path = resource.path
	var old_name = resource.name
	var new_name = resource.name
	if resource.name.is_empty():
		new_name = _filename_only(path)
	if _undo_redo != null:
		_undo_redo.create_action("Change actor resource path")
		_undo_redo.add_do_method(self, "_resource_path_change", resource, path, new_name)
		_undo_redo.add_undo_method(self, "_resource_path_change", resource, old_path, old_name)
		_undo_redo.commit_action()
	else:
		_resource_path_change(resource, path, new_name)

func _resource_path_change(resource: Dictionary, path: String, name: String) -> void:
	resource.path = path
	var name_changed = resource.name != name
	if name_changed:
		resource.name = name
	resource.name = name
	changed.emit()
	resource_path_changed.emit(resource)
	if name_changed:
		resource_name_changed.emit(resource)

func selected_resource():
	if _resource_selected == null and not resources.is_empty():
		_resource_selected = resources[0]
	return _resource_selected

func select_resource(resource) -> void:
	resource_selection_changed.emit(resource)

func default_uuid() -> String:
	var uuid = null
	if not resources.is_empty() and resources.size() >= 1:
		uuid = resources[0].uuid
	return uuid

func resource_by_uuid(uuid = null, default_texture = true) -> Resource:
	var texture = null
	if not resources.is_empty():
		if resources.size() == 1 and default_texture:
			texture = load(resources[0].path)
		elif uuid and resources.size() >= 1:
			for res in resources:
				if res.uuid == uuid:
					if resource_exists(res):
						texture = load(res.path)
					break
	return texture

func _filename_only(value: String) -> String:
	var first = value.rfind("/")
	var second = value.rfind(".")
	return value.substr(first + 1, second - first - 1)

func resource_exists(resource) -> bool:
	return FileAccess.file_exists(resource.path)
