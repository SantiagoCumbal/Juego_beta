extends Label

func _ready() -> void:
	text = "%d" % Global.best_score

	Global.score_changed.connect(_on_score_changed)

func _on_score_changed(new_score: int) -> void:
	text = "%d" % new_score
