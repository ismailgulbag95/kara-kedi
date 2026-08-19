extends CharacterBody2D

## Siyah Kedi Ana Karakteri (Player Controller)
## 1.6x Dengeli Ölçek, 8-Yönlü Koşma, Dinamik 3 Silah Yuvası ve Sağlam Hasar Algılama

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

# 8 Yönlü Duruş ve Koşu Dokuları
var idle_textures: Dictionary = {}
var run_animations: Dictionary = {}

var current_dir_name: String = "south"
var anim_frame_idx: int = 0
var anim_timer: float = 0.0
const FRAME_DURATION: float = 0.085
const PLAYER_BASE_SCALE: float = 1.6 # Tam 1.6x dengeli boyut

const WEAPON_SCENES = {
	"sword": preload("res://scenes/weapons/weapon_sword.tscn"),
	"claws": preload("res://scenes/weapons/weapon_claws.tscn"),
	"fish_boomerang": preload("res://scenes/weapons/weapon_fish_boomerang.tscn"),
	"yarn_bomb": preload("res://scenes/weapons/weapon_yarn_bomb.tscn"),
	"magnum": preload("res://scenes/weapons/weapon_magnum.tscn"),
	"glock": preload("res://scenes/weapons/weapon_glock.tscn"),
	"bow": preload("res://scenes/weapons/weapon_bow.tscn")
}

func _ready() -> void:
	add_to_group("player")
	GameManager.weapons_updated.connect(_update_equipped_weapons)
	magnet_area.area_entered.connect(_on_magnet_area_entered)
	hurtbox_area.area_entered.connect(_on_hurtbox_area_entered)
	
	_load_all_sprites()
	_update_equipped_weapons()
	_update_magnet_radius()

func _load_all_sprites() -> void:
	var rot_path = "res://assets/textures/player_character/rotations/"
	var directions = ["south", "south-east", "east", "north-east", "north", "north-west", "west", "south-west"]
	for d in directions:
		var p = rot_path + d + ".png"
		if ResourceLoader.exists(p):
			idle_textures[d] = load(p)
			
	if idle_textures.has("south"):
		sprite.texture = idle_textures["south"]

	var anim_base = "res://assets/textures/player_character/animations/Running/"
	var run_dirs = ["south", "south-east", "east", "north-east", "north", "north-west", "west"]
	for d in run_dirs:
		var frames: Array[Texture2D] = []
		for f in range(8):
			var fp = "%s%s/frame_%03d.png" % [anim_base, d, f]
			if ResourceLoader.exists(fp):
				frames.append(load(fp))
		if frames.size() > 0:
			run_animations[d] = frames

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
		_process_idle_animation()

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
	var angle = dir.angle() # -PI ile PI arası
	var new_dir = "south"
	var mirror_h = false
	
	if angle >= -PI/8 and angle < PI/8:
		new_dir = "east"
	elif angle >= PI/8 and angle < 3*PI/8:
		new_dir = "south-east"
	elif angle >= 3*PI/8 and angle < 5*PI/8:
		new_dir = "south"
	elif angle >= 5*PI/8 and angle < 7*PI/8:
		new_dir = "south-east"
		mirror_h = true
	elif angle >= 7*PI/8 or angle < -7*PI/8:
		new_dir = "west" # Doğrudan sola yürüyüş animasyonu
		mirror_h = false
	elif angle >= -7*PI/8 and angle < -5*PI/8:
		new_dir = "north-west"
		mirror_h = false
	elif angle >= -5*PI/8 and angle < -3*PI/8:
		new_dir = "north" # Doğrudan yukarı 'W' yürüyüş animasyonu
		mirror_h = false
	elif angle >= -3*PI/8 and angle < -PI/8:
		new_dir = "north-east"
		mirror_h = false
		
	current_dir_name = new_dir
	sprite.flip_h = mirror_h
	
	anim_timer += delta
	if anim_timer >= FRAME_DURATION:
		anim_timer = 0.0
		anim_frame_idx = (anim_frame_idx + 1) % 8
		
	if run_animations.has(new_dir):
		var frames = run_animations[new_dir]
		var safe_idx = anim_frame_idx % frames.size()
		sprite.texture = frames[safe_idx]
	elif idle_textures.has(new_dir):
		sprite.texture = idle_textures[new_dir]

	sprite.scale = Vector2(PLAYER_BASE_SCALE, PLAYER_BASE_SCALE)

func _process_idle_animation() -> void:
	anim_frame_idx = 0
	anim_timer = 0.0
	sprite.scale = Vector2(PLAYER_BASE_SCALE, PLAYER_BASE_SCALE)
	sprite.position.y = 0.0
	if idle_textures.has(current_dir_name):
		sprite.texture = idle_textures[current_dir_name]

func take_damage(amount: float, knockback_dir: Vector2 = Vector2.ZERO, knock_force: float = 180.0) -> void:
	if i_frame_time > 0.0 or GameManager.is_game_over:
		return
		
	i_frame_time = 0.45
	knockback_velocity = knockback_dir * knock_force
	GameManager.damage_player(amount)
	SoundManager.play_damage()
	
	var tween = create_tween()
	sprite.modulate = Color(2.5, 0.5, 0.5, 1.0)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)

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
