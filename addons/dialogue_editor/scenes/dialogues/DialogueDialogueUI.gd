# Dialogue dialogue UI for DialogueEditor : MIT License
# @author Vladimir Petrenko
@tool
extends MarginContainer

var _dialogue: DialogueDialogue
var _data: DialogueData

var _ui_style_selected: StyleBoxFlat

@onready var _name_ui = $HBox/Name as LineEdit
@onready var _del_ui = $HBox/Del as Button

func dialogue() -> DialogueDialogue:
	return _dialogue

func set_data(dialogue: DialogueDialogue, data: DialogueData):
	_dialogue = dialogue
	_data = data
	_init_styles()
	_init_connections()
	_draw_view()
	_draw_style()

func _init_styles() -> void:
	_ui_style_selected = StyleBoxFlat.new()
	_ui_style_selected.set_bg_color(Color("#868991"))

func _init_connections() -> void:
	if not _data.dialogue_added.is_connected(_on_dialogue_added):
		assert(_data.dialogue_added.connect(_on_dialogue_added) == OK)
	if not _data.dialogue_removed.is_connected(_on_dialogue_removed):
		assert(_data.dialogue_removed.connect(_on_dialogue_removed) == OK)
	if not _data.dialogue_selection_changed.is_connected(_on_dialogue_selection_changed):
		assert(_data.dialogue_selection_changed.connect(_on_dialogue_selection_changed) == OK)
	if not _name_ui.gui_input.is_connected(_on_gui_input):
		assert(_name_ui.gui_input.connect(_on_gui_input) == OK)
	if not _name_ui.focus_exited.is_connected(_on_focus_exited):
		assert(_name_ui.focus_exited.connect(_on_focus_exited) == OK)
	if not _name_ui.text_changed.is_connected(_on_text_changed):
		assert(_name_ui.text_changed.connect(_on_text_changed) == OK)
	if not _del_ui.pressed.is_connected(_del_pressed):
		assert(_del_ui.pressed.connect(_del_pressed) == OK)

func _on_dialogue_added(dialogue: DialogueDialogue) -> void:
	_draw_style()

func _on_dialogue_removed(dialogue: DialogueDialogue) -> void:
	_draw_style()

func _on_dialogue_selection_changed(dialogue: DialogueDialogue) -> void:
	_draw_style()

func _on_focus_exited() -> void:
	_draw_style()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if not _data.selected_dialogue() == _dialogue:
					_data.select_dialogue(_dialogue)
					_del_ui.grab_focus()
				else:
					_name_ui.remove_theme_stylebox_override("normal")
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_ENTER or event.scancode == KEY_KP_ENTER:
			if _name_ui.has_focus():
				_del_ui.grab_focus()

func _on_text_changed(new_text: String) -> void:
	_dialogue.name = new_text
	_data.select_dialogue(_dialogue, false)

func _del_pressed() -> void:
	_data.del_dialogue(_dialogue)

func _draw_view() -> void:
	_name_ui.text = _dialogue.name

func _draw_style() -> void:
	if _data.selected_dialogue() == _dialogue:
		_name_ui.add_theme_stylebox_override("normal", _ui_style_selected)
	else:
		_name_ui.remove_theme_stylebox_override("normal")
