extends CharacterBody2D

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var ui_layer = $UI if has_node("UI") else null
@onready var boss_bar = $UI/ProgressBar if has_node("UI/ProgressBar") else null

var direction : Vector2 = Vector2.ZERO
const SPEED = 50.0 

@export var max_health: int = 100
var health: int = 100
var is_dead: bool = false
var is_taking_damage: bool = false

var can_attack: bool = true
var attack_cooldown: float = 1.5
var cooldown_timer: float = 0.0
var is_cooldown_active: bool = false

var player: CharacterBody2D:
	get:
		return Global.current_player

func _ready() -> void:
	health = max_health
	
	AudioManager.play_finalboss_music()
	
	if boss_bar:
		boss_bar.max_value = max_health
		boss_bar.value = health
		boss_bar.visible = true

func _process(delta):
	if is_cooldown_active:
		cooldown_timer += delta
		if cooldown_timer >= attack_cooldown:
			can_attack = true
			is_cooldown_active = false
			cooldown_timer = 0.0

func _physics_process(delta):
	if player == null or is_dead or is_taking_damage:
		return
	
	direction = (player.global_position - global_position).normalized()
	
	if direction.x < 0:
		sprite.flip_h = true
	else: 
		sprite.flip_h = false
	

	velocity = direction * SPEED
	
	move_and_slide()

func take_damage(amount: int) -> void:
	if is_dead:
		return
	
	health -= amount
	if health < 0:
		health = 0
	
	if boss_bar:
		boss_bar.value = health
	
	if health <= 0:
		die()
	else:
		var state_machine = $FiniteStateMachine
		if state_machine:
			is_taking_damage = true
			state_machine.change_state("Damage")

func die() -> void:
	if is_dead:
		return
	is_dead = true
	set_physics_process(false)
	velocity = Vector2.ZERO
	
	AudioManager.on_boss_defeated()
	
	if boss_bar:
		boss_bar.visible = false
	
	var state_machine = $FiniteStateMachine
	if state_machine:
		state_machine.change_state("MuerteFinal")
