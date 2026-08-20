extends CharacterBody2D

## Arena İçi Dinamik Sürpriz Ganimet Sandığı (Loot Crate)
## Silahlarla kırılabilir (25 Can).
## Sürpriz İçerik:
## - %45 Şansla: Şifalı Taze Süt Çanağı (+25 HP can basar)
## - %40 Şansla: Zengin Altın Kesesi (10-18 Altın)
## - %15 Şansla: Büyük İkramiye (Hem Süt hem de 20 Altın!)

@export var max_health: float = 25.0
var current_health: float = 25.0
var is_dead: bool = false
var contact_damage: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var hurtbox: Area2D = $HurtboxArea

const MILK_SCENE = preload("res://scenes/props/milk_heal_item.tscn")
const COIN_SCENE = preload("res://scenes/coin.tscn")

func _ready() -> void:
	add_to_group("crates")
	add_to_group("enemies") # Silahların otomatik hedeflemesi ve temas edebilmesi için
	current_health = max_health
	
	# Giriş zıplama animasyonu (gökten düşme hissi)
	scale = Vector2(0.1, 0.1)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func take_damage(amount: float, _knockback_dir: Vector2 = Vector2.ZERO, _knock_force: float = 0.0, _is_crit: bool = false, _source_weapon: String = "") -> void:
	if is_dead:
		return
		
	current_health -= amount
	
	# Darbe esneme ve sallantı efekti
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "scale", Vector2(1.25, 0.8), 0.05)
		tween.tween_property(sprite, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_ELASTIC)
	
	# Uçuşan Tahta Hasar Rakamı
	var ft_scene = load("res://scenes/vfx/floating_text.tscn")
	if ft_scene:
		var ft = ft_scene.instantiate()
		ft.global_position = global_position + Vector2(randf_range(-10, 10), -14)
		get_parent().add_child(ft)
		ft.setup(str(int(amount)), Color(1.0, 0.8, 0.4), 13, false)
		
	if current_health <= 0.0:
		_break_crate()

func _break_crate() -> void:
	if is_dead:
		return
	is_dead = true
	remove_from_group("enemies")
	remove_from_group("crates")
	
	GameManager.request_screen_shake(0.2)
	SoundManager.play_enemy_death()
	
	# Kırılma Tahta Parçacığı
	var death_p_scene = load("res://scenes/vfx/death_particles.tscn")
	if death_p_scene:
		var dp = death_p_scene.instantiate()
		dp.global_position = global_position
		dp.modulate = Color(0.7, 0.45, 0.25)
		get_parent().call_deferred("add_child", dp)
	
	# Sürpriz İçerik Belirle
	var roll = randf()
	if roll < 0.45:
		# %45: Şifalı Süt Kasesi
		_drop_milk()
		_drop_coins(2, 1)
	elif roll < 0.85:
		# %40: Zengin Altın Kesesi (10-18 Altın)
		var total_coins = randi_range(10, 18)
		_drop_coins(total_coins / 2, 2)
	else:
		# %15: Büyük İkramiye (Hem Süt Hem 20 Altın)
		_drop_milk()
		_drop_coins(10, 2)
		
	queue_free()

func _drop_milk() -> void:
	if MILK_SCENE:
		var milk = MILK_SCENE.instantiate()
		milk.global_position = global_position
		get_parent().call_deferred("add_child", milk)

func _drop_coins(count: int, val_per_coin: int) -> void:
	if COIN_SCENE:
		for i in range(count):
			var c = COIN_SCENE.instantiate()
			var offset = Vector2(randf_range(-24.0, 24.0), randf_range(-24.0, 24.0))
			c.global_position = global_position + offset
			c.coin_value = float(val_per_coin)
			get_parent().call_deferred("add_child", c)
