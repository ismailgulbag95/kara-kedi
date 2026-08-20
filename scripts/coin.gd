extends Area2D

## Düşmanlardan Düşen Altın ve Bakır Bozuk Para (Coins)
## Büyük Ana Coinler: Parlak Sarı Altın Bozuk Para (coin_gold.png)
## Küçük Ek Coinler: Metalik Kahverengi Bakır Bozuk Para (coin_copper.png)

@export var coin_value: float = 1.0
@export var is_small_coin: bool = false
var value: float:
	get:
		return coin_value
	set(v):
		coin_value = float(v)

var is_attracted: bool = false
var is_collected: bool = false
var target_player: Node2D = null
var current_speed: float = 0.0
var max_speed: float = 700.0
var acceleration: float = 1300.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var col_shape: CollisionShape2D = $CollisionShape2D

const GOLD_COIN_TEX = preload("res://assets/textures/coin_gold.png")
const COPPER_COIN_TEX = preload("res://assets/textures/coin_copper.png")

func _ready() -> void:
	add_to_group("collectibles")
	
	if is_small_coin:
		sprite.texture = COPPER_COIN_TEX
		scale = Vector2(0.60, 0.60)
		if coin_value == 1.0:
			coin_value = 0.5
	else:
		sprite.texture = GOLD_COIN_TEX
		scale = Vector2(0.75, 0.75)
		
	var scatter_offset = Vector2(randf_range(-18, 18), randf_range(-18, 18))
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", position + scatter_offset, 0.25)
	
	# Hafif Parıltı & Nefes Alma Animasyonu
	var pulse = create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	pulse.tween_property(sprite, "scale", Vector2(1.12, 1.12), 0.38)
	pulse.tween_property(sprite, "scale", Vector2(0.92, 0.92), 0.38)

func _physics_process(delta: float) -> void:
	if is_collected:
		return
		
	if is_attracted and is_instance_valid(target_player):
		var dir = (target_player.global_position - global_position).normalized()
		current_speed = min(max_speed, current_speed + acceleration * delta)
		global_position += dir * current_speed * delta
		
		if global_position.distance_to(target_player.global_position) < 32.0:
			_collect()

func start_attraction(player: Node2D) -> void:
	if not is_attracted and not is_collected:
		is_attracted = true
		target_player = player
		current_speed = 120.0

func _collect() -> void:
	if is_collected:
		return
	is_collected = true
	set_physics_process(false)
	if is_instance_valid(col_shape):
		col_shape.set_deferred("disabled", true)
		
	GameManager.add_coins_value(coin_value)
	SoundManager.play_coin()
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(sprite, "scale", Vector2(1.6, 1.6), 0.1)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.1)
	tween.chain().tween_callback(queue_free)
