class_name FireBallParticles extends FireBallBase

@onready var explode_gpu_particles_2d: GPUParticles2D = $ExplodeGPUParticles2D
@onready var explode_dot_gpu_particles_2d: GPUParticles2D = $ExplodeDotGPUParticles2D
@onready var fire_ball_gpu_particles_2d: GPUParticles2D = $SRT/FireBallGPUParticles2D
@onready var tail_gpu_particles_2d: GPUParticles2D = $SRT/TailGPUParticles2D
@onready var tail_dot_gpu_particles_2d: GPUParticles2D = $SRT/TailDotGPUParticles2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer




func _ready() -> void:
	super()
	spawn_animation.connect(on_spawn_animation)
	move_animation.connect(on_move_animation)
	hit_animation.connect(on_hit_animation)


func on_spawn_animation() -> void:
	pass


func on_move_animation() -> void:
	animation_player.play("move")


func on_hit_animation() -> void:
	fire_ball_gpu_particles_2d.emitting = false
	tail_gpu_particles_2d.emitting = false
	tail_dot_gpu_particles_2d.emitting = false
	explode_gpu_particles_2d.restart()
	explode_dot_gpu_particles_2d.restart()
