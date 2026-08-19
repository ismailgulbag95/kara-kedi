extends PanelContainer

## Karakter Seçim Kartı Bileşeni (Character Card)

signal card_selected(character_id: String)

var character_id: String = "standard"
var _data: Dictionary = {}

func setup(data: Dictionary) -> void:
	_data = data
	if is_node_ready():
		_render()

func _ready() -> void:
	if not _data.is_empty():
		_render()

func _render() -> void:
	var name_lbl = get_node_or_null("VBoxContainer/NameLabel") as Label
	var title_lbl = get_node_or_null("VBoxContainer/TitleLabel") as Label
	var weapon_lbl = get_node_or_null("VBoxContainer/WeaponLabel") as Label
	var buffs_vbox = get_node_or_null("VBoxContainer/BuffsVBox") as VBoxContainer
	var select_btn = get_node_or_null("VBoxContainer/SelectButton") as Button
	
	if not name_lbl or not select_btn:
		return
		
	character_id = _data.get("id", "standard")
	name_lbl.text = _data.get("name", "Kedi")
	title_lbl.text = _data.get("title", "")
	weapon_lbl.text = "🗡️ " + _data.get("start_weapon_name", "Kılıç")
	
	if buffs_vbox:
		for child in buffs_vbox.get_children():
			child.queue_free()
			
		var buffs = _data.get("buffs", [])
		for b in buffs:
			var lbl = Label.new()
			lbl.text = "• " + str(b)
			lbl.add_theme_font_size_override("font_size", 10)
			lbl.add_theme_color_override("font_color", Color(0.3, 0.95, 0.45))
			buffs_vbox.add_child(lbl)
			
		var debuffs = _data.get("debuffs", [])
		for d in debuffs:
			var lbl = Label.new()
			lbl.text = "• " + str(d)
			lbl.add_theme_font_size_override("font_size", 10)
			lbl.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35))
			buffs_vbox.add_child(lbl)
			
	if not select_btn.pressed.is_connected(_on_select_pressed):
		select_btn.pressed.connect(_on_select_pressed)
		UIJuiceHelper.attach_button_juice(select_btn, 0.92, 1.06)

func _on_select_pressed() -> void:
	card_selected.emit(character_id)
