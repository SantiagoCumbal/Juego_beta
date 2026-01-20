extends State

@onready var death_label = Label.new()

func enter():
	super.enter()
	print("Muerte_final: Boss eliminado")

	owner.set_physics_process(false)
	owner.velocity = Vector2.ZERO

	if owner.sprite:
		owner.sprite.modulate = Color(0.5, 0.5, 0.5, 1.0)

	if animation_player:
		animation_player.play("Muerte_Final")
		Global.add_score(1000)
		animation_player.animation_finished.connect(_on_death_animation_finished)

	_show_death_text()

func _show_death_text():
	death_label.text = "BOSS ASESINADO"
	death_label.add_theme_font_size_override("font_size", 48)
	death_label.add_theme_color_override("font_color", Color.RED)
	death_label.position = Vector2(-150, -100)
	death_label.z_index = 100
	owner.add_child(death_label)

	var tween = create_tween()
	tween.set_parallel(true)
	death_label.modulate.a = 0
	tween.tween_property(death_label, "modulate:a", 1.0, 0.5)
	tween.tween_property(death_label, "position:y", death_label.position.y - 50, 2.0)
	tween.chain().tween_property(death_label, "modulate:a", 0.0, 1.0)

func _on_death_animation_finished(anim_name):
	if anim_name == "Muerte_Final":
		get_tree().change_scene_to_file("res://WIN/winner.tscn")

func exit():
	super.exit()

func transition():
	pass
