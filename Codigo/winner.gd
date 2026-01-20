extends Control

func _ready() -> void:
	AudioManager.stop_music()


func _on_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://selector_personajes/selector.tscn")


func _on_salir_pressed() -> void:
	get_tree().quit()
