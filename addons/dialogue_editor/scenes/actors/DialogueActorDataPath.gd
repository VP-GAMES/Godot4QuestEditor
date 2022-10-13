# Path UI LineEdit for DialogueEditor : MIT License
# @author Vladimir Petrenko
# Drag and drop not work just now, see Workaround -> DialogueActorDataPut
# https://github.com/godotengine/godot/issues/30480
@tool
extends LineEdit

var _resource: Dictionary
var _actor: DialogueActor
var _data: DialogueData

var _path_ui_style_resource: StyleBoxFlat

const DialogueActorDataResourceDialogFile = preload("res://addons/dialogue_editor/scenes/actors/DialogueActorDataResourceDialogFile.tscn")

func set_data(resource: Dictionary, actor: DialogueActor, data: DialogueData) -> void:
	_resource = resource
	_actor = actor
	_data = data
	_init_styles()
	_init_connections()
	_draw_view()

func _init_styles() -> void:
	_path_ui_style_resource = StyleBoxFlat.new()
	_path_ui_style_resource.set_bg_color(Color("#192e59"))

func _init_connections() -> void:
	if not _actor.resource_path_changed.is_connected(_on_resource_path_changed):
		assert(_actor.resource_path_changed.connect(_on_resource_path_changed) == OK)
	if not focus_entered.is_connected(_on_focus_entered):
		assert(focus_entered.connect(_on_focus_entered) == OK)
	if not focus_exited.is_connected(_on_focus_exited):
		assert(focus_exited.connect(_on_focus_exited) == OK)
	if not text_changed.is_connected(_path_value_changed):
		assert(text_changed.connect(_path_value_changed) == OK)
	if not gui_input.is_connected(_on_gui_input):
		assert(gui_input.connect(_on_gui_input) == OK)

func _on_resource_path_changed(resource) -> void:
	if _resource == resource:
		_draw_view()

func _draw_view() -> void:
	if has_focus():
		text = _resource.path
	else:
		text = _data.filename(_resource.path)
	_check_path_ui()

func _input(event) -> void:
	if (event is InputEventMouseButton) and event.pressed:
		if not get_global_rect().has_point(event.position):
			release_focus()

func _on_focus_entered() -> void:
	text = _resource.path
	_actor.select_resource(_resource)

func _on_focus_exited() -> void:
	text = _data.filename(_resource.path)

func _path_value_changed(path_value) -> void:
	_actor.change_resource_path(_resource, path_value)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_MIDDLE:
				grab_focus()
				var file_dialog: FileDialog = DialogueActorDataResourceDialogFile.instantiate()
				if _data.resource_exists(_resource):
					file_dialog.current_dir = _data.file_path(_resource.path)
					file_dialog.current_file = _data.filename(_resource.path)
				for extension in _data.SUPPORTED_ACTOR_RESOURCES:
					file_dialog.add_filter("*." + extension)
				var root = get_tree().get_root()
				root.add_child(file_dialog)
				assert(file_dialog.file_selected.connect(_path_value_changed) == OK)
				assert(file_dialog.get_cancel_button().pressed.connect(_on_popup_hide.bind(root, file_dialog)) == OK)
				file_dialog.popup_centered()

func _on_popup_hide(root, dialog) -> void:
	root.remove_child(dialog)
	dialog.queue_free()

func _can_drop_data(position, data) -> bool:
	var path_value = data["files"][0]
	var path_extension = _data.file_extension(path_value)
	for extension in _data.SUPPORTED_ACTOR_RESOURCES:
		if path_extension == extension:
			return true
	return false

func _drop_data(position, data) -> void:
	var path_value = data["files"][0]
	_path_value_changed(path_value)

func _check_path_ui() -> void:
	if not _data.resource_exists(_resource):
		set("custom_styles/normal", _path_ui_style_resource)
		tooltip_text =  "Your resource path: \"" + _resource.path + "\" does not exists"
	else:
		set("custom_styles/normal", null)
		tooltip_text =  ""
