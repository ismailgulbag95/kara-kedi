extends Node2D

## Şehir Sisi, Neon Siren Uyarısı ve Tehlike Döngüsü Orkestratörü (Environment & Storm Manager)
## Zamana ve dalgaya bağlı olarak şehirde Gece Fırtınası & Neon Siren uyarısı başlatır.

signal storm_state_changed(is_active: bool)

@export var storm_interval: float = 45.0  # Her 45 saniyede bir fırtına uyarısı
@export var storm_duration: float = 15.0  # 15 saniye sürer

var timer: float = 0.0
var is_storm_active: bool = false

var siren_overlay: CanvasLayer = null
var siren_rect: ColorRect = null

func _ready() -> void:
	add_to_group("environment_manager")
	_create_siren_overlay()

func _create_siren_overlay() -> void:
	siren_overlay = CanvasLayer.new()
	siren_overlay.layer = 5
	add_child(siren_overlay)
	
	siren_rect = ColorRect.new()
	siren_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	siren_rect.color = Color(1.0, 0.0, 0.15, 0.0)
	siren_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	siren_overlay.add_child(siren_rect)

func _process(delta: float) -> void:
	if not GameManager.is_wave_active or GameManager.is_game_over:
		if is_storm_active:
			_end_storm()
		return
		
	timer += delta
	if not is_storm_active and timer >= storm_interval:
		_start_storm()
	elif is_storm_active and timer >= storm_duration:
		_end_storm()
		
	if is_storm_active and siren_rect:
		var pulse = (sin(Time.get_ticks_msec() * 0.008) * 0.5 + 0.5) * 0.22
		siren_rect.color = Color(1.0, 0.05, 0.1, pulse)

func _start_storm() -> void:
	timer = 0.0
	is_storm_active = true
	storm_state_changed.emit(true)
	
	SoundManager.play_wave_horn()
	
	# Show warning text
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("show_wave_announcement"):
		hud.show_wave_announcement("🚨 UYARI: GECE SIRENİ & SİS! FARELER KIZDI! (+%50 Hız/Hasar)")

func _end_storm() -> void:
	timer = 0.0
	is_storm_active = false
	storm_state_changed.emit(false)
	
	if siren_rect:
		siren_rect.color = Color.TRANSPARENT
