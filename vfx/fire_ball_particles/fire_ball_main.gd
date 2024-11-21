extends Node2D

@export var fire_ball_tscn: PackedScene = preload("res://vfx/fire_ball_particles/fire_ball_particles.tscn")

@onready var sprite_2d: Sprite2D = $Sprite2D


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		var fire_ball: FireBallParticles = fire_ball_tscn.instantiate()
		add_child(fire_ball)
		fire_ball.global_position = sprite_2d.global_position
		fire_ball.target_global_position = get_global_mouse_position()
