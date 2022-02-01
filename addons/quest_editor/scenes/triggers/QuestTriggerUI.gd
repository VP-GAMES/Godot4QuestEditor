# Trigger trigger ui for TriggerEditor : MIT License
# @author Vladimir Petrenko
@tool
extends MarginContainer

var _trigger: QuestTrigger
var _data: QuestData

var _ui_style_selected: StyleBoxFlat

@onready var _texture_ui = $HBox/Texture as TextureRect
@onready var _name_ui = $HBox/Name as LineEdit
@onready var _del_ui = $HBox/Del as Button

const _texture_question = preload("res://addons/quest_editor/icons/Question.png")
const _texture_destination = preload("res://addons/quest_editor/icons/Destination.png")
const _texture_enemy = preload("res://addons/quest_editor/icons/Enemy.png")
const _texture_item = preload("res://addons/quest_editor/icons/Item.png")
const _texture_npc = preload("res://addons/quest_editor/icons/NPC.png")
const _texture_trigger = preload("res://addons/quest_editor/icons/Trigger.png")

func set_data(trigger: QuestTrigger, data: QuestData):
	_trigger = trigger
	_data = data
	_init_styles()
	_init_connections()
	_draw_view()
	_draw_style()

func _init_styles() -> void:
	_ui_style_selected = StyleBoxFlat.new()
	_ui_style_selected.set_bg_color(_data.BACKGROUND_COLOR_SELECTED)

func _init_connections() -> void:
	if not _data.trigger_added.is_connected(_on_trigger_added):
		assert(_data.trigger_added.connect(_on_trigger_added) == OK)
	if not _data.trigger_removed.is_connected(_on_trigger_removed):
		assert(_data.trigger_removed.connect(_on_trigger_removed) == OK)
	if not _data.trigger_selection_changed.is_connected(_on_trigger_selection_changed):
		assert(_data.trigger_selection_changed.connect(_on_trigger_selection_changed) == OK)
	if not _texture_ui.gui_input.is_connected(_on_gui_input):
		assert(_texture_ui.gui_input.connect(_on_gui_input) == OK)
	if not _name_ui.gui_input.is_connected(_on_gui_input):
		assert(_name_ui.gui_input.connect(_on_gui_input) == OK)
	if not _name_ui.focus_exited.is_connected(_on_focus_exited):
		assert(_name_ui.focus_exited.connect(_on_focus_exited) == OK)
	if not _name_ui.text_changed.is_connected(_on_text_changed):
		assert(_name_ui.text_changed.connect(_on_text_changed) == OK)
	if not _del_ui.pressed.is_connected(_del_pressed):
		assert(_del_ui.pressed.connect(_del_pressed) == OK)
	if not _trigger.scene_changed.is_connected(on_scene_changed):
		assert(_trigger.scene_changed.connect(on_scene_changed) == OK)

func _on_trigger_added(trigger: QuestTrigger) -> void:
	_draw_style()

func _on_trigger_removed(trigger: QuestTrigger) -> void:
	_draw_style()

func _on_trigger_selection_changed(trigger: QuestTrigger) -> void:
	_draw_style()

func _on_focus_exited() -> void:
	_draw_style()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if not _data.selected_trigger() == _trigger:
					_data.select_trigger(_trigger)
					_del_ui.grab_focus()
				else:
					_name_ui.set("custom_styles/normal", null)
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_ENTER or event.scancode == KEY_KP_ENTER:
			if _name_ui.has_focus():
				_del_ui.grab_focus()

func _on_text_changed(new_text: String) -> void:
	_trigger.change_name(new_text)

func _del_pressed() -> void:
	_data.del_trigger(_trigger)

func on_scene_changed() -> void:
	_draw_view()

func _draw_view() -> void:
	_name_ui.text = _trigger.name
	_draw_texture()

func _draw_texture() -> void:
	_texture_ui.texture = _define_texture()

func _draw_style() -> void:
	if _data.selected_trigger() == _trigger:
		_name_ui.set("custom_styles/normal", _ui_style_selected)
	else:
		_name_ui.set("custom_styles/normal", null)

func _define_texture():
	match _trigger.type:
		"DESTINATION":
			return _texture_destination
		"ENEMY":
			return _texture_enemy
		"ITEM":
			return _texture_item
		"NPC":
			return _texture_npc
		"TRIGGER":
			return _texture_trigger
	return _texture_question
