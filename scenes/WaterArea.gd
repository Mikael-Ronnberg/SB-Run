extends Area2D

signal fully_exited_top(body)
signal partially_exited_top(body)
signal exited_left_or_bottom(body)

var stream_effect = preload("res://scenes/effects/Stream.tscn")
var splash_instance = null

func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")

func _on_body_entered(body):
	if body.is_in_group("characters"):
		body.in_water = true

func _on_body_exited(body):
	if body.is_in_group("characters"):
		body.in_water = false

func check_exit_conditions(body):
	var screen_size = get_viewport().size
	var swimmer_pos = body.position
	
	if swimmer_pos.x < 0 or swimmer_pos.y > screen_size.y:
		print("now leaving left or bottom")
		emit_signal("exited_left_or_bottom", body)
	elif swimmer_pos.y < 0:
		# Determine if the player is fully or partially out of the water
		var collision_shape = $CollisionShape2D.shape 
		var water_top = self.position.y + 120
		
		if swimmer_pos.y < water_top:  # Adjust the threshold as needed
			emit_signal("fully_exited_top", body)
			if not splash_instance:
				create_splash_effect(body, body.position.x, water_top)
		elif swimmer_pos.y == water_top:
			emit_signal("partially_exited_top", body)
			create_splash_effect(body, body.position.x, water_top)
		else: 
			splash_instance = null

func create_splash_effect(body, x, y):
	splash_instance = stream_effect.instance()
	splash_instance.position = Vector2(x, y)
	get_parent().add_child(splash_instance)
	splash_instance.play("default")
	# Make the splash effect follow the body
	splash_instance.set("target", body)

func _process(delta):
	if splash_instance:
		var target = splash_instance.get("target")
		if target:
			splash_instance.position.x += target.position.x
			splash_instance.position.y = self.position.y + 120
