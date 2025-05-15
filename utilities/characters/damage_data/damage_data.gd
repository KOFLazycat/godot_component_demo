class_name DamageData 
extends Node

"""
伤害数据类（继承自Resource，轻量级数据容器）
用于在不同系统（如HealthManager、BloodSpawner）之间传递统一的伤害信息。
支持在编辑器中通过资源文件（.tres）创建和配置，减少运行时开销。

核心字段说明：
- damage_amount: 伤害值（≥0）
- spawn_blood: 是否生成血液特效
- damage_direction: 伤害来源方向（单位向量）
- hit_normal: 碰撞点法线（单位向量，描述被击表面朝向）
- source_of_damage: 造成伤害的节点（可选，需为Node2D或子类）
"""

# 无眩晕时间的常量（替代-1的模糊语义）
const NO_STUN_TIME: float = -1.0

# 伤害值（≥0）
@export var damage_amount: int = 0 : set = _set_damage_amount
# 是否生成基础血液特效
@export var spawn_blood: bool = true
# 是否生成额外血液特效（如暴击时）
@export var spawn_extra_blood: bool = false
# 是否生成血云特效（如重伤时）
@export var spawn_blood_cloud: bool = false
# 是否播放音效（如受击声）
@export var play_sound: bool = true
# 伤害来源方向（单位向量，用于计算飞溅方向）
@export var damage_direction: Vector2 = Vector2.RIGHT : set = _set_damage_direction
# 碰撞点世界坐标（如武器击中敌人的具体位置）
@export var damage_position: Vector2
# 碰撞点法线（单位向量，描述被击表面的朝向，如墙面外侧法线）
@export var hit_normal: Vector2 = Vector2.RIGHT : set = _set_hit_normal
# 造成伤害的责任节点（如攻击的角色，可选）
@export var source_of_damage: Node2D
# 眩晕时间（秒，NO_STUN_TIME表示无眩晕）
@export var stun_time: float = NO_STUN_TIME : set = _set_stun_time
# 击退系数（≥0，1.0为正常击退，0.5为削弱，2.0为增强）
@export var knockback_modifier: float = 1.0 : set = _set_knockback_modifier


func _set_damage_amount(value: int) -> void:
	"""设置伤害值（校验非负）"""
	if value < 0:
		push_warning("伤害值不能为负数，已自动修正为0")
		damage_amount = 0
	else:
		damage_amount = value


func _set_damage_direction(value: Vector2) -> void:
	if value == Vector2.ZERO:
		damage_direction = Vector2.RIGHT
	else:
		damage_direction = value.normalized()


func _set_hit_normal(value: Vector2) -> void:
	if value == Vector2.ZERO:
		hit_normal = Vector2.RIGHT
	else:
		hit_normal = value.normalized()


func _set_stun_time(value: float) -> void:
	"""设置眩晕时间（允许负数表示无眩晕）"""
	stun_time = value


func _set_knockback_modifier(value: float) -> void:
	"""设置击退系数（校验非负）"""
	if value < 0:
		push_warning("击退系数不能为负数，已自动修正为0")
		knockback_modifier = 0.0
	else:
		knockback_modifier = value


# region 便捷构造方法（可选，提升使用体验）
static func new_damage(
	amount: int,
	direction: Vector2,
	position: Vector2,
	normal: Vector2,
	source: Node2D = null,
	stun: float = NO_STUN_TIME,
	is_spawn_blood_cloud: bool = false,
	knockback: float = 1.0
) -> DamageData:
	"""
	静态构造方法：快速创建DamageData实例
	@param amount: 伤害值（≥0）
	@param direction: 伤害方向（自动归一化）
	@param position: 碰撞点位置
	@param normal: 碰撞点法线（自动归一化）
	@param source: 伤害来源节点（可选）
	@param stun: 眩晕时间（秒，默认无眩晕）
	@param is_spawn_blood_cloud: 是否生成血雾
	@param knockback: 击退系数（≥0，默认1.0）
	"""
	var data: DamageData = DamageData.new()
	data.damage_amount = amount
	data.damage_direction = direction
	data.damage_position = position
	data.hit_normal = normal
	data.source_of_damage = source
	data.stun_time = stun
	data.spawn_blood_cloud = is_spawn_blood_cloud
	data.knockback_modifier = knockback
	return data
# endregion
