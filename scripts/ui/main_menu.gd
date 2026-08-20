extends CanvasLayer

## Başlangıç ve Karakter Seçim Menüsü (Main Menu & Character Select)
## 5 Kedi Sınıfı doğrudan ana menüde listelenir. Tıklanan sınıf ile oyun anında başlar.

signal play_pressed(character_id: String)

@onready var panel: Panel = $Control/Panel

@onready var btn_standard: Button = $Control/Panel/ScrollContainer/CardsVBox/CardStandard/HBox/BtnStandard
@onready var btn_marksman: Button = $Control/Panel/ScrollContainer/CardsVBox/CardMarksman/HBox/BtnMarksman
@onready var btn_brawler: Button = $Control/Panel/ScrollContainer/CardsVBox/CardBrawler/HBox/BtnBrawler
@onready var btn_tank: Button = $Control/Panel/ScrollContainer/CardsVBox/CardTank/HBox/BtnTank
@onready var btn_pirate: Button = $Control/Panel/ScrollContainer/CardsVBox/CardPirate/HBox/BtnPirate

@onready var card_standard: PanelContainer = $Control/Panel/ScrollContainer/CardsVBox/CardStandard
@onready var card_marksman: PanelContainer = $Control/Panel/ScrollContainer/CardsVBox/CardMarksman
@onready var card_brawler: PanelContainer = $Control/Panel/ScrollContainer/CardsVBox/CardBrawler
@onready var card_tank: PanelContainer = $Control/Panel/ScrollContainer/CardsVBox/CardTank
@onready var card_pirate: PanelContainer = $Control/Panel/ScrollContainer/CardsVBox/CardPirate

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = true
	get_tree().paused = true
	
	_setup_codex_button()
	_setup_shelter_button()
	_refresh_character_cards()
	GameManager.character_unlocked.connect(func(_id): _refresh_character_cards())
	GameManager.quest_progress_updated.connect(func(_t, _c, _tgt): _refresh_character_cards())

func _setup_shelter_button() -> void:
	var s_btn = Button.new()
	s_btn.text = "🛖 BARINAK"
	s_btn.custom_minimum_size = Vector2(0, 36)
	s_btn.anchor_left = 0.0
	s_btn.anchor_top = 1.0
	s_btn.anchor_right = 0.5
	s_btn.anchor_bottom = 1.0
	s_btn.offset_left = 12
	s_btn.offset_right = -6
	s_btn.offset_top = -48
	s_btn.offset_bottom = -12
	s_btn.pressed.connect(func():
		var root = get_tree().current_scene
		if root and root.has_node("ShelterModal"):
			root.get_node("ShelterModal").open_shelter()
	)
	panel.add_child(s_btn)

func _setup_codex_button() -> void:
	var c_btn = Button.new()
	c_btn.text = "📖 CODEX"
	c_btn.custom_minimum_size = Vector2(0, 36)
	c_btn.anchor_left = 0.5
	c_btn.anchor_top = 1.0
	c_btn.anchor_right = 1.0
	c_btn.anchor_bottom = 1.0
	c_btn.offset_left = 6
	c_btn.offset_right = -12
	c_btn.offset_top = -48
	c_btn.offset_bottom = -12
	c_btn.pressed.connect(func():
		var root = get_tree().current_scene
		if root and root.has_node("CodexModal"):
			root.get_node("CodexModal").open_codex()
	)
	panel.add_child(c_btn)

func _refresh_character_cards() -> void:
	_setup_class_button(btn_standard, card_standard, "standard")
	_setup_class_button(btn_marksman, card_marksman, "marksman")
	_setup_class_button(btn_brawler, card_brawler, "brawler")
	_setup_class_button(btn_tank, card_tank, "chonky")
	_setup_class_button(btn_pirate, card_pirate, "pirate")

func _setup_class_button(btn: Button, card: PanelContainer, char_id: String) -> void:
	if not card or not btn:
		return
		
	var c = CharacterData.get_character(char_id)
	var is_unlocked = GameManager.unlocked_characters.has(char_id) or c.get("unlocked_by_default", false)
	
	var info_vbox = card.get_node_or_null("HBox/InfoVBox")
	var buff_label: Label = null
	var name_label: Label = null
	var wpn_label: Label = null
	if info_vbox:
		buff_label = info_vbox.get_node_or_null("Buff")
		name_label = info_vbox.get_node_or_null("Name")
		wpn_label = info_vbox.get_node_or_null("Weapon")
	
	card.modulate = Color.WHITE
	
	if not is_unlocked:
		# Karakter adı ve silahını hafif koyulaştır ama kartı kapatma
		if name_label:
			name_label.modulate = Color(0.7, 0.7, 0.75, 0.8)
		if wpn_label:
			wpn_label.modulate = Color(0.6, 0.65, 0.7, 0.7)
			
		var q_type = c.get("unlock_quest_type", "")
		var q_target = c.get("unlock_quest_target", 1)
		var q_curr = GameManager.quest_progress.get(q_type, 0)
		var pct = int((float(q_curr) / float(q_target)) * 100.0)
		
		btn.text = "🔒 %d/%d" % [q_curr, q_target]
		btn.disabled = true
		btn.tooltip_text = ""
		btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		
		# GEREKSİNİM: %100 Parlak, Altın Sarısı ve Net Görünür (Silik Değil!)
		if buff_label:
			buff_label.modulate = Color.WHITE
			buff_label.text = "🔒 GEREKSİNİM: %s\n   📊 İlerleme: %d / %d (%%%d)" % [c.get("unlock_quest", "Kilitli"), q_curr, q_target, pct]
			buff_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.3))
			buff_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1.0))
			buff_label.add_theme_constant_override("shadow_offset_x", 1)
			buff_label.add_theme_constant_override("shadow_offset_y", 1)
			buff_label.add_theme_font_size_override("font_size", 11)
			buff_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	else:
		if name_label:
			name_label.modulate = Color.WHITE
		if wpn_label:
			wpn_label.modulate = Color.WHITE
			
		btn.disabled = false
		btn.text = "SEÇ & OYNA"
		btn.tooltip_text = ""
		btn.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		UIJuiceHelper.attach_button_juice(btn, 0.92, 1.06)
		
		if buff_label:
			buff_label.modulate = Color.WHITE
			buff_label.text = "+ " + c["buffs"][0]
			buff_label.add_theme_color_override("font_color", Color(0.3, 0.95, 0.45))
			buff_label.add_theme_font_size_override("font_size", 10)
			buff_label.autowrap_mode = TextServer.AUTOWRAP_OFF
		
		if btn.is_connected("pressed", _on_character_chosen):
			btn.disconnect("pressed", _on_character_chosen)
		btn.pressed.connect(func(): _on_character_chosen(char_id))

func _on_character_chosen(char_id: String) -> void:
	SoundManager.play_wave_horn()
	GameManager.selected_character = char_id
	GameManager.has_played_before = true
	GameManager.reset_game()
	
	visible = false
	get_tree().paused = false
	play_pressed.emit(char_id)
	GameManager.wave_started.emit(1)
