class_name TelegraphDrawer
extends Node2D
## Desenha os AVISOS dos golpes do chefe no chão: linha (estocada, onda de
## choque, investida), círculo (salto, martelada) e leque (varredura).
## Num Souls-like punitivo, todo golpe forte precisa ser LEGÍVEL: o jogador
## morre porque errou o tempo da esquiva, nunca porque "não deu para ver".

var line_visible := false
var line_origin := Vector2.ZERO
var line_direction := Vector2.RIGHT
var line_length := 100.0
## false = mira ainda acompanhando (fraco); true = travou (forte: esquive AGORA).
var line_locked := false
## Linhas extras com a mesma origem e comprimento (leque de ondas de choque).
var extra_line_directions: Array[Vector2] = []

var circle_visible := false
var circle_center := Vector2.ZERO
var circle_radius := 26.0
var circle_progress := 0.0

var arc_visible := false
var arc_center := Vector2.ZERO
var arc_direction := Vector2.RIGHT
var arc_radius := 40.0
var arc_angle := deg_to_rad(200.0)
var arc_progress := 0.0

var _pulse := 0.0
## O que foi desenhado por último continua na tela até o próximo _draw().
## Por isso redesenhamos também no quadro em que o aviso SOME (senão a linha
## da estocada ficaria "congelada" no chão depois do golpe).
var _was_drawing := false


func _ready() -> void:
	top_level = true  # desenha em coordenadas do mundo
	global_position = Vector2.ZERO
	z_index = -1
	material = Fx.unshaded  # o aviso não pode sumir no escuro do Teatro


func _process(delta: float) -> void:
	_pulse += delta
	var drawing := line_visible or circle_visible or arc_visible
	if drawing or _was_drawing:
		queue_redraw()
	_was_drawing = drawing


## Esconde tudo (o próximo quadro já apaga o desenho).
func hide_all() -> void:
	line_visible = false
	circle_visible = false
	arc_visible = false
	extra_line_directions.clear()


func clear() -> void:
	hide_all()
	queue_redraw()


func _draw() -> void:
	if line_visible:
		_draw_line(line_direction)
		for direction in extra_line_directions:
			_draw_line(direction)
	if circle_visible:
		draw_arc(circle_center, circle_radius, 0.0, TAU, 40, Color(1.0, 0.3, 0.2, 0.9), 1.5)
		draw_circle(circle_center, circle_radius * clampf(circle_progress, 0.0, 1.0), Color(1.0, 0.25, 0.15, 0.35))
	if arc_visible:
		var steps := 24
		var start := arc_direction.angle() - arc_angle * 0.5
		var points := PackedVector2Array([arc_center])
		for i in steps + 1:
			points.append(arc_center + Vector2.from_angle(start + arc_angle * i / steps) * arc_radius)
		draw_colored_polygon(points, Color(1.0, 0.28, 0.18, 0.12 + 0.22 * clampf(arc_progress, 0.0, 1.0)))
		draw_arc(arc_center, arc_radius, start, start + arc_angle, steps, Color(1.0, 0.3, 0.2, 0.85), 1.5)


func _draw_line(direction: Vector2) -> void:
	var alpha := 0.75 + 0.25 * sin(_pulse * 30.0) if line_locked else 0.45
	var color := Color(1.0, 0.22, 0.18, alpha)
	var end := line_origin + direction * line_length
	var side := direction.orthogonal() * (5.0 if line_locked else 3.0)
	draw_colored_polygon(PackedVector2Array([line_origin + side, end, line_origin - side]), Color(color, alpha * 0.35))
	draw_line(line_origin, end, color, 2.0 if line_locked else 1.0)
	draw_circle(end, 2.5, color)
