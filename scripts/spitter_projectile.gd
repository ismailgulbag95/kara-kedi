extends Area2D

## Tüküren Farenin Asit Mermisi

var speed: float = 240.0
var direction: Vector2 = Vector2.ZERO
var damage: float = 14.0
var lifetime: float = 4.0

func _ready() -> void:
	add_to_group("enemy_hitbox")
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		var player = area.get_parent()
		if player and player.has_method("take_damage"):
			player.take_damage(damage, direction, 120.0)
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage, direction, 120.0)
		queue_free()
