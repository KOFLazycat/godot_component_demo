extends Node2D

@onready var bullet_impulse_tscn: PackedScene = preload("res://entities/bullet/bullet_impulse/bullet_impulse.tscn") as PackedScene


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		var bullet_impulse: BulletImpulse = bullet_impulse_tscn.instantiate() as BulletImpulse
		var v: Vector2 = Vector2.RIGHT * 150
		var pos: Vector2 = get_global_mouse_position()
		bullet_impulse.start(v)
		bullet_impulse.global_position = pos
		add_child(bullet_impulse)
