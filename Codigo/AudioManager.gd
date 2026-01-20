extends Node

var music_player: AudioStreamPlayer = null

const MUSIC_BACKGROUND = "res://Musica/mus_backgorund.wav"
const MUSIC_SELECTOR = "res://Musica/mus_selector.wav"
const MUSIC_FINALBOSS = "res://Musica/mus_finalboss.wav"

var current_music: String = ""
var is_boss_music_playing: bool = false
var should_loop: bool = true  
func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.bus = "Master"
	
	music_player.finished.connect(_on_music_finished)
	
	print("AudioManager inicializado")

func play_selector_music() -> void:
	_play_music(MUSIC_SELECTOR, true)

func play_background_music() -> void:
	_play_music(MUSIC_BACKGROUND, true)

func play_finalboss_music() -> void:
	is_boss_music_playing = true
	_play_music(MUSIC_FINALBOSS, true)  

func stop_music() -> void:
	if music_player and music_player.playing:
		music_player.stop()
	should_loop = false
	current_music = ""
	is_boss_music_playing = false
	print("Música detenida")

func _play_music(music_path: String, loop: bool) -> void:
	if current_music == music_path and music_player.playing:
		print("La música ya está reproduciéndose:", music_path)
		return
	
	var music_stream = load(music_path)
	if music_stream == null:
		print("Error: No se pudo cargar la música:", music_path)
		return
	
	if music_player.playing:
		music_player.stop()
	
	music_player.stream = music_stream
	should_loop = loop
	current_music = music_path
	
	music_player.play()
	
	print("Reproduciendo música:", music_path, "| Loop:", loop)

func _on_music_finished() -> void:
	if should_loop and current_music != "":
		music_player.play()
		print("Música reiniciada (loop):", current_music)
	else:
		print("Música terminada:", current_music)
		current_music = ""

func on_boss_defeated() -> void:
	if is_boss_music_playing:
		stop_music()
		is_boss_music_playing = false
		print("Boss derrotado - música detenida")
