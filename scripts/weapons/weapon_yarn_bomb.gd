extends Node2D

## 4. İp Yumağı Bombası Silahı (Kuyruk / Alan Hasarı)
## Tier seviyesine göre patlama alanı ve hasarı katlanır.

@export var slot_index: int = 2
@export var tier: int = 1

var cooldown: float = 0.0
var base_rate: float = 2.2

@onready var sprite: Sprite2D = $Sprite2D

const YARN_PROJ_SCENE = preload("res://scenes/weapons/yarn_projectile.tscn")

func _ready() -> void:
	if GameManager.TIER_COLORS.has(tier):
		sprite.modulate = GameManager.TIER_COLORS[tier]

func _process(delta: float) -> void:
	if GameManager.is_game_over:
		return
		
	cooldown -= delta
	if cooldown <= 0.0:
		var target = _find_best_target()
		if target != null:
			_launch_yarn(target.global_position)
			cooldown = max(0.5, base_rate / (GameManager.attack_speed * (1.0 + (tier - 1) * 0.1)))

func _find_best_target() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest: Node2D = null
	var min_dist: float = 450.0 + (tier - 1) * 50.0
	
	for e in enemies:
		if is_instance_valid(e) and not e.is_queued_for_deletion():
			var dist = global_position.distance_to(e.global_position)
			if dist < min_dist:
				min_dist = dist
				closest = e
	return closest

func _launch_yarn(target_pos: Vector2) -> void:
	var proj = YARN_PROJ_SCENE.instantiate()
	proj.global_position = global_position
	proj.target_position = target_pos
	proj.damage = GameManager.base_damage * 1.5
	proj.tier = tier
	get_tree().current_scene.add_child(proj)
	SoundManager.play_slash()
