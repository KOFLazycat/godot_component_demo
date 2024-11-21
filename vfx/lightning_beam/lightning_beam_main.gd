extends Node2D

@onready var lightning_beam: RayCast2D = $LightningBeam


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		lightning_beam.initial_lightning()


func _process(delta: float) -> void:
	lightning_beam.look_at(get_global_mouse_position())
