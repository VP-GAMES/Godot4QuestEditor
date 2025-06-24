# DialogueManager used for dialogues in games : MIT License
# @author Vladimir Petrenko
extends Node

signal dialogue_started(dialogue)
signal dialogue_event(event)
signal dialogue_canceled(dialogue)
signal dialogue_ended(dialogue)
signal sentence_changed(_sentence)

var started_from_editor = false

var _data: = DialogueData.new()
var _data_loaded = false
var _layer: CanvasLayer

var _dialogue
var _sentence
var _scene
var _node

func sentence():
	return _sentence

func _reset() -> void:
	_dialogue = null
	_sentence = null
	_scene = null
	_node = null

func _ready() -> void:
	if not _data_loaded:
		load_data()

func load_data() -> DialogueData:
	if not _data_loaded:
		_data = ResourceLoader.load(_data.PATH_TO_SAVE) as DialogueData
	return _data

func actual_dialogue() -> String:
	return _dialogue.name

func actual_dialogue_uuid():
	if _dialogue != null:
		return _dialogue.uuid
	return null

func is_started() -> bool:
	return _dialogue != null

func start_dialogue(dialogue: String, direct: bool = false) -> void:
	if not _data.dialogue_exists(dialogue):
		printerr("Dialogue ", dialogue,  " doesn't exists")
		_reset()
		return
	_dialogue = _data.dialogue(dialogue) as DialogueDialogue
	_node = _dialogue.node_start() as DialogueNode
	if _node != null and started_from_editor or _node != null and direct:
		_next_sentence(0)
	dialogue_started.emit(_dialogue)

func start_dialogue_by_uuid(dialogue_uuid: String, direct: bool = false) -> void:
	if not _data.dialogue_exists_by_uuid(dialogue_uuid):
		printerr("Dialogue ", dialogue_uuid,  " doesn't exists")
		_reset()
		return
	_dialogue = _data.dialogue_by_uuid(dialogue_uuid) as DialogueDialogue
	_node = _dialogue.node_start() as DialogueNode
	if _node != null and started_from_editor or _node != null and direct:
		_next_sentence(0)
	dialogue_started.emit(_dialogue)

func start_dialogue_by_name(dialogue_name: String, direct: bool = false) -> void:
	if not _data.dialogue_exists_by_name(dialogue_name):
		printerr("Dialogue ", dialogue_name,  " doesn't exists")
		_reset()
		return
	_dialogue = _data.dialogue_by_name(dialogue_name) as DialogueDialogue
	_node = _dialogue.node_start() as DialogueNode
	if _node != null and started_from_editor or _node != null and direct:
		_next_sentence(0)
	dialogue_started.emit(_dialogue)

func _input(event: InputEvent):
	if started_from_editor:
		if event.is_action_released("ui_accept"):
			next_sentence()
		if event.is_action_released("ui_cancel"):
			cancel_dialogue()

func next_sentence() -> void:
	if is_started():
		_next_sentence_action()

func cancel_dialogue() -> void:
	if is_started():
		_clear_sentences()
		var old_dialogue = _dialogue
		_reset()
		dialogue_canceled.emit(old_dialogue)

func _next_sentence_action() -> void:
		var index = -1
		if started_from_editor:
			index = _node.selected_sentence_index()
		if _node.sentences.size() == 1:
			index = 0
		if index != -1:
			_next_sentence(index)

func _next_sentence(index) -> void:
	var sentence_node_uuid = _node.sentences[index].node_uuid
	if _node and not sentence_node_uuid.is_empty():
		var sentence_node = _dialogue.node_by_uuid(sentence_node_uuid)
		_sentence = _node_to_dialogue_sentence(sentence_node)
		if _sentence.scene:
			_draw_view()
			_node = sentence_node
			sentence_changed.emit(_sentence)
		else:
			_clear_sentences()
			dialogue_ended.emit(_dialogue)
			_reset()

func _node_to_dialogue_sentence(node: DialogueNode):
	var dialogueSentence = DialogueSentence.new()
	dialogueSentence.scene = node.scene
	dialogueSentence.actor = node.actor
	dialogueSentence.texture_uuid = node.texture_uuid
	dialogueSentence.texte_events = []
	for sentence in node.sentences:
		var text_event = {"text": "", "event": null, "next": null}
		text_event.text = sentence.text
		if not sentence.event.is_empty():
			text_event.event = sentence.event
		if not sentence.node_uuid.is_empty():
			text_event.next = sentence.node_uuid
		dialogueSentence.texte_events.append(text_event)
	return dialogueSentence

func _draw_view() -> void:
	_clear_sentences()
	_draw_sentence()

func _clear_sentences() -> void:
	if _layer and is_instance_valid(_layer):
		get_tree().get_root().call_deferred("remove_child", _layer)
		_layer.queue_free()

func _draw_sentence() -> void:
	if _sentence.scene:
		var scenePath = _sentence.scene
		var SentenceScene = load(scenePath)
		_scene = SentenceScene.instantiate()
		_scene.name = _data.filename_only(scenePath)
		_layer = CanvasLayer.new()
		_layer.add_child(_scene)
		get_tree().get_root().add_child(_layer)
		_connect_gui_input()
		_scene.sentence_set(_sentence)
		if _sentence.texte_events.size() == 1:
			var event_name = _sentence.texte_events[0].event
			if event_name:
				var event_names = event_name.split(",")
				for name in event_names:
					dialogue_event.emit(name)
		elif _sentence.texte_events.size() > 1:
			_connect_buttons()

func _connect_gui_input() -> void:
	if not _scene.is_connected("gui_input", _on_gui_input):
		_scene.connect("gui_input", _on_gui_input)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if started_from_editor:
				_next_sentence_action()

func _connect_buttons() -> void:
	var buttons_array = _scene.buttons()
	for index in range(buttons_array.size() - 1, -1, -1):
		var index_reverse = buttons_array.size() - (index +1)
		var button_ui = buttons_array[index] as Button
		if not button_ui.pressed.is_connected(_on_button_pressed):
			button_ui.pressed.connect(_on_button_pressed.bind(index_reverse))

func _on_button_pressed(button_index: int) -> void:
	var event_name = _sentence.texte_events[button_index].event
	var key_text = _sentence.texte_events[button_index].text
	if event_name:
		var event_names = event_name.split(",")
		for name in event_names:
			dialogue_event.emit(name)
	_next_sentence(button_index)
