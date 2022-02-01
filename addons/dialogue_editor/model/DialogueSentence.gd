# Dialogue dialog for DialogueEditor: MIT License
# @author Vladimir Petrenko
@tool
extends Resource
class_name DialogueSentence, "res://addons/dialogue_editor/icons/Sentence.png"

@export var scene: String = ""
@export var actor: Resource # DialogueActor
@export var texture_uuid: String
@export var texte_events: Array = [{"text": "", "event": null, "next": null}]

func text_exists() -> bool:
	return texte_events.size() == 1

func buttons_exists() -> bool:
	return texte_events.size() > 1

func buttons_count() -> int:
	return texte_events.size()
