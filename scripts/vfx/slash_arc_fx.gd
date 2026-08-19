extends Sprite2D

## Anime / Arcade Smear Frame Kılıç Savurma Efekti (Slash Smear Arc)

func _ready() -> void:
	scale = Vector2(0.5, 1.8)
	modulate = Color(1.8, 2.2, 2.5, 1.0)
	
	var orig_rot = rotation
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.9, 1.3), 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation", orig_rot + 0.45, 0.12).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "modulate:a", 0.0, 0.14).set_delay(0.04)
	tween.chain().tween_callback(queue_free)

