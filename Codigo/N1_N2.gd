extends Area2D

@export var nivel_next: String

func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Caballero" or body.name == "Robot" or body.name == "Arquera":
		call_deferred("change_scene")

func change_scene():
	get_tree().change_scene_to_file(nivel_next)
