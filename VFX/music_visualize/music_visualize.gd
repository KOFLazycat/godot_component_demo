extends Line2D

@onready var audio_instance: AudioEffectInstance
@onready var lines_up: Array = []
@onready var lines_down: Array = []


func _ready() -> void:
	for i in 48:
		add_point(Vector2(i*16,0))
	
	audio_instance = AudioServer.get_bus_effect_instance(1,0)
	add_up_lines()
	add_down_lines()


func _process(_delta) -> void:
	for i in points.size():
		var temp_y: float = -(audio_instance.get_magnitude_for_frequency_range(60*i, 60*(i+1))*1000).y
		lines_down[i].points[1].y = lerp(lines_down[i].points[1].y, -temp_y ,0.1)
		lines_up[i].points[1].y = lerp(lines_up[i].points[1].y, temp_y, 0.1)


func add_up_lines() -> void:
	for i in points.size():
		var new_line_1:Line2D = Line2D.new()
		add_child(new_line_1)
		lines_up.append(new_line_1)
		# 起点
		new_line_1.add_point(points[i])
		# 终点
		new_line_1.add_point(points[i])


func add_down_lines() -> void:
	for i in points.size():
		var new_line_2:Line2D = Line2D.new()
		add_child(new_line_2)
		lines_down.append(new_line_2)
		# 起点
		new_line_2.add_point(points[i])
		# 终点
		new_line_2.add_point(points[i])
