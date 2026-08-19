extends CanvasLayer

## Başlangıç / Ana Menü Ekranı (Title Screen)
## Parlak Altın Başlangıç, Üzerine Gelince Kanlanan Kırmızı Hover Efekti
## Yeniden Oyna dendiğinde doğrudan oyunu başlatır (Menü tekrar açılmaz).

@onready var play_btn: Button = $Control/Panel/PlayButton
@onready var panel: Panel = $Control/Panel

var normal_style: StyleBoxFlat
var hover_style: StyleBoxFlat

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if GameManager.has_played_before:
		visible = false
		get_tree().paused = false
		GameManager.wave_started.emit(1)
		return
		
	visible = true
	get_tree().paused = true
	
	_setup_button_styles()
	play_btn.pressed.connect(_on_play_pressed)
	play_btn.mouse_entered.connect(_on_play_mouse_entered)
	play_btn.mouse_exited.connect(_on_play_mouse_exited)

func _setup_button_styles() -> void:
	# Normal Parlak Altın Sarısı
	normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.96, 0.78, 0.18, 1.0)
	normal_style.border_width_left = 3
	normal_style.border_width_top = 3
	normal_style.border_width_right = 3
	normal_style.border_width_bottom = 3
	normal_style.border_color = Color(1.0, 0.92, 0.45, 1.0)
	normal_style.corner_radius_top_left = 14
	normal_style.corner_radius_top_right = 14
	normal_style.corner_radius_bottom_right = 14
	normal_style.corner_radius_bottom_left = 14
	
	# Üzerine Gelindiğinde Kanlanan Kırmızı Stil
	hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color(0.75, 0.08, 0.08, 1.0) # Derin Kan Kırmızısı
	hover_style.border_width_left = 3
	hover_style.border_width_top = 3
	hover_style.border_width_right = 3
	hover_style.border_width_bottom = 3
	hover_style.border_color = Color(1.0, 0.3, 0.3, 1.0)
	hover_style.corner_radius_top_left = 14
	hover_style.corner_radius_top_right = 14
	hover_style.corner_radius_bottom_right = 14
	hover_style.corner_radius_bottom_left = 14
	
	play_btn.add_theme_stylebox_override("normal", normal_style)
	play_btn.add_theme_color_override("font_color", Color(0.12, 0.08, 0.02, 1.0))

func _on_play_mouse_entered() -> void:
	# Kanlanan Kırmızı Animasyon
	play_btn.add_theme_stylebox_override("normal", hover_style)
	play_btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	
	var tween = create_tween()
	tween.tween_property(play_btn, "scale", Vector2(1.06, 1.06), 0.12).set_trans(Tween.TRANS_QUAD)
	play_btn.pivot_offset = play_btn.size * 0.5

func _on_play_mouse_exited() -> void:
	play_btn.add_theme_stylebox_override("normal", normal_style)
	play_btn.add_theme_color_override("font_color", Color(0.12, 0.08, 0.02, 1.0))
	
	var tween = create_tween()
	tween.tween_property(play_btn, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_QUAD)

func _on_play_pressed() -> void:
	SoundManager.play_wave_horn()
	GameManager.has_played_before = true
	
	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 0.0, 0.35)
	tween.tween_callback(func():
		visible = false
		get_tree().paused = false
		GameManager.reset_game()
		GameManager.wave_started.emit(1)
	)
