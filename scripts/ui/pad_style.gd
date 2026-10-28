class_name PadStyle
## Qual CONTROLE está ligado — e como cada botão se chama nele (v0.30).
##
## O Godot (via SDL) entrega os botões por POSIÇÃO: JOY_BUTTON_A é sempre o de
## BAIXO, B o da direita, X o da esquerda, Y o de cima — em qualquer controle.
## O jogo também pensa por posição ("cross" = baixo, "circle" = direita,
## "square" = esquerda, "triangle" = cima). Só o NOME/DESENHO muda:
##
##   posição     PlayStation   Xbox   Nintendo   Genérico
##   baixo          ✕            A        B        ↓ (bolinha embaixo)
##   direita        ○            B        A        →
##   esquerda       □            X        Y        ←
##   cima           △            Y        X        ↑
##   ombros       L1 R1 L2 R2  LB RB LT RT  L R ZL ZR   L1 R1 L2 R2
##
## A família vem do NOME do controle (Input.get_joy_name). Se o nome não
## disser nada (controle "alternativo"), fica o Genérico, que desenha a POSIÇÃO
## do botão — serve para qualquer controle do mundo. As Opções podem forçar
## uma família (Settings.pad_style), caso o nome engane.
##
## Tudo que mostra botão de controle pergunta AQUI (legenda, menus, dicas).
## Um lugar só: um controle novo amanhã é uma linha nestas tabelas.

const FAMILIES: Array[String] = ["playstation", "xbox", "nintendo", "generico"]
const DISPLAY := {"playstation": "PlayStation", "xbox": "Xbox", "nintendo": "Nintendo", "generico": "Genérico"}

## Pedaços do nome do controle → família (em minúsculas; a 1ª que bater vence).
const NAME_HINTS := [
	["playstation", ["playstation", "dualshock", "dualsense", "ps3", "ps4", "ps5", "sony", "wireless controller"]],
	["xbox", ["xbox", "xinput", "microsoft", "x-box"]],
	["nintendo", ["nintendo", "switch", "pro controller", "joy-con", "joycon"]],
]

const FACE_LETTERS := {
	"xbox": {"cross": "A", "circle": "B", "square": "X", "triangle": "Y"},
	"nintendo": {"cross": "B", "circle": "A", "square": "Y", "triangle": "X"},
}
## Cores das letras: Xbox (verde, vermelho, azul, amarelo); Nintendo (as do SNES).
const FACE_COLORS := {
	"xbox": {"A": Color(0.45, 0.85, 0.4), "B": Color(1.0, 0.42, 0.4), "X": Color(0.4, 0.6, 1.0), "Y": Color(1.0, 0.85, 0.3)},
	"nintendo": {"A": Color(1.0, 0.42, 0.4), "B": Color(1.0, 0.85, 0.3), "X": Color(0.4, 0.6, 1.0), "Y": Color(0.45, 0.85, 0.4)},
}
const PS_COLORS := {"cross": Color(0.55, 0.72, 1.0), "circle": Color(1.0, 0.5, 0.5), "square": Color(1.0, 0.6, 0.88),
	"triangle": Color(0.5, 0.95, 0.72)}
const PS_SYMBOLS := {"cross": "✕", "circle": "○", "square": "□", "triangle": "△"}
const PS_NAMES := {"cross": "✕ (Xis)", "circle": "○ (Bola)", "square": "□ (Quadrado)", "triangle": "△ (Triângulo)"}
const POSITION_NAMES := {"cross": "o botão de baixo", "circle": "o botão da direita", "square": "o botão da esquerda",
	"triangle": "o botão de cima"}
const POSITION_ARROWS := {"cross": "↓", "circle": "→", "square": "←", "triangle": "↑"}
const POSITION_OFFSETS := {"cross": Vector2(0, 1), "circle": Vector2(1, 0), "square": Vector2(-1, 0), "triangle": Vector2(0, -1)}

const SHOULDERS := {
	"xbox": {"L1": "LB", "R1": "RB", "L2": "LT", "R2": "RT"},
	"nintendo": {"L1": "L", "R1": "R", "L2": "ZL", "R2": "ZR"},
}

## A família do controle ligado (descoberta sozinha; Settings pode forçar).
static var detected := "generico"
## O controle que mexeu por último (com dois ligados, vale o que está jogando).
static var device := -1


# --- Qual controle ------------------------------------------------------------------------

static func family() -> String:
	return Settings.pad_style if Settings.pad_style in FAMILIES else detected


static func from_name(joy_name: String) -> String:
	var lower := joy_name.to_lower()
	for pair: Array in NAME_HINTS:
		for hint: String in pair[1]:
			if lower.contains(hint):
				return pair[0]
	return "generico"


## Olha de novo os controles ligados (chamado ao ligar/desligar um controle).
static func refresh() -> void:
	var pads := Input.get_connected_joypads()
	if pads.is_empty():
		return  # sem controle: mantém o último (o jogo pode estar no teclado)
	var id: int = device if pads.has(device) else pads[0]
	detected = from_name(Input.get_joy_name(id))


## Um controle mexeu: se for outro, ele passa a mandar nos desenhos.
## Devolve true se a família mudou (quem chamou avisa a tela para redesenhar).
static func note_device(id: int) -> bool:
	if id == device:
		return false
	device = id
	var before := detected
	refresh()
	return detected != before


# --- Nomes e textos -----------------------------------------------------------------------

## O nome curto do botão de face: "✕", "A", "B", "↓"...
static func face(kind: String) -> String:
	match family():
		"playstation":
			return PS_SYMBOLS.get(kind, kind)
		"xbox", "nintendo":
			return FACE_LETTERS[family()].get(kind, kind)
	return POSITION_ARROWS.get(kind, kind)


## O nome para frases ("○ (Bola) esquiva", "B esquiva", "o botão da direita esquiva").
static func face_long(kind: String) -> String:
	match family():
		"playstation":
			return PS_NAMES.get(kind, kind)
		"xbox", "nintendo":
			return FACE_LETTERS[family()].get(kind, kind)
	return POSITION_NAMES.get(kind, kind)


## "L1" → "LB" (Xbox), "L" (Nintendo)...
static func shoulder(button: String) -> String:
	var table: Dictionary = SHOULDERS.get(family(), {})
	return table.get(button, button)


## Troca os botões dentro de um texto: "{R1}", "{circle}" (curto), "{circle_long}"
## (frase) e o par "L1/R1" escrito solto.
static func text(template: String) -> String:
	var out := template
	for kind in PS_SYMBOLS:
		out = out.replace("{%s_long}" % kind, face_long(kind)).replace("{%s}" % kind, face(kind))
	for button in ["L1", "R1", "L2", "R2"]:
		out = out.replace("{%s}" % button, shoulder(button))
	return out.replace("L1/R1", "%s/%s" % [shoulder("L1"), shoulder("R1")])


# --- Desenho ------------------------------------------------------------------------------

## Desenha um botão de face em qualquer CanvasItem, no estilo do controle ligado.
static func glyph(canvas: CanvasItem, at: Vector2, kind: String, radius: float, alpha: float = 1.0) -> void:
	canvas.draw_circle(at, radius + 1.0, Color(0.05, 0.05, 0.07, alpha * 0.9))
	canvas.draw_arc(at, radius + 1.0, 0.0, TAU, 20, Color(0.75, 0.75, 0.8, alpha * 0.8), 1.0)
	match family():
		"playstation":
			_ps_symbol(canvas, at, kind, radius, alpha)
		"xbox", "nintendo":
			var letter: String = FACE_LETTERS[family()].get(kind, "?")
			var color: Color = FACE_COLORS[family()].get(letter, Color.WHITE)
			var size := maxi(int(radius * 1.5), 6)
			var font := UIStyle.FONT
			var width := font.get_string_size(letter, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
			canvas.draw_string(font, at + Vector2(-width * 0.5, size * 0.38), letter, HORIZONTAL_ALIGNMENT_LEFT, -1, size,
				Color(color, alpha))
		_:
			# Genérico: os 4 pontinhos do losango, aceso o da posição.
			var gap := radius * 0.5
			for other in POSITION_OFFSETS:
				var lit: bool = other == kind
				var point: Vector2 = at + (POSITION_OFFSETS[other] as Vector2) * gap
				canvas.draw_circle(point, radius * (0.32 if lit else 0.18),
					Color(1.0, 0.95, 0.8, alpha) if lit else Color(0.6, 0.6, 0.65, alpha * 0.6))


static func _ps_symbol(canvas: CanvasItem, at: Vector2, kind: String, radius: float, alpha: float) -> void:
	var s := radius * 0.55
	var color := Color(PS_COLORS.get(kind, Color.WHITE), alpha)
	match kind:
		"cross":
			canvas.draw_line(at + Vector2(-s, -s), at + Vector2(s, s), color, 1.4)
			canvas.draw_line(at + Vector2(-s, s), at + Vector2(s, -s), color, 1.4)
		"circle":
			canvas.draw_arc(at, s, 0.0, TAU, 16, color, 1.4)
		"square":
			canvas.draw_rect(Rect2(at - Vector2(s, s) * 0.9, Vector2(s, s) * 1.8), color, false, 1.3)
		"triangle":
			var points := PackedVector2Array([at + Vector2(0, -s), at + Vector2(s, s * 0.75), at + Vector2(-s, s * 0.75), at + Vector2(0, -s)])
			canvas.draw_polyline(points, color, 1.3)
