class_name WeaponFx
extends Node2D
## Efeitos de um instante das armas (desenhados por código, somem sozinhos):
## a onda de choque do martelo e o raio que salta do virote.

var _kind := ""
var _a := Vector2.ZERO
var _b := Vector2.ZERO
var _radius := 0.0
var _color := Color.WHITE
var _life := 0.25
var _time := 0.0
var _jitter: PackedVector2Array = []


static func ring(parent: Node, at: Vector2, radius: float, color: Color) -> void:
	var fx := WeaponFx.new()
	fx._kind = "ring"
	fx._radius = radius
	fx._color = color
	fx._life = 0.3
	fx.position = at
	parent.add_child(fx)


static func lightning(parent: Node, from: Vector2, to: Vector2) -> void:
	var fx := WeaponFx.new()
	fx._kind = "bolt"
	fx._a = from
	fx._b = to
	fx._color = Color(0.7, 0.92, 1.0)
	fx._life = 0.18
	parent.add_child(fx)
	Sfx.play(&"zap", -6.0)


func _ready() -> void:
	z_index = 7
	material = Fx.unshaded
	if _kind == "bolt":  # zigue-zague fixo (sorteado uma vez, não pisca a cada quadro)
		for i in 5:
			_jitter.append(Vector2(randf_range(-4, 4), randf_range(-4, 4)))


func _process(delta: float) -> void:
	_time += delta
	if _time >= _life:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var k := 1.0 - _time / _life
	match _kind:
		"ring":
			draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.6))
			draw_arc(Vector2.ZERO, _radius * (1.1 - 0.6 * k), 0.0, TAU, 40, Color(_color, k), 3.0 * k + 1.0)
			draw_set_transform(Vector2.ZERO)
		"bolt":
			var points := PackedVector2Array([_a])
			for i in _jitter.size():
				points.append(_a.lerp(_b, (i + 1.0) / (_jitter.size() + 1.0)) + _jitter[i])
			points.append(_b)
			draw_polyline(points, Color(_color, k), 2.0)
			draw_polyline(points, Color(1, 1, 1, k), 1.0)
