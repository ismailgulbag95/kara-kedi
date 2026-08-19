class_name CityDepthManager
extends Node2D

## Üstten Bakış (Top-Down) Yoğun & Dinamik Gece Şehri Çatıları Yöneticisi
## Arenanın hemen etrafını saran komşu gökdelen çatıları, neon tabelalar, ışıklı cam tavanlar, güneş panelleri, dönen fanlar ve sokak ışıkları.

const FAN_BODY_TEX = preload("res://assets/textures/topdown_ac_body.png")
const FAN_BLADE_TEX = preload("res://assets/textures/topdown_fan_blade.png")
const WATER_TOWER_TEX = preload("res://assets/textures/topdown_water_tower.png")

var spinning_fans: Array[Sprite2D] = []
var neon_glow_lights: Array[Dictionary] = []
var traffic_lanes: Array[Dictionary] = []
var traffic_draw_node: Node2D

func _ready() -> void:
	z_index = -5
	_create_deep_city_traffic()
	_create_dense_rooftop_cityscape()
	_create_arena_rooftop_props()

func _process(delta: float) -> void:
	# 1. Dönen Fan Pervaneleri
	for blade in spinning_fans:
		if is_instance_valid(blade):
			blade.rotation += 15.0 * delta
			
	# 2. Sokak Trafik Işıkları Hareketi
	for lane in traffic_lanes:
		for car in lane.cars:
			car.pos += lane.speed * delta
			if lane.speed > 0 and car.pos > lane.end_pos:
				car.pos = lane.start_pos - randf_range(0, 100)
			elif lane.speed < 0 and car.pos < lane.end_pos:
				car.pos = lane.start_pos + randf_range(0, 100)
				
	if is_instance_valid(traffic_draw_node):
		traffic_draw_node.queue_redraw()

func _create_deep_city_traffic() -> void:
	traffic_draw_node = Node2D.new()
	traffic_draw_node.z_index = -12
	add_child(traffic_draw_node)
	traffic_draw_node.draw.connect(_on_draw_traffic)
	
	# Dar sokak aralıklarında derinlerde hareket eden araba farları
	var lanes_config = [
		{"axis": "x", "fixed": -1120, "start": -2800, "end": 2800, "speed": 190.0, "is_headlight": true},
		{"axis": "x", "fixed": -1160, "start": 2800, "end": -2800, "speed": -180.0, "is_headlight": false},
		{"axis": "x", "fixed": 1120, "start": -2800, "end": 2800, "speed": 220.0, "is_headlight": true},
		{"axis": "x", "fixed": 1160, "start": 2800, "end": -2800, "speed": -200.0, "is_headlight": false},
		{"axis": "y", "fixed": -800, "start": -2800, "end": 2800, "speed": 170.0, "is_headlight": true},
		{"axis": "y", "fixed": -840, "start": 2800, "end": -2800, "speed": -175.0, "is_headlight": false},
		{"axis": "y", "fixed": 800, "start": -2800, "end": 2800, "speed": 185.0, "is_headlight": true},
		{"axis": "y", "fixed": 840, "start": 2800, "end": -2800, "speed": -165.0, "is_headlight": false},
	]
	
	for cfg in lanes_config:
		var cars_list: Array = []
		var count = randi_range(7, 12)
		for _i in range(count):
			cars_list.append({
				"pos": randf_range(-2600, 2600),
				"len": randf_range(16, 26)
			})
		traffic_lanes.append({
			"axis": cfg.axis,
			"fixed": cfg.fixed,
			"start_pos": cfg.start,
			"end_pos": cfg.end,
			"speed": cfg.speed,
			"is_headlight": cfg.is_headlight,
			"cars": cars_list
		})

func _on_draw_traffic() -> void:
	for lane in traffic_lanes:
		var color = Color(1.0, 0.88, 0.45, 0.8) if lane.is_headlight else Color(1.0, 0.2, 0.25, 0.85)
		for car in lane.cars:
			var p = car.pos
			var length = car.len
			if lane.axis == "x":
				traffic_draw_node.draw_line(Vector2(p, lane.fixed), Vector2(p + length, lane.fixed), color, 3.5)
				traffic_draw_node.draw_circle(Vector2(p + length * 0.5, lane.fixed), 4.5, Color(color.r, color.g, color.b, 0.3))
			else:
				traffic_draw_node.draw_line(Vector2(lane.fixed, p), Vector2(lane.fixed, p + length), color, 3.5)
				traffic_draw_node.draw_circle(Vector2(lane.fixed, p + length * 0.5), 4.5, Color(color.r, color.g, color.b, 0.3))

func _create_dense_rooftop_cityscape() -> void:
	# Arenanın (X: -680..680, Y: -1020..1020) hemen dışını saran 16 farklı bina çatısı
	var building_data = [
		# KUZEY BİNALARI (Üst Taraf)
		{"rect": Rect2(-650, -1720, 580, 580), "type": "neon_magenta", "tint": Color(0.24, 0.26, 0.35)},
		{"rect": Rect2(50, -1750, 620, 600), "type": "skylight_gold", "tint": Color(0.22, 0.28, 0.38)},
		{"rect": Rect2(-1380, -1680, 640, 550), "type": "solar_cyan", "tint": Color(0.20, 0.25, 0.34)},
		{"rect": Rect2(780, -1700, 600, 560), "type": "hvac_fans", "tint": Color(0.25, 0.27, 0.36)},
		
		# GÜNEY BİNALARI (Alt Taraf)
		{"rect": Rect2(-640, 1140, 600, 580), "type": "skylight_gold", "tint": Color(0.23, 0.27, 0.36)},
		{"rect": Rect2(60, 1160, 620, 560), "type": "neon_cyan", "tint": Color(0.22, 0.29, 0.39)},
		{"rect": Rect2(-1360, 1120, 620, 560), "type": "hvac_fans", "tint": Color(0.26, 0.28, 0.38)},
		{"rect": Rect2(780, 1150, 600, 580), "type": "solar_cyan", "tint": Color(0.21, 0.26, 0.35)},
		
		# BATI BİNALARI (Sol Taraf)
		{"rect": Rect2(-1480, -960, 680, 580), "type": "neon_amber", "tint": Color(0.25, 0.28, 0.37)},
		{"rect": Rect2(-1460, -320, 660, 640), "type": "skylight_gold", "tint": Color(0.23, 0.26, 0.35)},
		{"rect": Rect2(-1480, 380, 680, 660), "type": "solar_cyan", "tint": Color(0.21, 0.27, 0.37)},
		
		# DOĞU BİNALARI (Sağ Taraf)
		{"rect": Rect2(800, -980, 680, 590), "type": "solar_cyan", "tint": Color(0.22, 0.27, 0.36)},
		{"rect": Rect2(820, -330, 660, 650), "type": "neon_magenta", "tint": Color(0.26, 0.28, 0.39)},
		{"rect": Rect2(800, 380, 680, 680), "type": "hvac_fans", "tint": Color(0.24, 0.27, 0.36)},
		
		# KÖŞE DIŞ BİNALAR
		{"rect": Rect2(-2250, -1700, 780, 750), "type": "skylight_gold", "tint": Color(0.19, 0.22, 0.30)},
		{"rect": Rect2(1500, -1700, 780, 750), "type": "neon_cyan", "tint": Color(0.20, 0.23, 0.32)},
	]
	
	for b in building_data:
		var roof_node = Node2D.new()
		roof_node.position = b.rect.position
		add_child(roof_node)
		
		# Çatı Gövdesi (Panel)
		var p = Panel.new()
		p.size = b.rect.size
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		var style = StyleBoxFlat.new()
		style.bg_color = b.tint
		style.border_width_left = 8
		style.border_width_top = 8
		style.border_width_right = 8
		style.border_width_bottom = 8
		style.border_color = b.tint * 1.55
		style.corner_radius_top_left = 6
		style.corner_radius_top_right = 6
		style.corner_radius_bottom_right = 6
		style.corner_radius_bottom_left = 6
		style.shadow_color = Color(0, 0, 0, 0.95)
		style.shadow_size = 28
		p.add_theme_stylebox_override("panel", style)
		roof_node.add_child(p)
		
		# Çatı Tipi Özellikleri (Neon, Cam Tavan, Güneş Paneli, HVAC)
		_decorate_roof(roof_node, b.rect.size, b.type)

func _decorate_roof(parent: Node2D, size: Vector2, type: String) -> void:
	match type:
		"neon_magenta":
			_add_neon_billboard(parent, size, Color(1.0, 0.2, 0.7, 1.0), "★ 24H NEON CLUB ★")
		"neon_cyan":
			_add_neon_billboard(parent, size, Color(0.2, 0.85, 1.0, 1.0), "♦ CYBER FELINE ♦")
		"neon_amber":
			_add_neon_billboard(parent, size, Color(1.0, 0.75, 0.2, 1.0), "⚡ TOKYO ROOF ⚡")
		"skylight_gold":
			_add_glass_skylight(parent, size)
		"solar_cyan":
			_add_solar_panels(parent, size)
		"hvac_fans":
			_add_hvac_cluster(parent, size)
			
	# Köşeye kırmızı yanıp sönen uçak ikaz feneri
	var beacon = _create_beacon_light(Vector2(28, 28))
	parent.add_child(beacon)

func _add_neon_billboard(parent: Node2D, size: Vector2, neon_color: Color, text: String) -> void:
	var center = size * 0.5
	
	# Neon Tabela Paneli
	var frame = Panel.new()
	frame.position = center - Vector2(140, 45)
	frame.size = Vector2(280, 90)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.10, 0.16, 0.95)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = neon_color
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left = 10
	style.shadow_color = Color(neon_color.r, neon_color.g, neon_color.b, 0.6)
	style.shadow_size = 16
	frame.add_theme_stylebox_override("panel", style)
	parent.add_child(frame)
	
	# Neon Yazısı
	var lbl = Label.new()
	lbl.position = Vector2(10, 24)
	lbl.size = Vector2(260, 40)
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.add_theme_color_override("font_color", neon_color)
	lbl.add_theme_constant_override("outline_size", 4)
	lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	frame.add_child(lbl)
	
	# Neon Işık Kaynağı (Dinamik Parlama)
	var light = PointLight2D.new()
	var grad = Gradient.new()
	grad.colors = PackedColorArray([Color(neon_color.r, neon_color.g, neon_color.b, 0.9), Color(neon_color.r, neon_color.g, neon_color.b, 0.0)])
	grad.offsets = PackedFloat32Array([0.0, 1.0])
	var tex = GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 0.0)
	tex.width = 180
	tex.height = 180
	light.texture = tex
	light.texture_scale = 2.4
	light.color = neon_color
	light.energy = 1.3
	light.position = center
	parent.add_child(light)
	
	# Nefes Alan Neon Animasyonu
	var tw = parent.create_tween().set_loops()
	tw.tween_property(light, "energy", 1.8, randf_range(0.8, 1.4)).set_trans(Tween.TRANS_SINE)
	tw.tween_property(light, "energy", 0.9, randf_range(0.8, 1.4)).set_trans(Tween.TRANS_SINE)

func _add_glass_skylight(parent: Node2D, size: Vector2) -> void:
	var center = size * 0.5
	
	# Altın Sarısı Işıklı Cam Tavan
	var skylight = Panel.new()
	skylight.position = center - Vector2(120, 120)
	skylight.size = Vector2(240, 240)
	skylight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.95, 0.82, 0.45, 0.85) # İç aydınlatma
	style.border_width_left = 6
	style.border_width_top = 6
	style.border_width_right = 6
	style.border_width_bottom = 6
	style.border_color = Color(0.3, 0.35, 0.45)
	style.shadow_color = Color(1.0, 0.85, 0.4, 0.5)
	style.shadow_size = 22
	skylight.add_theme_stylebox_override("panel", style)
	parent.add_child(skylight)
	
	# Cam Izgara Çizgileri
	for ox in [60, 120, 180]:
		var line_v = ColorRect.new()
		line_v.position = Vector2(ox - 2, 0)
		line_v.size = Vector2(4, 240)
		line_v.color = Color(0.25, 0.3, 0.4)
		skylight.add_child(line_v)
		
		var line_h = ColorRect.new()
		line_h.position = Vector2(0, ox - 2)
		line_h.size = Vector2(240, 4)
		line_h.color = Color(0.25, 0.3, 0.4)
		skylight.add_child(line_h)
		
	# Sıcak Işık Kaynağı
	var light = PointLight2D.new()
	var grad = Gradient.new()
	grad.colors = PackedColorArray([Color(1.0, 0.88, 0.5, 0.95), Color(1.0, 0.88, 0.5, 0.0)])
	grad.offsets = PackedFloat32Array([0.0, 1.0])
	var tex = GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 0.0)
	tex.width = 200
	tex.height = 200
	light.texture = tex
	light.texture_scale = 2.6
	light.color = Color(1.0, 0.86, 0.48)
	light.energy = 1.4
	light.position = center
	parent.add_child(light)

func _add_solar_panels(parent: Node2D, size: Vector2) -> void:
	# Sıralı Mavi Güneş Paneli Dizisi (3x3 Grid)
	var start_x = 40.0
	var start_y = 40.0
	var p_w = 70.0
	var p_h = 90.0
	
	var cols = int((size.x - 80) / (p_w + 20))
	var rows = int((size.y - 80) / (p_h + 20))
	
	for r in range(rows):
		for c in range(cols):
			var sp = Panel.new()
			sp.position = Vector2(start_x + c * (p_w + 16), start_y + r * (p_h + 16))
			sp.size = Vector2(p_w, p_h)
			sp.mouse_filter = Control.MOUSE_FILTER_IGNORE
			
			var style = StyleBoxFlat.new()
			style.bg_color = Color(0.12, 0.28, 0.48, 0.95) # Koyu Mavi Panel
			style.border_width_left = 2
			style.border_width_top = 2
			style.border_width_right = 2
			style.border_width_bottom = 2
			style.border_color = Color(0.35, 0.65, 0.95, 0.8) # Parlak çerçeve
			style.shadow_color = Color(0, 0, 0, 0.6)
			style.shadow_size = 6
			sp.add_theme_stylebox_override("panel", style)
			parent.add_child(sp)

func _add_hvac_cluster(parent: Node2D, size: Vector2) -> void:
	# 4 Adet Dönen Havalandırma Santrali ve Su Deposu
	var center = size * 0.5
	var fan_offsets = [
		Vector2(-70, -70),
		Vector2(70, -70),
		Vector2(-70, 70),
		Vector2(70, 70)
	]
	
	for offset in fan_offsets:
		var f_pos = center + offset
		var fan_node = Node2D.new()
		fan_node.position = f_pos
		
		var body = Sprite2D.new()
		body.texture = FAN_BODY_TEX
		fan_node.add_child(body)
		
		var blade = Sprite2D.new()
		blade.texture = FAN_BLADE_TEX
		fan_node.add_child(blade)
		spinning_fans.append(blade)
		
		# Buhar
		var steam = CPUParticles2D.new()
		steam.amount = 4
		steam.lifetime = 1.8
		steam.direction = Vector2(0, -1.0)
		steam.spread = 35.0
		steam.gravity = Vector2(0, -4.0)
		steam.initial_velocity_min = 10.0
		steam.initial_velocity_max = 20.0
		steam.scale_amount_min = 10.0
		steam.scale_amount_max = 22.0
		
		var s_grad = Gradient.new()
		s_grad.colors = PackedColorArray([
			Color(0.6, 0.7, 0.85, 0.0),
			Color(0.6, 0.7, 0.85, 0.12),
			Color(0.6, 0.7, 0.85, 0.0)
		])
		s_grad.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
		steam.color_ramp = s_grad
		fan_node.add_child(steam)
		
		parent.add_child(fan_node)
		
	# Su Deposu
	var tower = Sprite2D.new()
	tower.texture = WATER_TOWER_TEX
	tower.position = Vector2(size.x - 60, size.y - 60)
	parent.add_child(tower)

func _create_beacon_light(pos: Vector2) -> Node2D:
	var node = Node2D.new()
	node.position = pos
	
	var base_dot = ColorRect.new()
	base_dot.size = Vector2(8, 8)
	base_dot.position = Vector2(-4, -4)
	base_dot.color = Color(0.2, 0.25, 0.35)
	node.add_child(base_dot)
	
	var light = PointLight2D.new()
	var grad = Gradient.new()
	grad.colors = PackedColorArray([Color(1.0, 0.15, 0.2, 1.0), Color(1.0, 0.15, 0.2, 0.0)])
	grad.offsets = PackedFloat32Array([0.0, 1.0])
	var tex = GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 0.0)
	tex.width = 64
	tex.height = 64
	light.texture = tex
	light.texture_scale = 1.8
	light.color = Color(1.0, 0.2, 0.25, 1.0)
	light.energy = 1.6
	node.add_child(light)
	
	# Yanıp Sönen İkaz Işığı
	var tw = node.create_tween().set_loops()
	tw.tween_property(light, "energy", 2.2, 0.12).set_trans(Tween.TRANS_QUAD)
	tw.tween_interval(0.1)
	tw.tween_property(light, "energy", 0.0, 0.18).set_trans(Tween.TRANS_QUAD)
	tw.tween_interval(randf_range(1.0, 2.2))
	
	return node

func _create_arena_rooftop_props() -> void:
	# Ana Arena Çatı Köşe Ekipmanları
	var fan_positions = [
		Vector2(-580, -900),
		Vector2(580, -900),
		Vector2(-580, 900),
		Vector2(580, 900)
	]
	
	for pos in fan_positions:
		var fan_node = Node2D.new()
		fan_node.position = pos
		
		var body = Sprite2D.new()
		body.texture = FAN_BODY_TEX
		fan_node.add_child(body)
		
		var blade = Sprite2D.new()
		blade.texture = FAN_BLADE_TEX
		fan_node.add_child(blade)
		spinning_fans.append(blade)
		
		var steam = CPUParticles2D.new()
		steam.amount = 6
		steam.lifetime = 2.2
		steam.direction = Vector2(0.2, -1.0)
		steam.spread = 45.0
		steam.gravity = Vector2(0, -6.0)
		steam.initial_velocity_min = 12.0
		steam.initial_velocity_max = 24.0
		steam.scale_amount_min = 14.0
		steam.scale_amount_max = 28.0
		
		var s_grad = Gradient.new()
		s_grad.colors = PackedColorArray([
			Color(0.6, 0.7, 0.85, 0.0),
			Color(0.6, 0.7, 0.85, 0.14),
			Color(0.6, 0.7, 0.85, 0.0)
		])
		s_grad.offsets = PackedFloat32Array([0.0, 0.4, 1.0])
		steam.color_ramp = s_grad
		fan_node.add_child(steam)
		
		add_child(fan_node)
		
	var tower1 = Sprite2D.new()
	tower1.texture = WATER_TOWER_TEX
	tower1.position = Vector2(-540, -420)
	add_child(tower1)
	
	var tower2 = Sprite2D.new()
	tower2.texture = WATER_TOWER_TEX
	tower2.position = Vector2(540, 420)
	add_child(tower2)
