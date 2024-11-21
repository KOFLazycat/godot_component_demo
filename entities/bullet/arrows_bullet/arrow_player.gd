extends CharacterBody2D

@onready var player: AnimatedSprite2D = $Player

const SPEED:float = 100.0
var direction: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	direction = Input.get_vector("left", "right", "up", "down")
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		player.play("run")
		if direction.x > 0:
			player.flip_h = false
		if direction.x < 0:
			player.flip_h = true
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED/4)
		player.play("idle")
	move_and_slide()
