class_name Scent extends Node2D # 气味类

@onready var timer: Timer = $Timer

var player: ScentPlayer


func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	timer.start()


func _on_timer_timeout() -> void:
	player.scent_array.erase(self)
	queue_free()
