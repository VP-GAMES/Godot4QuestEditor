# 3D Level player to demonstrate functionality of QuestEditor : MIT License
# @author Vladimir Petrenko
extends QuestPlayer3D

export var speed : float = 30
export var speed_rotation : float = 65
export var acceleration : float = 15
export var gravity : float = 0.98

var velocity : Vector3
export(String) var attack = "attack"

onready var _animationPlayer = $AnimationPlayer as AnimationPlayer

func _physics_process(delta):
	handle_movement(delta)

func handle_movement(delta):
	var direction = Vector3()
	if Input.is_action_pressed("move_up"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_bottom"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_left"):
		rotation_degrees.y += speed_rotation * delta
	if Input.is_action_pressed("move_right"):
		rotation_degrees.y -= speed_rotation * delta
	direction = direction.normalized()
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	velocity = move_and_slide(velocity, Vector3.UP)

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
