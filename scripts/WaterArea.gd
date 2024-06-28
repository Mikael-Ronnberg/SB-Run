extends Area2D

signal exited_left_or_bottom(body)

var stream_effect = preload("res://scenes/effects/Stream.tscn")
var splash_instance = null
var swimmer_node = null

onready var collision_shape = $CollisionShape2D.shape 
onready var screen_size = get_viewport().size

func _ready():
	swimmer_node = get_node("../Swimmer")
	if swimmer_node == null:
		print("Swimmer node not found!")
	else:
		print("Swimmer node found:", swimmer_node)


func display_splash_effect(type):
	if splash_instance == null:
		if type == "stream":
			splash_instance = stream_effect.instance()
			get_parent().add_child(splash_instance)
			splash_instance.position.x = swimmer_node.position.x
			splash_instance.position.y = 40 
			splash_instance.play("default")
		else: 
			pass
			

func remove_splash_effect():
	if splash_instance:
		splash_instance.queue_free()
		splash_instance = null

func check_water_conditions(body):
	var swimmer_pos = body.position
	var water_top = 40
	var body_shape = body.get_node("CollisionShape2D").shape
	
	if swimmer_pos.x < 0 or swimmer_pos.y > 590:
		emit_signal("exited_left_or_bottom", body)
	elif swimmer_pos.y < water_top:
		body.in_water = false
		remove_splash_effect()
	elif swimmer_pos.y >= water_top and swimmer_pos.y <= water_top + body_shape.extents.y:
		body.in_water = false
		display_splash_effect("stream")
	else:
		body.in_water = true
		remove_splash_effect()
		splash_instance = null
		

func _process(_delta):
		if splash_instance:
			splash_instance.position.x = swimmer_node.position.x + 5
			splash_instance.position.y = 54 
