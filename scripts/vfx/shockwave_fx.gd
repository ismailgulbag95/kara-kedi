extends Area2D

## Genişleyen Şok Dalgası Efekti (Boss Saldırısı veya Bomba Şoku)

@export var max_scale: float = 3.8
@export var duration: float = 0.45
@export var is_enemy_attack: bool = false
@export var damage: float = 18.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var col_shape: CollisionShape2D = $CollisionShape2D

var hit_targets: Array[Node2D] = []

func _ready() -> void:
	scale = Vector2(0.2, 0.2)
	monitoring = is_enemy_attack
	if is_enemy_attack:
		add_to_group("enemy_hitbox")
		area_entered.connect(_on_area_entered)
		
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(max_scale, max_scale), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "modulate:a", 0.0, duration)
	tween.chain().tween_callback(queue_free)

func _on_area_entered(area: Area2D) -> void:
	if is_enemy_attack and area.is_in_group("player_hurtbox"):
		var player = area.get_parent()
		if player and player not in hit_targets and player.has_method("take_damage"):
			hit_targets.append(player)
			var knock_dir = (player.global_position - global_position).normalized()
			player.take_damage(damage, knock_dir, 350.0)
