class_name SprayEmitter
extends AttackEmitter

"""
散布攻击发射节点（继承自AttackEmitter）
功能：为攻击方向添加随机角度偏移，实现子弹/攻击的散布效果（如枪械的弹道散布）
属性说明：
- max_random_angle: 最大随机偏移角度（度数，≥0），实际偏移范围为 [-max_random_angle, max_random_angle]
"""

@export var max_random_angle: float = 3.0 : set = _set_max_random_angle  # 最大随机角度（度数）


func _set_max_random_angle(value: float) -> void:
	"""设置最大随机角度（限制≥0）"""
	max_random_angle = max(value, 0.0)  # 确保角度非负


func do_attack():
	"""执行散布攻击逻辑（覆盖父类方法）"""
	# 生成随机角度偏移（范围：-max_random_angle 到 max_random_angle）
	var random_angle: float = randf_range(-max_random_angle, max_random_angle)
	rotation_degrees = random_angle  # 设置当前节点旋转（影响攻击方向）
	
	super()  # 调用父类攻击逻辑（如发射子弹、递归子节点）
