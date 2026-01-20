extends State

var recovery_timer: float = 0.0
const MAX_RECOVERY_TIME: float = 2.0 
var has_finished: bool = false

func enter():
	super.enter()
	print("DespuesAtaque: El jefe está vulnerable")
	
	owner.is_taking_damage = false 
	owner.set_physics_process(false) 
	
	var follow_state = get_parent().states.get("Follow")
	if follow_state:
		follow_state.can_attack = false
		follow_state.cooldown_timer = 0.0
	
	_hide_claws()
	recovery_timer = 0.0
	has_finished = false
	
	if animation_player:
		animation_player.play("Despues_Ataque")
		if not animation_player.animation_finished.is_connected(_on_animation_finished):
			animation_player.animation_finished.connect(_on_animation_finished)

func _process(delta):
	if has_finished:
		return
	
	recovery_timer += delta
	

	if recovery_timer >= MAX_RECOVERY_TIME:
		_finish_recovery()

func _on_animation_finished(anim_name: String):
	if anim_name == "Despues_Ataque" and not has_finished:
		_finish_recovery()

func _finish_recovery():
	if has_finished:
		return
	
	has_finished = true

	owner.is_taking_damage = false
	owner.set_physics_process(true)
	
	get_parent().change_state("Follow")

func _hide_claws():
	var possible_names = ["Garras", "Garra", "Claws", "AttackSprite", "AtaqueGarras"]
	for node_name in possible_names:
		if owner.has_node(node_name):
			owner.get_node(node_name).visible = false
			return

func exit():
	super.exit()
	if animation_player and animation_player.animation_finished.is_connected(_on_animation_finished):
		animation_player.animation_finished.disconnect(_on_animation_finished)

func transition():
	pass
