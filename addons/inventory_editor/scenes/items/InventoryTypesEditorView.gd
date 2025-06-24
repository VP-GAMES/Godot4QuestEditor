# Types view for InventoryEditor : MIT License
# @author Vladimir Petrenko
@tool
extends VBoxContainer

var _data: InventoryData
var _split_viewport_size = 0

@onready var _split_ui = $Split
@onready var _types_ui = $Split/Types
@onready var _type_data_ui = $Split/VBoxData/TypeData
@onready var _separator_ui = $Split/VBoxData/HSeparator
@onready var _type_items_ui = $Split/VBoxData/Items

func set_data(data: InventoryData) -> void:
	_data = data
	_types_ui.set_data(data)
	_type_data_ui.set_data(data)
	_type_items_ui.set_data(data)
	_init_connections()
	check_view_visibility()

func _init_connections() -> void:
	if not _split_ui.dragged.is_connected(_on_split_dragged):
		_split_ui.dragged.connect(_on_split_dragged)
	if not _data.type_added.is_connected(_on_type_added):
		_data.type_added.connect(_on_type_added)
	if not _data.type_removed.is_connected(_on_type_removed):
		_data.type_removed.connect(_on_type_removed)

func _process(delta):
	if _split_viewport_size != size.x:
		_split_viewport_size = size.x
		_init_split_offset()

func _init_split_offset() -> void:
	var offset = InventoryData.SETTINGS_TYPES_SPLIT_OFFSET_DEFAULT
	if _data:
		offset = _data.setting_types_split_offset()
	_split_ui.set_split_offset(-size.x / 2 + offset)

func _on_split_dragged(offset: int) -> void:
	if _data != null:
		var value = -(-size.x / 2 - offset)
		_data.setting_types_split_offset_put(value)

func _on_type_added(type) -> void:
	check_view_visibility()

func _on_type_removed(type) -> void:
	check_view_visibility()

func check_view_visibility() -> void:
	if _data.types.size() > 0:
		_type_data_ui.show()
		_separator_ui.show()
		_type_items_ui.show()
	else:
		_type_data_ui.hide()
		_separator_ui.hide()
		_type_items_ui.hide()
