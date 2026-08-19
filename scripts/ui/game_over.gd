extends CanvasLayer

## Oyun Bitti (Game Over) Ekranı

@onready var stats_label: Label = $Control/Panel/StatsLabel
@onready var retry_btn: Button = $Control/Panel/RetryButton

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameManager.game_over_triggered.connect(_on_game_over)
	retry_btn.pressed.connect(_on_retry_pressed)

func _on_game_over() -> void:
	visible = true
	get_tree().paused = true
	stats_label.text = "Ulaşılan Dalga: %d\nÖldürülen Fare: %d\nToplanan Koin: %d\nToplam Puan: %d" % [
		GameManager.current_wave,
		GameManager.enemies_killed,
		GameManager.total_coins_collected,
		GameManager.score
	]

func _on_retry_pressed() -> void:
	get_tree().paused = false
	GameManager.reset_game()
	get_tree().reload_current_scene()
