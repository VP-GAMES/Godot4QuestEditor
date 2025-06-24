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
		var localizationEditorPath = "../../../../../../LocalizationEditor"
		if has_node(localizationEditorPath):
			localization_editor = get_node(localizationEditorPath)
	if localization_editor != null:
		var data = localization_editor.get_data()
		if data:
			if not data.data_changed.is_connected(_on_localization_data_changed):
				data.data_changed.connect(_on_localization_data_changed)
			if not data.data_key_value_changed.is_connected(_on_localization_data_changed):
				data.data_key_value_changed.connect(_on_localization_data_changed)
			if not _data.locale_changed.is_connected(_locale_changed):
				_data.locale_changed.connect(_locale_changed)
			_on_localization_data_changed()

func _locale_changed(_locale: String):
	_on_localization_data_changed()

func _on_localization_data_changed() -> void:
	if _dropdown_ui and localization_editor != null:
		_dropdown_ui.clear()
		var localization_data = localization_editor.get_data()
		for key in localization_data.data.keys:
			_dropdown_ui.add_item_as_string(key.value, localization_data.value_by_locale_key(_data.get_locale(), key.value))
			if _actor:
				_dropdown_ui.set_selected_by_value(_actor.uiname)

func _init_connections() -> void:
	if not _add_ui.pressed.is_connected(_on_add_pressed):
		_add_ui.pressed.connect(_on_add_pressed)
	if not _data.actor_selection_changed.is_connected(_on_actor_selection_changed):
		_data.actor_selection_changed.connect(_on_actor_selection_changed)

func _on_add_pressed() -> void:
	_actor.add_resource()

func _on_actor_selection_changed(actor: DialogueActor) -> void:
	_actor = actor
	_update_view()

func _init_actor_connections() -> void:
	if not _actor.resource_added.is_connected(_on_resource_added):
		_actor.resource_added.connect(_on_resource_added)
	if not _actor.resource_removed.is_connected(_on_resource_removed):
		_actor.resource_removed.connect(_on_resource_removed)
	if not _uiname_ui.text_changed.is_connected(_on_uiname_changed):
		_uiname_ui.text_changed.connect(_on_uiname_changed)
	if _data.setting_localization_editor_enabled():
		if not _dropdown_ui.selection_changed.is_connected(_on_selection_changed):
			_dropdown_ui.selection_changed.connect(_on_selection_changed)

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
	_dropdown_ui.set_selected_by_value(_actor.uiname)

func _clear_view() -> void:
	_uiname_ui.editable = false
	_dropdown_ui.set_disabled(true)
	_dropdown_ui.set_selected_index(-1)
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
