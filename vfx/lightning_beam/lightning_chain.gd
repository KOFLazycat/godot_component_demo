class_name LightningChain
extends Line2D
## 发散角度
@export_range(0.5, 3.0) var spread_angle: float = PI / 4
## 闪电链的线段数量
@export_range(1, 36) var segments: int = 12
## 闪电消失的时间
@export_range(0.1, 0.5) var flash_hold_time: float = 0.25

@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var spark_particles: GPUParticles2D = $SparkParticles


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_as_top_level(true)


func create_lightning(start: Vector2, end: Vector2) -> void:
	ray_cast_2d.global_position = start
	ray_cast_2d.target_position = end - start
	ray_cast_2d.force_raycast_update()
	if ray_cast_2d.is_colliding():
		end = ray_cast_2d.get_collision_point()
	
	var _points: Array = []
	var current: Vector2 = start
	var segment_length: float = current.distance_to(end) / segments
	_points.append(current)
	
	for segment in range(segments):
		var _rotation: float = randf_range(-spread_angle / 2, spread_angle / 2)
		var new: Vector2 = current + (current.direction_to(end) * segment_length).rotated(_rotation)
		_points.append(new)
		current = new
	_points.append(end)
	points = _points
	
	lightning_modulate()
	spark_particles.emitting = true
	spark_particles.global_position = end
	
	
func lightning_modulate():
	var tween: Tween = get_tree().create_tween()
	tween.tween_method(modulating, 1.0, 0.0, flash_hold_time)
	await tween.finished
	queue_free()


func modulating(a: float) -> void:
	self_modulate.a = a
	
	
	
