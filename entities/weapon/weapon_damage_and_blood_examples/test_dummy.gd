class_name TestDummy
extends CharacterBody2D

"""
测试假人（可受击的目标对象）
功能：
- 监听健康值变化并更新血条显示
- 处理死亡事件（隐藏、禁用碰撞）
- 支持健康数据的保存与加载

依赖节点：
- HealthManager: 健康管理组件（需包含health_updated和died信号）
- ProgressBar（命名为HealthBar）: 血条显示组件
- HitBox（可选）: 受击碰撞体节点（用于接收伤害）
"""

@onready var health_manager: HealthManager = $HealthManager  # 健康管理组件
@onready var health_bar: ProgressBar = $HealthBar            # 血条显示组件
@onready var hit_box: Node2D = $HitBox if has_node("HitBox") else null  # 受击碰撞体（可选）


func _ready() -> void:
	"""节点就绪时初始化信号连接和血条"""
	# 校验核心组件是否存在（避免空引用崩溃）
	if not health_manager:
		push_error("HealthManager节点未找到！健康管理功能将失效。")
		return
	if not health_bar:
		push_error("HealthBar节点未找到！血条显示功能将失效。")
		return

	# 连接健康值变化信号（参数：current_health, max_health）
	health_manager.health_updated.connect(_on_health_updated)
	health_manager.on_health_updated()
	# 连接死亡信号（无参数或自定义参数）
	health_manager.died.connect(_on_die)


func _on_health_updated(current_health: float, max_health: float) -> void:
	"""健康值更新时回调（更新血条显示）"""
	health_bar.max_value = max_health  # 设置血条最大值
	health_bar.value = current_health  # 设置血条当前值


func _on_die() -> void:
	"""死亡事件回调（隐藏假人并禁用碰撞）"""
	hide()  # 隐藏假人
	_set_collision_disabled()  # 禁用碰撞层和掩码


func _set_collision_disabled() -> void:
	"""
	统一设置碰撞层和掩码（自身及HitBox节点）
	@param enabled: 是否启用碰撞（true=启用，false=禁用）
	"""
	
	# 设置自身碰撞层和掩码
	collision_layer = 0
	collision_mask = 0

	# 设置HitBox碰撞层和掩码（若存在）
	if hit_box and hit_box.has_method("disable"):
		hit_box.disable()


func get_save_data() -> Dictionary:
	"""获取需要保存的健康数据（供存档系统调用）"""
	return {
		"health_manager": health_manager.get_save_data()  # 保存HealthManager的状态
	}


func load_save_data(save_data: Dictionary) -> void:
	"""加载存档数据（恢复健康状态）"""
	if health_manager and save_data.has("health_manager"):
		health_manager.load_save_data(save_data.health_manager)  # 恢复HealthManager状态
