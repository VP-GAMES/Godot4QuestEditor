# Quest 3D destination implementation for QuestEditor : MIT License
# @author Vladimir Petrenko
@tool
extends Area3D
class_name QuestDestination3D

const UUID = preload("res://addons/quest_editor/uuid/uuid.gd")

var dialogueManager
const DialogueManagerName = "DialogueManager"
var questManager
const questManagerName = "QuestManager"

var inside
@export var activate: String = "action"
@export var cancel: String = "cancel"

var _uuid: String
var _quest: QuestQuest

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
	if get_tree().get_root().has_node(DialogueManagerName):
		dialogueManager = get_tree().get_root().get_node(DialogueManagerName)
	if get_tree().get_root().has_node(questManagerName):
		questManager = get_tree().get_root().get_node(questManagerName)
	if not body_entered.is_connected(_on_body_entered):
		assert(body_entered.connect(_on_body_entered) == OK)
	if not body_exited.is_connected(_on_body_exited):
		assert(body_exited.connect(_on_body_exited) == OK)

func _on_body_entered(body: Node) -> void:
	inside = true
	if dialogueManager:
		var trigger = questManager.get_trigger_by_ui_uuid(_uuid)
		_quest = questManager.get_quest_available_by_start_trigger(trigger.uuid)
		if not questManager.is_quest_started():
			if _quest:
				_start_quest_and_dialogue()
		else:
			if _quest:
				if _quest.is_quest_running_dialogue() and not dialogueManager.is_started():
					dialogueManager.start_dialogue(_quest.quest_running_dialogue)
					dialogueManager.next_sentence()
			else:
				_quest = questManager.started_quest()
				var task_trigger = questManager.get_trigger_by_ui_uuid(_uuid)
				var task = questManager.get_task_and_update_quest_state(_quest, task_trigger.uuid)
				if task and task.dialogue and not task.dialogue.is_empty():
					dialogueManager.start_dialogue(task.dialogue)
					dialogueManager.next_sentence()

func _on_body_exited(body: Node) -> void:
	inside = false
	if dialogueManager:
		if dialogueManager.is_started():
			dialogueManager.cancel_dialogue()

func _input(event: InputEvent):
	if inside and dialogueManager:
		if event.is_action_released(activate):
				dialogueManager.next_sentence()

func _start_quest_and_dialogue() -> void:
	if not dialogueManager.is_started():
		if _quest.is_state_undefined() and _quest.is_quest_start_dialogue():
			dialogueManager.start_dialogue(_quest.quest_start_dialogue)
			dialogueManager.next_sentence()
			questManager.start_quest(_quest)
		elif _quest.is_state_started() and _quest.is_quest_running_dialogue():
			dialogueManager.start_dialogue(_quest.quest_running_dialogue)
			dialogueManager.next_sentence()
