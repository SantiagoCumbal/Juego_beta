extends State

func enter():
	super.enter()
	print("Pasivo: Jugador detectado en rango")
	owner.set_physics_process(false)
	
	if animation_player:
		animation_player.play("Pasivo")
		if not animation_player.animation_finished.is_connected(_on_animation_finished):
			animation_player.animation_finished.connect(_on_animation_finished)

func exit():
	super.exit()
	if animation_player.animation_finished.is_connected(_on_animation_finished):
		animation_player.animation_finished.disconnect(_on_animation_finished)

func _on_animation_finished(anim_name: String):
	if anim_name == "Pasivo":
		print("Pasivo: Animación completada, comenzando a perseguir")
		get_parent().change_state("Follow")

func transition():
	pass
