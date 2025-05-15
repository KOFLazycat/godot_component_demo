class_name BulletTracer
extends Node2D

"""
子弹轨迹显示节点
功能：根据起点/终点显示轨迹线，过近则自动销毁
参数说明：
- min_distance_to_show: 轨迹显示最小距离（小于此值不显示）
- min_offset: 起始位置随机偏移最小值（像素）
- max_offset: 起始位置随机偏移最大值（像素）
- base_len: 轨迹精灵基础长度（用于计算缩放）
依赖节点：Sprite2D（名称需与场景树一致）
"""

# 不显示轨迹的最小距离（终点过近时隐藏）
@export var min_distance_to_show: float = 150.0

# 轨迹起点随机偏移范围（增强真实感）
@export var min_offset: float = 50.0
@export var max_offset: float = 150.0

# 轨迹精灵基础长度（用于计算缩放比例）
@export var base_len: float = 130.0


func display_line(start_pos: Vector2, end_pos: Vector2) -> void:
	# 计算起点到终点的实际距离
	var dist: float = start_pos.distance_to(end_pos)
	
	# 距离过近则隐藏并清理资源
	if dist < min_distance_to_show:
		_cleanup()
		return

	# 基础设置：定位到起点并朝向终点
	global_position = start_pos
	look_at(end_pos)  # 确保精灵x轴指向终点

	# 计算随机偏移（包含方向随机）
	var offset_value: float = randf_range(min_offset, max_offset)
	# 沿精灵自身x轴方向偏移（使用local_transform避免父节点影响）
	global_position += global_transform.x * offset_value / 2

	# 计算缩放比例（确保非负避免精灵翻转）
	var effective_length: float = dist - offset_value
	scale.x = max(effective_length / base_len, 0.1)  # 最小缩放0.1避免消失


func _cleanup() -> void:
	"""统一清理资源（延迟销毁避免帧内重复操作）"""
	call_deferred("queue_free")
