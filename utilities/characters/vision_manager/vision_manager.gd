class_name VisionManager extends Node2D

@onready var ray_cast_2d = $RayCast2D

@export var cant_see_past_dist = 500.0
@export var always_see_within_dist = 100.0
@export var sight_arc = 60.0 # in degrees

enum DIRECTIONS {RIGHT, DOWN, LEFT, UP}
@export var front_direction = DIRECTIONS.RIGHT #which way does this character face by default

@export var debug_view = false
var did_los_check = false # used for debug view

func can_see_point(point: Vector2):
	did_los_check = false
	queue_redraw()
	
	if point_outside_max_sight_range(point):
		return false
	
	if !has_los_to_point(point):
		return false
	
	var dist_to_point = global_position.distance_squared_to(point)
	if dist_to_point < always_see_within_dist * always_see_within_dist:
		return true
	
	var dir_to_point = point - global_position
	var angle = get_forward_vector().angle_to(dir_to_point)
	if abs(rad_to_deg(angle)) > sight_arc/2.0:
		return false
	return true

func get_forward_vector() -> Vector2:
	match front_direction:
		DIRECTIONS.RIGHT:
			return global_transform.x
		DIRECTIONS.LEFT:
			return -global_transform.x
		DIRECTIONS.DOWN:
			return global_transform.y
	return -global_transform.y # up

func get_local_forward_vector() -> Vector2:
	match front_direction:
		DIRECTIONS.RIGHT:
			return Vector2.RIGHT
		DIRECTIONS.LEFT:
			return Vector2.LEFT
		DIRECTIONS.DOWN:
			return Vector2.DOWN
	return Vector2.UP

func point_outside_max_sight_range(point: Vector2):
	var dist_to_point = global_position.distance_squared_to(point)
	return dist_to_point > cant_see_past_dist * cant_see_past_dist

func has_los_to_point(point: Vector2):
	did_los_check = true
	ray_cast_2d.enabled = true
	ray_cast_2d.target_position = ray_cast_2d.to_local(point)
	ray_cast_2d.force_raycast_update()
	var has_los = !ray_cast_2d.is_colliding()
	if !debug_view: # have to leave enabled to get collision point in debug
		ray_cast_2d.enabled = false
	return has_los

func _draw():
	if !debug_view:
		return
	draw_circle(Vector2.ZERO, always_see_within_dist, Color.GREEN, false, 1)
	draw_circle(Vector2.ZERO, cant_see_past_dist, Color.RED, false, 1)
	var half_arc = deg_to_rad(sight_arc) / 2.0
	var fwd = get_local_forward_vector()
	draw_line(Vector2.ZERO, fwd.rotated( half_arc)*cant_see_past_dist, Color.YELLOW)
	draw_line(Vector2.ZERO, fwd.rotated(-half_arc)*cant_see_past_dist, Color.YELLOW)
	draw_arc(Vector2.ZERO, cant_see_past_dist, fwd.angle() + half_arc, fwd.angle() - half_arc, 10, Color.YELLOW, 1)
	
	var end_pos = ray_cast_2d.to_global(ray_cast_2d.target_position)
	if ray_cast_2d.is_colliding():
		end_pos = ray_cast_2d.get_collision_point()
	if did_los_check:
		draw_line(Vector2.ZERO, to_local(end_pos), Color.LIGHT_BLUE, 1)
