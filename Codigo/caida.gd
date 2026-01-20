extends Area2D

@export var damage: int = 30
@export var spawn_point: NodePath   

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Caballero" or body.name == "Robot" or body.name == "Arquera":

		if body.has_method("take_damage"):
			body.take_damage(damage)

		if spawn_point != NodePath(""):
			var spawn = get_node(spawn_point)
			if spawn:
				body.global_position = spawn.global_position
