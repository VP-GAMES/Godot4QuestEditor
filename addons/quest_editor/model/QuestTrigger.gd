# Quest trigger for QuestEditor: MIT License
# @author Vladimir Petrenko
@tool
extends Resource
class_name QuestTrigger

# ***** EDITOR_PLUGIN BOILERPLATE *****
var _editor
var _undo_redo

func set_editor(editor) -> void:
	_editor = editor
	if _editor:
		_undo_redo = _editor.get_undo_redo()
# ***** EDITOR_PLUGIN_END *****


const TYPE_2D ="2D"
const TYPE_3D ="3D"
const DESTINATION = "DESTINATION"
const ENEMY = "ENEMY"
const NPC = "NPC"
const TRIGGER = "TRIGGER"
const UNDEFINED = "UNDEFINED"

signal name_changed(name)
signal scene_changed

@export var uuid: String
@export var name: String
@export var scene: String
@export var type: String = UNDEFINED
@export var dimension: String = ""

var _loaded_scene

func get_loaded_scene():
	if scene:
		if not _loaded_scene:
			_loaded_scene =  load(scene).instantiate()
		return _loaded_scene

func change_name(new_name: String):
	name = new_name
	emit_signal("name_changed")

func change_scene(new_scene: String) -> void:
	scene = new_scene
	var scene_new = load(scene).instantiate()
	type = _scene_type(scene_new)
	dimension = _scene_dimension(scene_new)
	emit_signal("scene_changed")

func scene_valide(scene_path) -> bool:
	var scene = load(scene_path).instantiate()
	if scene is QuestDestination2D:
		return true
	if scene is QuestEnemy2D:
		return true
	if scene is QuestNPC2D:
		return true
	if scene is QuestTrigger2D:
		return true
	if scene is QuestDestination3D:
		return true
	if scene is QuestEnemy3D:
		return true
	if scene is QuestNPC3D:
		return true
	if scene is QuestTrigger3D:
		return true
	return false

func _scene_type(new_scene) -> String:
	if new_scene is QuestDestination2D:
		return DESTINATION
	if new_scene is QuestEnemy2D:
		return ENEMY
	if new_scene is QuestNPC2D:
		return NPC
	if new_scene is QuestTrigger2D:
		return TRIGGER
	if new_scene is QuestDestination3D:
		return DESTINATION
	if new_scene is QuestEnemy3D:
		return ENEMY
	if new_scene is QuestNPC3D:
		return NPC
	if new_scene is QuestTrigger3D:
		return TRIGGER
	return UNDEFINED

func _scene_dimension(new_scene) -> String:
	if new_scene is QuestDestination2D:
		return TYPE_2D
	if new_scene is QuestEnemy2D:
		return TYPE_2D
	if new_scene is QuestNPC2D:
		return TYPE_2D
	if new_scene is QuestTrigger2D:
		return TYPE_2D
	if new_scene is QuestDestination3D:
		return TYPE_3D
	if new_scene is QuestEnemy3D:
		return TYPE_3D
	if new_scene is QuestNPC3D:
		return TYPE_3D
	if new_scene is QuestTrigger3D:
		return TYPE_3D
	return ""
