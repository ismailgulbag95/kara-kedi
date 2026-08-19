extends Node2D

## Avcı Yayı Silahı
## Dengeli Hasar & Hız (24 Hasar, 0.48s bekleme), Delip Geçen Oklar

@export var slot_index: int = 0
@export var tier: int = 1

@onready var pivot: Node2D = $Pivot
@onready var sprite: Sprite2D = $Pivot/Sprite2D
@onready var muzzle: Marker2D = $Pivot/Muzzle

var attack_cooldown: float = 0.0
var base_fire_rate: float = 0.48

const ARROW_SCENE = preload("res://scenes/weapons/arrow_projectile.tscn")

func _ready() -> void:
	_apply_tier_visuals()

func _apply_tier_visuals() -> void:
	if GameManager.TIER_COLORS.has(tier):
		sprite.modulate = GameManager.TIER_COLORS[tier]
	var scale_mult = 1.0 + (tier - 1) * 0.15
	scale = Vector2(scale_mult, scale_mult)

func _process(delta: float) -> void:
	if GameManager.is_game_over:
		return
		
	attack_cooldown -= delta
	var target = _find_closest_enemy()
	
	if target != null:
		var dir = (target.global_position - global_position).normalized()
		pivot.rotation = dir.angle()
		
		if attack_cooldown <= 0.0:
			_fire_arrow(dir)
			attack_cooldown = max(0.18, base_fire_rate / GameManager.attack_speed)

func _find_closest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest: Node2D = null
	var min_dist: float = GameManager.attack_range * 6.2
	
	for e in enemies:
		if is_instance_valid(e) and not e.is_queued_for_deletion():
			var dist = global_position.distance_to(e.global_position)
			if dist < min_dist:
				min_dist = dist
				closest = e
	return closest

func _fire_arrow(dir: Vector2) -> void:
	SoundManager.play_bow()
	
	var tween = create_tween()
	sprite.position.x = 10.0
	tween.tween_property(sprite, "position:x", 16.0, 0.1)
	
	var arrow = ARROW_SCENE.instantiate()
	arrow.global_position = muzzle.global_position
	arrow.velocity_dir = dir
	arrow.rotation = dir.angle()
	arrow.tier = tier
	
	var root_scene = get_tree().current_scene
	if is_instance_valid(root_scene):
		root_scene.call_deferred("add_child", arrow)
