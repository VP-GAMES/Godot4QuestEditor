# Quest data for QuestEditor : MIT License
# @author Vladimir Petrenko
@tool
extends Resource
class_name QuestData

# ***** EDITOR_PLUGIN *****
var _editor
var _undo_redo

func editor():
	return _editor

func set_editor(editor) -> void:
	_editor = editor
	for quest in quests:
		quest.set_editor(_editor)
		quest.set_editor(_editor)
	_undo_redo = _editor.get_undo_redo()

const UUID = preload("res://addons/quest_editor/uuid/uuid.gd")
# ***** EDITOR_PLUGIN_END *****

const default_path = "res://quest/"

# ***** QUEST *****
signal quest_added(quest)
signal quest_removed(quest)
signal quest_selection_changed(quest)
signal quest_stacks_changed(quest)
signal quest_icon_changed(quest)
signal quest_scene_changed(quest)

func emit_quest_stacks_changed(quest: QuestQuest) -> void:
	emit_signal("quest_stacks_changed", quest)

func emit_quest_icon_changed(quest: QuestQuest) -> void:
	emit_signal("quest_icon_changed", quest)

func emit_quest_scene_changed(quest: QuestQuest) -> void:
	emit_signal("quest_scene_changed", quest)

@export var quests: Array = [_create_quest()]
var _quest_selected: QuestQuest

func add_quest(sendSignal = true) -> void:
	var quest = _create_quest()
	if _undo_redo != null:
		_undo_redo.create_action("Add quest")
		_undo_redo.add_do_method(self, "_add_quest", quest)
		_undo_redo.add_undo_method(self, "_del_quest", quest)
		_undo_redo.commit_action()
	else:
		_add_quest(quest, sendSignal)

func _create_quest() -> QuestQuest:
	var quest = QuestQuest.new()
	quest.set_editor(_editor)
	quest.uuid = UUID.v4()
	quest.name = _next_quest_name()
	return quest

func _next_quest_name() -> String:
	var base_name = "Quest"
	var value = -9223372036854775807
	var quest_found = false
	if quests:
		for quest in quests:
			var name = quest.name
			if name.begins_with(base_name):
				quest_found = true
				var behind = quest.name.substr(base_name.length())
				var regex = RegEx.new()
				regex.compile("^[0-9]+$")
				var result = regex.search(behind)
				if result:
					var new_value = int(behind)
					if  value < new_value:
						value = new_value
	var next_name = base_name
	if value != -9223372036854775807:
		next_name += str(value + 1)
	elif quest_found:
		next_name += "1"
	return next_name

func _add_quest(quest: QuestQuest, sendSignal = true, position = quests.size()) -> void:
	if quests == null:
		quests = []
	quests.insert(position, quest)
	emit_signal("quest_added", quest)
	select_quest(quest)

func del_quest(quest) -> void:
	if _undo_redo != null:
		var index = quests.find(quest)
		_undo_redo.create_action("Del quest")
		_undo_redo.add_do_method(self, "_del_quest", quest)
		_undo_redo.add_undo_method(self, "_add_quest", quest, false, index)
		_undo_redo.commit_action()
	else:
		_del_quest(quest)

func _del_quest(quest) -> void:
	var index = quests.find(quest)
	if index > -1:
		quests.remove_at(index)
		emit_signal("quest_removed", quest)
		_quest_selected = null
		var quest_selected = selected_quest()
		select_quest(quest_selected)

func selected_quest() -> QuestQuest:
	if not _quest_selected and not quests.is_empty():
		_quest_selected = quests[0]
	return _quest_selected

func select_quest(quest: QuestQuest) -> void:
	_quest_selected = quest
	emit_signal("quest_selection_changed", _quest_selected)

func get_quest_by_uuid(uuid: String) -> QuestQuest:
	for quest in quests:
		if quest.uuid == uuid:
			return quest
	return null

func get_quest_by_name(quest_name: String) -> QuestQuest:
	for quest in quests:
		if quest.name == quest_name:
			return quest
	return null

# ***** TRIGGER *****
signal trigger_added(trigger)
signal trigger_removed(trigger)
signal trigger_selection_changed(trigger)
signal trigger_stacks_changed(trigger)
signal trigger_icon_changed(trigger)
signal trigger_scene_changed(trigger)

func emit_trigger_stacks_changed(trigger: QuestTrigger) -> void:
	emit_signal("trigger_stacks_changed", trigger)

func emit_trigger_icon_changed(trigger: QuestTrigger) -> void:
	emit_signal("trigger_icon_changed", trigger)

func emit_trigger_scene_changed(trigger: QuestTrigger) -> void:
	emit_signal("trigger_scene_changed", trigger)

@export var triggers: Array = [_create_trigger()]
var _trigger_selected: QuestTrigger

func add_trigger(sendSignal = true) -> void:
	var trigger = _create_trigger()
	if _undo_redo != null:
		_undo_redo.create_action("Add trigger")
		_undo_redo.add_do_method(self, "_add_trigger", trigger)
		_undo_redo.add_undo_method(self, "_del_trigger", trigger)
		_undo_redo.commit_action()
	else:
		_add_trigger(trigger, sendSignal)

func _create_trigger() -> QuestTrigger:
	var trigger = QuestTrigger.new()
	trigger.set_editor(_editor)
	trigger.uuid = UUID.v4()
	trigger.name = _next_trigger_name()
	return trigger

func _next_trigger_name() -> String:
	var base_name = "Trigger"
	var value = -9223372036854775807
	var trigger_found = false
	if triggers:
		for trigger in triggers:
			var name = trigger.name
			if name.begins_with(base_name):
				trigger_found = true
				var behind = trigger.name.substr(base_name.length())
				var regex = RegEx.new()
				regex.compile("^[0-9]+$")
				var result = regex.search(behind)
				if result:
					var new_value = int(behind)
					if  value < new_value:
						value = new_value
	var next_name = base_name
	if value != -9223372036854775807:
		next_name += str(value + 1)
	elif trigger_found:
		next_name += "1"
	return next_name

func _add_trigger(trigger: QuestTrigger, sendSignal = true, position = triggers.size()) -> void:
	if triggers == null:
		triggers = []
	triggers.insert(position, trigger)
	emit_signal("trigger_added", trigger)
	select_trigger(trigger)

func del_trigger(trigger) -> void:
	if _undo_redo != null:
		var index = triggers.find(trigger)
		_undo_redo.create_action("Del trigger")
		_undo_redo.add_do_method(self, "_del_trigger", trigger)
		_undo_redo.add_undo_method(self, "_add_trigger", trigger, false, index)
		_undo_redo.commit_action()
	else:
		_del_trigger(trigger)

func _del_trigger(trigger) -> void:
	var index = triggers.find(trigger)
	if index > -1:
		triggers.remove_at(index)
		emit_signal("trigger_removed", trigger)
		_trigger_selected = null
		var trigger_selected = selected_trigger()
		select_trigger(trigger_selected)

func selected_trigger() -> QuestTrigger:
	if not _trigger_selected and not triggers.is_empty():
		_trigger_selected = triggers[0]
	return _trigger_selected

func select_trigger(trigger: QuestTrigger) -> void:
	_trigger_selected = trigger
	emit_signal("trigger_selection_changed", _trigger_selected)

func get_trigger_by_uuid(uuid: String) -> QuestTrigger:
	for trigger in triggers:
		if trigger.uuid == uuid:
			return trigger
	return null

func get_trigger_by_name(trigger_name: String) -> QuestTrigger:
	for trigger in triggers:
		if trigger.name == trigger_name:
			return trigger
	return null

func all_destinations() -> Array:
	var destinations = []
	for trigger in triggers:
		if trigger.type and trigger.type == QuestTrigger.DESTINATION:
			destinations.append(trigger)
	return destinations

func all_enemies() -> Array:
	var enemies = []
	for trigger in triggers:
		if trigger.type and trigger.type == QuestTrigger.ENEMY:
			enemies.append(trigger)
	return enemies

func all_items() -> Array:
	var items = []
	for trigger in triggers:
		if trigger.type and trigger.type == QuestTrigger.ITEM:
			items.append(trigger)
	return items

func all_npcs() -> Array:
	var npcs = []
	for trigger in triggers:
		if trigger.type and trigger.type == QuestTrigger.NPC:
			npcs.append(trigger)
	return npcs

func all_triggers() -> Array:
	var triggers_use = []
	for trigger in triggers:
		if trigger.type and trigger.type == QuestTrigger.TRIGGER:
			triggers_use.append(trigger)
	return triggers_use

func reset() -> void:
	for quest in quests:
		quest.reset()

# ***** LOAD SAVE *****
func init_data() -> void:
	var file = File.new()
	if file.file_exists(PATH_TO_SAVE):
		var resource = ResourceLoader.load(PATH_TO_SAVE) as QuestData
		if resource.quests and not resource.quests.is_empty():
			quests = resource.quests
		if resource.triggers and not resource.triggers.is_empty():
			triggers = resource.triggers


var _path_to_save = "user://QuestsSave.res"

func reset_saved_user_data() -> void:
	print("REMOVE USER SAVED DATA")
	var dir = Directory.new()
	if dir.file_exists(_path_to_save):
		dir.remove(_path_to_save)

func save(update_script_classes = false) -> void:	
	ResourceSaver.save(PATH_TO_SAVE, self)
	_save_data_quests()
	_save_data_triggers()
	if update_script_classes:
		_editor.get_editor_interface().get_resource_filesystem().update_script_classes()

func _save_data_quests() -> void:
	var directory = Directory.new()
	if not directory.dir_exists(default_path):
		directory.make_dir(default_path)
	var file = File.new()
	file.open(default_path + "QuestManagerQuests.gd", File.WRITE)
	var source_code = "# List of created quests for QuestManger to use in source code: MIT License\n"
	source_code += AUTHOR
	source_code += "tool\n"
	source_code += "class_name QuestManagerQuests\n\n"
	for quest in quests:
		var namePrepared = quest.name.replace(" ", "")
		namePrepared = namePrepared.to_upper()
		source_code += "const " + namePrepared + " = \"" + quest.uuid +"\"\n"
	source_code += "\nconst QUESTS = [\n"
	for index in range(quests.size()):
		source_code += " \"" + quests[index].name + "\""
		if index != quests.size() - 1:
			source_code += ",\n"
	source_code += "\n]"
	file.store_string(source_code)
	file.close()

func _save_data_triggers() -> void:
	var directory = Directory.new()
	if not directory.dir_exists(default_path):
		directory.make_dir(default_path)
	var file = File.new()
	file.open(default_path + "QuestManagerTriggers.gd", File.WRITE)
	var source_code = "# List of created triggers for QuestManger to use in source code: MIT License\n"
	source_code += AUTHOR
	source_code += "tool\n"
	source_code += "class_name QuestManagerTriggers\n\n"
	for trigger in triggers:
		var namePrepared = trigger.name.replace(" ", "")
		namePrepared = namePrepared.to_upper()
		source_code += "const " + namePrepared + " = \"" + trigger.uuid +"\"\n"
	source_code += "\nconst TRIGGERS = [\n"
	for index in range(triggers.size()):
		source_code += " \"" + triggers[index].name + "\""
		if index != triggers.size() - 1:
			source_code += ",\n"
	source_code += "\n]"
	file.store_string(source_code)
	file.close()

# ***** EDITOR SETTINGS *****
const BACKGROUND_COLOR_SELECTED = Color("#868991")
const SLOT_COLOR_DEFAULT = Color(1, 1, 1)
const SLOT_COLOR_PATH = Color(0.4, 0.78, 0.945)

var PATH_TO_SAVE = "res://addons/quest_editor/QuestsSave.res"
const AUTHOR = "# @author Vladimir Petrenko\n"
const SETTINGS_QUESTS_SPLIT_OFFSET = "quest_editor/quests_split_offset"
const SETTINGS_QUESTS_SPLIT_OFFSET_DEFAULT = 215
const SETTINGS_TRIGGERS_SPLIT_OFFSET = "quest_editor/triggers_split_offset"
const SETTINGS_TRIGGERS_SPLIT_OFFSET_DEFAULT = 215

func setting_quests_split_offset() -> int:
	var offset = SETTINGS_QUESTS_SPLIT_OFFSET_DEFAULT
	if ProjectSettings.has_setting(SETTINGS_QUESTS_SPLIT_OFFSET):
		offset = ProjectSettings.get_setting(SETTINGS_QUESTS_SPLIT_OFFSET)
	return offset

func setting_quests_split_offset_put(offset: int) -> void:
	ProjectSettings.set_setting(SETTINGS_QUESTS_SPLIT_OFFSET, offset)

func setting_triggers_split_offset() -> int:
	var offset = SETTINGS_TRIGGERS_SPLIT_OFFSET_DEFAULT
	if ProjectSettings.has_setting(SETTINGS_TRIGGERS_SPLIT_OFFSET):
		offset = ProjectSettings.get_setting(SETTINGS_TRIGGERS_SPLIT_OFFSET)
	return offset

func setting_triggers_split_offset_put(offset: int) -> void:
	ProjectSettings.set_setting(SETTINGS_TRIGGERS_SPLIT_OFFSET, offset)

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
	return value.substr(index + 1)

func resource_exists(resource_path) -> bool:
	var file = File.new()
	return file.file_exists(resource_path)

func resize_texture(t: Texture, size: Vector2):
	var itex = t
	if itex:
		var texture = t.get_data()
		if size.x > 0 && size.y > 0:
			texture.resize(size.x, size.y)
		itex = ImageTexture.new()
		itex.create_from_image(texture)
	return itex
