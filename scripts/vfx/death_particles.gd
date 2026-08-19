extends CPUParticles2D

func _ready() -> void:
	emitting = true
	one_shot = true
	var timer = get_tree().create_timer(lifetime + 0.1)
	timer.timeout.connect(queue_free)
