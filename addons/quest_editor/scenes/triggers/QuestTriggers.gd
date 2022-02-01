# Quest triggers UI for QuestEditor : MIT License
# @author Vladimir Petrenko
@tool
extends Panel

var _data: QuestData

@onready var _add_ui = $Margin/VBox/HBox/Add as Button
@onready var _triggers_ui = $Margin/VBox/Scroll/Triggers as VBoxContainer

const QuestTriggerUI = preload("res://addons/quest_editor/scenes/triggers/QuestTriggerUI.tscn")

func set_data(data: QuestData) -> void:
	_data = data
	_init_connections()
	_update_view()

func _init_connections() -> void:
	if not _add_ui.pressed.is_connected(_on_add_pressed):
		assert(_add_ui.pressed.connect(_on_add_pressed) == OK)
	if not _data.trigger_added.is_connected(_on_trigger_added):
		assert(_data.trigger_added.connect(_on_trigger_added) == OK)
	if not _data.trigger_removed.is_connected(_on_trigger_removed):
		assert(_data.trigger_removed.connect(_on_trigger_removed) == OK)

func _on_add_pressed() -> void:
	_data.add_trigger()

func _on_trigger_added(trigger: QuestTrigger) -> void:
	_update_view()

func _on_trigger_removed(trigger: QuestTrigger) -> void:
	_update_view()
	
func _update_view() -> void:
	_clear_view()
	_draw_view()

func _clear_view() -> void:
	for trigger_ui in _triggers_ui.get_children():
		_triggers_ui.remove_child(trigger_ui)
		trigger_ui.queue_free()

func _draw_view() -> void:
	for trigger in _data.triggers:
		_draw_trigger(trigger)

func _draw_trigger(trigger: QuestTrigger) -> void:
	var trigger_ui = QuestTriggerUI.instantiate()
	_triggers_ui.add_child(trigger_ui)
	trigger_ui.set_data(trigger, _data)
