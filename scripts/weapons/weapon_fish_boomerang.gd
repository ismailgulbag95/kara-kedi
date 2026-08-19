extends Node2D

## 3. Kılçık Bumerangı Silahı (Ranged Weapon)
## Tier seviyesine göre menzili ve hasarı artar.

@export var slot_index: int = 1
@export var tier: int = 1

var cooldown: float = 0.0
var base_rate: float = 1.3

@onready var sprite: Sprite2D = $Sprite2D

const FISH_PROJ_SCENE = preload("res://scenes/weapons/fish_projectile.tscn")

func _ready() -> void:
	if GameManager.TIER_COLORS.has(tier):
		sprite.modulate = GameManager.TIER_COLORS[tier]

func _process(delta: float) -> void:
	if GameManager.is_game_over:
		return
		
	cooldown -= delta
	if cooldown <= 0.0:
		var target = _find_target()
		if target != null:
			_throw_boomerang(target.global_position)
			cooldown = max(0.35, base_rate / (GameManager.attack_speed * (1.0 + (tier - 1) * 0.1)))

func _find_target() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest: Node2D = null
	var min_dist: float = 400.0 + (tier - 1) * 50.0
	
	for e in enemies:
		if is_instance_valid(e) and not e.is_queued_for_deletion():
			var dist = global_position.distance_to(e.global_position)
			if dist < min_dist:
				min_dist = dist
				closest = e
	return closest

func _throw_boomerang(target_pos: Vector2) -> void:
	var proj = FISH_PROJ_SCENE.instantiate()
	proj.global_position = global_position
	proj.direction = (target_pos - global_position).normalized()
	proj.damage = GameManager.base_damage * 0.95
	proj.tier = tier
	proj.max_distance = 300.0 + (tier - 1) * 40.0
	proj.target_player = owner if owner else get_parent()
	get_tree().current_scene.add_child(proj)
	SoundManager.play_slash()
