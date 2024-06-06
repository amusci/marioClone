extends StaticBody2D

@export var lifespan = 5.0 # Time in seconds before the platform disappears

func _ready():
	# Start the timer to remove the platform after the lifespan
	await get_tree().create_timer(lifespan).timeout # If timer ran out
	queue_free() # Don't make it dave freeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeees (remove)
