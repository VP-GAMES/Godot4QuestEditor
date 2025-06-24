# Node sentence for DialogueEditor: MIT License
# @author Vladimir Petrenko
@tool
extends "res://addons/dialogue_editor/scenes/dialogues/nodes_view/nodes/NodeBase.gd"

var _group = ButtonGroup.new()

@onready var _scenes_ui = $PanelScene/HBox/Scene as OptionButton
@onready var _add_ui = $PanelActor/HBox/Add as Button
@onready var _actors_ui = $PanelActor/HBox/Actor as OptionButton
@onready var _view_ui = $PanelTexture/HBoxTexture/View as CheckBox
@onready var _textures_ui = $PanelTexture/HBoxTexture/Texture as OptionButton
@onready var _texture_ui = $Center/Texture as TextureRect

const PanelSentence = preload("res://addons/dialogue_editor/scenes/dialogues/nodes_view/nodes/node_sentence/PanelSentence.tscn")

func set_data(node: DialogueNode, dialogue: DialogueDialogue, data: DialogueData) -> void:
	_node = node
	_dialogue = dialogue
	_data = data
	super._change_name()
	_init_connections()
	_update_view()

func _init_connections() -> void:
	super._init_connections()
	if not _scenes_ui.item_selected.is_connected(_on_item_scene_selected):
		_scenes_ui.item_selected.connect(_on_item_scene_selected)
	if not _node.scene_selection_changed.is_connected(_on_scene_selection_changed):
		_node.scene_selection_changed.connect(_on_scene_selection_changed)
	if not _actors_ui.item_selected.is_connected(_on_item_actor_selected):
		_actors_ui.item_selected.connect(_on_item_actor_selected)
	if not _node.actor_selection_changed.is_connected(_on_actor_selection_changed):
		_node.actor_selection_changed.connect(_on_actor_selection_changed)
	if not _add_ui.pressed.is_connected(_on_add_sentence_pressed):
		_add_ui.pressed.connect(_on_add_sentence_pressed)
	if not _node.sentence_added.is_connected(_on_sentence_added):
		_node.sentence_added.connect(_on_sentence_added)
	if not _node.sentence_removed.is_connected(_on_sentence_removed):
		_node.sentence_removed.connect(_on_sentence_removed)
	if not _textures_ui.item_selected.is_connected(_on_item_textures_selected):
		_textures_ui.item_selected.connect(_on_item_textures_selected)
	if not _node.texture_selection_changed.is_connected(_on_texture_selection_changed):
		_node.texture_selection_changed.connect(_on_texture_selection_changed)
	if not _view_ui.pressed.is_connected(_on_view_pressed):
		_view_ui.pressed.connect(_on_view_pressed)
	if not _node.view_selection_changed.is_connected(_on_view_selection_changed):
		_node.view_selection_changed.connect(_on_view_selection_changed)
	if not _node.sentence_event_visibility_changed.is_connected(_on_sentence_event_visibility_changed):
		_node.sentence_event_visibility_changed.connect(_on_sentence_event_visibility_changed)
	if not _node.sentence_selection_changed.is_connected(_on_sentence_selection_changed):
		_node.sentence_selection_changed.connect(_on_sentence_selection_changed)

func _on_item_scene_selected(index: int) -> void:
	if index > 0:
		_node.change_scene(_data.scenes[index - 1].resource)
	else:
		_node.change_scene()

func _on_scene_selection_changed(scene: String) -> void:
	_dialogue.emit_signal_update_view()

func _on_item_actor_selected(index: int) -> void:
	if index > 0:
		_node.change_actor(_data.actors[index - 1])
	else:
		_node.change_actor()

func _on_actor_selection_changed(actor: DialogueActor) -> void:
	_dialogue.emit_signal_update_view()

func _on_add_sentence_pressed() -> void:
	_node.add_sentence()

func _on_sentence_added(sentence) -> void:
	_dialogue.emit_signal_update_view()

func _on_sentence_removed(sentence) -> void:
	_dialogue.emit_signal_update_view()

func _on_item_textures_selected(index: int) -> void:
	if index > 0:
		_node.change_texture_uuid(_node.actor.resources[index - 1].uuid)
	else:
		_node.change_texture_uuid()

func _on_texture_selection_changed(texture_uuid) -> void:
	_dialogue.emit_signal_update_view()

func _on_view_pressed() -> void:
	_node.change_texture_view(_view_ui.button_pressed)

func _on_view_selection_changed(texture_view) -> void:
	_dialogue.emit_signal_update_view()

func _on_sentence_event_visibility_changed(sentence) -> void:
	_dialogue.emit_signal_update_view()

func _on_sentence_selection_changed(sentence) -> void:
	_dialogue.emit_signal_update_view()

func _update_view() -> void:
	super._update_view()
	_scenes_ui_fill_and_draw()
	_actors_ui_fill_and_draw()
	_textures_ui_fill_and_draw()
	_view_ui_fill_and_draw()
	_texture_ui_fill_and_draw()
	_sentences_draw_view()
	_slots_draw()
	position_offset = _node.position
	size = Vector2.ZERO

func _scenes_ui_fill_and_draw() -> void:
	_scenes_ui.clear()
	_scenes_ui.disabled = true
	var select = -1
	if not _data.scenes.is_empty():
		_scenes_ui.disabled = false
		_scenes_ui.add_item("None", 0)
		_scenes_ui.set_item_metadata(0, "None")
		select = 0
		for index in range(_data.scenes.size()):
			var scene = _data.scenes[index]
			if _node.scene == scene.resource:
				select = index + 1
			_scenes_ui.add_item(_data.filename_only(scene.resource), index + 1)
			_scenes_ui.set_item_metadata(index + 1, scene.resource)
		_scenes_ui.select(select)

func _actors_ui_fill_and_draw() -> void:
	_actors_ui.clear()
	_actors_ui.disabled = true
	var select = -1
	if not _data.actors.is_empty():
		_actors_ui.disabled = false
		_actors_ui.add_item("None", 0)
		select = 0
		for index in range(_data.actors.size()):
			var actor = _data.actors[index]
			if _node.actor == actor:
				select = index + 1
			if not actor.resources.is_empty():
				var image = load(actor.resources[0].path)
				image = _data.resize_texture(image, Vector2(16, 16))
				_actors_ui.add_icon_item(image, actor.name, index)
			else:
				_actors_ui.add_item(actor.name, index + 1)
		_actors_ui.select(select)

func _textures_ui_fill_and_draw() -> void:
	_textures_ui.clear()
	_textures_ui.disabled = true
	var select = -1
	if not _node.is_actor_empty_object():
		if not _node.actor.resources.is_empty():
			_textures_ui.disabled = false
			_textures_ui.add_item("None", 0)
			select = 0
			for index in range(_node.actor.resources.size()):
				var resource = _node.actor.resources[index]
				if _node.texture_uuid == resource.uuid:
					select = index + 1
				_textures_ui.add_item(resource.name, index + 1)
			_textures_ui.select(select)

func _view_ui_fill_and_draw() -> void:
	_view_ui.disabled = _node.texture_uuid.is_empty()
	_view_ui.button_pressed = _node.texture_view

func _texture_ui_fill_and_draw() -> void:
	var texture = null
	if not _node.is_actor_empty_object():
		texture = _node.actor.resource_by_uuid(_node.texture_uuid, false)
	_texture_ui.texture = texture
	_texture_ui.visible = _node.texture_view

func _sentences_draw_view() -> void:
	_sentences_clear()
	_sentences_draw()

func _sentences_clear() -> void:
	for child in get_children():
		if child is DialoguePanelSentence:
			remove_child(child)
			child.queue_free()

func _sentences_draw() -> void:
	for index in range(_node.sentences.size()):
		_sentence_draw(_node.sentences[index])

func _sentence_draw(sentence: Dictionary) -> void:
	var sentence_ui = PanelSentence.instantiate()
	add_child(sentence_ui)
	sentence_ui.set_data(_group, sentence, _node, _dialogue, _data)

func update_slots_draw() -> void:
	_slots_draw()

func _slots_draw() -> void:
	var children = get_children()
	for index in range(children.size()):
		var child = children[index]
		if index == 0:
			set_slot(child.get_index(), true, 0, Color.WHITE, false, 0, Color.WHITE)
		elif child is DialoguePanelSentence:
			set_slot(child.get_index(), false, 0, Color.WHITE, true, 0, Color.WHITE)
		else:
			set_slot(child.get_index(), false, 0, Color.WHITE, false, 0, Color.WHITE)

func slot_index_of_selected_sentence() -> int:
	var sentence = _node.selected_sentence()
	for child in get_children():
		if child is DialoguePanelSentence:
			if sentence == child.sentence():
				return child.get_index()
	return -1
