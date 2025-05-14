# 角色核心控制类：处理健康状态同步、死亡逻辑、存档读档
class_name TestDummy
extends CharacterBody2D

# --------------------- 节点与组件 ---------------------
@onready var health_manager: HealthManager = $HealthManager  # 健康管理组件
@onready var health_bar: ProgressBar = $HealthBar            # 血条显示组件
@onready var hitbox: HitBox = $HitBox                        # 受击盒组件（新增明确引用）

# --------------------- 生命周期方法 ---------------------
func _ready() -> void:
	# 安全校验：确保核心组件存在
	if not health_manager:
		push_error("HealthManager节点未找到，角色健康逻辑将失效")
		return
	if not health_bar:
		push_warning("HealthBar节点未找到，血条显示将失效")
	if not hitbox:
		push_warning("HitBox节点未找到，受击逻辑可能异常")

	# 连接健康更新信号（使用Godot 4新语法，自动处理重复连接）
	health_manager.health_updated.connect(_on_health_updated)
	# 连接死亡信号
	health_manager.died.connect(_on_die)
	# 初始化血条（通过触发健康更新信号驱动，而非直接调用内部方法）
	health_manager.on_health_updated()  # 注意：此方法应为HealthManager的公开触发方法，若为私有需调整

# --------------------- 健康状态同步 ---------------------
## 健康状态更新时同步血条显示
## @param cur_health 当前生命值（int类型）
## @param max_health 最大生命值（int类型）
func _on_health_updated(cur_health: int, max_health: int) -> void:
	# 仅当血条存在时更新（防御空引用）
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = cur_health

# --------------------- 死亡逻辑处理 ---------------------
## 角色死亡时的状态处理（隐藏、禁用碰撞）
func _on_die() -> void:
	_disable_collision()  # 禁用碰撞层/掩码
	_hide_character()     # 隐藏角色

## 禁用角色所有碰撞（自身+受击盒）
func _disable_collision() -> void:
	collision_layer = 0
	collision_mask = 0
	if hitbox:  # 安全调用子节点方法
		hitbox.disable_hitbox()  # 假设HitBox有disable_hitbox方法（见前例优化）

## 隐藏角色及其子节点（可选扩展）
func _hide_character() -> void:
	hide()
	# 可扩展：隐藏子节点（如武器、特效）
	# for child in get_children():
	#     child.hide()

# --------------------- 存档与读档 ---------------------
## 生成角色存档数据（包含健康状态）
func get_save_data() -> Dictionary:
	return {
		"health_manager": health_manager.get_save_data()  # 嵌套健康组件数据
	}

## 从存档恢复角色状态
func load_save_data(save_data: Dictionary) -> void:
	# 安全校验：确保存档数据有效
	if not is_instance_valid(save_data):
		push_error("无效的存档数据")
		return
	
	# 加载健康管理数据（使用字典安全访问）
	if "health_manager" in save_data:
		health_manager.load_save_data(save_data.health_manager)

# --------------------- 可选扩展方法 ---------------------
## 复活角色（重置死亡状态）
func revive() -> void:
	show()
	collision_layer = 2  # 恢复默认碰撞层（根据项目配置调整）
	collision_mask = 0
	if hitbox:
		hitbox.enable_hitbox()  # 恢复受击盒
