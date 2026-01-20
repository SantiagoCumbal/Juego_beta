extends CharacterBody2D

var speed: float = 80.0
var acceleration: float = 200.0
var hover_height: float = 100.0 
var hover_speed: float = 2.0 

var detection_range: float = 300.0
var attack_range: float = 30.0
var attack_damage: float = 15.0
var attack_cooldown: float = 2.0

var attack_timer: float = 0.0
var can_attack: bool = true
var is_pursuing: bool = false

var max_health: float = 40.0
var current_health: float = 40.0
var is_dead: bool = false

var player: Node2D = null
var sprite: Sprite2D = null
var animation_player: AnimationPlayer = null
var facing_right: bool = true
var start_position: Vector2
var hover_offset: float = 0.0

var current_velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	sprite = $Sprite2D
	animation_player = $AnimationPlayer
	if animation_player:
		animation_player.play("enemigo-volador")
	
	start_position = global_position
	current_health = max_health
	
	player = Global.current_player
	if player == null:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	if player == null or not is_instance_valid(player):
		player = Global.current_player
	
	hover_offset += hover_speed * delta
	var hover_y = sin(hover_offset) * 20.0  
	var target_y = start_position.y + hover_y
	

	update_ai(delta)
	

	if is_pursuing and player != null:
		var dir = sign(player.global_position.x - global_position.x)
		if dir != 0:
			facing_right = dir > 0
			if sprite:
				sprite.flip_h = not facing_right
		
		var target_speed = dir * speed
		current_velocity.x = move_toward(current_velocity.x, target_speed, acceleration * delta)
		
		var target_y_player = player.global_position.y - hover_height
		target_y = lerp(global_position.y, target_y_player, 0.05)
	else:
		current_velocity.x = move_toward(current_velocity.x, 0, acceleration * delta)
	
	current_velocity.y = (target_y - global_position.y) * 5.0
	
	velocity = current_velocity
	move_and_slide()

func update_ai(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		is_pursuing = false
		return
	
	var dist = global_position.distance_to(player.global_position)
	
	if dist <= detection_range:
		is_pursuing = true
		
		if dist <= attack_range and can_attack:
			_attack_player()
	else:
		is_pursuing = false
	
	if not can_attack:
		attack_timer -= delta
		if attack_timer <= 0.0:
			can_attack = true

func _attack_player() -> void:
	if not can_attack:
		return
	
	if player != null and player.has_method("take_damage"):
		player.take_damage(attack_damage)
	
	can_attack = false
	attack_timer = attack_cooldown

func take_damage(damage_amount: float) -> void:
	"""El enemigo recibe daño"""
	if is_dead:
		return
	
	current_health -= damage_amount
	print("Enemigo volador recibió ", damage_amount, " de daño. Vida: ", current_health)
	
	if current_health <= 0:
		die()

func die() -> void:
	"""El enemigo muere"""
	if is_dead:
		return
	
	is_dead = true
	print("Enemigo volador muerto")
	Global.add_score(15)
	collision_layer = 0
	collision_mask = 0
	queue_free()
