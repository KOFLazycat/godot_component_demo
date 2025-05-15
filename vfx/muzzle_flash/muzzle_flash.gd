class_name MuzzleFlash
extends Node2D

"""
枪口闪光效果节点
功能：调用flash()触发闪光→持续指定时间→自动隐藏
使用说明：
1. 场景树需包含FlashSprite（Sprite2D类型，用于显示闪光）
2. 场景树需包含FlashTimer（Timer类型，用于控制闪光持续时间）
3. 可通过编辑器调整flash_time（闪光持续时间）参数
"""

# 闪光持续时间（秒），需≥0.01
@export var flash_time: float = 0.1 : set = _set_flash_time

@onready var flash_timer: Timer = $FlashTimer  # 场景内Timer节点（非动态创建）
@onready var flash_sprite: Sprite2D = $FlashSprite  # 场景内闪光精灵节点


func _ready() -> void:
	# 校验关键节点是否存在（避免路径错误导致崩溃）
	if not flash_timer or not flash_sprite:
		push_error("关键节点缺失（需包含FlashTimer和FlashSprite），闪光效果无法工作！")
		queue_free()
		return

	# 初始隐藏节点
	hide()

	flash_timer.wait_time = flash_time
	# 连接计时器超时信号（显式断开防止泄漏）
	flash_timer.timeout.connect(_on_flash_timer_timeout)


func flash() -> void:
	"""触发枪口闪光效果"""
	# 校验精灵帧配置（避免hframes/vframes为0导致随机帧错误）
	if flash_sprite.hframes <= 0 or flash_sprite.vframes <= 0:
		push_warning("FlashSprite的hframes/vframes不能为0，闪光帧无法随机切换！")
		return

	# 显示节点并随机切换帧（总帧数=hframes*vframes）
	show()
	var total_frames: int = flash_sprite.hframes * flash_sprite.vframes
	flash_sprite.frame = randi_range(0, total_frames - 1)

	# 启动计时器（确保等待时间有效）
	if flash_timer.wait_time <= 0:
		push_warning("flash_time不能小于等于0，已使用默认值0.1秒")
		flash_timer.wait_time = 0.1
	flash_timer.start()


func _on_flash_timer_timeout() -> void:
	"""计时器超时时隐藏节点"""
	hide()


func _node_exit_tree() -> void:
	"""节点退出树时断开信号连接（显式清理资源）"""
	if flash_timer.timeout.is_connected(_on_flash_timer_timeout):
		flash_timer.timeout.disconnect(_on_flash_timer_timeout)


func _set_flash_time(value: float) -> void:
	"""设置闪光时间（带参数校验）"""
	flash_time = max(value, 0.01)  # 最小0.01秒避免无效计时
	if is_inside_tree() and flash_timer != null:
		flash_timer.wait_time = flash_time  # 同步更新计时器等待时间
