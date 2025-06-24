# Path scene UI LineEdit for InventoryEditor : MIT License
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
	if not _inventory.scene_changed.is_connected(_on_scene_changed):
		_inventory.scene_changed.connect(_on_scene_changed)
	if not focus_entered.is_connected(_on_focus_entered):
		focus_entered.connect(_on_focus_entered)
	if not focus_exited.is_connected(_on_focus_exited):
		focus_exited.connect(_on_focus_exited)
	if not text_changed.is_connected(_path_value_changed):
		text_changed.connect(_path_value_changed)

func _on_scene_changed() -> void:
	_draw_view()

func _draw_view() -> void:
	text = ""
	if _inventory.scene:
		if has_focus():
			text = _inventory.scene
		else:
			text = _data.filename(_inventory.scene)
		_check_path_ui()

func _input(event) -> void:
	if (event is InputEventMouseButton) and event.pressed:
		if not get_global_rect().has_point(event.position):
			release_focus()

func _on_focus_entered() -> void:
	text = _inventory.scene

func _on_focus_exited() -> void:
	text = _data.filename(_inventory.scene)

func _path_value_changed(path_value) -> void:
	_inventory.set_scene(path_value)
	_data.emit_inventory_scene_changed(_inventory)

func _can_drop_data(position, data) -> bool:
	var path_value = data["files"][0]
	var path_extension = _data.file_extension(path_value)
	if path_extension == "tscn":
		return true
	return false

func _drop_data(position, data) -> void:
	var path_value = data["files"][0]
	_path_value_changed(path_value)

func _check_path_ui() -> void:
	if _inventory.scene != null and not _data.resource_exists(_inventory.scene):
		add_theme_stylebox_override("normal", _path_ui_style_resource)
		tooltip_text =  "Your resource path: \"" + _inventory.scene + "\" does not exists"
	else:
		remove_theme_stylebox_override("normal")
		tooltip_text =  ""
