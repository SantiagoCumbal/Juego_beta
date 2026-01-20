extends CharacterBody2D

var speed: float = 150.0
var acceleration: float = 500.0
var friction: float = 400.0



var detection_range: float = 300.0  
var is_detecting: bool = false

var idle_animation: String = "idle"  
var alert_animation: String = "alert"  

var player: Node2D = null
var sprite: Sprite2D = null
var animation_player: AnimationPlayer = null
var facing_right: bool = true

var current_velocity: Vector2 = Vector2.ZERO


func _ready() -> void:
	sprite = $Sprite2D
	animation_player = $AnimationPlayer
	
	player = get_tree().root.find_child("Player", true, false)
	
	if player == null:
		push_warning("Enemigo Rojo: No se encontró el nodo 'Player'")
	
	if animation_player:
		animation_player.play(idle_animation)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		current_velocity.y += get_gravity().y * delta
	else:
		current_velocity.y = 0.0
	
	update_ai(delta)
	
	velocity = current_velocity
	move_and_slide()


func update_ai(delta: float) -> void:
	"""Actualiza la IA del enemigo"""
	if player == null:
		if is_detecting:
			is_detecting = false
			if animation_player:
				animation_player.play(idle_animation)
		current_velocity.x = 0.0
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player <= detection_range:
		if not is_detecting:
			is_detecting = true
			if animation_player:
				animation_player.play(alert_animation)
		
		var direction_to_player = sign(player.global_position.x - global_position.x)
		if direction_to_player != 0:
			facing_right = direction_to_player > 0
			if sprite:
				sprite.flip_h = not facing_right
		
		current_velocity.x = 0.0
	else:
		if is_detecting:
			is_detecting = false
			if animation_player:
				animation_player.play(idle_animation)
		
		current_velocity.x = 0.0



func set_detection_range(range_value: float) -> void:
	"""Establece el rango de detección del enemigo"""
	detection_range = max(0.0, range_value)


func set_idle_animation(animation_name: String) -> void:
	"""Establece el nombre de la animación de reposo"""
	idle_animation = animation_name


func set_alert_animation(animation_name: String) -> void:
	"""Establece el nombre de la animación de alerta"""
	alert_animation = animation_name


func take_damage(damage: float) -> void:
	"""El enemigo recibe daño (para futuras implementaciones)"""
	push_warning("Enemigo Rojo recibió daño: ", damage)
