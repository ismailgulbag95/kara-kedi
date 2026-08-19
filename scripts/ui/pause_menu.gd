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
	UIJuiceHelper.attach_button_juice(resume_btn)
	UIJuiceHelper.attach_button_juice(restart_btn)
	
	var codex_btn = Button.new()
	codex_btn.text = "📖 SOKAK GÜNCESİ (CODEX)"
	codex_btn.custom_minimum_size = Vector2(0, 42)
	var c_style = StyleBoxFlat.new()
	c_style.bg_color = Color(0.12, 0.16, 0.26, 0.95)
	c_style.border_width_left = 1
	c_style.border_width_top = 1
	c_style.border_width_right = 1
	c_style.border_width_bottom = 1
	c_style.border_color = Color(0.4, 0.65, 0.9, 1.0)
	c_style.corner_radius_top_left = 8
	c_style.corner_radius_top_right = 8
	c_style.corner_radius_bottom_right = 8
	c_style.corner_radius_bottom_left = 8
	codex_btn.add_theme_stylebox_override("normal", c_style)
	codex_btn.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
	codex_btn.add_theme_font_size_override("font_size", 13)
	UIJuiceHelper.attach_button_juice(codex_btn, 0.94, 1.05)
	
	codex_btn.pressed.connect(func():
		var root = get_tree().current_scene
		if root and root.has_node("CodexModal"):
			root.get_node("CodexModal").open_codex()
	)
	
	var vbox = $Control/Panel/ButtonsVBox
	vbox.add_child(codex_btn)
	vbox.move_child(codex_btn, 1)


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
	high_score_label.text = "🏆 EN YÜKSEK ŞEHİR SKORU: %d" % GameManager.high_score
	current_score_label.text = "Gece Skoru: %d  |  Baskın: %d / 15  |  Sermaye: %d 🐟" % [
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
