extends Control
class_name PieChart

var values : Dictionary

var colors: Array
var current = 12

func _init(size: Vector2):
	set_custom_minimum_size(size)
	self.colors = [Color.html("#64e571"), 
	Color.html("#b6ff55"), Color.html("#86ff64"), Color.html("#39db0c"),
	Color.html("#febd00"), Color.html("#fb5700"), Color.html("#ff03ba"), 
	Color.html("#feff0b"), Color.html("#ddb201"), Color.html("#0f7bd3"), 
	Color.html("#bed700"), Color.html("#bdcfe7"), Color.html("#558de4"), 
	Color.html("#1120d3"), Color.html("#7b28b8"), Color.html("#23cbe5")
	]
	for i in range(16):
		self.values[i] = 1

func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 40
	var points_arc = PackedVector2Array()
	points_arc.push_back(center)
	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(angle_from + i * (angle_to - angle_from) / nb_points )
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_colored_polygon(points_arc, color)

func change_month():
	for i in range(len(colors)):
		colors[i].a = 0.1 ## Change opacity value here
	colors[current].a = 1
	current += 1
	current %= 16
	queue_redraw()

func _draw():
	var center = Vector2(size.x/2, size.y/2)
	var radius = min(size.x, size.y) / 2
	var previousAngle : float = 0
	var angle_inc = 360 / 16.0
	
	for i in values:
		draw_circle_arc_poly( center, radius,
		previousAngle, previousAngle + angle_inc, colors[i])
		previousAngle += angle_inc
