# Remap UI LineEdit for LocalizationEditor : MIT License
# @author Vladimir Petrenko
# Drag and drop not work just now, see Workaround -> LocalizationRemapPut
# https://github.com/godotengine/godot/issues/30480
@tool
extends LineEdit

var _key
var _remap
var _data: LocalizationData

var _remap_ui_style_empty: StyleBoxFlat
var _remap_ui_style_resource: StyleBoxFlat
var _remap_ui_style_resource_diff: StyleBoxFlat
var _remap_ui_style_resource_double: StyleBoxFlat

const LocalizationRemapDialogFile = preload("res://addons/localization_editor/scenes/remaps/LocalizationRemapDialogFile.tscn")

func set_data(key, remap, data: LocalizationData) -> void:
	_key = key
	_remap = remap
	_data = data
	_init_styles()
	_init_connections()
	_draw_view()

func _init_styles() -> void:
	var style_box = get_theme_stylebox("normal", "LineEdit")
	_remap_ui_style_empty = style_box.duplicate()
	_remap_ui_style_empty.set_bg_color(Color("#661c1c"))
	_remap_ui_style_resource = style_box.duplicate()
	_remap_ui_style_resource.set_bg_color(Color("#192e59"))
	_remap_ui_style_resource_diff = style_box.duplicate()
	_remap_ui_style_resource_diff.set_bg_color(Color("#514200"))
	_remap_ui_style_resource_double = style_box.duplicate()
	_remap_ui_style_resource_double.set_bg_color(Color("#174044"))
	
func _init_connections() -> void:
	if not _data.is_connected("data_remapkey_value_changed", _draw_view):
		_data.data_remapkey_value_changed.connect(_draw_view)
	if not is_connected("focus_entered", _on_focus_entered):
		focus_entered.connect(_on_focus_entered)
	if not is_connected("focus_exited", _on_focus_exited):
		focus_exited.connect(_on_focus_exited)
	if not is_connected("text_changed", _remap_value_changed):
		text_changed.connect(_remap_value_changed)
	if not is_connected("gui_input", _on_gui_input):
		gui_input.connect(_on_gui_input)

func _draw_view() -> void:
	if has_focus():
		text = _remap.value
	else:
		text = _data.filename(_remap.value)
	_check_remap_ui()

func _input(event) -> void:
	if (event is InputEventMouseButton) and event.pressed:
		if not get_global_rect().has_point(event.position):
			release_focus()

func _on_focus_entered() -> void:
	text = _remap.value

func _on_focus_exited() -> void:
	text = _data.filename(_remap.value)

func _remap_value_changed(remap_value) -> void:
	_data.remapkey_value_change(_remap, remap_value)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				grab_focus()
				var file_dialog = LocalizationRemapDialogFile.instantiate()
				if _resource_exists():
					file_dialog.current_dir = _data.file_path(_remap.value)
					file_dialog.current_file = _data.filename(_remap.value)
				for extension in _data.supported_file_extensions():
					file_dialog.add_filter("*." + extension)
				var root = get_tree().get_root()
				root.add_child(file_dialog)
				file_dialog.connect("file_selected", _remap_value_changed)
				file_dialog.popup_centered()

func _can_drop_data(position, data) -> bool:
	var remap_value = data["files"][0]
	var remap_extension = _data.file_extension(remap_value)
	for extension in _data.supported_file_extensions():
		if remap_extension == extension:
			return true
	return false

func _drop_data(position, data) -> void:
	var remap_value = data["files"][0]
	_remap_value_changed(remap_value)

func _check_remap_ui() -> void:
	if text.length() <= 0:
		set("custom_styles/normal", _remap_ui_style_empty)
		tooltip_text =  "Please set remap resource"
	elif not _resource_exists():
		set("custom_styles/normal", _remap_ui_style_resource)
		tooltip_text =  "Your resource path: \"" + _remap.value + "\" does not exists"
	elif _resource_different_type():
		set("custom_styles/normal", _remap_ui_style_resource_diff)
		tooltip_text =  "Your remaps have different types"
	elif _resource_double():
		set("custom_styles/normal", _remap_ui_style_resource_double)
		tooltip_text =  "Your have double resources in your remaps"
	else:
		set("custom_styles/normal", null)
		tooltip_text =  ""

func _resource_exists() -> bool:
	if _data.remap_type(_remap) == "undefined":
		return false
	return FileAccess.file_exists(_remap.value)

func _resource_different_type() -> bool:
	var type = _data.remap_type(_remap)
	for remap in  _key.remaps:
		if remap.value.length() > 0 and type != _data.remap_type(remap):
			return true
	return false

func _resource_double() -> bool:
	var first
	for remap in  _key.remaps:
		if first == null:
			first = remap
			continue
		if remap.value.length() > 0 and first.value == remap.value:
			return true
	return false
