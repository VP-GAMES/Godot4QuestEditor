extends HBoxContainer

var _questManager
const _questManagerName = "QuestManager"
var _inventoryManager
const _inventoryManagerName = "InventoryManager"
var _quest: QuestQuest
var _task

@onready var _label_ui = $Label as Label
@onready var _done_ui = $Done as CheckBox
@onready var _task_ui = $Task as RichTextLabel

func _ready() -> void:
	if get_tree().get_root().has_node(_questManagerName):
		_questManager = get_tree().get_root().get_node(_questManagerName)
	if get_tree().get_root().has_node(_inventoryManagerName):
		_inventoryManager = get_tree().get_root().get_node(_inventoryManagerName)

func set_data(quest: QuestQuest, task) -> void:
	_quest = quest
	_task = task
	_questManager.quest_updated.connect(_on_quest_updated)
	_update_data()

func _on_quest_updated(_quest:QuestQuest) -> void:
	_update_data()

func _update_data() -> void:
	var trigger = _questManager.get_quest_trigger_by_ui_uuid(_task.trigger)
	if trigger:
		_label_ui.text = trigger.name
	else:
		var item_db = _inventoryManager.get_item_db(_task.trigger)
		if item_db:
			_label_ui.text = item_db.name
	_done_ui.pressed = _task.done
