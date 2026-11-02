extends Area2D

func _on_body_entered(body):
	# Verifica si lo que tocó las botas fue el jugador
	if body.is_in_group("player"): # Cambia "Player" por el nombre exacto del nodo de tu jugador
		Global.has_dash_boots = true # ¡Le da la habilidad!
		queue_free() # Destruye el objeto de las botas del mapa
func _ready():
	$AnimatedSprite2D.play("default")
