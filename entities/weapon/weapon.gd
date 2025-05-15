class_name Weapon 
extends Node

"""
武器基类（所有具体武器需继承此类）
功能：
- 管理攻击发射器（AttackEmitter）的核心属性（伤害、攻击来源、排除物体）
- 提供统一的攻击触发接口，并发射攻击完成信号

依赖说明：
- 场景中需包含名为 `AttackEmitter` 的子节点（类型为 AttackEmitter）
- 子类可重写 `attack` 方法扩展攻击逻辑（如添加动画、音效）
"""

@onready var attack_emitter: AttackEmitter = $AttackEmitter  # 关联场景中的攻击发射器节点

@export var damage: int = 1 : set = _set_damage  # 基础伤害值（≥0）
signal attacked  # 攻击完成时发射（用于通知动画、音效等）


func _ready():
	"""节点就绪时校验攻击发射器是否有效"""
	if not attack_emitter:
		push_error("武器节点未找到AttackEmitter子节点！请检查场景结构。")
	else:
		attack_emitter.damage = damage  # 初始化攻击发射器的伤害值


func _set_damage(value: int) -> void:
	"""设置伤害值（限制≥0，并同步到攻击发射器）"""
	damage = max(value, 0)  # 确保伤害值非负
	if attack_emitter:
		attack_emitter.damage = damage  # 同步更新攻击发射器的伤害


func set_attack_source(held_by: Node2D):
	"""
	设置攻击来源（通常为武器持有者，如角色节点）
	@param held_by: 攻击来源节点（用于伤害计算、击退方向等）
	"""
	if attack_emitter:
		attack_emitter.source_of_attack = held_by


func set_bodies_to_exclude(bte: Array):
	"""
	设置攻击时需排除的物理体（如持有者自身，避免误伤）
	@param bte: 要排除的物理体列表（类型为PhysicsBody2D/Area2D）
	"""
	if attack_emitter:
		attack_emitter.set_bodies_to_exclude(bte)


func attack():
	"""执行攻击逻辑（触发攻击发射器并发射信号）"""
	if not attack_emitter:
		push_warning("攻击发射器未初始化，无法执行攻击！")
		return

	attack_emitter.do_attack()  # 触发攻击发射器的攻击逻辑
	attacked.emit()  # 通知攻击完成（可用于播放音效、动画等）
