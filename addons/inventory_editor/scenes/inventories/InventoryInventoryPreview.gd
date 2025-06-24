# Inventory preview for InventoryEditor : MIT License
# @author Vladimir Petrenko
@tool
extends VBoxContainer

var _inventory: InventoryInventory
var _data: InventoryData
var _manager: InventoryManager
var _item_selected
var _items: Array
var localization_editor

@onready var _dropdown_ui = $ItemHandler/HBoxContainer/Dropdown
@onready var _quantity_ui = $ItemHandler/HBoxContainer/Quantity as LineEdit
@onready var _add_ui = $ItemHandler/HBoxContainer/Add as Button
@onready var _del_ui = $ItemHandler/HBoxContainer/Del as Button
@onready var _preview_ui = $ScrollPreview/Preview

const InventoryManager = preload("res://addons/inventory_editor/InventoryManager.gd")

func set_data(data: InventoryData) -> void:
	_data = data
	_init_manger()
	_inventory = _data.selected_inventory()
	_init_connections()
	_draw_view()
	_check_view()

func _process(delta: float) -> void:
	if not localization_editor:
		_dropdown_ui_init()

func _dropdown_ui_init() -> void:
	if not localization_editor:
		var localizationEditorPath = "../../../../../../../LocalizationEditor"
		if has_node(localizationEditorPath):
			localization_editor = get_node(localizationEditorPath)
	if localization_editor:
		var data = localization_editor.get_data()
		if data:
			if not data.data_changed.is_connected(_on_localization_data_changed):
				data.data_changed.connect(_on_localization_data_changed)
			if not data.data_key_value_changed.is_connected(_on_localization_data_changed):
				data.data_key_value_changed.connect(_on_localization_data_changed)
			if not _data.locale_changed.is_connected(_locale_changed):
				_data.locale_changed.connect(_locale_changed)
			_on_localization_data_changed()

func _locale_changed(_locale: String):
	_on_localization_data_changed()

func _on_localization_data_changed() -> void:
	_update_items_ui()

func _init_manger() -> void:
	if not _manager:
		_manager = InventoryManager.new()
		_manager.ready(_data)

func _init_connections() -> void:
	if not _data.inventory_added.is_connected(_on_inventory_added):
		_data.inventory_added.connect(_on_inventory_added)
	if not _data.inventory_removed.is_connected(_on_inventory_removed):
		_data.inventory_removed.connect(_on_inventory_removed)
	if not _data.inventory_selection_changed.is_connected(_on_inventory_selection_changed):
		_data.inventory_selection_changed.connect(_on_inventory_selection_changed)
	if not _data.inventory_scene_changed.is_connected(_on_inventory_scene_changed):
		_data.inventory_scene_changed.connect(_on_inventory_scene_changed)
	if not _data.item_added.is_connected(_on_item_added):
		_data.item_added.connect(_on_item_added)
	if not _dropdown_ui.selection_changed.is_connected(_on_selection_changed):
		_dropdown_ui.selection_changed.connect(_on_selection_changed)
	if not _data.item_removed.is_connected(_on_item_removed):
		_data.item_removed.connect(_on_item_removed)
	if not _quantity_ui.text_changed.is_connected(_on_text_changed):
		_quantity_ui.text_changed.connect(_on_text_changed)
	if not _add_ui.pressed.is_connected(_on_add_pressed):
		_add_ui.pressed.connect(_on_add_pressed)
	if not _del_ui.pressed.is_connected(_on_del_pressed):
		_del_ui.pressed.connect(_on_del_pressed)

func _on_inventory_added(inventory: InventoryInventory) -> void:
	_inventory = _data.selected_inventory()
	_draw_view()

func _on_inventory_removed(inventory: InventoryInventory) -> void:
	_inventory = _data.selected_inventory()
	_draw_view()

func _on_inventory_selection_changed(inventory: InventoryInventory) -> void:
	_inventory = _data.selected_inventory()
	_draw_view()

func _on_inventory_scene_changed(inventory: InventoryInventory) -> void:
	_inventory = _data.selected_inventory()
	_draw_view()

func _on_item_added(item: InventoryItem) -> void:
	_update_items_ui()

func _on_item_removed(item: InventoryItem) -> void:
	_update_items_ui()

func _on_text_changed(new_text: String) -> void:
	_check_view()

func _on_selection_changed(item: DropdownItem):
	_item_selected = item
	_check_view()

func _on_add_pressed() -> void:
	_manager.add_item(_inventory.uuid, _item_selected.value, _quantity_ui.text.to_int(), false)

func _on_del_pressed() -> void:
	_manager.remove_item(_inventory.uuid, _item_selected.value, _quantity_ui.text.to_int(), false)

func _draw_view() -> void:
	_update_items_ui()
	_clear_preview()
	_draw_preview()

func _update_items_ui() -> void:
	_items = _data.all_items()
	_dropdown_ui.clear()
	for item in _items:
		var icon = null
		if item.icon != null and _data.resource_exists(item.icon):
			icon = load(item.icon)
		var item_d
		if localization_editor != null:
			var localization_data = localization_editor.get_data()
			var description = localization_data.value_by_locale_key(_data.get_locale(), item.description)
			var name = item.name + "(" + description + ")"
			item_d = DropdownItem.new(item.uuid, name, description, icon)
		else:
			item_d = DropdownItem.new(item.uuid, item.name, item.description, icon)
		_dropdown_ui.add_item(item_d)

func _clear_preview() -> void:
	for child in _preview_ui.get_children():
		_preview_ui.remove_child(child)
		child.queue_free()

func _draw_preview() -> void:
	var inventory = _data.selected_inventory()
	if inventory.scene:
		var scene = load(inventory.scene)
		if scene != null:
			var inventory_scene = scene.instantiate()
			_preview_ui.add_child(inventory_scene)
			if inventory_scene.has_method("set_inventory_manager"):
				inventory_scene.set_inventory_manager(_inventory.uuid, _manager)

func _check_view() -> void:
	if _item_selected != null and _quantity_ui.text.to_int() > 0:
		_add_ui.disabled = false
		_del_ui.disabled = false
	else:
		_add_ui.disabled = true
		_del_ui.disabled = true
