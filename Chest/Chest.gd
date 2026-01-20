extends CharacterBody2D

const INTERACTION_DISTANCE = 50.0

var player: Node2D = null
var is_player_near = false
var is_opened = false
var interaction_label: Label = null
var e_key_was_pressed = false

@onready var interaction_ui = $InteractionUI if has_node("InteractionUI") else null

func _ready():
	if interaction_ui == null:
		_create_interaction_ui()
	player = Global.current_player
	
	if player == null:
		player = get_tree().get_first_node_in_group("player")
	
	if Global.current_player != null:
		player = Global.current_player

func _create_interaction_ui():
	"""Crea la UI para mostrar el botón de interacción"""
	interaction_ui = CanvasLayer.new()
	interaction_ui.name = "InteractionUI"
	add_child(interaction_ui)
	
	var container = Control.new()
	container.name = "Container"
	container.set_anchors_preset(Control.PRESET_FULL_RECT)
	interaction_ui.add_child(container)
	
	interaction_label = Label.new()
	interaction_label.name = "InteractionLabel"
	interaction_label.text = "[E] Abrir cofre"
	interaction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	interaction_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	interaction_label.add_theme_font_size_override("font_size", 24)
	interaction_label.add_theme_color_override("font_color", Color.WHITE)
	interaction_label.add_theme_color_override("font_outline_color", Color.BLACK)
	interaction_label.add_theme_constant_override("outline_size", 4)
	interaction_label.visible = false
	container.add_child(interaction_label)

func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		player = Global.current_player
		if player == null:
			player = get_tree().get_first_node_in_group("player")
	
	if player != null and is_instance_valid(player):
		var distance = global_position.distance_to(player.global_position)
		is_player_near = distance <= INTERACTION_DISTANCE and not is_opened
		
		if interaction_label != null:
			interaction_label.visible = is_player_near
			if is_player_near:
				var viewport_size = get_viewport().get_visible_rect().size
				interaction_label.position = Vector2(
					viewport_size.x / 2.0 - interaction_label.size.x / 2.0,
					viewport_size.y / 2.0 - 100 
				)
		
		if is_player_near:
			var e_pressed = Input.is_key_pressed(KEY_E)
			if e_pressed and not e_key_was_pressed:
				open_chest()
			e_key_was_pressed = e_pressed
		else:
			e_key_was_pressed = false
	else:
		is_player_near = false
		e_key_was_pressed = false
		if interaction_label != null:
			interaction_label.visible = false

func open_chest():
	"""Abre el cofre y da un arma aleatoria al jugador"""
	if is_opened:
		return
	is_opened = true
	
	if interaction_label != null:
		interaction_label.visible = false
	
	var animation_player = $AnimationPlayer
	if animation_player != null:
		animation_player.play("Abrir Cofre")
		await animation_player.animation_finished
	
	var random_weapon = Global.get_random_weapon()
	if random_weapon == "":
		print("Error: No hay armas disponibles")
		is_opened = false
		return
	
	if Global.equip_weapon(random_weapon):
		print("¡Cofre abierto! Arma obtenida: ", random_weapon)
	else:
		print("Error: No se pudo equipar el arma")
		is_opened = false
