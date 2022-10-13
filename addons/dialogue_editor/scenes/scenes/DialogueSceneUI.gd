# Dialogue scene UI for DialogueEditor : MIT License
# @author Vladimir Petrenko
@tool
extends MarginContainer

var _scene
var _data: DialogueData

var _ui_style_selected: StyleBoxFlat

@onready var _name_ui = $HBox/Name as Label
@onready var _sentence_ui = $HBox/Sentence as Button
@onready var _open_ui = $HBox/Open as Button
@onready var _del_ui = $HBox/Del as Button

const DialogueScenePreviewSentenceDialog = preload("res://addons/dialogue_editor/scenes/scenes/DialogueScenePreviewSentenceDialog.tscn")

func scene():
	return _scene

func set_data(scene, data: DialogueData):
	_scene = scene
	_data = data
	_init_styles()
	_init_connections()
	_draw_view()
	_draw_style()

func _init_styles() -> void:
	_ui_style_selected = StyleBoxFlat.new()
	_ui_style_selected.set_bg_color(_data.BACKGROUND_COLOR_SELECTED)

func _init_connections() -> void:
	if not _data.scene_added.is_connected(_on_scene_added):
		assert(_data.scene_added.connect(_on_scene_added) == OK)
	if not _data.scene_removed.is_connected(_on_scene_removed):
		_data.scene_removed.connect(_on_scene_removed)
	if not _data.scene_selection_changed.is_connected(_on_scene_selection_changed):
		assert(_data.scene_selection_changed.connect(_on_scene_selection_changed) == OK)
	if not _name_ui.gui_input.is_connected(_on_gui_input):
		assert(_name_ui.gui_input.connect(_on_gui_input) == OK)
	if not _sentence_ui.pressed.is_connected(_on_sentence_pressed):
		assert(_sentence_ui.pressed.connect(_on_sentence_pressed) == OK)
	if not _open_ui.pressed.is_connected(_on_open_pressed):
		assert(_open_ui.pressed.connect(_on_open_pressed) == OK)
	if not _del_ui.pressed.is_connected(_on_del_pressed):
		assert(_del_ui.pressed.connect(_on_del_pressed) == OK)

func _on_scene_added(scene) -> void:
	_draw_style()

func _on_scene_removed(scene) -> void:
	_draw_style()

func _on_scene_selection_changed(scene) -> void:
	_draw_style()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if not _data.selected_scene() == _scene:
					_data.select_scene(_scene)
				else:
					_name_ui.set("custom_styles/normal", null)

func _on_sentence_pressed() -> void:
	_data.select_scene(_scene)
	var sentence_dialog  = DialogueScenePreviewSentenceDialog.instantiate()
	var root = get_tree().get_root()
	root.add_child(sentence_dialog)
	sentence_dialog.set_data(_scene, _data)
	sentence_dialog.title = "Preview Sentence"
	assert(sentence_dialog.close_requested.connect(_on_popup_hide.bind(root, sentence_dialog)) == OK)
	sentence_dialog.popup_centered()

func _on_popup_hide(root, dialog) -> void:
	root.remove_child(dialog)
	dialog.queue_free()

func _on_open_pressed() -> void:
	_data.select_scene(_scene)
	_data.editor().get_editor_interface().open_scene_from_path(_scene.resource)

func _on_del_pressed() -> void:
	_data.del_scene(_scene)

func _draw_view() -> void:
	_name_ui.text = _data.filename_only(_scene.resource)

func _draw_style() -> void:
	if _data.selected_scene() == _scene:
		_name_ui.set("custom_styles/normal", _ui_style_selected)
	else:
		_name_ui.set("custom_styles/normal", null)
