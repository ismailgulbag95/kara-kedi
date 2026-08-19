extends CharacterBody2D

## Sokak Kedisi Yoldaşı (Stray Cat Companion Ally)
## Oyuncuyu takip eden, yakındaki farelere tırnak atan ve otomatik savaşan sadık müttefik kedi.

@export var move_speed: float = 240.0
@export var attack_damage: float = 25.0
@export var attack_cooldown: float = 0.8

var attack_timer: float = 0.0
var player_ref: Node2D = null

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("allies")
	player_ref = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player_ref):
		player_ref = get_tree().get_first_node_in_group("player")
		return
		
	var target_pos = player_ref.global_position + Vector2(40, -30)
	var dist = global_position.distance_to(target_pos)
	
	if dist > 30.0:
		var dir = (target_pos - global_position).normalized()
		velocity = dir * move_speed
		move_and_slide()
		
	attack_timer += delta
	if attack_timer >= attack_cooldown:
		_try_attack_nearest_rat()

func _try_attack_nearest_rat() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var nearest: Node2D = null
	var min_dist: float = 180.0
	
	for e in enemies:
		if is_instance_valid(e):
			var d = global_position.distance_to(e.global_position)
			if d < min_dist:
				min_dist = d
				nearest = e
				
	if nearest:
		attack_timer = 0.0
		if nearest.has_method("take_damage"):
			nearest.take_damage(attack_damage)
		SoundManager.play_meow(1.2)
		
		# Visual slash arc
		var slash_sc = load("res://scenes/vfx/slash_arc_fx.tscn")
		if slash_sc:
			var s = slash_sc.instantiate()
			s.global_position = nearest.global_position
			get_parent().add_child(s)
