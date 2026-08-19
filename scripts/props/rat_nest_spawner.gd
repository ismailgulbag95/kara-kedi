extends StaticBody2D

## Lağım ve Havalandırma Fare Yuvası (Rat Nest Spawner)
## Yok edilebilir, oyuncu yaklaştıkça fare üretimini hızlandıran ve yok edildiğinde yüksek miktar Whiskers düşüren yapı.

signal nest_destroyed(position: Vector2)

@export var max_hp: float = 120.0
var current_hp: float = 120.0
@export var base_spawn_interval: float = 4.0
@export var active_spawn_interval: float = 1.2
@export var warning_radius: float = 220.0

var spawn_timer: float = 0.0
var is_player_nearby: bool = false
var player_ref: Node2D = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var warning_circle: Line2D = $WarningCircle

func _ready() -> void:
	add_to_group("enemy_nests")
	current_hp = max_hp
	_setup_warning_circle()

func _setup_warning_circle() -> void:
	if not warning_circle:
		warning_circle = Line2D.new()
		warning_circle.width = 3.0
		warning_circle.default_color = Color(1.0, 0.2, 0.2, 0.4)
		add_child(warning_circle)
		
	var points = PackedVector2Array()
	var num_points = 32
	for i in range(num_points + 1):
		var angle = (float(i) / num_points) * TAU
		points.append(Vector2(cos(angle), sin(angle)) * warning_radius)
	warning_circle.points = points

func _process(delta: float) -> void:
	if not player_ref:
		player_ref = get_tree().get_first_node_in_group("player")
		return
		
	var dist = global_position.distance_to(player_ref.global_position)
	is_player_nearby = dist <= warning_radius
	
	if warning_circle:
		warning_circle.default_color.a = 0.85 if is_player_nearby else 0.35
		
	var current_interval = active_spawn_interval if is_player_nearby else base_spawn_interval
	spawn_timer += delta
	if spawn_timer >= current_interval:
		spawn_timer = 0.0
		_spawn_rat_pack()

func _spawn_rat_pack() -> void:
	var wave_mgr = get_tree().get_first_node_in_group("wave_manager")
	if wave_mgr and wave_mgr.has_method("spawn_rat_from_nest"):
		wave_mgr.spawn_rat_from_nest(global_position)

func take_damage(amount: float) -> void:
	current_hp -= amount
	
	# Flash effect
	if sprite:
		var tw = create_tween()
		tw.tween_property(sprite, "modulate", Color(2.5, 0.5, 0.5), 0.08)
		tw.tween_property(sprite, "modulate", Color(0.35, 0.15, 0.25, 1.0), 0.08)
		
	if current_hp <= 0.0:
		_destroy_nest()

func _destroy_nest() -> void:
	SoundManager.play_explosion()
	nest_destroyed.emit(global_position)
	
	# Drop lots of coins & Whiskers
	GameManager.whiskers += 15
	GameManager.add_coins(35)
	
	# Floating text
	var ft_sc = load("res://scenes/vfx/floating_text.tscn")
	if ft_sc:
		var ft = ft_sc.instantiate()
		ft.global_position = global_position
		ft.set_text("💥 YUVA İMHASI! +15 🥫", Color(1.0, 0.85, 0.2))
		get_parent().add_child(ft)
		
	queue_free()
