# Quest data UI for QuestEditor : MIT License
# @author Vladimir Petrenko
@tool
extends VBoxContainer

var _quest: QuestQuest
var _data: QuestData

@onready var _vbox_ui = $VBox
@onready var _name_description_ui = $VBox/QuestQuestNameDescription as VBoxContainer
@onready var _requerements_ui = $VBox/QuestQuestRequerements as VBoxContainer
@onready var _start_ui = $VBox/QuestQuestStart as VBoxContainer
@onready var _tasks_ui = $VBox/QuestQuestTasks as VBoxContainer
@onready var _delivery_ui = $VBox/QuestQuestDelivery as VBoxContainer
@onready var _rewards_ui = $VBox/VBoxRewards as VBoxContainer

func set_data(data: QuestData) -> void:
	_data = data
	_init_connections()
	_selection_changed()

func _init_connections() -> void:
	if not _data.quest_selection_changed.is_connected(_on_quest_selection_changed):
		_data.quest_selection_changed.connect(_on_quest_selection_changed)

func _on_quest_selection_changed(quest: QuestQuest) -> void:
	_selection_changed()

func _selection_changed() -> void:
	_quest = _data.selected_quest()
	if _quest:
		_vbox_ui.show()
		_quest = _data.selected_quest()
		_name_description_ui.set_data(_quest, _data)
		_requerements_ui.set_data(_quest, _data)
		_start_ui.set_data(_quest, _data)
		_tasks_ui.set_data(_quest, _data)
		_delivery_ui.set_data(_quest, _data)
		_rewards_ui.set_data(_quest, _data)
	else:
		_vbox_ui.hide()
