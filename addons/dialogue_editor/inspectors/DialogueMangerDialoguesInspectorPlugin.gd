# EditorInspectorPlugin for Dialogue2D and Dialogue3D in DialogueEditor : MIT License
# @author Vladimir Petrenko
extends EditorInspectorPlugin

var _data: DialogueData

func set_data(data: DialogueData) -> void:
	_data = data

func _can_handle(object):
	return object is Dialogue2D or object is Dialogue3D

func _parse_property(object: Object, type: int, name: String, hint_type: int, hint_string: String, usage_flags: int, wide: bool):
	if type == TYPE_STRING and name == "dialogue_name":
		var dialogueDialogueInspectorEditor = DialogueDialogueInspectorEditor.new()
		dialogueDialogueInspectorEditor.set_data(_data)
		add_property_editor(name, dialogueDialogueInspectorEditor)
		return true
	else:
		return false
