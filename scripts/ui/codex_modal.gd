extends CanvasLayer

## Sokak Güncesi & Koleksiyon Ekranı (Codex & Bestiary Modal)
## Fare türleri, silah sinerjileri ve kedi kahramanlarını inceleyen retro ansiklopedi.

@onready var close_btn: Button = $Control/Panel/VBox/Header/CloseButton
@onready var tab_rats_btn: Button = $Control/Panel/VBox/TabBar/RatsTabBtn
@onready var tab_weapons_btn: Button = $Control/Panel/VBox/TabBar/WeaponsTabBtn
@onready var tab_cats_btn: Button = $Control/Panel/VBox/TabBar/CatsTabBtn
@onready var content_scroll: ScrollContainer = $Control/Panel/VBox/ContentScroll
@onready var items_container: VBoxContainer = $Control/Panel/VBox/ContentScroll/ItemsContainer

var current_tab: String = "rats"

const CODEX_RATS = [
	{
		"name": "Standart Sokak Faresi",
		"icon": "🐭",
		"type": "Temel Kemirgen",
		"stats": "Can: 20 | Hız: 120 | Hasar: 10",
		"desc": "Sokakları istila eden sürü fareleri. Tek başlarına zayıftırlar ancak kalabalık gruplar halinde tehlikelidirler."
	},
	{
		"name": "Çevik Atılgan Fare",
		"icon": "⚡",
		"type": "Suikastçı Kemirgen",
		"stats": "Can: 14 | Hız: 230 | Hasar: 12",
		"desc": "Ani yön değiştirip kediye doğru hızlı atılımlar yapar. Dikkatli manevra ve alan silahları gerektirir."
	},
	{
		"name": "Zehirli Tüküren Fare",
		"icon": "🧪",
		"type": "Menzilli Kemirgen",
		"stats": "Can: 25 | Hız: 100 | Hasar: 14",
		"desc": "Kediye yaklaşmadan uzaktan asit topları fırlatır. Öncelikli olarak avlanması gereken hedeftir."
	},
	{
		"name": "Dev Şişman Fare",
		"icon": "🐗",
		"type": "Tank Kemirgen",
		"stats": "Can: 85 | Hız: 75 | Hasar: 20",
		"desc": "Lağım peynirleriyle semirmiş dev gövdesiyle darbeleri emer ve önündeki farelere kalkan olur."
	},
	{
		"name": "Büyük Fare Kralı (Boss)",
		"icon": "👑",
		"type": "Hükümdar Boss",
		"stats": "Can: 500+ | Hız: 110 | Hasar: 25",
		"desc": "Kuyrukları birbirine düğümlenmiş kadim lağım lideri. Minik fare orduları doğurur ve dev şok dalgaları saçar."
	}
]

const CODEX_WEAPONS = [
	{
		"name": "Kara Çelik Kılıç",
		"icon": "🗡️",
		"synergy": "⚔️ Bıçak Sinerjisi (+Kritik & +Alan)",
		"desc": "Kedinin en sadık yakın dövüş kılıcı. Önündeki tüm fareleri kavisli bir hilal savurmasıyla biçer."
	},
	{
		"name": "Vahşi Pençeler",
		"icon": "🐾",
		"synergy": "⚔️ Bıçak Sinerjisi (+Kritik & +Hız)",
		"desc": "Çok yüksek saldırı hızına sahip çift pençe saldırısı. Yakın mesafedeki hedefleri saniyeler içinde parçalar."
	},
	{
		"name": "Balık Bumerangı",
		"icon": "🐟",
		"synergy": "🔨 Ağır Sinerji (+Zırh & +Geri Tepme)",
		"desc": "Fırlatıldıktan sonra dönerek geri gelen kurutulmuş kılçık bumerang. Gidişte ve dönüşte iki kez hasar vurur."
	},
	{
		"name": "Yün Yumağı Bombası",
		"icon": "🧶",
		"synergy": "🔨 Ağır Sinerji (+Geniş Patlama)",
		"desc": "Fırlatıldığı noktada devasa bir patlama yaratarak fare sürülerini geri savuran infilak yumağı."
	},
	{
		"name": "Kara Magnum",
		"icon": "🔫",
		"synergy": "🎯 Silah Sinerjisi (+Menzil & +Delme)",
		"desc": "Büyük kalibreli mermiler sıkan tok tabanca. Tek vuruşta devasa hasar verir."
	},
	{
		"name": "Glock-17",
		"icon": "💥",
		"synergy": "🎯 Silah Sinerjisi (+Seri Atış)",
		"desc": "Yüksek ateşleme hızına sahip hafif tabanca. Seri atışlarıyla kalabalıkları durdurur."
	},
	{
		"name": "Kediotu Yayı",
		"icon": "🏹",
		"synergy": "🎯 Silah / Bıçak Hibrit",
		"desc": "Birden fazla fareyi delip geçen keskin oklar fırlatan uzun menzilli avcı yayı."
	}
]

const CODEX_CATS = [
	{
		"name": "Kara Kedi (Varsayılan)",
		"icon": "🐈‍⬛",
		"role": "Dengeli Sokak Savaşçısı",
		"desc": "Tüm alanlarda dengeli istatistiklere sahip sokakların koruyucusu. Çelik Kılıç ile başlar."
	},
	{
		"name": "Keskin Nişancı",
		"icon": "🎯",
		"role": "Menzilli Atış Uzmanı",
		"desc": "+30 Menzil, +%15 Kritik ve Glock-17 ile başlar. Uzaktan avlanmayı seven oyuncular için idealdir."
	},
	{
		"name": "Vahşi Pençeci",
		"icon": "🐆",
		"role": "Çevik Suikastçı",
		"desc": "+40 Hareket Hızı, +%30 Saldırı Hızı ve Çift Pençeler ile başlar. Yüksek refleks gerektirir."
	},
	{
		"name": "Zırhlı Şövalye",
		"icon": "🛡️",
		"role": "Yıkılmaz Tank",
		"desc": "+40 Maks Can, +4 Zırh ve Balık Bumerangı ile başlar. Hataları affeden dayanıklı bir yapıya sahiptir."
	},
	{
		"name": "Korsan Kedi",
		"icon": "🏴‍☠️",
		"role": "Gözü Kara Hazine Avcısı",
		"desc": "+%25 Fazla Altın/Koin, +%20 Hasar ve Kara Magnum ile başlar. Ekonomiyi hızla büyütür."
	}
]

func _ready() -> void:
	visible = false
	close_btn.pressed.connect(close_codex)
	UIJuiceHelper.attach_button_juice(close_btn)
	
	tab_rats_btn.pressed.connect(func(): _switch_tab("rats"))
	tab_weapons_btn.pressed.connect(func(): _switch_tab("weapons"))
	tab_cats_btn.pressed.connect(func(): _switch_tab("cats"))
	
	UIJuiceHelper.attach_button_juice(tab_rats_btn)
	UIJuiceHelper.attach_button_juice(tab_weapons_btn)
	UIJuiceHelper.attach_button_juice(tab_cats_btn)
	
	_render_content()

func open_codex() -> void:
	visible = true
	get_tree().paused = true
	_render_content()
	
	var panel = $Control/Panel
	panel.pivot_offset = panel.size * 0.5
	panel.scale = Vector2(0.85, 0.85)
	panel.modulate.a = 0.0
	
	var tw = create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.set_ignore_time_scale(true)
	tw.tween_property(panel, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(panel, "modulate:a", 1.0, 0.15)

func close_codex() -> void:
	var panel = $Control/Panel
	var tw = create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.set_ignore_time_scale(true)
	tw.tween_property(panel, "scale", Vector2(0.9, 0.9), 0.12).set_trans(Tween.TRANS_QUAD)
	tw.parallel().tween_property(panel, "modulate:a", 0.0, 0.12)
	tw.tween_callback(func():
		visible = false
		# Eğer oyun içinde duraklatmadan açılmadıysa unpause etme
		if not GameManager.is_wave_active:
			get_tree().paused = false
	)

func _switch_tab(tab_name: String) -> void:
	current_tab = tab_name
	_render_content()

func _render_content() -> void:
	for child in items_container.get_children():
		child.queue_free()
		
	# Sekme buton renklerini güncelle
	tab_rats_btn.modulate = Color(1.3, 1.3, 1.3) if current_tab == "rats" else Color(0.7, 0.7, 0.7)
	tab_weapons_btn.modulate = Color(1.3, 1.3, 1.3) if current_tab == "weapons" else Color(0.7, 0.7, 0.7)
	tab_cats_btn.modulate = Color(1.3, 1.3, 1.3) if current_tab == "cats" else Color(0.7, 0.7, 0.7)
	
	var data_list = []
	if current_tab == "rats":
		data_list = CODEX_RATS
	elif current_tab == "weapons":
		data_list = CODEX_WEAPONS
	else:
		data_list = CODEX_CATS
		
	for entry in data_list:
		var card = _build_entry_card(entry)
		items_container.add_child(card)

func _build_entry_card(entry: Dictionary) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 75)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.09, 0.11, 0.17, 0.95)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.25, 0.35, 0.55, 0.8)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left = 10
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", style)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 14)
	
	var icon_lbl = Label.new()
	icon_lbl.text = entry.get("icon", "⭐")
	icon_lbl.add_theme_font_size_override("font_size", 32)
	icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(icon_lbl)
	
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 3)
	
	var title_hbox = HBoxContainer.new()
	var title_lbl = Label.new()
	title_lbl.text = entry.get("name", "")
	title_lbl.add_theme_font_size_override("font_size", 14)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.35))
	title_hbox.add_child(title_lbl)
	
	var sub_text = entry.get("type", entry.get("synergy", entry.get("role", "")))
	var sub_lbl = Label.new()
	sub_lbl.text = " (" + sub_text + ")"
	sub_lbl.add_theme_font_size_override("font_size", 11)
	sub_lbl.add_theme_color_override("font_color", Color(0.35, 0.85, 0.95))
	title_hbox.add_child(sub_lbl)
	vbox.add_child(title_hbox)
	
	if entry.has("stats"):
		var stats_lbl = Label.new()
		stats_lbl.text = entry["stats"]
		stats_lbl.add_theme_font_size_override("font_size", 11)
		stats_lbl.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45))
		vbox.add_child(stats_lbl)
		
	var desc_lbl = Label.new()
	desc_lbl.text = entry.get("desc", "")
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.add_theme_font_size_override("font_size", 11)
	desc_lbl.add_theme_color_override("font_color", Color(0.85, 0.88, 0.92))
	vbox.add_child(desc_lbl)
	
	hbox.add_child(vbox)
	panel.add_child(hbox)
	return panel
