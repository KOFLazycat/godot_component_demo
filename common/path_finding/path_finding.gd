extends Node2D

@onready var path_follow_2d = $Path2D/PathFollow2D
@onready var player: Sprite2D = $Player
var speed = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	path_follow_2d.set_progress(path_follow_2d.get_progress() + speed * delta)
	player.global_position = path_follow_2d.global_position
	#player.rotate(0.1)
