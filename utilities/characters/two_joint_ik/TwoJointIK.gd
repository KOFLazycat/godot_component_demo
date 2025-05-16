@tool
extends Node2D

## Basic two joint IK
## to set up, have a child node named MiddleJoint
## and a child of that node called EndJoint
## arrange the joints and graphics along the positive x axis 


@export var target_node : Node2D

@onready var middle_joint : Node2D
@onready var end_joint : Node2D

@onready var upper_arm_len = 0
@onready var lower_arm_len = 0
@onready var max_len = 0
@export var middle_joint_flipped = true
@export var rotate_hand = true

@export var update_ik_in_editor = false
@export_tool_button("Reset IK") var reset_ik_in_editor_button = reset_ik

var last_base_transform : Transform2D
var last_target_transform : Transform2D

var initialized = false

func _ready():
	initialize_ik()
	update_ik()

func initialize_ik():
	middle_joint = $MiddleJoint
	end_joint = $MiddleJoint/EndJoint
	upper_arm_len = middle_joint.position.x
	lower_arm_len = end_joint.position.x
	max_len = upper_arm_len + lower_arm_len

func reset_ik():
	global_rotation = 0.0
	middle_joint.rotation = 0.0
	end_joint.rotation = 0.0
	update_ik_in_editor = false

func _process(_delta):
	if Engine.is_editor_hint():
		if update_ik_in_editor:
			initialize_ik()
			update_ik()
	else:
		update_ik()

func enable():
	set_process(true)

func disable():
	set_process(false)

func update_ik():
	if last_base_transform.is_equal_approx(global_transform) and last_target_transform.is_equal_approx(target_node.global_transform):
		return
	
		## ROTATION CALCULATION
	# use SSS formula to calculate angles of a 3 sided triangle
	# upper arm is side a
	# lower arm is side b
	# dist to hand is side c
	var vec_to_hand = target_node.global_position - global_position
	var dist_to_hand = vec_to_hand.length()

	# calculate angle of shoulder
	# cos(B) =  (c^2 + a^2 − b^2) / 2ca 
	var a2 = upper_arm_len*upper_arm_len
	var b2 = lower_arm_len*lower_arm_len
	var c2 = dist_to_hand*dist_to_hand
	var relative_shoulder_angle = -acos((c2 + a2 - b2) / (2 * dist_to_hand * upper_arm_len))
	if is_nan(relative_shoulder_angle):
		relative_shoulder_angle = 0.0

	# calculate angle of middle joint
	# cos(C) = (a^2 + b^2 − c^2) / 2ba 
	var relative_middle_joint_angle = acos((b2 + c2 - a2) / (2 * lower_arm_len * dist_to_hand))
	if is_nan(relative_middle_joint_angle):
		relative_middle_joint_angle = 0.0
	
	if middle_joint_flipped:
		relative_shoulder_angle *= -1
		relative_middle_joint_angle *= -1
	
	var base_angle = global_position.angle_to_point(target_node.global_position)
	global_rotation = relative_shoulder_angle + base_angle
	middle_joint.global_rotation = relative_middle_joint_angle + base_angle
	
	if rotate_hand:
		end_joint.global_rotation = target_node.global_rotation
	
	last_base_transform = global_transform
	last_target_transform = target_node.global_transform
