extends Area2D

func _on_body_entered(body):
	if body.is_in_group("Climber"):
		if not body.climbing:
			body.start_climbing()

func _on_body_exited(body):
	if body.is_in_group("Climber"):
		if body.climbing:
			body.stop_climbing()
