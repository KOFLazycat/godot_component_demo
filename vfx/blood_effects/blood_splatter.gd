class_name BloodSplatter
extends Node2D
## 2D血液飞溅效果，支持动态抛洒和静态展示

# 子节点引用
@onready var sprite: Sprite2D = $Sprite2D  # 飞溅的精灵图
@onready var initial_scale: Vector2 = scale  # 节点落地时初始缩放（编辑器预设值）
@onready var initial_rotation: float = global_rotation  # 节点落地时初始旋转（编辑器预设值）

# 精灵表参数
@export var sprite_sheet_frame_count: int = 4  # 精灵表总帧数

# 颜色参数
@export_color_no_alpha var blood_dark_color: Color  # 基础深色
@export_color_no_alpha var blood_light_color: Color  # 基础亮色

# 运动参数
@export var min_travel_speed: float = 500.0  # 最小飞行速度（像素/秒）
@export var max_travel_speed: float = 700.0  # 最大飞行速度（像素/秒）
@export var in_air_scale: float = 0.4  # 飞行时整体缩放比例
@export var in_air_modulate_percent: float = 0.3  # 飞行时颜色加深比例（0-1）

# 外观参数
@export var max_blood_scale: float = 0.7  # 最大基础缩放
@export var min_blood_scale: float = 0.4  # 最小基础缩放
@export var blood_scale_spread_time: float = 0.2 # 血迹落地后蔓延扩大时间
@export var chance_to_stretch: float = 0.2  # 拉伸概率（0-1）

# 静态模式（不参与动态效果）
@export var is_static = false

# 层级控制
const GROUND_Z_INDEX: int = 1    # 落地后的渲染层级
const IN_AIR_Z_INDEX: int = 10   # 飞行中的渲染层级

# 状态变量
var base_color: Color            # 基础颜色（随机混合深浅色）
var final_pos: Vector2           # 目标终点位置
var final_scale: Vector2         # 落地后的目标缩放
var final_angle: float           # 落地后的目标旋转
var loaded_from_save: bool = false  # 存档加载标记
var in_air = false				 # 是否在空中


func _ready() -> void:
	if loaded_from_save:
		return
	randomize_blood_splatter()
	if is_in_group("instanced"):
		add_to_group("serializable")


## 随机化飞溅效果的基础属性
func randomize_blood_splatter() -> void:
	sprite.frame = randi_range(0, sprite_sheet_frame_count - 1)
	if not is_static:
		rotation = randf_range(0.0, TAU)  # 修改节点旋转而非精灵图
		scale = Vector2.ONE * randf_range(min_blood_scale, max_blood_scale)
	base_color = blood_dark_color.lerp(blood_light_color, randf())
	modulate = base_color


## 抛洒血液动画
func fling_blood(start_pos: Vector2, end_pos: Vector2, play_splatter_sound: bool = false) -> void:
	if is_static:
		return
	
	# 重置最终参数为初始值
	final_scale = initial_scale
	final_angle = initial_rotation
	final_pos = end_pos
	
	# 计算飞行方向
	var fly_direction: Vector2 = start_pos.direction_to(end_pos)
	
	# 设置飞行初始状态
	z_index = IN_AIR_Z_INDEX
	global_position = start_pos
	scale = Vector2.ONE * in_air_scale
	modulate = base_color.lerp(Color.BLACK, in_air_modulate_percent)
	
	# 随机拉伸逻辑
	if randf() < chance_to_stretch:
		final_angle = fly_direction.angle()  # 根据飞行方向调整最终角度
		final_scale.y *= 0.7   # 垂直压缩
		final_scale.x *= 1.4   # 水平拉伸
	
	# 计算飞行时间并创建补间动画
	var travel_speed: float = randf_range(min_travel_speed, max_travel_speed)
	var travel_time: float = start_pos.distance_to(end_pos) / travel_speed
	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position", end_pos, travel_time).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_callback(on_hit_ground.bind(play_splatter_sound))


## 落地回调处理
func on_hit_ground(play_splatter_sound: bool = false) -> void:
	modulate = base_color
	z_index = GROUND_Z_INDEX
	global_rotation = final_angle  # 应用最终旋转
	# 应用最终缩放
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", final_scale, blood_scale_spread_time).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	# 播放音效逻辑
	if play_splatter_sound and has_node("SplatterSounds"):
		var sounds_player: AudioStreamPlayer = get_node("SplatterSounds")
		sounds_player.play()
		await sounds_player.finished  # 等待音效播放完毕
		if is_instance_valid(sounds_player):
			sounds_player.queue_free()


#func get_save_data() -> Dictionary:
	#var save_data = {}
	#save_data[SaveManager.INSTANCE_ID_KEY] = "res://vfx/blood_effects/blood_splatter.tscn" # either pass path or uid
	#save_data.instance_tag = "blood_splatter"
	#save_data.sprite_frame = sprite.frame
	#save_data.global_rotation = global_rotation
	#save_data.scale = scale.x # will always be scaled uniformly
	#save_data.base_color = var_to_str(base_color)
	#var save_transform = global_transform
	#if in_air:
		#save_transform = Transform2D()
		#save_transform.rotated(final_angle)
		#save_transform.scaled(final_scale)
		#save_transform.origin = final_pos
	#save_data.global_transform = var_to_str(save_transform)
	#return save_data
#
#func load_save_data(save_data: Dictionary):
	#loaded_from_save = true
	#add_to_group("instanced")
	#add_to_group("serializable")
	#if "sprite_frame" in save_data:
		#sprite.frame = int(save_data.sprite_frame)
	#if "global_rotation" in save_data:
		#global_rotation = save_data.global_rotation
	#if "scale" in save_data:
		#scale = Vector2.ONE * save_data.sprite_scale
	#if "base_color" in save_data:
		#base_color = str_to_var(save_data.base_color)
		#modulate = base_color
	#if "global_transform" in save_data:
		#global_transform = str_to_var(save_data.global_transform)
	#
	#if has_node("SplatterSounds"):
		#get_node("SplatterSounds").queue_free()
