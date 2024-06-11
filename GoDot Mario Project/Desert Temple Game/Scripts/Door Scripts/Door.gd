extends Area2D

var entered : bool = false # Set flag to false

@export_file var desired_scene # Allow us to change scenes in inspector


func _on_body_entered(body: PhysicsBody2D): # If player enters collision radius
	entered = true # Flag set to true


func _on_body_exited(body: PhysicsBody2D): # If player leaves collision radius
	entered = false # Flag set to false


func _physics_process(delta):
	# This function will handle the scene switching
	if entered == true: # If flag is true
		if Input.is_action_just_pressed("player_interact"): # And we press player_interact "e"
			get_tree().change_scene_to_file(desired_scene) # Change to desired scene



