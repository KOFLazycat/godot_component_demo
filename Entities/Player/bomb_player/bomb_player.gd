extends Node2D

@onready var player: AnimatedSprite2D = $Player
@onready var tail_gpu_particles_2d: GPUParticles2D = $TailGPUParticles2D


var speed = 100
var velocity = Vector2.ZERO


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	velocity.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	position += velocity.normalized() * speed * delta

	if velocity.x < 0:
		player.flip_h = true
	if velocity.x > 0:
		player.flip_h = false
	
	if velocity != Vector2.ZERO:
		player.play("walk")
		tail_gpu_particles_2d.emitting = true
	else:
		player.stop()
		tail_gpu_particles_2d.emitting = false
