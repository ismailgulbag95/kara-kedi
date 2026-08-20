extends StaticBody2D

## Çatı Su Kulesi (Interactive Water Tower Prop)
## Vurulduğunda kırılan ve su dalgası salarak tüm fareleri sürükleyip hasar veren interaktif nesne.

@export var max_hp: float = 40.0
var current_hp: float = 40.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("interactive_props")
	current_hp = max_hp

func take_damage(amount: float, _knockback_dir: Vector2 = Vector2.ZERO, _knock_force: float = 0.0, _is_crit: bool = false, _source_weapon: String = "") -> void:
	current_hp -= amount
	if sprite:
		var tw = create_tween()
		tw.tween_property(sprite, "modulate", Color(1.5, 2.0, 3.0), 0.08)
		tw.tween_property(sprite, "modulate", Color.WHITE, 0.08)
		
	if current_hp <= 0.0:
		_break_water_tower()

func _break_water_tower() -> void:
	SoundManager.play_explosion()
	
	# Spawn water shockwave FX
	var wave_sc = load("res://scenes/vfx/shockwave_fx.tscn")
	if wave_sc:
		var wave = wave_sc.instantiate()
		wave.global_position = global_position
		wave.scale = Vector2(2.5, 2.5)
		wave.modulate = Color(0.2, 0.7, 1.0, 0.9)
		get_parent().add_child(wave)
		
	# Damage & push back all nearby enemies in 350px radius
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if is_instance_valid(e):
			var dist = global_position.distance_to(e.global_position)
			if dist <= 350.0:
				var push_dir = (e.global_position - global_position).normalized()
				if e.has_method("take_damage"):
					e.take_damage(80.0, push_dir, 450.0)
				if "velocity" in e:
					e.velocity += push_dir * 450.0
					
	queue_free()
