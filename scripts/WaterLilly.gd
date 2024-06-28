extends Area2D

func _ready():
	pass

func _on_WaterLilly_body_entered(body):
	body.is_tangled = true


func _on_WaterLilly_body_exited(body):
	body.is_tangled = false
