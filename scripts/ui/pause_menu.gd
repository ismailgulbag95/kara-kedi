extends CanvasLayer

## Sadeleştirilmiş Duraklatma Menüsü (Pause Menu)
## 1. En Yüksek Skor (Seçilemez Bilgi)
## 2. Devam Et (Seçilebilir)
## 3. Yeniden Başla (Seçilebilir)

@onready var high_score_label: Label = $Control/Panel/HighScoreCard/HighScoreLabel
@onready var current_score_label: Label = $Control/Panel/CurrentScoreLabel
@onready var resume_btn: Button = $Control/Panel/ButtonsVBox/ResumeButton
@onready var restart_btn: Button = $Control/Panel/ButtonsVBox/RestartButton

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	resume_btn.pressed.connect(_on_resume_pressed)
	restart_btn.pressed.connect(_on_restart_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not GameManager.is_game_over:
		if visible:
			_on_resume_pressed()
		else:
			open_pause_menu()

func open_pause_menu() -> void:
	if GameManager.is_game_over:
		return
		
	visible = true
	get_tree().paused = true
	_update_display()

func _update_display() -> void:
	# En yüksek skor ve anlık skor güncellemesi
	high_score_label.text = "🏆 EN YÜKSEK SKOR: %d" % GameManager.high_score
	current_score_label.text = "Mevcut Skor: %d  |  Dalga: %d  |  Koin: %d" % [
		GameManager.score,
		GameManager.current_wave,
		GameManager.coins
	]

func _on_resume_pressed() -> void:
	visible = false
	get_tree().paused = false

func _on_restart_pressed() -> void:
	visible = false
	get_tree().paused = false
	GameManager.reset_game()
	get_tree().reload_current_scene()
