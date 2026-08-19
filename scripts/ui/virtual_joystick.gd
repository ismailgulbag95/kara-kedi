extends Control

## Android / Mobil Dinamik Dokunmatik Sanal Joystick (Floating Touch Joystick)
## Parmakla ekrana dokunulduğu yerde belirir ve 360 derece akıcı yönlendirme sağlar.

@export var max_distance: float = 60.0
@onready var base: TextureRect = $Base
@onready var knob: TextureRect = $Base/Knob

var is_touching: bool = false
var touch_index: int = -1
var default_base_pos: Vector2

func _ready() -> void:
	default_base_pos = base.position
	GameManager.joystick_vector = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and not is_touching:
			# Ekranın alt 2/3'lük kısmına dokunulduğunda aktifleş
			if event.position.y > 200.0:
				is_touching = true
				touch_index = event.index
				base.global_position = event.position - (base.size / 2.0)
				knob.position = (base.size / 2.0) - (knob.size / 2.0)
				base.modulate.a = 0.9
		elif not event.pressed and event.index == touch_index:
			_reset_joystick()
			
	elif event is InputEventScreenDrag and is_touching and event.index == touch_index:
		_process_drag(event.position)
		
	# PC'de Fare ile Test Desteği
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not is_touching:
				if event.position.y > 200.0:
					is_touching = true
					base.global_position = event.position - (base.size / 2.0)
					knob.position = (base.size / 2.0) - (knob.size / 2.0)
					base.modulate.a = 0.9
			elif not event.pressed:
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
	base.modulate.a = 0.5
	GameManager.joystick_vector = Vector2.ZERO
