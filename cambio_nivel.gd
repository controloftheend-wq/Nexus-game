extends Area2D

func _ready():
	$AnimatedSprite2D.play("default")

func _on_body_entered(body):
	if body.is_in_group("player"):
		get_tree().change_scene_to_file("res://escenas/Level2.tscn")
