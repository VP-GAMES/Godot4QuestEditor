# Quest 3D enemy implementation for QuestEditor : MIT License
# @author Vladimir Petrenko
@tool
extends Area3D
class_name QuestEnemy3D

const UUID = preload("res://addons/quest_editor/uuid/uuid.gd")

var questManager
const questManagerName = "QuestManager"

var _uuid: String

func get_uuid() -> String:
	if _uuid == null or _uuid.is_empty():
		_update_uuid()
	return _uuid

func _process(delta: float) -> void:
	if _uuid == null or _uuid.is_empty():
		_update_uuid()
	if Engine.is_editor_hint() and (_uuid == null or _uuid.is_empty()):
		var node = Node.new()
		node.name = "QuestTriggerUUID_" + UUID.v4()
		add_child(node)
		node.set_owner(get_tree().edited_scene_root)

func _update_uuid() -> void:
	for child in get_children():
		if str(child.name).begins_with("QuestTriggerUUID_"):
			_uuid = child.name
			break

func _ready() -> void:
	if get_tree().get_root().has_node(questManagerName):
		questManager = get_tree().get_root().get_node(questManagerName)
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if questManager and questManager.is_quest_started():
		var quest = questManager.started_quest()
		var task_trigger = questManager.get_trigger_by_ui_uuid(_uuid)
		var task = questManager.get_task_and_update_quest_state(quest, task_trigger.uuid, 1)
	if body.name == "Weapon":
		queue_free()
