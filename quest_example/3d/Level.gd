# 3D Level to demonstrate functionality of QuestEditor : MIT License
# @author Vladimir Petrenko
extends Spatial

var _questManager
const _questManagerName = "QuestManager"
var _localizationManager
const _localizationManagerName = "LocalizationManager"
var _inventoryManager
const _inventoryManagerName = "InventoryManager"

onready var _inventory_button_ui = $CanvasLayer/InventoryButton as TextureButton
onready var _inventory_ui = $CanvasLayer/Inventory
onready var _quest_button_ui = $CanvasLayer/QuestButton as TextureButton
onready var _quest_ui = $CanvasLayer/Quest
onready var _label_ui = $CanvasLayer/Label as RichTextLabel
onready var _timer_ui = $CanvasLayer/Timer as Timer

const _timeout = 3
const textureSimple = preload("res://quest_example/textures/Quest.png")
const textureExtended = preload("res://quest_example/textures/QuestNow.png")

func _ready() -> void:
	if get_tree().get_root().has_node(_inventoryManagerName):
		_inventoryManager = get_tree().get_root().get_node(_inventoryManagerName)
		_inventoryManager.clear_inventory(InventoryManagerInventory.INVENTORY)
	if get_tree().get_root().has_node(_localizationManagerName):
		_localizationManager = get_tree().get_root().get_node(_localizationManagerName)
	if get_tree().get_root().has_node(_questManagerName):
		_questManager = get_tree().get_root().get_node(_questManagerName)
		_questManager.set_player($Player)
		_questManager.connect("quest_started", self, "_on_quest_started")
		_questManager.connect("quest_ended", self, "_on_quest_ended")
	_inventory_button_ui.connect("pressed", self, "_on_inventory_button_pressed")
	_quest_button_ui.connect("pressed", self, "_on_quest_button_pressed")
	_timer_ui.connect("timeout", self, "_on_timer_timeout")

func _on_quest_started(_quest: QuestQuest) -> void:
	_label_ui.show()
	_label_ui.bbcode_text = _localizationManager.tr(LocalizationKeys.QUEST_STARTED_TEXT) + _localizationManager.tr(_quest.uiname)
	_timer_ui.start(_timeout)
	_quest_button_ui.texture_normal = textureExtended

func _on_quest_ended(_quest: QuestQuest) -> void:
	_label_ui.show()
	_label_ui.bbcode_text = _localizationManager.tr(LocalizationKeys.QUEST_ENDED_TEXT) + _localizationManager.tr(_quest.uiname)
	_timer_ui.start(_timeout)
	_quest_button_ui.texture_normal = textureSimple

func _on_inventory_button_pressed() -> void:
	if _inventory_ui.visible:
		_inventory_ui.hide()
	else:
		_inventory_ui.show()

func _on_quest_button_pressed() -> void:
	if _quest_ui.visible:
		_quest_ui.hide()
	else:
		_quest_ui.show()

func _on_timer_timeout() -> void:
	_label_ui.hide()
