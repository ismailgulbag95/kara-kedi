extends Control

## Karakter Seçim Ekranı (Character Select Menu)
## 5 Karakter Sınıfı: Kara Kedi, Nişancı Kedi, Vahşi Pençeci, Şişko Kedi, Korsan Kedi
## Kilitli karakterler silik, gri ve asma kilitli (🔒) gösterilir; görev ilerleme çubukları mevcuttur.

signal character_selected(char_id: String)
signal back_to_menu_requested

@onready var cards_container: HBoxContainer = $MarginContainer/VBoxContainer/CardsScroll/CardsContainer
@onready var btn_start: Button = $MarginContainer/VBoxContainer/BottomBar/BtnStart
@onready var btn_back: Button = $MarginContainer/VBoxContainer/BottomBar/BtnBack
@onready var selected_info_label: Label = $MarginContainer/VBoxContainer/SelectedInfoLabel

var active_selection: String = "standard"
var card_nodes: Dictionary = {}

func _ready() -> void:
	active_selection = GameManager.selected_character
	btn_start.pressed.connect(_on_start_pressed)
	btn_back.pressed.connect(_on_back_pressed)
	GameManager.character_unlocked.connect(func(_id): _populate_cards())
	GameManager.quest_progress_updated.connect(func(_t, _c, _tgt): _populate_cards())
	_populate_cards()

func _populate_cards() -> void:
	for child in cards_container.get_children():
		child.queue_free()
	card_nodes.clear()
	
	var characters = CharacterData.get_all_characters()
	for c in characters:
		var c_id = c["id"]
		var is_unlocked = GameManager.unlocked_characters.has(c_id) or c.get("unlocked_by_default", false)
		var is_selected = (c_id == active_selection)
		
		var card = _create_character_card(c, is_unlocked, is_selected)
		cards_container.add_child(card)
		card_nodes[c_id] = card
		
	_update_info_label()

func _create_character_card(c: Dictionary, is_unlocked: bool, is_selected: bool) -> PanelContainer:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(170, 360)
	
	# Stil Kutusu
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	
	if is_selected:
		style.bg_color = Color(0.12, 0.16, 0.24, 0.95)
		style.border_color = Color(1.0, 0.85, 0.2, 1.0)
		style.shadow_color = Color(1.0, 0.8, 0.2, 0.4)
		style.shadow_size = 10
	elif is_unlocked:
		style.bg_color = Color(0.08, 0.10, 0.16, 0.9)
		style.border_color = Color(0.25, 0.35, 0.5, 1.0)
	else:
		style.bg_color = Color(0.05, 0.05, 0.08, 0.75)
		style.border_color = Color(0.2, 0.2, 0.25, 0.6)
		
	card.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	margin.add_child(vbox)
	card.add_child(margin)
	
	# 1. Başlık ve Ünvan
	var lbl_name = Label.new()
	lbl_name.text = c["name"]
	lbl_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_name.add_theme_font_size_override("font_size", 15)
	lbl_name.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3) if is_unlocked else Color(0.6, 0.6, 0.6))
	vbox.add_child(lbl_name)
	
	var lbl_title = Label.new()
	lbl_title.text = c["title"]
	lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_title.add_theme_font_size_override("font_size", 10)
	lbl_title.add_theme_color_override("font_color", Color(0.6, 0.7, 0.85) if is_unlocked else Color(0.45, 0.45, 0.45))
	vbox.add_child(lbl_title)
	
	# 2. Portre / Görsel
	var port_tex = TextureRect.new()
	port_tex.custom_minimum_size = Vector2(64, 64)
	port_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	port_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	port_tex.texture = load(c["portrait"])
	if not is_unlocked:
		port_tex.modulate = Color(0.3, 0.3, 0.35, 0.5)
	vbox.add_child(port_tex)
	
	# 3. Başlangıç Silahı
	var lbl_wpn = Label.new()
	lbl_wpn.text = "🗡️ " + c["start_weapon_name"]
	lbl_wpn.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_wpn.add_theme_font_size_override("font_size", 11)
	lbl_wpn.add_theme_color_override("font_color", Color(0.2, 0.85, 1.0) if is_unlocked else Color(0.4, 0.4, 0.4))
	vbox.add_child(lbl_wpn)
	
	# 4. Stat Özetleri
	var lbl_stats = Label.new()
	lbl_stats.text = "❤️ Can: %d  |  ⚡ Hız: %d" % [int(c["max_hp"]), int(c["move_speed"])]
	lbl_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_stats.add_theme_font_size_override("font_size", 10)
	lbl_stats.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8) if is_unlocked else Color(0.4, 0.4, 0.4))
	vbox.add_child(lbl_stats)
	
	# 5. Avantajlar (Yeşil / Kırmızı)
	if is_unlocked:
		var lbl_buff = Label.new()
		lbl_buff.text = "✨ " + c["buffs"][0]
		lbl_buff.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl_buff.add_theme_font_size_override("font_size", 9)
		lbl_buff.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
		vbox.add_child(lbl_buff)
		
		# Seç Butonu
		var btn_select = Button.new()
		btn_select.text = "✓ SEÇİLDİ" if is_selected else "SEÇ"
		btn_select.disabled = is_selected
		btn_select.size_flags_vertical = Control.SIZE_EXPAND_FILL
		btn_select.pressed.connect(func(): _select_character(c["id"]))
		vbox.add_child(btn_select)
	else:
		# Kilitli Görünüm ve Görev İlerlemesi
		var lbl_lock = Label.new()
		lbl_lock.text = "🔒 KİLİTLİ"
		lbl_lock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_lock.add_theme_font_size_override("font_size", 12)
		lbl_lock.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35))
		vbox.add_child(lbl_lock)
		
		var lbl_quest = Label.new()
		lbl_quest.text = c.get("unlock_quest", "")
		lbl_quest.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl_quest.add_theme_font_size_override("font_size", 9)
		lbl_quest.add_theme_color_override("font_color", Color(0.8, 0.8, 0.5))
		vbox.add_child(lbl_quest)
		
		# Canlı İlerleme Çubuğu
		var q_type = c.get("unlock_quest_type", "")
		var q_target = c.get("unlock_quest_target", 1)
		var q_current = GameManager.quest_progress.get(q_type, 0)
		
		var pbar = ProgressBar.new()
		pbar.min_value = 0
		pbar.max_value = q_target
		pbar.value = q_current
		pbar.custom_minimum_size = Vector2(0, 14)
		pbar.show_percentage = false
		vbox.add_child(pbar)
		
		var lbl_prog = Label.new()
		lbl_prog.text = "%d / %d" % [q_current, q_target]
		lbl_prog.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_prog.add_theme_font_size_override("font_size", 9)
		lbl_prog.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
		vbox.add_child(lbl_prog)
		
	return card

func _select_character(char_id: String) -> void:
	active_selection = char_id
	GameManager.selected_character = char_id
	GameManager.save_shelter()
	SoundManager.play_button_click()
	_populate_cards()

func _update_info_label() -> void:
	var c = CharacterData.get_character(active_selection)
	selected_info_label.text = "Seçilen Savaşçı: %s (%s) — %s" % [c["name"], c["title"], c["description"]]

func _on_start_pressed() -> void:
	SoundManager.play_button_click()
	GameManager.apply_character_archetype(active_selection)
	character_selected.emit(active_selection)
	hide()

func _on_back_pressed() -> void:
	SoundManager.play_button_click()
	back_to_menu_requested.emit()
	hide()
