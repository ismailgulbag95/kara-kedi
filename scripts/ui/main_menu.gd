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
	_setup_class_button(btn_standard, card_standard, "standard")

func _setup_shelter_button() -> void:
	var s_btn = Button.new()
	s_btn.text = "🛖 BARINAK (MAMA AĞACI)"
	s_btn.custom_minimum_size = Vector2(0, 34)
	s_btn.anchor_left = 0.0
	s_btn.anchor_top = 1.0
	s_btn.anchor_right = 0.5
	s_btn.anchor_bottom = 1.0
	s_btn.offset_left = 12
	s_btn.offset_right = -6
	s_btn.offset_top = -48
	s_btn.offset_bottom = -14
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.18, 0.14, 0.08, 0.95)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(1.0, 0.75, 0.25, 1.0)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	s_btn.add_theme_stylebox_override("normal", style)
	s_btn.add_theme_color_override("font_color", Color(1.0, 0.88, 0.4))
	s_btn.add_theme_font_size_override("font_size", 11)
	
	UIJuiceHelper.attach_button_juice(s_btn, 0.94, 1.05)
	s_btn.pressed.connect(func():
		var root = get_tree().current_scene
		if root and root.has_node("ShelterModal"):
			root.get_node("ShelterModal").open_shelter()
	)
	panel.add_child(s_btn)
	_setup_class_button(btn_marksman, card_marksman, "marksman")
	_setup_class_button(btn_brawler, card_brawler, "brawler")
	_setup_class_button(btn_tank, card_tank, "tank")
	_setup_class_button(btn_pirate, card_pirate, "pirate")

func _setup_codex_button() -> void:
	var c_btn = Button.new()
	c_btn.text = "📖 SOKAK GÜNCESİ (CODEX)"
	c_btn.custom_minimum_size = Vector2(0, 34)
	c_btn.anchor_left = 0.5
	c_btn.anchor_top = 1.0
	c_btn.anchor_right = 1.0
	c_btn.anchor_bottom = 1.0
	c_btn.offset_left = 6
	c_btn.offset_right = -12
	c_btn.offset_top = -48
	c_btn.offset_bottom = -14
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.14, 0.22, 0.95)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.4, 0.65, 0.9, 1.0)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	c_btn.add_theme_stylebox_override("normal", style)
	c_btn.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
	c_btn.add_theme_font_size_override("font_size", 11)
	
	UIJuiceHelper.attach_button_juice(c_btn, 0.94, 1.05)
	c_btn.pressed.connect(func():
		var root = get_tree().current_scene
		if root and root.has_node("CodexModal"):
			root.get_node("CodexModal").open_codex()
	)
	panel.add_child(c_btn)

func _setup_class_button(btn: Button, card: PanelContainer, char_id: String) -> void:
	if btn:
		btn.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		UIJuiceHelper.attach_button_juice(btn, 0.92, 1.06)
		btn.pressed.connect(func():
			_on_character_chosen(char_id)
		)
	if card:
		card.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_on_character_chosen(char_id)
		)

func _on_character_chosen(char_id: String) -> void:
	SoundManager.play_wave_horn()
	GameManager.selected_character = char_id
	GameManager.has_played_before = true
	GameManager.reset_game()
	
	visible = false
	get_tree().paused = false
	play_pressed.emit(char_id)
	GameManager.wave_started.emit(1)
