class_name MuzzleSmoke
extends Node2D

"""
枪口烟雾效果节点
功能：调用start_smoke()启动烟雾粒子→持续指定时间→自动停止发射
设计说明：
- 粒子重父到根节点：避免因父节点旋转导致粒子发射方向异常
- 加入"smoke_particles"组：便于全局管理（如场景切换时统一清理）
依赖节点：
- GPUParticles2D（名称需与场景树一致，用于烟雾粒子）
- SmokeTimer（Timer类型，用于控制发射持续时间）
"""

# 烟雾发射持续时间（秒），需>0
@export var emit_smoke_time: float = 2.0 : set = _set_emit_smoke_time

@onready var gpu_particles: GPUParticles2D = $GPUParticles2D  # 场景内粒子节点
@onready var smoke_timer: Timer = $SmokeTimer  # 场景内计时器节点（非动态创建）


func _ready() -> void:
	# 校验关键节点是否存在（避免路径错误导致崩溃）
	if not gpu_particles or not smoke_timer:
		push_error("关键节点缺失（需包含GPUParticles2D和SmokeTimer），烟雾效果无法工作！")
		queue_free()
		return

	# 初始化粒子状态（封装为独立方法）
	_initialize_particles()

	# 连接计时器超时信号（显式指定连接模式）
	smoke_timer.timeout.connect(_on_smoke_timer_timeout)


func start_smoke() -> void:
	"""启动烟雾粒子发射"""
	if not gpu_particles.is_inside_tree():
		push_warning("粒子节点已离开场景树，无法启动烟雾！")
		return

	# 确保粒子处于根节点（避免父节点旋转影响）
	if gpu_particles.get_parent() != get_tree().get_root():
		gpu_particles.reparent.bind(get_tree().get_root()).call_deferred()

	gpu_particles.emitting = true
	smoke_timer.start()


func _on_smoke_timer_timeout() -> void:
	"""计时器超时时停止粒子发射"""
	gpu_particles.emitting = false


func _initialize_particles() -> void:
	"""初始化粒子基础状态"""
	gpu_particles.emitting = false  # 初始不发射
	gpu_particles.add_to_group("instanced")  # 加入组便于全局管理
	# 预重父到根节点（确保初始状态正确）
	gpu_particles.reparent.bind(get_tree().get_root()).call_deferred()


func _node_exit_tree() -> void:
	"""节点退出树时断开信号连接（显式清理资源）"""
	if smoke_timer.timeout.is_connected(_on_smoke_timer_timeout):
		smoke_timer.timeout.disconnect(_on_smoke_timer_timeout)


func _set_emit_smoke_time(value: float) -> void:
	"""设置发射时间（带参数校验）"""
	emit_smoke_time = max(value, 0.1)  # 最小0.1秒避免无效计时
	if is_inside_tree() and smoke_timer != null:
		smoke_timer.wait_time = emit_smoke_time  # 同步更新计时器等待时间
