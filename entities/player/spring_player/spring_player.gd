extends Node2D

## 弹性系数K F = K * x
@export var K: float = 1024.0
## 质量M F = M * a
@export var M: float = 10.0
## 阻尼C F = K * x - C * v
@export var C: float = 10.0
## 弹力变化时的运动速度，图形组件没有速度参数
@export var velocity: float = 0.0
## 弹力运动的距离
@export var displacement: float = 100.0

@onready var sprite_2d_swing: Sprite2D = $Sprite2DSwing
@onready var sprite_2d_bouncy: Sprite2D = $Sprite2DBouncy


func _process(delta: float) -> void:
	# 旋转 & 形变
	var factor := Tanli(delta) / 2  # 限制弹性变化的幅度
	sprite_2d_swing.rotation = factor * PI
	var scale_factor := 1 + factor * 0.9
	sprite_2d_bouncy.scale = Vector2(scale_factor, 1 / scale_factor)
	
	if Input.is_action_just_pressed("ui_accept"): # 按空格重置
		displacement = 100.0


## 把弹性形变过程抽象为一个【-1, 1】变动的函数
func Tanli(delta: float) -> float:
	# F = -kx - cv
	var force := -K * displacement - C * velocity # 作用力
	# F = ma
	var acceleration := force / M # 加速度
	velocity += acceleration * delta # 速度变化
	displacement += velocity * delta # 距离变化
	return displacement / 100.0
