extends Area2D

## Fırlatılan Kılçık Bumerangı Mermisi (Tier Destekli)

var target_player: Node2D = null
var direction: Vector2 = Vector2.RIGHT
var speed: float = 480.0
var max_distance: float = 300.0
var distance_traveled: float = 0.0
var is_returning: bool = false
var damage: float = 22.0
var tier: int = 1
var hit_enemies: Array[Node2D] = []

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("player_hitbox")
	area_entered.connect(_on_area_entered)
	if GameManager.TIER_COLORS.has(tier):
		sprite.modulate = GameManager.TIER_COLORS[tier]
	var s = 1.0 + (tier - 1) * 0.2
	scale = Vector2(s, s)

func _physics_process(delta: float) -> void:
	sprite.rotation += delta * 18.0
	
	if not is_returning:
		position += direction * speed * delta
		distance_traveled += speed * delta
		if distance_traveled >= max_distance:
			is_returning = true
			hit_enemies.clear()
	else:
		if is_instance_valid(target_player):
			var to_player = (target_player.global_position - global_position).normalized()
			position += to_player * (speed * 1.25) * delta
			if global_position.distance_to(target_player.global_position) < 25.0:
				queue_free()
		else:
			queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hurtbox"):
		var enemy = area.get_parent()
		if enemy and enemy not in hit_enemies and enemy.has_method("take_damage"):
			hit_enemies.append(enemy)
			var tier_mult = GameManager.TIER_MULTIPLIERS.get(tier, 1.0)
			var is_crit = randf() < GameManager.crit_chance
			var dmg = damage * tier_mult * (GameManager.crit_multiplier if is_crit else 1.0)
			var knock_dir = (enemy.global_position - global_position).normalized()
			enemy.take_damage(dmg, knock_dir, 160.0, is_crit)
			SoundManager.play_hit()
