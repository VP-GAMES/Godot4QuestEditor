extends Control

const DialogueManager = preload("res://addons/dialogue_editor/DialogueManager.gd")
const DialogueManagerName = "DialogueManager"
var dialogueManagerAdded  = false
var dialogueManager

@onready var _timer_ui = $Timer as Timer
@onready var _event_ui = $Event as Label

func _ready():
	if not get_tree().get_root().has_node(DialogueManagerName):
		dialogueManager = DialogueManager.new()
		_init_dialogue_manager()
		get_tree().get_root().call_deferred("add_child", dialogueManager)
	else:
		dialogueManager = get_tree().get_root().get_node(DialogueManagerName)
		_init_dialogue_manager()
	var locale = _setting_dialogue_editor_locale()
	if locale:
		TranslationServer.set_locale(locale)

func _init_dialogue_manager() -> void:
	dialogueManager.started_from_editor = true
	dialogueManager.load_data()
	dialogueManager.name = DialogueManagerName

func _setting_dialogue_editor_locale():
	if ProjectSettings.has_setting("dialogue_editor/dialogues_editor_locale"):
		return ProjectSettings.get_setting("dialogue_editor/dialogues_editor_locale")
	return null

func _process(delta):
	if not dialogueManagerAdded and ProjectSettings.has_setting(DialogueData.SETTINGS_DIALOGUES_SELECTED_DIALOGUE):
		if get_tree().get_root().has_node(DialogueManagerName):
			dialogueManagerAdded = true
			var dialogue_name = ProjectSettings.get_setting(DialogueData.SETTINGS_DIALOGUES_SELECTED_DIALOGUE)
			if not dialogueManager.dialogue_ended.is_connected(_on_dialogue_ended_canceled):
				dialogueManager.dialogue_ended.connect(_on_dialogue_ended_canceled)
			if not dialogueManager.dialogue_canceled.is_connected(_on_dialogue_ended_canceled):
				dialogueManager.dialogue_canceled.connect(_on_dialogue_ended_canceled)
			if not dialogueManager.dialogue_event.is_connected(_on_dialogue_event):
				dialogueManager.dialogue_event.connect(_on_dialogue_event)
			dialogueManager.start_dialogue(dialogue_name)

func _on_dialogue_ended_canceled(dialogue) -> void:
	get_tree().quit()

func _on_dialogue_event(event: String) -> void:
	_event_ui.text = "EVENT: -> " +  event
	_event_ui.visible = true
	_timer_ui.start()
	if not _timer_ui.timeout.is_connected(_on_timeout):
		_timer_ui.timeout.connect(_on_timeout)

func _on_timeout() -> void:
	_event_ui.visible = false
