extends CharacterBody2D

enum State { IDLE, WALK, JUMP, DEATH }
var state: State = State.IDLE

const SPEED := 300.0
const JUMP_VELOCITY := -630.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready():
	sprite.animation_finished.connect(_on_animation_finished)
	change_state(State.IDLE)


func _physics_process(delta):
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

	move_and_slide()


# ------------------ CAMBIO DE ESTADO ------------------

func change_state(new_state: State):
	state = new_state

	match state:
		State.IDLE:
			sprite.play("Idle")
		State.WALK:
			sprite.play("Walk")
		State.JUMP:
			sprite.play("Jump")
		State.DEATH:
			sprite.play("death")


# ------------------ ESTADOS ------------------

func state_idle():
	velocity.x = move_toward(velocity.x, 0, SPEED)

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		change_state(State.JUMP)
		return

	var dir := Input.get_axis("left", "right")
	if dir != 0:
		change_state(State.WALK)


func state_walk():
	var dir := Input.get_axis("left", "right")

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

	if dir != 0:
		sprite.flip_h = dir < 0

	if is_on_floor():
		if abs(velocity.x) > 10:
			change_state(State.WALK)
		else:
			change_state(State.IDLE)


func state_death():
	# No controla nada, solo cae
	pass


# ------------------ GRAVEDAD ------------------

func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta


# ------------------ MUERTE ------------------

func die():
	if state == State.DEATH:
		return

	$CollisionShape2D.disabled = true
	velocity = Vector2(0, -200)
	change_state(State.DEATH)


func _on_animation_finished():
	if state == State.DEATH:
		get_tree().reload_current_scene()
