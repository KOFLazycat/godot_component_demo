class_name ArcEmitter
extends AttackEmitter

"""
弧形攻击发射节点（继承自AttackEmitter）
功能：在指定弧度范围内分散发射多次攻击，每个攻击按角度均匀分布。
属性说明：
- arc: 攻击分布的总弧度（度数，0~360）
- shots_to_fire: 发射次数（≥1，1次时为单一方向攻击）
"""

@export var arc: float = 30.0 : set = _set_arc  # 总弧度（度数）
@export var shots_to_fire: int = 5 : set = _set_shots_to_fire  # 发射次数


func _ready():
	# 初始化时校验参数（可选，根据需求决定校验时机）
	_set_arc(arc)
	_set_shots_to_fire(shots_to_fire)


func do_attack():
	"""执行弧形攻击发射逻辑"""
	var effective_shots: int = max(shots_to_fire, 1)  # 确保至少发射1次

	if effective_shots == 1:
		# 单一方向攻击，显式设置角度为0（与默认旋转一致，增强可读性）
		rotation_degrees = 0.0
		super()  # 触发父类攻击逻辑
		return

	# 计算每个攻击的角度偏移（从弧度左侧到右侧均匀分布）
	var angle_increment: float = arc / (effective_shots - 1)  # 相邻攻击的角度间隔
	for i in range(effective_shots):
		var current_angle: float = -arc / 2.0 + i * angle_increment  # 从左侧到右侧计算角度
		rotation_degrees = current_angle  # 设置当前节点旋转（影响攻击方向）
		super()  # 触发父类攻击逻辑（基于当前旋转发射）


# ------------------------
# 参数设置器（带校验逻辑）
# ------------------------
func _set_arc(value: float) -> void:
	"""设置总弧度（限制在0~360度）"""
	arc = clamp(value, 0.0, 360.0)

func _set_shots_to_fire(value: int) -> void:
	"""设置发射次数（限制≥1）"""
	shots_to_fire = max(value, 1)
