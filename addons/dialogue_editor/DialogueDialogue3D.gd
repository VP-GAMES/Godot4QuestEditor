# Dialogue3D as custom type for DialogueEditor : MIT License
# @author Vladimir Petrenko
@tool
extends Area3D
class_name Dialogue3D

var inside
var dialogueManager
const DialogueManagerName = "DialogueManager"

@export var dialogue_name: String
@export var autostart: bool = false
@export var activate: String = "action"
@export var cancel: String = "cancel"

func _ready() -> void:
	if get_tree().get_root().has_node(DialogueManagerName):
		dialogueManager = get_tree().get_root().get_node(DialogueManagerName)
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	for child in get_children():
		if body == child:
			return 
	inside = true
	if autostart:
		_start_dialogue()

func _on_body_exited(body: Node) -> void:
	inside = false
	if dialogueManager:
		if dialogueManager.is_started():
			dialogueManager.cancel_dialogue()

func _input(event: InputEvent):
	if inside and dialogueManager:
		if event.is_action_released(activate):
			if dialogueManager.is_started():
				dialogueManager.next_sentence()
			else:
				_start_dialogue()
				dialogueManager.next_sentence()
		if event.is_action_released(cancel):
			dialogueManager.cancel_dialogue()

func _start_dialogue() -> void:
	if not dialogueManager.is_started():
		dialogueManager.start_dialogue(dialogue_name)
		if autostart:
			dialogueManager.next_sentence()
