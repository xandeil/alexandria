class_name SlashFX
extends Node2D
## Meia-lua do golpe, desenhada por código (sem sprite): varre e some em ~0,14 s.
## Desenhar por código deixa a cor/tamanho de cada golpe configurável no AttackData.

var radius := 16.0
var arc := deg_to_rad(140.0)
var thickness := 5.0
var color := Color(1, 1, 1, 0.9)
var duration := 0.14
## Varre no sentido contrário (2º golpe do combo vem pelo outro lado).
var reverse := false
## Estocada: um traço reto em vez de arco.
var thrust := false

var _t := 0.0


func _process(delta: float) -> void:
	_t += delta / duration
	if _t >= 1.0:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var reveal := clampf(_t * 2.2, 0.0, 1.0)
	if reveal < 0.06:
		return
	var fade := 1.0 - clampf((_t - 0.35) / 0.65, 0.0, 1.0)
	var c := Color(color, color.a * fade)
	if thrust:
		var length := radius * 1.7 * reveal
		draw_colored_polygon(PackedVector2Array([
			Vector2(-2, -thickness * 0.45), Vector2(length, 0.0), Vector2(-2, thickness * 0.45)
		]), c)
		return
	var segments := 14
	var outer := PackedVector2Array()
	var inner := PackedVector2Array()
	for i in segments + 1:
		var f := float(i) / segments
		var angle := -arc * 0.5 + arc * reveal * f
		if reverse:
			angle = -angle
		var width := thickness * (0.15 + 0.85 * sin(f * PI)) * (0.5 + 0.5 * f)
		outer.append(Vector2.from_angle(angle) * (radius + width * 0.5))
		inner.append(Vector2.from_angle(angle) * (radius - width * 0.5))
	inner.reverse()
	draw_colored_polygon(outer + inner, c)
