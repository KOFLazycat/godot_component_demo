class_name BulletHitEffect
extends Node2D

"""
子弹击中效果节点
功能：播放粒子特效→持续指定时间→自动销毁
依赖节点结构：
- DeleteTimer (Timer类型，用于控制效果持续时间)
- SmokeParticles (GPUParticles2D类型，烟雾粒子)
- SparkParticles (GPUParticles2D类型，火花粒子)
"""

@onready var delete_timer: Timer = $DeleteTimer
@onready var smoke_particles: GPUParticles2D = $SmokeParticles
@onready var spark_particles: GPUParticles2D = $SparkParticles


func _ready() -> void:
	# 校验关键节点是否存在（避免因节点路径错误导致崩溃）
	if not delete_timer or not smoke_particles or not spark_particles:
		push_error("关键节点缺失，请检查场景树结构！")
		queue_free()
		return

	# 连接计时器超时信号（显式指定连接模式）
	delete_timer.timeout.connect(_on_delete_timer_timeout, CONNECT_ONE_SHOT | CONNECT_DEFERRED)
	
	# 启动粒子效果（封装为独立方法提升可读性）
	_start_particle_effects()


func _start_particle_effects() -> void:
	"""启动所有粒子效果（重置并播放）"""
	smoke_particles.emitting = true
	smoke_particles.restart()  # 确保从初始状态开始播放
	
	spark_particles.emitting = true
	spark_particles.restart()
	
	# 启动计时器（明确控制启动时机，避免依赖编辑器的autostart属性）
	delete_timer.start()


func _on_delete_timer_timeout() -> void:
	"""计时器超时时触发销毁"""
	queue_free()


func _node_exit_tree() -> void:
	"""节点退出树时断开所有信号连接（显式清理资源）"""
	if delete_timer.timeout.is_connected(_on_delete_timer_timeout):
		delete_timer.timeout.disconnect(_on_delete_timer_timeout)
