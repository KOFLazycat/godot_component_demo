# ==============================================
# 类名: AttackEmitter
# 继承: Node2D
# 功能: 用于武器攻击的基础发射器，支持递归管理子发射器
# 说明: 可挂载到武器节点下，统一管理伤害值、攻击来源和攻击行为
# ==============================================
class_name AttackEmitter extends Node2D

# 攻击成功时的信号（参数可根据需求扩展）
signal attacked

# ------------------------------
# 私有成员（存储实际值，避免setter递归）
# ------------------------------
var _damage: int = 0                  # 攻击伤害值（基础存储变量）
var _source_of_attack: Node2D = null  # 攻击来源节点（基础存储变量）

# ------------------------------
# 公有属性（带setter，自动同步子发射器）
# ------------------------------
@export var damage: int:
	get: return _damage
	set(value):
		# 避免重复赋值触发递归
		if _damage == value:
			return
		_damage = value
		# 同步所有子发射器的伤害值
		_foreach_child_emitter(func(child): child.damage = value)

@export var source_of_attack: Node2D:
	get: return _source_of_attack
	set(value):
		# 避免重复赋值触发递归
		if _source_of_attack == value:
			return
		_source_of_attack = value
		# 同步所有子发射器的攻击来源
		_foreach_child_emitter(func(child): child.source_of_attack = value)

# ------------------------------
# 公有方法
# ------------------------------
# 设置需要排除的碰撞体（如武器持有者自身）
# @param bodies_to_exclude: 要排除的PhysicsBody2D数组（避免误伤害）
func set_bodies_to_exclude(bodies_to_exclude: Array[PhysicsBody2D]):
	_foreach_child_emitter(func(child): child.set_bodies_to_exclude(bodies_to_exclude))

# 执行攻击逻辑（触发子发射器并发射信号）
func do_attack():
	_foreach_child_emitter(func(child): child.do_attack())
	attacked.emit()  # 所有子发射器执行完毕后发射信号

# ------------------------------
# 私有工具方法（提取公共逻辑）
# ------------------------------
# 遍历所有子节点中的AttackEmitter并执行回调
# @param callback: 回调函数（参数为子发射器实例）
func _foreach_child_emitter(callback: Callable):
	for child in get_children():
		if child is AttackEmitter:
			callback.call(child)
