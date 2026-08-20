extends Area2D

## İyileştirici Süt Çanağı (Milk Healing Item)
## Sandık kırıldığında düşer. Oyuncu yaklaştığında çekilir ve +20 Can yeniler.

@export var heal_amount: float = 20.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var col: CollisionShape2D = $CollisionShape2D

var is_collected: bool = false
var float_offset: float = 0.0
var target_player: Node2D = null

func _ready() -> void:
	add_to_group("collectibles")
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	
	# Hafif yukarı fırlama animasyonu
	var initial_pos = position
	var tween = create_tween()
	tween.tween_property(self, "position:y", initial_pos.y - 18.0, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", initial_pos.y, 0.25).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func _process(delta: float) -> void:
	if is_collected:
		return
		
	# Hafif süzülme animasyonu
	float_offset += delta * 4.0
	sprite.position.y = sin(float_offset) * 3.0
	
	# Mıknatıs / Yaklaşma Takibi
	if target_player and is_instance_valid(target_player):
		var dir = (target_player.global_position - global_position).normalized()
		global_position += dir * 420.0 * delta
		if global_position.distance_to(target_player.global_position) < 24.0:
			_collect()

func start_attraction(player_ref: Node2D) -> void:
	target_player = player_ref

func _on_area_entered(area: Area2D) -> void:
	if area.name == "MagnetArea":
		target_player = area.get_parent()
	elif area.name == "HurtboxArea":
		_collect()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_collect()

func _collect() -> void:
	if is_collected:
		return
	is_collected = true
	
	GameManager.heal_player(heal_amount)
	GameManager.record_milk_collected()
	SoundManager.play_coin()
	
	# Uçuşan Yeşil İyileşme Metni
	var ft_scene = load("res://scenes/vfx/floating_text.tscn")
	if ft_scene:
		var ft = ft_scene.instantiate()
		ft.global_position = global_position + Vector2(0, -15)
		get_parent().add_child(ft)
		ft.setup("+%d CAN 🥛" % int(heal_amount), Color(0.2, 0.95, 0.4), 14, false)
		
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free)
