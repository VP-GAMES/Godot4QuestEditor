# Quest data tasks UI for QuestEditor : MIT License
# @author Vladimir Petrenko
@tool
extends VBoxContainer

var _quest: QuestQuest
var _data: QuestData

@onready var _add_ui = $HBoxTasksAdd/Add as Button
@onready var _linear = $HBoxTasksAdd/Linear as CheckBox
@onready var _tasks_ui = $VBoxTasksItems

func set_data(quest: QuestQuest, data: QuestData) -> void:
	_data = data
	_quest = quest
	_linear.button_pressed = quest.linear
	_init_connections()
	_tasks_ui.set_data(quest, data)

func _init_connections() -> void:
	if not _add_ui.pressed.is_connected(_on_add_pressed):
		_add_ui.pressed.connect(_on_add_pressed)
	if not _linear.toggled.is_connected(_on_linear_pressed):
		_linear.toggled.connect(_on_linear_pressed)

func _on_add_pressed() -> void:
	_quest.add_task()

func _on_linear_pressed(button_pressed: bool) -> void:
	_quest.linear = button_pressed
