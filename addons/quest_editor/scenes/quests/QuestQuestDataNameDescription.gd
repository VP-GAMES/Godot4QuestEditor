# Quest data name UI for QuestEditor : MIT License
# @author Vladimir Petrenko
@tool
extends VBoxContainer

var _quest: QuestQuest
var _data: QuestData
var localization_editor

@onready var _uiname_ui = $HBoxName/UIName as LineEdit
@onready var _dropdown_name_ui = $HBoxName/Dropdown
@onready var _description_ui = $HBoxDescription/Description as TextEdit
@onready var _dropdown_description_ui = $HBoxDescription/Dropdown

func set_data(quest: QuestQuest, data: QuestData) -> void:
	_data = data
	_quest = quest
	_init_connections()
	_draw_view()
	_update_view_visibility()

func _process(delta: float) -> void:
	if not localization_editor:
		_dropdown_ui_init()

func _dropdown_ui_init() -> void:
	if not localization_editor:
		var localizationEditorPath = "../../../../../../../../LocalizationEditor"
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
	_fill_dropdown_name_ui()
	_fill_dropdown_description_ui()

func _fill_dropdown_name_ui() -> void:
	if _dropdown_name_ui:
		_dropdown_name_ui.clear()
		for key in localization_editor.get_data().data.keys:
			var item = DropdownItem.new(key.value, key.value)
			_dropdown_name_ui.add_item(item)
		_dropdown_name_ui.set_selected_by_value(_quest.uiname)

func _fill_dropdown_description_ui() -> void:
	if _dropdown_description_ui:
		_dropdown_description_ui.clear()
		for key in localization_editor.get_data().data.keys:
			var item = DropdownItem.new(key.value, key.value)
			_dropdown_description_ui.add_item(item)
		_dropdown_description_ui.set_selected_by_value(_quest.description)

func _init_connections() -> void:
	if not _uiname_ui.text_changed.is_connected(_on_uiname_changed):
		assert(_uiname_ui.text_changed.connect(_on_uiname_changed) == OK)
	if not _description_ui.text_changed.is_connected(_on_description_changed):
		assert(_description_ui.text_changed.connect(_on_description_changed) == OK)
	if _data.setting_localization_editor_enabled():
		if not _dropdown_name_ui.selection_changed.is_connected(_on_selection_changed_name):
			assert(_dropdown_name_ui.selection_changed.connect(_on_selection_changed_name) == OK)
		if not _dropdown_description_ui.selection_changed.is_connected(_on_selection_changed_description):
			assert(_dropdown_description_ui.selection_changed.connect(_on_selection_changed_description) == OK)

func _on_uiname_changed(new_text: String) -> void:
	_quest.change_uiname(new_text)

func _on_description_changed() -> void:
	_quest.change_description(_description_ui.text)

func _on_selection_changed_name(item: DropdownItem) -> void:
	_quest.uiname = item.value

func _on_selection_changed_description(item: DropdownItem) -> void:
	_quest.description = item.value

func _update_view_visibility() -> void:
	if _data.setting_localization_editor_enabled():
		_uiname_ui.hide()
		_description_ui.hide()
		_dropdown_name_ui.show()
		_dropdown_description_ui.show()
	else:
		_uiname_ui.show()
		_description_ui.show()
		_dropdown_name_ui.hide()
		_dropdown_description_ui.hide()

func _draw_view() -> void:
	_uiname_ui.text = ""
	_description_ui.text = ""
	if _quest:
		_draw_view_uiname_ui()
		_draw_view_description_ui()

func _draw_view_uiname_ui() -> void:
	_uiname_ui.text = str(_quest.uiname)
	_dropdown_name_ui.set_selected_by_value(_quest.uiname)

func _draw_view_description_ui() -> void:
	_description_ui.text = str(_quest.description)
	_dropdown_description_ui.set_selected_by_value(_quest.description)
