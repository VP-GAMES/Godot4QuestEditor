# Dialogue data for DialogueEditor : MIT License
# @author Vladimir Petrenko
@tool
extends Resource
class_name DialogueData

# ***** EDITOR_PLUGIN *****
var _editor
var _undo_redo
var localization_editor

func editor():
	return _editor

func set_editor(editor) -> void:
	_editor = editor
	for actor in actors:
		actor.set_editor(_editor)
	for dialogue in dialogues:
		dialogue.set_editor(_editor)
	_undo_redo = _editor.get_undo_redo()

const UUID = preload("res://addons/dialogue_editor/uuid/uuid.gd")
# ***** EDITOR_PLUGIN_END *****

const default_path = "res://dialogue/"

# ***** LOCALIZATION *****
var _locale

signal locale_changed(locale)

func get_locale() -> String:
	_locale = setting_dialogue_editor_locale()
	if _locale == null:
		_locale = TranslationServer.get_locale()
	return _locale

func set_locale(locale: String) -> void:
	_locale = locale
	setting_dialogue_editor_locale_put(_locale)
	TranslationServer.set_locale(_locale)
	locale_changed.emit(_locale)

# ***** ACTORS *****
signal actor_added(actor)
signal actor_removed(actor)
signal actor_selection_changed(actor)

@export var actors: Array
var _actor_selected: DialogueActor

func add_actor(sendSignal = true) -> void:
		var actor = _create_actor()
		if _undo_redo != null:
			_undo_redo.create_action("Add actor")
			_undo_redo.add_do_method(self, "_add_actor", actor)
			_undo_redo.add_undo_method(self, "_del_actor", actor)
			_undo_redo.commit_action()
		else:
			_add_actor(actor, sendSignal)

func _create_actor() -> DialogueActor:
	var actor = DialogueActor.new()
	actor.uuid = UUID.v4()
	actor.name = _next_actor_name()
	actor.resources = []
	return actor

func _next_actor_name() -> String:
	var value = -9223372036854775807
	var actor_found = false
	for actor in actors:
		var name = actor.name
		if name.begins_with("Actor"):
			actor_found = true
			var behind = actor.name.substr(5)
			var regex = RegEx.new()
			regex.compile("^[0-9]+$")
			var result = regex.search(behind)
			if result:
				var new_value = str(behind).to_int()
				if  value < new_value:
					value = new_value
	var next_name = "Actor"
	if value != -9223372036854775807:
		next_name += str(value + 1)
	elif actor_found:
		next_name += "1"
	return next_name

func _add_actor(actor: DialogueActor, sendSignal = true, position = actors.size()) -> void:
	if actors == null:
		actors = []
	actors.insert(position, actor)
	actor_added.emit(actor)
	select_actor(actor)

func del_actor(actor) -> void:
	if _undo_redo != null:
		var index = actors.find(actor)
		_undo_redo.create_action("Del actor")
		_undo_redo.add_do_method(self, "_del_actor", actor)
		_undo_redo.add_undo_method(self, "_add_actor", actor, false, index)
		_undo_redo.commit_action()
	else:
		_del_actor(actor)

func _del_actor(actor) -> void:
	var index = actors.find(actor)
	if index > -1:
		actors.remove_at(index)
		actor_removed.emit(actor)
		_actor_selected = null
		var actor_selected = selected_actor()
		select_actor(actor_selected)

func selected_actor() -> DialogueActor:
	if not _actor_selected and not actors.is_empty():
		_actor_selected = actors[0]
	return _actor_selected

func select_actor(actor: DialogueActor) -> void:
	_actor_selected = actor
	actor_selection_changed.emit(_actor_selected)

# ***** SCENES *****
signal scene_added(scene)
signal scene_removed(scene)
signal scene_selection_changed(scene)
signal scene_preview_data_changed(scene)

@export var scenes: Array = [
	{"uuid": UUID.v4(), "resource": "res://addons/dialogue_editor/default/DialogueActorLeft.tscn"},
	{"uuid": UUID.v4(), "resource": "res://addons/dialogue_editor/default/DialogueActorCenter.tscn"},
	{"uuid": UUID.v4(), "resource": "res://addons/dialogue_editor/default/DialogueActorRight.tscn"}
]
var _scene_selected

func add_scene(resource: String, sendSignal = true) -> void:
	if _scene_exists(resource):
		printerr("Dialog resource: ", resource, " allready exists")
		return
	var scene = _create_scene(resource)
	if _undo_redo != null:
		_undo_redo.create_action("Add scene")
		_undo_redo.add_do_method(self, "_add_scene", scene)
		_undo_redo.add_undo_method(self, "_del_scene", scene)
		_undo_redo.commit_action()
	else:
		_add_scene(scene, sendSignal)

func _scene_exists(resource: String) -> bool:
	for scene in scenes:
		if scene.resource == resource:
			return true
	return false 

func _create_scene(resource):
	return {"uuid": UUID.v4(), "resource": resource}

func _add_scene(scene, sendSignal = true, position = scenes.size()) -> void:
	scenes.insert(position, scene)
	scene_added.emit(scene)
	select_scene(scene)

func del_scene(scene) -> void:
	if _undo_redo != null:
		var index = scenes.find(scene)
		_undo_redo.create_action("Del scene")
		_undo_redo.add_do_method(self, "_del_scene", scene)
		_undo_redo.add_undo_method(self, "_add_scene", scene, false, index)
		_undo_redo.commit_action()
	else:
		_del_scene(scene)

func _del_scene(scene) -> void:
	var index = scenes.find(scene)
	if index > -1:
		scenes.remove_at(index)
		scene_removed.emit(scene)
		_scene_selected = null
		var scene_selected = selected_scene()
		select_scene(scene_selected)

func selected_scene():
	if _scene_selected == null and not scenes.is_empty():
		_scene_selected = scenes[0]
	return _scene_selected

func select_scene(scene) -> void:
	_scene_selected = scene
	scene_selection_changed.emit(_scene_selected)

func emit_signal_scene_preview_data_changed(scene) -> void:
	scene_preview_data_changed.emit(scene)

# ***** DIALOGUES *****
signal dialogue_changed
signal dialogue_added(dialogue)
signal dialogue_removed(dialogue)
signal dialogue_selection_changed(dialogue)
signal dialogue_view_selection_changed

@export var dialogues: Array

var _dialogue_selected: DialogueDialogue

func add_dialogue(sendSignal = true) -> void:
	var dialogue = _create_dialogue()
	if _undo_redo != null:
		_undo_redo.create_action("Add dialogue")
		_undo_redo.add_do_method(self, "_add_dialogue", dialogue)
		_undo_redo.add_undo_method(self, "_del_dialogue", dialogue)
		_undo_redo.commit_action()
	else:
		_add_dialogue(dialogue, sendSignal)

func _create_dialogue() -> DialogueDialogue:
	var dialogue = DialogueDialogue.new()
	dialogue.uuid = UUID.v4()
	dialogue.name = _next_dialogue_name() 
	dialogue.set_editor(_editor)
	return dialogue

func copy_dialogue(sendSignal = true) -> void:
	var dialogue = _copy_dialogue()
	if _undo_redo != null:
		_undo_redo.create_action("Copy dialogue")
		_undo_redo.add_do_method(self, "_add_dialogue", dialogue)
		_undo_redo.add_undo_method(self, "_del_dialogue", dialogue)
		_undo_redo.commit_action()
	else:
		_add_dialogue(dialogue, sendSignal)

func _copy_dialogue() -> DialogueDialogue:
	if _dialogue_selected == null:
		return _create_dialogue()
	else:
		var dialogue: DialogueDialogue = DialogueDialogue.new()
		dialogue.uuid = UUID.v4()
		dialogue.name = _next_dialogue_name(_dialogue_selected.name)
		dialogue.scroll_offset = _dialogue_selected.scroll_offset
		dialogue.set_editor(_editor)
		dialogue.nodes = []
		if _dialogue_selected.nodes.size() > 0:
			for node_dialogue_selected in _dialogue_selected.nodes:
				var node = DialogueNode.new()
				node.set_editor(_editor)
				node.uuid = node_dialogue_selected.uuid
				node.type = node_dialogue_selected.type
				node.title = node_dialogue_selected.title
				node.position = node_dialogue_selected.position
				node.scene = node_dialogue_selected.scene
				node.actor = node_dialogue_selected.actor
				node.texture_uuid = node_dialogue_selected.texture_uuid
				node.texture_view = node_dialogue_selected.texture_view
				node.sentence_selected_uuid = node_dialogue_selected.sentence_selected_uuid
				dialogue.nodes.append(node)
				if node_dialogue_selected.sentences.size() > 0:
					node.sentences = []
					for sentence_dialogue_selected in node_dialogue_selected.sentences:
						var sentence = {
							"uuid": UUID.v4(),
							"text": sentence_dialogue_selected.text,
							"event_visible": sentence_dialogue_selected.event_visible,
							"event": sentence_dialogue_selected.event,
							"node_uuid": sentence_dialogue_selected.node_uuid
						}
						node.sentences.append(sentence)
			for node_dialogue_selected in _dialogue_selected.nodes:
				var old_uuid = node_dialogue_selected.uuid
				var new_uuid = UUID.v4()
				for node_to_reuuid in dialogue.nodes:
					if node_to_reuuid.uuid == old_uuid:
						node_to_reuuid.uuid = new_uuid
					for sentence_to_reuuid in node_to_reuuid.sentences:
						if sentence_to_reuuid.node_uuid == old_uuid:
							sentence_to_reuuid.node_uuid = new_uuid
		return dialogue

func _next_dialogue_name(base_name: String = "Dialogue") -> String:
	var value = -9223372036854775807
	var dialogue_found = false
	for dialogue in dialogues:
		var name = dialogue.name
		if name.begins_with(base_name):
			dialogue_found = true
			var behind = dialogue.name.substr(8)
			var regex = RegEx.new()
			regex.compile("^[0-9]+$")
			var result = regex.search(behind)
			if result:
				var new_value = str(behind).to_int()
				if  value < new_value:
					value = new_value
	var next_name = base_name
	if value != -9223372036854775807:
		next_name += str(value + 1)
	elif dialogue_found:
		next_name += "1"
	return next_name

func _add_dialogue(dialogue: DialogueDialogue, sendSignal = true, position = dialogues.size()) -> void:
	if dialogues == null:
		dialogues = []
	dialogues.insert(position, dialogue)
	dialogue_added.emit(dialogue)
	dialogue_changed.emit()
	select_dialogue(dialogue)

func del_dialogue(dialogue) -> void:
	if _undo_redo != null:
		var index = dialogues.find(dialogue)
		_undo_redo.create_action("Del dialogue")
		_undo_redo.add_do_method(self, "_del_dialogue", dialogue)
		_undo_redo.add_undo_method(self, "_add_dialogue", dialogue, false, index)
		_undo_redo.commit_action()
	else:
		_del_dialogue(dialogue)

func _del_dialogue(dialogue) -> void:
	var index = dialogues.find(dialogue)
	if index > -1:
		dialogues.remove_at(index)
		dialogue_removed.emit(dialogue)
		dialogue_changed.emit()
		_dialogue_selected = null
		var dialogue_selected = selected_dialogue()
		select_dialogue(dialogue_selected)

func selected_dialogue() -> DialogueDialogue:
	if not _dialogue_selected and not dialogues.is_empty():
		var selected_name = setting_dialogues_selected_dialogue()
		_dialogue_selected = dialogue_by_name(selected_name)
		if not _dialogue_selected:
			select_dialogue(dialogues[0])
	return _dialogue_selected

func select_dialogue(dialogue: DialogueDialogue, emitSignal = true) -> void:
	_dialogue_selected = dialogue
	if _dialogue_selected:
		setting_dialogues_selected_dialogue_put(_dialogue_selected.uuid)
	if emitSignal:
		dialogue_selection_changed.emit(_dialogue_selected)

# ***** LOAD SAVE *****
func init_data() -> void:
	if FileAccess.file_exists(PATH_TO_SAVE):
		var resource = ResourceLoader.load(PATH_TO_SAVE) as DialogueData
		if resource.actors and not resource.actors.is_empty():
			actors = resource.actors
		if resource.scenes and not resource.scenes.is_empty():
			scenes = resource.scenes
		if resource.dialogues and not resource.dialogues.is_empty():
			dialogues = resource.dialogues
		_chech_uuids()

func _chech_uuids() -> void:
	for actor in actors:
		if actor.uuid == null or actor.uuid.is_empty():
			actor.uuid = UUID.v4()
	for scene in scenes:
		if scene.uuid == null or scene.uuid.is_empty():
			scene.uuid = UUID.v4()
	for dialogue in dialogues:
		if dialogue.uuid == null or dialogue.uuid.is_empty():
			dialogue.uuid = UUID.v4()

func save(update_script_classes = false) -> void:
	ResourceSaver.save(self, PATH_TO_SAVE)
	_save_data_dialogue_names()
	_save_data_dialogue_events()
	if update_script_classes:
		_editor.get_editor_interface().get_resource_filesystem().scan()

func _save_data_dialogue_names() -> void:
	var dir:= DirAccess.open(default_path)
	if not dir:
		dir.make_dir(default_path)
	var fileAccess = FileAccess.open(default_path + "DialogueDialogues.gd", FileAccess.WRITE)
	var source_code = "# Names for DialogueManger to use in source code: MIT License\n"
	source_code += AUTHOR
	source_code += "@tool\n"
	source_code += "class_name DialogueDialogues\n\n"
	for dialogue in dialogues:
		var namePrepared = dialogue.name.replace(" ", "")
		namePrepared = namePrepared.to_upper()
		source_code += "const " + namePrepared + " = \"" + dialogue.uuid +"\"\n"
	source_code += "\nconst DIALOGUES = [\n"
	for index in range(dialogues.size()):
		source_code += " \"" + dialogues[index].name + "\""
		if index != dialogues.size() - 1:
			source_code += ",\n"
	source_code += "\n]"
	fileAccess.store_string(source_code)

func _save_data_dialogue_events() -> void:
	var fileAccess = FileAccess.open(default_path + "DialogueEvents.gd", FileAccess.WRITE)
	var source_code = "# Events for DialogueManger to use in source code: MIT License\n"
	source_code += AUTHOR
	source_code += "@tool\n"
	source_code += "class_name DialogueEvents\n\n"
	for dialogue in dialogues:
		for event in dialogue.events():
			var sub_events = event.split(",")
			for eve in sub_events:
				source_code += "const " + dialogue.name.to_upper() + "_EVENT_" + eve.to_upper()
				source_code += " = \"" + eve +"\"\n"
	fileAccess.store_string(source_code)
	

func dialogue_exists(dialogue_uuid_or_name: String) -> bool:
	if dialogue_exists_by_uuid(dialogue_uuid_or_name):
		return true
	return dialogue_exists_by_name(dialogue_uuid_or_name)

func dialogue_exists_by_uuid(dialogue_uuid: String) -> bool:
	for dialogue in dialogues:
		if dialogue.uuid == dialogue_uuid:
			return true
	return false

func dialogue_exists_by_name(dialogue_name: String) -> bool:
	for dialogue in dialogues:
		if dialogue.name == dialogue_name:
			return true
	return false

func dialogue(dialogue_uuid_or_name: String) -> DialogueDialogue:
	var dialogue = dialogue_by_uuid(dialogue_uuid_or_name)
	if dialogue:
		return dialogue
	else:
		return dialogue_by_name(dialogue_uuid_or_name)

func dialogue_by_uuid(dialogue_uuid: String) -> DialogueDialogue:
	for dialogue in dialogues:
		if dialogue.uuid == dialogue_uuid:
			return dialogue
	return null

func dialogue_by_name(dialogue_name: String) -> DialogueDialogue:
	for dialogue in dialogues:
		if dialogue.name == dialogue_name:
			return dialogue
	return null

# ***** EDITOR SETTINGS *****
const BACKGROUND_COLOR_SELECTED = Color("#868991")
const SLOT_COLOR_DEFAULT = Color(1, 1, 1)
const SLOT_COLOR_PATH = Color(0.4, 0.78, 0.945)

const PATH_TO_SAVE = "res://addons/dialogue_editor/DialogueSave.res"
const AUTHOR = "# @author Vladimir Petrenko\n"
const SETTINGS_ACTORS_SPLIT_OFFSET = "dialogue_editor/actors_split_offset"
const SETTINGS_ACTORS_SPLIT_OFFSET_DEFAULT = 215
const SUPPORTED_ACTOR_RESOURCES = ["bmp", "jpg", "jpeg", "png", "svg", "svgz", "tres"]
const SETTINGS_SCENES_SPLIT_OFFSET = "dialogue_editor/scenes_split_offset"
const SETTINGS_SCENES_SPLIT_OFFSET_DEFAULT = 215
const SETTINGS_DIALOGUES_SPLIT_OFFSET = "dialogue_editor/dialogues_split_offset"
const SETTINGS_DIALOGUES_SPLIT_OFFSET_DEFAULT = 215
const SETTINGS_DIALOGUES_SELECTED_DIALOGUE = "dialogue_editor/dialogues_selected_dialogue"
const SETTINGS_DIALOGUES_EDITOR_TYPE = "dialogue_editor/dialogues_editor_type"
const SETTINGS_DIALOGUES_EDITOR_LOCALE = "dialogue_editor/dialogues_editor_locale"
const SETTINGS_DIALOGUES_EDITOR_TYPE_DEFAULT = "NODES"
const SETTINGS_DISPLAY_WIDTH = "display/window/size/viewport_width"
const SETTINGS_DISPLAY_HEIGHT = "display/window/size/viewport_height"

func setting_actors_split_offset() -> int:
	var offset = SETTINGS_ACTORS_SPLIT_OFFSET_DEFAULT
	if ProjectSettings.has_setting(SETTINGS_ACTORS_SPLIT_OFFSET):
		offset = ProjectSettings.get_setting(SETTINGS_ACTORS_SPLIT_OFFSET)
	return offset

func setting_actors_split_offset_put(offset: int) -> void:
	ProjectSettings.set_setting(SETTINGS_ACTORS_SPLIT_OFFSET, offset)
	ProjectSettings.save()

func setting_scenes_split_offset() -> int:
	var offset = SETTINGS_SCENES_SPLIT_OFFSET_DEFAULT
	if ProjectSettings.has_setting(SETTINGS_SCENES_SPLIT_OFFSET):
		offset = ProjectSettings.get_setting(SETTINGS_SCENES_SPLIT_OFFSET)
	return offset

func setting_scenes_split_offset_put(offset: int) -> void:
	ProjectSettings.set_setting(SETTINGS_SCENES_SPLIT_OFFSET, offset)
	ProjectSettings.save()

func setting_dialogues_split_offset() -> int:
	var offset = SETTINGS_DIALOGUES_SPLIT_OFFSET_DEFAULT
	if ProjectSettings.has_setting(SETTINGS_DIALOGUES_SPLIT_OFFSET):
		offset = ProjectSettings.get_setting(SETTINGS_DIALOGUES_SPLIT_OFFSET)
	return offset

func setting_dialogues_split_offset_put(offset: int) -> void:
	ProjectSettings.set_setting(SETTINGS_DIALOGUES_SPLIT_OFFSET, offset)
	ProjectSettings.save()

func setting_dialogues_selected_dialogue() -> String:
	var dialogue_name
	if ProjectSettings.has_setting(SETTINGS_DIALOGUES_SELECTED_DIALOGUE):
		dialogue_name = ProjectSettings.get_setting(SETTINGS_DIALOGUES_SELECTED_DIALOGUE)
	return dialogue_name

func setting_dialogues_selected_dialogue_put(dialogue_name: String) -> void:
	ProjectSettings.set_setting(SETTINGS_DIALOGUES_SELECTED_DIALOGUE, dialogue_name)
	ProjectSettings.save()

func setting_dialogues_editor_type() -> String:
	var type = SETTINGS_DIALOGUES_EDITOR_TYPE_DEFAULT
	if ProjectSettings.has_setting(SETTINGS_DIALOGUES_EDITOR_TYPE):
		type = ProjectSettings.get_setting(SETTINGS_DIALOGUES_EDITOR_TYPE)
	return type

func setting_dialogues_editor_type_put(type: String) -> void:
	ProjectSettings.set_setting(SETTINGS_DIALOGUES_EDITOR_TYPE, type)
	ProjectSettings.save()
	dialogue_view_selection_changed.emit()

func setting_display_size() -> Vector2:
	var width = ProjectSettings.get_setting(SETTINGS_DISPLAY_WIDTH)
	var height = ProjectSettings.get_setting(SETTINGS_DISPLAY_HEIGHT)
	return Vector2(width, height)

func setting_dialogue_editor_locale():
	if ProjectSettings.has_setting(SETTINGS_DIALOGUES_EDITOR_LOCALE):
		return ProjectSettings.get_setting(SETTINGS_DIALOGUES_EDITOR_LOCALE)
	return null

func setting_dialogue_editor_locale_put(locale: String) -> void:
	ProjectSettings.set_setting(SETTINGS_DIALOGUES_EDITOR_LOCALE, locale)
	ProjectSettings.save()

func setting_localization_editor_enabled() -> bool:
	if ProjectSettings.has_setting("editor_plugins/enabled"):
		var enabled_plugins = ProjectSettings.get_setting("editor_plugins/enabled") as Array
		for plugin in enabled_plugins:
			if "localization_editor" in plugin:
				return true
	return false

# ***** UTILS *****
func filename(value: String) -> String:
	var index = value.rfind("/")
	return value.substr(index + 1)

func filename_only(value: String) -> String:
	var first = value.rfind("/")
	var second = value.rfind(".")
	return value.substr(first + 1, second - first - 1)

func file_path(value: String) -> String:
	var index = value.rfind("/")
	return value.substr(0, index)

func file_extension(value: String):
	var index = value.rfind(".")
	if index == -1:
		return null
	return value.get_extension()

func resource_exists(resource) -> bool:
	return FileAccess.file_exists(resource.path)

func resize_texture(t: Texture2D, size: Vector2) -> Texture:
	if t == null:
		return null
	var tx = t.duplicate()
	var itex = ImageTexture.create_from_image(tx.get_image())
	itex.set_size_override(size)
	return itex

func sort_dialogue_by_name() -> void:
	dialogues.sort_custom(func(a, b): return a.name < b.name)

func sort_actors_by_name() -> void:
	actors.sort_custom(func(a, b): return a.name < b.name)

func sort_scenes_by_name() -> void:
	scenes.sort_custom(func(a, b): return filename_only(a.resource) < filename_only(b.resource))
