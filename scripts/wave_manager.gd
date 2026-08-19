extends Node2D

## Dalga ve Düşman Doğma Yöneticisi (Wave Manager)
## 15 Dalga Toplam, Dalga 5 (Mini), 10 (Büyük), 15 (Mega-Boss), Dalga Sonu Tam Mermi/Düşman Temizliği

signal wave_time_updated(time_left: float)
signal time_updated(seconds_left: float)
signal boss_spawned(boss_node: Node2D)

@export var small_rat_scene: PackedScene = preload("res://scenes/enemies/rat_small.tscn")
@export var tank_rat_scene: PackedScene = preload("res://scenes/enemies/rat_tank.tscn")
@export var spitter_rat_scene: PackedScene = preload("res://scenes/enemies/rat_spitter.tscn")
@export var dasher_rat_scene: PackedScene = preload("res://scenes/enemies/rat_dasher.tscn")
@export var boss_rat_king_scene: PackedScene = preload("res://scenes/enemies/boss_rat_king.tscn")
const LOOT_CRATE_SCENE = preload("res://scenes/props/loot_crate.tscn")

var wave_time_left: float = 0.0
var spawn_timer: float = 0.0
var spawn_interval: float = 1.0
var crate_spawn_timer: float = 10.0
var target_player: Node2D = null
var is_elite_spawned: bool = false
var active_boss_node: Node2D = null

# Arena İç Sınırları
const ARENA_MIN_X: float = -620.0
const ARENA_MAX_X: float = 620.0
const ARENA_MIN_Y: float = -950.0
const ARENA_MAX_Y: float = 950.0

func _ready() -> void:
	GameManager.wave_started.connect(_on_wave_started)

func _on_wave_started(wave_num: int) -> void:
	if wave_num == 5 or wave_num == 10 or wave_num == 15:
		wave_time_left = 38.0
	else:
		wave_time_left = 22.0 + float(wave_num - 1) * 2.0
		
	spawn_interval = max(0.22, 0.65 - float(wave_num - 1) * 0.03)
	spawn_timer = 0.3
	crate_spawn_timer = randf_range(7.0, 12.0)
	is_elite_spawned = false
	active_boss_node = null
	GameManager.is_wave_active = true
	SoundManager.play_wave_horn()
	_find_player()

func _find_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target_player = players[0]

func _process(delta: float) -> void:
	if not GameManager.is_wave_active or GameManager.is_game_over:
		return
		
	wave_time_left -= delta
	time_updated.emit(max(0.0, wave_time_left))
	
	# Dinamik Hediye Sandığı Doğuşu
	crate_spawn_timer -= delta
	if crate_spawn_timer <= 0.0:
		_spawn_loot_crate()
		crate_spawn_timer = randf_range(16.0, 24.0)
	
	# Boss Doğuşu (Dalga 5, 10 & 15)
	if (GameManager.current_wave == 5 or GameManager.current_wave == 10 or GameManager.current_wave == 15) and not is_elite_spawned and wave_time_left <= 35.0:
		var tier = 1
		if GameManager.current_wave == 10:
			tier = 2
		elif GameManager.current_wave == 15:
			tier = 3
		_spawn_rat_king_boss(tier)
		
	# Dalga Sonu Kontrolü: Boss hayattaysa süre bitse bile dalga bitmez!
	if wave_time_left <= 0.0:
		if is_instance_valid(active_boss_node) and not active_boss_node.is_dead:
			pass # Boss ölene kadar bekle
		else:
			_end_wave()
			return
		
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		_spawn_wave_enemy()
		spawn_timer = spawn_interval

func _spawn_loot_crate() -> void:
	var existing_crates = get_tree().get_nodes_in_group("crates")
	if existing_crates.size() >= 2:
		return
	if LOOT_CRATE_SCENE:
		var crate = LOOT_CRATE_SCENE.instantiate()
		var rx = randf_range(ARENA_MIN_X + 60.0, ARENA_MAX_X - 60.0)
		var ry = randf_range(ARENA_MIN_Y + 60.0, ARENA_MAX_Y - 60.0)
		crate.global_position = Vector2(rx, ry)
		get_parent().add_child(crate)


func _spawn_wave_enemy() -> void:
	if not is_instance_valid(target_player):
		_find_player()
		if not is_instance_valid(target_player):
			return
			
	var wave = GameManager.current_wave
	var enemy_scene: PackedScene = small_rat_scene
	var roll = randf()
	
	if wave == 1:
		enemy_scene = small_rat_scene
	elif wave == 2:
		enemy_scene = small_rat_scene if roll < 0.70 else dasher_rat_scene
	elif wave <= 4:
		if roll < 0.50:
			enemy_scene = small_rat_scene
		elif roll < 0.80:
			enemy_scene = dasher_rat_scene
		else:
			enemy_scene = spitter_rat_scene
	elif wave <= 7:
		if roll < 0.35:
			enemy_scene = small_rat_scene
		elif roll < 0.65:
			enemy_scene = dasher_rat_scene
		elif roll < 0.85:
			enemy_scene = spitter_rat_scene
		else:
			enemy_scene = tank_rat_scene
	else:
		if roll < 0.25:
			enemy_scene = small_rat_scene
		elif roll < 0.55:
			enemy_scene = dasher_rat_scene
		elif roll < 0.78:
			enemy_scene = spitter_rat_scene
		else:
			enemy_scene = tank_rat_scene
			
	var enemy = enemy_scene.instantiate()
	enemy.global_position = _get_spawn_position()
	
	var hp_mult = 1.0 + float(wave - 1) * 0.18
	var dmg_mult = 1.0 + float(wave - 1) * 0.08
	enemy.max_health = enemy.max_health * hp_mult
	enemy.contact_damage = enemy.contact_damage * dmg_mult
	
	get_parent().add_child(enemy)

func _get_spawn_position() -> Vector2:
	var side = randi() % 4
	var spawn_pos = Vector2.ZERO
	
	match side:
		0:
			spawn_pos = Vector2(randf_range(ARENA_MIN_X + 40.0, ARENA_MAX_X - 40.0), ARENA_MIN_Y + 50.0)
		1:
			spawn_pos = Vector2(randf_range(ARENA_MIN_X + 40.0, ARENA_MAX_X - 40.0), ARENA_MAX_Y - 50.0)
		2:
			spawn_pos = Vector2(ARENA_MIN_X + 50.0, randf_range(ARENA_MIN_Y + 40.0, ARENA_MAX_Y - 40.0))
		3:
			spawn_pos = Vector2(ARENA_MAX_X - 50.0, randf_range(ARENA_MIN_Y + 40.0, ARENA_MAX_Y - 40.0))
			
	return spawn_pos

func _spawn_rat_king_boss(tier: int) -> void:
	is_elite_spawned = true
	var boss = boss_rat_king_scene.instantiate()
	boss.boss_tier = tier
	boss.global_position = _get_spawn_position()
	active_boss_node = boss
	
	boss.boss_defeated.connect(_on_boss_defeated)
	get_parent().add_child(boss)
	boss_spawned.emit(boss)

func _on_boss_defeated() -> void:
	active_boss_node = null
	var timer = get_tree().create_timer(1.2)
	timer.timeout.connect(func():
		if GameManager.is_wave_active and not GameManager.is_game_over:
			_end_wave()
	)

func _end_wave() -> void:
	GameManager.is_wave_active = false
	
	# 1. Sahada kalan tüm düşmanları temizle
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if is_instance_valid(e):
			e.queue_free()
			
	# 2. Sahada kalan tüm koinleri temizle
	var coins = get_tree().get_nodes_in_group("collectibles")
	for c in coins:
		if is_instance_valid(c):
			c.queue_free()
			
	# 3. Sahada kalan TÜM düşman mermilerini & atışlarını temizle (yeni wave'e sarkmaz!)
	var projectiles = get_tree().get_nodes_in_group("enemy_hitbox")
	for p in projectiles:
		if is_instance_valid(p):
			p.queue_free()
			
	var shocks = get_tree().get_nodes_in_group("vfx")
	for s in shocks:
		if is_instance_valid(s):
			s.queue_free()
			
	# Dalga 15 Tamamlandığında Zafer Ekranı
	if GameManager.current_wave >= 15:
		GameManager.trigger_victory()
	else:
		GameManager.process_wave_completion_rewards()
		GameManager.wave_completed.emit(GameManager.current_wave)
