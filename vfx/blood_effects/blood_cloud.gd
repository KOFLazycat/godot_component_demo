class_name BloodCloud
extends Node2D
## 2D血雾效果，播放完成自动删除

@export var emit_on_ready: bool = true

@onready var blood_cloud_particles: GPUParticles2D = $BloodCloudParticles


func _ready() -> void:
	blood_cloud_particles.finished.connect(_on_particle_finished)
	blood_cloud_particles.emitting = true


func _on_particle_finished() -> void:
	queue_free()
