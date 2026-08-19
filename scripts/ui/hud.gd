extends CanvasLayer

## Oyun İçi Bilgi Arayüzü (HUD), Boss Can Barı & Duraklatma Butonu
## Kritik Can Nabzı, Son 5 Saniye Acil Sayaç Animasyonu ve Koin Yaylanması

@onready var wave_label: Label = $Control/TopBar/WaveLabel
@onready var timer_label: Label = $Control/TopBar/TimerLabel
@onready var coins_label: Label = $Control/TopBar/CoinsContainer/CoinsLabel
@onready var hp_bar: ProgressBar = $Control/BottomBar/HpBar
@onready var damage_lag_bar: ProgressBar = $Control/BottomBar/DamageLagBar
@onready var hp_label: Label = $Control/BottomBar/HpLabel
@onready var score_label: Label = $Control/TopBar/ScoreLabel
@onready var pause_btn: Button = $Control/PauseButton

@onready var boss_container: Control = $Control/BossHealthBarContainer
@onready var boss_hp_bar: ProgressBar = $Control/BossHealthBarContainer/BossHpBar
@onready var boss_title: Label = $Control/BossHealthBarContainer/BossTitle

signal pause_requested

var hp_tween: Tween
var danger_rect: ColorRect
var danger_tween: Tween
var last_second_int: int = -1

func _ready() -> void:
	GameManager.coins_changed.connect(_on_coins_changed)
	GameManager.health_changed.connect(_on_health_changed)
	GameManager.wave_started.connect(_on_wave_started)
	GameManager.death_defiance_triggered.connect(_on_death_defiance_triggered)
	pause_btn.pressed.connect(_on_pause_pressed)
	UIJuiceHelper.attach_button_juice(pause_btn)
	
	boss_container.visible = false
	_setup_danger_rect()
	_setup_rage_ui()
	_update_all()

func _setup_danger_rect() -> void:
	danger_rect = ColorRect.new()
	danger_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	danger_rect.color = Color(0.85, 0.05, 0.05, 0.0)
	danger_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Control.add_child(danger_rect)
	$Control.move_child(danger_rect, 0)

func _update_all() -> void:
	_on_coins_changed(GameManager.coins)
	_on_health_changed(GameManager.current_hp, GameManager.max_hp)
	_on_wave_started(GameManager.current_wave)

func _on_coins_changed(new_coins: int) -> void:
	coins_label.text = str(new_coins)
	score_label.text = "PUAN: " + str(GameManager.score)
	
	var tween = create_tween()
	coins_label.pivot_offset = coins_label.size * 0.5
	coins_label.scale = Vector2(1.25, 1.25)
	tween.tween_property(coins_label, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_health_changed(current: float, max_hp: float) -> void:
	hp_bar.max_value = max_hp
	damage_lag_bar.max_value = max_hp
	
	hp_bar.value = current
	hp_label.text = "%d / %d" % [int(current), int(max_hp)]
	
	if is_instance_valid(hp_tween):
		hp_tween.kill()
		
	hp_tween = create_tween()
	hp_tween.tween_property(damage_lag_bar, "value", current, 0.35).set_delay(0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Kritik Can Nabzı (%25 Altında kırmızı kalp atışı uyarısı)
	var hp_ratio = current / max(1.0, max_hp)
	if hp_ratio <= 0.25 and current > 0.0:
		_start_danger_pulse()
	else:
		_stop_danger_pulse()

func _start_danger_pulse() -> void:
	if is_instance_valid(danger_tween) and danger_tween.is_running():
		return
	if is_instance_valid(danger_tween):
		danger_tween.kill()
		
	danger_tween = create_tween().set_loops()
	danger_tween.tween_property(danger_rect, "color:a", 0.28, 0.4).set_trans(Tween.TRANS_SINE)
	danger_tween.tween_property(danger_rect, "color:a", 0.08, 0.4).set_trans(Tween.TRANS_SINE)

func _stop_danger_pulse() -> void:
	if is_instance_valid(danger_tween):
		danger_tween.kill()
	if danger_rect:
		var fade = create_tween()
		fade.tween_property(danger_rect, "color:a", 0.0, 0.3)

func _on_wave_started(wave_num: int) -> void:
	wave_label.text = "DALGA " + str(wave_num)
	boss_container.visible = false
	timer_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))

func update_timer(seconds_left: float) -> void:
	var sec = max(0, int(seconds_left))
	timer_label.text = "%02d:%02d" % [sec / 60, sec % 60]
	
	# Son 5 saniye kırmızı acil sayaç nabzı
	if seconds_left <= 5.0 and seconds_left > 0.0:
		timer_label.add_theme_color_override("font_color", Color(1.0, 0.25, 0.25, 1.0))
		if sec != last_second_int:
			last_second_int = sec
			timer_label.pivot_offset = timer_label.size * 0.5
			var t = create_tween()
			t.tween_property(timer_label, "scale", Vector2(1.22, 1.22), 0.08).set_trans(Tween.TRANS_QUAD)
			t.tween_property(timer_label, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_SINE)
	else:
		timer_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))

func _on_pause_pressed() -> void:
	pause_requested.emit()

# --- BOSS HEALTH BAR KONTROLÜ ---
func show_boss_bar(title_name: String, max_hp: float) -> void:
	boss_title.text = "👑 " + title_name
	boss_hp_bar.max_value = max_hp
	boss_hp_bar.value = max_hp
	boss_container.visible = true
	
	var tween = create_tween()
	boss_container.modulate.a = 0.0
	tween.tween_property(boss_container, "modulate:a", 1.0, 0.3)

func update_boss_bar(current: float, max_val: float) -> void:
	boss_hp_bar.max_value = max_val
	boss_hp_bar.value = current
	if current <= 0.0:
		hide_boss_bar()

func hide_boss_bar() -> void:
	var tween = create_tween()
	tween.tween_property(boss_container, "modulate:a", 0.0, 0.3)
	tween.chain().tween_callback(func(): boss_container.visible = false)

func _on_death_defiance_triggered(_remaining_lives: int) -> void:
	var banner = PanelContainer.new()
	banner.custom_minimum_size = Vector2(400, 70)
	banner.set_anchors_preset(Control.PRESET_CENTER)
	banner.position = Vector2($Control.size.x * 0.5 - 200, $Control.size.y * 0.35)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.09, 0.02, 0.95)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = Color(1.0, 0.85, 0.2, 1.0)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_right = 12
	style.corner_radius_bottom_left = 12
	style.shadow_color = Color(1.0, 0.8, 0.1, 0.6)
	style.shadow_size = 16
	banner.add_theme_stylebox_override("panel", style)
	
	var lbl = Label.new()
	lbl.text = "🐱 DOKUZ CAN DEVREDE!\nÖlümden Dönüldü! (+%50 Can)"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 16)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.95, 0.4))
	lbl.add_theme_constant_override("outline_size", 3)
	lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	banner.add_child(lbl)
	
	$Control.add_child(banner)
	banner.pivot_offset = Vector2(200, 35)
	banner.scale = Vector2(0.5, 0.5)
	banner.modulate.a = 0.0
	
	var tw = create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.set_ignore_time_scale(true)
	tw.tween_property(banner, "scale", Vector2(1.15, 1.15), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(banner, "modulate:a", 1.0, 0.15)
	tw.tween_property(banner, "scale", Vector2.ONE, 0.12)
	tw.tween_interval(1.2)
	tw.tween_property(banner, "modulate:a", 0.0, 0.4)
	tw.parallel().tween_property(banner, "scale", Vector2(1.2, 1.2), 0.4)
	tw.tween_callback(banner.queue_free)

var rage_bar: ProgressBar
var rage_btn: Button

func _setup_rage_ui() -> void:
	var rage_container = HBoxContainer.new()
	rage_container.alignment = BoxContainer.ALIGNMENT_CENTER
	rage_container.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	rage_container.position = Vector2(0, $Control.size.y - 70)
	rage_container.size = Vector2($Control.size.x, 26)
	rage_container.add_theme_constant_override("separation", 10)
	
	rage_bar = ProgressBar.new()
	rage_bar.custom_minimum_size = Vector2(260, 16)
	rage_bar.max_value = 100.0
	rage_bar.value = 0.0
	rage_bar.show_percentage = false
	
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.08, 0.12, 0.09, 0.9)
	bg_style.border_width_left = 1
	bg_style.border_width_top = 1
	bg_style.border_width_right = 1
	bg_style.border_width_bottom = 1
	bg_style.border_color = Color(0.15, 0.55, 0.3)
	bg_style.corner_radius_top_left = 6
	bg_style.corner_radius_top_right = 6
	bg_style.corner_radius_bottom_right = 6
	bg_style.corner_radius_bottom_left = 6
	rage_bar.add_theme_stylebox_override("background", bg_style)
	
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color(0.15, 0.9, 0.45)
	fill_style.corner_radius_top_left = 5
	fill_style.corner_radius_top_right = 5
	fill_style.corner_radius_bottom_right = 5
	fill_style.corner_radius_bottom_left = 5
	rage_bar.add_theme_stylebox_override("fill", fill_style)
	
	rage_btn = Button.new()
	rage_btn.text = "⚡ KEDİOTU ÖFKESİ (%0)"
	rage_btn.custom_minimum_size = Vector2(200, 26)
	rage_btn.disabled = true
	rage_btn.add_theme_font_size_override("font_size", 11)
	UIJuiceHelper.attach_button_juice(rage_btn, 0.92, 1.06)
	rage_btn.pressed.connect(func():
		GameManager.activate_feline_rage()
	)
	
	rage_container.add_child(rage_bar)
	rage_container.add_child(rage_btn)
	$Control.add_child(rage_container)
	
	GameManager.feline_rage_changed.connect(_on_feline_rage_changed)
	GameManager.feline_rage_state_changed.connect(_on_feline_rage_state_changed)

func _on_feline_rage_changed(cur: float, max_v: float) -> void:
	if not is_instance_valid(rage_bar) or not is_instance_valid(rage_btn):
		return
	rage_bar.value = cur
	var pct = int((cur / max_v) * 100.0)
	if cur >= max_v:
		rage_btn.disabled = false
		rage_btn.text = "🔥 ÖFKEYİ BOŞALT! [BOŞLUK]"
		rage_btn.add_theme_color_override("font_color", Color(1.0, 0.95, 0.2))
	else:
		rage_btn.disabled = true
		rage_btn.text = "⚡ KEDİOTU ÖFKESİ (%%%d)" % pct
		rage_btn.add_theme_color_override("font_color", Color(0.7, 0.9, 0.8))

func _on_feline_rage_state_changed(is_active: bool) -> void:
	if not is_instance_valid(rage_btn):
		return
	if is_active:
		rage_btn.text = "💥 ÖFKE AKTİF! (HIZ + HASAR)"
		rage_btn.disabled = true
		rage_btn.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4))
