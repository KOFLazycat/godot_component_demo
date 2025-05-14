# 健康管理模块：负责处理角色/敌人的生命值、受伤、治疗、再生及存档逻辑
class_name HealthManager extends Node2D

# --------------------- 节点与配置 ---------------------
@onready var blood_spawner: BloodSpawner = $BloodSpawner  # 血液生成器（需在场景中绑定）
var death_sounds: AudioStreamPlayer  # 死亡音效节点缓存
var hurt_sounds: AudioStreamPlayer    # 受伤音效节点缓存

# --------------------- 可配置属性 ---------------------
@export_range(1, 1000, 1) var max_health: int = 100  # 最大生命值（编辑器限制范围）
@onready var cur_health: int = max_health  # 当前生命值（初始化时同步最大值）

@export_range(-10, 10, 0.1) var health_regen_rate: float = -1.0  # 生命再生速率（负数为无再生）
var fractional_health_regened: float = 0.0  # 再生小数累积量（解决浮点精度问题）

@export var only_save_cur_health: bool = true  # 存档时是否仅保存当前生命值（优化存档体积）

# --------------------- 信号定义 ---------------------
signal health_updated(cur_health: int, max_health: int)  # 生命值数值更新信号
signal health_updated_percentage(health_full_percentage: float)  # 生命值百分比更新信号
signal died  # 死亡信号
signal healed  # 主动治疗信号（道具/技能）
signal healed_from_regen  # 再生治疗信号（自然恢复）
signal took_damage  # 受伤信号

# --------------------- 初始化与准备 ---------------------
func _ready() -> void:
	# 预缓存音效节点（避免频繁调用get_node）
	death_sounds = get_node_or_null("DeathSounds")
	hurt_sounds = get_node_or_null("HurtSounds")
	
	# 校验血液生成器是否存在（避免运行时崩溃）
	if not blood_spawner:
		push_warning("BloodSpawner节点未绑定，血液生成功能将失效")
	
	# 初始化再生逻辑
	set_health_regen_rate(health_regen_rate)

# --------------------- 核心控制方法 ---------------------
## 设置生命再生速率（自动控制是否启用每帧更新）
func set_health_regen_rate(regen_rate: float) -> void:
	health_regen_rate = regen_rate
	# 仅当再生速率>0时启用_process（性能优化）
	set_process(health_regen_rate > 0)

## 设置当前生命值（带边界校验）
func set_cur_health(h: int) -> void:
	# 限制当前生命值在[0, max_health]范围内
	cur_health = clamp(h, 0, max_health)
	on_health_updated()

## 设置最大生命值（自动修正当前生命值）
func set_max_health(h: int) -> void:
	# 最大生命值至少为1（避免除零错误）
	max_health = max(h, 1)
	# 当前生命值超过新上限时自动修正
	if cur_health > max_health:
		cur_health = max_health
	on_health_updated()

# --------------------- 伤害与治疗逻辑 ---------------------
## 处理受伤逻辑（核心方法）
func hurt(damage_data: DamageData) -> void:
	if is_dead():
		return  # 已死亡则忽略伤害
	
	# 确保伤害量非负（防御错误输入）
	var damage_amount: int = max(damage_data.damage_amount, 0)
	if damage_amount > 0:
		# 安全调用血液生成（避免空引用崩溃）
		blood_spawner.spawn_blood_from_damage_data(damage_data)
	
	# 触发受伤信号
	took_damage.emit()
	
	# 通过set_cur_health修改生命值（确保边界校验）
	set_cur_health(cur_health - damage_amount)
	
	# 处理死亡逻辑
	if is_dead():
		died.emit()
		# 安全播放死亡音效（已缓存节点）
		if death_sounds and damage_data.play_sound:
			death_sounds.play()
	else:
		# 安全播放受伤音效（已缓存节点）
		if hurt_sounds and damage_data.play_sound:
			hurt_sounds.play()

## 处理治疗逻辑（支持主动治疗和再生治疗）
func heal(amount: int, from_regen: bool = false) -> void:
	# 确保治疗量非负（防御错误输入）
	var heal_amount: int = max(amount, 0)
	# 通过set_cur_health修改生命值（确保边界校验）
	set_cur_health(cur_health + heal_amount)
	
	# 触发对应治疗信号（区分来源）
	if from_regen:
		healed_from_regen.emit()
	else:
		healed.emit()

# --------------------- 状态更新与再生 ---------------------
## 生命值更新时统一触发信号（保证信号一致性）
func on_health_updated() -> void:
	health_updated.emit(cur_health, max_health)
	# 计算百分比（避免除零错误）
	var percentage: float = cur_health / float(max(max_health, 1))
	health_updated_percentage.emit(clamp(percentage, 0.0, 1.0))

## 判断是否死亡
func is_dead() -> bool:
	return cur_health <= 0

## 每帧处理生命再生（仅当再生速率>0时执行）
func _process(delta: float) -> void:
	process_health_regen(delta)

## 处理再生逻辑（累积小数部分避免浮点误差）
func process_health_regen(delta: float) -> void:
	if health_regen_rate <= 0:
		return  # 无再生时跳过
	
	fractional_health_regened += health_regen_rate * delta
	var health_int: int = int(fractional_health_regened)
	fractional_health_regened -= health_int  # 保留剩余小数部分
	
	if health_int > 0:
		heal(health_int, true)  # 触发再生治疗

# --------------------- 存档与读档 ---------------------
## 生成存档数据（优化存档体积）
func get_save_data() -> Dictionary:
	var save_data: Dictionary = {}
	save_data.cur_health = cur_health
	if not only_save_cur_health:
		save_data.max_health = max_health
		save_data.health_regen_rate = health_regen_rate
	return save_data

## 加载存档数据（安全恢复状态）
func load_save_data(save_data: Dictionary) -> void:
	# 逐个字段安全加载（避免KeyError）
	if "cur_health" in save_data:
		set_cur_health(roundi(save_data.cur_health))
	if "max_health" in save_data:
		set_max_health(roundi(save_data.max_health))
	if "health_regen_rate" in save_data:
		set_health_regen_rate(save_data.health_regen_rate)  # 保留浮点精度
	
	# 加载后若已死亡，补发生命信号
	if is_dead():
		died.emit()
