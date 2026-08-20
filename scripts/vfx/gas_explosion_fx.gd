extends Area2D

## Detaylı Gaz / Yangın Tüpü Patlaması Efekti
## Çok katmanlı alev, duman, şok dalgası ve hasar alanı.

@export var explosion_damage: float = 120.0
@export var player_damage: float = 12.0
@export var explosion_radius: float = 160.0
@export var knockback_force: float = 450.0

@onready var fire_particles: CPUParticles2D = $FireParticles
@onready var smoke_particles: CPUParticles2D = $SmokeParticles
@onready var shock_ring: Sprite2D = $ShockRing
@onready var fireball: Sprite2D = $Fireball

var hit_entities: Array[Node2D] = []

func _ready() -> void:
	# Ekran sarsıntısı ve ses
	GameManager.request_screen_shake(0.32)
	SoundManager.play_explosion()
	
	# Parçacıkları patlat
	if fire_particles:
		fire_particles.emitting = true
	if smoke_particles:
		smoke_particles.emitting = true
		
	# Alev topu genişleme ve sönme animasyonu
	if fireball:
		fireball.scale = Vector2(0.3, 0.3)
		fireball.modulate = Color(2.5, 2.0, 0.8, 1.0)
		var tw = create_tween().set_parallel(true)
		tw.tween_property(fireball, "scale", Vector2(3.6, 3.6), 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(fireball, "modulate:a", 0.0, 0.35).set_ease(Tween.EASE_IN)
		
	# Şok dalgası çemberi
	if shock_ring:
		shock_ring.scale = Vector2(0.2, 0.2)
		shock_ring.modulate = Color(1.0, 0.5, 0.1, 0.9)
		var tw2 = create_tween().set_parallel(true)
		tw2.tween_property(shock_ring, "scale", Vector2(4.2, 4.2), 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw2.tween_property(shock_ring, "modulate:a", 0.0, 0.30)

	# Hasar alanını tara (tek seferlik ani darbe)
	_apply_explosion_damage()
	
	# 0.8 saniye sonra sahneden temizle
	get_tree().create_timer(0.85).timeout.connect(queue_free)

func _apply_explosion_damage() -> void:
	# 1. Düşmanlara Hasar
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if is_instance_valid(e) and e not in hit_entities:
			var dist = global_position.distance_to(e.global_position)
			if dist <= explosion_radius:
				hit_entities.append(e)
				var knock_dir = (e.global_position - global_position).normalized()
				if knock_dir == Vector2.ZERO:
					knock_dir = Vector2.RIGHT
				if e.has_method("take_damage"):
					e.take_damage(explosion_damage, knock_dir, knockback_force, true)
					
	# 2. Oyuncuya Risk / Ödül Hasarı (Kedimiz patlamanın çok yakınındaysa)
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		if is_instance_valid(p):
			var dist = global_position.distance_to(p.global_position)
			if dist <= (explosion_radius * 0.65):
				var knock_dir = (p.global_position - global_position).normalized()
				if knock_dir == Vector2.ZERO:
					knock_dir = Vector2.DOWN
				if p.has_method("take_damage"):
					p.take_damage(player_damage, knock_dir, 240.0)
