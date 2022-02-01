# Quest data rewards view UI for QuestEditor : MIT License
# @author Vladimir Petrenko
@tool
extends VBoxContainer

var _data: QuestData
var _quest: QuestQuest

const RewardUI = preload("res://addons/quest_editor/scenes/quests/QuestQuestDataRewardsViewItem.tscn")

func set_data(quest: QuestQuest, data: QuestData) -> void:
	_data = data
	_quest = quest
	_init_connections()
	_update_view()

func _init_connections() -> void:
	if not _quest.rewards_changed.is_connected(_on_rewards_changed):
		_quest.rewards_changed.connect(_on_rewards_changed)

func _on_rewards_changed() -> void:
	_update_view()

func _update_view() -> void:
	_clear_view()
	_draw_view()

func _clear_view() -> void:
	for reward_ui in get_children():
		remove_child(reward_ui)
		reward_ui.queue_free()

func _draw_view() -> void:
	for reward in _quest.rewards:
		_draw_reward(reward)

func _draw_reward(reward) -> void:
	var reward_ui = RewardUI.instantiate()
	add_child(reward_ui)
	reward_ui.set_data(reward, _quest, _data)
