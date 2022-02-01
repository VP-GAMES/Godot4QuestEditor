# Quest 2D player implementation for QuestEditor : MIT License
# @author Vladimir Petrenko
extends CharacterBody2D
class_name QuestPlayer2D

var _questManager
const _questManagerName = "QuestManager"
var _inventoryManager
const _inventoryManagerName = "InventoryManager"

func _ready() -> void:
	if get_tree().get_root().has_node(_questManagerName):
		_questManager = get_tree().get_root().get_node(_questManagerName)
	_questManager.set_player(self)
	if get_tree().get_root().has_node(_inventoryManagerName):
		_inventoryManager = get_tree().get_root().get_node(_inventoryManagerName)
	_inventoryManager.player = self
