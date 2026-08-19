extends Area2D

## İp Yumağı Bombası Mermisi (Tier Destekli AoE)

var target_position: Vector2 = Vector2.ZERO
var start_position: Vector2 = Vector2.ZERO
var flight_progress: float = 0.0
var flight_duration: float = 0.55
var arc_height: float = 60.0
var damage: float = 38.0
var aoe_radius: float = 75.0
var tier: int = 1

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	start_position = global_position
	if GameManager.TIER_COLORS.has(tier):
		sprite.modulate = GameManager.TIER_COLORS[tier]
	var s = 1.0 + (tier - 1) * 0.25
	scale = Vector2(s, s)
	aoe_radius = 75.0 + (tier - 1) * 20.0

func _physics_process(delta: float) -> void:
	flight_progress += delta / flight_duration
	sprite.rotation += delta * 12.0
	
	var t = clampf(flight_progress, 0.0, 1.0)
	var current_ground = start_position.lerp(target_position, t)
	var current_y_offset = -sin(t * PI) * arc_height
	global_position = current_ground + Vector2(0, current_y_offset)
	
	if flight_progress >= 1.0:
		_explode()

const SHOCKWAVE_SCENE = preload("res://scenes/vfx/shockwave_fx.tscn")

func _explode() -> void:
	SoundManager.play_bomb_boom()
	var tier_mult = GameManager.TIER_MULTIPLIERS.get(tier, 1.0)
	
	# Alan Patlama Şok Dalgası Görseli (VFX)
	var shock = SHOCKWAVE_SCENE.instantiate()
	shock.global_position = global_position
	shock.max_scale = 2.4 + (tier - 1) * 0.4
	shock.is_enemy_attack = false
	var root_scene = get_tree().current_scene
	if is_instance_valid(root_scene):
		root_scene.call_deferred("add_child", shock)
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if is_instance_valid(e) and not e.is_queued_for_deletion():
			var dist = global_position.distance_to(e.global_position)
			if dist <= aoe_radius:
				var is_crit = randf() < GameManager.crit_chance
				var dmg = damage * tier_mult * (GameManager.crit_multiplier if is_crit else 1.0)
				var knock_dir = (e.global_position - global_position).normalized()
				e.take_damage(dmg, knock_dir, 320.0 * tier_mult, is_crit)
				
	var tween = create_tween().set_parallel(true)
	tween.tween_property(sprite, "scale", Vector2(2.8, 2.8), 0.14)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.14)
	tween.chain().tween_callback(queue_free)
