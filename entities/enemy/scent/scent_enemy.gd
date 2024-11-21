class_name ScentEnemy extends CharacterBody2D

@export var target: ScentPlayer

@onready var ray_cast_2d: RayCast2D = $RayCast2D

const MAX_SPEED: float = 100.0
const MAX_FORCE: float = 0.02
const MIN_DISTANCE: float = 50.0
var dir: Vector2 = Vector2.ZERO

func _ready() -> void:
	chase_target()


func _physics_process(_delta: float) -> void:
	# 如果距离太近了，就不进行追踪了
	if global_position.distance_to(target.global_position) <= MIN_DISTANCE:
		velocity = Vector2.ZERO
	else :
		velocity = dir * MAX_SPEED
	move_and_slide()
	chase_target()


func chase_target() -> void:
	ray_cast_2d.target_position = (target.position - position)
	ray_cast_2d.force_raycast_update()
	
	dir = ray_cast_2d.target_position.normalized()
	if ray_cast_2d.is_colliding():
		for scent in target.scent_array:
			ray_cast_2d.target_position = (scent.position - position)
			ray_cast_2d.force_raycast_update()
			
			if not ray_cast_2d.is_colliding():
				dir = ray_cast_2d.target_position.normalized()
				break
