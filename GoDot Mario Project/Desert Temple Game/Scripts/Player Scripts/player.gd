class_name Player
extends CharacterBody2D

# Export variables
@export var speed = 300.0
@export var jump_force = -250.0
@export var jump_time : float = 0.2
@export var coyote_time : float = 0.1
@export var jump_buffer_time : float = 0.2
@export var gravity_multiplier : float = 3.0
@export var acceleration : float = 15
@export var wall_jump_pushoff : float = 300
@export var wall_slide_gravity : float = 50
@export var hat_distance : int = 100
@export var gravity_jump_increment : float = 15
@export var gravity_clamp : float = 1300

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
@onready var sprite_2d = $AnimatedSprite2D
@onready var animation_player = $AnimatedSprite2D
@onready var gravity_label = $GravityLabel # Reference to the Label node
@onready var y_velo_label = $yVelocityLabel # Reference to the Label node
@onready var x_velo_label = $xVelocityLabel # Reference to the Label node

func _physics_process(delta):
	# DEBUG LABELS
	gravity_label.text = "Gravity: %s" % gravity
	y_velo_label.text = "y Velocity: %s" % velocity.y
	x_velo_label.text = "x Velocity: %s" % velocity.x
	
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
	player_animations(direction) # Call animations

func player_jump(delta):
	# Print debug information
	print("is_on_floor: ", is_on_floor())
	print("is_jumping: ", is_jumping)
	print("coyote_counter: ", coyote_counter)
	print("jump_timer: ", jump_timer)
	
	# This function handles player's ability to jump
	if is_on_floor(): # If we are on the floor
		coyote_counter = coyote_time
		gravity = 800 # Make sure gravity starts at 980
	else: # If we are jumping/falling
		gravity += gravity_jump_increment * delta # Increase gravity to give player weight
		# Clamp gravity after incrementing
		if gravity >= gravity_clamp:
			gravity = gravity_clamp # Clamp gravity to 1300
		velocity.y += gravity * gravity_multiplier * delta # Apply gravity
		coyote_counter -= delta # Decrement Counter
	
	if (is_jumping or is_wall_sliding) and velocity.y < .5: # If we are at the apex
		gravity -= 25 * delta # Remove a bit of gravity to have a floaty apex
	
	if Input.is_action_just_pressed("jump"): # This will allow us to jump just before landing
		jump_buffer_counter = jump_buffer_time # We set the counter to the time we want our character to jump before landing
	else:
		jump_buffer_counter -= delta # Decrement counter by delta since we aren't jumping we want it to go down to 0
	
	if coyote_counter >= 0 and jump_buffer_counter > 0: # If we aren't jumping (since 0) and jumping (line 64) 
		jump_buffer_counter = 0 # Instantly set counter to 0
		velocity.y = jump_force # Apply jump force
		is_jumping = true # Switch the jump flag to true
	elif Input.is_action_pressed("jump") and is_jumping: # If we are holding jump while jumping
		velocity.y = jump_force # Maintain jump force for a higher jump
	
	if is_jumping and Input.is_action_pressed("jump") and jump_timer < jump_time: # Handle jump height based on button hold duration
		jump_timer += delta # Increment jump timer
	else: # If anything else is happening
		is_jumping = false # Switch flag back to not jumping
		jump_timer = 0 # Reset timer since we aren't jumping

	if is_on_wall() and Input.is_action_pressed("move_right") and Input.is_action_just_pressed("jump"): # If holding right and tap jump
		gravity = 550 # Set gravity to a bit lighter for better feeling walljumps
		velocity.y = jump_force * 2.5 # Jump up
		velocity.x = -wall_jump_pushoff # Jump towards left
	elif is_on_wall() and Input.is_action_pressed("move_left") and Input.is_action_just_pressed("jump"):
		gravity = 550 # Set gravity to a bit lighter for better feeling walljumps
		velocity.y = jump_force * 2.5 # Jump up
		velocity.x = wall_jump_pushoff # Jump towards left
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
	
func player_animations(direction : float) -> void:
	# Function handles all player animations
	if abs(direction) > 0.1 and is_on_floor(): # If we are moving and on floor
		animation_player.play("player_run") # Running animation
	# elif not is_on_floor(): # If we are in the air
		# animation_player.play("jump") # Jumping animation
	else: 
		animation_player.play("player_idle") # Idle animation
