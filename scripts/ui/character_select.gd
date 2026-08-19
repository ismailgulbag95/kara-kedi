extends CanvasLayer

## Karakter Seçim Ekranı (Character Select)
## 5 Özgün Kedi Sınıfı: Dengeli, Nişancı, Pençeci, Tank ve Korsan Kedi

signal character_chosen(character_id: String)

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
	visible = false
	
	_setup_button(btn_standard, card_standard, "standard")
	_setup_button(btn_marksman, card_marksman, "marksman")
	_setup_button(btn_brawler, card_brawler, "brawler")
	_setup_button(btn_tank, card_tank, "tank")
	_setup_button(btn_pirate, card_pirate, "pirate")

func _setup_button(btn: Button, card: PanelContainer, char_id: String) -> void:
	if btn:
		btn.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		UIJuiceHelper.attach_button_juice(btn, 0.92, 1.06)
		btn.pressed.connect(func():
			_on_character_selected(char_id)
		)
	if card:
		card.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_on_character_selected(char_id)
		)

func open_character_select() -> void:
	visible = true
	get_tree().paused = true
	if panel:
		panel.modulate.a = 1.0

func _on_character_selected(char_id: String) -> void:
	SoundManager.play_wave_horn()
	GameManager.selected_character = char_id
	GameManager.reset_game()
	
	visible = false
	get_tree().paused = false
	character_chosen.emit(char_id)
	GameManager.wave_started.emit(1)
