extends Node2D

## Çatı Havalandırma / Kanalizasyon Izgarası (Rat Nest Spawner)
## Dalga boyunca fare sürüsü fırlatır. Hasar verilemez/kırılamaz.
## Karakter üzerinden engelsizce geçebilir ve hasar almaz.

@export var spawn_interval: float = 4.2
var spawn_timer: float = 2.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("enemy_nests")
	z_index = -4
	z_as_relative = false
	if sprite:
		sprite.z_index = 0
		sprite.z_as_relative = true
	spawn_timer = randf_range(2.0, 4.0)

func _process(delta: float) -> void:
	if not GameManager.is_wave_active or GameManager.is_game_over:
		return
		
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		spawn_timer = spawn_interval
		_spawn_rat_pack()

func _spawn_rat_pack() -> void:
	# Kapak sarsılma / titreme efekti
	if sprite:
		var tw = create_tween()
		tw.tween_property(sprite, "scale", Vector2(1.25, 0.8), 0.08)
		tw.tween_property(sprite, "scale", Vector2(0.9, 1.15), 0.08)
		tw.tween_property(sprite, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_ELASTIC)
		tw.tween_property(sprite, "modulate", Color(2.0, 0.5, 0.5), 0.1)
		tw.tween_property(sprite, "modulate", Color.WHITE, 0.1)
		
	var wave_mgr = get_tree().get_first_node_in_group("wave_manager")
	if wave_mgr and wave_mgr.has_method("spawn_rat_from_nest"):
		wave_mgr.spawn_rat_from_nest(global_position)
