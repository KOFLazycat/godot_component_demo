class_name AntPlayer extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var speed: float = 50.0
var move_vector: Vector2 = Vector2.ZERO


func _input(_event: InputEvent) -> void:
	if Input.get_vector("left", "right", "up", "down"):
		animated_sprite_2d.play("default")
	else :
		animated_sprite_2d.stop()


func _physics_process(_delta: float) -> void:
	move_vector = Input.get_vector("left", "right", "up", "down").normalized()
	velocity = move_vector * speed
	move_and_slide()
	if velocity:
		# 对蚂蚁初始方向的补偿
		#rotation = velocity.angle() + PI/2
		# 使用反正切值计算旋转角度
		rotation = atan2(velocity.x, -velocity.y)
	
