# Quests view for QuestEditor : MIT License
# @author Vladimir Petrenko
@tool
extends VBoxContainer

var _data: QuestData
var _split_viewport_size = 0

@onready var _split_ui = $Split as SplitContainer
@onready var _quests_ui = $Split/Quests as Control
@onready var _quest_data_ui = $Split/QuestData as VBoxContainer

func set_data(data: QuestData) -> void:
	_data = data
	_quests_ui.set_data(_data)
	_quest_data_ui.set_data(_data)
	_init_connections()

func _init_connections() -> void:
	if not _split_ui.dragged.is_connected(_on_split_dragged):
		assert(_split_ui.dragged.connect(_on_split_dragged) == OK)

func _process(delta):
	if _split_viewport_size != rect_size.x:
		_split_viewport_size = rect_size.x
		_init_split_offset()

func _init_split_offset() -> void:
	var offset = QuestData.SETTINGS_QUESTS_SPLIT_OFFSET_DEFAULT
	if _data:
		offset = _data.setting_quests_split_offset()
	_split_ui.set_split_offset(-rect_size.x / 2 + offset)

func _on_split_dragged(offset: int) -> void:
	if _data != null:
		var value = -(-rect_size.x / 2 - offset)
		_data.setting_quests_split_offset_put(value)
