extends Area2D

var entered : bool = false

@export_file var desired_scene


func _on_body_entered(body):
	entered = true


func _on_body_exited(body):
	entered = false
	
	
func _physics_process(delta):
	if entered == true:
		if Input.is_action_just_pressed("player_interact"):
			get_tree().change_scene_to_file(desired_scene)
