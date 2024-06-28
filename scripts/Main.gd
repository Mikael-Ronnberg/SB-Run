extends Node


var stag_bottom_scene = preload("res://scenes/Stag1.tscn")
var waterplant_scene = preload("res://scenes/WaterLilly.tscn")
var crab_scene = preload("res://scenes/Crab.tscn")

var bottle_scene = preload("res://scenes/bottle.tscn")
var can_scene = preload("res://scenes/Can.tscn")

var obstacles_types := [stag_bottom_scene, waterplant_scene ]
var litter_types :=[bottle_scene, can_scene]
var obstacles : Array = []
var litter : Array = []
var last_litter = null
var last_obs = null
var distance : int
var speed : int 
var screen_size : Vector2
var game_running : bool
var score : int

const SWIMMER_START_POS = Vector2(176, 380)
const CAM_START_POS = Vector2(516, 300)
const SLOWED_DOWN : int = 1
const START_SPEED : int = 5
const DISTANCE_MODIFIER: int = 10

onready var player_instance = $Swimmer
onready var oxygen_bar = $Hud/OxygenBar
onready var oxygen_timer = $OxygenTimer
onready var score_label = $Hud/Score
onready var water_area = $WaterArea

func _ready():
	water_area.connect("exited_left_or_bottom", self, "_on_exited_left_or_bottom")
	screen_size = get_viewport().size
	$GameOver/Button.connect("pressed", self, "new_game")
	new_game()
	oxygen_bar.set_player(player_instance) 
	oxygen_timer.connect("timeout", self, "_on_OxygenTimer_timeout")
	oxygen_timer.wait_time = 0.1 
	oxygen_timer.start()  
	
func new_game():
	# Reset variables
	game_running = false
	player_instance.set_gravity_enabled(false)
	get_tree().paused = false
	distance = 0
	score = 0
	last_litter = null
	last_obs = null
	show_distance()
	
# Clear obstacles
	for obs in obstacles:
		obs.queue_free()
	obstacles = []

	# Clear litter
	for litt in litter:
		litt.queue_free()
	litter  = []
	
	#Reset player
	player_instance.oxygen = player_instance.MAX_OXYGEN
	player_instance.change_oxygen(0) 
	
	#Reset nodes
	$Swimmer.position = SWIMMER_START_POS
	$Swimmer.velocity = Vector2(0, 0)
	$Camera2D.position = CAM_START_POS
	$Camera2D.current = true
	$Water.position = Vector2(0, 0)
	$WaterArea.position = Vector2(0, -40)
	
	$Hud.get_node("Press").show()
	$GameOver.hide()


func _process(_delta):
	if game_running:
		speed = START_SPEED
		water_area.check_water_conditions($Swimmer)
		generate_obs()
		generate_litter()
		show_distance()
		
		$Swimmer.position.x += speed
		$Camera2D.position.x += speed
		$WaterArea.position.x += speed
		
		#Update distance
		distance += speed
		
		if $Camera2D.position.x - $Water.position.x > screen_size.x * 1.5:
			$Water.position.x += screen_size.x 
			
	#Clean up objects
		for obs in obstacles: 
			if obs.position.x < distance - 280:
				remove_obj(obs, obstacles)
		for litt in litter: 
			if litt.position.x < distance - 280:
				remove_obj(litt, litter)
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$Hud.get_node("Press").hide()
			$GameOver.hide()
			player_instance.set_gravity_enabled(true)
			
			

func generate_obs():
	if obstacles.empty() or last_obs.position.x < distance - rand_range(300, 500):
		var obs_type = obstacles_types[randi() % obstacles_types.size()]
		var obs 
		var max_obs = 3
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instance()
			var obs_x : float = screen_size.x + distance + 100 + (i )
			var obs_y : float = 490
			if obs_type == waterplant_scene:
				obs.get_node("AnimatedSprite").play("default")
				obs_y = 510
			add_obs(obs, obs_x, obs_y)
			last_obs = obs
		if (randi() % 2) == 0:
			obs = crab_scene.instance()
			obs.get_node("AnimatedSprite").play("default")
			var obs_x : float = screen_size.x + distance + 100
			var obs_y : float = 150
			add_obs(obs, obs_x, obs_y)
			

func generate_litter():
	if litter.empty() or last_litter.position.x < distance - rand_range(300, 500):
		var litter_type = litter_types[randi() % litter_types.size()]
		var litt = litter_type.instance() 
		var litt_x : float = screen_size.x + distance + 10
		var litt_y : float = rand_range(80, 450)
		add_litter(litt, litt_x, litt_y)
		last_litter = litt

func add_obs(obs, x, y):
	obs.position = Vector2(x, y)
	if obs.name != "WaterLilly":
		obs.connect("body_entered", self, "hit_obs")
	add_child(obs)
	obstacles.append(obs)
	
func add_litter(litt, x, y):
	litt.position = Vector2(x, y)
	add_child(litt)
	litter.append(litt)
	litt.connect("body_entered", self, "_on_litter_body_entered", [litt])

func _on_litter_body_entered(body, litter_instance):
	if body.name == "Swimmer":
		pick_litter(litter_instance)

func pick_litter(litt):
		score += 1
		score_label.text = "SCORE: " + str(score)
		remove_obj(litt, litter)
	
func remove_obj(obj, arr):
	obj.queue_free()
	arr.erase(obj)

func hit_obs(body):
	if body.name == "Swimmer":
		game_over()


func show_distance():
	score_label.text = "SCORE: " + str(score)

func _on_OxygenTimer_timeout():
	if game_running:
		if player_instance.in_water:
			player_instance.change_oxygen(-player_instance.OXYGEN_DECREASE_RATE)
		else:
			player_instance.change_oxygen(player_instance.OXYGEN_INCREASE_RATE)

func _on_exited_left_or_bottom(body):
	if body.name == "Swimmer":
		game_over()

func game_over():
	get_tree().paused = true
	game_running = false
	$GameOver.show()
