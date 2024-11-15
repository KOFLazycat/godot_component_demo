class_name Laser
extends RayCast2D

@onready var line_2d: Line2D = $Line2D
@onready var casting_particles_2d: GPUParticles2D = $CastingParticles2D
@onready var collision_particles_2d: GPUParticles2D = $CollisionParticles2D
@onready var beam_particles_2d: GPUParticles2D = $BeamParticles2D

var is_casting: bool = false: set = set_is_casting


func _ready() -> void:
	set_physics_process(false)
	line_2d.points[1] = Vector2.ZERO


func _process(delta: float) -> void:
	var cast_point: Vector2 = target_position
	force_raycast_update()
	
	# 激光结尾段碰撞粒子
	collision_particles_2d.emitting = is_colliding()
	
	if is_colliding():
		cast_point = to_local(get_collision_point())
		collision_particles_2d.global_rotation = get_collision_normal().angle()
		collision_particles_2d.position = cast_point
	
	line_2d.points[1] = cast_point
	
	beam_particles_2d.position = cast_point * 0.5
	beam_particles_2d.process_material.emission_box_extents.x = cast_point.length() * 0.5


func set_is_casting(cast: bool) -> void:
	is_casting = cast
	set_physics_process(is_casting)
	
	# 激光起始段粒子
	casting_particles_2d.emitting = is_casting
	# 激光中间段粒子
	beam_particles_2d.emitting = is_casting
	
	if is_casting:
		appear()
	else:
		disappear()


func appear() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.parallel().tween_property(line_2d, "width", 10, 0.2)
	tween.parallel().tween_property(self, "target_position", Vector2(500.0, 0), 0.4)
	tween.play()


func disappear() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.parallel().tween_property(line_2d, "width", 0, 0.1)
	tween.parallel().tween_property(self, "target_position", Vector2.ZERO, 0.1)
	tween.play()


#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			#is_casting = not is_casting
