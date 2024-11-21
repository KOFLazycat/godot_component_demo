extends Node2D


@onready var laser: Laser = $Laser


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		laser.is_casting = not laser.is_casting
