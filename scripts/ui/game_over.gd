extends CanvasLayer

## Oyun Bitti (Game Over) Ekranı
## Dinamik Rakam Sayma Animasyonu (Number Ticking) ve Yüksek Skor Vurgusu

@onready var stats_label: Label = $Control/Panel/StatsLabel
@onready var retry_btn: Button = $Control/Panel/RetryButton

var is_animating: bool = false

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameManager.game_over_triggered.connect(_on_game_over)
	retry_btn.pressed.connect(_on_retry_pressed)
	UIJuiceHelper.attach_button_juice(retry_btn)

func _on_game_over() -> void:
	visible = true
	get_tree().paused = true
	_animate_stats_count()

func _animate_stats_count() -> void:
	var target_wave = GameManager.current_wave
	var target_kills = GameManager.enemies_killed
	var target_coins = GameManager.total_coins_collected
	var target_score = GameManager.score
	
	var is_new_record = (target_score >= GameManager.high_score and target_score > 0)
	var record_str = "\n🏆 YENİ EN YÜKSEK SKOR!" if is_new_record else ""
	
	var tween = create_tween()
	if tween:
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		var dummy = 0.0
		tween.tween_method(func(val: float):
			var ratio = clampf(val, 0.0, 1.0)
			stats_label.text = "Ulaşılan Dalga: %d\nÖldürülen Fare: %d\nToplanan Koin: %d\nToplam Puan: %d%s" % [
				int(float(target_wave) * ratio),
				int(float(target_kills) * ratio),
				int(float(target_coins) * ratio),
				int(float(target_score) * ratio),
				record_str if ratio >= 1.0 else ""
			]
		, 0.0, 1.0, 0.75).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else:
		stats_label.text = "Ulaşılan Dalga: %d\nÖldürülen Fare: %d\nToplanan Koin: %d\nToplam Puan: %d%s" % [
			target_wave, target_kills, target_coins, target_score, record_str
		]

func _on_retry_pressed() -> void:
	get_tree().paused = false
	GameManager.reset_game()
	get_tree().reload_current_scene()
