extends Resource
class_name weapon

@export var weapon_name: String = ""
@export var actual_bullets: int = 0
@export var max_bullets: int = 0
@export var fire_rate: float = 0.2
@export var continuos_shooting: bool = false
@export var bullet_speed: int = 1000
@export var damage: int = 10
@export var bullet_num: int = 1
@export var bullet_spread: float = 0.0
@export var reload_time: float = 1.5
@export var impact_scene: PackedScene
@export var gun_sound: AudioStream
@export var gun_reload_sound: AudioStream
