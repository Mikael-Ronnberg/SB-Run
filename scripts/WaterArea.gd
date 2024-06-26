extends Area2D

signal fully_exited_top(body)
signal partially_exited_top(body)
signal exited_left_or_bottom(body)

var stream_effect = preload("res://scenes/effects/Stream.tscn")
var splash_instance = null
var swimmer_pos = null

onready var collision_shape = $CollisionShape2D.shape 
onready var screen_size = get_viewport().size

func _ready():
	swimmer_pos = get_node("../Swimmer")
	if swimmer_pos == null:
		print("Swimmer node not found!")
	else:
		print("Swimmer node found:", swimmer_pos)


func display_splash_effect(body, type):
	if splash_instance == null:
		if type == "stream":
			splash_instance = stream_effect.instance()
			get_parent().add_child(splash_instance)
			splash_instance.position.x = swimmer_pos.position.x
			splash_instance.position.y = 40  # Adjust as needed
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
		emit_signal("fully_exited_top", body)
		body.in_water = false
		remove_splash_effect()
	elif swimmer_pos.y >= water_top and swimmer_pos.y <= water_top + body_shape.extents.y:
		emit_signal("partially_exited_top", body)
		body.in_water = false
		display_splash_effect(body, "stream")
	else:
		body.in_water = true
		remove_splash_effect()
		splash_instance = null
		

func _process(delta):
		if splash_instance:
			splash_instance.position.x = swimmer_pos.position.x + 5
			splash_instance.position.y = 54 
#			if splash_instance.position.x < -screen_size.x or splash_instance.position.x > screen_size.x:
#				splash_instance.queue_free()
#				splash_instance = null
