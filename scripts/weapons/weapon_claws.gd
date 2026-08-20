extends Node2D

## 2. Çift Pençe (Claws)
## Seri Yakın Dövüş, %25 Ekstra Kritik, Yalnızca Menzildeki En Yakın Düşmana Tekil Vuruş

@export var slot_index: int = 1
@export var tier: int = 1

@onready var pivot: Node2D = $Pivot
@onready var sprite: Sprite2D = $Pivot/Sprite2D
@onready var hitbox: Area2D = $Pivot/HitboxArea
@onready var hitbox_col: CollisionShape2D = $Pivot/HitboxArea/CollisionShape2D

var attack_cooldown: float = 0.0
var is_slashing: bool = false
var slash_progress: float = 0.0
var base_attack_duration: float = 0.12
var target_angle: float = 0.0

var hit_enemies_in_current_slash: Array[Node2D] = []

const CLAWS_MAX_REACH: float = 145.0

func _ready() -> void:
	hitbox.monitoring = true
	hitbox.monitorable = true
	hitbox_col.disabled = true
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	_apply_tier_visuals()

func _apply_tier_visuals() -> void:
	if GameManager.TIER_COLORS.has(tier):
		sprite.modulate = GameManager.TIER_COLORS[tier]
	var scale_mult = 1.0 + (tier - 1) * 0.15
	scale = Vector2(scale_mult, scale_mult)

func _process(delta: float) -> void:
	if GameManager.is_game_over:
		return
		
	var actual_rate = max(0.12, 0.45 / GameManager.attack_speed)
	
	if is_slashing:
		slash_progress += delta / (base_attack_duration / GameManager.attack_speed)
		var punch = sin(slash_progress * PI) * 14.0
		sprite.position.x = 22.0 + punch
		
		if slash_progress >= 1.0:
			is_slashing = false
			hitbox_col.disabled = true
			sprite.position.x = 22.0
			pivot.rotation = 0.0
			hit_enemies_in_current_slash.clear()
			attack_cooldown = actual_rate
	else:
		if attack_cooldown > 0.0:
			attack_cooldown -= delta
		else:
			var target = _find_closest_enemy_in_reach()
			if target != null:
				_perform_claw_swipe(target.global_position)

func _find_closest_enemy_in_reach() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest: Node2D = null
	var min_dist: float = CLAWS_MAX_REACH * (GameManager.attack_range / 100.0)
	
	for e in enemies:
		if is_instance_valid(e) and not e.get("is_dead") and not e.is_queued_for_deletion():
			var dist = global_position.distance_to(e.global_position)
			if dist <= min_dist:
				min_dist = dist
				closest = e
	return closest

func _perform_claw_swipe(target_pos: Vector2) -> void:
	is_slashing = true
	slash_progress = 0.0
	hit_enemies_in_current_slash.clear()
	
	target_angle = (target_pos - global_position).angle()
	pivot.rotation = target_angle
	hitbox_col.disabled = false
	SoundManager.play_slash()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if not is_slashing:
		return
		
	if area.is_in_group("enemy_hurtbox"):
		var enemy = area.get_parent()
		if is_instance_valid(enemy) and enemy.has_method("take_damage") and enemy not in hit_enemies_in_current_slash:
			hit_enemies_in_current_slash.append(enemy)
			var tier_mult = GameManager.TIER_MULTIPLIERS.get(tier, 1.0)
			var is_crit = randf() < (GameManager.crit_chance + 0.25 + (tier - 1) * 0.08)
			var dmg = (GameManager.base_damage * 0.7) * tier_mult * (GameManager.crit_multiplier if is_crit else 1.0)
			var knock_dir = (enemy.global_position - global_position).normalized()
			enemy.take_damage(dmg, knock_dir, 160.0, is_crit, "claws")
			SoundManager.play_hit()
