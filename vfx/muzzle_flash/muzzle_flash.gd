# ==============================================
# 类名: MuzzleFlash
# 继承: Node2D
# 功能: 枪械枪口火焰效果组件，调用flash()触发闪烁
# 说明: 依赖场景中的FlashSprite（显示火焰）和FlashTimer（控制持续时间）
# ==============================================
class_name MuzzleFlash 
extends Node2D

# ------------------------------
# 公有参数（可通过编辑器配置）
# ------------------------------
@export var flash_duration: float = 0.1  # 火焰显示持续时间（秒）

# ------------------------------
# 节点引用
# ------------------------------
@onready var flash_timer: Timer = $FlashTimer  # 场景中预定义的计时器节点
@onready var flash_sprite: Sprite2D = $FlashSprite  # 场景中预定义的火焰精灵节点

# ------------------------------
# 生命周期方法
# ------------------------------
func _ready():
	# 初始化时隐藏火焰（避免默认显示）
	hide()
	
	# 验证节点是否存在（避免崩溃）
	if not flash_timer:
		push_error("未找到FlashTimer节点，枪口火焰计时功能将失效！")
	if not flash_sprite:
		push_error("未找到FlashSprite节点，枪口火焰显示功能将失效！")
		return  # 无精灵节点时直接退出初始化
	
	add_child(flash_timer)
	# 配置计时器（使用导出参数设置等待时间）
	flash_timer.wait_time = flash_duration
	# 连接计时器超时信号到隐藏火焰的方法
	flash_timer.timeout.connect(_on_flash_timer_timeout)

# ------------------------------
# 公有方法（触发火焰闪烁）
# ------------------------------
func flash():
	# 若关键节点缺失，提前返回
	if not flash_sprite or not flash_timer:
		return
	
	# 显示火焰并随机选择一帧（适配Godot4 Sprite2D的帧逻辑）
	show()
	_randomize_sprite_frame()
	# 启动计时器，倒计时后隐藏火焰
	flash_timer.start()

# ------------------------------
# 私有辅助方法（随机选择精灵帧）
# ------------------------------
func _randomize_sprite_frame():
	# 若精灵节点或帧资源缺失，跳过随机逻辑
	if not flash_sprite or not flash_sprite.frames:
		return
	
	# 获取当前动画的总帧数（适配Sprite2D的SpriteFrames资源）
	var total_frames: int = flash_sprite.frames.get_frame_count(flash_sprite.animation)
	if total_frames <= 0:
		push_warning("FlashSprite的SpriteFrames无有效帧，无法随机选择！")
		return
	
	# 随机选择一帧（0到总帧数-1）
	flash_sprite.frame = randi_range(0, total_frames - 1)

# ------------------------------
# 信号回调（计时器超时，隐藏火焰）
# ------------------------------
func _on_flash_timer_timeout():
	hide()
