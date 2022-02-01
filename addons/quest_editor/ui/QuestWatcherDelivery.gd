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

func set_data(quest: QuestQuest) -> void:
	_quest = quest
	_questManager.quest_updated.connect(_on_quest_updated)
	_update_data()

func _on_quest_updated(_quest:QuestQuest) -> void:
	_update_data()

func _update_data() -> void:
	_label_ui.text = "Delivery"
	_done_ui.pressed = _quest.delivery_done
