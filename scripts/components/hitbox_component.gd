class_name HitboxComponent
extends Area2D

## Saldırı ve Çarpışma Hasar İletim Bileşeni

@export var damage: float = 20.0
@export var knockback_force: float = 200.0

func _init() -> void:
	# Layer 3: player_hitbox or Layer 4: enemy_hitbox
	monitoring = true
	monitorable = true
