# QuestEditor : MIT License
# @author Vladimir Petrenko
@tool
extends Control

var _editor: EditorPlugin
var _data:= QuestData.new()
var localization_editor

@onready var _save_ui = $VBox/Margin/HBox/Save as Button
@onready var _reset_ui = $VBox/Margin/HBox/Reset as Button
@onready var _label_ui = $VBox/Margin/HBox/Label as Label
@onready var _languages_ui = $VBox/Margin/HBox/Language as OptionButton
@onready var _tabs_ui = $VBox/Tabs as TabContainer
@onready var _quests_ui = $VBox/Tabs/Quests as VBoxContainer
@onready var _triggers_ui = $VBox/Tabs/Triggers as VBoxContainer

const IconResourceQuests = preload("res://addons/quest_editor/icons/Quest.png")
const IconResourceTriggers = preload("res://addons/quest_editor/icons/Triggers.png")

func _ready() -> void:
	_tabs_ui.set_tab_icon(0, IconResourceQuests)
	_tabs_ui.set_tab_icon(1, IconResourceTriggers)

func set_editor(editor: EditorPlugin) -> void:
	_editor = editor
	_init_connections()
	_load_data()
	_data.set_editor(editor)
	_data_to_childs()

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
	if not _save_ui.pressed.is_connected(save_data_scripts):
		_save_ui.pressed.connect(save_data_scripts)
	if not _reset_ui.pressed.is_connected(reset_saved_user_data):
		_reset_ui.pressed.connect(reset_saved_user_data)
	if not _tabs_ui.tab_changed.is_connected(_on_tab_changed):
		_tabs_ui.tab_changed.connect(_on_tab_changed)

func get_data() -> QuestData:
	return _data

func _load_data() -> void:
	_data.init_data()

func _on_tab_changed(tab: int) -> void:
	_data_to_childs()

func _data_to_childs() -> void:
	_quests_ui.set_data(_data)
	_triggers_ui.set_data(_data)

func save_data_scripts() -> void:
	save_data(true)

func save_data(update_script_classes = false) -> void:
	_data.save(update_script_classes)

func reset_saved_user_data() -> void:
	_data.reset_saved_user_data()

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
