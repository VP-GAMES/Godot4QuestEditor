# QuestInspectorPluginNpc for QuestEditor : MIT License
# @author Vladimir Petrenko
extends EditorInspectorPlugin

var _main_screen: VBoxContainer

func set_data(main_screen: VBoxContainer) -> void:
	_main_screen = main_screen

func _can_handle(object):
	return object is QuestNPC3D or object is QuestNPC3D

func _parse_property(object: Object, type, name: String, hint_type: int, hint_string: String, usage_flags: int, wide: bool):
	if type == TYPE_STRING and name == "dialogue_default":
		var questInspectorPluginNpc = QuestInspectorPluginNpc.new()
		add_property_editor(name, questInspectorPluginNpc)
		questInspectorPluginNpc.set_data(_main_screen)
		return true
	return false
