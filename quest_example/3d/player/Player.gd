# 3D Level player to demonstrate functionality of QuestEditor : MIT License
# @author Vladimir Petrenko
extends QuestPlayer3D

@export var speed : float = 30
@export var speed_rotation : float = 3
@export var gravity : float = 0.98

@export var attack: String = "attack"

@onready var _animationPlayer: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	super._ready()

func _physics_process(delta):
	handle_movement(delta)

func handle_movement(delta):
	var direction = Vector3()
	if Input.is_action_pressed("move_up"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_bottom"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_left"):
		rotation.y += speed_rotation * delta
	if Input.is_action_pressed("move_right"):
		rotation.y -= speed_rotation * delta
	direction = direction.normalized()
	direction = direction * speed
	velocity = Vector3(direction.x, 0, direction.z)
	move_and_slide()

func _input(event: InputEvent):
	if event.is_action_released(attack):
		_animationPlayer.play("attack")

# Methods for requerements
func is_valid_player() -> bool:
	return true

func player_lvl() -> int:
	return 5 

func player_class() -> String:
	return "PALADIN" 

func reward() -> void:
	_inventoryManager.add_item(InventoryManagerInventory.INVENTORY, InventoryManagerItem.HEALTHBIG_3D, 1)
