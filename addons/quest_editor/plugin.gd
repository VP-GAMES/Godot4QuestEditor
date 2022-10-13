# Plugin QuestEditor : MIT License
# @author Vladimir Petrenko
@tool
extends EditorPlugin

const IconResource = preload("res://addons/quest_editor/icons/Quest.png")
const QuestMain = preload("res://addons/quest_editor/QuestEditor.tscn")

var _quest_main

func _enter_tree():
	add_autoload_singleton("QuestManager", "res://addons/quest_editor/QuestManager.gd")
	_quest_main = QuestMain.instantiate()
	_quest_main.name = "QuestMain"
	get_editor_interface().get_editor_main_screen().add_child(_quest_main)
	_quest_main.set_editor(self)
	_make_visible(false)

func _exit_tree():
	remove_autoload_singleton("QuestManager")
	if _quest_main:
		_quest_main.queue_free()

func _has_main_screen():
	return true

func _make_visible(visible):
	if _quest_main:
		_quest_main.visible = visible

func _get_plugin_name():
	return "Quest"

func _get_plugin_icon():
	return IconResource

#func save_external_data():
#	if _quest_main:
#		_quest_main.save_data()
