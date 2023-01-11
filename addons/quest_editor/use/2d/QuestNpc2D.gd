# Quest 2D NPC implementation for QuestEditor : MIT License
# @author Vladimir Petrenko
@tool
extends Area2D
class_name QuestNPC2D

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

func get_quest() -> QuestQuest:
	return _quest

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

func is_quest_available() -> bool:
	var trigger = questManager.get_trigger_by_ui_uuid(get_uuid())
	if not trigger:
		printerr(name, " Trigger with uuid ", get_uuid(), " not found")
	var quest = questManager.get_quest_available_by_start_trigger(trigger.uuid)
	return quest != null

func is_quest_delivery_available() -> bool:
	var trigger = questManager.get_trigger_by_ui_uuid(get_uuid())
	var quest = questManager.get_quest_available_by_delivery_trigger(trigger.uuid)
	return quest != null and quest.tasks_done()

func _on_body_entered(body: Node) -> void:
	inside = true

func _on_body_exited(body: Node) -> void:
	inside = false
	if dialogueManager != null:
		if dialogueManager.is_started():
			dialogueManager.cancel_dialogue()

func _input(event: InputEvent):
	if inside and dialogueManager != null:
		if event.is_action_released(activate) and not dialogueManager.is_started():
			var trigger = questManager.get_trigger_by_ui_uuid(get_uuid())
			_quest = questManager.get_quest_available_by_start_trigger(trigger.uuid)
			if not questManager.is_quest_started():
				if _quest != null:
					_start_quest_and_dialogue()
			else:
				if _quest != null:
					if _quest.tasks_done() and _quest.is_quest_delivery_dialogue() and not dialogueManager.is_started():
						if _quest.delivery_trigger == trigger.uuid:
							dialogueManager.start_dialogue(_quest.delivery_dialogue)
							questManager.delivery_quest(_quest)
							questManager.call_rewards_methods(_quest)
							questManager.end_quest(_quest)
					elif _quest.is_quest_running_dialogue() and not dialogueManager.is_started():
						dialogueManager.start_dialogue(_quest.quest_running_dialogue)
				else:
					_quest = questManager.started_quest()
					var task_trigger = questManager.get_trigger_by_ui_uuid(get_uuid())
					var task = questManager.get_task_and_update_quest_state(_quest, task_trigger.uuid)
					if task != null and task.dialogue != null and not task.dialogue.is_empty():
						dialogueManager.start_dialogue(task.dialogue)
		if event.is_action_released(activate):
				dialogueManager.next_sentence()
		if event.is_action_released(cancel):
			dialogueManager.cancel_dialogue()

func _start_quest_and_dialogue() -> void:
	if not dialogueManager.is_started():
		if _quest.is_state_undefined() and _quest.is_quest_start_dialogue():
			dialogueManager.start_dialogue(_quest.quest_start_dialogue)
			if not dialogueManager.dialogue_event.is_connected(_dialogue_event_accept_quest):
				dialogueManager.dialogue_event.connect(_dialogue_event_accept_quest)
			if not dialogueManager.dialogue_canceled.is_connected(_dialogue_canceled_event):
				dialogueManager.dialogue_canceled.connect(_dialogue_canceled_event)
			if not dialogueManager.dialogue_ended.is_connected(_dialogue_ended_event):
				dialogueManager.dialogue_ended.connect(_dialogue_ended_event)

func _dialogue_event_accept_quest(event: String) -> void:
	if event == "ACCEPT_QUEST":
		questManager.start_quest(_quest)

func _dialogue_canceled_event(event) -> void:
	_dialogue_ended()

func _dialogue_ended_event(event) -> void:
	_dialogue_ended()

func _dialogue_ended() -> void:
	if dialogueManager.dialogue_event.is_connected(_dialogue_event_accept_quest):
		dialogueManager.dialogue_event.disconnect(_dialogue_event_accept_quest)
	if dialogueManager.dialogue_ended.is_connected(_dialogue_ended_event):
		dialogueManager.dialogue_ended.disconnect(_dialogue_ended_event)
