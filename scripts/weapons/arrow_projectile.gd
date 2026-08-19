extends Area2D

## Avcı Yayı Keskin Oku
## Delip Geçme (Pierce 2), 24 Taban Hasar, Dengeli Hız

@export var speed: float = 720.0
@export var damage: float = 24.0
@export var tier: int = 1
@export var max_pierce: int = 2

var velocity_dir: Vector2 = Vector2.RIGHT
var pierce_count: int = 0
var hit_enemies: Array[Node2D] = []

func _ready() -> void:
	var timer = get_tree().create_timer(1.6)
	timer.timeout.connect(queue_free)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	global_position += velocity_dir * speed * delta

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hurtbox"):
		var enemy = area.get_parent()
		if enemy and enemy not in hit_enemies and enemy.has_method("take_damage"):
			hit_enemies.append(enemy)
			var tier_mult = GameManager.TIER_MULTIPLIERS.get(tier, 1.0)
			var is_crit = randf() < (GameManager.crit_chance + 0.08)
			var dmg = damage * tier_mult * (GameManager.crit_multiplier if is_crit else 1.0)
			enemy.take_damage(dmg, velocity_dir, 200.0 * tier_mult, is_crit)
			SoundManager.play_hit()
			
			pierce_count += 1
			if pierce_count >= max_pierce + (tier - 1):
				queue_free()
