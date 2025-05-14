# ==============================================
# 类名: Weapon
# 继承: Node
# 功能: 武器基类，所有具体武器（如剑、弓）应继承此类
# 说明: 负责管理攻击发射器（AttackEmitter）的核心参数（伤害、来源、排除碰撞体）
# ==============================================
class_name Weapon extends Node

# ------------------------------
# 公有信号（攻击触发时发射）
# ------------------------------
signal attacked  # 原功能保持不变

# ------------------------------
# 私有成员（存储核心参数）
# ------------------------------
var _attack_emitter: AttackEmitter = null  # 攻击发射器实例（避免直接暴露）
var _damage: int = 1  # 私有存储变量（解决原代码中_damage未定义问题）

# ------------------------------
# 公有属性（可通过编辑器配置）
# ------------------------------
@export var damage: int = 1:
	get: return _damage  # 获取当前伤害值（通过私有变量）
	set(value):
		# 避免无效赋值（如设置相同值）
		if _damage == value:
			return
		_damage = value  # 更新私有存储变量
		# 同步到攻击发射器（若已初始化）
		if _attack_emitter != null:
			_attack_emitter.damage = value  # 同步伤害值到发射器

# ------------------------------
# 生命周期方法
# ------------------------------
func _ready():
	# 安全获取攻击发射器节点（避免场景结构错误导致崩溃）
	_attack_emitter = get_node_or_null("AttackEmitter") as AttackEmitter
	if _attack_emitter == null:
		push_error("Weapon节点下未找到AttackEmitter子节点，攻击功能将失效！")
		return
	
	# 初始化攻击发射器参数（使用damage属性的当前值）
	_attack_emitter.damage = damage  # 等价于_attack_emitter.damage = _damage
	# 其他初始化逻辑可扩展...

# ------------------------------
# 公有方法（武器操作接口）
# ------------------------------
# 设置武器持有者（攻击来源）
# @param holder: 持有武器的节点（如角色主体Node2D）
func set_weapon_held_by(holder: Node2D):
	if _attack_emitter == null:
		push_warning("AttackEmitter未初始化，无法设置攻击来源")
		return
	_attack_emitter.source_of_attack = holder  # 同步到发射器

# 设置需要排除的碰撞体（避免误伤害）
# @param bodies_to_exclude: 要排除的PhysicsBody2D数组（如持有者自身、友方）
func set_bodies_to_exclude(bodies_to_exclude: Array[PhysicsBody2D]):
	if _attack_emitter == null:
		push_warning("AttackEmitter未初始化，无法设置排除碰撞体")
		return
	_attack_emitter.set_bodies_to_exclude(bodies_to_exclude)  # 同步到发射器

# 执行攻击操作（触发攻击逻辑）
func attack():
	if _attack_emitter == null:
		push_warning("AttackEmitter未初始化，无法执行攻击")
		return
	
	_attack_emitter.do_attack()  # 触发发射器的攻击逻辑
	attacked.emit()  # 发射攻击完成信号（与原功能一致）
