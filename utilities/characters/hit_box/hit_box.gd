class_name HitBox extends Area2D

"""
受击盒节点（继承自Area2D）
功能：
- 接收伤害数据并应用伤害倍率
- 触发伤害相关信号（hitbox_hurt/took_damage）
- 通过碰撞层控制受击盒启用/禁用
使用说明：
- 需配合DamageData自定义类型使用（包含damage_amount和spawn_extra_blood属性）
- damage_multiplier：伤害倍率（如头部受击盒设为2.0）
- spawn_extra_blood_on_hit：是否触发额外血液特效
"""

# 伤害倍率（1.0为正常，>1为易伤，<1为抗性）
@export var damage_multiplier: float = 1.0 : set = _set_damage_multiplier

# 受击时是否生成额外血液特效
@export var spawn_extra_blood_on_hit: bool = false

# 碰撞层常量（提高可读性，替代硬编码数值）
const COLLISION_LAYER_DISABLED: int = 0  # 禁用碰撞层（无碰撞检测）
const COLLISION_LAYER_ENABLED: int = 16  # 启用碰撞层（对应第16层，需与项目碰撞层配置一致）

signal hitbox_hurt(damage_data: DamageData)  # 传递处理后的伤害数据
signal took_damage  # 通知成功造成有效伤害（伤害值>0时触发）


func _ready() -> void:
	# 初始化碰撞层为启用状态（可根据需求调整）
	collision_layer = COLLISION_LAYER_ENABLED


func hurt(damage_data: DamageData) -> void:
	"""
	处理伤害逻辑
	@param damage_data: 包含基础伤害值和血液特效标志的伤害数据对象
	"""
	# 防御性检查：避免无效的伤害数据
	if not is_instance_valid(damage_data):
		push_warning("伤害数据无效（damage_data为null），跳过伤害处理")
		return

	# 应用伤害倍率
	damage_data.damage_amount = roundi(damage_multiplier * damage_data.damage_amount)

	# 设置血液特效标志（根据受击盒配置）
	damage_data.spawn_extra_blood = spawn_extra_blood_on_hit

	hitbox_hurt.emit(damage_data)

	# 触发有效伤害信号（仅当最终伤害>0时）
	if damage_data.damage_amount > 0:
		took_damage.emit()


func disable() -> void:
	"""禁用受击盒（关闭碰撞检测）"""
	collision_layer = COLLISION_LAYER_DISABLED


func enable() -> void:
	"""启用受击盒（开启碰撞检测）"""
	collision_layer = COLLISION_LAYER_ENABLED


func _set_damage_multiplier(value: float) -> void:
	"""设置伤害倍率（带最小值限制，防止无效倍率）"""
	damage_multiplier = max(value, 0.0)  # 伤害倍率不能为负数
