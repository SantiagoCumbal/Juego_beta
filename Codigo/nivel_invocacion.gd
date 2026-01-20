extends Node2D

@onready var spawn_point = $SpawnPoint
var camera: Camera2D

func _ready():
	_setup_level_music()
	
	if Global.selected_character_scene != "":
		var scene_player = load(Global.selected_character_scene)
		var player = scene_player.instantiate()
		add_child(player)
		player.global_position = spawn_point.global_position
		
		Global.current_player = player
		
		call_deferred("_restore_player_weapon")
		
		_setup_camera(player)

func _setup_level_music() -> void:
	"""Configura la música según el nivel actual"""
	var scene_path = get_tree().current_scene.scene_file_path
	var scene_name = scene_path.get_file().to_lower()
	var node_name = get_tree().current_scene.name.to_lower()
	
	if "jefe" in scene_name or "jefe" in node_name or "boss" in scene_name or "boss" in node_name:
		AudioManager.play_finalboss_music()
	else:
		AudioManager.play_background_music()

func _restore_player_weapon() -> void:
	if Global.current_weapon_path != "":
		Global.restore_weapon()
		print("Arma restaurada: ", Global.current_weapon_path)


func _setup_camera(player: Node2D) -> void:
	"""Configura la cámara para seguir al jugador con límites del mapa"""
	
	camera = find_child("Camera2D", true, false)
	
	if camera == null:
		camera = Camera2D.new()
		camera.name = "Camera2D"
		add_child(camera)
		camera.set_script(load("res://Codigo/camara.gd"))
	
	camera.make_current()
	
	camera.set_player(player)
	
	camera.set_physics_process(true)
	
	var map_limits = _get_map_limits()
	camera.set_camera_limits(
		map_limits.left,
		map_limits.right,
		map_limits.top,
		map_limits.bottom
	)


func _get_map_limits() -> Dictionary:
	"""
	Retorna los límites del mapa.
	Puedes personalizar esto según tu nivel específico.
	"""
	var map_bounds = find_child("MapBounds", true, false)
	
	if map_bounds != null and map_bounds is Area2D:
		var rect = map_bounds.get_node("CollisionShape2D").shape.get_rect()
		return {
			"left": rect.position.x,
			"right": rect.position.x + rect.size.x,
			"top": rect.position.y,
			"bottom": rect.position.y + rect.size.y
		}
	
	return {
		"left": 0.0,
		"right": 1280.0,
		"top": 0.0,
		"bottom": 720.0
	}
