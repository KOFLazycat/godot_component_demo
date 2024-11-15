extends Control

@onready var color_rect = $ColorRect
#每次闪烁间隔时间
@export var time_for_each_flash = 0.5
#闪烁次数
@export var times_for_flash = 3


func _ready():
	var tween = get_tree().create_tween()
	var i = 0
	while i < times_for_flash:
		i += 1
		tween.tween_property(color_rect, "modulate", Color(1,1,1,0.1), time_for_each_flash).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
		tween.tween_property(color_rect, "modulate", Color(1,1,1,0.7), time_for_each_flash).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	
	await tween.finished
	queue_free()

