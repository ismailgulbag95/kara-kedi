extends Node2D

## Ana Oyun Sahnesi Yöneticisi (Main Scene)
## Kamera takibi, Boss Bar bağlantısı ve anlık sönen ekran sarsıntısı

@onready var camera: Camera2D = $Camera2D
@onready var player: CharacterBody2D = $Player
@onready var wave_manager: Node2D = $WaveManager
@onready var hud: CanvasLayer = $HUD
@onready var pause_menu: CanvasLayer = $PauseMenu

var shake_intensity: float = 0.0
var shake_decay: float = 38.0
var last_hp: float = 100.0

func _ready() -> void:
	wave_manager.time_updated.connect(hud.update_timer)
	wave_manager.boss_spawned.connect(_on_boss_spawned)
	hud.pause_requested.connect(pause_menu.open_pause_menu)
	GameManager.health_changed.connect(_on_health_changed)

func _process(delta: float) -> void:
	if is_instance_valid(player):
		camera.global_position = player.global_position
		
	if shake_intensity > 0.0:
		var offset = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
		camera.offset = offset
		shake_intensity = max(0.0, shake_intensity - shake_decay * delta)
	else:
		camera.offset = Vector2.ZERO

func _on_boss_spawned(boss_node: Node2D) -> void:
	var title = "BÜYÜK FARE KRALI" if boss_node.is_final_boss else "FARE KRALI"
	hud.show_boss_bar(title, boss_node.max_health)
	boss_node.boss_hp_updated.connect(hud.update_boss_bar)

func _on_health_changed(current: float, _max: float) -> void:
	if current < last_hp:
		add_screen_shake(4.5)
	last_hp = current

func add_screen_shake(amount: float) -> void:
	shake_intensity = amount
