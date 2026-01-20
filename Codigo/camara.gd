extends Camera2D

# Referencias
var player: Node2D = null
var is_following: bool = false

# Configuración de seguimiento
var follow_speed: float = 10.0  # Velocidad de suavizado del seguimiento (más suave)
var look_ahead_distance: float = 0.0  # Desactivado para eliminar shake - anticipación según dirección
var vertical_offset: float = 0.0  # Sin offset vertical para movimiento más estable

# Límites de la cámara
var camera_limits_enabled: bool = true
var max_limit_left: float = 0.0
var max_limit_right: float = 1280.0
var max_limit_top: float = 0.0
var max_limit_bottom: float = 720.0

# Tamaño de la ventana visible
var viewport_width: float = 1280.0
var viewport_height: float = 720.0

# Zoom
var default_zoom: float = 4.18
var current_zoom: float = 4.18
var zoom_speed: float = 1.0


# Posición objetivo
var target_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	# Obtener referencia del jugador desde Global
	player = Global.current_player
	
	# Si no hay jugador en Global, intentar buscarlo en la escena
	if player == null:
		player = get_tree().root.find_child("Player", true, false)
	
	# Si aún no se encuentra, buscar por tipo CharacterBody2D (común para jugadores)
	if player == null:
		var nodes = get_tree().get_nodes_in_group("player")
		if nodes.size() > 0:
			player = nodes[0] as Node2D
	
	if player == null:
		# No mostrar error inmediatamente, puede que el jugador se configure después
		is_following = false
		return
	
	is_following = true
	set_physics_process(true)
	
	# Configurar la cámara
	global_position = player.global_position
	target_position = player.global_position
	zoom = Vector2(default_zoom, default_zoom)
	# Calcular tamaño de viewport basado en zoom
	_update_viewport_size()
	
	# Aplicar límites iniciales
	_apply_camera_limits()


func _physics_process(delta: float) -> void:
	# Intentar obtener el jugador si no está configurado
	if player == null:
		player = Global.current_player
		if player == null:
			return
	
	if not is_following or player == null:
		return
	
	# Verificar que el jugador sigue siendo válido
	if not is_instance_valid(player):
		player = null
		is_following = false
		return
	
	# Calcular posición objetivo (sin anticipación para evitar shake)
	var target_x = player.global_position.x
	var target_y = player.global_position.y + vertical_offset
	
	target_position = Vector2(target_x, target_y)
	
	# Suavizar movimiento de cámara con método más estable
	var distance_to_target = target_position - global_position
	# Usar smoothstep para un movimiento más suave sin oscilaciones
	var smooth_factor = min(1.0, follow_speed * delta)
	global_position = global_position.lerp(target_position, smooth_factor)
	
	# Aplicar límites de cámara
	_apply_camera_limits()
	


func _update_viewport_size() -> void:
	"""Actualiza el tamaño del viewport basado en el zoom actual"""
	var viewport_size = get_viewport_rect().size
	viewport_width = viewport_size.x / zoom.x
	viewport_height = viewport_size.y / zoom.y


func _apply_camera_limits() -> void:
	"""Aplica los límites del mapa para que la cámara no se salga de los bordes"""
	if not camera_limits_enabled:
		return
	
	# Calcular los límites considerando el tamaño de la ventana visible
	var half_width = viewport_width / 2.0
	var half_height = viewport_height / 2.0
	
	# Limitar posición X
	global_position.x = clamp(
		global_position.x,
		max_limit_left + half_width,
		max_limit_right - half_width
	)
	
	# Limitar posición Y
	global_position.y = clamp(
		global_position.y,
		max_limit_top + half_height,
		max_limit_bottom - half_height
	)
func set_player(new_player: Node2D) -> void:
	"""Establece un nuevo usuario a seguir"""
	player = new_player
	if player != null:
		# Guardar también en Global para persistencia
		Global.current_player = player
		is_following = true
		global_position = player.global_position
		target_position = player.global_position
		# Asegurar que el zoom esté configurado correctamente
		zoom = Vector2(current_zoom, current_zoom)
		_update_viewport_size()


func set_camera_limits(left: float, right: float, top: float, bottom: float) -> void:
	"""Establece los límites de la cámara para el nivel actual"""
	max_limit_left = left
	max_limit_right = right
	max_limit_top = top
	max_limit_bottom = bottom
	_apply_camera_limits()


func set_zoom_level(new_zoom: float) -> void:
	"""Cambia el nivel de zoom de la cámara
	Valores menores a 1.0 = más cerca (ej: 0.5 es zoom 2x)
	Valores mayores a 1.0 = más lejos (ej: 2.0 es zoom 0.5x)"""
	current_zoom = new_zoom
	zoom = Vector2(new_zoom, new_zoom)
	_update_viewport_size()


func shake_camera(intensity: float, duration: float) -> void:
	"""Shake desactivado - esta función no hace nada ahora"""
	pass


func stop_following() -> void:
	"""Detiene el seguimiento del usuario"""
	is_following = false


func resume_following() -> void:
	"""Reanuda el seguimiento del usuario"""
	if player != null:
		is_following = true
