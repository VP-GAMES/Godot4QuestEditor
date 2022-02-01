# Plugin QuestEditor : MIT License
# @author Vladimir Petrenko
tool
extends EditorPlugin

const IconResource = preload("res://addons/quest_editor/icons/Quest.png")
const QuestMain = preload("res://addons/quest_editor/QuestEditor.tscn")

var _quest_main

func _enter_tree():
	_quest_main = QuestMain.instantiate()
	_quest_main.name = "QuestMain"
	get_editor_interface().get_editor_viewport().add_child(_quest_main)
	_quest_main.set_editor(self)
	make_visible(false)

func _exit_tree():
	if _quest_main:
		_quest_main.queue_free()

func has_main_screen():
	return true

func make_visible(visible):
	if _quest_main:
		_quest_main.visible = visible

func get_plugin_name():
	return "Quest"

func get_plugin_icon():
	return IconResource

func save_external_data():
	if _quest_main:
		_quest_main.save_data()
