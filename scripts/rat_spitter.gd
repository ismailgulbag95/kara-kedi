extends EnemyBase

## Menzilli Tüküren Fare (Rat Spitter)
## Doğrudan karaktere doğru yürür, ekran menziline (380px) girdiğinde turuncu kor mermiler fırlatır.

@export var shoot_interval: float = 2.4
@export var max_shoot_range: float = 380.0
var shoot_timer: float = 0.0

const PROJECTILE_SCENE = preload("res://scenes/enemies/spitter_projectile.tscn")

func _ready() -> void:
	super._ready()
	shoot_timer = randf_range(0.8, shoot_interval)

func _physics_process(delta: float) -> void:
	if is_dead or GameManager.is_game_over:
		return
		
	if not is_instance_valid(target_player):
		_find_player()
		return
		
	var dist = global_position.distance_to(target_player.global_position)
	var to_player = (target_player.global_position - global_position).normalized()
	var separation = _calculate_separation()
	var final_direction = (to_player * 0.75 + separation * 0.25).normalized()
	
	# Doğrudan karaktere doğru yürüme
	velocity = final_direction * move_speed
	
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0
		
	wobble_time += delta * 12.0
	sprite.rotation = sin(wobble_time) * 0.1

	# Ateş etme: Yalnızca ekrana girdiği menzildeyken (380px) ateş eder!
	shoot_timer -= delta
	if shoot_timer <= 0.0:
		if dist <= max_shoot_range:
			_shoot_projectile()
		shoot_timer = shoot_interval

	# Geri tepme
	if knockback_velocity.length() > 5.0:
		velocity += knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, delta * 1000.0)

	move_and_slide()

func _shoot_projectile() -> void:
	if not is_instance_valid(target_player) or is_dead:
		return
		
	var proj = PROJECTILE_SCENE.instantiate()
	proj.global_position = global_position
	proj.direction = (target_player.global_position - global_position).normalized()
	
	var root_scene = get_tree().current_scene
	if is_instance_valid(root_scene):
		root_scene.call_deferred("add_child", proj)
