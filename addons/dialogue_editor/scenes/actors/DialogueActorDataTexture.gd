# Dialogue actor data texture for DialogueEditor : MIT License
# @author Vladimir Petrenko
@tool
extends TextureRect

var _resource
var _data: DialogueData

func set_data(data: DialogueData):
	_data = data
	_init_connections()

func _init_connections() -> void:
	if not _data.actor_selection_changed.is_connected(_on_actor_selection_changed):
		_data.actor_selection_changed.connect(_on_actor_selection_changed)

func _on_actor_selection_changed(actor: DialogueActor) -> void:
	if actor:
		if not actor.resource_path_changed.is_connected(_on_resource_path_changed):
			actor.resource_path_changed.connect(_on_resource_path_changed)
		if not actor.resource_selection_changed.is_connected(_on_resource_selection_changed):
			actor.resource_selection_changed.connect(_on_resource_selection_changed)
	else:
		set_resource(null)

func _on_resource_path_changed(resource) -> void:
	if _resource == resource:
		_update_view()

func _on_resource_selection_changed(resource) -> void:
	set_resource(resource)

func set_resource(resource):
	_resource = resource
	_update_view()

func _update_view() -> void:
	var t = null
	if _resource and _data.resource_exists(_resource):
		t = load(_resource.path)
	texture = t
