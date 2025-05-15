class_name RaycastBulletEmitter
extends AttackEmitter

"""
射线检测子弹发射节点（继承自AttackEmitter）
功能：
- 通过射线检测模拟子弹飞行路径
- 对碰撞到的HitBox造成伤害
- 生成子弹轨迹和击中特效（墙面/障碍物）

依赖资源：
- BULLET_HIT_EFFECT: 子弹击中墙面/障碍物的特效场景
- BULLET_TRACER: 子弹轨迹特效场景
"""

@onready var ray_cast: RayCast2D = $RayCast2D  # 关联场景中的RayCast2D节点

# 预加载特效资源
const BULLET_HIT_EFFECT: PackedScene = preload("res://vfx/bullet_hit_effect/bullet_hit_effect.tscn")
const BULLET_TRACER: PackedScene = preload("res://vfx/bullet_tracer/bullet_tracer.tscn")


func _ready():
	# 校验射线节点是否成功关联（避免@onready失败导致的空引用）
	if not ray_cast:
		push_error("RayCast2D节点未找到！请检查场景结构。")


func set_bodies_to_exclude(bte: Array):
	"""
	设置射线检测时需排除的物理体（覆盖父类方法）
	@param bte: 要排除的物理体列表（如发射者自身）
	"""
	super(bte)  # 调用父类方法递归传递排除列表
	for body in bte:
		ray_cast.add_exception(body)  # 将物体添加到射线的排除列表


func do_attack():
	"""执行子弹发射逻辑（覆盖父类方法）"""
	super()  # 调用父类攻击逻辑（如递归子节点、发射信号）

	# 强制更新射线检测（会自动启用射线并立即检测）
	ray_cast.enabled = true
	ray_cast.force_raycast_update()
	# 获取射线终点（碰撞点或原始目标点）
	var end_pos: Vector2 = _get_ray_end_position()
	_handle_collision(end_pos)  # 处理碰撞逻辑（伤害或特效）
	_spawn_bullet_tracer(end_pos)  # 生成子弹轨迹特效
	ray_cast.enabled = false  # 关闭射线（非必要，可根据需求保留）


func _get_ray_end_position() -> Vector2:
	"""获取射线终点坐标（碰撞点或原始目标点）"""
	if ray_cast.is_colliding():
		return ray_cast.get_collision_point()
	else:
		return ray_cast.to_global(ray_cast.target_position)


func _handle_collision(end_pos: Vector2):
	"""处理碰撞逻辑（伤害或击中特效）"""
	if not ray_cast.is_colliding():
		return  # 无碰撞，无需处理

	var hit_collider = ray_cast.get_collider()
	if not hit_collider:
		return  # 碰撞体为空，跳过

	if hit_collider is HitBox:
		_deal_damage_to_hitbox(hit_collider)  # 对HitBox造成伤害
	else:
		_spawn_hit_effect(end_pos)  # 生成墙面/障碍物击中特效


func _deal_damage_to_hitbox(hit_box: HitBox):
	"""对HitBox造成伤害（生成DamageData并调用hurt方法）"""
	# 构造伤害数据（修正参数顺序，移除多余的true）
	var spawn_blood_cloud: bool = true
	var damage_data: DamageData = DamageData.new_damage(
		damage,
		ray_cast.global_transform.x,  # 子弹方向（射线x轴方向）
		ray_cast.get_collision_point(),  # 碰撞点坐标
		ray_cast.get_collision_normal(),  # 碰撞点法线
		source_of_attack,  # 伤害来源节点
		DamageData.NO_STUN_TIME,  # 无眩晕
		spawn_blood_cloud, # 是否生成血雾
		1.0  # 击退系数（正常）
	)
	hit_box.hurt(damage_data)  # 调用受击方法


func _spawn_hit_effect(hit_position: Vector2):
	"""生成击中墙面/障碍物的特效"""
	if not BULLET_HIT_EFFECT:
		push_warning("BULLET_HIT_EFFECT资源未找到！")
		return

	var hit_effect = BULLET_HIT_EFFECT.instantiate()
	hit_effect.global_position = hit_position  # 设置特效位置
	get_tree().get_root().call_deferred("add_child", hit_effect) # 延迟添加避免帧同步问题


func _spawn_bullet_tracer(end_pos: Vector2):
	"""生成子弹轨迹特效"""
	if not BULLET_TRACER:
		push_warning("BULLET_TRACER资源未找到！")
		return

	var bullet_tracer = BULLET_TRACER.instantiate()
	get_tree().get_root().call_deferred("add_child", bullet_tracer)  # 延迟添加避免帧同步问题
	bullet_tracer.display_line(global_position, end_pos)  # 设置轨迹起点和终点
