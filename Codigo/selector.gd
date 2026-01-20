extends Control

func _ready() -> void:
	AudioManager.play_selector_music()


func _on_button_robot_pressed():
	Global.reset_score()
	Global.reset_health()
	Global.selected_character_scene = "res://personajes/Robot/robot.tscn"
	AudioManager.play_background_music()
	get_tree().change_scene_to_file("res://niveles/nivel1A.tscn")

func _on_button_arquera_pressed():
	Global.reset_score()
	Global.reset_health()
	Global.selected_character_scene = "res://personajes/Arquera/arquera.tscn"
	AudioManager.play_background_music()
	get_tree().change_scene_to_file("res://niveles/nivel1A.tscn")

func _on_button_caballero_pressed():
	Global.reset_score()
	Global.reset_health()
	Global.selected_character_scene = "res://personajes/Caballero/caballero.tscn"
	AudioManager.play_background_music()
	get_tree().change_scene_to_file("res://niveles/nivel1A.tscn")
