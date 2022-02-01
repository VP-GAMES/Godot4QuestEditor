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

const _path_to_save = "user://QuestsSave.res"

func _init() -> void:
	var file = File.new()
	if file.file_exists(_path_to_save):
		_data.PATH_TO_SAVE = _path_to_save
	if not _data_loaded:
		load_data()

func load_data() -> void:
	_data = ResourceLoader.load(_data.PATH_TO_SAVE) as QuestData

func save_data() -> void:
	_data.PATH_TO_SAVE = _path_to_save
	_data.save(false)

func reset_data() -> void:
	_data.reset()

func set_player(player) -> void:
	_player = player
	emit_signal("player_changed")

func player():
	if not _player:
		assert(true, "Player not specified for QuestEditor")
	return _player

func is_quest_started() -> bool:
	for quest in _data.quests:
		if quest.state == QuestQuest.QUESTSTATE_STARTED:
			return true
	return false

func started_quest() -> QuestQuest:
	for quest in _data.quests:
		if quest.state == QuestQuest.QUESTSTATE_STARTED:
			return quest
	return null

func start_quest(quest: QuestQuest) -> void:
	quest.state = QuestQuest.QUESTSTATE_STARTED
	emit_signal("quest_started", quest)

func end_quest(quest: QuestQuest) -> void:
	quest.state = QuestQuest.QUESTSTATE_DONE
	emit_signal("quest_ended", quest)

func get_task_and_update_quest_state(quest: QuestQuest, trigger_uuid: String, add_quantity = 0):
	var task = quest.update_task_state(trigger_uuid, add_quantity)
	if task and task.done == true:
		quest.check_state()
		if quest.state == QuestQuest.QUESTSTATE_DONE:
			call_rewards_methods(quest)
			emit_signal("quest_ended", quest)
		else:
			emit_signal("quest_updated", quest)
	return task

func get_quest_trigger_by_ui_uuid(trigger_ui: String) -> QuestTrigger:
	return _data.get_trigger_by_uuid(trigger_ui)

func get_trigger_by_ui_uuid(trigger_ui: String) -> QuestTrigger:
	for trigger in _data.triggers:
		if trigger.scene:
			var scene =  trigger.get_loaded_scene()
			if scene.has_method("get_uuid"):
				var trigger_uuid = scene.get_uuid()
				if trigger_ui == trigger_uuid:
					return trigger
	return null

func print_triggers() -> void:
	for trigger in _data.triggers:
		var scene =  trigger.get_loaded_scene()
		if scene.has_method('get_uuid'):
			print(scene.get_uuid())

func get_quest_available_by_start_trigger(quest_trigger: String) -> QuestQuest:
	var response_quest = null
	for quest in _data.quests:
		if quest.quest_trigger == quest_trigger:
			if quest.state == QuestQuest.QUESTSTATE_STARTED:
				response_quest = quest
			if quest.state == QuestQuest.QUESTSTATE_UNDEFINED:
				if _precompleted_quest_done(quest) and _quest_requerements_fulfilled(quest):
					response_quest = quest
	return response_quest

func get_quest_available_by_delivery_trigger(delivery_trigger: String) -> QuestQuest:
	var response_quest = null
	for quest in _data.quests:
		if quest.delivery_trigger == delivery_trigger:
			if quest.state == QuestQuest.QUESTSTATE_STARTED:
				response_quest = quest
	return response_quest

func _precompleted_quest_done(quest: QuestQuest) -> bool:
	if not quest.precompleted_quest or quest.precompleted_quest.is_empty():
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
