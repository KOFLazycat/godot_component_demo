extends Node2D

## 箭矢运动速度
@export var speed: float = 1000.0
## 方案3：箭矢调整方向的阻力系数
@export var drag_factor: float = 0.15
## 方案4：箭矢方向调整角度插值计算的weight
@export var elapsed: float = 0.07
## 方案5/6：使用贝塞尔曲线计算坐标时的起始点（控制点1）信息的修正系数，系数越大，箭矢运动绕的弯子越大
@export var control_1_fix: float = 1.7
## 方案6：控制点1固定方向，单位度
@export var control_1_direction: float = 60.0

@onready var timer: Timer = $Timer
@onready var hit_box: Area2D = $HitBox


var type: int = 1
var direction: Vector2 = Vector2.ZERO # 箭矢指向的归一化向量
var current_velocity: Vector2 = Vector2.ZERO# 箭矢速度向量
var next_point: Vector2 = Vector2.ZERO
var current_time: float = 0.0
var current_player_pos: Vector2 = Vector2.ZERO
var current_enemy_pos: Vector2 = Vector2.ZERO
var length_base: float = 2.236# 抛物线控制点斜边长度base


func _ready() -> void:
	direction = global_position.direction_to(get_global_mouse_position())
	look_at(global_position + direction)
	
	current_velocity = speed * 2.5 * Vector2.RIGHT.rotated(rotation)
	
	next_point = global_position
	current_player_pos = get_tree().get_first_node_in_group("bezier_player").global_position
	current_enemy_pos = get_tree().get_first_node_in_group("bezier_enemy").global_position
	
	timer.timeout.connect(on_timer_timeout)
	hit_box.area_entered.connect(on_hit_box_area_entered)


func _physics_process(delta: float) -> void:
	callv("action" + str(type), [delta])


## 指哪打哪，直线射击
func action1(delta: float) -> void:
	global_position += direction * speed * delta


## 强制瞄准，每一帧都会刷新敌人位置，并将箭矢射击方向调整为新的位置
func action2(delta: float) -> void:
	var enemy: Node2D = get_tree().get_first_node_in_group("bezier_enemy") as Node2D
	if !enemy:
		global_position += direction * delta * speed
		return
		
	global_position = global_position.move_toward(enemy.global_position, delta * speed)
	look_at(enemy.global_position)


## 强制瞄准，每一帧都会刷新敌人位置，但是箭矢在调整方向时，会受到阻力系数影响，一定程度上会让箭矢的跟踪效果更加平滑
func action3(delta: float) -> void:
	var enemy: Node2D = get_tree().get_first_node_in_group("bezier_enemy") as Node2D
	if !enemy:
		global_position += direction * delta * speed
		return
		
	var desired_direction: Vector2 = global_position.direction_to(enemy.global_position)
	var desired_velocity: Vector2 = desired_direction * speed
	var change: Vector2 = (desired_velocity - current_velocity) * drag_factor
	current_velocity += change
	
	position += current_velocity * delta
	look_at(global_position + current_velocity)


## 强制瞄准，每一帧都会刷新敌人位置，通过箭矢方向插值计算新的方向，并更新位置，该方法追踪效果比较平滑，由于插值计算的缘故，会出现箭矢绕着目标旋转的情况
func action4(delta: float) -> void:
	var enemy: Node2D = get_tree().get_first_node_in_group("bezier_enemy") as Node2D
	if !enemy:
		global_position += direction * delta * speed
		return
	
	var target_rotation = (enemy.global_position - global_position).angle()
	rotation = lerp_angle(rotation, target_rotation, elapsed)
	current_velocity = Vector2(speed, 0).rotated(rotation)
	position += current_velocity * delta


## 通过修正系数修正控制点1，通过起点和终点直线距离计算贝塞尔曲线时间参数，控制点2和终点相同，通过bezier_interpolate计算相应时间点的位置信息
func set_next_point(delta: float, target_pos: Vector2) -> void:
	current_time += delta
	var distance: float = global_position.distance_to(target_pos)
	# 两点之间，距离最短，时间也最短
	var min_time: float = distance / speed
	var t: float = min(current_time / min_time, 1)
	var start_control_point: Vector2 = direction * speed * control_1_fix
	next_point = global_position.bezier_interpolate(start_control_point, target_pos, target_pos, t)


## 通过贝塞尔曲线函数bezier_interpolate计算箭矢运动方向
func action5(delta: float) -> void:
	var enemy: Node2D = get_tree().get_first_node_in_group("bezier_enemy") as Node2D	
	if !enemy:
		global_position += direction * delta * speed
		return
	
	set_next_point(delta, enemy.global_position)
	look_at(next_point)
	global_position = global_position.move_toward(next_point, speed * delta)


## 通过修正系数修正控制点1，固定控制点1的方向，起点和终点直线距离计算贝塞尔曲线时间参数，控制点2和终点相同，通过bezier_interpolate计算相应时间点的位置信息
func set_next_point2(delta: float, target_pos: Vector2) -> void:
	current_time += delta
	var distance: float = current_player_pos.distance_to(target_pos)
	# 两点之间，距离最短，时间也最短
	var min_time: float = distance / speed
	var t: float = min(current_time / min_time, 1)
	direction = global_position.direction_to(target_pos)
	var start_control_point: Vector2 = direction.rotated(rad_to_deg(control_1_direction) * (-1)) * speed * control_1_fix
	next_point = current_player_pos.bezier_interpolate(start_control_point, target_pos, target_pos, t)


## 固定抛物线曲线移动方向，通过贝塞尔曲线函数bezier_interpolate模拟抛物线
func action6(delta: float) -> void:
	var enemy: Node2D = get_tree().get_first_node_in_group("bezier_enemy") as Node2D	
	if !enemy:
		global_position += direction * delta * speed
		return
	
	set_next_point2(delta, enemy.global_position)
	look_at(next_point)
	global_position = global_position.move_toward(next_point, speed * delta)
	

func on_timer_timeout() -> void:
	queue_free()


func on_hit_box_area_entered(area: Area2D) -> void:
	if area.owner.is_in_group("bezier_enemy"):
		queue_free()
