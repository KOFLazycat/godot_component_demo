class_name ScentPlayer extends CharacterBody2D

@onready var timer: Timer = $Timer

const SPEED: float = 200.0

var scent_tscn: PackedScene = preload("res://entities/enemy/scent/scent.tscn")
var scent_array: Array[Scent] = []


func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	timer.start()


func _physics_process(_delta: float) -> void:
	var direction: Vector2 = get_movement_vector()
	velocity = direction * SPEED
	move_and_slide()


func get_movement_vector() -> Vector2:
	var x_movement: float = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_movement: float = Input.get_action_strength("down") - Input.get_action_strength("up")
	return Vector2(x_movement, y_movement).normalized()


func _on_timer_timeout() ->void:
	var new_scent: Scent = scent_tscn.instantiate()
	new_scent.player = self
	new_scent.global_position = global_position
	new_scent.show_behind_parent = true
	get_parent().add_child(new_scent)
	scent_array.push_front(new_scent)
