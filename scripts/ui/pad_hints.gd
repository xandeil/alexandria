class_name PadHints
extends Control
## No Modo controle, no lugar dos botões de toque: uma legenda DISCRETA com os
## botões do controle ligado (PlayStation, Xbox, Nintendo ou genérico — quem
## sabe desenhar cada um é o PadStyle) e o que cada um faz agora.
##
##   L1 Escudo  L2 Aparar  R1 Ataque  R2 Forte   (L1/L2 mudam com as mãos)
##                    △ Humanidade (segurar: duas mãos)
##          □ Frasco x3        ○ Esquiva
##                    ✕ Interagir / Falar
##
## Os símbolos são desenhados (não dependem de fonte) com as cores clássicas.

const ALPHA := 0.62

var interact_label := "Interagir"
var flasks := 0
var sanity_flasks := 0
## O que L1 e L2 fazem agora (mudam com o que está nas mãos — hand_labels).
var l1_label := "Escudo"
var l2_label := "Aparar"


## [L1, L2] para cada jeito de segurar (Game.hand_mode). Um lugar só: a
## legenda do controle e os botões de toque leem daqui.
static func hand_labels(mode: String) -> Array[String]:
	match mode:
		"escudo":
			return ["Escudo", "Aparar"]
		"duas_maos":
			return ["Guarda", "Especial"]
		"par":
			return ["As duas", "Forte E."]
		"dupla":
			return ["Ataque E.", "Forte E."]
	return ["—", "Aparar"]


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	Settings.changed.connect(queue_redraw)  # trocou o controle (ou o estilo nas Opções): redesenha


func _draw() -> void:
	var view := get_viewport_rect().size  # sob um CanvasLayer não há Control pai: as âncoras não dão tamanho
	var center := Vector2(view.x - 78, view.y - 40)
	var step := 13.0
	var r := 5.5
	var font := UIStyle.FONT
	draw_set_transform(Vector2.ZERO)
	# Ombros (uma linha acima do losango).
	var shoulders := [["L1", l1_label], ["L2", l2_label], ["R1", "Ataque"], ["R2", "Forte"]]
	var x := view.x - 236.0
	for pair in shoulders:
		x = _shoulder(Vector2(x, view.y - 80), pair[0], pair[1], font) + 16.0
	# O losango dos botões de face.
	glyph(self, center + Vector2(0, -step), "triangle", r, ALPHA * (1.0 if sanity_flasks > 0 else 0.5))
	glyph(self, center + Vector2(-step, 0), "square", r, ALPHA)
	glyph(self, center + Vector2(step, 0), "circle", r, ALPHA)
	glyph(self, center + Vector2(0, step), "cross", r, ALPHA)
	_text(center + Vector2(0, -step - 9), "Humanidade x%d · segure: 2 mãos" % sanity_flasks, font, HORIZONTAL_ALIGNMENT_CENTER)
	_text(center + Vector2(-step - 9, 3), "Frasco x%d" % flasks, font, HORIZONTAL_ALIGNMENT_RIGHT)
	_text(center + Vector2(step + 9, 3), "Esquiva · segure: correr", font, HORIZONTAL_ALIGNMENT_LEFT)
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
	var name := PadStyle.shoulder(button)  # L1 / LB / L...
	var box := Rect2(at - Vector2(0, 7), Vector2(13, 9))
	draw_rect(box, Color(0.08, 0.08, 0.1, ALPHA * 0.9))
	draw_rect(box, Color(0.8, 0.8, 0.85, ALPHA), false, 1.0)
	var inset := (13.0 - font.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, 6).x) * 0.5
	draw_string(font, at + Vector2(inset, 0), name, HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Color(1, 1, 1, ALPHA))
	var label_at := at + Vector2(16, 0)
	_text(label_at, label, font, HORIZONTAL_ALIGNMENT_LEFT)
	return label_at.x + font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 7).x


## Desenha um botão de face (o estilo vem do PadStyle). Mantido aqui porque
## a legenda, os menus e o diálogo já chamam PadHints.glyph.
static func glyph(canvas: CanvasItem, at: Vector2, kind: String, radius: float, alpha: float = 1.0) -> void:
	PadStyle.glyph(canvas, at, kind, radius, alpha)
