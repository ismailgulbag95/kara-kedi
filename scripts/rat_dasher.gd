extends EnemyBase

## Atılan / Avcı Fare (Rat Dasher)
## Kediyi görünce hazırlanır ve aniden üzerine doğru atılır (dash).

@export var dash_speed: float = 380.0
@export var dash_range: float = 160.0
@export var dash_cooldown: float = 3.0

var dash_timer: float = 0.0
var is_dashing: bool = false
var dash_direction: Vector2 = Vector2.ZERO
var dash_duration: float = 0.35
var current_dash_time: float = 0.0

var ghost_timer: float = 0.0

func _ready() -> void:
	super._ready()
	dash_timer = randf_range(1.0, dash_cooldown)

func _physics_process(delta: float) -> void:
	if is_dead or GameManager.is_game_over:
		return
		
	if not is_instance_valid(target_player):
		_find_player()
		return

	if is_dashing:
		current_dash_time -= delta
		velocity = dash_direction * dash_speed
		ghost_timer += delta
		if ghost_timer >= 0.055:
			ghost_timer = 0.0
			_spawn_dash_ghost()
			
		if current_dash_time <= 0.0:
			is_dashing = false
			dash_timer = dash_cooldown
	else:
		dash_timer -= delta
		var dist = global_position.distance_to(target_player.global_position)
		
		# Menzile girince atılma hazırlığı
		if dash_timer <= 0.0 and dist < dash_range:
			_prepare_dash()
		else:
			# Normal takip
			var to_player = (target_player.global_position - global_position).normalized()
			velocity = to_player * move_speed
			if velocity.x != 0:
				sprite.flip_h = velocity.x < 0

	# Geri tepme
	if knockback_velocity.length() > 5.0:
		velocity += knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, delta * 1000.0)

	move_and_slide()

func _prepare_dash() -> void:
	is_dashing = true
	current_dash_time = dash_duration
	dash_direction = (target_player.global_position - global_position).normalized()
	ghost_timer = 0.0
	
	# Atılma gerilme animasyonu
	var tween = create_tween()
	sprite.modulate = Color(2.5, 1.5, 0.5, 1.0)
	tween.tween_property(sprite, "modulate", Color.WHITE, dash_duration)

func _spawn_dash_ghost() -> void:
	var ghost = Sprite2D.new()
	ghost.texture = sprite.texture
	ghost.flip_h = sprite.flip_h
	ghost.global_position = sprite.global_position
	ghost.rotation = sprite.rotation
	ghost.scale = sprite.scale
	ghost.modulate = Color(1.0, 0.28, 0.12, 0.5)
	ghost.z_index = z_index - 1
	var root = get_tree().current_scene
	if is_instance_valid(root):
		root.add_child(ghost)
		var tw = ghost.create_tween()
		tw.tween_property(ghost, "modulate:a", 0.0, 0.2)
		tw.tween_callback(ghost.queue_free)

