extends CharacterBody2D

enum State { IDLE, WALK, JUMP, DEATH, DASH } # 1. Agregamos el estado DASH
var state: State = State.IDLE

const SPEED := 300.0
const JUMP_VELOCITY := -630.0
const DASH_SPEED := 800.0 # Velocidad del dash
const DASH_DURATION := 0.2 # Cuánto dura el dash en segundos

var dash_timer := 0.0
var has_dash_boots := false # 2. Variable para saber si recogió las botas

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	sprite.animation_finished.connect(_on_animation_finished)
	change_state(State.IDLE)

func _physics_process(delta):
	# El dash no se ve afectado por la gravedad normal
	if state != State.DASH:
		apply_gravity(delta)

	match state:
		State.IDLE:
			state_idle()
		State.WALK:
			state_walk()
		State.JUMP:
			state_jump()
		State.DEATH:
			state_death()
		State.DASH:
			state_dash(delta) 

	move_and_slide()

func change_state(new_state: State):
	state = new_state
	

	var anim_suffix = ""
	if Global.habilidad_equipada == Global.Habilidades.BOTAS:
		anim_suffix = "_boots"
	match state:
		State.IDLE:
			sprite.play("Idle" + anim_suffix)
		State.WALK:
			sprite.play("Walk" + anim_suffix)
		State.JUMP:
			sprite.play("Jump" + anim_suffix)
		State.DEATH:
			sprite.play("death") 
		State.DASH:
			sprite.play("Dash" + anim_suffix)



func state_idle():
	velocity.x = move_toward(velocity.x, 0, SPEED)
	check_dash_input() 

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		change_state(State.JUMP)
		return

	var dir := Input.get_axis("left", "right")
	if dir != 0:
		change_state(State.WALK)

func state_walk():
	var dir := Input.get_axis("left", "right")
	check_dash_input()

	if dir == 0:
		change_state(State.IDLE)
		return

	velocity.x = dir * SPEED
	sprite.flip_h = dir < 0

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		change_state(State.JUMP)
		return

	if not is_on_floor():
		change_state(State.JUMP)

func state_jump():
	var dir := Input.get_axis("left", "right")
	velocity.x = dir * SPEED
	check_dash_input()

	if dir != 0:
		sprite.flip_h = dir < 0

	if is_on_floor():
		if abs(velocity.x) > 10:
			change_state(State.WALK)
		else:
			change_state(State.IDLE)

func state_dash(delta):
	dash_timer -= delta
	if dash_timer <= 0:
		velocity.x = 0
		change_state(State.IDLE)

func state_death():
	pass

# --- FUNCIONES DE AYUDA ---

func check_dash_input():
	# Solo permite el dash si las botas están equipadas en el menú
	if Global.habilidad_equipada == Global.Habilidades.BOTAS and Input.is_action_just_pressed("dash"):
		start_dash()

func start_dash():
	change_state(State.DASH)
	dash_timer = DASH_DURATION
	velocity.y = 0 # Evita caer mientras haces dash
	# Hacia dónde mira el sprite define la dirección del dash
	var dir = -1 if sprite.flip_h else 1 
	velocity.x = dir * DASH_SPEED

func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

func die():
	if state == State.DEATH:
		return
	$CollisionShape2D.disabled = true
	velocity = Vector2(0, -200)
	change_state(State.DEATH)

func _on_animation_finished():
	if state == State.DEATH:
		get_tree().reload_current_scene()
