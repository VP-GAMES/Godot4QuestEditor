extends Spatial

var questManager
const questManagerName = "QuestManager"

var _collision_shape

func _ready() -> void:
	_collision_shape = get_node("Item3D/InventoryItem_6550b66f-7b71-4737-b2d1-f70fe102d6b8/CollisionShape") as CollisionShape
	_collision_shape.call_deferred("set_disabled", true)
	if get_tree().get_root().has_node(questManagerName):
		questManager = get_tree().get_root().get_node(questManagerName)
	if not questManager.is_connected("quest_updated", self, "_on_quest_updated"):
		questManager.connect("quest_updated", self, "_on_quest_updated")

func _on_quest_updated(_quest: QuestQuest) -> void:
	if _quest.uuid == QuestManagerQuests.QUEST_3D:
		if _quest.get_task_state(QuestManagerTriggers.JOHN_3D):
			show()
			if has_node("Item3D"):
				_collision_shape.call_deferred("set_disabled", false)
	
