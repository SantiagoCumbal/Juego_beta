extends Node
class_name State

var state_machine = null
@onready var animation_player = owner.find_child("AnimationPlayer")

func enter():
	print("State[", name, "]: enter() llamado")

func exit():
	print("State[", name, "]: exit() llamado")

func transition():
	pass
