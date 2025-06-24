# Quest quest ui for QuestEditor : MIT License
# @author Vladimir Petrenko
@tool
extends MarginContainer

var _quest: QuestQuest
var _data: QuestData

var _ui_style_selected: StyleBoxFlat

@onready var _texture_ui = $HBox/Texture as TextureRect
@onready var _name_ui = $HBox/Name as LineEdit
@onready var _del_ui = $HBox/Del as Button

const _texture = preload("res://addons/quest_editor/icons/QuestPath.png")

func set_data(quest: QuestQuest, data: QuestData):
	_quest = quest
	_data = data
	_init_styles()
	_init_connections()
	_draw_view()
	_draw_style()

func _init_styles() -> void:
	_ui_style_selected = StyleBoxFlat.new()
	_ui_style_selected.set_bg_color(_data.BACKGROUND_COLOR_SELECTED)

func _init_connections() -> void:
	if not _data.quest_added.is_connected(_on_quest_added):
		_data.quest_added.connect(_on_quest_added)
	if not _data.quest_removed.is_connected(_on_quest_removed):
		_data.quest_removed.connect(_on_quest_removed)
	if not _data.quest_selection_changed.is_connected(_on_quest_selection_changed):
		_data.quest_selection_changed.connect(_on_quest_selection_changed)
	if not _texture_ui.gui_input.is_connected(_on_gui_input):
		_texture_ui.gui_input.connect(_on_gui_input)
	if not _name_ui.gui_input.is_connected(_on_gui_input):
		_name_ui.gui_input.connect(_on_gui_input)
	if not _name_ui.focus_exited.is_connected(_on_focus_exited):
		_name_ui.focus_exited.connect(_on_focus_exited)
	if not _name_ui.text_changed.is_connected(_on_text_changed):
		_name_ui.text_changed.connect(_on_text_changed)
	if not _del_ui.pressed.is_connected(_del_pressed):
		_del_ui.pressed.connect(_del_pressed)

func _on_quest_added(quest: QuestQuest) -> void:
	_draw_style()

func _on_quest_removed(quest: QuestQuest) -> void:
	_draw_style()

func _on_quest_selection_changed(quest: QuestQuest) -> void:
	_draw_style()

func _on_focus_exited() -> void:
	_draw_style()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if not _data.selected_quest() == _quest:
					_data.select_quest(_quest)
					_del_ui.grab_focus()
				else:
					_name_ui.remove_theme_stylebox_override("normal")
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			if _name_ui.has_focus():
				_del_ui.grab_focus()

func _on_text_changed(new_text: String) -> void:
	_quest.change_name(new_text)

func _del_pressed() -> void:
	_data.del_quest(_quest)

func _draw_view() -> void:
	_name_ui.text = _quest.name
	_draw_texture()

func _draw_texture() -> void:
	_texture_ui.texture = _texture

func _draw_style() -> void:
	if _data.selected_quest() == _quest:
		_name_ui.add_theme_stylebox_override("normal", _ui_style_selected)
	else:
		_name_ui.remove_theme_stylebox_override("normal")
