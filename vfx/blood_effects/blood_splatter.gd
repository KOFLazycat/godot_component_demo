class_name BloodSplatter extends Node2D

"""
血液飞溅特效节点（继承自Node2D）
功能：
- 随机化血滴外观（帧、旋转、缩放、颜色）
- 抛射血滴到目标位置（飞行中调整视觉效果）
- 落地后恢复视觉状态并播放音效
- 支持数据持久化（保存/加载血滴状态）

依赖节点：
- Sprite2D（名称需与场景树一致，用于显示血滴）
- SplatterSounds（可选，AudioPlayer类型，用于播放飞溅音效）
"""

# 飞行状态Z轴层级（确保飞行血滴在其他血滴上方）
const IN_AIR_Z_INDEX: int = 10
# 地面状态Z轴层级（确保落地血滴在底层）
const GROUND_Z_INDEX: int = 1
# 随机拉伸概率（0.0~1.0）
const CHANCE_TO_STRETCH: float = 0.2
# 落地后缩放时间
const HIT_SPREAD_TIME: float = 0.5
# 落地后概率拉伸系数
const FINAL_SCALE_STRETCH: Vector2 = Vector2(1.4, 0.7)

# 血滴精灵帧数量（需与精灵图集中的帧数一致）
@export var sprite_sheet_frame_count: int = 4 : set = _set_sprite_sheet_frame_count

# 血滴颜色范围（深色→浅色插值）
@export_color_no_alpha var blood_dark_color: Color
@export_color_no_alpha var blood_light_color: Color

# 飞行速度范围（像素/秒）
@export var min_travel_speed: float = 500.0 : set = _set_min_travel_speed
@export var max_travel_speed: float = 700.0 : set = _set_max_travel_speed

# 飞行中缩放比例（相对于最终缩放）
@export var in_air_scale: float = 0.4 : set = _set_in_air_scale
# 飞行中颜色暗化比例（0.0~1.0，0为原色，1为全黑）
@export var in_air_modulate_percent: float = 0.3 : set = _set_in_air_modulate_percent

# 落地后缩放范围（确保min≤max）
@export var min_blood_scale: float = 0.4 : set = _set_min_blood_scale
@export var max_blood_scale: float = 0.7 : set = _set_max_blood_scale

# 是否为静态血滴（不参与抛射）
@export var is_static: bool = false

# 最终缩放（落地后恢复的缩放）
@onready var final_scale: Vector2 = scale
# 最终旋转（落地后恢复的角度）
@onready var final_angle: float = global_rotation
# 依赖节点（通过@onready+校验确保存在性）
@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null
@onready var splatter_sounds: PlayRandomSound = $SplatterSounds if has_node("SplatterSounds") else null

# 血滴基础颜色（随机插值结果）
var base_color: Color
# 飞行方向（初始向右）
var fly_direction: Vector2 = Vector2.RIGHT
# 是否处于飞行状态
var in_air: bool = false
# 目标位置（落地后位置）
var final_pos: Vector2
# 是否从存档加载（避免重复随机化）
var loaded_from_save: bool = false


func _ready() -> void:
	# 校验关键节点存在性（避免空引用崩溃）
	if not sprite:
		push_error("Sprite2D节点缺失，血滴无法显示！")
		queue_free()
		return

	if not loaded_from_save:
		_randomize_blood_splatter()  # 非存档加载时随机化外观
		if is_in_group("instanced"):
			add_to_group("serializable")  # 加入可序列化组


func _randomize_blood_splatter() -> void:
	"""随机化血滴外观（内部方法）"""
	# 随机精灵帧（确保不越界）
	sprite.frame = randi_range(0, sprite_sheet_frame_count - 1)

	if not is_static:
		# 随机旋转（0~360度）
		sprite.rotation = randf_range(0.0, TAU)
		# 随机缩放（确保在min~max之间）
		var random_scale: float = randf_range(min_blood_scale, max_blood_scale)
		sprite.scale = Vector2.ONE * random_scale

	# 随机颜色（在深浅色之间插值）
	base_color = blood_dark_color.lerp(blood_light_color, randf_range(0.0, 1.0))
	modulate = base_color


func fling_blood(start_pos: Vector2, end_pos: Vector2, play_splatter_sound: bool = false) -> void:
	"""
	抛射血滴到目标位置（核心方法）
	@param start_pos: 起始位置
	@param end_pos: 目标位置
	@param play_splatter_sound: 是否播放飞溅音效
	"""
	if is_static:
		return  # 静态血滴不参与抛射

	in_air = true
	final_pos = end_pos
	fly_direction = start_pos.direction_to(end_pos)  # 计算飞行方向
	z_index = IN_AIR_Z_INDEX  # 设置飞行状态Z层级
	global_position = start_pos  # 初始化起始位置

	# 飞行中视觉调整（缩放和颜色暗化）
	scale = Vector2.ONE * in_air_scale * randf_range(0.5, 1.0)
	modulate = base_color.lerp(Color.BLACK, in_air_modulate_percent)

	# 随机拉伸处理（概率CHANCE_TO_STRETCH）
	if randf_range(0.0, 1.0) < CHANCE_TO_STRETCH:
		final_angle = fly_direction.angle()  # 旋转方向与飞行方向一致
		final_scale.x *= FINAL_SCALE_STRETCH.x  # 水平方向拉伸
		final_scale.y *= FINAL_SCALE_STRETCH.y  # 垂直方向压缩

	# 计算飞行时间（距离/速度）
	var travel_distance: float = start_pos.distance_to(end_pos)
	var travel_speed: float = randf_range(min_travel_speed, max_travel_speed)
	var travel_time: float = travel_distance / travel_speed

	# 创建补间动画（管理tween生命周期）
	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position", end_pos, travel_time)
	tween.tween_callback(_on_hit_ground.bind(play_splatter_sound))


func _on_hit_ground(play_splatter_sound: bool = false) -> void:
	"""血滴落地时的处理逻辑（内部方法）"""
	in_air = false
	modulate = base_color  # 恢复原始颜色
	z_index = GROUND_Z_INDEX  # 设置地面状态Z层级
	global_rotation = final_angle  # 恢复目标旋转角度

	# 创建缩放恢复补间动画
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", final_scale, HIT_SPREAD_TIME).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

	# 播放飞溅音效（校验节点类型和播放标志）
	if play_splatter_sound and splatter_sounds is PlayRandomSound:
		splatter_sounds.play()
		# 延迟清理音效节点（确保音效播放完成）
		await get_tree().create_timer(1.0).timeout
		if is_instance_valid(splatter_sounds):
			splatter_sounds.queue_free() # reduce node spam in scene


func get_save_data() -> Dictionary:
	"""获取需要保存的血滴数据（支持序列化）"""
	var save_data: Dictionary = {}
	save_data[SaveManager.INSTANCE_ID_KEY] = "res://vfx/blood_effects/blood_splatter.tscn"
	save_data.instance_tag = "blood_splatter"
	save_data.sprite_frame = sprite.frame
	save_data.sprite_rotation = sprite.rotation
	save_data.sprite_scale = sprite.scale.x  # 统一缩放，仅保存x值
	save_data.base_color = var_to_str(base_color)  # 直接保存Color对象（Godot自动序列化）
	var save_transform = global_transform
	if in_air:
		save_transform = Transform2D()
		save_transform.rotated(final_angle)
		save_transform.scaled(final_scale)
		save_transform.origin = final_pos
	save_data.global_transform = var_to_str(save_transform)
	return save_data


func load_save_data(save_data: Dictionary) -> void:
	"""从存档恢复血滴状态（兼容旧数据格式）"""
	loaded_from_save = true
	add_to_group("instanced")
	add_to_group("serializable")

	if "sprite_frame" in save_data:
		sprite.frame = int(save_data.sprite_frame)
	if "sprite_rotation" in save_data:
		sprite.rotation = save_data.sprite_rotation
	if "sprite_scale" in save_data:
		sprite.scale = Vector2.ONE * save_data.sprite_scale
	if "base_color" in save_data:
		base_color = str_to_var(save_data.base_color)
		modulate = base_color
	if "global_transform" in save_data:
		global_transform = str_to_var(save_data.global_transform)

	# 清理残留音效节点（避免存档加载时重复）
	if splatter_sounds:
		splatter_sounds.queue_free()


# region 参数设置器（带边界校验）
func _set_sprite_sheet_frame_count(value: int) -> void:
	"""设置精灵帧数量（至少1帧）"""
	sprite_sheet_frame_count = max(value, 1)

func _set_min_travel_speed(value: float) -> void:
	"""设置最小飞行速度（不超过最大速度）"""
	min_travel_speed = min(value, max_travel_speed)

func _set_max_travel_speed(value: float) -> void:
	"""设置最大飞行速度（不小于最小速度）"""
	max_travel_speed = max(value, min_travel_speed)

func _set_in_air_scale(value: float) -> void:
	"""设置飞行中缩放比例（0.1~1.0）"""
	in_air_scale = clamp(value, 0.1, 1.0)

func _set_in_air_modulate_percent(value: float) -> void:
	"""设置飞行中颜色暗化比例（0.0~1.0）"""
	in_air_modulate_percent = clamp(value, 0.0, 1.0)

func _set_min_blood_scale(value: float) -> void:
	"""设置最小落地缩放（不超过最大缩放）"""
	min_blood_scale = min(value, max_blood_scale)

func _set_max_blood_scale(value: float) -> void:
	"""设置最大落地缩放（不小于最小缩放）"""
	max_blood_scale = max(value, min_blood_scale)
# endregion
