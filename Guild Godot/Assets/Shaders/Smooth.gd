tool
class_name SmoothPath
extends Path2D

export(float) var spline_length = 50
export(bool) var _smooth setget smooth
export(bool) var _straighten setget straighten

var t = 0.0

func create_curve(begin, end, nb_points):
	var radius = (end - begin).length()/2
	print(radius)
	var center = begin + direction_to(begin, end) * radius
	var tangent = center.tangent().normalized()
	var middle = center + (tangent * 250)
	print(middle)
	curve = Curve2D.new()
	
	var t = 0.0
	var increment = 1.0/nb_points
	while t <= 1.0:
		var point = _quadratic_bezier(begin, middle, end, t)
		curve.add_point(point)
		t += increment
	
	smooth(true)


func _physics_process(delta):
	t += delta
	if t >= 1.0:
		t = 0.0
	$Particles2D.position = curve.interpolate_baked(t * curve.get_baked_length(), true)

func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float):
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)
	var r = q0.linear_interpolate(q1, t)
	return r

func direction_to(a, b):
	return (b - a).normalized()

func straighten(value):
	if not value: return
	for i in curve.get_point_count():
		curve.set_point_in(i, Vector2())
		curve.set_point_out(i, Vector2())

func smooth(value):
	if not value: return

	var point_count = curve.get_point_count()
	for i in point_count:
		var spline = _get_spline(i)
		curve.set_point_in(i, -spline)
		curve.set_point_out(i, spline)

func _get_spline(i):
	var last_point = _get_point(i - 1)
	var next_point = _get_point(i + 1)
	var spline = direction_to(last_point, next_point) * spline_length
	return spline

func _get_point(i):
	var point_count = curve.get_point_count()
	i = wrapi(i, 0, point_count - 1)
	return curve.get_point_position(i)

func _draw():
	var points = curve.get_baked_points()
	if points:
		draw_polyline(points, Color.red, 8, true)