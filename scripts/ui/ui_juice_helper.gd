class_name UIJuiceHelper
extends RefCounted

## UI Elemanları için Yaylanma, Dokunsal Kart Fiziği ve Mikro Animasyon Yardımcısı (Squash & Stretch & Balatro Tilt)
## Pause-safe ve Web uyumlu yumuşak buton ve kart geri bildirimi.

static func attach_button_juice(btn: Button, press_scale: float = 0.92, hover_scale: float = 1.04) -> void:
	if not is_instance_valid(btn):
		return
	
	btn.pivot_offset = btn.size * 0.5
	if not btn.resized.is_connected(_on_btn_resized.bind(btn)):
		btn.resized.connect(_on_btn_resized.bind(btn))
	
	if not btn.button_down.is_connected(_on_btn_down.bind(btn, press_scale)):
		btn.button_down.connect(_on_btn_down.bind(btn, press_scale))
	
	if not btn.button_up.is_connected(_on_btn_up.bind(btn)):
		btn.button_up.connect(_on_btn_up.bind(btn))
	
	if not btn.mouse_entered.is_connected(_on_btn_enter.bind(btn, hover_scale)):
		btn.mouse_entered.connect(_on_btn_enter.bind(btn, hover_scale))
	
	if not btn.mouse_exited.is_connected(_on_btn_exit.bind(btn)):
		btn.mouse_exited.connect(_on_btn_exit.bind(btn))

static func attach_card_tilt(card: Control, _is_holo: bool = false) -> void:
	if not is_instance_valid(card):
		return
	
	card.pivot_offset = card.size * 0.5
	if not card.resized.is_connected(_on_card_resized.bind(card)):
		card.resized.connect(_on_card_resized.bind(card))
		
	card.mouse_entered.connect(func():
		if is_instance_valid(card):
			var tw = card.create_tween()
			if tw:
				tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
				tw.set_ignore_time_scale(true)
				tw.tween_property(card, "scale", Vector2(1.06, 1.06), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	)
	
	card.gui_input.connect(func(event: InputEvent):
		if not is_instance_valid(card):
			return
		if event is InputEventMouseMotion:
			var half_w = max(1.0, card.size.x * 0.5)
			var rel_x = (event.position.x - half_w) / half_w
			var target_rot = clamp(rel_x * 5.5, -6.0, 6.0)
			card.rotation_degrees = lerp(card.rotation_degrees, target_rot, 0.4)
	)
	
	card.mouse_exited.connect(func():
		if is_instance_valid(card):
			var tw = card.create_tween()
			if tw:
				tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
				tw.set_ignore_time_scale(true)
				tw.tween_property(card, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				tw.parallel().tween_property(card, "rotation_degrees", 0.0, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	)

static func _on_card_resized(card: Control) -> void:
	if is_instance_valid(card):
		card.pivot_offset = card.size * 0.5

static func _on_btn_resized(btn: Button) -> void:
	if is_instance_valid(btn):
		btn.pivot_offset = btn.size * 0.5

static func _on_btn_down(btn: Button, press_scale: float) -> void:
	if is_instance_valid(btn) and not btn.disabled:
		var tween = btn.create_tween()
		if tween:
			tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			tween.set_ignore_time_scale(true)
			tween.tween_property(btn, "scale", Vector2(press_scale, press_scale), 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

static func _on_btn_up(btn: Button) -> void:
	if is_instance_valid(btn) and not btn.disabled:
		var tween = btn.create_tween()
		if tween:
			tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			tween.set_ignore_time_scale(true)
			tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

static func _on_btn_enter(btn: Button, hover_scale: float) -> void:
	if is_instance_valid(btn) and not btn.disabled:
		var tween = btn.create_tween()
		if tween:
			tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			tween.set_ignore_time_scale(true)
			tween.tween_property(btn, "scale", Vector2(hover_scale, hover_scale), 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

static func _on_btn_exit(btn: Button) -> void:
	if is_instance_valid(btn) and not btn.disabled:
		var tween = btn.create_tween()
		if tween:
			tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			tween.set_ignore_time_scale(true)
			tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
