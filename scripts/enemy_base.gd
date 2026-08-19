class_name EnemyBase
extends CharacterBody2D

## Düşman Fare Temel Sınıfı (Enemy Base)
## Her düşman türü kendi taban koinini (Base) düşürür; ek koin ise (Base / 2) değerinde ve %50 boyuttadır.

@export var max_health: float = 25.0
@export var move_speed: float = 140.0
@export var contact_damage: float = 12.0
@export var base_coin_value: float = 1.0 # Düşmanın ana koin değeri
@export var bonus_coin_chance: float = 0.50 # Ek küçük koin düşme şansı
@export var score_value: int = 100

var current_health: float = 25.0
var target_player: Node2D = null
var knockback_velocity: Vector2 = Vector2.ZERO
var is_dead: bool = false
var wobble_time: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var hurtbox_col: CollisionShape2D = $HurtboxArea/CollisionShape2D

const COIN_SCENE = preload("res://scenes/coin.tscn")
const DEATH_PARTICLES_SCENE = preload("res://scenes/vfx/death_particles.tscn")
const FLOATING_TEXT_SCENE = preload("res://scenes/vfx/floating_text.tscn")

func _ready() -> void:
	add_to_group("enemies")
	current_health = max_health
	wobble_time = randf() * 10.0
	_find_player()

func _find_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target_player = players[0]

func _physics_process(delta: float) -> void:
	if is_dead or GameManager.is_game_over:
		return
		
	if not is_instance_valid(target_player):
		_find_player()
		return

	var to_player = (target_player.global_position - global_position).normalized()
	var separation = _calculate_separation()
	var final_direction = (to_player * 0.75 + separation * 0.25).normalized()
	
	velocity = final_direction * move_speed
	
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0
		
	wobble_time += delta * 12.0
	sprite.rotation = sin(wobble_time) * 0.1
	
	if knockback_velocity.length() > 5.0:
		velocity += knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, delta * 1000.0)

	move_and_slide()

func _calculate_separation() -> Vector2:
	var separation = Vector2.ZERO
	var nearby_enemies = get_tree().get_nodes_in_group("enemies")
	for other in nearby_enemies:
		if other != self and is_instance_valid(other) and not other.is_dead:
			var diff = global_position - other.global_position
			var dist = diff.length()
			if dist < 28.0 and dist > 0.0:
				separation += diff.normalized() / dist
	return separation.normalized()

func take_damage(amount: float, knockback_dir: Vector2, knock_force: float, is_crit: bool = false) -> void:
	if is_dead:
		return
		
	current_health -= amount
	knockback_velocity = knockback_dir * knock_force
	
	# Kritik Hasar Metni (Floating Text)
	if is_crit:
		_spawn_floating_text("CRIT! " + str(int(amount)), Color(1.0, 0.85, 0.2), 16)
	
	var tween = create_tween()
	sprite.modulate = Color(3.0, 1.0, 1.0, 1.0)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)
	
	if current_health <= 0.0:
		_die()

func _spawn_floating_text(txt: String, col: Color, size: int) -> void:
	var ftext = FLOATING_TEXT_SCENE.instantiate()
	ftext.global_position = global_position + Vector2(0, -16)
	var root_scene = get_tree().current_scene
	if is_instance_valid(root_scene):
		root_scene.call_deferred("add_child", ftext)
		ftext.call_deferred("setup", txt, col, size)

func _die() -> void:
	if is_dead:
		return
	is_dead = true
	set_physics_process(false)
	
	if is_instance_valid(hurtbox_col):
		hurtbox_col.set_deferred("disabled", true)
		
	GameManager.enemies_killed += 1
	GameManager.score += score_value
	
	# Ölüm Partikülleri (Death Sparks)
	var particles = DEATH_PARTICLES_SCENE.instantiate()
	particles.global_position = global_position
	var root_scene = get_tree().current_scene
	if is_instance_valid(root_scene):
		root_scene.call_deferred("add_child", particles)
		
		# 1. Her Düşmandan GARANTİ Ana Koin (Base Değerinde, Tam Boyut)
		var normal_coin = COIN_SCENE.instantiate()
		normal_coin.global_position = global_position
		normal_coin.is_small_coin = false
		normal_coin.coin_value = base_coin_value
		root_scene.call_deferred("add_child", normal_coin)
			
		# 2. Şansa Bağlı EK KÜÇÜK Bonus Koin (Base / 2 Değerinde, %50 Boyut)
		if randf() <= bonus_coin_chance:
			var bonus_coin = COIN_SCENE.instantiate()
			bonus_coin.global_position = global_position + Vector2(randf_range(-12, 12), randf_range(-12, 12))
			bonus_coin.is_small_coin = true
			bonus_coin.coin_value = base_coin_value / 2.0
			root_scene.call_deferred("add_child", bonus_coin)
		
	var tween = create_tween().set_parallel(true)
	tween.tween_property(sprite, "scale", Vector2.ZERO, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.2)
	tween.chain().tween_callback(queue_free)
