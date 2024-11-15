extends Node2D

var stone: PackedScene = preload("res://entities/water/water_effect/stone.tscn")


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		var s: CharacterBody2D = stone.instantiate()
		s.initialize(get_global_mouse_position())
		get_tree().current_scene.add_child(s)
