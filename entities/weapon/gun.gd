class_name Gun 
extends Weapon

"""
枪械基类（所有具体枪械需继承此类）
功能：
- 管理枪口特效（闪光、烟雾）
- 触发攻击时播放特效并调用父类攻击逻辑（发射子弹等）

依赖说明：
- 场景中需包含以下子节点：
  - MuzzleFlash: 枪口闪光特效节点（需包含flash()方法）
  - MuzzleSmoke: 枪口烟雾特效节点（需包含start_smoke()方法）
"""

@onready var muzzle_smoke: Node = $MuzzleSmoke  # 枪口烟雾特效节点
@onready var muzzle_flash: Node = $MuzzleFlash  # 枪口闪光特效节点


func _ready():
	"""节点就绪时校验特效节点是否有效"""
	_validate_effect_nodes()
	super()


func _validate_effect_nodes():
	"""校验特效节点是否存在并输出警告（辅助调试）"""
	if not muzzle_flash:
		push_warning("未找到MuzzleFlash节点！枪口闪光特效将无法播放。")
	if not muzzle_smoke:
		push_warning("未找到MuzzleSmoke节点！枪口烟雾特效将无法播放。")


func attack():
	"""执行枪械攻击逻辑（覆盖父类方法）"""
	_play_muzzle_effects()  # 播放枪口特效
	super()  # 调用父类攻击逻辑（触发AttackEmitter发射子弹等）


func _play_muzzle_effects():
	"""播放枪口闪光和烟雾特效（带空值校验）"""
	if muzzle_flash and muzzle_flash.has_method("flash"):
		muzzle_flash.flash()  # 播放闪光特效（如播放动画/粒子）
	
	if muzzle_smoke and muzzle_smoke.has_method("start_smoke"):
		muzzle_smoke.start_smoke()  # 播放烟雾特效（如启动粒子系统）
