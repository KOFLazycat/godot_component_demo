class_name HealthManager extends Node2D

"""
健康管理核心节点（继承自Node2D）
功能：
- 管理当前健康值（cur_health）与最大健康值（max_health）
- 处理伤害（hurt）、治疗（heal）、生命再生（health_regen）
- 发射健康状态变化信号（健康值/百分比/死亡/受伤/治疗）
- 支持数据持久化（保存/加载健康状态）

使用说明：
1. 场景树需包含BloodSpawner节点（用于生成血液特效）
2. 可选添加DeathSounds/HurtSounds节点（AudioPlayer类型，用于播放音效）
3. 再生速率>0时启用自动再生（health_regen_rate）
"""

# 最大健康值（初始当前健康值等于最大值）
@export var max_health: int = 100 : set = _set_max_health
# 当前健康值（通过set_cur_health修改，确保在0~max_health之间）
var cur_health: int : set = _set_cur_health
# 生命再生速率（每秒恢复健康值，≤0时禁用再生）
@export var health_regen_rate: float = -1.0 : set = _set_health_regen_rate
# 浮点再生累积值（用于精确计算再生量）
var _fractional_health_regened: float = 0.0
# 数据持久化标志（仅保存当前健康值，忽略max_health和regen_rate）
@export var only_save_cur_health: bool = true 

# 信号声明（带参数说明）
signal health_updated(cur_health: int, max_health: int)  # 健康值变化时触发（绝对值）
signal health_updated_percentage(health_full_percentage: float)  # 健康值变化时触发（百分比）
signal died  # 健康值≤0时触发
signal healed  # 主动治疗（非再生）时触发
signal healed_from_regen  # 再生治疗时触发
signal took_damage  # 受到有效伤害时触发

# 依赖节点（通过@onready+校验确保存在性）
@onready var blood_spawner: Node2D = $BloodSpawner
@onready var death_sounds: PlayRandomSound = $DeathSounds if has_node("DeathSounds") else null
@onready var hurt_sounds: PlayRandomSound = $HurtSounds if has_node("HurtSounds") else null


func _ready() -> void:
	# 初始化当前健康值（确保不超过最大值）
	cur_health = max_health
	# 初始化再生处理（根据再生速率启用/禁用_process）
	_set_health_regen_rate(health_regen_rate)


func set_health_regen_rate(regen_rate: float) -> void:
	"""设置生命再生速率（公开方法，兼容旧逻辑）"""
	_set_health_regen_rate(regen_rate)


func _set_health_regen_rate(regen_rate: float) -> void:
	"""私有设置器（带参数校验和逻辑处理）"""
	health_regen_rate = regen_rate
	# 仅当再生速率>0时启用_process
	set_process(health_regen_rate > 0)


func set_cur_health(h: int) -> void:
	"""公开方法：设置当前健康值（带边界校验）"""
	_set_cur_health(h)


func _set_cur_health(h: int) -> void:
	"""私有设置器：确保当前健康值在0~max_health之间"""
	var clamped_health: int = clamp(h, 0, max_health)
	if cur_health == clamped_health:
		return  # 健康值未变化时不触发更新
	cur_health = clamped_health
	on_health_updated()


func set_max_health(h: int) -> void:
	"""公开方法：设置最大健康值（带边界校验）"""
	_set_max_health(h)


func _set_max_health(h: int) -> void:
	"""私有设置器：确保最大健康值≥1"""
	var clamped_max: int = max(h, 1)  # 最大健康值至少为1
	if max_health == clamped_max:
		return  # 最大值未变化时不触发更新
	max_health = clamped_max
	# 当前健康值可能超过新的最大值，需同步调整
	_set_cur_health(cur_health)  # 触发健康值重新校验
	on_health_updated()


func hurt(damage_data: DamageData) -> void:
	"""
	处理伤害逻辑（关键入口方法）
	@param damage_data: 包含伤害值、血液特效标志、音效标志的伤害数据对象
	"""
	if is_dead():
		return  # 已死亡时忽略伤害

	# 校验伤害数据有效性
	if not is_instance_valid(damage_data) or damage_data.damage_amount <= 0:
		return  # 无效伤害或零伤害不处理

	# 生成血液特效（校验blood_spawner存在性）
	if blood_spawner is BloodSpawner:  # 显式校验节点类型
		blood_spawner.spawn_blood_from_damage_data(damage_data)

	# 发射受伤信号
	took_damage.emit()

	# 扣除健康值（通过设置器自动校验边界）
	_set_cur_health(cur_health - damage_data.damage_amount)

	# 处理死亡逻辑
	if is_dead():
		_play_death_sound(damage_data.play_sound)
		died.emit()
	else:
		_play_hurt_sound(damage_data.play_sound)


func heal(amount: int, from_regen: bool = false) -> void:
	"""
	处理治疗逻辑（支持主动治疗和再生治疗）
	@param amount: 治疗量（需>0）
	@param from_regen: 是否来自再生系统
	"""
	if amount <= 0:
		return  # 无效治疗量不处理

	# 增加健康值（通过设置器自动校验边界）
	_set_cur_health(cur_health + amount)

	# 发射治疗信号（仅健康值实际变化时触发）
	if from_regen:
		healed_from_regen.emit()
	else:
		healed.emit()


func on_health_updated() -> void:
	"""健康值变化时的统一信号发射逻辑"""
	health_updated.emit(cur_health, max_health)
	var percentage: float = clamp(float(cur_health) / max_health, 0.0, 1.0)
	health_updated_percentage.emit(percentage)


func is_dead() -> bool:
	"""判断是否死亡（健康值≤0）"""
	return cur_health <= 0


func _process(delta: float) -> void:
	"""处理生命再生（仅当health_regen_rate>0时执行）"""
	if health_regen_rate <= 0:
		return

	# 累积再生量（使用浮点计算提升精度）
	_fractional_health_regened += health_regen_rate * delta
	var health_to_heal: int = int(_fractional_health_regened)
	_fractional_health_regened -= health_to_heal  # 保留小数部分避免精度丢失

	if health_to_heal > 0:
		heal(health_to_heal, true)  # 调用heal方法触发再生治疗


func get_save_data() -> Dictionary:
	"""获取需要保存的健康数据（支持仅保存当前健康值）"""
	var save_data: Dictionary = {}
	save_data.cur_health = cur_health
	if not only_save_cur_health:
		save_data.max_health = max_health
		save_data.health_regen_rate = health_regen_rate  # 保存原始浮点值
	return save_data


func load_save_data(save_data: Dictionary) -> void:
	"""从保存数据恢复健康状态（兼容旧数据格式）"""
	if "cur_health" in save_data:
		set_cur_health(save_data.cur_health)  # 自动转换为int并校验边界
	if not only_save_cur_health:
		if "max_health" in save_data:
			set_max_health(save_data.max_health)
		if "health_regen_rate" in save_data:
			set_health_regen_rate(save_data.health_regen_rate)  # 直接使用原始浮点值
	# 死亡状态同步（确保信号正确发射）
	if is_dead():
		died.emit()


func _play_death_sound(should_play: bool) -> void:
	"""播放死亡音效（校验节点类型和播放标志）"""
	if should_play and death_sounds is PlayRandomSound:
		death_sounds.play()


func _play_hurt_sound(should_play: bool) -> void:
	"""播放受伤音效（校验节点类型和播放标志）"""
	if should_play and hurt_sounds is PlayRandomSound:
		hurt_sounds.play()
