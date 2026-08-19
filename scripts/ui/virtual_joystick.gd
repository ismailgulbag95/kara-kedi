extends Control

## Android / Mobil Dinamik Dokunmatik Sanal Joystick (Floating Touch Joystick)
## Parmakla ekrana dokunulduğu yerde belirir ve 360 derece akıcı analog yönlendirme sağlar.

@export var max_distance: float = 75.0
@onready var base: TextureRect = $Base
@onready var knob: TextureRect = $Base/Knob

var is_touching: bool = false
var touch_index: int = -1
var default_base_pos: Vector2

func _ready() -> void:
	default_base_pos = base.position
	GameManager.joystick_vector = Vector2.ZERO
	base.modulate.a = 0.35
	
	GameManager.wave_started.connect(_on_wave_started)
	GameManager.wave_completed.connect(_on_wave_ended)
	GameManager.game_over_triggered.connect(_on_wave_ended)
	GameManager.victory_triggered.connect(_on_wave_ended)

func _on_wave_started(_wave: int) -> void:
	visible = true
	_reset_joystick()

func _on_wave_ended(_arg = null) -> void:
	_reset_joystick()
	visible = false

func _input(event: InputEvent) -> void:
	if not visible or not GameManager.is_wave_active or get_tree().paused:
		return

	# Dokunmatik Ekran Girişleri (Touch / Multitouch)
	if event is InputEventScreenTouch:
		if event.pressed and not is_touching:
			# Üst 140px (HUD ve Duraklatma butonu alanı) dışındaki her yere basıldığında joystick parmak altına gelsin
			if event.position.y > 140.0:
				is_touching = true
				touch_index = event.index
				base.global_position = event.position - (base.size / 2.0)
				knob.position = (base.size / 2.0) - (knob.size / 2.0)
				base.modulate.a = 0.85
		elif not event.pressed and event.index == touch_index:
			_reset_joystick()

	elif event is InputEventScreenDrag and is_touching and event.index == touch_index:
		_process_drag(event.position)

	# PC ve Fare Test Desteği
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not is_touching:
				if event.position.y > 140.0:
					is_touching = true
					touch_index = 0
					base.global_position = event.position - (base.size / 2.0)
					knob.position = (base.size / 2.0) - (knob.size / 2.0)
					base.modulate.a = 0.85
			elif not event.pressed and is_touching:
				_reset_joystick()

	elif event is InputEventMouseMotion and is_touching:
		_process_drag(event.position)

func _process_drag(target_global_pos: Vector2) -> void:
	var center = base.global_position + (base.size / 2.0)
	var offset = target_global_pos - center
	if offset.length() > max_distance:
		offset = offset.normalized() * max_distance

	knob.position = (base.size / 2.0) + offset - (knob.size / 2.0)
	GameManager.joystick_vector = offset / max_distance

func _reset_joystick() -> void:
	is_touching = false
	touch_index = -1
	base.position = default_base_pos
	knob.position = (base.size / 2.0) - (knob.size / 2.0)
	base.modulate.a = 0.35
	GameManager.joystick_vector = Vector2.ZERO
