# Quest data requerements view UI for QuestEditor : MIT License
# @author Vladimir Petrenko
@tool
extends VBoxContainer

var _data: QuestData
var _quest: QuestQuest

const RequerementUI = preload("res://addons/quest_editor/scenes/quests/QuestQuestDataRequerementsViewItem.tscn")

func set_data(quest: QuestQuest, data: QuestData) -> void:
	_data = data
	_quest = quest
	_init_connections()
	_update_view()

func _init_connections() -> void:
	if not _quest.requerements_changed.is_connected(_on_requerements_changed):
		_quest.requerements_changed.connect(_on_requerements_changed)

func _on_requerements_changed() -> void:
	_update_view()

func _update_view() -> void:
	_clear_view()
	_draw_view()

func _clear_view() -> void:
	for requerement_ui in get_children():
		remove_child(requerement_ui)
		requerement_ui.queue_free()

func _draw_view() -> void:
	for requerement in _quest.requerements:
		_draw_requerement(requerement)

func _draw_requerement(requerement) -> void:
	var requerement_ui = RequerementUI.instantiate()
	add_child(requerement_ui)
	requerement_ui.set_data(requerement, _quest, _data)
