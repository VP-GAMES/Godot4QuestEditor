# Dialogue actor ui for DialogueEditor : MIT License
# @author Vladimir Petrenko
@tool
extends MarginContainer

var _actor: DialogueActor
var _data: DialogueData

var _ui_style_selected: StyleBoxFlat

@onready var _texture_ui = $HBox/Texture as TextureRect
@onready var _name_ui = $HBox/Name as LineEdit
@onready var _del_ui = $HBox/Del as Button

func set_data(actor: DialogueActor, data: DialogueData):
	_actor = actor
	_data = data
	_init_styles()
	_init_connections()
	_draw_view()
	_draw_style()

func _init_styles() -> void:
	_ui_style_selected = StyleBoxFlat.new()
	_ui_style_selected.set_bg_color(_data.BACKGROUND_COLOR_SELECTED)

func _init_connections() -> void:
	if not _data.actor_added.is_connected(_on_actor_added):
		assert(_data.actor_added.connect(_on_actor_added) == OK)
	if not _data.actor_removed.is_connected(_on_actor_removed):
		assert(_data.actor_removed.connect(_on_actor_removed) == OK)
	if not _data.actor_selection_changed.is_connected(_on_actor_selection_changed):
		assert(_data.actor_selection_changed.connect(_on_actor_selection_changed) == OK)
	if not _actor.resource_path_changed.is_connected(_on_resource_path_changed):
		assert(_actor.resource_path_changed.connect(_on_resource_path_changed) == OK)
	if not _texture_ui.gui_input.is_connected(_on_gui_input):
		assert(_texture_ui.gui_input.connect(_on_gui_input) == OK)
	if not _name_ui.gui_input.is_connected(_on_gui_input):
		assert(_name_ui.gui_input.connect(_on_gui_input) == OK)
	if not _name_ui.focus_exited.is_connected(_on_focus_exited):
		assert(_name_ui.focus_exited.connect(_on_focus_exited) == OK)
	if not _name_ui.text_changed.is_connected(_on_text_changed):
		assert(_name_ui.text_changed.connect(_on_text_changed) == OK)
	if not _del_ui.pressed.is_connected(_del_pressed):
		assert(_del_ui.pressed.connect(_del_pressed) == OK)

func _on_actor_added(actor: DialogueActor) -> void:
	_draw_style()

func _on_actor_removed(actor: DialogueActor) -> void:
	_draw_style()

func _on_actor_selection_changed(actor: DialogueActor) -> void:
	_draw_style()

func _on_focus_exited() -> void:
	_draw_style()

func _on_resource_path_changed(resource) -> void:
	_draw_texture()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if not _data.selected_actor() == _actor:
					_data.select_actor(_actor)
					_del_ui.grab_focus()
				else:
					_name_ui.remove_theme_stylebox_override("normal")
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			if _name_ui.has_focus():
				_del_ui.grab_focus()

func _on_text_changed(new_text: String) -> void:
	_actor.change_name(new_text)

func _del_pressed() -> void:
	_data.del_actor(_actor)

func _draw_view() -> void:
	_name_ui.text = _actor.name
	_draw_texture()

func _draw_texture() -> void:
	var texture = null
	if _actor and not _actor.resources.is_empty():
		var uuid = _actor.default_uuid()
		texture = _actor.resource_by_uuid(uuid)
		if texture != null:
			texture = _data.resize_texture(texture, Vector2(16, 16))
	if texture == null:
		texture = load("res://addons/dialogue_editor/icons/Actor.png")
	_texture_ui.texture = texture

func _draw_style() -> void:
	if _data.selected_actor() == _actor:
		_name_ui.add_theme_stylebox_override("normal", _ui_style_selected)
	else:
		_name_ui.remove_theme_stylebox_override("normal")
