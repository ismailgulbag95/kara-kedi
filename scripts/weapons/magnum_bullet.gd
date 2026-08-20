extends Area2D

## Magnum Ağır Mermisi
## Yüksek hız, 45 taban hasar, yüksek geri tepme

@export var speed: float = 780.0
@export var damage: float = 45.0
@export var tier: int = 1

var velocity_dir: Vector2 = Vector2.RIGHT

func _ready() -> void:
	var timer = get_tree().create_timer(1.4)
	timer.timeout.connect(queue_free)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	global_position += velocity_dir * speed * delta

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hurtbox"):
		var enemy = area.get_parent()
		if enemy and enemy.has_method("take_damage"):
			var tier_mult = GameManager.TIER_MULTIPLIERS.get(tier, 1.0)
			var is_crit = randf() < (GameManager.crit_chance + 0.15)
			var dmg = damage * tier_mult * (GameManager.crit_multiplier if is_crit else 1.0)
			enemy.take_damage(dmg, velocity_dir, 380.0 * tier_mult, is_crit, "magnum")
			SoundManager.play_hit()
			queue_free()
