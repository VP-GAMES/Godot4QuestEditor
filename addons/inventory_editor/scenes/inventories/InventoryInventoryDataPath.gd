# Path UI LineEdit for InventoryEditor : MIT License
# @author Vladimir Petrenko
@tool
extends LineEdit

var _inventory: InventoryInventory
var _data: InventoryData

var _path_ui_style_resource: StyleBoxFlat

func set_data(inventory: InventoryInventory, data: InventoryData) -> void:
	_inventory = inventory
	_data = data
	_init_styles()
	_init_connections()
	_draw_view()

func _init_styles() -> void:
	_path_ui_style_resource = StyleBoxFlat.new()
	_path_ui_style_resource.set_bg_color(Color("#192e59"))

func _init_connections() -> void:
	if not _inventory.icon_changed.is_connected(_on_icon_changed):
		assert(_inventory.icon_changed.connect(_on_icon_changed) == OK)
	if not focus_entered.is_connected(_on_focus_entered):
		assert(focus_entered.connect(_on_focus_entered) == OK)
	if not focus_exited.is_connected(_on_focus_exited):
		assert(focus_exited.connect(_on_focus_exited) == OK)
	if not text_changed.is_connected(_path_value_changed):
		assert(text_changed.connect(_path_value_changed) == OK)

func _on_icon_changed() -> void:
	_draw_view()

func _draw_view() -> void:
	text = ""
	if _inventory.icon:
		if has_focus():
			text = _inventory.icon
		else:
			text = _data.filename(_inventory.icon)
		_check_path_ui()

func _input(event) -> void:
	if (event is InputEventMouseButton) and event.pressed:
		if not get_global_rect().has_point(event.position):
			release_focus()

func _on_focus_entered() -> void:
	text = _inventory.icon

func _on_focus_exited() -> void:
	text = _data.filename(_inventory.icon)

func _path_value_changed(path_value) -> void:
	_inventory.set_icon(path_value)
	_data.emit_inventory_icon_changed(_inventory)

func _can_drop_data(position, data) -> bool:
	var path_value = data["files"][0]
	var path_extension = _data.file_extension(path_value)
	for extension in _data.SUPPORTED_IMAGE_RESOURCES:
		if path_extension == extension:
			return true
	return false

func _drop_data(position, data) -> void:
	var path_value = data["files"][0]
	_path_value_changed(path_value)

func _check_path_ui() -> void:
	if _inventory.icon != null and not _data.resource_exists(_inventory.icon):
		add_theme_stylebox_override("normal", _path_ui_style_resource)
		tooltip_text =  "Your resource path: \"" + _inventory.icon + "\" does not exists"
	else:
		remove_theme_stylebox_override("normal")
		tooltip_text =  ""
