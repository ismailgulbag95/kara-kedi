extends Node

## Oyun Durumu, Karakter Statları ve Build Mekaniği (Singleton)
## Tank (Zırh, Can, Regen, Thorns), Atak (Hasar, Menzil, Kritik), Çevik (Hız, Saldırı Hızı) ve Ekonomi

signal health_changed(current_hp: float, max_hp: float)
signal coins_changed(total_coins: int)
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal game_over_triggered
signal victory_triggered
signal player_stat_updated(stat_name: String, value: float)
signal weapons_updated
signal screen_shake_requested(trauma_amount: float)
signal death_defiance_triggered(remaining_lives: int)
signal chromatic_aberration_requested(strength: float, duration: float)
signal feline_rage_changed(current_rage: float, max_rage: float)
signal feline_rage_state_changed(is_active: bool)
signal character_unlocked(char_id: String)
signal quest_progress_updated(quest_type: String, current_val: int, target_val: int)

var unlocked_characters: Array = ["standard"]
var quest_progress: Dictionary = {
	"magnum_kills": 0,
	"claws_kills": 0,
	"milk_collected": 0,
	"total_coins": 0
}

var lives_remaining: int = 1
var feline_rage: float = 0.0
var max_feline_rage: float = 100.0
var is_feline_rage_active: bool = false


# Karakter Temel ve Güncel Statları
var max_hp: float = 100.0
var current_hp: float = 100.0
var move_speed: float = 220.0
var base_damage: float = 22.0
var damage_multiplier: float = 1.0
var attack_speed: float = 1.0
var attack_range: float = 80.0
var magnet_radius: float = 130.0
var armor: float = 0.0
var crit_chance: float = 0.05
var crit_multiplier: float = 2.0

# Yeni Stratejik Pasif Özellikler
var hp_regen: float = 0.0        # Saniye başına can yenileme
var thorns_damage: float = 0.0   # Hasar alındığında geri yansıtılan alan hasarı
var piggy_bank_count: int = 0    # Dalga sonu faiz veren kumbara sayısı

# 3 Silah Yuvası: [0 = Sağ El, 1 = Sol El, 2 = Kuyruk]
var equipped_weapons: Array = [
	{"id": "sword", "name": "Kara Çelik Kılıç", "tier": 1, "type": "weapon", "cost": 10},
	null,
	null
]

# Kilitli Market Kartları (Freeze/Lock)
var locked_shop_cards: Array = []

# Ekonomi, Skor ve En Yüksek Skor (High Score)
var coins: int = 0
var total_coins_collected: int = 0
var score: int = 0
var high_score: int = 0
var enemies_killed: int = 0

# Dalga (Wave) Durumu
var current_wave: int = 1
var max_waves: int = 15
var wave_duration: float = 25.0
var is_wave_active: bool = false
var is_game_over: bool = false
var has_played_before: bool = false

# Sanal Joystick Girdisi (Android için)
var joystick_vector: Vector2 = Vector2.ZERO

const TIER_COLORS = {
	1: Color(0.2, 1.0, 0.4),   # Yeşil (Tier 1)
	2: Color(0.3, 0.7, 1.0),   # Mavi (Tier 2)
	3: Color(0.85, 0.4, 1.0),  # Mor (Tier 3)
	4: Color(1.0, 0.85, 0.1)   # Altın (Tier 4)
}

const TIER_NAMES = {
	1: "I (Yeşil)",
	2: "II (Mavi)",
	3: "III (Mor)",
	4: "IV (Efsanevi Altın)"
}

const TIER_MULTIPLIERS = {
	1: 1.0,
	2: 1.5,
	3: 2.2,
	4: 3.2
}

signal shelter_updated

var whiskers: int = 50 # Kalıcı Kedi Mama Parası (Catnip Whiskers)
var shelter_upgrades: Dictionary = {
	"hp": 0,
	"dmg": 0,
	"speed": 0,
	"luck": 0,
	"coins": 0
}

const SAVE_FILE_PATH = "user://shelter_save.cfg"

const WEAPON_EVOLUTIONS = [
	{
		"id": "fused_yarn_boomerang",
		"name": "⚡ PATLAYICI YUMAK KASIRGASI",
		"desc": "Çift Boomerang Yörüngesi & Devasa Patlama!",
		"icon": "🌀",
		"cost": 50,
		"req": ["yarn_bomb", "fish_boomerang"]
	},
	{
		"id": "fused_claw_gun",
		"name": "⚡ OTOMATİK PENÇELİ TABANCA",
		"desc": "Keskin Pençe Savurması + Mermi Yağmuru!",
		"icon": "🔫",
		"cost": 50,
		"req": ["glock", "claws"]
	},
	{
		"id": "fused_storm_bow",
		"name": "⚡ FIRTINA YAYI",
		"desc": "Delip Geçen Ok Patlaması & Kılıç Dalgaları!",
		"icon": "🏹",
		"cost": 50,
		"req": ["bow", "sword"]
	}
]

func save_shelter() -> void:
	var cfg = ConfigFile.new()
	cfg.set_value("shelter", "whiskers", whiskers)
	cfg.set_value("shelter", "high_score", high_score)
	cfg.set_value("characters", "selected_character", selected_character)
	cfg.set_value("characters", "unlocked", unlocked_characters)
	for q in quest_progress:
		cfg.set_value("quests", q, quest_progress[q])
	for k in shelter_upgrades:
		cfg.set_value("shelter", "lvl_" + k, shelter_upgrades[k])
	cfg.save(SAVE_FILE_PATH)

func load_shelter() -> void:
	var cfg = ConfigFile.new()
	if cfg.load(SAVE_FILE_PATH) == OK:
		whiskers = cfg.get_value("shelter", "whiskers", 50)
		high_score = cfg.get_value("shelter", "high_score", 0)
		selected_character = cfg.get_value("characters", "selected_character", "standard")
		unlocked_characters = cfg.get_value("characters", "unlocked", ["standard"])
		if not unlocked_characters.has("standard"):
			unlocked_characters.append("standard")
		for q in quest_progress:
			quest_progress[q] = cfg.get_value("quests", q, 0)
		for k in shelter_upgrades:
			shelter_upgrades[k] = cfg.get_value("shelter", "lvl_" + k, 0)
	else:
		whiskers = 50
		unlocked_characters = ["standard"]

func record_weapon_kill(weapon_id: String) -> void:
	if weapon_id == "magnum":
		quest_progress["magnum_kills"] = quest_progress.get("magnum_kills", 0) + 1
		quest_progress_updated.emit("magnum_kills", quest_progress["magnum_kills"], 100)
	elif weapon_id == "claws":
		quest_progress["claws_kills"] = quest_progress.get("claws_kills", 0) + 1
		quest_progress_updated.emit("claws_kills", quest_progress["claws_kills"], 150)
	_check_character_unlocks()

func record_milk_collected() -> void:
	quest_progress["milk_collected"] = quest_progress.get("milk_collected", 0) + 1
	quest_progress_updated.emit("milk_collected", quest_progress["milk_collected"], 12)
	_check_character_unlocks()

func record_coins_collected(amount: int) -> void:
	quest_progress["total_coins"] = quest_progress.get("total_coins", 0) + amount
	quest_progress_updated.emit("total_coins", quest_progress["total_coins"], 300)
	_check_character_unlocks()

func _check_character_unlocks() -> void:
	var newly_unlocked = false
	
	# Nişancı Kedi (100 Magnum kills)
	if not unlocked_characters.has("marksman") and quest_progress.get("magnum_kills", 0) >= 100:
		unlocked_characters.append("marksman")
		character_unlocked.emit("marksman")
		newly_unlocked = true
		
	# Vahşi Pençeci (150 Claws kills)
	if not unlocked_characters.has("brawler") and quest_progress.get("claws_kills", 0) >= 150:
		unlocked_characters.append("brawler")
		character_unlocked.emit("brawler")
		newly_unlocked = true
		
	# Şişko Kedi (12 Milk bowls)
	if not unlocked_characters.has("chonky") and quest_progress.get("milk_collected", 0) >= 12:
		unlocked_characters.append("chonky")
		character_unlocked.emit("chonky")
		newly_unlocked = true
		
	# Korsan Kedi (300 Total Coins)
	if not unlocked_characters.has("pirate") and quest_progress.get("total_coins", 0) >= 300:
		unlocked_characters.append("pirate")
		character_unlocked.emit("pirate")
		newly_unlocked = true
		
	if newly_unlocked:
		save_shelter()

func get_shelter_cost(stat_key: String) -> int:
	var lvl = shelter_upgrades.get(stat_key, 0)
	return (lvl + 1) * 35

func buy_shelter_upgrade(stat_key: String) -> bool:
	var cost = get_shelter_cost(stat_key)
	if whiskers >= cost:
		var lvl = shelter_upgrades.get(stat_key, 0)
		if lvl < 5:
			whiskers -= cost
			shelter_upgrades[stat_key] = lvl + 1
			save_shelter()
			shelter_updated.emit()
			return true
	return false

func get_available_weapon_evolutions() -> Array:
	var active_ids: Array = []
	for w in equipped_weapons:
		if w != null and w.get("tier", 1) >= 4:
			active_ids.append(w.get("id", ""))
			
	var evos: Array = []
	for evo in WEAPON_EVOLUTIONS:
		var reqs = evo["req"]
		if active_ids.has(reqs[0]) and active_ids.has(reqs[1]):
			evos.append(evo)
	return evos

func execute_weapon_evolution(evo_data: Dictionary) -> bool:
	var reqs = evo_data.get("req", [])
	var slot1 = -1
	var slot2 = -1
	for i in range(3):
		if equipped_weapons[i] != null:
			var w_id = equipped_weapons[i].get("id", "")
			if w_id == reqs[0] and slot1 == -1:
				slot1 = i
			elif w_id == reqs[1] and slot2 == -1:
				slot2 = i
				
	if slot1 != -1 and slot2 != -1:
		equipped_weapons[slot1] = {
			"id": evo_data["id"],
			"name": evo_data["name"],
			"tier": 5,
			"type": "weapon",
			"cost": 60
		}
		equipped_weapons[slot2] = null
		_recalculate_weapon_synergies()
		weapons_updated.emit()
		SoundManager.play_evolution()
		return true
	return false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_shelter()
	reset_game()

func _process(delta: float) -> void:
	# Can Yenilenmesi (HP Regen)
	if hp_regen > 0.0 and is_wave_active and not is_game_over and current_hp < max_hp:
		heal_player(hp_regen * delta)

var selected_character: String = "standard"
var coin_multiplier: float = 1.0

# Silah Sınıf Sinerjileri (Blade, Gun, Heavy)
const WEAPON_TAGS = {
	"sword": "blade",
	"claws": "blade",
	"glock": "gun",
	"magnum": "gun",
	"bow": "gun",
	"fish_boomerang": "heavy",
	"yarn_bomb": "heavy"
}

const TAG_NAMES = {
	"blade": "⚔️ Kesici",
	"gun": "🎯 Menzilli",
	"heavy": "🛡️ İlkel / Ağır"
}

var active_synergies: Dictionary = {}
signal synergies_updated(active_tags: Dictionary)

# Dalga Sonu Seviye Atlama Stat Seçenekleri (Draft Options)
const DRAFT_STAT_OPTIONS = [
	{"id": "max_hp", "title": "Dokuz Can", "stat": "max_hp", "delta": 15.0, "desc": "+15 Maksimum Can & İyileşme", "icon": "❤️"},
	{"id": "dmg", "title": "Keskin Pençe", "stat": "damage_multiplier", "delta": 0.12, "desc": "+%12 Genel Hasar Artışı", "icon": "⚡"},
	{"id": "atk_spd", "title": "Kediotu Hızı", "stat": "attack_speed", "delta": 0.15, "desc": "+%15 Saldırı Hızı", "icon": "🌪️"},
	{"id": "armor", "title": "Kalın Kürk", "stat": "armor", "delta": 2.0, "desc": "+2 Zırh (Hasar Azaltma)", "icon": "🛡️"},
	{"id": "spd", "title": "Çevik Pati", "stat": "move_speed", "delta": 22.0, "desc": "+22 Hareket Hızı", "icon": "🐾"},
	{"id": "crit", "title": "Avcı Gözü", "stat": "crit_chance", "delta": 0.08, "desc": "+%8 Kritik Vuruş Şansı", "icon": "🎯"},
	{"id": "regen", "title": "Mırıldanma", "stat": "hp_regen", "delta": 1.2, "desc": "+1.2 Saniye Başı Can Yenilenmesi", "icon": "🌿"},
	{"id": "thorns", "title": "Dikenli Zırh", "stat": "thorns_damage", "delta": 6.0, "desc": "+6 Hasar Yansıtma (Thorns)", "icon": "🌵"}
]

func apply_character_archetype(char_id: String) -> void:
	selected_character = char_id
	var c = CharacterData.get_character(char_id)
	max_hp = c.get("max_hp", 100.0)
	current_hp = max_hp
	move_speed = c.get("move_speed", 220.0)
	damage_multiplier = c.get("dmg_mult", 1.0)
	attack_speed = c.get("attack_speed", 1.0)
	crit_chance = c.get("crit_chance", 0.05)
	armor = c.get("armor", 0.0)
	thorns_damage = c.get("thorns", 0.0)
	attack_range = 80.0 + c.get("range_bonus", 0.0)
	coin_multiplier = c.get("coin_mult", 1.0)
	
	var sw_id = c.get("start_weapon", "sword")
	var sw_name = c.get("start_weapon_name", "Kara Çelik Kılıç")
	equipped_weapons = [
		{"id": sw_id, "name": sw_name, "tier": 1, "type": "weapon", "cost": 10},
		null,
		null
	]
	weapons_updated.emit()
	health_changed.emit(current_hp, max_hp)
	_recalculate_weapon_synergies()

func reset_game() -> void:
	Engine.time_scale = 1.0
	max_hp = 100.0
	current_hp = max_hp
	move_speed = 220.0
	base_damage = 22.0
	damage_multiplier = 1.0
	attack_speed = 1.0
	attack_range = 80.0
	magnet_radius = 130.0
	armor = 0.0
	crit_chance = 0.05
	crit_multiplier = 2.0
	coin_multiplier = 1.0
	
	hp_regen = 0.0
	thorns_damage = 0.0
	piggy_bank_count = 0
	lives_remaining = 1
	feline_rage = 0.0
	is_feline_rage_active = false
	
	apply_character_archetype(selected_character)
	locked_shop_cards.clear()
	
	# Apply Persistent Shelter Upgrades
	var hp_lvl = shelter_upgrades.get("hp", 0)
	var dmg_lvl = shelter_upgrades.get("dmg", 0)
	var spd_lvl = shelter_upgrades.get("speed", 0)
	var luck_lvl = shelter_upgrades.get("luck", 0)
	var coins_lvl = shelter_upgrades.get("coins", 0)
	
	max_hp += float(hp_lvl) * 10.0
	current_hp = max_hp
	damage_multiplier += float(dmg_lvl) * 0.08
	move_speed += float(spd_lvl) * 10.0
	coin_multiplier += float(luck_lvl) * 0.10
	coins = coins_lvl * 25
	
	total_coins_collected = coins
	score = 0
	enemies_killed = 0
	current_wave = 1
	is_wave_active = false
	is_game_over = false

func _recalculate_weapon_synergies() -> void:
	var tag_counts = {"blade": 0, "gun": 0, "heavy": 0}
	for w in equipped_weapons:
		if w != null and w is Dictionary:
			var w_id = w.get("id", "")
			if WEAPON_TAGS.has(w_id):
				var t = WEAPON_TAGS[w_id]
				tag_counts[t] = tag_counts.get(t, 0) + 1
				
	active_synergies.clear()
	for t in tag_counts:
		if tag_counts[t] >= 2:
			active_synergies[t] = tag_counts[t]
			
	synergies_updated.emit(active_synergies)

func get_synergy_bonus(stat_name: String) -> float:
	var bonus = 0.0
	if active_synergies.has("blade"):
		var count = active_synergies["blade"]
		if stat_name == "attack_speed":
			bonus += 0.18 if count == 2 else 0.35
	if active_synergies.has("gun"):
		var count = active_synergies["gun"]
		if stat_name == "damage_multiplier":
			bonus += 0.20 if count == 2 else 0.40
		elif stat_name == "attack_range":
			bonus += 30.0 if count == 2 else 60.0
	if active_synergies.has("heavy"):
		var count = active_synergies["heavy"]
		if stat_name == "armor":
			bonus += 3.0 if count == 2 else 6.0
	return bonus

func get_effective_damage_multiplier() -> float:
	return max(0.1, damage_multiplier + get_synergy_bonus("damage_multiplier"))

func get_effective_attack_speed() -> float:
	return max(0.2, attack_speed + get_synergy_bonus("attack_speed"))

func get_effective_attack_range() -> float:
	return max(20.0, attack_range + get_synergy_bonus("attack_range"))

func get_effective_armor() -> float:
	return armor + get_synergy_bonus("armor")



var partial_coins: float = 0.0

func add_coins(amount: int) -> void:
	add_coins_value(float(amount))

func add_coins_value(amount: float) -> void:
	partial_coins += (amount * coin_multiplier)
	var int_gain = int(partial_coins)
	if int_gain > 0:
		partial_coins -= float(int_gain)
		coins += int_gain
		total_coins_collected += int_gain
		score += int_gain * 10
		if score > high_score:
			high_score = score
		coins_changed.emit(coins)

func spend_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		coins_changed.emit(coins)
		return true
	return false

func heal_player(amount: float) -> void:
	current_hp = min(current_hp + amount, max_hp)
	health_changed.emit(current_hp, max_hp)

func damage_player(amount: float) -> void:
	if is_game_over:
		return
	var actual_damage = max(1.0, amount - armor)
	current_hp -= actual_damage
	health_changed.emit(current_hp, max_hp)
	
	# Diken (Thorns) Hasarı: Çevredeki farelere vur
	if thorns_damage > 0.0:
		_trigger_thorns_damage()
	
	if current_hp <= 0.0:
		if lives_remaining > 0:
			lives_remaining -= 1
			current_hp = max_hp * 0.5
			health_changed.emit(current_hp, max_hp)
			death_defiance_triggered.emit(lives_remaining)
			_execute_death_defiance()
		else:
			trigger_game_over()

func _execute_death_defiance() -> void:
	# 1. Dramatik Slow-Motion
	Engine.time_scale = 0.15
	var reset_timer = get_tree().create_timer(0.55, true, false, true)
	reset_timer.timeout.connect(func():
		var tw = create_tween()
		if tw:
			tw.tween_property(Engine, "time_scale", 1.0, 0.3)
	)
	
	# 2. Şok Dalgası ve Ekran Sarsıntısı
	request_screen_shake(0.65)
	SoundManager.play_wave_horn()
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var p = players[0]
		p.i_frame_time = 2.2 # 2.2 saniye dokunulmazlık
		var p_pos = p.global_position
		
		# Tüm çevredeki fareleri 420px geri püskürt ve 45 hasar ver
		var enemies = get_tree().get_nodes_in_group("enemies")
		for e in enemies:
			if is_instance_valid(e) and not e.get("is_dead"):
				var diff = e.global_position - p_pos
				var dist = diff.length()
				if dist < 420.0:
					var push_dir = diff.normalized() if dist > 0.0 else Vector2.UP
					e.take_damage(45.0, push_dir, 450.0, true)

func _trigger_thorns_damage() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		return
	var p_pos = players[0].global_position
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if is_instance_valid(e) and not e.is_queued_for_deletion():
			if p_pos.distance_to(e.global_position) < 130.0:
				var k_dir = (e.global_position - p_pos).normalized()
				e.take_damage(thorns_damage, k_dir, 200.0)

func add_feline_rage(amount: float) -> void:
	if is_feline_rage_active or is_game_over:
		return
	feline_rage = min(max_feline_rage, feline_rage + amount)
	feline_rage_changed.emit(feline_rage, max_feline_rage)

func activate_feline_rage() -> bool:
	if is_feline_rage_active or feline_rage < max_feline_rage or is_game_over:
		return false
	
	is_feline_rage_active = true
	feline_rage = 0.0
	feline_rage_changed.emit(feline_rage, max_feline_rage)
	feline_rage_state_changed.emit(true)
	
	var orig_speed = move_speed
	var orig_atk_spd = attack_speed
	var orig_crit = crit_chance
	
	move_speed *= 1.65
	attack_speed += 1.0
	crit_chance += 0.25
	
	Engine.time_scale = 0.45
	request_screen_shake(0.4)
	request_chromatic_aberration(0.015, 0.3)
	SoundManager.play_wave_horn()
	
	var rage_timer = get_tree().create_timer(5.0, true, false, true)
	rage_timer.timeout.connect(func():
		is_feline_rage_active = false
		move_speed = orig_speed
		attack_speed = orig_atk_spd
		crit_chance = orig_crit
		Engine.time_scale = 1.0
		feline_rage_state_changed.emit(false)
	)
	return true

func request_chromatic_aberration(strength: float = 0.012, duration: float = 0.15) -> void:
	chromatic_aberration_requested.emit(strength, duration)

func trigger_game_over() -> void:
	if is_game_over:
		return
	is_game_over = true
	is_wave_active = false
	if score > high_score:
		high_score = score
	game_over_triggered.emit()

func trigger_victory() -> void:
	if is_game_over:
		return
	is_wave_active = false
	if score > high_score:
		high_score = score
	SoundManager.play_victory()
	victory_triggered.emit()

# --- SİLAH VE BİRLEŞTİRME YÖNETİMİ ---

func get_first_empty_slot() -> int:
	for i in range(3):
		if equipped_weapons[i] == null:
			return i
	return -1

func equip_weapon(slot_index: int, weapon_data: Dictionary) -> bool:
	if slot_index < 0 or slot_index >= 3:
		return false
	if not weapon_data.has("tier"):
		weapon_data["tier"] = 1
	equipped_weapons[slot_index] = weapon_data
	_recalculate_weapon_synergies()
	weapons_updated.emit()
	return true

func sell_weapon(slot_index: int) -> int:
	if slot_index < 0 or slot_index >= 3 or equipped_weapons[slot_index] == null:
		return 0
	var w = equipped_weapons[slot_index]
	var tier_val = w.get("tier", 1)
	var base_c = w.get("cost", 8)
	var refund = max(4, int(base_c * pow(1.8, tier_val - 1) * 0.6))
	equipped_weapons[slot_index] = null
	add_coins(refund)
	SoundManager.play_coin()
	_recalculate_weapon_synergies()
	weapons_updated.emit()
	return refund

func find_combinable_slot(source_slot: int) -> int:
	var src = equipped_weapons[source_slot]
	if src == null:
		return -1
	var src_id = src.get("id", "")
	var src_tier = src.get("tier", 1)
	if src_tier >= 4:
		return -1
		
	for i in range(3):
		if i != source_slot and equipped_weapons[i] != null:
			var other = equipped_weapons[i]
			if other.get("id", "") == src_id and other.get("tier", 1) == src_tier:
				return i
	return -1

func combine_weapons(slot_a: int, slot_b: int) -> bool:
	if slot_a < 0 or slot_a >= 3 or slot_b < 0 or slot_b >= 3 or slot_a == slot_b:
		return false
	var w_a = equipped_weapons[slot_a]
	var w_b = equipped_weapons[slot_b]
	if w_a == null or w_b == null:
		return false
	if w_a.get("id", "") != w_b.get("id", "") or w_a.get("tier", 1) != w_b.get("tier", 1):
		return false
	var current_tier = w_a.get("tier", 1)
	if current_tier >= 4:
		return false
		
	w_a["tier"] = current_tier + 1
	equipped_weapons[slot_b] = null
	_recalculate_weapon_synergies()
	weapons_updated.emit()
	return true

# --- STAT & STRATEJİK BUFF YÖNETİMİ ---

func apply_draft_stat(stat_key: String, delta_val: float) -> void:
	match stat_key:
		"max_hp":
			max_hp += delta_val
			current_hp += delta_val
			health_changed.emit(current_hp, max_hp)
			player_stat_updated.emit("max_hp", max_hp)
		"damage_multiplier":
			damage_multiplier += delta_val
			player_stat_updated.emit("damage_multiplier", damage_multiplier)
		"attack_speed":
			attack_speed = max(0.2, attack_speed + delta_val)
			player_stat_updated.emit("attack_speed", attack_speed)
		"armor":
			armor += delta_val
			player_stat_updated.emit("armor", armor)
		"move_speed":
			move_speed = max(80.0, move_speed + delta_val)
			player_stat_updated.emit("move_speed", move_speed)
		"crit_chance":
			crit_chance = clampf(crit_chance + delta_val, 0.0, 1.0)
			player_stat_updated.emit("crit_chance", crit_chance)
		"hp_regen":
			hp_regen += delta_val
			player_stat_updated.emit("hp_regen", hp_regen)
		"thorns_damage":
			thorns_damage += delta_val
			player_stat_updated.emit("thorns_damage", thorns_damage)


func apply_item_buff(item_data: Dictionary, cost: int) -> bool:
	if not spend_coins(cost):
		return false
		
	var effects = item_data.get("effects", {})
	for stat_key in effects:
		var delta_val = effects[stat_key]
		match stat_key:
			"damage":
				base_damage += delta_val
				player_stat_updated.emit("damage", base_damage)
			"damage_multiplier":
				damage_multiplier += delta_val
				player_stat_updated.emit("damage_multiplier", damage_multiplier)
			"attack_speed":
				attack_speed = max(0.2, attack_speed + delta_val)
				player_stat_updated.emit("attack_speed", attack_speed)
			"max_hp":
				max_hp = max(10.0, max_hp + delta_val)
				current_hp = min(current_hp + delta_val, max_hp)
				health_changed.emit(current_hp, max_hp)
				player_stat_updated.emit("max_hp", max_hp)
			"heal_full":
				heal_player(max_hp)
			"move_speed":
				move_speed = max(80.0, move_speed + delta_val)
				player_stat_updated.emit("move_speed", move_speed)
			"magnet_radius":
				magnet_radius = max(40.0, magnet_radius + delta_val)
				player_stat_updated.emit("magnet_radius", magnet_radius)
			"armor":
				armor += delta_val
				player_stat_updated.emit("armor", armor)
			"crit_chance":
				crit_chance = clampf(crit_chance + delta_val, 0.0, 1.0)
				player_stat_updated.emit("crit_chance", crit_chance)
			"attack_range":
				attack_range += delta_val
				player_stat_updated.emit("attack_range", attack_range)
			"hp_regen":
				hp_regen += delta_val
				player_stat_updated.emit("hp_regen", hp_regen)
			"thorns_damage":
				thorns_damage += delta_val
				player_stat_updated.emit("thorns_damage", thorns_damage)
			"piggy_bank":
				piggy_bank_count += int(delta_val)
	return true

func process_wave_completion_rewards() -> void:
	if piggy_bank_count > 0 and coins > 0:
		var bonus = int(coins / 10) * piggy_bank_count
		if bonus > 0:
			add_coins(bonus)

func request_screen_shake(amount: float) -> void:
	screen_shake_requested.emit(amount)

var _is_in_hitstop: bool = false

func hitstop(duration: float = 0.05, time_scale: float = 0.05) -> void:
	if is_game_over or not is_inside_tree() or get_tree().paused:
		return
	Engine.time_scale = time_scale
	_is_in_hitstop = true
	var timer = get_tree().create_timer(duration, true, false, true)
	timer.timeout.connect(func():
		Engine.time_scale = 1.0
		_is_in_hitstop = false
	)
