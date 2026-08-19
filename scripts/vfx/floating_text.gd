extends Node2D

## Kritik / Hasar Uçan Metin Efekti (Floating Combat Text)
## Siyah konturlu, yay şeklinde sıçrayan (arc trajectory) dinamik hasar yazıları

@onready var label: Label = $Label

func setup(text_val: String, color_val: Color = Color(1.0, 0.95, 0.85), font_size: int = 14, is_crit: bool = false) -> void:
	label.text = text_val
	label.add_theme_color_override("font_color", color_val)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 3 if is_crit else 2)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	
	var start_scale = Vector2(0.4, 0.4)
	var peak_scale = Vector2(1.65, 1.65) if is_crit else Vector2(1.2, 1.2)
	scale = start_scale
	
	var rot_target = randf_range(-14.0, 14.0) if is_crit else randf_range(-6.0, 6.0)
	rotation_degrees = rot_target
	
	var target_x = position.x + randf_range(-26.0, 26.0)
	var peak_y = position.y - (48.0 if is_crit else 30.0)
	var end_y = peak_y + 10.0
	
	var tween = create_tween().set_parallel(true)
	# Pop scale & rotation spring
	tween.tween_property(self, "scale", peak_scale, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(self, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "rotation_degrees", 0.0, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Horizontal arc
	tween.tween_property(self, "position:x", target_x, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Vertical arc (up then down slightly)
	tween.tween_property(self, "position:y", peak_y, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(self, "position:y", end_y, 0.33).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	# Fade out
	tween.tween_property(label, "modulate:a", 0.0, 0.25).set_delay(0.3)
	tween.chain().tween_callback(queue_free)

