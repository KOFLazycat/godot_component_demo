extends Node

@onready var fade_transition: FadeTransition = $FadeTransition

func _ready():
	fade_transition.uncover()
