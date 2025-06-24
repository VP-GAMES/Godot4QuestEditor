# Inventory type UI for InventoryEditor : MIT License
# @author Vladimir Petrenko
@tool
extends MarginContainer

var _data: InventoryData
var _type: InventoryType

var _ui_style_selected: StyleBoxFlat

@onready var _texture_ui = $HBox/Texture as TextureRect
@onready var _name_ui = $HBox/Name as LineEdit
@onready var _del_ui = $HBox/Del as Button

func set_data(type: InventoryType, data: InventoryData):
	_type = type
	_data = data
	_init_styles()
	_init_connections()
	_draw_view()
	_draw_style()

func _init_styles() -> void:
	_ui_style_selected = StyleBoxFlat.new()
	_ui_style_selected.set_bg_color(_data.BACKGROUND_COLOR_SELECTED)

func _init_connections() -> void:
	if not _data.type_added.is_connected(_on_type_added):
		_data.type_added.connect(_on_type_added)
	if not _data.type_removed.is_connected(_on_type_removed):
		_data.type_removed.connect(_on_type_removed)
	if not _type.icon_changed.is_connected(_on_icon_changed):
		_type.icon_changed.connect(_on_icon_changed)
	if not _data.type_selection_changed.is_connected(_on_type_selection_changed):
		_data.type_selection_changed.connect(_on_type_selection_changed)
	if not _texture_ui.gui_input.is_connected(_on_gui_input):
		_texture_ui.gui_input.connect(_on_gui_input)
	if not _name_ui.gui_input.is_connected(_on_gui_input):
		_name_ui.gui_input.connect(_on_gui_input)
	if not _name_ui.focus_exited.is_connected(_on_focus_exited):
		_name_ui.focus_exited.connect(_on_focus_exited)
	if not _name_ui.text_changed.is_connected(_on_text_changed):
		_name_ui.text_changed.connect(_on_text_changed)
	if not _del_ui.pressed.is_connected(_del_pressed):
		_del_ui.pressed.connect(_del_pressed)

func _on_type_added(type: InventoryType) -> void:
	_draw_style()

func _on_type_removed(type: InventoryType) -> void:
	_draw_style()

func _on_icon_changed() -> void:
	_draw_view()

func _on_type_selection_changed(type: InventoryType) -> void:
	_draw_style()

func _on_focus_exited() -> void:
	_draw_style()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if not _data.selected_type() == _type:
					_data.select_type(_type)
					_del_ui.grab_focus()
				else:
					_name_ui.remove_theme_stylebox_override("normal")
	if event is InputEventKey and event.pressed:
		if event.physical_keycode == KEY_ENTER or event.physical_keycode == KEY_KP_ENTER:
			if _name_ui.has_focus():
				_del_ui.grab_focus()

func _on_text_changed(new_text: String) -> void:
	_type.change_name(new_text)

func _del_pressed() -> void:
	_data.del_type(_type)

func _draw_view() -> void:
	_name_ui.text = _type.name
	_draw_texture()

func _draw_texture() -> void:
	var texture
	if _type.icon != null and not _type.icon.is_empty() and _data.resource_exists(_type.icon):
		texture = load(_type.icon)
	else:
		texture = load("res://addons/inventory_editor/icons/Type.png")
	_texture_ui.texture = texture

func _draw_style() -> void:
	if _data.selected_type() == _type:
		_name_ui.add_theme_stylebox_override("normal", _ui_style_selected)
	else:
		_name_ui.remove_theme_stylebox_override("normal")
