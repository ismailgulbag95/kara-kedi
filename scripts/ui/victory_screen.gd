extends CanvasLayer

## Zafer Ekranı (Victory Screen)
## Dalga 10 Final Boss'u yenildiğinde açılır.

@onready var stats_label: Label = $Control/Panel/StatsLabel
@onready var retry_btn: Button = $Control/Panel/RetryButton

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameManager.victory_triggered.connect(_on_victory)
	retry_btn.pressed.connect(_on_retry_pressed)

func _on_victory() -> void:
	visible = true
	get_tree().paused = true
	
	stats_label.text = """Öldürülen Fare: %d
Toplanan Koin: %d
Toplam Puan: %d
🏆 En Yüksek Skor: %d""" % [
		GameManager.enemies_killed,
		GameManager.total_coins_collected,
		GameManager.score,
		GameManager.high_score
	]

func _on_retry_pressed() -> void:
	visible = false
	get_tree().paused = false
	GameManager.reset_game()
	get_tree().reload_current_scene()
