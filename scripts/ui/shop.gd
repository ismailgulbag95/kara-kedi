extends CanvasLayer

## Brotato Tarzı Görsel Kartlı Market & Envanter Ekranı
## 15+ Stratejik Build Eşyası (Tank, Glass Cannon, Hız/Kritik, Ekonomi), 48x48 İkonlar

@onready var cards_container: Container = $Control/Panel/CardsGrid
@onready var slots_container: HBoxContainer = $Control/Panel/WeaponSlotsPanel/SlotsContainer
@onready var coins_label: Label = $Control/Panel/CoinsLabel
@onready var reroll_btn: Button = $Control/Panel/RerollButton
@onready var next_wave_btn: Button = $Control/Panel/NextWaveButton

var reroll_count: int = 0
var reroll_cost: int = 3
var current_offers: Array = []

const WEAPONS_DATABASE = [
	{
		"category": "weapon",
		"id": "sword",
		"title": "🗡️ Kara Çelik Kılıç",
		"tier": 1,
		"slot_pref": "Sağ/Sol El",
		"desc": "Geniş savurma, yüksek hasar ve geri tepme.\nHasar: 30 | Hız: Orta",
		"icon_path": "res://assets/textures/sword.png",
		"cost": 10
	},
	{
		"category": "weapon",
		"id": "claws",
		"title": "🐾 Çift Pençe",
		"tier": 1,
		"slot_pref": "Sağ/Sol El",
		"desc": "Çok seri saldırır, yüksek kritik şansı sağlar.\nHasar: 16 | Hız: Hızlı (+%25 Kritik)",
		"icon_path": "res://assets/textures/claws.png",
		"cost": 9
	},
	{
		"category": "weapon",
		"id": "fish_boomerang",
		"title": "🐟 Kılçık Bumerangı",
		"tier": 1,
		"slot_pref": "Her Yuva",
		"desc": "Düşmanları delip geçen delici kemik.\nHasar: 22 | Menzil: 320px",
		"icon_path": "res://assets/textures/fish_bone.png",
		"cost": 10
	},
	{
		"category": "weapon",
		"id": "yarn_bomb",
		"title": "🧶 İp Yumağı Bombası",
		"tier": 1,
		"slot_pref": "Kuyruk Yuvası",
		"desc": "Farelerin içine patlayıcı alan hasarı atar.\nHasar: 36 (Alan) | Menzil: 450px",
		"icon_path": "res://assets/textures/yarn_bomb.png",
		"cost": 11
	},
	{
		"category": "weapon",
		"id": "magnum",
		"title": "💥 Ağır Magnum",
		"tier": 1,
		"slot_pref": "Sağ/Sol El",
		"desc": "Yüksek hasar ve geri tepmeli ağır mermiler.\nHasar: 45 | Hız: Ağır (1.1s)",
		"icon_path": "res://assets/textures/items/weapon_magnum.png",
		"cost": 12
	},
	{
		"category": "weapon",
		"id": "glock",
		"title": "⚡ Seri Glock",
		"tier": 1,
		"slot_pref": "Sağ/Sol El",
		"desc": "Saniyede 4.5 seri kurşun yağmuru.\nHasar: 10 | Hız: Çok Hızlı (0.22s)",
		"icon_path": "res://assets/textures/items/weapon_glock.png",
		"cost": 10
	},
	{
		"category": "weapon",
		"id": "bow",
		"title": "🏹 Avcı Yayı",
		"tier": 1,
		"slot_pref": "Sağ/Sol El",
		"desc": "Düşmanları delip geçen keskin oklar.\nHasar: 24 (Delme 2) | Hız: Dengeli",
		"icon_path": "res://assets/textures/items/weapon_bow.png",
		"cost": 11
	}
]

const ITEMS_DATABASE = [
	# --- TANK & SAVUNMA BUILD ---
	{
		"category": "item",
		"id": "cat_armor",
		"title": "🛡️ Dev Kedi Zırhı",
		"desc": "+30 Maks Can, +3 Zırh\n-12 Hareket Hızı",
		"icon_path": "res://assets/textures/items/item_cat_armor.png",
		"cost": 10,
		"effects": {"max_hp": 30.0, "armor": 3.0, "move_speed": -12.0}
	},
	{
		"category": "item",
		"id": "thorns",
		"title": "🌵 Dikenli Kürk",
		"desc": "+2.5 Zırh\nHasar alınca farelere 15 hasar yansıtır",
		"icon_path": "res://assets/textures/items/item_thorns.png",
		"cost": 9,
		"effects": {"armor": 2.5, "thorns_damage": 15.0}
	},
	{
		"category": "item",
		"id": "regen",
		"title": "💖 Kedi Canlılığı",
		"desc": "+1.5 Can/Sn Otomatik Yenilenme\n-%10 Saldırı Hızı",
		"icon_path": "res://assets/textures/items/item_regen.png",
		"cost": 10,
		"effects": {"hp_regen": 1.5, "attack_speed": -0.10}
	},
	{
		"category": "item",
		"id": "heavy_bell",
		"title": "🔔 Ağır Çan Kolye",
		"desc": "+25 Maks Can, +2 Zırh\n-10 Hareket Hızı",
		"icon_path": "res://assets/textures/items/item_heavy_bell.png",
		"cost": 8,
		"effects": {"max_hp": 25.0, "armor": 2.0, "move_speed": -10.0}
	},
	
	# --- GLASS CANNON (YÜKSEK SALDIRI) BUILD ---
	{
		"category": "item",
		"id": "bloody_claw",
		"title": "🩸 Kanlı Pençe",
		"desc": "+8 Temel Hasar, +%15 Hasar\n-12 Maks Can",
		"icon_path": "res://assets/textures/items/item_bloody_claw.png",
		"cost": 10,
		"effects": {"damage": 8.0, "damage_multiplier": 0.15, "max_hp": -12.0}
	},
	{
		"category": "item",
		"id": "sniper_glass",
		"title": "🎯 Sniper Gözlüğü",
		"desc": "+35 Saldırı Menzili, +%15 Kritik\n-2 Zırh",
		"icon_path": "res://assets/textures/items/item_sniper_glass.png",
		"cost": 9,
		"effects": {"attack_range": 35.0, "crit_chance": 0.15, "armor": -2.0}
	},
	{
		"category": "item",
		"id": "rage_mint",
		"title": "🔥 Öfke Nanesi",
		"desc": "+%30 Saldırı Hızı\n-5 Maks Can",
		"icon_path": "res://assets/textures/items/item_rage_mint.png",
		"cost": 8,
		"effects": {"attack_speed": 0.30, "max_hp": -5.0}
	},
	{
		"category": "item",
		"id": "lightning_whiskers",
		"title": "⚡ Yıldırımlı Bıyık",
		"desc": "+6 Temel Hasar\n+%12 Saldırı Hızı",
		"icon_path": "res://assets/textures/items/item_lightning_whiskers.png",
		"cost": 9,
		"effects": {"damage": 6.0, "attack_speed": 0.12}
	},
	
	# --- ÇEVİK SUİKASTÇI (HIZ & KRİTİK) BUILD ---
	{
		"category": "item",
		"id": "puma_boots",
		"title": "👟 Puma Adımları",
		"desc": "+40 Hareket Hızı, +%10 Kritik\n-3 Temel Hasar",
		"icon_path": "res://assets/textures/items/item_puma_boots.png",
		"cost": 8,
		"effects": {"move_speed": 40.0, "crit_chance": 0.10, "damage": -3.0}
	},
	{
		"category": "item",
		"id": "shadow_cloak",
		"title": "🧥 Gölge Pelerini",
		"desc": "+%15 Saldırı Hızı, +%20 Hız\n-8 Maks Can",
		"icon_path": "res://assets/textures/items/item_shadow_cloak.png",
		"cost": 8,
		"effects": {"attack_speed": 0.15, "move_speed": 20.0, "max_hp": -8.0}
	},
	{
		"category": "item",
		"id": "night_vision",
		"title": "👁️ Gece Avcısı Gözü",
		"desc": "+%14 Kritik Şansı\n+20 Saldırı Menzili",
		"icon_path": "res://assets/textures/items/item_night_vision.png",
		"cost": 7,
		"effects": {"crit_chance": 0.14, "attack_range": 20.0}
	},
	
	# --- EKONOMİ & TOPLAYICI BUILD ---
	{
		"category": "item",
		"id": "gold_magnet",
		"title": "🧲 Altın Mıknatıs",
		"desc": "+60 Koin Çekim Alanı\n+10 Hareket Hızı",
		"icon_path": "res://assets/textures/items/item_gold_magnet.png",
		"cost": 7,
		"effects": {"magnet_radius": 60.0, "move_speed": 10.0}
	},
	# --- STRATEJİK RİSK / ÖDÜL (TRADE-OFF) BUILD ---
	{
		"category": "item",
		"id": "glass_dagger",
		"title": "🗡️ Cam Hançer",
		"desc": "+%35 Genel Hasar Artışı\n-15 Maksimum Can",
		"icon_path": "res://assets/textures/items/item_bloody_claw.png",
		"cost": 12,
		"effects": {"damage_multiplier": 0.35, "max_hp": -15.0}
	},
	{
		"category": "item",
		"id": "knight_armor",
		"title": "🛡️ Ağır Şövalye Zırhı",
		"desc": "+6 Zırh Koruması\n-25 Hareket Hızı",
		"icon_path": "res://assets/textures/items/item_cat_armor.png",
		"cost": 12,
		"effects": {"armor": 6.0, "move_speed": -25.0}
	},
	{
		"category": "item",
		"id": "pirate_scope",
		"title": "🔭 Korsan Dürbünü",
		"desc": "+55px Saldırı Menzili\n-%10 Saldırı Hızı",
		"icon_path": "res://assets/textures/items/item_sniper_glass.png",
		"cost": 10,
		"effects": {"attack_range": 55.0, "attack_speed": -0.10}
	},
	{
		"category": "item",
		"id": "catnip_potion",
		"title": "🧪 Çılgın Kediotu İksiri",
		"desc": "+%30 Saldırı Hızı\n-4 Temel Hasar",
		"icon_path": "res://assets/textures/items/item_rage_mint.png",
		"cost": 11,
		"effects": {"attack_speed": 0.30, "damage": -4.0}
	},
	{
		"category": "item",
		"id": "spiked_collar",
		"title": "⛓️ Dikenli Çelik Tasma",
		"desc": "+12 Yansıtılan Diken Hasarı\n-8 Maksimum Can",
		"icon_path": "res://assets/textures/items/item_thorns.png",
		"cost": 10,
		"effects": {"thorns_damage": 12.0, "max_hp": -8.0}
	},
	{
		"category": "item",
		"id": "greedy_amulet",
		"title": "🪙 Açgözlü Korsan Tılsımı",
		"desc": "+%50 Fazla Koin Kazancı\n-2 Zırh Zayıflığı",
		"icon_path": "res://assets/textures/items/item_gold_magnet.png",
		"cost": 13,
		"effects": {"armor": -2.0}
	},
	{
		"category": "item",
		"id": "ninja_tabi",
		"title": "🥷 Ninja Kedisi Patikleri",
		"desc": "+35 Hareket Hızı, +%12 Kritik\n-10 Maksimum Can",
		"icon_path": "res://assets/textures/items/item_puma_boots.png",
		"cost": 11,
		"effects": {"move_speed": 35.0, "crit_chance": 0.12, "max_hp": -10.0}
	},
	{
		"category": "item",
		"id": "berserk_ring",
		"title": "💍 Berserker Yüzüğü",
		"desc": "+%25 Hasar, +%15 Saldırı Hızı\n-3 Zırh",
		"icon_path": "res://assets/textures/items/item_lightning_whiskers.png",
		"cost": 14,
		"effects": {"damage_multiplier": 0.25, "attack_speed": 0.15, "armor": -3.0}
	}
]


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameManager.coins_changed.connect(_update_coins_ui)
	GameManager.weapons_updated.connect(_update_weapon_slots_ui)
	
	reroll_btn.pressed.connect(_on_reroll_pressed)
	next_wave_btn.pressed.connect(_on_next_wave_pressed)
	UIJuiceHelper.attach_button_juice(reroll_btn)
	UIJuiceHelper.attach_button_juice(next_wave_btn)

func open_shop() -> void:
	visible = true
	get_tree().paused = true
	reroll_count = 0
	_calculate_reroll_cost()
	_update_coins_ui(GameManager.coins)
	_update_weapon_slots_ui()
	_populate_market_cards()

func _on_wave_completed(_wave_num: int) -> void:
	open_shop()


func _calculate_reroll_cost() -> void:
	reroll_cost = 3 + (reroll_count * 2) + (GameManager.current_wave - 1) * 2

func _update_coins_ui(current_coins: int) -> void:
	coins_label.text = "MEVCUT COIN: " + str(current_coins)
	_calculate_reroll_cost()
	reroll_btn.disabled = current_coins < reroll_cost
	reroll_btn.text = "YENİLE (%d Coin)" % reroll_cost

func _update_weapon_slots_ui() -> void:
	for child in slots_container.get_children():
		child.queue_free()
		
	var slot_names = ["Sağ El (1)", "Sol El (2)", "Kuyruk (3)"]
	for i in range(3):
		var w = GameManager.equipped_weapons[i]
		var panel = PanelContainer.new()
		panel.custom_minimum_size = Vector2(190, 85)
		
		var vbox = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 2)
		
		var lbl = Label.new()
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 12)
		
		if w != null:
			var tier_num = w.get("tier", 1)
			var tier_col = GameManager.TIER_COLORS.get(tier_num, Color.WHITE)
			var w_id = w.get("id", "")
			var tag_str = ""
			if GameManager.WEAPON_TAGS.has(w_id):
				var tag_key = GameManager.WEAPON_TAGS[w_id]
				tag_str = " (" + GameManager.TAG_NAMES.get(tag_key, "") + ")"
			
			lbl.text = "%s:\n%s [T%d]%s" % [slot_names[i], w.get("name", "Silah"), tier_num, tag_str]
			lbl.add_theme_color_override("font_color", tier_col)
			vbox.add_child(lbl)
			
			var btns_hbox = HBoxContainer.new()
			btns_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
			btns_hbox.add_theme_constant_override("separation", 6)
			
			var sell_btn = Button.new()
			var base_c = w.get("cost", 8)
			var refund = max(4, int(base_c * pow(1.8, tier_num - 1) * 0.6))
			sell_btn.text = "♻️ Sat (+%d)" % refund
			sell_btn.add_theme_font_size_override("font_size", 10)
			sell_btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
			UIJuiceHelper.attach_button_juice(sell_btn, 0.92, 1.05)
			sell_btn.pressed.connect(func():
				GameManager.sell_weapon(i)
				_update_weapon_slots_ui()
				_render_cards()
			)
			btns_hbox.add_child(sell_btn)
			
			var match_slot = GameManager.find_combinable_slot(i)
			if match_slot != -1 and tier_num < 4:
				var combine_btn = Button.new()
				var next_tier_col = GameManager.TIER_COLORS.get(tier_num + 1, Color.WHITE)
				combine_btn.text = "⚡ BİRLEŞTİR"
				combine_btn.add_theme_font_size_override("font_size", 10)
				combine_btn.add_theme_color_override("font_color", next_tier_col)
				UIJuiceHelper.attach_button_juice(combine_btn, 0.92, 1.05)
				combine_btn.pressed.connect(func():
					if GameManager.combine_weapons(i, match_slot):
						SoundManager.play_upgrade()
						_update_weapon_slots_ui()
						_render_cards()
				)
				btns_hbox.add_child(combine_btn)
				
			vbox.add_child(btns_hbox)
		else:
			lbl.text = "%s:\n[BOŞ YUVA]" % slot_names[i]
			lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
			vbox.add_child(lbl)
			
		panel.add_child(vbox)
		slots_container.add_child(panel)

	# ⚡ Evrimleşme (Weapon Fusion) Butonlarını Ekle
	var evos = GameManager.get_available_weapon_evolutions()
	for evo in evos:
		var evo_btn = Button.new()
		evo_btn.text = "%s %s" % [evo["icon"], evo["name"]]
		evo_btn.custom_minimum_size = Vector2(160, 48)
		
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.65, 0.15, 0.85, 0.95)
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.border_color = Color(1.0, 0.85, 0.3, 1.0)
		style.corner_radius_top_left = 8
		style.corner_radius_top_right = 8
		style.corner_radius_bottom_right = 8
		style.corner_radius_bottom_left = 8
		evo_btn.add_theme_stylebox_override("normal", style)
		evo_btn.add_theme_font_size_override("font_size", 10)
		evo_btn.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
		
		UIJuiceHelper.attach_button_juice(evo_btn, 0.94, 1.06)
		var evo_data = evo
		evo_btn.pressed.connect(func():
			if GameManager.execute_weapon_evolution(evo_data):
				_update_weapon_slots_ui()
				_render_cards()
		)
		slots_container.add_child(evo_btn)


func _populate_market_cards() -> void:
	var new_offers: Array = []
	for card_data in current_offers:
		if card_data.get("is_locked", false):
			new_offers.append(card_data)
			
	var all_pool = WEAPONS_DATABASE + ITEMS_DATABASE
	all_pool.shuffle()
	
	var wave = GameManager.current_wave
	
	while new_offers.size() < 4 and all_pool.size() > 0:
		var candidate = all_pool.pop_front().duplicate()
		candidate["is_locked"] = false
		
		# Kademeli Tier Belirleme
		var roll = randf()
		var offer_tier = 1
		if wave <= 3:
			offer_tier = 1
		elif wave <= 7:
			offer_tier = 2 if roll < 0.30 else 1
		elif wave <= 11:
			if roll < 0.15:
				offer_tier = 3
			elif roll < 0.50:
				offer_tier = 2
			else:
				offer_tier = 1
		else: # Dalga 12 - 15
			if roll < 0.10:
				offer_tier = 4
			elif roll < 0.35:
				offer_tier = 3
			elif roll < 0.75:
				offer_tier = 2
			else:
				offer_tier = 1
				
		if candidate["category"] == "weapon":
			candidate["tier"] = offer_tier
			candidate["actual_cost"] = int(candidate["cost"] * (1.0 + float(offer_tier - 1) * 0.75) + (wave - 1))
		else:
			candidate["actual_cost"] = candidate["cost"] + (wave - 1)
			
		new_offers.append(candidate)
		
	current_offers = new_offers
	_render_cards()

func _render_cards() -> void:
	for child in cards_container.get_children():
		child.queue_free()
		
	for i in range(current_offers.size()):
		var card_data = current_offers[i]
		_create_card_ui(card_data, i)

func _animate_card_purchase(card: Control, callback: Callable) -> void:
	card.pivot_offset = Vector2(card.custom_minimum_size.x * 0.5, card.custom_minimum_size.y * 0.5)
	
	# Tek Sefer Akıcı 360° Dönüş ve Parlama (0.36s)
	var tween = card.create_tween()
	tween.tween_property(card, "scale:x", -1.0, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(card, "modulate", Color(2.8, 2.4, 1.3, 1.0), 0.18)
	tween.tween_property(card, "scale:x", 1.0, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Anında Parçalanarak Dağılma ve Yok Olma (0.28s)
	tween.tween_property(card, "scale", Vector2(1.3, 1.3), 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(card, "modulate:a", 0.0, 0.28)
	
	SoundManager.play_upgrade()
	tween.tween_callback(callback)

func _create_card_ui(card_data: Dictionary, index: int) -> void:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(300, 320)
	panel.pivot_offset = Vector2(150, 160)
	panel.scale = Vector2(0.85, 0.85)
	panel.modulate.a = 0.0
	
	var tween = panel.create_tween()
	if tween:
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_interval(float(index) * 0.05)
		tween.tween_property(panel, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(panel, "modulate:a", 1.0, 0.15)

	
	var is_locked = card_data.get("is_locked", false)
	var card_tier = card_data.get("tier", 1)
	
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(0.10, 0.11, 0.17, 0.97)
	card_style.border_width_left = 3
	card_style.border_width_top = 3
	card_style.border_width_right = 3
	card_style.border_width_bottom = 3
	
	if is_locked:
		card_style.border_color = Color(1.0, 0.85, 0.2, 1.0) # Parlak Altın Kilit Çerçevesi
	elif card_data["category"] == "weapon":
		card_style.border_color = GameManager.TIER_COLORS.get(card_tier, Color(0.2, 0.85, 0.45, 0.9))
	else:
		card_style.border_color = Color(0.85, 0.65, 0.2, 0.9)
		
	card_style.corner_radius_top_left = 14
	card_style.corner_radius_top_right = 14
	card_style.corner_radius_bottom_right = 14
	card_style.corner_radius_bottom_left = 14
	panel.add_theme_stylebox_override("panel", card_style)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	
	# Üst Çubuk: İkon ve Kilit Durumu
	var top_bar = HBoxContainer.new()
	top_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var icon_rect = TextureRect.new()
	icon_rect.custom_minimum_size = Vector2(48, 48)
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var icon_path = card_data.get("icon_path", "")
	if ResourceLoader.exists(icon_path):
		icon_rect.texture = load(icon_path)
	top_bar.add_child(icon_rect)
	vbox.add_child(top_bar)
	
	# 2. Başlık (18 Punto)
	var title_lbl = Label.new()
	var t_suffix = (" [T%d]" % card_tier) if card_data["category"] == "weapon" else ""
	title_lbl.text = card_data["title"] + t_suffix
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 18)
	var tier_col = GameManager.TIER_COLORS.get(card_tier, Color(1.0, 0.88, 0.3))
	title_lbl.add_theme_color_override("font_color", tier_col)
	vbox.add_child(title_lbl)
	
	# 3. Kategori
	var cat_lbl = Label.new()
	cat_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cat_lbl.add_theme_font_size_override("font_size", 13)
	if card_data["category"] == "weapon":
		cat_lbl.text = "⚔️ SİLAH (" + card_data.get("slot_pref", "Her Yuva") + ")"
		cat_lbl.add_theme_color_override("font_color", Color(0.3, 1.0, 0.6))
	else:
		cat_lbl.text = "✨ PASİF EŞYA / BUFF"
		cat_lbl.add_theme_color_override("font_color", Color(0.6, 0.9, 1.0))
	vbox.add_child(cat_lbl)
	
	# 4. Açıklama & İstatistikler (15 Punto)
	var desc_lbl = Label.new()
	desc_lbl.text = card_data["desc"]
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_lbl.custom_minimum_size = Vector2(275, 56)
	desc_lbl.add_theme_font_size_override("font_size", 15)
	vbox.add_child(desc_lbl)
	
	var cost = card_data["actual_cost"]
	var can_afford = GameManager.coins >= cost
	
	if card_data["category"] == "weapon":
		var existing_slot = -1
		for s in range(3):
			var w = GameManager.equipped_weapons[s]
			if w != null and w.get("id") == card_data["id"] and w.get("tier", 1) == card_tier:
				existing_slot = s
				break
				
		var empty_slot = GameManager.get_first_empty_slot()
		
		# 1. Durum: Envanterde aynı silah var -> "AL & BİRLEŞTİR"
		if existing_slot != -1 and card_tier < 4:
			var combine_buy_btn = Button.new()
			combine_buy_btn.custom_minimum_size = Vector2(0, 44)
			var next_tier = card_tier + 1
			combine_buy_btn.text = "⚡ AL & BİRLEŞTİR (T%d -> T%d) [%d K]" % [card_tier, next_tier, cost]
			combine_buy_btn.disabled = not can_afford
			var next_col = GameManager.TIER_COLORS.get(next_tier, Color.CYAN)
			combine_buy_btn.add_theme_color_override("font_color", next_col)
			combine_buy_btn.add_theme_font_size_override("font_size", 14)
			combine_buy_btn.pressed.connect(func():
				_animate_card_purchase(panel, func():
					if GameManager.spend_coins(cost):
						GameManager.equipped_weapons[existing_slot]["tier"] = next_tier
						GameManager.weapons_updated.emit()
						current_offers.erase(card_data)
						_update_weapon_slots_ui()
						_render_cards()
				)
			)
			vbox.add_child(combine_buy_btn)
			UIJuiceHelper.attach_button_juice(combine_buy_btn, 0.94, 1.04)
			
		# 2. Durum: Boş yuva varsa normal "AL"
		if empty_slot != -1:
			var buy_btn = Button.new()
			buy_btn.custom_minimum_size = Vector2(0, 44)
			buy_btn.text = "SATIN AL (%d Coin)" % cost
			buy_btn.disabled = not can_afford
			buy_btn.add_theme_font_size_override("font_size", 14)
			buy_btn.pressed.connect(func():
				_animate_card_purchase(panel, func():
					if GameManager.spend_coins(cost):
						GameManager.equip_weapon(empty_slot, {
							"id": card_data["id"],
							"name": card_data["title"],
							"tier": card_tier,
							"type": "weapon",
							"cost": cost
						})
						current_offers.erase(card_data)
						_update_weapon_slots_ui()
						_render_cards()
				)
			)
			vbox.add_child(buy_btn)
			UIJuiceHelper.attach_button_juice(buy_btn, 0.94, 1.04)
		elif existing_slot == -1:
			var full_btn = Button.new()
			full_btn.custom_minimum_size = Vector2(0, 44)
			full_btn.text = "YUVALAR DOLU (3/3)"
			full_btn.disabled = true
			full_btn.add_theme_font_size_override("font_size", 13)
			vbox.add_child(full_btn)
	else:
		# Pasif İtem Alımı
		var buy_btn = Button.new()
		buy_btn.custom_minimum_size = Vector2(0, 44)
		buy_btn.text = "SATIN AL (%d Coin)" % cost
		buy_btn.disabled = not can_afford
		buy_btn.add_theme_font_size_override("font_size", 14)
		buy_btn.pressed.connect(func():
			_animate_card_purchase(panel, func():
				if GameManager.apply_item_buff(card_data, cost):
					current_offers.erase(card_data)
					_update_weapon_slots_ui()
					_render_cards()
			)
		)
		vbox.add_child(buy_btn)
		UIJuiceHelper.attach_button_juice(buy_btn, 0.94, 1.04)
	
	# 5. Özel Pixel Art Kilit Butonu (lock_closed.png / lock_open.png)
	var lock_btn = Button.new()
	lock_btn.custom_minimum_size = Vector2(0, 38)
	var lock_icon_path = "res://assets/textures/ui/lock_closed.png" if is_locked else "res://assets/textures/ui/lock_open.png"
	if ResourceLoader.exists(lock_icon_path):
		lock_btn.icon = load(lock_icon_path)
		lock_btn.expand_icon = true
	lock_btn.text = " KİLİTLİ (KORUNUYOR)" if is_locked else " KİLİTLE"
	lock_btn.add_theme_font_size_override("font_size", 13)
	if is_locked:
		lock_btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
		
	lock_btn.pressed.connect(func():
		card_data["is_locked"] = not card_data.get("is_locked", false)
		_render_cards()
	)
	vbox.add_child(lock_btn)
	UIJuiceHelper.attach_button_juice(lock_btn, 0.94, 1.04)

	
	margin.add_child(vbox)
	panel.add_child(margin)
	UIJuiceHelper.attach_card_tilt(panel, card_tier >= 3)
	cards_container.add_child(panel)

func _on_reroll_pressed() -> void:
	if GameManager.spend_coins(reroll_cost):
		SoundManager.play_upgrade()
		reroll_count += 1
		_update_coins_ui(GameManager.coins)
		_populate_market_cards()

func _on_next_wave_pressed() -> void:
	visible = false
	get_tree().paused = false
	GameManager.current_wave += 1
	GameManager.wave_started.emit(GameManager.current_wave)
