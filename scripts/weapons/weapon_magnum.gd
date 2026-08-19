extends Node2D

## Ağır Magnum Revolver Silahı
## Yüksek Hasar (45), Düşük Hız (1.1s bekleme), Yüksek Geri Tepme

@export var slot_index: int = 0
@export var tier: int = 1

@onready var pivot: Node2D = $Pivot
@onready var sprite: Sprite2D = $Pivot/Sprite2D
@onready var muzzle: Marker2D = $Pivot/Muzzle

var attack_cooldown: float = 0.0
var base_fire_rate: float = 1.1

const BULLET_SCENE = preload("res://scenes/weapons/magnum_bullet.tscn")

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
			_fire_magnum(dir)
			attack_cooldown = max(0.4, base_fire_rate / GameManager.attack_speed)

func _find_closest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest: Node2D = null
	var min_dist: float = GameManager.attack_range * 6.5
	
	for e in enemies:
		if is_instance_valid(e) and not e.is_queued_for_deletion():
			var dist = global_position.distance_to(e.global_position)
			if dist < min_dist:
				min_dist = dist
				closest = e
	return closest

func _fire_magnum(dir: Vector2) -> void:
	SoundManager.play_magnum()
	
	# Geri tepme animasyonu
	var tween = create_tween()
	sprite.position.x = 10.0
	tween.tween_property(sprite, "position:x", 18.0, 0.12)
	
	var bullet = BULLET_SCENE.instantiate()
	bullet.global_position = muzzle.global_position
	bullet.velocity_dir = dir
	bullet.rotation = dir.angle()
	bullet.tier = tier
	
	var root_scene = get_tree().current_scene
	if is_instance_valid(root_scene):
		root_scene.call_deferred("add_child", bullet)
