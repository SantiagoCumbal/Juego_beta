extends Node2D

@export var weapon_data: weapon
@export var weapon_scale: Vector2 = Vector2.ONE

var is_firing = false
var is_reloading = false
var time_since_last_shot = 0.0
var mouse_button_was_pressed = false

var player: Node2D = null
var base_scale: Vector2 = Vector2.ONE

@onready var animation_player = $AnimationPlayer if has_node("AnimationPlayer") else null
@onready var audio_player = $AudioStreamPlayer2D if has_node("AudioStreamPlayer2D") else null
@onready var bullet_spawn_point = $Node2D if has_node("Node2D") else self
@onready var sprite_base = $Sprite2D if has_node("Sprite2D") else null
@onready var sprite_fire = $Disparo if has_node("Disparo") else null
@onready var sprite_reload = $Reload if has_node("Reload") else null

func _ready():
	if weapon_data == null:
		weapon_data = weapon.new()
		weapon_data.weapon_name = "REVOLVER-GUN"
		weapon_data.actual_bullets = 6
		weapon_data.max_bullets = 6
		weapon_data.fire_rate = 0.5
		weapon_data.continuos_shooting = false
		weapon_data.bullet_speed = 2000
		weapon_data.damage = 25
		weapon_data.bullet_num = 1
		weapon_data.bullet_spread = 0
		weapon_data.reload_time = 2.0
		weapon_data.impact_scene = preload("res://Guns/Bullets/REVOLVER-Bullet.tscn")
		weapon_data.gun_sound = preload("res://Guns/sounds/Revolver-ammo.wav")
		if not weapon_data.gun_reload_sound:
			weapon_data.gun_reload_sound = preload("res://Guns/sounds/Revolver-ammo.wav")
	
	weapon_data.actual_bullets = weapon_data.max_bullets

	base_scale = weapon_scale
	scale = base_scale
	
	if player == null:
		player = get_parent()
		if player == null:
			player = Global.current_player
	
	_disable_own_physics(self)
	_show_sprite("base")

func _disable_own_physics(node: Node) -> void:
	for child in node.get_children():
		if child is CharacterBody2D:
			var char_body = child as CharacterBody2D
			char_body.collision_layer = 0
			char_body.collision_mask = 0
			char_body.velocity = Vector2.ZERO
			char_body.set_physics_process(false)
			char_body.set_physics_process_internal(false)
		_disable_own_physics(child)

func _process(delta):
	_update_weapon_rotation()
	
	if not is_firing:
		time_since_last_shot += delta
	
	var mouse_pressed = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var mouse_just_pressed = mouse_pressed and not mouse_button_was_pressed
	mouse_button_was_pressed = mouse_pressed
	
	if weapon_data.continuos_shooting:
		if Input.is_action_pressed("ui_accept") or mouse_pressed:
			if weapon_data.actual_bullets > 0 and not is_reloading:
				if time_since_last_shot >= weapon_data.fire_rate:
					fire()
			elif weapon_data.actual_bullets == 0 and not is_reloading:
				reload()
	else:
		if Input.is_action_just_pressed("ui_accept") or mouse_just_pressed:
			if weapon_data.actual_bullets > 0 and not is_firing and not is_reloading:
				fire()
			elif weapon_data.actual_bullets == 0 and not is_reloading:
				reload()

func _update_weapon_rotation() -> void:
	if player == null:
		return
	
	var player_facing_right = true
	if "facing_right" in player:
		player_facing_right = player.get("facing_right")
	elif player.has_meta("facing_right"):
		player_facing_right = player.get_meta("facing_right")
	
	var right = Input.is_action_pressed("ui_right")
	var left = Input.is_action_pressed("ui_left")
	var up = Input.is_action_pressed("ui_up")
	var down = Input.is_action_pressed("ui_down")
	
	var direction_x = 0
	var direction_y = 0
	
	var has_input = right or left or up or down
	
	if has_input:
		if right:
			direction_x = 1
		if left:
			direction_x = -1
		if up:
			direction_y = -1
		if down:
			direction_y = 1
	else:
		direction_x = Global.last_horizontal_direction
		direction_y = 0
	
	var direction = Vector2(direction_x, direction_y).normalized()
	var target_angle = direction.angle()
	
	if player_facing_right:
		scale.x = base_scale.x
		rotation = target_angle
	else:
		scale.x = -base_scale.x
		rotation = target_angle
	
	var rotation_degrees = rad_to_deg(rotation)
	if rotation_degrees > 90 and rotation_degrees < 270:
		scale.y = -base_scale.y
	else:
		scale.y = base_scale.y

func set_player(new_player: Node2D) -> void:
	player = new_player

func _show_sprite(sprite_type: String) -> void:
	if sprite_base:
		sprite_base.visible = (sprite_type == "base")
	if sprite_fire:
		sprite_fire.visible = (sprite_type == "fire")
	if sprite_reload:
		sprite_reload.visible = (sprite_type == "reload")

func fire():
	if weapon_data.actual_bullets <= 0:
		print("No hay balas disponibles")
		return
	
	is_firing = true
	time_since_last_shot = 0.0
	print("Disparando! Balas restantes: ", weapon_data.actual_bullets)
	
	_show_sprite("fire")
	
	if animation_player:
		animation_player.play("Disparo")
	
	if audio_player and weapon_data.gun_sound:
		audio_player.stream = weapon_data.gun_sound
		audio_player.play()
	
	for i in range(weapon_data.bullet_num):
		if weapon_data.actual_bullets > 0:
			spawn_bullet()
			weapon_data.actual_bullets -= 1
		else:
			break
	
	if animation_player:
		await animation_player.animation_finished
	
	_show_sprite("base")
	is_firing = false
	
	if weapon_data.actual_bullets == 0:
		reload()

func spawn_bullet():
	if not weapon_data.impact_scene:
		print("Error: No hay escena de bala asignada")
		return
	
	var bullet = weapon_data.impact_scene.instantiate()
	
	var base_angle = rotation
	var spread_angle = 0.0
	if weapon_data.bullet_spread > 0:
		spread_angle = deg_to_rad(randf_range(-weapon_data.bullet_spread / 2.0, weapon_data.bullet_spread / 2.0))
	
	var final_angle = base_angle + spread_angle
	
	var scene_root = get_tree().current_scene
	if scene_root == null:
		scene_root = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
	
	scene_root.add_child(bullet)
	
	if bullet.has_method("set_properties"):
		bullet.call_deferred("set_properties", final_angle, bullet_spawn_point.global_position, final_angle, weapon_data.bullet_speed, weapon_data.damage)
	else:
		call_deferred("_set_bullet_properties", bullet, final_angle, bullet_spawn_point.global_position, final_angle, weapon_data.bullet_speed, weapon_data.damage)

func _set_bullet_properties(bullet: Node, dir_angle: float, pos_vec: Vector2, rot_vec: Vector2, speed_val: int, damage_val: int):
	if not is_instance_valid(bullet):
		return
	
	if "dir" in bullet:
		bullet.set("dir", dir_angle)
	if "pos" in bullet:
		bullet.set("pos", pos_vec)
	if "rota" in bullet:
		bullet.set("rota", rot_vec)
	if "speed" in bullet:
		bullet.set("speed", speed_val)
	if "damage" in bullet:
		bullet.set("damage", damage_val)

func reload():
	if is_reloading or weapon_data.actual_bullets >= weapon_data.max_bullets:
		return
	
	is_reloading = true
	
	_show_sprite("reload")
	
	if animation_player:
		animation_player.play("Reload")
	
	if audio_player and weapon_data.gun_reload_sound:
		audio_player.stream = weapon_data.gun_reload_sound
		audio_player.play()
	
	await get_tree().create_timer(weapon_data.reload_time).timeout
	
	if animation_player and animation_player.is_playing():
		await animation_player.animation_finished
	
	weapon_data.actual_bullets = weapon_data.max_bullets
	
	_show_sprite("base")
	is_reloading = false
	is_firing = false
