extends CanvasLayer

## Dalga Sonu Seviye Atlama Stat Seçimi (Level-Up Stat Drafting)
## Nadirlik Renkleri (Mavi, Mor, Altın), Sıralı Kart Açılış Animasyonu ve Juicy Seçim Geri Bildirimi

signal draft_completed

@onready var container: HBoxContainer = $Control/Panel/ScrollContainer/CardsContainer
@onready var panel: Panel = $Control/Panel

const RARITY_COLORS = {
	"common": Color(0.25, 0.75, 0.45, 0.95),  # Zümrüt Yeşili
	"rare": Color(0.3, 0.65, 1.0, 0.95),      # Safir Mavisi
	"epic": Color(0.85, 0.45, 1.0, 0.95),     # Büyülü Mor
	"legendary": Color(1.0, 0.85, 0.2, 1.0)   # Parlak Altın
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func open_draft() -> void:
	visible = true
	get_tree().paused = true
	if panel:
		panel.modulate.a = 1.0
	_populate_random_options()

func _populate_random_options() -> void:
	if not container:
		return
		
	for child in container.get_children():
		child.queue_free()
		
	var pool = GameManager.DRAFT_STAT_OPTIONS.duplicate()
	pool.shuffle()
	
	var chosen_count = min(3, pool.size())
	for i in range(chosen_count):
		var opt = pool[i]
		var card = _create_draft_card(opt, i)
		container.add_child(card)
		_animate_card_entry(card, i * 0.08)

func _animate_card_entry(card: PanelContainer, delay_sec: float) -> void:
	card.pivot_offset = Vector2(67, 135)
	card.scale = Vector2(0.85, 0.85)
	card.modulate.a = 1.0
	
	var tween = card.create_tween()
	if tween:
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.set_ignore_time_scale(true)
		if delay_sec > 0.0:
			tween.tween_interval(delay_sec)
		tween.tween_property(card, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _create_draft_card(opt: Dictionary, _index: int) -> PanelContainer:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(135, 270)
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var stat_id = opt.get("id", "")
	var border_col = RARITY_COLORS["common"]
	if stat_id in ["crit", "thorns", "regen"]:
		border_col = RARITY_COLORS["epic"]
	elif stat_id in ["dmg", "atk_spd", "armor"]:
		border_col = RARITY_COLORS["rare"]
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.10, 0.16, 0.98)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = border_col
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_right = 14
	style.corner_radius_bottom_left = 14
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	style.shadow_color = Color(border_col.r, border_col.g, border_col.b, 0.3)
	style.shadow_size = 8
	card.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	card.add_child(vbox)
	
	# İkon
	var icon_lbl = Label.new()
	icon_lbl.text = opt.get("icon", "⭐")
	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_lbl.add_theme_font_size_override("font_size", 28)
	vbox.add_child(icon_lbl)
	
	# Başlık
	var title_lbl = Label.new()
	title_lbl.text = opt.get("title", "Geliştirme")
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 14)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.35))
	title_lbl.add_theme_constant_override("outline_size", 2)
	title_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	vbox.add_child(title_lbl)
	
	# Açıklama
	var desc_lbl = Label.new()
	desc_lbl.text = opt.get("desc", "")
	desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.add_theme_font_size_override("font_size", 11)
	desc_lbl.add_theme_color_override("font_color", Color(0.35, 0.95, 0.55))
	vbox.add_child(desc_lbl)
	
	# Boşluk
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)
	
	# Seç Butonu
	var btn = Button.new()
	btn.text = "GELİŞTİR"
	btn.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	btn.custom_minimum_size = Vector2(0, 36)
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.2, 0.7, 0.35, 1.0)
	btn_style.corner_radius_top_left = 8
	btn_style.corner_radius_top_right = 8
	btn_style.corner_radius_bottom_right = 8
	btn_style.corner_radius_bottom_left = 8
	btn.add_theme_stylebox_override("normal", btn_style)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_font_size_override("font_size", 12)
	
	UIJuiceHelper.attach_button_juice(btn, 0.92, 1.06)
	
	var stat_key = opt.get("stat", "")
	var delta_val = opt.get("delta", 0.0)
	
	var on_select = func():
		_on_option_chosen(card, stat_key, delta_val)
		
	btn.pressed.connect(on_select)
	card.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			on_select.call()
	)
	
	UIJuiceHelper.attach_card_tilt(card)
	
	vbox.add_child(btn)
	return card

func _on_option_chosen(chosen_card: PanelContainer, stat_key: String, delta_val: float) -> void:
	SoundManager.play_wave_horn()
	GameManager.apply_draft_stat(stat_key, delta_val)
	
	# Seçilen kartı öne fırlat, diğerlerini karart
	if container:
		for c in container.get_children():
			if c != chosen_card:
				var t_other = c.create_tween()
				if t_other:
					t_other.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
					t_other.tween_property(c, "modulate:a", 0.2, 0.15)
					
	var t_chosen = chosen_card.create_tween()
	if t_chosen:
		t_chosen.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		t_chosen.tween_property(chosen_card, "scale", Vector2(1.08, 1.08), 0.15).set_trans(Tween.TRANS_BACK)
		t_chosen.tween_interval(0.08)
		t_chosen.tween_callback(func():
			visible = false
			draft_completed.emit()
		)
	else:
		visible = false
		draft_completed.emit()
