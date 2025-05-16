class_name ProcedurallyAnimatedStepper extends Sprite2D

## 'Steps' the foot target marker to local position 0, 0 whenever it's outside 
## the rect of this node. Scale this node to change the step area.


@onready var foot_target_marker = $FootTargetMarker
var base_transform_ref : Node2D

@export var other_step_manager : ProcedurallyAnimatedStepper # Optional, if set won't step when other is stepping
@export var wall_check_raycaster : RayCast2D # Optional, if null won't check for wall collisions

@export var step_time = 0.1
@export var post_step_delay = 0.2 # time after step before other foot can step
var cur_step_time = 0.0

@export var dont_step_under_dist = 30.0 # dont step if foot is within this distance to goal position

var is_stepping = false
var foot_on_ground = true

signal taking_step
signal step_landed

@onready var goal_transform : Transform2D = foot_target_marker.global_transform
var step_start_transform : Transform2D

func _ready():
	hide()
	base_transform_ref = Node2D.new()
	add_child(base_transform_ref)
	base_transform_ref.global_transform = foot_target_marker.global_transform
	foot_target_marker.top_level = true
	foot_target_marker.global_transform = base_transform_ref.global_transform

func disable():
	set_process(false)

func _process(delta):
	if is_stepping:
		process_step(delta)
	elif needs_to_step():
		take_step()

func process_step(delta):
	cur_step_time += delta
	if cur_step_time >= step_time:
		if !foot_on_ground:
			step_landed.emit()
		foot_on_ground = true
		foot_target_marker.global_transform = goal_transform
		if cur_step_time >= post_step_delay + step_time:
			is_stepping = false
		return
	var t = clamp(cur_step_time / step_time, 0.0, 1.0)
	foot_target_marker.global_transform = step_start_transform.interpolate_with(goal_transform, t)

func needs_to_step():
	return !get_rect().has_point(to_local(foot_target_marker.global_position))

func reset_step():
	if !is_stepping:
		return
	is_stepping = false
	foot_on_ground = true
	cur_step_time = 0.0
	goal_transform = foot_target_marker.global_transform

func take_step():
	if other_step_manager and other_step_manager.is_stepping:
		return
	
	var new_goal_transform = base_transform_ref.global_transform
	if wall_check_raycaster:
		wall_check_raycaster.target_position = wall_check_raycaster.to_local(new_goal_transform.origin)
		wall_check_raycaster.enabled = true
		wall_check_raycaster.force_raycast_update()
		if wall_check_raycaster.is_colliding():
			var hit_pos = wall_check_raycaster.get_collision_point()
			var dir = wall_check_raycaster.global_position.direction_to(hit_pos)
			new_goal_transform.origin = hit_pos - dir * 10.0 # size of foot
	
	if new_goal_transform.origin.distance_to(step_start_transform.origin) < dont_step_under_dist:
		return
	
	goal_transform = new_goal_transform
	is_stepping = true
	foot_on_ground = false
	cur_step_time = 0.0
	step_start_transform = foot_target_marker.global_transform
	taking_step.emit()
