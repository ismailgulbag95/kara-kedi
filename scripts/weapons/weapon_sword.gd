extends Node2D

## 1. Kara Çelik Kılıç (Melee Sword)
## Tekil Odaklı Hedefleme (En Yakın Düşmana Tek Sefer Vuruş), 120° Yay ve Menzil Kontrolü

@export var slot_index: int = 0
@export var tier: int = 1

@onready var pivot: Node2D = $Pivot
@onready var hitbox: Area2D = $Pivot/HitboxArea
@onready var hitbox_col: CollisionShape2D = $Pivot/HitboxArea/CollisionShape2D

var attack_cooldown: float = 0.0
var is_slashing: bool = false
var slash_progress: float = 0.0
var base_attack_duration: float = 0.16
var target_angle: float = 0.0

# Savurma başına her düşmana yalnızca 1 kez hasar verme listesi
var hit_enemies_in_current_slash: Array[Node2D] = []

const ARC_SPAN: float = 2.2 # 120 Derece
const SLASH_ARC_SCENE = preload("res://scenes/vfx/slash_arc_fx.tscn")

# Yakın Dövüş Vuruş Menzili (Düşman bu mesafenin içinde değilse ASLA boşa savurmaz)
const SWORD_MAX_REACH: float = 160.0

func _ready() -> void:
	hitbox.monitoring = true
	hitbox.monitorable = true
	hitbox_col.disabled = true
	hitbox.area_entered.connect(_on_hitbox_area_entered)

func _process(delta: float) -> void:
	if GameManager.is_game_over:
		return
		
	var actual_rate = max(0.22, 1.0 / GameManager.attack_speed)
	
	if is_slashing:
		slash_progress += delta / (base_attack_duration / GameManager.attack_speed)
		var current_arc = lerp(-ARC_SPAN * 0.5, ARC_SPAN * 0.5, ease_slash(slash_progress))
		pivot.rotation = target_angle + current_arc
		
		if slash_progress >= 1.0:
			is_slashing = false
			hitbox_col.disabled = true
			pivot.rotation = 0.0
			hit_enemies_in_current_slash.clear()
			attack_cooldown = actual_rate
	else:
		if attack_cooldown > 0.0:
			attack_cooldown -= delta
		else:
			# Menzildeki EN YAKIN tekil düşmanı bul
			var target = _find_closest_enemy_in_reach()
			if target != null:
				_perform_slash(target.global_position)

func ease_slash(t: float) -> float:
	return 1.0 - pow(1.0 - t, 3.0)

func _find_closest_enemy_in_reach() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest: Node2D = null
	var min_dist: float = SWORD_MAX_REACH * (GameManager.attack_range / 100.0)
	
	for e in enemies:
		if is_instance_valid(e) and not e.get("is_dead") and not e.is_queued_for_deletion():
			var dist = global_position.distance_to(e.global_position)
			if dist <= min_dist:
				min_dist = dist
				closest = e
	return closest

func _perform_slash(target_pos: Vector2) -> void:
	is_slashing = true
	slash_progress = 0.0
	hit_enemies_in_current_slash.clear()
	
	target_angle = (target_pos - global_position).angle()
	pivot.rotation = target_angle - ARC_SPAN * 0.5
	hitbox_col.disabled = false
	SoundManager.play_slash()
	
	# Büyütülmüş Kesme İzi Görseli (Slash Arc VFX)
	var slash_vfx = SLASH_ARC_SCENE.instantiate()
	slash_vfx.global_position = global_position + Vector2.RIGHT.rotated(target_angle) * 38.0
	slash_vfx.rotation = target_angle
	slash_vfx.scale = Vector2(2.0, 2.0)
	
	if GameManager.TIER_COLORS.has(tier):
		slash_vfx.modulate = GameManager.TIER_COLORS[tier]
		
	var root_scene = get_tree().current_scene
	if is_instance_valid(root_scene):
		root_scene.call_deferred("add_child", slash_vfx)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if not is_slashing:
		return
		
	if area.is_in_group("enemy_hurtbox"):
		var enemy = area.get_parent()
		if is_instance_valid(enemy) and enemy.has_method("take_damage") and enemy not in hit_enemies_in_current_slash:
			hit_enemies_in_current_slash.append(enemy)
			var tier_mult = GameManager.TIER_MULTIPLIERS.get(tier, 1.0)
			var is_crit = randf() < (GameManager.crit_chance + (tier - 1) * 0.05)
			var dmg = (GameManager.base_damage + 8.0) * tier_mult * (GameManager.crit_multiplier if is_crit else 1.0)
			var knock_dir = (enemy.global_position - global_position).normalized()
			enemy.take_damage(dmg, knock_dir, 320.0 * tier_mult, is_crit)
			SoundManager.play_hit()
