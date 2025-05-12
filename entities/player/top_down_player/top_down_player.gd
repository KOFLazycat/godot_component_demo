class_name TopDownPlayer
extends CharacterBody2D

@onready var top_down_character_mover: TopDownCharacterMover = $TopDownCharacterMover
@onready var top_down_input: TopDownInput = $TopDownInput


func _process(_delta: float) -> void:
	top_down_character_mover.move_vec = top_down_input.move_vec
	top_down_character_mover.face_vec = top_down_input.face_vec
