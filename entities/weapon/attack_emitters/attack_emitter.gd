class_name AttackEmitter 
extends Node2D

"""
攻击发射基类（继承自Node2D）
功能：
- 管理攻击属性（伤害值、攻击来源）并递归传递给子攻击发射节点
- 提供统一的攻击方法和信号机制
- 支持设置排除的物理体（供子类扩展）

设计模式：组合模式（Composite Pattern）
- 允许通过子节点嵌套实现复杂攻击逻辑（如多级武器发射）
"""
# ------------------------
# 公共属性（带set get封装）
# ------------------------
@export var damage: int : set = _set_damage, get = _get_damage
@export var source_of_attack: Node2D : set = _set_source, get = _get_source

# ------------------------
# 信号（攻击事件通知）
# ------------------------
signal attacked  # 攻击执行后发射，用于通知上层逻辑

# ------------------------
# 私有属性（封装实现细节）
# ------------------------
var _damage: int = 0
var _source_of_attack: Node2D = null

# ------------------------
# 公共方法（供子类调用）
# ------------------------
func set_bodies_to_exclude(bte: Array):
	"""
	设置要排除的物理体（递归应用于所有子攻击发射节点）
	@param bte: 排除的物理体列表（供碰撞检测等逻辑使用）
	"""
	for child in get_children():
		if child is AttackEmitter:
			child.set_bodies_to_exclude(bte)  # 递归调用子节点


func do_attack():
	"""
	执行攻击逻辑（递归触发子节点攻击，完成后发射信号）
	子类可重写此方法扩展具体攻击行为（如生成子弹、播放动画等）
	"""
	_trigger_child_attacks()  # 递归触发子节点攻击
	attacked.emit()  # 通知攻击完成


func _trigger_child_attacks():
	"""私有方法：递归触发所有子AttackEmitter的do_attack方法"""
	for child in get_children():
		if child is AttackEmitter:
			child.do_attack()  # 递归调用子节点的do_attack

# ------------------------
# 属性设置器（带递归传播）
# ------------------------
func _set_damage(value: int) -> void:
	"""设置伤害值并递归传播到所有子攻击发射节点"""
	if _damage == value: return  # 避免无变化时的无效更新
	_damage = value
	_propagate_damage(value)  # 递归更新子节点

func _set_source(value: Node2D) -> void:
	"""设置攻击来源并递归传播到所有子攻击发射节点"""
	if _source_of_attack == value: return
	_source_of_attack = value
	_propagate_source(value)  # 递归更新子节点

# ------------------------
# 递归传播逻辑（私有方法）
# ------------------------
func _propagate_damage(damage_value: int) -> void:
	"""递归设置所有子AttackEmitter的伤害值"""
	for child in get_children():
		if child is AttackEmitter:
			child.damage = damage_value  # 通过公共接口更新，确保封装性


func _propagate_source(source_node: Node2D) -> void:
	"""递归设置所有子AttackEmitter的攻击来源"""
	for child in get_children():
		if child is AttackEmitter:
			child.source_of_attack = source_node  # 通过公共接口更新


# ------------------------
# 属性获取器（可选扩展）
# ------------------------
func _get_damage() -> int:
	"""获取伤害值（可在此添加额外逻辑，如伤害倍率计算）"""
	return _damage

func _get_source() -> Node2D:
	"""获取攻击来源（可在此添加安全校验，如确保来源有效）"""
	return _source_of_attack
