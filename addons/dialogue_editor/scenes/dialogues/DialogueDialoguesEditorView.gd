# Dialogues dialogs view for DialogueEditor : MIT License
# @author Vladimir Petrenko
@tool
extends HBoxContainer

var _data: DialogueData
var _split_viewport_size = 0

@onready var _split_ui = $Split as SplitContainer
@onready var _dialogs_ui = $Split/Dialogs as Panel
@onready var _editors_ui = $Split/Editors as MarginContainer

func set_data(data: DialogueData) -> void:
	_data = data
	_dialogs_ui.set_data(data)
	_editors_ui.set_data(data)

func _ready() -> void:
	_init_connections()

func _init_connections() -> void:
	if not _split_ui.dragged.is_connected(_on_split_dragged):
		_split_ui.dragged.connect(_on_split_dragged)

func _process(delta):
	if _split_viewport_size != size.x:
		_split_viewport_size = size.x
		_init_split_offset()

func _init_split_offset() -> void:
	var offset = DialogueData.SETTINGS_DIALOGUES_SPLIT_OFFSET_DEFAULT
	if _data:
		offset = _data.setting_dialogues_split_offset()
	_split_ui.set_split_offset(-size.x / 2 + offset)

func _on_split_dragged(offset: int) -> void:
	if _data != null:
		var value = -(-size.x / 2 - offset)
		_data.setting_dialogues_split_offset_put(value)
