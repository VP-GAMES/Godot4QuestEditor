# Inventory types UI for InventoryEditor : MIT License
# @author Vladimir Petrenko
@tool
extends Panel

var _data: InventoryData

@onready var _add_ui = $Margin/VBox/HBox/Add as Button
@onready var _types_ui = $Margin/VBox/Scroll/Types

const InventoryTypeUI = preload("res://addons/inventory_editor/scenes/items/InventoryTypeUI.tscn")

func set_data(data: InventoryData) -> void:
	_data = data
	_data.sort_types_by_name()
	_init_connections()
	_update_view()

func _init_connections() -> void:
	if not _add_ui.pressed.is_connected(_on_add_pressed):
		_add_ui.pressed.connect(_on_add_pressed)
	if not _data.type_added.is_connected(_on_type_added):
		_data.type_added.connect(_on_type_added)
	if not _data.type_removed.is_connected(_on_type_removed):
		_data.type_removed.connect(_on_type_removed)

func _on_add_pressed() -> void:
	_data.add_type()

func _on_type_added(type: InventoryType) -> void:
	_update_view()

func _on_type_removed(type: InventoryType) -> void:
	_update_view()
	
func _update_view() -> void:
	_clear_view()
	_draw_view()

func _clear_view() -> void:
	for type_ui in _types_ui.get_children():
		_types_ui.remove_child(type_ui)
		type_ui.queue_free()

func _draw_view() -> void:
	for type in _data.types:
		_draw_type(type)

func _draw_type(type: InventoryType) -> void:
	var type_ui = InventoryTypeUI.instantiate()
	_types_ui.add_child(type_ui)
	type_ui.set_data(type, _data)
