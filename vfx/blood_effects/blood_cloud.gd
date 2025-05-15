class_name BloodCloudEffect
extends Node2D

"""
血云特效节点
功能：播放血云粒子特效→持续指定时间→自动销毁
依赖节点：
- DeleteTimer (Timer类型，控制特效持续时间)
- BloodCloudParticles (GPUParticles2D类型，血云粒子)
"""

# 特效持续时间（秒），需≥0.1
@export var effect_duration: float = 3.0 : set = _set_effect_duration

@onready var delete_timer: Timer = $DeleteTimer
@onready var blood_cloud_particles: GPUParticles2D = $BloodCloudParticles


func _ready() -> void:
	# 校验关键节点是否存在（避免路径错误导致崩溃）
	if not delete_timer or not blood_cloud_particles:
		push_error("关键节点缺失（需包含DeleteTimer和BloodCloudParticles），血云特效无法工作！")
		queue_free()
		return

	# 初始化计时器（确保超时时间有效）
	delete_timer.wait_time = max(effect_duration, 0.1)
	
	# 连接计时器超时信号（显式指定单次触发模式）
	delete_timer.timeout.connect(_on_delete_timer_timeout, CONNECT_ONE_SHOT)
	
	# 启动粒子发射
	blood_cloud_particles.emitting = true
	blood_cloud_particles.restart()  # 确保粒子从初始状态开始发射
	
	# 启动计时器
	delete_timer.start()


func _on_delete_timer_timeout() -> void:
	"""计时器超时时停止粒子发射并销毁节点"""
	# 停止粒子发射（避免残留粒子）
	blood_cloud_particles.emitting = false
	
	# 延迟销毁节点（确保所有粒子生命周期结束）
	call_deferred("queue_free")


func _set_effect_duration(value: float) -> void:
	"""设置特效持续时间（带参数校验）"""
	effect_duration = max(value, 0.1)  # 最小0.1秒避免无效计时
	if is_inside_tree() and delete_timer != null:
		delete_timer.wait_time = effect_duration
