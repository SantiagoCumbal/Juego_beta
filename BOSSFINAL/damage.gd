extends State

var damage_timer: float = 0.0
const MAX_DAMAGE_TIME: float = 0.8  
var has_finished: bool = false

func enter():
	super.enter()
	print("Damage: Boss recibiendo daño - Preparando contraataque")
	owner.set_physics_process(false)
	owner.velocity = Vector2.ZERO
	damage_timer = 0.0
	has_finished = false
	
	set_process(true)
	
	if animation_player:
		animation_player.play("Damage")
		if not animation_player.animation_finished.is_connected(_on_animation_finished):
			animation_player.animation_finished.connect(_on_animation_finished)
	else:
		_finish_damage()

func exit():
	super.exit()
	set_process(false)
	has_finished = true
	if animation_player and animation_player.animation_finished.is_connected(_on_animation_finished):
		animation_player.animation_finished.disconnect(_on_animation_finished)

func _process(delta):
	if has_finished:
		return
		
	damage_timer += delta
	if damage_timer >= MAX_DAMAGE_TIME:
		_finish_damage()

func _on_animation_finished(anim_name: String):
	if anim_name == "Damage" and not has_finished:
		_finish_damage()

func _finish_damage():
	if has_finished:
		return
		
	has_finished = true
	
	print("Damage: Iniciando contraataque inmediato!")
	get_parent().change_state("Ataque_Garra")

func transition():
	pass
