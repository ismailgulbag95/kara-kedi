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

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	reset_game()

func _process(delta: float) -> void:
	# Can Yenilenmesi (HP Regen)
	if hp_regen > 0.0 and is_wave_active and not is_game_over and current_hp < max_hp:
		heal_player(hp_regen * delta)

func reset_game() -> void:
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
	
	hp_regen = 0.0
	thorns_damage = 0.0
	piggy_bank_count = 0
	
	equipped_weapons = [
		{"id": "sword", "name": "Kara Çelik Kılıç", "tier": 1, "type": "weapon", "cost": 10},
		null,
		null
	]
	locked_shop_cards.clear()
	
	coins = 0
	total_coins_collected = 0
	score = 0
	enemies_killed = 0
	current_wave = 1
	is_wave_active = false
	is_game_over = false
	weapons_updated.emit()

var partial_coins: float = 0.0

func add_coins(amount: int) -> void:
	add_coins_value(float(amount))

func add_coins_value(amount: float) -> void:
	partial_coins += amount
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
		trigger_game_over()

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
	weapons_updated.emit()
	return true

func sell_weapon(slot_index: int) -> int:
	if slot_index < 0 or slot_index >= 3 or equipped_weapons[slot_index] == null:
		return 0
	var w = equipped_weapons[slot_index]
	var tier_val = w.get("tier", 1)
	var base_c = w.get("cost", 8)
	var refund = int(base_c * tier_val * 0.6)
	equipped_weapons[slot_index] = null
	add_coins(refund)
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
	weapons_updated.emit()
	return true

# --- STAT & STRATEJİK BUFF YÖNETİMİ ---

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
