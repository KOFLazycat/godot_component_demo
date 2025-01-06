class_name BulletImpulse
extends RigidBody2D

@export_range(-15.0, 15.0) var spin_speed: float = 10.0

@onready var timer: Timer = $Timer
@onready var flash_timer: Timer = $FlashTimer
@onready var sprite_2d: Sprite2D = $Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#sprite_2d.material.set_shader_parameter("active", true)
	spin_speed = randi_range(-15,15)
	timer.timeout.connect(_on_timer_timeout)
	flash_timer.timeout.connect(_on_flash_timer_timeout)


func _physics_process(delta: float) -> void:
	rotation += spin_speed * delta


func start(start: Vector2):
	apply_impulse(-(start + Vector2(0,200)))


func _on_flash_timer_timeout() -> void:
	sprite_2d.material.set_shader_parameter("active", false)


func _on_timer_timeout() -> void:
	queue_free()
