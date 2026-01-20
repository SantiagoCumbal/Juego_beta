extends Node

var selected_character_scene: String = ""

var current_player: Node2D = null

var player_health: int = 100
var score: int = 0
var best_score: int = 0

var last_horizontal_direction: int = 1

const WEAPONS = {
	"AK47": "res://Guns/AK47/AK-47.tscn",
	"GLOCK": "res://Guns/GLOCK/GLOCK.tscn",
	"REVOLVER": "res://Guns/Revolver/REVOLVER.tscn"
}

var weapon_scenes: Array[String] = [
	WEAPONS["AK47"],
	WEAPONS["GLOCK"],
	WEAPONS["REVOLVER"]
]

var current_weapon: String = ""
var current_weapon_path: String = ""

func _ready() -> void:
	randomize()

func get_random_weapon() -> String:
	if weapon_scenes.is_empty():
		return ""
	var random_index := randi() % weapon_scenes.size()
	return weapon_scenes[random_index]

func equip_weapon(weapon: String) -> bool:
	if current_player == null:
		print("Error: No hay personaje actual para equipar arma")
		return false
	
	var scene_path := ""
	if WEAPONS.has(weapon):
		scene_path = WEAPONS[weapon]
		current_weapon = weapon
		current_weapon_path = scene_path
	else:
		scene_path = weapon
		current_weapon_path = scene_path
		var found = false
		for k in WEAPONS.keys():
			if WEAPONS[k] == scene_path:
				current_weapon = k
				found = true
				break
		if not found:
			current_weapon = ""
	
	unequip_weapon()
	var weapon_scene := load(scene_path) as PackedScene
	if weapon_scene == null:
		print("Error: No se pudo cargar la escena del arma:", scene_path)
		return false
	var weapon_instance: Node = weapon_scene.instantiate()
	if weapon_instance == null:
		print("Error: No se pudo instanciar el arma")
		return false
	current_player.add_child(weapon_instance)
	weapon_instance.name = "EquippedWeapon"
	weapon_instance.position = Vector2.ZERO
	weapon_instance.z_index = 10
	if weapon_instance.has_method("set_z_as_relative"):
		weapon_instance.z_as_relative = false
	call_deferred("_disable_weapon_physics", weapon_instance)
	if weapon_instance.has_method("set_player"):
		weapon_instance.set_player(current_player)
	print("Arma equipada:", scene_path)
	return true

func restore_weapon() -> bool:
	if current_player == null:
		print("Error: No hay personaje actual para restaurar arma")
		return false
	
	if current_weapon_path == "":
		return false
	
	return equip_weapon(current_weapon_path)

func unequip_weapon() -> void:
	if current_player == null:
		return
	var equipped := current_player.get_node_or_null("EquippedWeapon")
	if equipped != null:
		equipped.queue_free()
		print("Arma desequipada")
		return
	var legacy := current_player.get_node_or_null("Weapon")
	if legacy != null:
		legacy.queue_free()
		print("Arma desequipada (legacy)")

func _disable_weapon_physics(weapon_node: Node) -> void:
	if not is_instance_valid(weapon_node):
		return
	if weapon_node is CharacterBody2D:
		var cb := weapon_node as CharacterBody2D
		cb.collision_layer = 0
		cb.collision_mask = 0
		cb.velocity = Vector2.ZERO
		cb.set_physics_process(false)
		cb.set_physics_process_internal(false)
	for child in weapon_node.get_children():
		if child is CharacterBody2D:
			var ccb := child as CharacterBody2D
			ccb.collision_layer = 0
			ccb.collision_mask = 0
			ccb.velocity = Vector2.ZERO
			ccb.set_physics_process(false)
			ccb.set_physics_process_internal(false)
		_disable_weapon_physics(child)

signal score_changed(new_score: int)
signal health_changed(new_health: int)

func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)
	if (score >= best_score):
		best_score = score
		

func reset_score() -> void:
	score = 0
	score_changed.emit(score)
	
func reset_health() -> void:
	player_health = 100
	health_changed.emit(player_health)

func add_health_and_score(vida: int, puntos: int, puntos_llenos: int) -> void:
	if player_health >= 100:
		add_score(puntos_llenos)
	else:
		player_health += vida
		if player_health > 100:
			player_health = 100
		health_changed.emit(player_health)
		add_score(puntos)
