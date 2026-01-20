extends CharacterBody2D
@onready var sprite = $Sprite2D
var direction : Vector2 = Vector2.ZERO
const SPEED = 40.0

var player: CharacterBody2D:
	get:
		return Global.current_player

func _ready() -> void:
	set_physics_process(false)
	print("Boss: Inicializado")

func _physics_process(delta):
	if player == null:
		return
	direction = player.position - position
	if direction.x < 0:
		sprite.flip_h = true
	else: 
		sprite.flip_h = false
	velocity.x = direction.normalized().x * SPEED
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()
