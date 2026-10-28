class_name ButtonHintBar
extends Control
## Barra de legenda no rodapé dos menus ("✕ Equipar   ○ Voltar   L1/R1 Categoria").
##
## No modo controle desenha os botões do controle ligado (PadStyle: PlayStation,
## Xbox, Nintendo ou genérico); fora dele, escreve a tecla. Desenhar o
## símbolo em vez de usar um caractere ✕○ evita depender da fonte ter o glifo.

## Cada item: [botão do controle, tecla do teclado, texto]. Botões: "cross",
## "circle", "square", "triangle" ou um texto curto ("L1/R1").
var items: Array = []:
	set(value):
		items = value
		queue_redraw()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	Settings.changed.connect(queue_redraw)


func _draw() -> void:
	var font := UIStyle.FONT
	var x := 0.0
	var y := size.y * 0.5
	for item: Array in items:
		var pad: String = item[0]
		var key: String = item[1]
		var text: String = item[2]
		if Settings.controller_mode and pad in ["cross", "circle", "square", "triangle"]:
			PadHints.glyph(self, Vector2(x + 5.0, y), pad, 4.5)
			x += 13.0
		else:
			var label: String = PadStyle.text(pad) if Settings.controller_mode else key
			draw_string(font, Vector2(x, y + 3.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.95, 0.9, 0.75))
			x += font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 8).x + 4.0
		draw_string(font, Vector2(x, y + 3.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.7, 0.68, 0.64))
		x += font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 8).x + 14.0
