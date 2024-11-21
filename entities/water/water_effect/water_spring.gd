extends Node2D

@onready var area_2d: Area2D = $Area2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

# spring当前速度
var velocity: float = 0.0
# 对spring施加的力
var force: float = 0.0
# 高度
var height: float = 0
# 稳定状态高度
var target_height: float = 0

var index: int = 0
var motion_factor: float = 0.015
var collide_with: Node2D = null

signal splash(index, speed)


func _ready() -> void:
	area_2d.body_entered.connect(on_area_2d_body_entered)


func water_update(spring_constant: float, dampening: float) -> void:
	# 更新当前高度
	height = position.y
	# 获取当前拉伸长度
	var x: float = height - target_height
	var loss: float = - dampening * velocity
	# 胡克定律
	force = - spring_constant * x + loss
	
	# 对速度施加力
	velocity += force
	# 移动位置
	position.y += velocity


func initialize(x_position: float, id: int) -> void:
	height = position.y
	target_height = position.y
	velocity = 0
	position.x = x_position
	index = id


func set_collision_width(value: float) -> void:
	## TODO 需要设置碰撞宽度和形状
	var size: Vector2 = collision_shape_2d.shape.size
	var new_size: Vector2 = Vector2(value, size.y)
	collision_shape_2d.shape.size = new_size


func on_area_2d_body_entered(body: Node2D) -> void:
	if body == collide_with:
		return
	collide_with = body
	
	# 对body的速度乘上一个因子，控制其大小
	var speed: float = body.velocity.y * motion_factor
	body.gravity = body.gravity * 0.2
	body.velocity.y -= speed*20
	emit_signal("splash", index, speed)
