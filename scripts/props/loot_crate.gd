extends CharacterBody2D

## Arena İçi Dinamik Hediye Sandığı (Loot Crate)
## Silahlarla kırılabilir (25 Can). Kırıldığında 1 Süt Çanağı (+20 Can) ve 3-5 altın fırlatır.

@export var max_health: float = 25.0
var current_health: float = 25.0
var is_dead: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var hurtbox: Area2D = $HurtboxArea

const MILK_SCENE = preload("res://scenes/props/milk_heal_item.tscn")
const COIN_SCENE = preload("res://scenes/coin.tscn")

func _ready() -> void:
	add_to_group("crates")
	add_to_group("enemies") # Silahların otomatik hedeflemesi ve temas edebilmesi için
	current_health = max_health
	
	# Giriş zıplama animasyonu
	scale = Vector2(0.1, 0.1)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func take_damage(amount: float, _knockback_dir: Vector2 = Vector2.ZERO, _knock_force: float = 0.0, _is_crit: bool = false) -> void:
	if is_dead:
		return
		
	current_health -= amount
	
	# Darbe esneme ve sallantı efekti
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.2, 0.8), 0.06)
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_ELASTIC)
	
	# Uçuşan Tahta Hasar Rakamı
	var ft_scene = load("res://scenes/vfx/floating_text.tscn")
	if ft_scene:
		var ft = ft_scene.instantiate()
		ft.global_position = global_position + Vector2(randf_range(-10, 10), -12)
		ft.text = str(int(amount))
		ft.color = Color(1.0, 0.8, 0.5)
		get_parent().add_child(ft)
		
	if current_health <= 0.0:
		_break_crate()

func _break_crate() -> void:
	if is_dead:
		return
	is_dead = true
	
	GameManager.request_screen_shake(0.18)
	SoundManager.play_enemy_death()
	
	# 1 Adet İyileştirici Süt Fırlat
	if MILK_SCENE:
		var milk = MILK_SCENE.instantiate()
		milk.global_position = global_position
		get_parent().call_deferred("add_child", milk)
		
	# 3 ile 5 arası Altın Fırlat
	var coin_count = randi_range(3, 5)
	for i in range(coin_count):
		if COIN_SCENE:
			var c = COIN_SCENE.instantiate()
			var spread = Vector2(randf_range(-35, 35), randf_range(-35, 35))
			c.global_position = global_position + spread
			get_parent().call_deferred("add_child", c)
			
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.15)
	tween.tween_callback(queue_free)
