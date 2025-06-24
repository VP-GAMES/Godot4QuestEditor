# Path UI LineEdit for QuestEditor : MIT License
# @author Vladimir Petrenko
# Drag and drop not work just now, see Workaround -> QuestTriggerPathPut
# https://github.com/godotengine/godot/issues/30480
@tool
extends LineEdit

var _trigger: QuestTrigger
var _data: QuestData

var _path_ui_style_resource: StyleBoxFlat

func set_data(trigger: QuestTrigger, data: QuestData) -> void:
	_data = data
	_trigger = trigger
	_init_styles()
	_init_connections()
	_draw_view()

func _init_styles() -> void:
	_path_ui_style_resource = StyleBoxFlat.new()
	_path_ui_style_resource.set_bg_color(Color("#192e59"))

func _init_connections() -> void:
	if not _trigger.scene_changed.is_connected(on_scene_changed):
		_trigger.scene_changed.connect(on_scene_changed)
	if not focus_entered.is_connected(_on_focus_entered):
		focus_entered.connect(_on_focus_entered)
	if not focus_exited.is_connected(_on_focus_exited):
		focus_exited.connect(_on_focus_exited)
	if not text_changed.is_connected(_path_value_changed):
		text_changed.connect(_path_value_changed)

func on_scene_changed() -> void:
	_draw_view()

func _draw_view() -> void:
	text = ""
	if _trigger.scene:
		if has_focus():
			text = _trigger.scene
		else:
			text = _data.filename(_trigger.scene)
		_check_path_ui()

func _input(event) -> void:
	if (event is InputEventMouseButton) and event.pressed:
		if not get_global_rect().has_point(event.position):
			release_focus()

func _on_focus_entered() -> void:
	text = _trigger.scene

func _on_focus_exited() -> void:
	text = _data.filename(_trigger.scene)

func _path_value_changed(path_value) -> void:
	_trigger.change_scene(path_value)

func _can_drop_data(position, data) -> bool:
	var path_value = data["files"][0]
	var resource_extension = _data.file_extension(path_value)
	if resource_extension == "tscn":
		return true
	return false

func _drop_data(position, data) -> void:
	var path_value = data["files"][0]
	_path_value_changed(path_value)

func _check_path_ui() -> void:
	if _trigger.scene != null and not _data.resource_exists(_trigger.scene):
		add_theme_stylebox_override("normal", _path_ui_style_resource)
		tooltip_text =  "Your resource path: \"" + _trigger.scene + "\" does not exists"
	else:
		remove_theme_stylebox_override("normal")
		tooltip_text =  ""
