extends Node2D

@onready var marker_2d:Marker2D = $Marker2D
@onready var timer:Timer = $Timer

var bezier_arrow_tscn:Resource = preload("res://Entities/bullet/bezier_bullet/bezier_arrow.tscn")
var type:int = 1
var bullet_types:int = 6


func _process(delta: float) -> void:
	look_at(get_global_mouse_position())


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("left_click"):
		attack()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		type = wrapi(type + 1, 1 , bullet_types + 1)
		print(type)
	get_tree().root.set_input_as_handled()


func attack() -> void:
	if !timer.is_stopped():
		return
	
	timer.start()
	var arrow = bezier_arrow_tscn.instantiate() as Node2D
	arrow.type = type
	arrow.global_position = marker_2d.global_position
	get_parent().add_child(arrow)
