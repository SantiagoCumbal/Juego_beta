extends State

@export var distancia_derecha: float = 0.0
@export var distancia_izquierda: float = 65.0 
var attack_timer: float = 0.0
const MAX_ATTACK_TIME: float = 0.7
var has_finished: bool = false
var dash_direction: Vector2 = Vector2.ZERO
const DASH_SPEED = 200.0
var has_hit_player: bool = false

func enter():
	super.enter()
	owner.set_physics_process(true)
	attack_timer = 0.0
	has_finished = false
	has_hit_player = false 
	
	owner.set_collision_layer_value(3, false)
	owner.sprite.modulate.a = 0.5  
	
	if owner.player:
		dash_direction = (owner.player.global_position - owner.global_position).normalized()
		_actualizar_posicion_claws(dash_direction)
	
	_show_claws(true)
	
	if animation_player:
		animation_player.play("Garras")
		if not animation_player.animation_finished.is_connected(_on_animation_finished):
			animation_player.animation_finished.connect(_on_animation_finished)

func _process(delta):
	if has_finished:
		return
	
	owner.velocity = dash_direction * DASH_SPEED
	owner.move_and_slide()
	
	if not has_hit_player:
		_check_hit_player()
	
	attack_timer += delta
	if attack_timer >= MAX_ATTACK_TIME:
		_finish_attack()

func _actualizar_posicion_claws(dir: Vector2):
	if owner.has_node("Ataque"):
		var nodo_ataque = owner.get_node("Ataque")
		var sprite_claws = nodo_ataque.get_node_or_null("Sprite2D")
		
		if dir.x >= 0:
			nodo_ataque.position.x = distancia_derecha
			if sprite_claws: 
				sprite_claws.flip_h = false
		else:
			nodo_ataque.position.x = -distancia_izquierda
			if sprite_claws: 
				sprite_claws.flip_h = true

func _check_hit_player():
	if owner.player == null:
		return
	var diff = owner.player.global_position - owner.global_position
	if abs(diff.x) < 45 and abs(diff.y) < 30:
		if owner.player.has_method("take_damage"):
			owner.player.take_damage(15) 
			has_hit_player = true 

func _show_claws(visible: bool):
	if owner.has_node("Ataque/Sprite2D"):
		owner.get_node("Ataque/Sprite2D").visible = visible

func exit():
	super.exit()
	owner.set_collision_layer_value(3, true)
	owner.sprite.modulate.a = 1.0
	owner.velocity = Vector2.ZERO
	_show_claws(false)
	has_finished = true
	
	if animation_player and animation_player.animation_finished.is_connected(_on_animation_finished):
		animation_player.animation_finished.disconnect(_on_animation_finished)

func _on_animation_finished(anim_name: String):
	if anim_name == "Garras" and not has_finished:
		_finish_attack()

func _finish_attack():
	if has_finished:
		return
	has_finished = true
	get_parent().change_state("DespuesAtaque")
