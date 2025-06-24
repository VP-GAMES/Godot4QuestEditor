# Path UI LineEdit for InventoryEditor : MIT License
# @author Vladimir Petrenko
@tool
extends LineEdit

var _recipe: InventoryRecipe
var _data: InventoryData

var _path_ui_style_resource: StyleBoxFlat

const InventoryRecipeDataResourceDialogFile = preload("res://addons/inventory_editor/scenes/craft/InventoryCraftDataResourceDialogFile.tscn")

func set_data(recipe: InventoryRecipe, data: InventoryData) -> void:
	_recipe = recipe
	_data = data
	_init_styles()
	_init_connections()
	_draw_view()

func _init_styles() -> void:
	_path_ui_style_resource = StyleBoxFlat.new()
	_path_ui_style_resource.set_bg_color(Color("#192e59"))

func _init_connections() -> void:
	if not _recipe.icon_changed.is_connected(_on_icon_changed):
		_recipe.icon_changed.connect(_on_icon_changed)
	if not focus_entered.is_connected(_on_focus_entered):
		focus_entered.connect(_on_focus_entered)
	if not focus_exited.is_connected(_on_focus_exited):
		focus_exited.connect(_on_focus_exited)
	if not text_changed.is_connected(_path_value_changed):
		text_changed.connect(_path_value_changed)
	if not gui_input.is_connected(_on_gui_input):
		gui_input.connect(_on_gui_input)

func _on_icon_changed() -> void:
	_draw_view()

func _draw_view() -> void:
	text = ""
	if _recipe.icon:
		if has_focus():
			text = _recipe.icon
		else:
			text = _data.filename(_recipe.icon)
		_check_path_ui()

func _input(event) -> void:
	if (event is InputEventMouseButton) and event.pressed:
		if not get_global_rect().has_point(event.position):
			release_focus()

func _on_focus_entered() -> void:
	text = _recipe.icon

func _on_focus_exited() -> void:
	text = _data.filename(_recipe.icon)

func _path_value_changed(path_value) -> void:
	_recipe.set_icon(path_value)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_MASK_MIDDLE:
				grab_focus()
				var file_dialog = InventoryRecipeDataResourceDialogFile.instantiate()
				if _data.resource_exists(_recipe.icon):
					file_dialog.current_dir = _data.file_path(_recipe.icon)
					file_dialog.current_file = _data.filename(_recipe.icon)
				for extension in _data.SUPPORTED_IMAGE_RESOURCES:
					file_dialog.add_filter("*." + extension)
				var root = get_tree().get_root()
				root.add_child(file_dialog)
				file_dialog.file_selected.connect(_path_value_changed)
				file_dialog.popup_hide.connect(_on_popup_hide, [root, file_dialog])
				file_dialog.popup_centered()

func _on_popup_hide(root, dialog) -> void:
	root.remove_child(dialog)
	dialog.queue_free()

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
	if _recipe.icon != null and not _data.resource_exists(_recipe.icon):
		add_theme_stylebox_override("normal", _path_ui_style_resource)
		tooltip_text =  "Your resource path: \"" + _recipe.icon + "\" does not exists"
	else:
		remove_theme_stylebox_override("normal")
		tooltip_text =  ""
