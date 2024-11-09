extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var line_2d: Line2D = $Line2D


var speed = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	sprite_2d.position = Vector2(480, 60)
	line_2d.points = [Vector2(0, 300), Vector2(960, 300)]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if sprite_2d.position.y > 300:
		speed -= 30
		line_2d.points = [Vector2(0, 300), sprite_2d.position, Vector2(960, 300)]
	else:
		speed += 20
		line_2d.points = [Vector2(0, 300), Vector2(960, 300)]
	sprite_2d.position.y += speed * delta
