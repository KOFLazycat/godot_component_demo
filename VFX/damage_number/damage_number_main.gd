extends Node2D

@onready var marker_2d: Marker2D = $Sprite2D/Marker2D


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		var damage: int = randi_range(10, 20)
		var is_critical: bool = false
		var critical_rand = randf_range(0.0, 1.0)
		if critical_rand > 0.8:
			is_critical = true
		DamageNumber.display_number(damage, marker_2d.global_position, is_critical)
