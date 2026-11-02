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





# Carga de recursos
var textura_botas = preload("res://sprites/Nexus idle-2.png(1).png")
# 1. Carga la imagen de tu cuadro vacío (arrástrala desde el Sistema de Archivos a las comillas)
var textura_vacia = preload("res://sprites/Nexus idle-2.png.png")
@onready var grid = $PanelContainer2/GridContainer
@onready var texto_nombre = $PanelContainer3/VBoxContainer/Label2
@onready var texto_descripcion = $PanelContainer3/VBoxContainer/Label
@onready var boton_elegir = $PanelContainer4/VBoxContainer/Button

# Almacena el índice del slot seleccionado actualmente (0 a 7, o -1 si no hay selección)
var slot_seleccionado: int = 0

func _ready():
	visibility_changed.connect(_on_visibility_changed)
	conectar_slots()
	actualizar_menu()

func _on_visibility_changed():
	if visible:
		actualizar_menu()

# Conecta la señal 'pressed' de todos los botones dentro del GridContainer
func conectar_slots():
	var slots = grid.get_children()
	for i in range(slots.size()):
		var slot = slots[i]
		if slot is Button or slot is TextureButton:
			# Conecta el clic de cada botón pasándole su número de índice (0 a 7)
			slot.pressed.connect(_on_slot_pressed.bind(i))

# Se ejecuta al hacer clic en CUALQUIERA de los 8 cuadros
func _on_slot_pressed(index: int):
	slot_seleccionado = index
	resaltar_slot_seleccionado(index)

	# Lógica según el slot presionado (Slot 0 es el de las Botas)
	match index:
		0: # Slot 0: Botas de Impulso
			if Global.has_dash_boots:
				texto_nombre.text = "Nombre: Botas de Impulso"
				texto_descripcion.text = "Descripción: Pulsa la tecla de Dash para impulsarte rápidamente en el aire o suelo."
			else:
				texto_nombre.text = "Nombre: Slot Vacío"
				texto_descripcion.text = "Descripción: No has descubierto esta habilidad."
		_: # Slots 1 al 7
			texto_nombre.text = "Nombre: Slot Vacío"
			texto_descripcion.text = "Descripción: Sin objeto asignado."

# Pinta de color el botón seleccionado para darle feedback al jugador
func resaltar_slot_seleccionado(index_activo: int):
	var slots = grid.get_children()
	for i in range(slots.size()):
		if i == index_activo:
			slots[i].modulate = Color(0.573, 0.573, 0.573, 1.0) # Verde destacante
		else:
			slots[i].modulate = Color(1.0, 1.0, 1.0) # Color normal

# Actualiza los iconos de la cuadrícula según lo que el jugador ha desbloqueado
func actualizar_menu():
	var slots = grid.get_children()
	
	# Le pone la textura vacía a los 8 cuadros
	for slot in slots:
		if slot is Button or slot is TextureButton:
			slot.icon = textura_vacia

	# Si tienes las botas, reemplaza el icono del Slot 0
	if Global.has_dash_boots and slots.size() > 0:
		slots[0].icon = textura_botas

# --- ACCIONES DE LOS BOTONES DE CONFIRMACIÓN ---

# Conecta la señal pressed() de tu botón "Elegir Objeto"



func _on_button_pressed():
	match slot_seleccionado:
		0:
			if Global.has_dash_boots:
				Global.habilidad_equipada = Global.Habilidades.BOTAS
				print("¡Equipaste las Botas de Impulso!")
			else:
				print("No tienes esta habilidad desbloqueada.")
		_:
			print("Este slot está vacío.")


func _on_button_2_pressed() -> void:
	Global.habilidad_equipada = Global.Habilidades.NINGUNA
	slot_seleccionado = -1
	resaltar_slot_seleccionado(-1)
	texto_nombre.text = "Nombre:"
	texto_descripcion.text = "Descripción:"
	print("Habilidad desequipada.")
