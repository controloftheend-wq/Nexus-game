extends Control

func paused():
	get_tree().paused=!get_tree().paused
	visible=get_tree().paused
func _input(event):
	if event.is_action_pressed("Pause"):
		paused()

func _on_continuar_pressed() :
	paused()


func _on_ajustes_pressed() :
	pass # Replace with function body.


func _on_menu_principal_pressed():
	pass # Replace with function body.


func _on_salir_pressed():
	get_tree().quit()
