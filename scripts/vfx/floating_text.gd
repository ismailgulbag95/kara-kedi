extends Node2D

## Kritik / Hasar Uçan Metin Efekti (Floating Combat Text)

@onready var label: Label = $Label

func setup(text_val: String, color_val: Color = Color(1.0, 0.85, 0.2), font_size: int = 15) -> void:
	label.text = text_val
	label.add_theme_color_override("font_color", color_val)
	label.add_theme_font_size_override("font_size", font_size)
	
	scale = Vector2(0.5, 0.5)
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", position.y - 38.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.45).set_delay(0.1)
	tween.chain().tween_callback(queue_free)
