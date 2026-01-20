extends Node
class_name StateMachine

var current_state: State = null
var states: Dictionary = {}

func _ready():
	await owner.ready
	await get_tree().process_frame
	
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.state_machine = self
			print("StateMachine: Registrado - ", child.name)
	
	if states.has("Follow"):
		print("StateMachine: Iniciando en Follow")
		change_state("Follow")
	else:
		push_error("StateMachine: No se encontró el estado Follow!")

func _process(delta):
	if current_state:
		current_state.transition()

func change_state(new_state_name: String):
	if not states.has(new_state_name):
		push_error("StateMachine: Estado '" + new_state_name + "' no existe!")
		return
	
	if current_state:
		print("StateMachine: Saliendo de ", current_state.name)
		current_state.exit()
	
	current_state = states[new_state_name]
	print("StateMachine: Entrando a ", current_state.name)
	current_state.enter()
