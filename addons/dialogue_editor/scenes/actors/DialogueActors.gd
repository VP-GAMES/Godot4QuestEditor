# Dialogue actors UI for DialogueEditor : MIT License
# @author Vladimir Petrenko
@tool
extends Panel

var _data: DialogueData

@onready var _add_ui = $Margin/VBox/HBox/Add as Button
@onready var _actors_ui = $Margin/VBox/Scroll/Actors

const DialogueActorUI = preload("res://addons/dialogue_editor/scenes/actors/DialogueActorUI.tscn")

func set_data(data: DialogueData) -> void:
	_data = data
	_data.sort_actors_by_name()
	_init_connections()
	_update_view()

func _init_connections() -> void:
	if not _add_ui.pressed.is_connected(_on_add_pressed):
		_add_ui.pressed.connect(_on_add_pressed)
	if not _data.actor_added.is_connected(_on_actor_added):
		_data.actor_added.connect(_on_actor_added)
	if not _data.actor_removed.is_connected(_on_actor_removed):
		_data.actor_removed.connect(_on_actor_removed)

func _on_add_pressed() -> void:
	_data.add_actor()

func _on_actor_added(actor: DialogueActor) -> void:
	_update_view()

func _on_actor_removed(actor: DialogueActor) -> void:
	_update_view()
	
func _update_view() -> void:
	_clear_view()
	_draw_view()

func _clear_view() -> void:
	for actor_ui in _actors_ui.get_children():
		_actors_ui.remove_child(actor_ui)
		actor_ui.queue_free()

func _draw_view() -> void:
	for actor in _data.actors:
		_draw_actor(actor)

func _draw_actor(actor: DialogueActor) -> void:
	var actor_ui = DialogueActorUI.instantiate()
	_actors_ui.add_child(actor_ui)
	actor_ui.set_data(actor, _data)
