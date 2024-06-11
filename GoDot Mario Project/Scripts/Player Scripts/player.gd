class_name Player
extends CharacterBody2D

# Export variables
@export var speed = 300.0
@export var jump_force = -200.0
@export var jump_time : float = 0.2
@export var coyote_time : float = 0.1
@export var jump_buffer_time : float = 0.2
@export var gravity_multiplier : float = 3.0
@export var acceleration : float = 15
@export var wall_jump_pushoff : float = 300
@export var wall_slide_gravity : float = 50
@export var hat_distance : int = 100
@export var gravity_jump_increment : float = 15

# Packed Scenes
@export var hat : PackedScene = preload("res://Scenes/Platforms/temporary_platform.tscn")

# Variables in-house
var gravity = 100
var is_jumping : bool = false
var jump_timer : float = 0
var coyote_counter : float = 0
var jump_buffer_counter : float = 0
var can_control : bool = true
var is_wall_sliding : bool = false
var facing_right : bool = false
var hat_exists : bool = false

# On ready variables
@onready var sprite_2d = $AnimatedSprite2D
@onready var animation_player = $AnimatedSprite2D
@onready var gravity_label = $Label # Reference to the Label node

func _physics_process(delta):
	if not can_control: # If we cant control our player, return
		return
	# Function called once per physics frame
	player_jump(delta)
	player_run(delta)
	move_and_slide()
	wall_slide(delta)
	if Input.is_action_just_pressed("throw_hat"):
		throw_hat()

	# Update the gravity label text
	gravity_label.text = "Gravity: %s" % gravity

func player_run(delta):
	var direction = Input.get_axis("move_left", "move_right")

	if direction != 0:
		if direction > 0:
			velocity.x = min(velocity.x + acceleration, speed)
			sprite_2d.flip_h = false
			facing_right = true
		else:
			velocity.x = max(velocity.x - acceleration, -speed)
			sprite_2d.flip_h = true
			facing_right = false
	else:
		velocity.x = move_toward(velocity.x, 0, acceleration + 3)
	player_animations(direction)

func player_jump(delta):
	# Print debug information
	print("is_on_floor: ", is_on_floor())
	print("is_jumping: ", is_jumping)
	print("coyote_counter: ", coyote_counter)
	print("jump_timer: ", jump_timer)
	if gravity >= 1300:
		gravity = 1300
	
	# This function handles player's ability to jump
	if is_on_floor():
		coyote_counter = coyote_time
		gravity = 980
	else:
		gravity += gravity_jump_increment
		velocity.y += gravity * gravity_multiplier * delta
		coyote_counter -= delta
		
		
	if Input.is_action_just_pressed("jump"):
		jump_buffer_counter = jump_buffer_time
	else:
		jump_buffer_counter -= delta
	
	if coyote_counter >= 0 and jump_buffer_counter > 0:
		jump_buffer_counter = 0
		velocity.y = jump_force
		is_jumping = true
		
	elif Input.is_action_pressed("jump") and is_jumping:
		velocity.y = jump_force
	if is_jumping and Input.is_action_pressed("jump") and jump_timer < jump_time:
		jump_timer += delta
	else:
		gravity = gravity
		is_jumping = false
		jump_timer = 0

	if is_on_wall() and Input.is_action_pressed("move_right") and Input.is_action_just_pressed("jump"):
		gravity = 550
		velocity.y = jump_force * 3
		velocity.x = -wall_jump_pushoff
		
	elif is_on_wall() and Input.is_action_pressed("move_left") and Input.is_action_just_pressed("jump"):
		gravity = 550
		velocity.y = jump_force * 3
		velocity.x = wall_jump_pushoff
		
		
func wall_slide(delta):
	# This will handle all player movement against the wall
	if is_on_wall() and not is_on_floor():
		if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
			is_wall_sliding = true
		else:
			is_wall_sliding = false
	else:
		is_wall_sliding = false
	
	if is_wall_sliding:
		velocity.y += wall_slide_gravity * delta
		velocity.y = min(velocity.y, wall_slide_gravity)

func throw_hat():
	if not hat_exists:
		var hat = hat.instantiate()
		hat.connect("tree_exited", Callable(self, "_on_hat_removed"))
		if facing_right:
			hat.global_position = global_position + Vector2(hat_distance, 0)
		else:
			hat.global_position = global_position + Vector2(-hat_distance, 0)
		get_parent().add_child(hat)
		hat_exists = true
		
func _on_hat_removed():
	hat_exists = false

func player_animations(direction: float) -> void:
	# Function handles all player animations
	if abs(direction) > 0.1 and is_on_floor():
		animation_player.play("player_run")
	else:
		animation_player.play("player_idle")
