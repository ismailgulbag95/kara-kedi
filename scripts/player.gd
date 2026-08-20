extends CharacterBody2D

## Siyah Kedi Ana Karakteri (Player Controller)
## 8-Yönlü Ultra Akıcı Koşma ve Idle Animasyonları, Dinamik 3 Silah Yuvası (Z-Derinliği), Sağlam Dokü Yükleme ve Hasar Algılama

@export var max_health: float = 100.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var hurtbox_area: Area2D = $HurtboxArea
@onready var magnet_area: Area2D = $MagnetArea
@onready var magnet_col: CollisionShape2D = $MagnetArea/CollisionShape2D

@onready var slot_right: Node2D = $WeaponSlots/RightHand
@onready var slot_left: Node2D = $WeaponSlots/LeftHand
@onready var slot_tail: Node2D = $WeaponSlots/Tail

var i_frame_time: float = 0.0
var knockback_velocity: Vector2 = Vector2.ZERO

# 8-Yönlü Karakter Animasyon Veritabanı
const DIRECTIONS = ["south", "south-east", "east", "north-east", "north", "north-west", "west", "south-west"]
var hero_idle_rotations: Dictionary = {}
var hero_running_animations: Dictionary = {}
var current_facing: String = "south"

var walk_frame_idx: int = 0
var anim_timer: float = 0.0
var step_bob_timer: float = 0.0
const FRAME_DURATION: float = 0.075
const PLAYER_BASE_SCALE: float = 1.5 # 48x48 piksel karakter için dengeli arena ölçeği

const WEAPON_SCENES = {
	"sword": preload("res://scenes/weapons/weapon_sword.tscn"),
	"claws": preload("res://scenes/weapons/weapon_claws.tscn"),
	"fish_boomerang": preload("res://scenes/weapons/weapon_fish_boomerang.tscn"),
	"yarn_bomb": preload("res://scenes/weapons/weapon_yarn_bomb.tscn"),
	"magnum": preload("res://scenes/weapons/weapon_magnum.tscn"),
	"glock": preload("res://scenes/weapons/weapon_glock.tscn"),
	"bow": preload("res://scenes/weapons/weapon_bow.tscn"),
	"fused_yarn_boomerang": preload("res://scenes/weapons/weapon_yarn_bomb.tscn"),
	"fused_claw_gun": preload("res://scenes/weapons/weapon_glock.tscn"),
	"fused_storm_bow": preload("res://scenes/weapons/weapon_bow.tscn")
}

const PALETTE_SHADER = preload("res://assets/shaders/palette_swap.gdshader")
var actor_material: ShaderMaterial

func _ready() -> void:
	add_to_group("player")
	GameManager.weapons_updated.connect(_update_equipped_weapons)
	magnet_area.area_entered.connect(_on_magnet_area_entered)
	hurtbox_area.area_entered.connect(_on_hurtbox_area_entered)
	
	actor_material = ShaderMaterial.new()
	actor_material.shader = PALETTE_SHADER
	actor_material.set_shader_parameter("shadow_tint", Color(0.12, 0.08, 0.22, 1.0))
	actor_material.set_shader_parameter("highlight_tint", Color(1.0, 0.88, 0.4, 1.0))
	actor_material.set_shader_parameter("grading_strength", 0.15)
	actor_material.set_shader_parameter("flash_color", Color(1.0, 0.25, 0.25, 1.0))
	sprite.material = actor_material
	
	_load_all_sprites()
	_update_equipped_weapons()
	_update_magnet_radius()
	_create_ground_shadow()

func _load_texture_robust(path: String) -> Texture2D:
	# 1. Standart Godot ResourceLoader kontrolü
	if ResourceLoader.exists(path):
		var res = load(path)
		if res is Texture2D:
			return res
			
	# 2. Doğrudan dosya sisteminden yükleme (Unimported PNG fallback)
	if FileAccess.file_exists(path):
		var img = Image.load_from_file(path)
		if img and not img.is_empty():
			return ImageTexture.create_from_image(img)
			
	# 3. Global işletim sistemi yolu ile yükleme
	var global_path = ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(global_path):
		var img = Image.load_from_file(global_path)
		if img and not img.is_empty():
			return ImageTexture.create_from_image(img)
			
	return null

func _create_ground_shadow() -> void:
	var shadow = Polygon2D.new()
	var points = PackedVector2Array()
	var rad_x = 18.0
	var rad_y = 9.0
	for i in range(12):
		var angle = float(i) * TAU / 12.0
		points.append(Vector2(cos(angle) * rad_x, sin(angle) * rad_y))
	shadow.polygon = points
	shadow.color = Color(0.02, 0.02, 0.06, 0.42)
	shadow.position = Vector2(0, 18.0)
	shadow.z_index = -1
	add_child(shadow)
	move_child(shadow, 0)

func _load_all_sprites() -> void:
	hero_idle_rotations.clear()
	hero_running_animations.clear()
	
	var base_rot_path = "res://assets/textures/karakedi_hero/rotations/"
	var base_run_path = "res://assets/textures/karakedi_hero/animations/Running/"
	
	for dir in DIRECTIONS:
		# Idle yönleri (rotations)
		var rot_file = "%s%s.png" % [base_rot_path, dir]
		var tex = _load_texture_robust(rot_file)
		if not tex:
			tex = _load_texture_robust("res://assets/textures/player_character/rotations/%s.png" % dir)
		if tex:
			hero_idle_rotations[dir] = tex
			
		# Koşma animasyonu kareleri (Running animations - 8 kare)
		var run_frames: Array[Texture2D] = []
		for f in range(8):
			var frame_file = "%s%s/frame_%03d.png" % [base_run_path, dir, f]
			var f_tex = _load_texture_robust(frame_file)
			if f_tex:
				run_frames.append(f_tex)
				
		if run_frames.size() == 0 and tex != null:
			run_frames.append(tex)
		hero_running_animations[dir] = run_frames
		
	if hero_idle_rotations.has("south"):
		sprite.texture = hero_idle_rotations["south"]
	elif sprite.texture == null:
		var fallback_tex = _load_texture_robust("res://assets/textures/player.png")
		if fallback_tex:
			sprite.texture = fallback_tex
			
	_update_weapon_slots_layout(current_facing)

func _get_direction_8(vec: Vector2) -> String:
	if vec.length_squared() < 0.001:
		return current_facing
	var angle = vec.angle()
	var norm_angle = fposmod(angle + PI / 8.0, TAU)
	var octant = int(norm_angle / (TAU / 8.0))
	match octant:
		0: return "east"
		1: return "south-east"
		2: return "south"
		3: return "south-west"
		4: return "west"
		5: return "north-west"
		6: return "north"
		7: return "north-east"
	return "south"

func _update_weapon_slots_layout(direction: String) -> void:
	match direction:
		"south":
			slot_right.position = Vector2(16, 6)
			slot_right.z_index = 1
			slot_left.position = Vector2(-16, 6)
			slot_left.z_index = 1
			slot_tail.position = Vector2(0, -10)
			slot_tail.z_index = -1
		"south-east":
			slot_right.position = Vector2(16, 4)
			slot_right.z_index = 1
			slot_left.position = Vector2(-10, 8)
			slot_left.z_index = 1
			slot_tail.position = Vector2(-12, -8)
			slot_tail.z_index = -1
		"east":
			slot_right.position = Vector2(16, 2)
			slot_right.z_index = 1
			slot_left.position = Vector2(-4, 4)
			slot_left.z_index = -1
			slot_tail.position = Vector2(-16, 0)
			slot_tail.z_index = -1
		"north-east":
			slot_right.position = Vector2(14, -6)
			slot_right.z_index = -1
			slot_left.position = Vector2(-10, -2)
			slot_left.z_index = -1
			slot_tail.position = Vector2(-14, 8)
			slot_tail.z_index = 1
		"north":
			slot_right.position = Vector2(14, -6)
			slot_right.z_index = -1
			slot_left.position = Vector2(-14, -6)
			slot_left.z_index = -1
			slot_tail.position = Vector2(0, 12)
			slot_tail.z_index = 1
		"north-west":
			slot_right.position = Vector2(10, -2)
			slot_right.z_index = -1
			slot_left.position = Vector2(-14, -6)
			slot_left.z_index = -1
			slot_tail.position = Vector2(14, 8)
			slot_tail.z_index = 1
		"west":
			slot_right.position = Vector2(4, 4)
			slot_right.z_index = -1
			slot_left.position = Vector2(-16, 2)
			slot_left.z_index = 1
			slot_tail.position = Vector2(16, 0)
			slot_tail.z_index = -1
		"south-west":
			slot_right.position = Vector2(10, 8)
			slot_right.z_index = 1
			slot_left.position = Vector2(-16, 4)
			slot_left.z_index = 1
			slot_tail.position = Vector2(12, -8)
			slot_tail.z_index = -1

func _update_magnet_radius() -> void:
	if magnet_col and magnet_col.shape is CircleShape2D:
		magnet_col.shape.radius = GameManager.magnet_radius

func _update_equipped_weapons() -> void:
	for slot_node in [slot_right, slot_left, slot_tail]:
		for child in slot_node.get_children():
			child.queue_free()
			
	for i in range(3):
		var weapon_data = GameManager.equipped_weapons[i]
		var slot_node: Node2D = null
		match i:
			0: slot_node = slot_right
			1: slot_node = slot_left
			2: slot_node = slot_tail
			
		if weapon_data != null and weapon_data.has("id"):
			var weapon_id = weapon_data["id"]
			if WEAPON_SCENES.has(weapon_id):
				var weapon_inst = WEAPON_SCENES[weapon_id].instantiate()
				weapon_inst.slot_index = i
				weapon_inst.tier = weapon_data.get("tier", 1)
				slot_node.add_child(weapon_inst)

func _physics_process(delta: float) -> void:
	if GameManager.is_game_over:
		return
		
	if i_frame_time > 0.0:
		i_frame_time -= delta
		
	# Girdi: Klavye (WASD) veya Sanal Dokunmatik Joystick
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if GameManager.joystick_vector != Vector2.ZERO:
		input_dir = GameManager.joystick_vector
		
	if input_dir.length() > 1.0:
		input_dir = input_dir.normalized()

	if input_dir.length() > 0.1:
		velocity = input_dir * GameManager.move_speed
		_process_movement_animation(input_dir, delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, GameManager.move_speed * 6.0 * delta)
		_process_idle_animation(delta)

	# Geri tepme (Knockback) uygulama
	if knockback_velocity.length() > 5.0:
		velocity += knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, delta * 1200.0)

	move_and_slide()
	
	# Doğrudan fiziksel temas hasarı kontrolü (Slide Collisions)
	if i_frame_time <= 0.0:
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if is_instance_valid(collider) and collider.is_in_group("enemies"):
				var dmg = collider.contact_damage if "contact_damage" in collider else 10.0
				var knock_dir = -collision.get_normal()
				take_damage(dmg, knock_dir, 180.0)
				break

func _process_movement_animation(dir: Vector2, delta: float) -> void:
	current_facing = _get_direction_8(dir)
	_update_weapon_slots_layout(current_facing)
	
	# Dinamik kare süresi (Karakterin hızı arttıkça animasyon orantılı hızlanır)
	var speed_ratio = clamp(GameManager.move_speed / 220.0, 0.7, 2.2)
	var frame_dur = FRAME_DURATION / speed_ratio
	
	anim_timer += delta
	if anim_timer >= frame_dur:
		anim_timer = 0.0
		var frames: Array = hero_running_animations.get(current_facing, [])
		if frames.size() > 0:
			walk_frame_idx = (walk_frame_idx + 1) % frames.size()
			sprite.texture = frames[walk_frame_idx]
		elif hero_idle_rotations.has(current_facing):
			sprite.texture = hero_idle_rotations[current_facing]
			
	# Koşarken hafif adım yaylanması (squash & stretch)
	step_bob_timer += delta * speed_ratio * 18.0
	var bob = sin(step_bob_timer) * 0.05
	sprite.scale = Vector2(PLAYER_BASE_SCALE * (1.0 + bob), PLAYER_BASE_SCALE * (1.0 - bob))

func _process_idle_animation(delta: float = 0.016) -> void:
	walk_frame_idx = 0
	anim_timer = 0.0
	step_bob_timer = 0.0
	
	if hero_idle_rotations.has(current_facing):
		sprite.texture = hero_idle_rotations[current_facing]
		
	sprite.scale = Vector2(PLAYER_BASE_SCALE, PLAYER_BASE_SCALE)
	_update_weapon_slots_layout(current_facing)

func take_damage(amount: float, knockback_dir: Vector2 = Vector2.ZERO, knock_force: float = 180.0) -> void:
	if i_frame_time > 0.0 or GameManager.is_game_over:
		return
		
	i_frame_time = 0.45
	knockback_velocity = knockback_dir * knock_force
	GameManager.damage_player(amount)
	SoundManager.play_damage()
	
	GameManager.hitstop(0.06, 0.04)
	GameManager.request_screen_shake(0.42)
	
	if is_instance_valid(actor_material):
		actor_material.set_shader_parameter("flash_modifier", 1.0)
		var tween = create_tween()
		tween.tween_method(func(v: float):
			if is_instance_valid(actor_material):
				actor_material.set_shader_parameter("flash_modifier", v),
			1.0, 0.0, 0.22
		).set_trans(Tween.TRANS_QUAD)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hitbox") or area.is_in_group("enemy_hurtbox"):
		var enemy = area.get_parent()
		var dmg = 10.0
		var knock_dir = Vector2.ZERO
		if enemy:
			dmg = enemy.contact_damage if "contact_damage" in enemy else 10.0
			knock_dir = (global_position - enemy.global_position).normalized()
		take_damage(dmg, knock_dir, 200.0)

func _on_magnet_area_entered(area: Area2D) -> void:
	if area.is_in_group("collectibles") and area.has_method("start_attraction"):
		area.start_attraction(self)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_SPACE):
		if GameManager.feline_rage >= GameManager.max_feline_rage and not GameManager.is_feline_rage_active:
			GameManager.activate_feline_rage()
