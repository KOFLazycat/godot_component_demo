extends RayCast2D

## 生成闪电的数量
@export_range(1, 10) var flashes: int = 3
@export_range(0, 10) var bounce_max: int = 3
@export_range(0.0, 3.0) var flash_time: float = 0.1

@onready var lightning_chain: PackedScene = preload("res://vfx/lightning_beam/lightning_chain.tscn")
@onready var bounce_area: Area2D = $BounceArea

var target_point: Vector2 = Vector2.ZERO


func _physics_process(_delta: float) -> void:
	target_point = to_global(target_position)
	if is_colliding():
		target_point = get_collision_point()
	
	bounce_area.global_position = target_point


func initial_lightning() -> void:
	var _target_point: Vector2 = target_point
	if is_colliding():
		## 获取射线相交的第一个对象
		var first_body: Node2D = get_collider()
		## 获取跳转的对象
		var bounce_body: Array[Node2D] = bounce_area.get_overlapping_bodies()
		bounce_body.erase(first_body)
		_target_point = first_body.global_position
		
		for flash in range(flashes):
			var start: Vector2 = global_position
			var lightning_chain_segment: LightningChain = lightning_chain.instantiate()
			add_child(lightning_chain_segment)
			lightning_chain_segment.create_lightning(start, target_point)
			## 对于次要物体跳转，跳转次数不能超过最大值
			start = first_body.global_position
			for i in range(min(bounce_max, bounce_body.size())):
				var body: Node2D = bounce_body[i]
				lightning_chain_segment = lightning_chain.instantiate()
				add_child(lightning_chain_segment)
				lightning_chain_segment.create_lightning(start, body.global_position)
				
				start = body.global_position
				
		await get_tree().create_timer(flash_time).timeout
