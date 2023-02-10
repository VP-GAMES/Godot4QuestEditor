# EditorProperty as QuestNpc for QuestEditor : MIT License
# @author Vladimir Petrenko
@tool
extends EditorProperty
class_name QuestInspectorPluginNpc

const Dropdown = preload("res://addons/ui_extensions/dropdown/Dropdown.tscn")

var updating = false
var dropdown = Dropdown.instantiate()
var _main_screen: VBoxContainer
var _dialogue_editor
var _data: DialogueData

func set_data(main_screen: VBoxContainer) -> void:
	_main_screen = main_screen
	if main_screen.has_node("DialogueEditor") and _dialogue_editor == null:
		_dialogue_editor = main_screen.get_node("DialogueEditor")
		_data = _dialogue_editor.get_data()
		_update_dropdown()

func _init():
	add_child(dropdown)
	add_focusable(dropdown)
	_update_dropdown()
	dropdown.selection_changed.connect(_on_selection_changed)

func _update_dropdown() -> void:
	dropdown.clear()
	if _data != null:
		for dialogue in _data.dialogues:
			var item_d = DropdownItem.new(dialogue.uuid, dialogue.name)
			dropdown.add_item(item_d)

func _on_selection_changed(item: DropdownItem):
	if (updating):
		return
	emit_changed(get_edited_property(), item.value)

func _update_property():
	var new_value = get_edited_object()[get_edited_property()]
	updating = true
	dropdown.set_selected_by_value(new_value)
	updating = false
