# Drag and drop UI for QuestEditor : MIT License
# @author Vladimir Petrenko
# This is a workaround for https://github.com/godotengine/godot/issues/30480
@tool
extends TextureRect

var _trigger: QuestTrigger
var _data: QuestData

func set_data(trigger: QuestTrigger, data: QuestData) -> void:
	_trigger = trigger
	_data = data

func can_drop_data(position, data) -> bool:
	var resource_value = data["files"][0]
	var resource_extension = _data.file_extension(resource_value)
	if resource_extension == "tscn":
		if _trigger.scene_valide(resource_value):
			return true
	return false


func drop_data(position, data) -> void:
	var path_value = data["files"][0]
	_trigger.change_scene(path_value)
