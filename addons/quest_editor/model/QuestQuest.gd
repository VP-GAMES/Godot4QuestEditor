# Quest for QuestEditor: MIT License
# @author Vladimir Petrenko
@tool
extends Resource
class_name QuestQuest

# ***** EDITOR_PLUGIN BOILERPLATE *****
var _editor
var _undo_redo

func set_editor(editor) -> void:
	_editor = editor
	if _editor:
		_undo_redo = _editor.get_undo_redo()
# ***** EDITOR_PLUGIN_END *****

signal name_changed(name)
signal uiname_changed(uiname)
signal description_changed(description)
signal state_changed(state)

# * BASE
@export var uuid: String
@export var name: String
@export var uiname: String
@export var description: String
@export var state: String
# * REQUEREMENT
@export var precompleted_quest = ""
@export var requerements: Array
# * DIALOGUE TRIGGER
@export var quest_trigger: String = ""
@export var quest_start_dialogue: String = ""
@export var quest_running_dialogue: String = ""
# * TASKS
@export var linear: bool = false
@export var tasks: Array
# * DELIVERY
@export var delivery: bool = false
@export var delivery_done: bool = false
@export var delivery_trigger: String = ""
@export var delivery_dialogue: String = ""
# * TASKS
@export var rewards: Array

const UUID = preload("res://addons/quest_editor/uuid/uuid.gd")

const QUESTSTATE_UNDEFINED ="UNDEFINED"
const QUESTSTATE_STARTED ="STARTED"
const QUESTSTATE_IN_PROGRESS ="IN_PROGRESS"
const QUESTSTATE_DONE ="DONE"

func _init() -> void:
	uuid = UUID.v4()
	state = QUESTSTATE_UNDEFINED

func change_name(new_name: String):
	name = new_name
	name_changed.emit()

func change_uiname(new_uiname: String):
	uiname = new_uiname
	uiname_changed.emit()

func change_description(new_description: String):
	description = new_description
	description_changed.emit()

func is_state_undefined() -> bool:
	return state == QUESTSTATE_UNDEFINED

func is_state_started() -> bool:
	return state == QUESTSTATE_STARTED or is_state_in_progress()

func is_state_in_progress() -> bool:
	return state == QUESTSTATE_IN_PROGRESS

func is_state_done() -> bool:
	return state == QUESTSTATE_DONE

func is_quest_start_dialogue() -> bool:
	return quest_start_dialogue != null and not quest_start_dialogue.is_empty()

func is_quest_running_dialogue() -> bool:
	return quest_running_dialogue != null and not quest_running_dialogue.is_empty()

func is_quest_delivery_dialogue() -> bool:
	return delivery_dialogue != null and not delivery_dialogue.is_empty()

func check_state() -> void:
	if state == QUESTSTATE_DONE:
		return
	if not tasks_done():
		return
	if not delivery:
		state = QUESTSTATE_DONE
	elif delivery_done:
		state = QUESTSTATE_DONE

# ***** REQUEREMENTS *****
signal requerements_changed

const REQUEREMENT_BOOL ="BOOL"
const REQUEREMENT_TEXT ="TEXT"
const REQUEREMENT_NUMBER = "NUMBER"

func add_requerement() -> void:
	var requerement = {"method": "", "params": "", "type": REQUEREMENT_BOOL, "response": ""}
	if _undo_redo != null:
		_undo_redo.create_action("Add requerement")
		_undo_redo.add_do_method(self, "_add_requerement", requerement)
		_undo_redo.add_undo_method(self, "_del_requerement", requerement)
		_undo_redo.commit_action()
	else:
		_add_requerement(requerement)

func _add_requerement(requerement: Dictionary, position = requerements.size()) -> void:
	if requerements == null:
		requerements = []
	requerements.insert(position, requerement)
	requerements_changed.emit()

func del_requerement(requerement) -> void:
	if _undo_redo != null:
		var index = requerements.find(requerement)
		_undo_redo.create_action("Del requerement")
		_undo_redo.add_do_method(self, "_del_requerement", requerement)
		_undo_redo.add_undo_method(self, "_add_requerement", requerement, false, index)
		_undo_redo.commit_action()
	else:
		_del_requerement(requerement)

func _del_requerement(requerement) -> void:
	var index = requerements.find(requerement)
	if index > -1:
		requerements.remove_at(index)
		requerements_changed.emit()

# ***** TASKS *****
signal tasks_changed

func tasks_done() -> bool:
	for task in tasks:
		if task.done == false:
			return false
	return true

func get_task(trigger_uuid: String):
	for task in tasks:
		if task.trigger == trigger_uuid:
			return task
	return null

func get_task_available_by_trigger(trigger_uuid: String):
	if not linear:
		return get_task(trigger_uuid)
	else:
		var task_found = null
		var all_done = true
		var start = false
		for i in range(tasks.size() - 1, -1, -1):
			var task = tasks[i]
			if start:
				if task.done != true:
					all_done = false
			if task.trigger == trigger_uuid and task.done == false:
				task_found = task
				start = true
		if start == true and all_done == true:
			return task_found
	return null

func get_task_first():
	return tasks[0]

func get_task_bevore(trigger_uuid: String):
	var index = 0
	for task in tasks:
		if task.trigger == trigger_uuid:
			if index == 0:
				return null
			return tasks[index - 1]
		index += 1
	return null

func has_task(trigger_uuid: String) -> bool:
	for task in tasks:
		if task.trigger == trigger_uuid:
			return true
	return false

func get_task_state(trigger_uuid: String) -> bool:
	for task in tasks:
		if task.trigger == trigger_uuid and task.done == true:
			return true
	return false

func update_task_state(trigger_uuid, add_quantity = 0, add_quantity_put = 0):
	for task in tasks:
		if task.trigger == trigger_uuid:
			if not task.has("quantity_now"):
				task["quantity_now"] = 0
			if not task.has("quantity_put"):
				task["quantity_put"] = 0
			if task.quantity > 0:
				if add_quantity > 0:
					task.quantity_now += add_quantity
				if add_quantity_put > 0:
					task.quantity_put += add_quantity_put
			if task.has("quantity_put_do") and task.quantity_put_do == true:
				if task.quantity_now >= task.quantity and task.quantity_put >= task.quantity:
					task.done = true
					state = QUESTSTATE_IN_PROGRESS
			elif task.quantity_now >= task.quantity:
				task.done = true
				state = QUESTSTATE_IN_PROGRESS
			return task
	return null

func add_task() -> void:
	var task = {"uuid": UUID.v4(), "trigger": "", "dialogue": "", "dialogue_done": "", "quantity": 0, "quantity_now": 0, "quantity_put_do": false, "quantity_put": 0, "done": false }
	if _undo_redo != null:
		_undo_redo.create_action("Add task")
		_undo_redo.add_do_method(self, "_add_task", task)
		_undo_redo.add_undo_method(self, "_del_task", task)
		_undo_redo.commit_action()
	else:
		_add_task(task)

func _add_task(task: Dictionary, position = tasks.size()) -> void:
	if tasks == null:
		tasks = []
	tasks.insert(position, task)
	tasks_changed.emit()

func del_task(task) -> void:
	if _undo_redo != null:
		var index = tasks.find(task)
		_undo_redo.create_action("Del task")
		_undo_redo.add_do_method(self, "_del_task", task)
		_undo_redo.add_undo_method(self, "_add_task", task, false, index)
		_undo_redo.commit_action()
	else:
		_del_task(task)

func _del_task(task) -> void:
	var index = tasks.find(task)
	if index > -1:
		tasks.remove_at(index)
		tasks_changed.emit()

# ***** REWARD *****
signal rewards_changed

const REWARD_BOOL ="BOOL"
const REWARD_TEXT ="TEXT"
const REWARD_NUMBER = "NUMBER"

func add_reward() -> void:
	var reward = {"method": "", "params": ""}
	if _undo_redo != null:
		_undo_redo.create_action("Add reward")
		_undo_redo.add_do_method(self, "_add_reward", reward)
		_undo_redo.add_undo_method(self, "_del_reward", reward)
		_undo_redo.commit_action()
	else:
		_add_reward(reward)

func _add_reward(reward: Dictionary, position = rewards.size()) -> void:
	if rewards == null:
		rewards = []
	rewards.insert(position, reward)
	rewards_changed.emit()

func del_reward(reward) -> void:
	if _undo_redo != null:
		var index = rewards.find(reward)
		_undo_redo.create_action("Del reward")
		_undo_redo.add_do_method(self, "_del_reward", reward)
		_undo_redo.add_undo_method(self, "_add_reward", reward, false, index)
		_undo_redo.commit_action()
	else:
		_del_reward(reward)

func _del_reward(reward) -> void:
	var index = rewards.find(reward)
	if index > -1:
		rewards.remove_at(index)
		rewards_changed.emit()

func reset() -> void:
	state = QUESTSTATE_UNDEFINED
	for task in tasks:
		if task.has("quantity_now"):
			task.quantity_now = 0
		if task.has("quantity_put"):
			task.quantity_put = 0
		task.done = false
	delivery_done = false

func print_data() -> void:
	print("*** QUEST: ", name, " UUID: ", uuid, " ***")
	print("UINAME: ", uiname, "DESCRIPTION: ", description)
	print("STATE: ", state)
	print("** REQUEREMENT **")
	print("PRECOMPLETED QUEST: ", precompleted_quest)
	print("REQUEREMENTS: ", requerements)
	print("** DIALOGUE TRIGGER **")
	print("QUEST TRIGGER: ", quest_trigger)
	print("QUEST START DIALOGUE: ", quest_start_dialogue)
	print("QUEST RUNNING DIALOGUE: ", quest_running_dialogue)
	print("** TASKS **")
	for task in tasks:
		print(task)
	print("** DELIVERY **")
	print("DELIVERY: ", delivery)
	print("DELIVERY DONE: ", delivery_done)
	print("DELIVERY TRIGGER: ", delivery_trigger)
	print("DELIVERY DIALOGUE: ", delivery_dialogue)
	print("** REWARDS **")
	print(rewards)
