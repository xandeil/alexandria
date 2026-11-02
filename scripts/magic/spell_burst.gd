class_name SpellBurst
extends Node2D
## v0.50: o desenho de uma magia de área — um anel de luz que abre e some
## (explosão, tempestade) ou um leque à frente (lâmina, chicote de chamas).

var radius := 40.0
var color := Color.WHITE
## Vector2.ZERO = anel inteiro; senão, um leque nessa direção.
var direction := Vector2.ZERO
var half_angle := 70.0
var _t := 0.0
const LIFE := 0.35


static func spawn(parent: Node, at: Vector2, burst_radius: float, burst_color: Color, dir: Vector2 = Vector2.ZERO) -> SpellBurst:
	var burst := SpellBurst.new()
	burst.radius = burst_radius
	burst.color = burst_color
	burst.direction = dir
	burst.z_index = 6
	burst.material = Fx.unshaded
	parent.add_child(burst)
	burst.global_position = at
	return burst


func _process(delta: float) -> void:
	_t += delta
	if _t >= LIFE:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var k := _t / LIFE
	var r := radius * (0.35 + 0.65 * k)
	var fade := Color(color, 0.85 * (1.0 - k))
	if direction == Vector2.ZERO:
		draw_circle(Vector2.ZERO, r, Color(color, 0.18 * (1.0 - k)))
		draw_arc(Vector2.ZERO, r, 0.0, TAU, 32, fade, 3.0)
	else:
		var a := direction.angle()
		var span := deg_to_rad(half_angle)
		draw_arc(Vector2.ZERO, r, a - span, a + span, 16, fade, 4.0)
		draw_arc(Vector2.ZERO, r * 0.7, a - span * 0.8, a + span * 0.8, 12, Color(1, 1, 1, 0.6 * (1.0 - k)), 2.0)
