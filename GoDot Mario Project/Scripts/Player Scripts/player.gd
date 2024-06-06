class_name Player
extends CharacterBody2D

# Export variables
@export var speed = 300.0
@export var jump_force = -290.0
@export var jump_time : float = 0.2
@export var coyote_time : float = 0.1
@export var jump_buffer_time : float = 0.2
@export var gravity_multiplier : float = 3.0
@export var acceleration : float = 15
@export var wall_jump_pushoff : float = 300
@export var wall_slide_gravity : float = 50
@export var hat_distance : int = 100

# Packed Scenes
@export var hat : PackedScene = preload("res://Scenes/Platforms/temporary_platform.tscn")

# Variables in-house
var gravity = 980
var is_jumping : bool = false
var jump_timer : float = 0
var coyote_counter : float = 0
var jump_buffer_counter : float = 0
var can_control : bool = true
var is_wall_sliding : bool = false
var facing_right : bool = false
var hat_exists : bool = false

# On ready variables
@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer

func _physics_process(delta):
	if not can_control: # If we cant control our player, return
		return
	# Function called once per physics frame
	player_jump(delta) # Line 33
	player_run(delta) # Line 47
	move_and_slide() # Move and slide
	wall_slide(delta) # Line 95
	if Input.is_action_just_pressed("throw_hat"): # If B key pressed
		throw_hat() # Line 108


func player_run(delta):
	var direction = Input.get_axis("move_left", "move_right") # Get left and right inputs

	if direction != 0: # If inputs exist
		if direction > 0: # If going right
			velocity.x = min(velocity.x + acceleration, speed) # Whatever minimum from start acceleration to max speed
			sprite_2d.flip_h = false # Make sure the sprite is not flipped
			facing_right = true
		else: # If going left
			velocity.x = max(velocity.x - acceleration, -speed) # Whatever maximum (remember going left is negative)
			sprite_2d.flip_h = true # Flip the sprite horizontally
			facing_right = false
	else: # If no inputs
		velocity.x = move_toward(velocity.x, 0, acceleration + 3) # MOVE TO A HALT
	#player_animations(direction) # Call animations

func player_jump(delta):
	# Print debug information
	print("is_on_floor: ", is_on_floor())
	print("is_jumping: ", is_jumping)
	print("coyote_counter: ", coyote_counter)
	print("jump_timer: ", jump_timer)
	
	# This function handles player's ability to jump
	if is_on_floor(): # if we are on the floor
		coyote_counter = coyote_time # Set the counter to the time 
	else: # If we aren't on the floor (falling)
		velocity.y += gravity * gravity_multiplier * delta # Apply gravity with multiplier
		coyote_counter -= delta # Decrement counterq
		
	if Input.is_action_just_pressed("jump"):
		# This allows us to press jump slightly before we land for smooth controls
		jump_buffer_counter = jump_buffer_time # We set the counter to the time we want our character to jump before landing
	else:
		jump_buffer_counter -= delta # Decrement the counter by delta since we aren't jumping we want it to go to 0
	if coyote_counter >= 0 and jump_buffer_counter > 0: # If we arent jumping (since 0) and jumping (line 64) 
		jump_buffer_counter = 0 # Instantly set counter back to 0
		velocity.y = jump_force # Apply jump force
		is_jumping = true # Switch jump flag to true
	elif Input.is_action_pressed("jump") and is_jumping: # If we are holding jump while jumping
		velocity.y = jump_force # Maintain jump force if jump button is held
	if is_jumping and Input.is_action_pressed("jump") and jump_timer < jump_time: # Handle variable jump height based on button hold duration
		jump_timer += delta # Increment jump timer
	else:
		is_jumping = false # End jumping if conditions are not met
		jump_timer = 0 # Reset jump timer
	if is_on_wall() and Input.is_action_pressed("move_right") and Input.is_action_just_pressed("jump"): # If holding right and tap jump
		velocity.y = jump_force * 3 # Jump up
		velocity.x = -wall_jump_pushoff # Jump towards left
	if is_on_wall() and Input.is_action_pressed("move_left") and Input.is_action_just_pressed("jump"): # If holding right and tap jump
		velocity.y = jump_force * 3 # Jump up
		velocity.x = wall_jump_pushoff # Jump towards right
		
		
func wall_slide(delta):
	# This will handle all player movement against the wall
	if is_on_wall() and not is_on_floor(): # If on wall in air
		if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"): # If we want to hug the wall
			is_wall_sliding = true # Slide down
		else:
			is_wall_sliding = false # We aren't on a wall
	else:
		is_wall_sliding = false # We aren't on a wall
	
	if is_wall_sliding: # If we are on a wall
		velocity.y += (wall_slide_gravity * delta) # Slide down
		velocity.y = min(velocity.y, wall_slide_gravity) # Slide down
	
func throw_hat():
	if not hat_exists:
		
		var hat = hat.instantiate() # Add an instance of the hat to our scene (NOT SHOWN)
		hat.connect("tree_exited", Callable(self, "_on_hat_removed"))
		if facing_right: # If we are facing right
			hat.global_position = global_position + Vector2(hat_distance, 0) # Send hat to the right
		else:
			hat.global_position = global_position + Vector2(-hat_distance, 0) # Send hat to the left
		get_parent().add_child(hat) # Add the hat to our scene tree (SHOWN)
		hat_exists = true # Platform exists
		
func _on_hat_removed():
	hat_exists = false # Reset flag when platform removed

'''func handle_death() -> void:
	# Function handles player death
	print("Player Died!")
	visible = false
	can_control = false
	await get_tree().create_timer(1).timeout # Wait for timer to time out
	reset_player()'''
	
'''func reset_player() -> void:
	# Function handles player reset
	global_position = Vector2(0,0) # Set the global position to (0, 0)
	visible = true
	can_control = true'''
	
'''func player_animations(direction : float) -> void:
	# Function handles all player animations
	if abs(direction) > 0.1 and is_on_floor(): # If we are moving and on floor
		animation_player.play("running") # Running animation
	elif not is_on_floor(): # If we are in the air
		animation_player.play("jump") # Jumping animation
	else: 
		animation_player.play("idle") # Idle animation'''
