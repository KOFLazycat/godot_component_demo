class_name TweenLabel extends Node2D

@export var from_num: int = 0
@export var to_num: int = 100
@onready var label: Label = $Label


func _ready() -> void:
	var tween: Tween = create_tween()
	tween.tween_method(update_label, from_num, to_num, 5.0).set_trans(Tween.TRANS_LINEAR)


func update_label(v: int) -> void:
	label.text = str(v)
