extends KinematicBody2D

signal oxygen_change

var velocity = Vector2()
var in_water = false
var gravity_enabled = false
var is_tangled = false
var oxygen : int

const MAX_OXYGEN = 100
const OXYGEN_DECREASE_RATE : float = 1.0
const OXYGEN_INCREASE_RATE : float = 10.0
const GRAVITY : int = 2200
const SWIM_SPEED : int = -600
const MOVE_SPEED : int = 18000
const TANGLED_MOVE_SPEED : int  = 7000
const TANGLED_SPEED : int = -30

func _ready():
	reset_player()
	
func _physics_process(delta):
	process_movement(delta)
	process_gravity(delta)
	if oxygen == 0:
		get_parent().game_over()

func process_movement(delta):
	velocity.x = 0

	if is_tangled:
		$AnimatedSprite.play("tangled")
		if Input.is_action_pressed("ui_right"):
			velocity.x += TANGLED_MOVE_SPEED * delta
		if Input.is_action_pressed("ui_left"):
			velocity.x -= TANGLED_MOVE_SPEED * delta
		velocity.y = 0  
	else:
		if Input.is_action_pressed("ui_right"):
			velocity.x += MOVE_SPEED * delta
		if Input.is_action_pressed("ui_left"):
			velocity.x -= MOVE_SPEED * delta
		if in_water:
			if Input.is_action_just_pressed("ui_accept"):
				velocity.y = SWIM_SPEED
				$AnimatedSprite.play("swim")
				$SwimSound.play()  
			elif velocity.y > 0:
				$AnimatedSprite.play("idle")

	velocity = move_and_slide(velocity, Vector2.UP)

func process_gravity(delta):
	if gravity_enabled:
		if in_water:
			if $O2.is_playing():
				$O2.stop()
			if not is_tangled:
				if $Tangled.is_playing():
					$Tangled.stop()
				velocity.y += GRAVITY * delta * 0.5
			change_oxygen(-OXYGEN_DECREASE_RATE * delta)
			if is_tangled:
				change_oxygen(-OXYGEN_DECREASE_RATE * (delta + 1))
				if not $Tangled.is_playing():
					$Tangled.play()
		else:
			velocity.y += GRAVITY * delta
			change_oxygen(OXYGEN_INCREASE_RATE * delta)
			if not $O2.is_playing():
				$O2.play()

func set_gravity_enabled(enabled: bool):
	gravity_enabled = enabled

func change_oxygen(amount: int):
	oxygen += amount
	if oxygen > MAX_OXYGEN:
		oxygen = MAX_OXYGEN
	elif oxygen < 0:
		oxygen = 0
	emit_signal("oxygen_change", oxygen)
	
func reset_player():
	in_water = true
	oxygen = MAX_OXYGEN
	is_tangled = false  
	$AnimatedSprite.play("idle")
