# ==============================================
# 类名: MuzzleSmoke
# 继承: Node2D
# 功能: 烟雾粒子发射器，通过start_smoke触发定时烟雾效果
# 说明: 解决父节点旋转导致的粒子位置异常问题，支持编辑器参数配置
# ==============================================
class_name MuzzleSmoke
extends Node2D

# ------------------------------
# 公有参数（可通过编辑器配置）
# ------------------------------
@export var smoke_duration: float = 2.0:
	get: return _smoke_duration
	set(value):
		_smoke_duration = value
		# 动态同步计时器等待时间（运行时修改参数时生效）
		if emit_timer != null:
			emit_timer.wait_time = value

# ------------------------------
# 私有节点引用（通过场景树获取）
# ------------------------------
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D  # 场景中预定义的粒子节点
@onready var emit_timer: Timer = $EmitTimer  # 场景中预定义的计时器节点（替代动态创建）

# ------------------------------
# 私有存储变量
# ------------------------------
var _smoke_duration: float = 2.0  # 存储烟雾持续时间（用于参数同步）

# ------------------------------
# 生命周期方法
# ------------------------------
func _ready():
	# 验证关键节点是否存在（避免崩溃）
	if not gpu_particles_2d:
		push_error("未找到GPUParticles2D节点，烟雾粒子功能将失效！")
	if not emit_timer:
		push_error("未找到EmitTimer节点，烟雾计时功能将失效！")
		return

	# 初始化粒子状态（默认不发射）
	gpu_particles_2d.emitting = false

	# 配置计时器（使用导出参数设置等待时间）
	emit_timer.wait_time = smoke_duration
	# 连接计时器超时信号到停止发射方法
	emit_timer.timeout.connect(_on_emit_timer_timeout)

	# 粒子重定向到根节点（避免父节点旋转影响粒子位置）
	# 原理：将粒子设为根节点的子节点，使其位置基于全局坐标而非父节点局部坐标
	gpu_particles_2d.reparent(get_tree().get_root())
	# 添加到"instanced"组（用于后续可能的批量管理/清理）
	gpu_particles_2d.add_to_group("instanced")

# ------------------------------
# 公有方法（触发烟雾发射）
# ------------------------------
func start_smoke():
	# 若关键节点缺失，提前返回
	if not gpu_particles_2d or not emit_timer:
		return

	# 启动粒子发射并开始计时
	gpu_particles_2d.emitting = true
	emit_timer.start()

# ------------------------------
# 信号回调（计时器超时，停止发射）
# ------------------------------
func _on_emit_timer_timeout():
	gpu_particles_2d.emitting = false
