class_name BossRatKing
extends EnemyBase

## Zırhsız & Siyah Pelerinli Fare Kralı / İmparatoru Boss'u
## Dalga 5 (850 HP), Dalga 10 (1800 HP), Dalga 15 Mega-Boss (6000 HP - 3 Kat Daha Zor!)

signal boss_hp_updated(current: float, max_val: float)
signal boss_defeated

@export var boss_tier: int = 1 # 1: Dalga 5, 2: Dalga 10, 3: Dalga 15 Mega-Boss

var attack_timer: float = 3.5
var is_enraged: bool = false
var is_jumping: bool = false

const SHOCKWAVE_SCENE = preload("res://scenes/vfx/shockwave_fx.tscn")
const SMALL_RAT_SCENE = preload("res://scenes/enemies/rat_small.tscn")
const DASHER_RAT_SCENE = preload("res://scenes/enemies/rat_dasher.tscn")

func _ready() -> void:
	super._ready()
	add_to_group("boss")
	
	match boss_tier:
		1: # Dalga 5 Mini-Boss
			max_health = 850.0
			contact_damage = 22.0
			move_speed = 95.0
			base_coin_value = 16.0
			score_value = 2500
		2: # Dalga 10 Büyük-Boss
			max_health = 1800.0
			contact_damage = 32.0
			move_speed = 110.0
			base_coin_value = 32.0
			score_value = 5000
		3: # Dalga 15 Mega-Boss (Fare İmparatoru - 3 Kat Zor!)
			max_health = 6000.0
			contact_damage = 44.0
			move_speed = 135.0
			base_coin_value = 64.0
			score_value = 15000
			scale = Vector2(1.8, 1.8)
			
	current_health = max_health
	bonus_coin_chance = 1.0
	
	SoundManager.play_boss_roar()
	boss_hp_updated.emit(current_health, max_health)

func _physics_process(delta: float) -> void:
	if is_dead or GameManager.is_game_over:
		return
		
	# %50 Can Altı Öfkeli Hücum
	if not is_enraged and current_health <= (max_health * 0.5):
		is_enraged = true
		move_speed *= 1.35
		sprite.modulate = Color(2.5, 0.6, 0.6, 1.0)
		SoundManager.play_boss_roar()
		
	attack_timer -= delta
	if attack_timer <= 0.0 and not is_jumping:
		_choose_boss_attack()
		attack_timer = randf_range(2.8, 4.2) if not is_enraged else randf_range(1.6, 2.6)
		
	super._physics_process(delta)

func _choose_boss_attack() -> void:
	var roll = randf()
	if roll < 0.60:
		_perform_slam_shockwave()
	else:
		_perform_minion_roar()

func _perform_slam_shockwave() -> void:
	is_jumping = true
	var orig_speed = move_speed
	move_speed = 0.0
	
	var tween = create_tween()
	tween.tween_property(sprite, "position:y", -45.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "position:y", 0.0, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	await tween.finished
	is_jumping = false
	move_speed = orig_speed
	
	SoundManager.play_bomb_boom()
	
	# Şok Dalgası (Mega Boss çift dalga atar)
	var waves_count = 2 if boss_tier == 3 else 1
	for w in range(waves_count):
		var shock = SHOCKWAVE_SCENE.instantiate()
		shock.global_position = global_position
		shock.max_scale = 4.8 + float(w) * 1.5
		shock.is_enemy_attack = true
		shock.damage = 22.0 + float(boss_tier * 6)
		
		var root_scene = get_tree().current_scene
		if is_instance_valid(root_scene):
			root_scene.add_child(shock)
			
	GameManager.request_screen_shake(0.75)
	GameManager.hitstop(0.06, 0.05)


func _perform_minion_roar() -> void:
	SoundManager.play_boss_roar()
	
	var root_scene = get_tree().current_scene
	if is_instance_valid(root_scene):
		var spawn_count = 6 if boss_tier == 3 else 4
		for i in range(spawn_count):
			var minion_scene = DASHER_RAT_SCENE if (boss_tier == 3 and i % 2 == 0) else SMALL_RAT_SCENE
			var minion = minion_scene.instantiate()
			var offset = Vector2(randf_range(-80, 80), randf_range(-80, 80))
			minion.global_position = global_position + offset
			root_scene.call_deferred("add_child", minion)

func take_damage(amount: float, knockback_dir: Vector2 = Vector2.ZERO, knock_force: float = 0.0, is_crit: bool = false, source_weapon: String = "") -> void:
	super.take_damage(amount, knockback_dir, knock_force * 0.15, is_crit, source_weapon)
	boss_hp_updated.emit(max(0.0, current_health), max_health)

func _die() -> void:
	boss_hp_updated.emit(0.0, max_health)
	boss_defeated.emit()
	super._die()
