extends CanvasLayer

## Kalıcı Kedi Barınağı Geliştirme Ağacı (Meta-Progression Shelter Modal)
## Run'lar arasında biriken Kedi Mama Parası (Catnip Whiskers) ile kalıcı stat geliştirmeleri.

signal shelter_closed

@onready var container: VBoxContainer = $Control/Panel/ScrollContainer/UpgradesContainer
@onready var whiskers_lbl: Label = $Control/Panel/WhiskersLabel
@onready var close_btn: Button = $Control/Panel/CloseButton

const STAT_CONFIGS = [
	{"id": "hp", "title": "❤️ Dokuz Can Barınağı", "desc": "Başlangıç Canı +10 HP (Kademeli)", "icon": "🛖"},
	{"id": "dmg", "title": "⚔️ Bilenmiş Tırnaklar", "desc": "Tüm Saldırı Hasarları +%8", "icon": "💅"},
	{"id": "speed", "title": "🐾 Çevik Adımlar", "desc": "Kalıcı Hareket Hızı +10", "icon": "👟"},
	{"id": "luck", "title": "🍀 Uğurlu Patiler", "desc": "Kazanılan Paralar ve Şans +%10", "icon": "🌟"},
	{"id": "coins", "title": "🐟 Başlangıç Mama Stoku", "desc": "Her Oyuna +25 Altın İle Başla", "icon": "🥫"}
]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	close_btn.pressed.connect(_on_close)
	UIJuiceHelper.attach_button_juice(close_btn)

func open_shelter() -> void:
	visible = true
	_update_ui()

func _update_ui() -> void:
	whiskers_lbl.text = "🥫 Mama Parası (Whiskers): %d" % GameManager.whiskers
	
	for child in container.get_children():
		child.queue_free()
		
	for cfg in STAT_CONFIGS:
		var row = _create_upgrade_row(cfg)
		container.add_child(row)

func _create_upgrade_row(cfg: Dictionary) -> PanelContainer:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 58)
	
	var stat_id = cfg["id"]
	var lvl = GameManager.shelter_upgrades.get(stat_id, 0)
	var cost = GameManager.get_shelter_cost(stat_id)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.12, 0.18, 0.95)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.3, 0.7, 1.0, 0.6)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left = 10
	style.content_margin_left = 12
	style.content_margin_right = 12
	card.add_theme_stylebox_override("panel", style)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	card.add_child(hbox)
	
	var icon_lbl = Label.new()
	icon_lbl.text = cfg["icon"]
	icon_lbl.add_theme_font_size_override("font_size", 22)
	hbox.add_child(icon_lbl)
	
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var t_lbl = Label.new()
	t_lbl.text = "%s (Seviye %d)" % [cfg["title"], lvl]
	t_lbl.add_theme_font_size_override("font_size", 13)
	t_lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.4))
	vbox.add_child(t_lbl)
	
	var d_lbl = Label.new()
	d_lbl.text = cfg["desc"]
	d_lbl.add_theme_font_size_override("font_size", 10)
	d_lbl.add_theme_color_override("font_color", Color(0.75, 0.85, 0.95))
	vbox.add_child(d_lbl)
	
	hbox.add_child(vbox)
	
	var btn = Button.new()
	btn.text = "GELİŞTİR (%d 🥫)" % cost if lvl < 5 else "MAX SEVİYE"
	btn.disabled = (lvl >= 5) or (GameManager.whiskers < cost)
	btn.custom_minimum_size = Vector2(130, 36)
	
	var b_style = StyleBoxFlat.new()
	b_style.bg_color = Color(0.2, 0.75, 0.4, 1.0) if not btn.disabled else Color(0.25, 0.28, 0.35, 1.0)
	b_style.corner_radius_top_left = 6
	b_style.corner_radius_top_right = 6
	b_style.corner_radius_bottom_right = 6
	b_style.corner_radius_bottom_left = 6
	btn.add_theme_stylebox_override("normal", b_style)
	btn.add_theme_font_size_override("font_size", 11)
	
	UIJuiceHelper.attach_button_juice(btn)
	
	btn.pressed.connect(func():
		if GameManager.buy_shelter_upgrade(stat_id):
			SoundManager.play_upgrade()
			_update_ui()
	)
	
	hbox.add_child(btn)
	return card

func _on_close() -> void:
	visible = false
	shelter_closed.emit()
