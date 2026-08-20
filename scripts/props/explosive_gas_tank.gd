extends StaticBody2D

## Patlayıcı Gaz / Yangın Tüpü (Explosive Gas Tank)
## Kedinin silahlarıyla vurulduğunda (30 HP) patlar ve dev alev şokuyla fareleri kül eder.

@export var max_health: float = 30.0
var current_health: float = 30.0
var is_broken: bool = false
var is_dead: bool = false
var contact_damage: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

const EXPLOSION_FX = preload("res://scenes/vfx/gas_explosion_fx.tscn")

func _ready() -> void:
	add_to_group("interactive_props")
	add_to_group("enemies") # Silahların otomatik hedefleyebilmesi ve hasar verebilmesi için
	current_health = max_health

func take_damage(amount: float, _knockback_dir: Vector2 = Vector2.ZERO, _knock_force: float = 0.0, _is_crit: bool = false, _source_weapon: String = "") -> void:
	if is_broken or is_dead:
		return
		
	current_health -= amount
	
	# Darbe esneme ve tehlike parlaması
	if sprite:
		var tw = create_tween()
		tw.tween_property(sprite, "scale", Vector2(1.3, 0.75), 0.05)
		tw.tween_property(sprite, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_ELASTIC)
		tw.tween_property(sprite, "modulate", Color(2.5, 1.2, 0.5), 0.06)
		tw.tween_property(sprite, "modulate", Color.WHITE, 0.08)
		
	# Uçuşan hasar rakamı
	var ft_scene = load("res://scenes/vfx/floating_text.tscn")
	if ft_scene:
		var ft = ft_scene.instantiate()
		ft.global_position = global_position + Vector2(randf_range(-8, 8), -18)
		get_parent().add_child(ft)
		ft.setup(str(int(amount)), Color(1.0, 0.4, 0.2), 14, false)
		
	if current_health <= 0.0:
		_explode_tank()

func _explode_tank() -> void:
	if is_broken or is_dead:
		return
	is_broken = true
	is_dead = true
	remove_from_group("enemies")
	remove_from_group("interactive_props")
	
	# Detaylı patlama sahnesini doğur
	if EXPLOSION_FX:
		var exp_node = EXPLOSION_FX.instantiate()
		exp_node.global_position = global_position
		get_parent().call_deferred("add_child", exp_node)
		
	queue_free()
