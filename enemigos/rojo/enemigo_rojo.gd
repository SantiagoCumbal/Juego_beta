extends CharacterBody2D

var speed: float = 50.0
var acceleration: float = 500.0

var obstacle_detection_distance: float = 24.0
var raycast_wall: RayCast2D
var raycast_floor: RayCast2D

var detection_range: float = 300.0
var attack_range: float = 40.0
var attack_damage: float = 10.0
var attack_cooldown: float = 1.5

var attack_timer: float = 0.0
var can_attack: bool = true
var is_pursuing: bool = false

var max_health: float = 50.0
var current_health: float = 50.0
var is_dead: bool = false

var player: Node2D = null
var sprite: Sprite2D
var animation_player: AnimationPlayer
var facing_right: bool = true

var current_velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	sprite = $Sprite2D
	animation_player = $AnimationPlayer
	if animation_player:
		animation_player.play("enemigo-verde")

	create_detectors()
	current_velocity.x = speed
	current_health = max_health

	var all_bodies = get_tree().get_nodes_in_group("Player")
	if all_bodies.size() > 0:
		player = all_bodies[0]

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	_update_detectors()

	if not is_on_floor():
		current_velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta
	else:
		current_velocity.y = 0.0

	# IA
	update_ai(delta)

	if not is_pursuing:
		patrol()

	velocity = current_velocity
	move_and_slide()

	_check_player_push()

func update_ai(delta: float) -> void:
	var p = Global.current_player
	if p == null:
		is_pursuing = false
		return

	var dist = global_position.distance_to(p.global_position)

	if dist <= detection_range:
		is_pursuing = true
		_chase_player_toward(p, delta)
	else:
		is_pursuing = false

func _chase_player_toward(target: Node2D, delta: float) -> void:
	var dir = sign(target.global_position.x - global_position.x)
	if dir != 0:
		facing_right = dir > 0
		sprite.flip_h = not facing_right

	var target_speed = dir * speed
	current_velocity.x = move_toward(current_velocity.x, target_speed, acceleration * delta)

func patrol() -> void:
	var dir = 1 if facing_right else -1
	if raycast_wall.is_colliding() or not raycast_floor.is_colliding():
		_reverse_dir()
		return
	current_velocity.x = dir * speed

func _reverse_dir() -> void:
	facing_right = not facing_right
	sprite.flip_h = not sprite.flip_h
	current_velocity.x = speed if facing_right else -speed

func _attack_player(target: CharacterBody2D) -> void:
	if not can_attack:
		return
	if target.has_method("take_damage"):
		target.take_damage(attack_damage)
	can_attack = false
	attack_timer = attack_cooldown

func _process(delta: float) -> void:
	if not can_attack:
		attack_timer -= delta
		if attack_timer <= 0.0:
			can_attack = true

func _check_player_push():
	var collision = get_last_slide_collision()
	if collision == null:
		return
	var collider = collision.get_collider()
	if collider == null:
		return

	if collider.name == "Caballero" or collider.name == "Robot" or collider.name == "Arquera":
		print("¡Chocó con: ", collider.name, "!")
		
		var push_dir = sign(collider.global_position.x - global_position.x)
		collider.push_force.x = push_dir * 200

		if can_attack:
			_attack_player(collider)

func create_detectors() -> void:
	for child in get_children():
		if child is RayCast2D:
			child.queue_free()

	raycast_wall = RayCast2D.new()
	raycast_wall.enabled = true
	raycast_wall.collision_mask = 1
	raycast_wall.visible = false
	add_child(raycast_wall)

	raycast_floor = RayCast2D.new()
	raycast_floor.enabled = true
	raycast_floor.collision_mask = 1
	raycast_floor.visible = false
	add_child(raycast_floor)

func _update_detectors() -> void:
	var dir = 1 if facing_right else -1
	raycast_wall.position = Vector2(10 * dir, 0)
	raycast_wall.target_position = Vector2(obstacle_detection_distance * dir, 0)
	raycast_floor.position = Vector2(10 * dir, 0)
	raycast_floor.target_position = Vector2(10 * dir, 30)

func take_damage(damage_amount: float) -> void:
	"""El enemigo recibe daño"""
	if is_dead:
		return
	
	current_health -= damage_amount
	print("Enemigo verde recibió ", damage_amount, " de daño. Vida: ", current_health)
	
	if current_health <= 0:
		die()

func die() -> void:
	"""El enemigo muere"""
	if is_dead:
		return
	
	is_dead = true
	print("Enemigo verde muerto")
	Global.add_score(15)
	collision_layer = 0
	collision_mask = 0
	queue_free()
