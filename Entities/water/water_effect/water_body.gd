extends Node2D

## 倔强系数，是一个常数
@export var k: float = 0.015
## 阻尼值，控制运动停下来的时间
@export var d: float = 0.03
## 扩散系数，判断运动会扩散多少次
@export var spread: float = 0.0002
## 每个spring相距的距离
@export var distance_between_springs: float = 36.0
## 场景中spring的数量
@export var spring_number: int = 6
## 水深
@export var depth: float = 1000.0
## 水面厚度
@export var border_thickness: float = 1.1


@onready var water_spring: PackedScene = preload("res://entities/water/water_effect/water_spring.tscn")
@onready var water_particles: PackedScene = preload("res://entities/water/water_effect/water_particles.tscn")
@onready var water_polygon: Polygon2D = $WaterPolygon
@onready var water_border: SmoothPath = $WaterBorder
@onready var water_area: Area2D = $WaterArea
@onready var collision_shape_2d: CollisionShape2D = $WaterArea/CollisionShape2D

var springs: Array = []
var passes: int = 8
var water_length: float = distance_between_springs * spring_number
var target_height: float = global_position.y
var bottom: float = 0.0

func _ready() -> void:
	for i in range(spring_number):
		var x_position: float = distance_between_springs * i
		var w: Node2D = water_spring.instantiate()
		add_child(w)
		springs.append(w)
		w.initialize(x_position, i)
		w.set_collision_width(distance_between_springs)
		w.splash.connect(splash)
	
	water_border.width = border_thickness
	bottom = target_height + depth
	
	var total_length: float = distance_between_springs * (spring_number - 1)
	var rectangle: RectangleShape2D = RectangleShape2D.new().duplicate()
	var rect_position: Vector2 = Vector2(total_length / 2, depth / 2)
	water_area.position = rect_position
	rectangle.size = rect_position * 2
	collision_shape_2d.shape = rectangle
	water_area.body_entered.connect(on_water_area_body_entered)


func _physics_process(delta: float) -> void:
	for i in springs:
		i.water_update(k, d)
	
	var left_deltas: Array = []
	var right_deltas: Array = []
	
	for i in range (springs.size()):
		left_deltas.append(0)
		right_deltas.append(0)
	
	for j in range(passes):
		for i in range (springs.size()):
			if i > 0:
				left_deltas[i] = spread * (springs[i].height - springs[i - 1].height)
				springs[i - 1].velocity += left_deltas[i]
			if i < springs.size() - 1:
				right_deltas[i] = spread * (springs[i].height - springs[i + 1].height)
				springs[i + 1].velocity += right_deltas[i]
	new_border()
	draw_water_body()


# 给指定索引spring增加个速度
func splash(index: int, speed: float) -> void:
	if index >= 0 and index < springs.size():
		springs[index].velocity += speed


func draw_water_body() -> void:
	var curve: Resource = water_border.curve
	var points: Array = Array(curve.get_baked_points())
	var water_polygon_points: Array = points
	
	var first_index: int = 0
	var last_index: int = water_polygon_points.size() - 1
	
	water_polygon_points.append(Vector2(water_polygon_points[last_index].x, bottom))
	water_polygon_points.append(Vector2(water_polygon_points[first_index].x, bottom))
	water_polygon_points = PackedVector2Array(water_polygon_points)
	water_polygon.polygon = PackedVector2Array(water_polygon_points)


func new_border() -> void:
	var curve: Resource = Curve2D.new().duplicate()
	
	var surface_points: Array = []
	for i in range(springs.size()):
		surface_points.append(springs[i].position)
	
	for i in range(surface_points.size()):
		curve.add_point(surface_points[i])
	water_border.curve = curve
	water_border.smooth = true
	water_border.update()


func on_water_area_body_entered(body: Node2D) -> void:
	var p = water_particles.instantiate()
	add_child(p)
	p.global_position = body.global_position
