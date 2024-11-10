class_name FireBallBase extends Node2D # 火球术基类

@export var spawn_time: float = 0.2
@export var move_time: float = 1.0
@export var hit_time: float = 2.0

var target_global_position: Vector2 = Vector2.ZERO

signal spawn_animation
signal move_animation
signal hit_animation


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_animation.emit()
	await get_tree().create_timer(spawn_time).timeout
	_move_to_target()


func _move_to_target() -> void:
	move_animation.emit()
	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position", target_global_position, move_time)
	tween.tween_callback(_hit_target)


func _hit_target() -> void:
	hit_animation.emit()
	await get_tree().create_timer(hit_time).timeout
	queue_free()
