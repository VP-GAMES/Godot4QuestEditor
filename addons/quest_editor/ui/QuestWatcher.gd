extends Control

var _questManager
const _questManagerName = "QuestManager"
var _localizationManager
const _localizationManagerName = "LocalizationManager"

var _quest: QuestQuest

@export var active: bool =  true

@onready var _name_ui = $Margin/VBox/HBoxName/Name as RichTextLabel
@onready var _description_ui = $Margin/VBox/HBoxDescription/Description as RichTextLabel
@onready var _tasks_ui = $Margin/VBox/VBoxTasks

const QuestWatcherTask = preload("res://addons/quest_editor/ui/QuestWatcherTask.tscn")
const QuestDeliveryTask = preload("res://addons/quest_editor/ui/QuestWatcherDelivery.tscn")

func _ready() -> void:
	if not active:
		return
	if get_tree().get_root().has_node(_questManagerName):
		_questManager = get_tree().get_root().get_node(_questManagerName)
		_questManager.connect("quest_started", self, "_on_quest_started")
		_questManager.connect("quest_updated", self, "_on_quest_updated")
		_questManager.connect("quest_ended", self, "_on_quest_ended")
	if get_tree().get_root().has_node(_localizationManagerName):
		_localizationManager = get_tree().get_root().get_node(_localizationManagerName)
		_localizationManager.connect("translation_changed", self, "_on_translation_changed")
	if _questManager and _localizationManager:
		_quest = _questManager.started_quest()
		if _quest:
			show()
			_quest = _questManager.started_quest()
			_quest_data_update()

func _on_quest_started(quest: QuestQuest) -> void:
	show()
	_quest = quest
	_quest_data_update()

func _on_quest_updated(quest: QuestQuest) -> void:
	_quest = quest
	_quest_data_update()

func _on_quest_ended(_quest_param: QuestQuest) -> void:
	hide()
	_quest = null
	_quest_data_update()

func _on_translation_changed() -> void:
	_quest_data_update()

func _quest_data_update() -> void:
	_clear_tasks_view()
	if _quest:
		_name_ui.bbcode_text = _remove_break_sign(_localizationManager.tr(_quest.uiname))
		_description_ui.bbcode_text = _remove_break_sign(_localizationManager.tr(_quest.description))
		_draw_tasks_view()
	else:
		_name_ui.bbcode_text = _localizationManager.tr(LocalizationKeys.QUEST_HEADER)
		_description_ui.bbcode_text = _localizationManager.tr(LocalizationKeys.QUEST_DESCRIPTION)

func _clear_tasks_view() -> void:
	for task_ui in _tasks_ui.get_children():
		_tasks_ui.remove_child(task_ui)
		task_ui.queue_free()

func _draw_tasks_view() -> void:
	for task in _quest.tasks:
		_draw_task_ui(task)
	if _quest.delivery:
		_draw_delivery_ui()

func _draw_task_ui(task) -> void:
	var task_ui = QuestWatcherTask.instantiate()
	_tasks_ui.add_child(task_ui)
	task_ui.set_data(_quest, task)

func _draw_delivery_ui() -> void:
	var delivery_ui = QuestDeliveryTask.instantiate()
	_tasks_ui.add_child(delivery_ui)
	delivery_ui.set_data(_quest)

func _remove_break_sign(text: String) -> String:
	return text.replace("\n", " ")
