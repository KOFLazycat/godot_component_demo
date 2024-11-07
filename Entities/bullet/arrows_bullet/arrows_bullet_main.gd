extends Node2D

@onready var arrow_player: CharacterBody2D = $ArrowPlayer
@onready var arrow_tscn = preload("res://Entities/bullet/arrows_bullet/arrow.tscn") as PackedScene


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		fire()


func fire() -> void:
	var num: int = randi_range(2, 6)
	for i in range(num):
		var arrow = arrow_tscn.instantiate()
		arrow.global_position = arrow_player.global_position
		add_child(arrow)
