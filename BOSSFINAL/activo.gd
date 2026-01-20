extends State

var idle_time: float = 0.0
const IDLE_DURATION: float = 0.1 

func enter():
	super.enter()
	print("Activo: Boss en reposo breve")
	owner.set_physics_process(false)
	idle_time = 0.0
	
	if animation_player:
		animation_player.play("follow")

func exit():
	super.exit()

func _process(delta):
	idle_time += delta
	
func transition():
	if idle_time >= IDLE_DURATION:
		if owner.player != null:
			var distance = (owner.player.position - owner.position).length()
			if distance < 50:  
				get_parent().change_state("Pasivo")
