extends CanvasLayer

## Zafer Ekranı (Victory Screen)
## Dalga 10 Final Boss'u yenildiğinde açılır. Dinamik Rakam Sayma Animasyonu (Number Ticking).

@onready var stats_label: Label = $Control/Panel/StatsLabel
@onready var retry_btn: Button = $Control/Panel/RetryButton

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameManager.victory_triggered.connect(_on_victory)
	retry_btn.pressed.connect(_on_retry_pressed)
	UIJuiceHelper.attach_button_juice(retry_btn)

func _on_victory() -> void:
	Engine.time_scale = 1.0
	visible = true
	get_tree().paused = true
	_animate_victory_stats()

func _animate_victory_stats() -> void:
	var target_kills = GameManager.enemies_killed
	var target_coins = GameManager.total_coins_collected
	var target_score = GameManager.score
	var high_s = GameManager.high_score
	
	var tween = create_tween()
	if tween:
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_method(func(val: float):
			var ratio = clampf(val, 0.0, 1.0)
			stats_label.text = """👑 ŞEHİR ARTIK KARA KEDİNİN!
Temizlenen Fare Sürüsü: %d
Kazanılan Zula Sermayesi: %d 🐟
Toplam Şehir Puanı: %d
🏆 En Yüksek Şehir Skoru: %d""" % [
				int(float(target_kills) * ratio),
				int(float(target_coins) * ratio),
				int(float(target_score) * ratio),
				high_s
			]
		, 0.0, 1.0, 0.85).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else:
		stats_label.text = """👑 ŞEHİR ARTIK KARA KEDİNİN!
Temizlenen Fare Sürüsü: %d
Kazanılan Zula Sermayesi: %d 🐟
Toplam Şehir Puanı: %d
🏆 En Yüksek Şehir Skoru: %d""" % [
			target_kills, target_coins, target_score, high_s
		]

func _on_retry_pressed() -> void:
	visible = false
	get_tree().paused = false
	GameManager.reset_game()
	get_tree().reload_current_scene()
