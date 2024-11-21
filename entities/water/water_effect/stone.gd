extends CharacterBody2D

var gravity: float = 35.0
var max_speed: float = 450.0
var rotation_speed: float = 2


func _physics_process(delta: float) -> void:
	velocity.y += gravity
	velocity.y = clamp(velocity.y, -max_speed, max_speed)
	rotation += rotation_speed * delta
	move_and_slide()


func initialize(position: Vector2) -> void:
	global_position = position
