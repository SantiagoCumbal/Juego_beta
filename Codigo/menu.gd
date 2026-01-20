extends Control

func _ready() -> void:
	AudioManager.play_selector_music()


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://selector_personajes/selector.tscn")
