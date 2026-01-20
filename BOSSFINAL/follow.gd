extends State

static var can_attack: bool = true
static var cooldown_timer: float = 0.0
const ATTACK_COOLDOWN: float = 2.75
const ATTACK_RANGE: float = 30.0

func enter():
	super.enter()
	print("Follow: Entrando al estado Follow")
	print("Follow: Estado de ataque -> can_attack: ", can_attack, " | cooldown: ", snappedf(cooldown_timer, 0.1), "s/", ATTACK_COOLDOWN, "s")
	
	owner.set_physics_process(true)
	owner.is_taking_damage = false
	
	set_process(true)
	
	if animation_player:
		animation_player.play("follow")
		print("Follow: Animación 'follow' iniciada")
	else:
		print("Follow: No se encontró AnimationPlayer")

func exit():
	super.exit()
	print("Follow: Saliendo del estado")
	print("Follow: Estado final -> can_attack: ", can_attack, " | cooldown: ", snappedf(cooldown_timer, 0.1), "s")

func _process(delta):

	if not can_attack:
		cooldown_timer += delta
		
		if int(cooldown_timer) != int(cooldown_timer - delta):
			print("Follow: Cooldown en progreso: ", snappedf(cooldown_timer, 0.1), "/", ATTACK_COOLDOWN, "s")
		
		if cooldown_timer >= ATTACK_COOLDOWN:
			can_attack = true
			cooldown_timer = 0.0
			print("Follow: Cooldown completado, puede atacar de nuevo")

func transition():
	if owner.player == null or owner.is_dead:
		return
	
	var distance = owner.direction.length()

	if distance < ATTACK_RANGE:
		if can_attack:
			print("Follow: Jugador en rango (", snappedf(distance, 0.1), "m) - ATACANDO")
			can_attack = false
			cooldown_timer = 0.0
			get_parent().change_state("Ataque_Garra")
		else:
			if int(cooldown_timer * 2) != int((cooldown_timer - get_process_delta_time()) * 2):
				print("Follow: Jugador en rango pero en cooldown (", snappedf(cooldown_timer, 0.1), "/", ATTACK_COOLDOWN, "s)")
