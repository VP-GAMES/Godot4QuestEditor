# Dialogue actor data for DialogueEditor : MIT License
# @author Vladimir Petrenko
@tool
extends HBoxContainer

var _data: DialogueData
var _actor: DialogueActor
var localization_editor = null

@onready var _uiname_ui = $MarginData/VBox/HBoxUIName/UIName as LineEdit
@onready var _dropdown_ui = $MarginData/VBox/HBoxUIName/Dropdown
@onready var _add_ui = $MarginData/VBox/HBox/Add as Button
@onready var _resources_ui = $MarginData/VBox/Resources as VBoxContainer
@onready var _texture_ui = $MarginPreview/VBox/Texture as TextureRect

const DialogueActorDataResource = preload("res://addons/dialogue_editor/scenes/actors/DialogueActorDataResource.tscn")

func set_data(data: DialogueData):
	_data = data
	_texture_ui.set_data(data)
	_dropdown_ui_init()
	_init_connections()
	_update_view()

func _process(delta: float) -> void:
	if localization_editor == null:
		_dropdown_ui_init()

func _dropdown_ui_init() -> void:
	if localization_editor == null:
		localization_editor = get_tree().get_root().find_node("LocalizationEditor", true, false)
	if localization_editor != null:
		var data = localization_editor.get_data()
		if data:
			if not data.is_connected("data_changed", _on_localization_data_changed):
				data.connect("data_changed", _on_localization_data_changed)
			if not data.is_connected("data_key_value_changed", _on_localization_data_changed):
				data.connect("data_key_value_changed", _on_localization_data_changed)
			_on_localization_data_changed()

func _on_localization_data_changed() -> void:
	if _dropdown_ui:
		_dropdown_ui.clear()
		if localization_editor:
			for key in localization_editor.get_data().data.keys:
				_dropdown_ui.add_item_as_string(key.value)
			if _actor:
				_dropdown_ui.set_selected_by_value(_actor.uiname)

func _init_connections() -> void:
	if not _add_ui.is_connected("pressed", _on_add_pressed):
		assert(_add_ui.connect("pressed", _on_add_pressed) == OK)
	if not _data.is_connected("actor_selection_changed", _on_actor_selection_changed):
		assert(_data.connect("actor_selection_changed", _on_actor_selection_changed) == OK)

func _on_add_pressed() -> void:
	_actor.add_resource()

func _on_actor_selection_changed(actor: DialogueActor) -> void:
	_actor = actor
	_update_view()

func _init_actor_connections() -> void:
	if not _actor.is_connected("resource_added", _on_resource_added):
		assert(_actor.connect("resource_added", _on_resource_added) == OK)
	if not _actor.is_connected("resource_removed", _on_resource_removed):
		assert(_actor.connect("resource_removed", _on_resource_removed) == OK)
	if not _uiname_ui.is_connected("text_changed", _on_uiname_changed):
		assert(_uiname_ui.connect("text_changed", _on_uiname_changed) == OK)
	if _data.setting_localization_editor_enabled():
		if not _dropdown_ui.selection_changed.is_connected(_on_selection_changed):
			assert(_dropdown_ui.selection_changed.connect(_on_selection_changed) == OK)

func _on_resource_added(resource) -> void:
	_update_view()
	_resource_request_focus(resource)

func _on_resource_removed(resource) -> void:
	_update_view()

func _on_uiname_changed(new_text: String) -> void:
	_actor.change_uiname(new_text)

func _on_selection_changed(item: DropdownItem) -> void:
	_actor.change_uiname(item.value)

func _update_view() -> void:
	_clear_view()
	if _data:
		_actor = _data.selected_actor()
		if _actor:
			_init_actor_connections()
			_draw_view()
		_dropdown_ui_draw()

func _draw_view() -> void:
	_uiname_ui_draw()
	_on_localization_data_changed()
	_add_ui.disabled = false
	for resource in _actor.resources:
		_draw_resource(resource)
		_draw_preview_texture()

func _uiname_ui_draw() -> void:
	_uiname_ui.visible = not _data.setting_localization_editor_enabled()
	_uiname_ui.editable = true
	_uiname_ui.text = _actor.uiname

func _dropdown_ui_draw() -> void:
	_dropdown_ui.visible = _data.setting_localization_editor_enabled()
	_dropdown_ui.set_disabled(false)

func _clear_view() -> void:
	_uiname_ui.editable = false
	_dropdown_ui.set_disabled(true)
	_add_ui.disabled = true
	for resource_ui in _resources_ui.get_children():
		_resources_ui.remove_child(resource_ui)
		resource_ui.queue_free()

func _draw_resource(resource) -> void:
	var resource_ui = DialogueActorDataResource.instantiate()
	_resources_ui.add_child(resource_ui)
	resource_ui.set_data(resource, _actor, _data)

func _resource_request_focus(resource) -> void:
	for resource_ui in _resources_ui.get_children():
		if resource_ui.resource() == resource:
			resource_ui.request_focus()

func _draw_preview_texture() -> void:
	if _actor and not _actor.resources.is_empty():
		_texture_ui.set_resource(_actor.resources[0])
	else:
		_texture_ui.set_resource(null)

func _draw_preview_clear() -> void:
		_texture_ui.set_resource(null)
