# DialogueEditor : MIT License
# @author Vladimir Petrenko
@tool
extends Control

var _editor: EditorPlugin
var _data:= DialogueData.new()
var localization_editor

@onready var _save_ui = $VBox/Margin/HBox/Save as Button
@onready var _label_ui = $VBox/Margin/HBox/Label as Label
@onready var _languages_ui = $VBox/Margin/HBox/Language as OptionButton
@onready var _tabs_ui = $VBox/Tabs as TabContainer
@onready var _actors_ui = $VBox/Tabs/Actors as VBoxContainer
@onready var _scenes_ui = $VBox/Tabs/Scenes as HBoxContainer
@onready var _dialogues_ui = $VBox/Tabs/Dialogues as HBoxContainer

const IconResourceActor = preload("res://addons/dialogue_editor/icons/Actor.png")
const IconResourceScene = preload("res://addons/dialogue_editor/icons/Scene.png")
const IconResourceDialogue = preload("res://addons/dialogue_editor/icons/Dialogue.png")

func _ready() -> void:
	_tabs_ui.set_tab_icon(0, IconResourceActor)
	_tabs_ui.set_tab_icon(1, IconResourceScene)
	_tabs_ui.set_tab_icon(2, IconResourceDialogue)

func set_editor(editor: EditorPlugin) -> void:
	_editor = editor
	_init_connections()
	_load_data()
	_data.set_editor(editor)
	_data_to_childs()
	_init_localization()

func _process(delta: float) -> void:
	if not localization_editor:
		_dropdown_ui_init()

func _dropdown_ui_init() -> void:
	if not localization_editor:
		var localizationEditorPath = "../LocalizationEditor"
		if has_node(localizationEditorPath):
			localization_editor = get_node(localizationEditorPath)
		
	if localization_editor:
		var data = localization_editor.get_data()
		if data:
			if not data.data_changed.is_connected(_on_localization_data_changed):
				data.data_changed.connect(_on_localization_data_changed)
			if not data.data_key_value_changed.is_connected(_on_localization_data_changed):
				data.data_key_value_changed.connect(_on_localization_data_changed)
			_on_localization_data_changed()

func _on_localization_data_changed() -> void:
	init_languages()

func _init_connections() -> void:
	if not _save_ui.pressed.is_connected(_on_save_data):
		_save_ui.pressed.connect(_on_save_data)
	if not _tabs_ui.tab_changed.is_connected(_on_tab_changed):
		_tabs_ui.tab_changed.connect(_on_tab_changed)

func get_data() -> DialogueData:
	return _data

func _load_data() -> void:
	_data.init_data()

func _on_tab_changed(tab: int) -> void:
	_data_to_childs()

func _data_to_childs() -> void:
	_actors_ui.set_data(_data)
	_scenes_ui.set_data(_data)
	_dialogues_ui.set_data(_data)

func _on_save_data() -> void:
	save_data(true)

func save_data(update_script_classes = false) -> void:
	_data.save(update_script_classes)

func _init_localization() -> void:
	if _data.setting_localization_editor_enabled():
		_label_ui.show()
		_languages_ui.show()
	else:
		_label_ui.hide()
		_languages_ui.hide()

var _locales
func init_languages() -> void:
	_languages_ui.clear()
	_locales = localization_editor.get_data().locales()
	var index: = -1
	for i in range(_locales.size()):
		_languages_ui.add_item(TranslationServer.get_locale_name(_locales[i]))
		if _locales[i] in _data.get_locale():
			index = i
	_languages_ui.select(index)
	if not _languages_ui.item_selected.is_connected(_on_item_selected):
		_languages_ui.item_selected.connect(_on_item_selected)

func _on_item_selected(index: int) -> void:
	_data.set_locale(_locales[index])
