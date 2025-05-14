## 血液效果生成器，负责处理血液飞溅和血雾效果
class_name BloodSpawner 
extends Node2D

const BLOOD_SPLATTER: PackedScene = preload("res://vfx/blood_effects/blood_splatter.tscn")
const BLOOD_CLOUD: PackedScene = preload("res://vfx/blood_effects/blood_cloud.tscn")

@export var max_splatter_dist: float = 130.0    # 单个血渍最大飞溅距离
@export var blood_wall_offset: float = 15.0     # 墙面碰撞时的位置偏移
@export var min_splatter_count: int = 3         # 最小血渍生成数量
@export var max_splatter_count: int = 5         # 最大血渍生成数量
@export var blood_spray_arc: float = 180.0      # 血渍飞溅扩散角度（单位：度）

@onready var ray_cast_2d: RayCast2D = $RayCast2D  # 用于检测碰撞的射线
@onready var impact_sounds: PlayRandomSound = $ImpactSounds


## 根据伤害数据生成血液效果
func spawn_blood_from_damage_data(damage_data: DamageData) -> void:
	if not damage_data.spawn_blood:
		return
	
	# 设置生成器到命中点位置
	global_position = damage_data.damage_position
	
	# 计算平均方向：表面法线与伤害方向的中间值
	var base_dir: Vector2 = (damage_data.hit_normal + damage_data.damage_direction).normalized()
	
	# 基础飞溅（正反两个方向）
	generate_blood_spray(base_dir, damage_data.play_sound)
	generate_blood_spray(-base_dir, damage_data.play_sound)
	
	# 额外飞溅处理
	if damage_data.spawn_extra_blood:
		generate_blood_spray(damage_data.hit_normal, damage_data.play_sound, 2)
	
	# 血雾生成
	if damage_data.spawn_blood_cloud:
		spawn_blood_cloud()
	
	# 音效播放
	if damage_data.play_sound and not impact_sounds.is_playing():
		impact_sounds.play()


## 通用血渍生成方法
func generate_blood_spray(base_direction: Vector2, play_sound: bool, intensity: int = 1) -> void:
	var count: int = randi_range(min_splatter_count, max_splatter_count) * intensity
	for i in count:
		var sound_flag: bool = (i % 3) == 0 and play_sound  # 每第3个播放音效
		spawn_blood(
			calculate_splatter_offset(base_direction), 
			sound_flag
		)


## 计算单个血渍的偏移量
func calculate_splatter_offset(base_direction: Vector2) -> Vector2:
	# 应用随机角度偏移（-90°到+90°之间）
	var random_angle: float = deg_to_rad(randf_range(-blood_spray_arc/2, blood_spray_arc/2))
	var final_dir: Vector2 = base_direction.rotated(random_angle)
	
	# 应用随机距离
	return final_dir * randf_range(0.0, max_splatter_dist)


## 生成单个血渍实例
func spawn_blood(pos_offset: Vector2 = Vector2.ZERO, play_sound: bool = false) -> void:
	# 实例化并配置血渍
	var splatter: BloodSplatter = BLOOD_SPLATTER.instantiate()
	splatter.add_to_group("instanced")
	
	# 获取目标位置并检测碰撞
	var goal_pos: Vector2 = global_position + pos_offset
	update_raycast_target(goal_pos)
	
	# 处理碰撞偏移
	if ray_cast_2d.is_colliding():
		goal_pos = ray_cast_2d.get_collision_point()
		goal_pos += ray_cast_2d.get_collision_normal() * blood_wall_offset
	
	# 添加到场景树并启动动画
	get_parent().add_child(splatter)  # 改为添加到当前父节点
	splatter.fling_blood(global_position, goal_pos, play_sound)


## 更新射线检测目标点
func update_raycast_target(target: Vector2) -> void:
	ray_cast_2d.enabled = true
	ray_cast_2d.target_position = to_local(target)
	ray_cast_2d.force_raycast_update()
	ray_cast_2d.enabled = false  # 立即禁用避免影响其他逻辑


## 生成血雾效果
func spawn_blood_cloud() -> void:
	var blood_cloud: GPUParticles2D = BLOOD_CLOUD.instantiate()
	blood_cloud.global_position = global_position
	get_parent().add_child(blood_cloud)  # 统一添加到当前父节点
