# Quest data rewards item UI for QuestEditor : MIT License
# @author Vladimir Petrenko
@tool
extends HBoxContainer

const _types = [QuestQuest.REWARD_BOOL, QuestQuest.REWARD_TEXT, QuestQuest.REWARD_NUMBER]

var _reward: Dictionary
var _quest: QuestQuest
var _data: QuestData

@onready var _method_ui = $Method as LineEdit
@onready var _params_ui = $Params as LineEdit
@onready var _delete_ui = $Del as Button

func set_data(reward: Dictionary, quest: QuestQuest, data: QuestData) -> void:
	_reward = reward
	_quest = quest
	_data = data
	_init_connections()
	_update_view()

func _init_connections() -> void:
	if not _method_ui.text_changed.is_connected(_on_method_text_changed):
		_method_ui.text_changed.connect(_on_method_text_changed)
	if not _params_ui.text_changed.is_connected(_on_params_text_changed):
		_params_ui.text_changed.connect(_on_params_text_changed)
	if not _delete_ui.pressed.is_connected(_on_delete_pressed):
		_delete_ui.pressed.connect(_on_delete_pressed)

func _on_method_text_changed(new_text: String) -> void:
	_reward.method = new_text

func _on_type_item_selected(index: int) -> void:
	_reward.type = _types[index]

func _on_params_text_changed(new_text: String) -> void:
	_reward.params = new_text

func _on_delete_pressed() -> void:
	_quest.del_reward(_reward)

func _update_view() -> void:
	_method_ui.text = _reward.method
	_params_ui.text = _reward.params
