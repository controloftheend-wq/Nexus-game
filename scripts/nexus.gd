extends CharacterBody2D


var SPEED := 300.0
const JUMP_VELOCITY := -630.0

enum State { IDLE, WALK, JUMP }
var state: State = State.IDLE

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	state_machine(delta)
	update_animation()
	move_and_slide()



func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

func die():
	get_tree().reload_current_scene()

func state_machine(delta):
	match state:
		State.IDLE:
			state_idle()
		State.WALK:
			state_walk()
		State.JUMP:
			state_jump()



func state_idle():
	velocity.x = move_toward(velocity.x, 0, SPEED)

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		state = State.JUMP
		return

	var direction := Input.get_axis("left", "right")
	if direction != 0:
		state = State.WALK



func state_walk():
	var direction := Input.get_axis("left", "right")

	if direction == 0:
		state = State.IDLE
		return

	velocity.x = direction * SPEED
	sprite.flip_h = direction < 0

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		state = State.JUMP
		return

	if not is_on_floor():
		state = State.JUMP



func state_jump():
	var direction := Input.get_axis("left", "right")
	velocity.x = direction * SPEED

	sprite.flip_h = direction < 0 if direction != 0 else sprite.flip_h

	if is_on_floor():
		if abs(velocity.x) > 10:
			state = State.WALK
		else:
			state = State.IDLE


func update_animation():
	match state:
		State.IDLE:
			sprite.play("Idle")
		State.WALK:
			sprite.play("Walk")
		State.JUMP:
			sprite.play("Jump")
