class_name HealthComponent
extends Node2D

## Can ve Hasar Yönetim Bileşeni

signal health_changed(current: float, max: float)
signal damage_taken(amount: float, knockback_dir: Vector2, knockback_force: float)
signal died

@export var max_health: float = 30.0
var current_health: float = 30.0
var is_invulnerable: bool = false
var invulnerability_timer: float = 0.0

func _ready() -> void:
	current_health = max_health

func _process(delta: float) -> void:
	if is_invulnerable:
		invulnerability_timer -= delta
		if invulnerability_timer <= 0.0:
			is_invulnerable = false

func take_damage(amount: float, knockback_dir: Vector2 = Vector2.ZERO, knockback_force: float = 0.0, i_frame_time: float = 0.0) -> bool:
	if is_invulnerable or current_health <= 0.0:
		return false
		
	current_health = max(0.0, current_health - amount)
	health_changed.emit(current_health, max_health)
	damage_taken.emit(amount, knockback_dir, knockback_force)
	
	if i_frame_time > 0.0:
		is_invulnerable = true
		invulnerability_timer = i_frame_time
		
	if current_health <= 0.0:
		died.emit()
		
	return true

func heal(amount: float) -> void:
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)
