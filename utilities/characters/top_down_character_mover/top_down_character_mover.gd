class_name TopDownCharacterMover extends Node
## 俯视角角色移动控制器（物理增强版）
## 特性：
## - 基于运动学公式的加速/减速
## - 精确转向角度控制
## - 移动方向与面朝方向关联限制
#region 节点依赖
@onready var character_body : CharacterBody2D = get_parent()
#endregion

#region 导出参数
@export_group("Movement")
@export var max_move_speed: float = 300.0        ## 最大移动速度（像素/秒）
@export var acceleration_time: float = 0.2      ## 加速到最大速度所需时间（秒）
@export var deceleration_time: float = 0.1      ## 从最大速度停止所需时间（秒）

@export_group("Rotation")
@export var turn_speed: float = 300.0           ## 转向速度（度/秒）
@export var instantly_turn: bool = false       ## 是否启用瞬时转向
@export var move_angle_threshold: float = 30.0  ## 允许移动的最大角度偏差（度）
enum DIRECTIONS {RIGHT, DOWN, LEFT, UP}
@export var front_direction: DIRECTIONS = DIRECTIONS.RIGHT #which way does this character face by default

@export_group("Advanced")
@export var floor_snap_length: float = 32.0     ## 地面吸附距离
@export var reverse_threshold: float = -0.1     ## 反向移动判定阈值
#endregion

#region 内部状态
var move_vec := Vector2.ZERO              ## 输入移动方向
var face_vec := Vector2.ZERO              ## 目标面朝方向
var is_moving_allowed: bool = true             ## 移动许可状态
var accel_force: float = 0.0                    ## 计算加速度
var move_drag: float = 0.0                      ## 移动阻力系数
var stop_drag: float = 0.0                      ## 停止阻力系数
#endregion


#region 初始化
func _ready() -> void:
	# 父节点类型验证
	assert(character_body is CharacterBody2D, "Parent must be CharacterBody2D!")
	
	# 基于物理公式计算参数（替换魔法数字）
	# 加速度 = Δ速度 / 时间，4.6 is magic number to assume time to reach ~99% max speed
	accel_force = max_move_speed * 4.6 / acceleration_time
	# 移动阻力 = 加速度 / 最大速度
	move_drag = accel_force / max_move_speed
	# 停止阻力 = ln(初速度/终速度) / 时间，0.01 magic number again, assuming ~99% stopped
	stop_drag = log(max_move_speed / 0.01) / deceleration_time
#endregion


#region 物理处理
func _physics_process(delta: float) -> void:
	update_rotation(delta)
	update_movement(delta)


func update_rotation(delta: float) -> void:
	## 处理角色转向逻辑
	var current_facing: Vector2 = get_forward_vector()
	var target_facing: Vector2 = face_vec.normalized()
	
	# 计算带环绕修正的角度差
	var angle_diff: float = wrapf(current_facing.angle_to(target_facing), -PI, PI)
	
	if instantly_turn:
		# 瞬时转向模式
		character_body.rotation += angle_diff
		is_moving_allowed = true
		return
	
	# 计算转向方向和速度
	var turn_dir = sign(current_facing.cross(target_facing))  # 叉乘确定方向
	var turn_amount = turn_dir * deg_to_rad(turn_speed) * delta
	
	# 应用转向并限制角度差
	if abs(turn_amount) > abs(angle_diff):
		turn_amount = angle_diff
	character_body.rotation += turn_amount
	
	# 更新移动许可状态
	is_moving_allowed = abs(rad_to_deg(angle_diff)) <= move_angle_threshold


func update_movement(delta: float) -> void:
	## 处理角色移动逻辑
	var drag = calculate_drag()
	var acceleration = move_vec * accel_force - character_body.velocity * drag
	
	# 应用物理计算
	character_body.velocity += acceleration * delta
	perform_movement()


func calculate_drag() -> float:
	## 计算当前阻力系数
	if !is_moving_allowed || move_vec.is_zero_approx():
		return stop_drag
	if move_vec.dot(character_body.velocity) < reverse_threshold:
		return stop_drag
	return move_drag


func perform_movement() -> void:
	## 执行移动并处理斜坡
	character_body.floor_snap_length = floor_snap_length
	character_body.move_and_slide()
	
	# 处理斜坡滑动
	if character_body.is_on_floor():
		var floor_normal = character_body.get_floor_normal()
		character_body.velocity = character_body.velocity.slide(floor_normal)
#endregion


#region 公共接口
func stop_moving() -> void:
	## 立即停止移动
	move_vec = Vector2.ZERO
	character_body.velocity = Vector2.ZERO


func stop_turning():
	## 立即停止转动
	face_vec = get_forward_vector()


func face_towards(position: Vector2) -> void:
	## 设置面朝目标位置
	face_vec = character_body.global_position.direction_to(position)


func get_forward_vector() -> Vector2:
	## 获取当前面朝方向
	match front_direction:
		DIRECTIONS.RIGHT: return character_body.global_transform.x
		DIRECTIONS.LEFT:  return -character_body.global_transform.x
		DIRECTIONS.DOWN:  return character_body.global_transform.y
		_:                return -character_body.global_transform.y  # 处理UP和其他情况
#endregion
