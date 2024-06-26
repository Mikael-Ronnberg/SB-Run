extends KinematicBody2D

signal oxygen_change

var velocity = Vector2()
var in_water = false
var gravity_enabled = false

var MAX_OXYGEN = 100
var oxygen = MAX_OXYGEN
const OXYGEN_DECREASE_RATE : float = 1.0
const OXYGEN_INCREASE_RATE : float = 10.0

const GRAVITY : int = 2200
const SWIM_SPEED : int = -600
const MOVE_SPEED : int = 18000

func _ready():
	in_water = true
	
func _physics_process(delta):
	process_movement(delta)
	process_gravity(delta)

func process_movement(delta):
	velocity.x = 0
	if Input.is_action_pressed("ui_right"):
		velocity.x += MOVE_SPEED * delta
	if Input.is_action_pressed("ui_left"):
		velocity.x -= MOVE_SPEED * delta
	velocity = move_and_slide(velocity, Vector2.UP)

	if in_water:
		if Input.is_action_pressed("ui_accept"):
			velocity.y = SWIM_SPEED
			$AnimatedSprite.play("swim")
		elif velocity.y > 0:
			$AnimatedSprite.play("idle")

func process_gravity(delta):
	if gravity_enabled:
		if in_water:
			velocity.y += GRAVITY * delta * 0.5
			change_oxygen(-OXYGEN_DECREASE_RATE * delta)
		else:
			velocity.y += GRAVITY * delta
			change_oxygen(OXYGEN_INCREASE_RATE * delta)

func set_gravity_enabled(enabled: bool):
	gravity_enabled = enabled

func change_oxygen(amount: int):
	oxygen += amount
	if oxygen > MAX_OXYGEN:
		oxygen = MAX_OXYGEN
	elif oxygen < 0:
		oxygen = 0
	emit_signal("oxygen_change", oxygen)
