extends Node2D

## Ana Oyun Sahnesi Yöneticisi (Main Scene)
## Kamera takibi, Boss Bar bağlantısı, 2D Sokak Işıklandırması, Retro CRT ve Kromatik Aberasyon

@onready var camera: Camera2D = $Camera2D
@onready var player: CharacterBody2D = $Player
@onready var wave_manager: Node2D = $WaveManager
@onready var hud: CanvasLayer = $HUD
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var shop: CanvasLayer = $Shop
@onready var level_up_draft: CanvasLayer = $LevelUpDraft
@onready var main_menu: CanvasLayer = $MainMenu
@onready var postprocess_rect: ColorRect = $VignetteOverlay/ColorRect


var trauma: float = 0.0
var trauma_decay: float = 2.4
var max_offset: Vector2 = Vector2(16.0, 16.0)
var max_roll: float = 0.04
var last_hp: float = 100.0

func _ready() -> void:
	wave_manager.time_updated.connect(hud.update_timer)
	wave_manager.boss_spawned.connect(_on_boss_spawned)
	hud.pause_requested.connect(pause_menu.open_pause_menu)
	GameManager.health_changed.connect(_on_health_changed)
	GameManager.screen_shake_requested.connect(add_screen_shake)
	GameManager.chromatic_aberration_requested.connect(_on_chromatic_aberration_requested)
	GameManager.feline_rage_state_changed.connect(_on_feline_rage_state_changed)
	GameManager.wave_completed.connect(_on_wave_completed)
	level_up_draft.draft_completed.connect(shop.open_shop)
	
	_setup_street_lighting()
	_setup_street_fog()

func _setup_street_fog() -> void:
	var fog = CPUParticles2D.new()
	fog.amount = 26
	fog.lifetime = 7.5
	fog.preprocess = 3.5
	fog.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	fog.emission_rect_extents = Vector2(850, 1200)
	fog.direction = Vector2(1, 0.2)
	fog.spread = 30.0
	fog.gravity = Vector2.ZERO
	fog.initial_velocity_min = 6.0
	fog.initial_velocity_max = 18.0
	fog.scale_amount_min = 28.0
	fog.scale_amount_max = 56.0
	
	var grad = Gradient.new()
	grad.colors = PackedColorArray([
		Color(0.4, 0.5, 0.75, 0.0),
		Color(0.45, 0.55, 0.8, 0.07),
		Color(0.4, 0.5, 0.75, 0.0)
	])
	grad.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	fog.color_ramp = grad
	
	add_child(fog)

func _setup_street_lighting() -> void:
	# 1. Gece Mavisi Ortam Aydınlatması
	var dir_light = DirectionalLight2D.new()
	dir_light.color = Color(0.78, 0.82, 0.94, 1.0)
	dir_light.energy = 0.85
	add_child(dir_light)
	
	# 2. Sokak Lambaları / Sıcak Işık Havuzları (4 Köşe)
	var light_positions = [
		Vector2(-420, -620),
		Vector2(420, -620),
		Vector2(-420, 620),
		Vector2(420, 620)
	]
	
	var light_grad = Gradient.new()
	light_grad.colors = PackedColorArray([Color(1.0, 0.88, 0.5, 1.0), Color(1.0, 0.88, 0.5, 0.0)])
	light_grad.offsets = PackedFloat32Array([0.0, 1.0])
	var light_tex = GradientTexture2D.new()
	light_tex.gradient = light_grad
	light_tex.fill = GradientTexture2D.FILL_RADIAL
	light_tex.fill_from = Vector2(0.5, 0.5)
	light_tex.fill_to = Vector2(0.5, 0.0)
	light_tex.width = 380
	light_tex.height = 380
	
	for pos in light_positions:
		var p_light = PointLight2D.new()
		p_light.position = pos
		p_light.texture = light_tex
		p_light.texture_scale = 1.8
		p_light.color = Color(1.0, 0.84, 0.45, 0.9)
		p_light.energy = 1.15
		add_child(p_light)

func _on_wave_completed(_wave_num: int) -> void:
	GameManager.process_wave_completion_rewards()
	level_up_draft.open_draft()

func _process(delta: float) -> void:
	if is_instance_valid(player):
		camera.global_position = player.global_position
		
	if trauma > 0.0:
		trauma = max(0.0, trauma - trauma_decay * delta)
		var shake = trauma * trauma # Quadratic trauma curve
		camera.offset = Vector2(
			randf_range(-max_offset.x, max_offset.x) * shake,
			randf_range(-max_offset.y, max_offset.y) * shake
		)
		camera.rotation = randf_range(-max_roll, max_roll) * shake
	else:
		camera.offset = Vector2.ZERO
		camera.rotation = 0.0

func _on_boss_spawned(boss_node: Node2D) -> void:
	var title = "BÜYÜK FARE KRALI" if boss_node.is_final_boss else "FARE KRALI"
	hud.show_boss_bar(title, boss_node.max_health)
	boss_node.boss_hp_updated.connect(hud.update_boss_bar)
	GameManager.request_chromatic_aberration(0.015, 0.3)

func _on_health_changed(current: float, _max: float) -> void:
	if current < last_hp:
		add_screen_shake(0.45)
		GameManager.request_chromatic_aberration(0.012, 0.16)
	last_hp = current

func add_screen_shake(amount: float) -> void:
	var normalized = amount if amount <= 1.0 else min(1.0, amount / 12.0)
	trauma = clampf(trauma + normalized, 0.0, 1.0)

func _on_chromatic_aberration_requested(strength: float, duration: float) -> void:
	if not is_instance_valid(postprocess_rect) or not postprocess_rect.material:
		return
	var mat = postprocess_rect.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("chromatic_aberration", strength)
		var tw = create_tween()
		tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.set_ignore_time_scale(true)
		tw.tween_property(mat, "shader_parameter/chromatic_aberration", 0.0, duration).set_trans(Tween.TRANS_QUAD)

func _on_feline_rage_state_changed(is_active: bool) -> void:
	if not is_instance_valid(postprocess_rect) or not postprocess_rect.material:
		return
	var mat = postprocess_rect.material as ShaderMaterial
	if mat:
		var target_intensity = 1.0 if is_active else 0.0
		var tw = create_tween()
		tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.set_ignore_time_scale(true)
		tw.tween_property(mat, "shader_parameter/rage_intensity", target_intensity, 0.25)
