extends Line2D

##扭曲次数（随机数）
@export var arc: int = 100 
##随机偏移量
@export var rand_range: int = 10 
##闪电路径
@export var lighting_path: PackedVector2Array 
##闪电速度
@export var lighting_speed: float = 0.002 
##闪电生成后多久画面开始闪烁
@export var lighting_flash_time: float = 0.05 
##画面闪烁后多久消失
@export var lighting_disappear_time: float = 0.5 
###随机分裂次数
#@export var division: int = 80 
###分裂路径1
#@export var division1: PackedVector2Array 

@onready var flash_animation_player: AnimationPlayer = $FlashAnimationPlayer
@onready var timer: Timer = $Timer


func _ready() -> void:
	timer.timeout.connect(on_timer_timeout)
	timer.start()


func _process(delta: float) -> void:
	points = lighting_path


func set_lighting():
	modulate = Color(1,1,1,1)#恢复透明度
	# 生成起始和终点
	# TODO A、B可设置随机值
	var pos_a: Vector2 = Vector2(randf_range(180, 840), -10)
	var pos_b: Vector2= Vector2(randf_range(0, 960), randf_range(400, 540))
	lighting_path.append(pos_a)
	
	var last_pos: Vector2 = Vector2.ZERO
	var next_pos: Vector2 = Vector2.ZERO
	for n in (arc - 2):
		last_pos = lighting_path[lighting_path.size() - 1]
		next_pos = last_pos + (pos_b - last_pos)/(arc - 1 -n) + Vector2(randf_range(-rand_range, rand_range), randf_range(-rand_range, rand_range))
		lighting_path.append(next_pos)
		# 每隔一段时间再增加下一个节点，这样看起来闪电是一点一点形成的
		await get_tree().create_timer(lighting_speed).timeout
	
	#设置终点
	lighting_path.append(pos_b)
	
	#画面闪烁
	await get_tree().create_timer(lighting_flash_time).timeout
	flash_animation_player.play("flash")
	
	#消失
	await flash_animation_player.animation_finished
	var disappear: Tween = create_tween()
	disappear.tween_property(self, "modulate", Color(0,0,0,0), lighting_disappear_time).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	disappear.play()
	lighting_path.clear()


func on_timer_timeout() -> void:
	set_lighting()
