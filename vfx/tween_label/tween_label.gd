class_name TweenLabel extends Node2D

@export var from_num: int = 0
@export var to_num: int = 100
@onready var label: Label = $Label


func _ready() -> void:
	var tween: Tween = create_tween()
	tween.tween_method(update_label, from_num, to_num, 0.2).set_trans(Tween.TRANS_LINEAR)
	# 放大到 1.5 倍，快速完成（0.2秒）
	tween.parallel().tween_property(label, "scale", Vector2(1.5, 1.5), 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# 缩放到原始尺寸，带有弹性效果（0.5秒）
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


func update_label(v: int) -> void:
	label.text = str(v)
