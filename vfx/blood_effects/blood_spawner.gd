class_name BloodSpawner extends Node2D

"""
血液生成器节点（继承自Node2D）
功能：
- 根据伤害数据生成血滴（BloodSplatter）和血云（BloodCloud）特效
- 使用射线检测确定血滴落地位置
- 支持配置生成数量、距离、角度等参数

依赖节点：
- RayCast2D（名称需与场景树一致，用于碰撞检测）
- ImpactSounds（可选，用于播放冲击音效）

资源路径：
- BLOOD_SPLATTER: 血滴特效场景路径
- BLOOD_CLOUD: 血云特效场景路径
"""

# 血滴特效资源路径（可在编辑器中修改）
@export var blood_splatter_path: String = "res://vfx/blood_effects/blood_splatter.tscn"
# 血云特效资源路径（可在编辑器中修改）
@export var blood_cloud_path: String = "res://vfx/blood_effects/blood_cloud.tscn"

# 最大血滴生成距离（像素）
@export var max_splatter_dist: float = 130.0 : set = _set_max_splatter_dist
# 血滴生成最小数量
@export var min_splatter_count: int = 3 : set = _set_min_splatter_count
# 血滴生成最大数量
@export var max_splatter_count: int = 5 : set = _set_max_splatter_count
# 血雾喷射角度范围（度数，0~360）
@export var blood_spray_arc: float = 180.0 : set = _set_blood_spray_arc
# 墙壁偏移距离（像素，用于调整血滴在碰撞点的位置）
@export var blood_wall_offset: float = 15.0 : set = _set_blood_wall_offset

# 依赖节点（带类型校验）
@onready var ray_cast: RayCast2D = $RayCast2D if has_node("RayCast2D") else null
@onready var impact_sounds: PlayRandomSound = $ImpactSounds if has_node("ImpactSounds") else null

# 预加载资源（使用变量管理，避免硬编码）
var blood_splatter_scene: PackedScene
var blood_cloud_scene: PackedScene

func _ready():
	# 校验射线检测节点存在性
	if not ray_cast:
		push_error("RayCast2D节点缺失，血液生成器无法正常工作！")
		queue_free()
		return
	
	# 加载资源（支持编辑器动态配置路径）
	blood_splatter_scene = load(blood_splatter_path)
	blood_cloud_scene = load(blood_cloud_path)


func spawn_blood_from_damage_data(damage_data: DamageData):
	"""
	根据伤害数据生成血液特效
	@param damage_data: 包含伤害位置、方向、特效开关等的伤害数据对象
	"""
	if not damage_data.spawn_blood:
		return
	
	# 设置生成器位置为伤害位置
	global_position = damage_data.damage_position
	
	# 计算平均方向（伤害法线与伤害方向的反方向）
	var dir: Vector2 = damage_data.hit_normal - damage_data.damage_direction
	
	# 生成主方向血滴
	_splatter_blood(dir / 2.0, damage_data.play_sound)
	_splatter_blood(-dir / 2.0, damage_data.play_sound)
	
	# 生成额外血滴（如果需要）
	if damage_data.spawn_extra_blood:
		_splatter_blood(damage_data.hit_normal, damage_data.play_sound, true)
	
	# 生成血云（如果需要）
	if damage_data.spawn_blood_cloud:
		_spawn_blood_cloud()
	
	# 播放音效（如果需要）
	if damage_data.play_sound and impact_sounds != null:
		impact_sounds.play()


func _splatter_blood(dir: Vector2 = Vector2.DOWN, play_sound: bool = true, is_extra: bool = false):
	"""
	生成血滴的核心逻辑（内部方法）
	@param dir: 基础生成方向
	@param play_sound: 是否播放音效
	@param is_extra: 是否为额外血滴（数量更多）
	"""
	var count: int = randi_range(min_splatter_count, max_splatter_count)
	if is_extra:
		count *= 2
	
	for i in count:
		var offset: Vector2 = _get_splatter_offset(dir, is_extra)
		_spawn_blood(offset, i%3==0 and play_sound)


func _get_splatter_offset(base_dir: Vector2 = Vector2.DOWN, is_extra: bool = false) -> Vector2:
	"""
	获取血滴生成偏移量（内部方法）
	@param base_dir: 基础方向
	@param is_extra: 是否为额外血滴（距离更远）
	@return: 随机偏移向量
	"""
	var angle: float = deg_to_rad(randf_range(-blood_spray_arc / 2.0, blood_spray_arc / 2.0))
	var rotated_dir: Vector2 = base_dir.rotated(angle)
	
	var distance: float = randf_range(0.0, max_splatter_dist)
	if is_extra:
		distance *= 1.5
	return rotated_dir * distance


func _spawn_blood(pos_offset: Vector2 = Vector2.ZERO, play_splatter_sound: bool = false):
	"""
	实例化血滴并处理碰撞检测（内部方法）
	@param pos_offset: 生成位置偏移量
	@param play_splatter_sound: 是否播放血滴飞溅音效
	"""
	var blood_splatter: BloodSplatter = blood_splatter_scene.instantiate()
	# 需要在add_child之前使用add_to_group，否则BloodSplatter的_onready函数就不能正确把blood_splatter加入到serializable组中
	blood_splatter.add_to_group("instanced")
	get_tree().get_root().add_child(blood_splatter)

	var goal_pos: Vector2 = global_position + pos_offset
	
	# 射线检测碰撞位置（世界坐标→本地坐标转换）
	ray_cast.enabled = true
	ray_cast.target_position = ray_cast.to_local(goal_pos)  # 修正：将世界坐标转换为本地坐标
	ray_cast.force_raycast_update()
	
	if ray_cast.is_colliding():
		goal_pos = ray_cast.get_collision_point()  # 碰撞点为世界坐标
		var normal: Vector2 = ray_cast.get_collision_normal()
		pos_offset = normal * blood_wall_offset
		goal_pos += pos_offset
	ray_cast.enabled = false
	blood_splatter.fling_blood(global_position, goal_pos, play_splatter_sound)


func _spawn_blood_cloud():
	"""实例化血云特效（内部方法）"""
	var blood_cloud: BloodCloudEffect = blood_cloud_scene.instantiate()
	blood_cloud.global_position = global_position
	get_tree().get_root().add_child(blood_cloud)

# region 参数设置器（带边界校验）
func _set_max_splatter_dist(value: float) -> void:
	"""设置最大血滴距离（必须≥0）"""
	max_splatter_dist = max(value, 0.0)

func _set_min_splatter_count(value: int) -> void:
	"""设置最小血滴数量（必须≤最大数量且≥1）"""
	min_splatter_count = clamp(value, 1, max_splatter_count)

func _set_max_splatter_count(value: int) -> void:
	"""设置最大血滴数量（必须≥最小数量且≥1）"""
	max_splatter_count = clamp(value, min_splatter_count, 100)  # 限制最大数量防止性能问题

func _set_blood_spray_arc(value: float) -> void:
	"""设置血雾喷射角度（0~360度）"""
	blood_spray_arc = clamp(value, 0.0, 360.0)

func _set_blood_wall_offset(value: float) -> void:
	"""设置墙壁偏移距离（必须≥0）"""
	blood_wall_offset = max(value, 0.0)
# endregion
