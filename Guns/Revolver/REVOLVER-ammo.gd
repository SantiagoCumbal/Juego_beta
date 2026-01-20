extends CharacterBody2D
var pos:Vector2 = Vector2.ZERO
var rota:Vector2 = Vector2.ZERO
var dir: float = 0.0
var speed: int = 2000
var damage: int = 10  
var has_hit: bool = false  
func _ready():
	collision_layer = 1 
	collision_mask = 4 
	

	if pos != Vector2.ZERO:
		global_position = pos
	
	if rota != Vector2.ZERO:
		rotation = rota.angle()

func set_properties(direction_angle: float, position: Vector2, rotation_angle: float, bullet_speed: int, bullet_damage: int):
	"""Método para establecer las propiedades de la bala desde el arma"""
	dir = direction_angle
	pos = position
	rota = Vector2(1, 0).rotated(rotation_angle)
	speed = bullet_speed
	damage = bullet_damage
	
	print("Bala recibió propiedades - Pos: ", pos, " Dir: ", rad_to_deg(dir), " Speed: ", speed, " Damage: ", damage)
	
	if is_inside_tree():
		global_position = pos
		rotation = dir
		print("Bala posicionada en: ", global_position)
	
func _physics_process(delta):
	if has_hit:
		return
	
	velocity=Vector2(speed,0).rotated(dir)
	move_and_slide()
	
	_check_enemy_collisions()

func _check_enemy_collisions():
	"""Detecta colisiones con enemigos y les hace daño"""
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is CharacterBody2D:
			if collider.has_method("take_damage"):
				collider.take_damage(damage)
				has_hit = true
				queue_free()
				return
		
		if collider:
			has_hit = true
			queue_free()
			return
	
	if global_position.y < -1000 or global_position.y > 2000:
		queue_free()
