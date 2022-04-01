# EditorProperty for Dialogue2D and Dialogue3D in DialogueEditor : MIT License
# @author Vladimir Petrenko
@tool
extends EditorProperty
class_name DialogueDialogueInspectorEditor

const Dropdown = preload("res://addons/dialogue_editor/ui_extensions/dropdown/Dropdown.tscn")

var updating = false
var dropdown = Dropdown.instantiate()
var _data: DialogueData

func set_data(data: DialogueData) -> void:
	_data = data
	_data.dialogue_changed.connect(_update_dropdown)
	_update_dropdown()

func _init():
	add_child(dropdown)
	add_focusable(dropdown)
	dropdown.selection_changed.connect(_on_selection_changed)

func _update_dropdown() -> void:
	dropdown.clear()
	for dialogue in _data.dialogues:
		var item_d = DropdownItem.new(dialogue.name, dialogue.uuid)
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
