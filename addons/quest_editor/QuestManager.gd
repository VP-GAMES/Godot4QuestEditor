# QuestManager used for quests in games : MIT License
# @author Vladimir Petrenko
@tool
extends Node

signal quest_loaded(quest)
signal quest_started(quest)
signal quest_updated(quest)
signal quest_ended(quest)
signal player_changed

var _player
var _data: = QuestData.new()
var _data_loaded = false

const PATH_DEFAULT_TO_SAVE = "user://QuestsSave.res"

var _path_to_save = PATH_DEFAULT_TO_SAVE

var player_inside_dialogue_area: bool = false

func _init() -> void:
	load_data()

func data() -> QuestData:
	return _data

func load_data() -> void:
	_data = QuestData.new()
	if FileAccess.file_exists(_path_to_save):
		_data.PATH_TO_SAVE = _path_to_save
		_data.init_data()
	else:
		_data.init_data()
		_data.PATH_TO_SAVE = _path_to_save

func save_data() -> void:
	_data.PATH_TO_SAVE = _path_to_save
	_data.save(false)

func reset_data(save_data_too: bool = true) -> void:
	_data.reset()
	if save_data_too:
		save_data()

func set_player(player) -> void:
	_player = player
	player_changed.emit()

func player():
	if not _player:
		assert(true, "Player not specified for QuestEditor")
	return _player

func is_quest_started() -> bool:
	for quest in _data.quests:
		if quest.state == QuestQuest.QUESTSTATE_STARTED or quest.state == QuestQuest.QUESTSTATE_IN_PROGRESS:
			return true
	return false

func started_quest() -> QuestQuest:
	for quest in _data.quests:
		if quest.state == QuestQuest.QUESTSTATE_STARTED or quest.state == QuestQuest.QUESTSTATE_IN_PROGRESS:
			return quest
	return null

#func started_quest_enum() -> QuestManagerQuests.QuestManagerQuestsEnum:
	

func start_quest(quest: QuestQuest) -> void:
	quest.state = QuestQuest.QUESTSTATE_STARTED
	quest_started.emit(quest)

func delivery_quest(quest: QuestQuest) -> void:
	quest.delivery_done = true
	quest_ended.emit(quest)

func end_quest(quest: QuestQuest) -> void:
	quest.state = QuestQuest.QUESTSTATE_DONE
	quest_ended.emit(quest)

func update_quest() -> void:
	quest_updated.emit(started_quest())

func get_quest_by_uuid(uuid: String) -> QuestQuest:
	return _data.get_quest_by_uuid(uuid)

func get_task_and_update_quest_state(quest: QuestQuest, trigger_uuid: String, add_quantity = 0, add_quantity_put = 0, ignore_linear: bool = false):
	var task = quest.get_task_available_by_trigger(trigger_uuid)
	var quest_updated_state = false
	if not quest.linear or ignore_linear:
		task = quest.update_task_state(trigger_uuid, add_quantity, add_quantity_put)
		if task != null:
			quest_updated_state = true
	else:
		var first_task = quest.get_task_first()
		if first_task != null and first_task.trigger == trigger_uuid:
			if first_task.done != true:
				task = quest.update_task_state(trigger_uuid, add_quantity, add_quantity_put)
				quest_updated_state = true
		else:
			var task_bevore = quest.get_task_bevore(trigger_uuid)
			if task_bevore != null and task_bevore.done == true:
				task = quest.update_task_state(trigger_uuid, add_quantity, add_quantity_put)
				quest_updated_state = true

	if quest_updated_state == true:
		if task.done == true:
			quest.check_state()
			if quest.state == QuestQuest.QUESTSTATE_DONE:
				call_rewards_methods(quest)
				end_quest(quest)
		quest_updated.emit(quest)
	return task

func get_quest_trigger_by_ui_uuid(trigger_ui: String) -> QuestTrigger:
	return _data.get_trigger_by_uuid(trigger_ui)

func get_trigger_by_ui_uuid(trigger_ui: String) -> QuestTrigger:
	for trigger in _data.triggers:
		if trigger.scene != null:
			var scene =  trigger.get_loaded_scene()
			if scene.has_method("get_uuid"):
				var trigger_uuid = scene.get_uuid()
				if trigger_ui == trigger_uuid:
					return trigger
	return null

func print_triggers() -> void:
	for trigger in _data.triggers:
		var scene =  trigger.get_loaded_scene()

func get_quest_available_by_start_trigger(quest_trigger: String) -> QuestQuest:
	var response_quest = null
	for quest in _data.quests:
		if quest.quest_trigger == quest_trigger:
			if quest.state == QuestQuest.QUESTSTATE_STARTED or quest.state == QuestQuest.QUESTSTATE_IN_PROGRESS:
				response_quest = quest
			if quest.state == QuestQuest.QUESTSTATE_UNDEFINED:
				if _precompleted_quest_done(quest):
					if _quest_requerements_fulfilled(quest):
						response_quest = quest
	return response_quest

func get_quest_available_by_delivery_trigger(delivery_trigger: String) -> QuestQuest:
	var response_quest = null
	for quest in _data.quests:
		if quest.delivery_trigger == delivery_trigger:
			if quest.state == QuestQuest.QUESTSTATE_STARTED or quest.state == QuestQuest.QUESTSTATE_IN_PROGRESS and quest.tasks_done():
				response_quest = quest
	return response_quest

func _precompleted_quest_done(quest: QuestQuest) -> bool:
	if quest.precompleted_quest == null or quest.precompleted_quest.is_empty():
		return true
	else:
		return _data.get_quest_by_uuid(quest.precompleted_quest).state == QuestQuest.QUESTSTATE_DONE

func _quest_requerements_fulfilled(quest: QuestQuest) -> bool:
	if quest.requerements.is_empty():
		return true
	for requerement in quest.requerements:
		if not player().has_method(requerement.method):
			printerr("Player has no method " + requerement.method + " defined in " + str(quest.name))
		else:
			match requerement.type:
				QuestQuest.REQUEREMENT_BOOL:
					return _call_requerement_method(requerement) == true
				QuestQuest.REQUEREMENT_NUMBER:
					return _call_requerement_method(requerement) == int(requerement.response)
				QuestQuest.REQUEREMENT_TEXT:
					return _call_requerement_method(requerement) == requerement.response
	return true

func _call_requerement_method(requerement):
	if requerement.params.is_empty():
		return player().call(requerement.method)
	else:
		return player().call(requerement.method, requerement.params)

func call_rewards_methods(quest: QuestQuest):
	if quest.rewards:
		for reward in quest.rewards:
			if reward.params.is_empty():
				return player().call(reward.method)
			else:
				return player().call(reward.method, reward.params)
