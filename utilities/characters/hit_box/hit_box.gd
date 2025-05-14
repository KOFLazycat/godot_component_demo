# 受击盒类：用于处理特定区域的伤害接收逻辑（如头部、躯干等）
# 继承自Area2D，利用碰撞检测触发伤害逻辑
class_name HitBox extends Area2D

# --------------------- 信号定义 ---------------------
# 发射伤害数据信号（携带处理后的伤害信息）
signal hitbox_hurt(damage_data: DamageData)
# 实际造成伤害时发射的信号（用于音效/特效触发）
signal took_damage

# --------------------- 可配置属性 ---------------------
# 关联的根节点（通常为角色的CharacterBody2D，用于访问角色属性）
@export var root_node: CharacterBody2D
# 伤害倍率（用于区分弱点/普通部位，如爆头设置为2.0）
@export_range(0.1, 10.0, 0.1) var damage_multiplier: float = 1.0
# 是否在受击时生成额外血液效果
@export var spawn_extra_blood_on_hit: bool = false

# 碰撞层常量（建议根据项目实际碰撞层配置调整）
const HITBOX_LAYER_ACTIVE: int = 16  # 激活时的碰撞层（可与项目碰撞层定义同步）
const HITBOX_LAYER_INACTIVE: int = 0  # 禁用时的碰撞层（无碰撞检测）

# --------------------- 生命周期方法 ---------------------
func _ready() -> void:
	if not root_node:
		push_warning("HitBox未找到关联的CharacterBody2D根节点，可能影响后续逻辑")

# --------------------- 核心伤害逻辑 ---------------------
## 处理伤害数据（应用倍率并发射信号）
## @param damage_data 原始伤害数据（包含伤害值、位置等信息）
func hurt(damage_data: DamageData) -> void:
	# 防御性检查：确保传入正确类型
	if not is_instance_valid(damage_data):
		push_error("传入的damage_data无效")
		return

	# 创建伤害数据副本（避免修改原始对象影响外部逻辑）
	var processed_damage: DamageData = damage_data.duplicate()
	
	# 应用伤害倍率（四舍五入取整，符合游戏数值设计常见需求）
	processed_damage.damage_amount = roundi(processed_damage.damage_amount * damage_multiplier)
	# 设置是否生成额外血液
	processed_damage.spawn_extra_blood = spawn_extra_blood_on_hit

	# 发射伤害信号（由父节点HealthManager等组件监听处理）
	hitbox_hurt.emit(processed_damage)

	# 仅当实际造成有效伤害时触发took_damage信号
	if processed_damage.damage_amount > 0:
		took_damage.emit()

# --------------------- 状态控制方法 ---------------------
## 禁用受击盒（关闭碰撞检测）
func disable_hitbox() -> void:
	collision_layer = HITBOX_LAYER_INACTIVE

## 启用受击盒（开启碰撞检测）
func enable_hitbox() -> void:
	collision_layer = HITBOX_LAYER_ACTIVE

# --------------------- 辅助方法 ---------------------
## 获取当前受击盒关联的根角色节点
func get_root_node() -> CharacterBody2D:
	return root_node
