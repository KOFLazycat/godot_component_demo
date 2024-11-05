extends Node2D

@export var speed: float = 1000.0

var type: int = 1
var direction: Vector2 = Vector2.ZERO # 箭矢指向的归一化向量

var current_velocity: Vector2 = Vector2.ZERO# 箭矢速度向量
var drag_factor: float = 0.15

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


func _physics_process(delta: float) -> void:
	callv("action" + str(type), [delta])


func action1(delta: float) -> void:
	global_position += direction * speed * delta


func action2(delta):
	var enemy = get_tree().get_first_node_in_group("enemy")
	if !enemy:
		global_position += direction * delta * speed
		return
		
	global_position = global_position.move_toward(enemy.global_position, delta * speed)
	look_at(enemy.global_position)


func action3(delta):
	var enemy = get_tree().get_first_node_in_group("enemy")
	if !enemy:
		global_position += direction * delta * speed
		return
		
	var direction_ = global_position.direction_to(enemy.global_position)
	var desired_velocity = direction_ * speed
	var change = (desired_velocity - current_velocity) * drag_factor
	current_velocity += change
	
	position += current_velocity * delta
	look_at(global_position + current_velocity)


func action4(delta):
	var enemy = get_tree().get_first_node_in_group("enemy")
	if !enemy:
		global_position += direction * delta * speed
		return
	
	var target_rotation = (enemy.global_position - global_position).angle()
	rotation = lerp_angle(rotation, target_rotation, 0.07)
	current_velocity = Vector2(speed, 0).rotated(rotation)
	position += current_velocity * delta


func set_next_point(delta):
	var enemy = get_tree().get_first_node_in_group("enemy") as Node2D
	if !enemy:
		global_position += direction * delta * speed
		return
	
	current_time += delta	
	var distance = global_position.distance_to(enemy.global_position)
	var all_time = distance / speed
	var t = min(current_time / all_time, 1)
	var start_control_point = direction * speed * 1.7
	next_point = global_position.bezier_interpolate(start_control_point, enemy.global_position, enemy.global_position, t)


func action5(delta):
	var enemy = get_tree().get_first_node_in_group("enemy") as Node2D	
	if !enemy:
		global_position += direction * delta * speed
		return
	
	set_next_point(delta)
	look_at(next_point)
	global_position = global_position.move_toward(next_point, speed * delta)


func set_next_point2(delta):
	current_time += delta
	var distance = current_player_pos.distance_to(current_enemy_pos)
	var all_time = distance / speed
	var t = min(current_time / all_time, 1)
#	var start_control_point = direction * speed * 1.7
	var control_p_v = current_player_pos.direction_to(current_enemy_pos)*distance*length_base/3
	var rrr = acos(1/length_base)
	if control_p_v.x > 0:
		rrr = rrr * (-1)
	control_p_v = control_p_v.rotated(rrr)
	var start_control_point = current_player_pos + control_p_v
	next_point = current_player_pos.bezier_interpolate(start_control_point, start_control_point, current_enemy_pos, t)

# 抛物线子弹
func action6(delta):
	set_next_point2(delta)
	look_at(next_point)
	global_position = global_position.move_toward(next_point, speed * delta)
	

func _on_timer_timeout():
	queue_free()
