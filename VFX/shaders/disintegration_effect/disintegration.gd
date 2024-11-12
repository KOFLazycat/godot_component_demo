extends GPUParticles2D


func _ready() -> void:
	one_shot = true
	start()


func start() -> void:
	restart()
	emitting = true
	var frac: float = process_material.get("shader_parameter/particle_lifetime_fraction")
	process_material.set("shader_parameter/progress", 0.0)

	var tween := get_tree().create_tween()
	tween.tween_property(process_material, "shader_parameter/progress", 1.0, lifetime * (1.0 - frac))
	tween.tween_callback(start).set_delay(lifetime * frac)
