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
	add_to_group("wave_manager")
	GameManager.wave_started.connect(_on_wave_started)

func _on_wave_started(wave_num: int) -> void:
	if wave_num == 5 or wave_num == 10 or wave_num == 15:
		wave_time_left = 38.0
	else:
		wave_time_left = 22.0 + float(wave_num - 1) * 2.0
		
	spawn_interval = max(0.22, 0.65 - float(wave_num - 1) * 0.03)
	spawn_timer = 0.3
	crate_spawn_timer = 5.0 # Dalga başladıktan 5 sn sonra ilk sandık düşer
	is_elite_spawned = false
	active_boss_node = null
	GameManager.is_wave_active = true
	SoundManager.play_wave_horn()
	_find_player()
	_setup_wave_props_and_nests(wave_num)

func spawn_rat_from_nest(nest_pos: Vector2) -> void:
	if small_rat_scene:
		var rat = small_rat_scene.instantiate()
		var offset = Vector2(randf_range(-25.0, 25.0), randf_range(-25.0, 25.0))
		rat.global_position = nest_pos + offset
		get_parent().add_child(rat)

func _setup_wave_props_and_nests(wave_num: int) -> void:
	# Önceki dalgadan kalan kapakları ve etkileşimli nesneleri temizle
	for n in get_tree().get_nodes_in_group("enemy_nests"):
		n.queue_free()
	for p in get_tree().get_nodes_in_group("interactive_props"):
		p.queue_free()
		
	# Dalga numarasına göre dinamik lağım kapağı sayısı (Wave 1-2: 2, Wave 3-5: 3, Wave 6-9: 4, Wave 10+: 5)
	var grate_count: int = 2
	if wave_num >= 10:
		grate_count = 5
	elif wave_num >= 6:
		grate_count = 4
	elif wave_num >= 3:
		grate_count = 3
		
	var nest_sc = load("res://scenes/props/rat_nest_spawner.tscn")
	if nest_sc:
		var spawned_positions: Array[Vector2] = []
		for i in range(grate_count):
			var pos = Vector2.ZERO
			var attempts = 0
			while attempts < 15:
				pos = Vector2(randf_range(ARENA_MIN_X + 90, ARENA_MAX_X - 90), randf_range(ARENA_MIN_Y + 120, ARENA_MAX_Y - 120))
				var too_close = false
				for other_pos in spawned_positions:
					if pos.distance_to(other_pos) < 180.0:
						too_close = true
						break
				if not too_close:
					break
				attempts += 1
			spawned_positions.append(pos)
			
			var nest = nest_sc.instantiate()
			nest.global_position = pos
			get_parent().call_deferred("add_child", nest)
			
	# Spawn 2 Patlayıcı Gaz / Yangın Tüpü (Kırılabilir/Patlayabilir)
	var tank_sc = load("res://scenes/props/explosive_gas_tank.tscn")
	if tank_sc:
		for i in range(2):
			var tank = tank_sc.instantiate()
			tank.global_position = Vector2(randf_range(-380, 380), randf_range(-600, 600))
			get_parent().call_deferred("add_child", tank)
			
	# Spawn Stray Cat Ally companion on wave 3+
	if wave_num >= 3 and get_tree().get_nodes_in_group("allies").size() == 0:
		var cat_sc = load("res://scenes/allies/stray_cat_ally.tscn")
		if cat_sc and target_player:
			var cat = cat_sc.instantiate()
			cat.global_position = target_player.global_position + Vector2(50, 50)
			get_parent().add_child(cat)

func _find_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target_player = players[0]

func _process(delta: float) -> void:
	if not GameManager.is_wave_active or GameManager.is_game_over:
		return
		
	wave_time_left -= delta
	time_updated.emit(max(0.0, wave_time_left))
	
	# Dinamik Hediye Sandığı Doğuşu (Her 10-15 sn'de bir yeni sandık)
	crate_spawn_timer -= delta
	if crate_spawn_timer <= 0.0:
		_spawn_loot_crate()
		crate_spawn_timer = randf_range(10.0, 15.0)
	
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
		if is_instance_valid(active_boss_node) and not active_boss_node.get("is_dead"):
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
	if existing_crates.size() >= 3:
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
