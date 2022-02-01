@tool
extends QuestTrigger2D

@onready var _trigger = $Trigger as Node2D

func _ready() -> void:
	super._ready()

func _input(event: InputEvent):
	if inside and event.is_action_released(activate):
		if questManager and questManager.is_quest_started():
			var quest = questManager.started_quest()
			var task_trigger = questManager.get_trigger_by_ui_uuid(_uuid)
			var task = questManager.get_task_and_update_quest_state(quest, task_trigger.uuid)
			if task.done == true:
				_trigger.flip_h = true
