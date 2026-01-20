extends Area2D
@export var vida_a_dar: int = 30
@export var puntos_normales: int = 50
@export var puntos_vida_llena: int = 100

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name in ["Caballero", "Robot", "Arquera"] or body.is_in_group("player"):
		Global.add_health_and_score(
			vida_a_dar,
			puntos_normales,
			puntos_vida_llena
		)
		queue_free()
