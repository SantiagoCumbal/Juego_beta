extends CharacterBody2D

const VELOCIDAD = 75.0
const GRAVEDAD = 900.0
const SALTO = -350.0

@onready var spriteQuieto = $Quieto
@onready var spriteCaminar = $Caminar
@onready var spriteSaltar = $Salto
@onready var animationPlayer = $AnimationPlayer

@export var max_health: int = 100
var health: int

@onready var barra = $CanvasLayer/TextureProgressBar

var push_force: Vector2 = Vector2.ZERO

var facing_right: bool = true


func _ready():

	if Global.player_health <= 0:
		Global.player_health = max_health

	health = Global.player_health

	if barra:
		barra.max_value = max_health
		barra.value = health


	if Global.has_signal("health_changed"):
		Global.health_changed.connect(_on_global_health_changed)

	Global.current_player = self


func _physics_process(_delta):

	if not is_on_floor():
		velocity.y += GRAVEDAD * _delta
	else:
		velocity.y = 0

	var input_dir := 0
	if Input.is_action_pressed("ui_right"):
		input_dir = 1
	elif Input.is_action_pressed("ui_left"):
		input_dir = -1

	velocity.x = input_dir * VELOCIDAD

	if velocity.x > 0:
		facing_right = true
	elif velocity.x < 0:
		facing_right = false

	var up_pressed = Input.is_action_pressed("ui_up")
	var down_pressed = Input.is_action_pressed("ui_down")
	if not up_pressed and not down_pressed:
		if input_dir > 0:
			Global.last_horizontal_direction = 1
		elif input_dir < 0:
			Global.last_horizontal_direction = -1

	velocity += push_force
	push_force = push_force.move_toward(Vector2.ZERO, 600 * _delta)

	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = SALTO

	_update_animations(input_dir)

	move_and_slide()


func _update_animations(input_dir: int) -> void:
	if not is_on_floor():
		spriteQuieto.visible = false
		spriteCaminar.visible = false
		spriteSaltar.visible = true
		spriteSaltar.flip_h = not facing_right
		animationPlayer.play("Salto")
	else:
		if input_dir == 0:
			spriteQuieto.visible = true
			spriteCaminar.visible = false
			spriteSaltar.visible = false
			spriteQuieto.flip_h = not facing_right
			animationPlayer.play("Quieto")
		else:
			spriteQuieto.visible = false
			spriteSaltar.visible = false
			spriteCaminar.visible = true
			spriteCaminar.flip_h = not facing_right
			animationPlayer.play("Caminar")



func _on_global_health_changed(new_health: int) -> void:
	health = new_health
	if barra:
		barra.value = health
	print("Vida actualizada desde Global: ", health)



func apply_push(push: Vector2) -> void:
	push_force += push



func take_damage(amount: int) -> void:
	health -= amount
	Global.player_health = health 

	if barra:
		barra.value = health

	print("Recibió ", amount, " de daño. Vida actual: ", health)

	if health <= 0:
		call_deferred("die")


func die() -> void:
	print("¡Personaje muerto!")
	Global.player_health = max_health
	queue_free()
	get_tree().change_scene_to_file("res://GameOver/game_over.tscn")
