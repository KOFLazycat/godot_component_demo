extends Node

@onready var fade_transition: FadeTransition = $FadeTransition

func _unhandled_key_input(event):
	if event.is_action_pressed("ui_accept"):
		if fade_transition.visible:
			fade_transition.uncover()
		else:
			fade_transition.cover()
