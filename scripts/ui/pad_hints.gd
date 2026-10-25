class_name PadHints
extends Control
## No Modo controle, no lugar dos botões de toque: uma legenda DISCRETA com os
## botões do controle (padrão PlayStation) e o que cada um faz agora.
##
##        L1/L2 Escudo   R1 Ataque   R2 Forte
##                    △ Humanidade
##          □ Frasco x3        ○ Esquiva
##                    ✕ Interagir / Falar
##
## Os símbolos são desenhados (não dependem de fonte) com as cores clássicas.

const ALPHA := 0.62
const CROSS := Color(0.55, 0.72, 1.0)
const CIRCLE := Color(1.0, 0.5, 0.5)
const SQUARE := Color(1.0, 0.6, 0.88)
const TRIANGLE := Color(0.5, 0.95, 0.72)

var interact_label := "Interagir"
var flasks := 0
var sanity_flasks := 0


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var view := get_viewport_rect().size  # sob um CanvasLayer não há Control pai: as âncoras não dão tamanho
	var center := Vector2(view.x - 78, view.y - 40)
	var step := 13.0
	var r := 5.5
	var font := UIStyle.FONT
	draw_set_transform(Vector2.ZERO)
	# Ombros (uma linha acima do losango).
	var shoulders := [["L1", "Escudo"], ["R1", "Ataque"], ["R2", "Forte"]]
	var x := view.x - 170.0
	for pair in shoulders:
		x = _shoulder(Vector2(x, view.y - 80), pair[0], pair[1], font) + 16.0
	# O losango dos botões de face.
	glyph(self, center + Vector2(0, -step), "triangle", r, ALPHA * (1.0 if sanity_flasks > 0 else 0.5))
	glyph(self, center + Vector2(-step, 0), "square", r, ALPHA)
	glyph(self, center + Vector2(step, 0), "circle", r, ALPHA)
	glyph(self, center + Vector2(0, step), "cross", r, ALPHA)
	_text(center + Vector2(0, -step - 9), "Humanidade x%d" % sanity_flasks, font, HORIZONTAL_ALIGNMENT_CENTER)
	_text(center + Vector2(-step - 9, 3), "Frasco x%d" % flasks, font, HORIZONTAL_ALIGNMENT_RIGHT)
	_text(center + Vector2(step + 9, 3), "Esquiva", font, HORIZONTAL_ALIGNMENT_LEFT)
	_text(center + Vector2(0, step + 15), interact_label, font, HORIZONTAL_ALIGNMENT_CENTER)


func _text(at: Vector2, text: String, font: Font, align: HorizontalAlignment) -> void:
	var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 7).x
	var left := at.x
	if align == HORIZONTAL_ALIGNMENT_CENTER:
		left -= width * 0.5
	elif align == HORIZONTAL_ALIGNMENT_RIGHT:
		left -= width
	draw_string_outline(font, Vector2(left, at.y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 7, 3, Color(0, 0, 0, ALPHA))
	draw_string(font, Vector2(left, at.y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.95, 0.93, 0.9, ALPHA))


## "L1 Escudo": a etiqueta do gatilho/ombro numa caixinha arredondada.
func _shoulder(at: Vector2, button: String, label: String, font: Font) -> float:
	var box := Rect2(at - Vector2(0, 7), Vector2(13, 9))
	draw_rect(box, Color(0.08, 0.08, 0.1, ALPHA * 0.9))
	draw_rect(box, Color(0.8, 0.8, 0.85, ALPHA), false, 1.0)
	draw_string(font, at + Vector2(1.5, 0), button, HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Color(1, 1, 1, ALPHA))
	var label_at := at + Vector2(16, 0)
	_text(label_at, label, font, HORIZONTAL_ALIGNMENT_LEFT)
	return label_at.x + font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 7).x


## Desenha um botão de face do PlayStation em qualquer CanvasItem (reaproveitável:
## o diálogo e os menus podem usar o mesmo desenho).
static func glyph(canvas: CanvasItem, at: Vector2, kind: String, radius: float, alpha: float = 1.0) -> void:
	canvas.draw_circle(at, radius + 1.0, Color(0.05, 0.05, 0.07, alpha * 0.9))
	canvas.draw_arc(at, radius + 1.0, 0.0, TAU, 20, Color(0.75, 0.75, 0.8, alpha * 0.8), 1.0)
	var s := radius * 0.55
	match kind:
		"cross":
			canvas.draw_line(at + Vector2(-s, -s), at + Vector2(s, s), Color(CROSS, alpha), 1.4)
			canvas.draw_line(at + Vector2(-s, s), at + Vector2(s, -s), Color(CROSS, alpha), 1.4)
		"circle":
			canvas.draw_arc(at, s, 0.0, TAU, 16, Color(CIRCLE, alpha), 1.4)
		"square":
			canvas.draw_rect(Rect2(at - Vector2(s, s) * 0.9, Vector2(s, s) * 1.8), Color(SQUARE, alpha), false, 1.3)
		"triangle":
			var points := PackedVector2Array([at + Vector2(0, -s), at + Vector2(s, s * 0.75), at + Vector2(-s, s * 0.75), at + Vector2(0, -s)])
			canvas.draw_polyline(points, Color(TRIANGLE, alpha), 1.3)
