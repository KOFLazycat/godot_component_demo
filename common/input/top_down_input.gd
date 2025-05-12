## 输入系统：处理键盘移动、鼠标瞄准、手柄双摇杆控制
## 自动切换输入设备模式并控制光标显隐
class_name TopDownInput extends Node2D

# 输入状态信号
signal move_vec_updated(move_vec: Vector2) # 移动方向向量变化
signal face_vec_updated(face_vec: Vector2) # 朝向方向向量变化
signal face_angle_updated(face_angle: float) # 朝向角度变化（弧度）

## 拖拽角色节点到 Inspector
@export var character_node : Node2D
## 输入平滑系数
@export var input_smoothing: float = 0.2
## 摇杆死区阈值
@export var joystick_deadzone: float = 0.01
## 最小有效朝向长度
@export var min_facing_length: float = 0.1
## 最小切换间隔
@export var min_switch_interval: float = 0.5

var move_vec : Vector2 # 当前移动方向向量
var face_vec : Vector2 # 当前面朝方向向量
var face_angle : float # 面朝方向弧度角
var using_mouse = true # 是否正在使用鼠标
var smoothed_move_vec := Vector2.ZERO
var last_move_vec := Vector2.ZERO
var last_switch_time: float = 0.0


func _input(event: InputEvent) -> void:
	# 检测到鼠标移动时强制启用鼠标模式
	if event is InputEventMouseMotion:
		set_using_mouse(true)


func _process(_delta: float) -> void:
	process_movement_input()
	process_facing_input()
	emit_signals()


func process_movement_input():
	# 防止输入突变，使移动更平滑
	var raw_input: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	smoothed_move_vec = smoothed_move_vec.lerp(raw_input, input_smoothing)
	move_vec = smoothed_move_vec

# 面朝方向
func process_facing_input():
	var dir_to_face: Vector2 = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if dir_to_face.length_squared() > joystick_deadzone:
		set_using_mouse(false)
	
	if using_mouse && character_node:
		dir_to_face = character_node.global_position.direction_to(get_global_mouse_position())
	
	if dir_to_face.length_squared() > min_facing_length:
		face_vec = dir_to_face.normalized()
		face_angle = face_vec.angle()


func set_using_mouse(b: bool):
	# 添加切换延迟或优先级，防止同时快速移动鼠标和摇杆可能导致模式频繁切换，产生抖动
	if Time.get_ticks_msec() - last_switch_time < min_switch_interval * 1000:
		return
	last_switch_time = Time.get_ticks_msec()
	
	using_mouse = b
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if b else Input.MOUSE_MODE_CAPTURED


func emit_signals():
	# 添加输入变化检测
	if move_vec != last_move_vec:
		move_vec_updated.emit(move_vec)
		last_move_vec = move_vec
	face_vec_updated.emit(face_vec)
	face_angle_updated.emit(face_angle)
