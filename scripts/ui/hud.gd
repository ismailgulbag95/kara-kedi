extends CanvasLayer

## Oyun İçi Bilgi Arayüzü (HUD), Boss Can Barı & Duraklatma Butonu

@onready var wave_label: Label = $Control/TopBar/WaveLabel
@onready var timer_label: Label = $Control/TopBar/TimerLabel
@onready var coins_label: Label = $Control/TopBar/CoinsContainer/CoinsLabel
@onready var hp_bar: ProgressBar = $Control/BottomBar/HpBar
@onready var hp_label: Label = $Control/BottomBar/HpLabel
@onready var score_label: Label = $Control/TopBar/ScoreLabel
@onready var pause_btn: Button = $Control/PauseButton

@onready var boss_container: Control = $Control/BossHealthBarContainer
@onready var boss_hp_bar: ProgressBar = $Control/BossHealthBarContainer/BossHpBar
@onready var boss_title: Label = $Control/BossHealthBarContainer/BossTitle

signal pause_requested

func _ready() -> void:
	GameManager.coins_changed.connect(_on_coins_changed)
	GameManager.health_changed.connect(_on_health_changed)
	GameManager.wave_started.connect(_on_wave_started)
	pause_btn.pressed.connect(_on_pause_pressed)
	
	boss_container.visible = false
	_update_all()

func _update_all() -> void:
	_on_coins_changed(GameManager.coins)
	_on_health_changed(GameManager.current_hp, GameManager.max_hp)
	_on_wave_started(GameManager.current_wave)

func _on_coins_changed(new_coins: int) -> void:
	coins_label.text = str(new_coins)
	score_label.text = "PUAN: " + str(GameManager.score)
	
	var tween = create_tween()
	coins_label.scale = Vector2(1.2, 1.2)
	tween.tween_property(coins_label, "scale", Vector2.ONE, 0.15)

func _on_health_changed(current: float, max_hp: float) -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = current
	hp_label.text = str(int(current)) + " / " + str(int(max_hp))

func _on_wave_started(wave_num: int) -> void:
	wave_label.text = "DALGA " + str(wave_num)
	boss_container.visible = false

func update_timer(seconds_left: float) -> void:
	var sec = max(0, int(seconds_left))
	timer_label.text = "%02d:%02d" % [sec / 60, sec % 60]

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
