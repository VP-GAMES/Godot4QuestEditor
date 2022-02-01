@tool
extends QuestNPC2D

@onready var _attention = $Attention as Node2D

func _ready() -> void:
	super._ready()
	if not questManager.player_changed.is_connected(_on_player_changed):
		questManager.player_changed.connect(_on_player_changed)
	if not questManager.quest_started.is_connected(_on_quest_started):
		questManager.quest_started.connect(_on_quest_started)
	if not questManager.quest_ended.is_connected(_on_quest_ended):
		questManager.quest_ended.connect(_on_quest_ended)
	if not questManager.quest_updated.is_connected(_on_quest_updated):
		questManager.quest_updated.connect(_on_quest_updated)

func _on_player_changed() -> void:
	_check_attention()

func _on_quest_started(_p_quest: QuestQuest) -> void:
	_check_attention()

func _on_quest_ended(_p_quest: QuestQuest) -> void:
	_check_attention()

func _on_quest_updated(_p_quest: QuestQuest) -> void:
	_check_attention()

func _check_attention() -> void:
	if (not questManager.is_quest_started() and is_quest_available()) or (get_quest() and is_quest_delivery_available()):
		_attention.show()
	else:
		var quest = questManager.started_quest()
		if quest:
			var task_trigger = questManager.get_trigger_by_ui_uuid(_uuid)
			var task = quest.get_task(task_trigger.uuid)
			if task and task.done != true:
				_attention.show()
			else:
				_attention.hide()
		else:
			_attention.hide()
