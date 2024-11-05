extends Node2D

@onready var spawn_timer: Timer = $SpawnTimer
@onready var ant_player: AntPlayer = $AntPlayer
@onready var ant_enemy_scene: PackedScene = preload("res://entities/player/ant_player/ant_enemy.tscn")

const MAX_ENEMY_COUNT: int = 50
var total_enemy_num: int = 0

func _ready() -> void:
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)


func _on_spawn_timer_timeout() -> void:
	for i in range(10):
		var ant_enemy: AntEnemy = ant_enemy_scene.instantiate()
		ant_enemy.global_position = Vector2(300, 180)
		ant_enemy.player = ant_player
		add_child(ant_enemy)
		total_enemy_num += 1
		if total_enemy_num >= MAX_ENEMY_COUNT:
			spawn_timer.stop()
			break
	
	
