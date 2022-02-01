# Quest data requerements UI for QuestEditor : MIT License
# @author Vladimir Petrenko
@tool
extends VBoxContainer

var _quest: QuestQuest
var _data: QuestData

@onready var _quests_dropdown_ui = $HBoxRequerements/Quests as LineEdit
@onready var _add_ui = $HBoxRequerementsAdd/Add as Button
@onready var _requerements_ui = $VBoxRequerementsItems

func set_data(quest: QuestQuest, data: QuestData) -> void:
	_data = data
	_quest = quest
	_init_connections()
	_fill_dropdown()
	_quests_dropdown_ui.set_selected_by_value(_quest.precompleted_quest)
	_requerements_ui.set_data(quest, data)

func _init_connections() -> void:
	if not _quests_dropdown_ui.gui_input.is_connected(_on_gui_input):
		_quests_dropdown_ui.gui_input.connect(_on_gui_input)
	if not _quests_dropdown_ui.selection_changed.is_connected(_on_selection_changed):
		_quests_dropdown_ui.selection_changed.connect(_on_selection_changed)
	if not _add_ui.pressed.is_connected(_on_add_pressed):
		_add_ui.pressed.connect(_on_add_pressed)

func _on_gui_input(event: InputEvent) -> void:
	_fill_dropdown()

func _fill_dropdown() -> void:
	_quests_dropdown_ui.clear()
	var item_null = {"text": "NONE", "value": ""}
	_quests_dropdown_ui.add_item(item_null)
	for quest in _data.quests:
		if quest != _quest:
			var item_d = {"text": quest.name, "value": quest.uuid}
			_quests_dropdown_ui.add_item(item_d)

func _on_selection_changed(quest: Dictionary) -> void:
	_quest.precompleted_quest = quest.value

func _on_add_pressed() -> void:
	_quest.add_requerement()
