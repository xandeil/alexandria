class_name StepperRow
extends HBoxContainer
## Uma linha "Nome  ‹ valor ›" que funciona IGUAL no toque, no mouse e no controle.
##
## O defeito (feedback do teste, v0.30.2): as duas setas eram dois botões
## focáveis. No controle, ← / → MOVIAM O FOCO entre elas (e, na ponta, o Godot
## procurava "o botão mais perto à direita" — que podia estar em cima ou embaixo).
## O jogador apertava → para trocar o cabelo e o cursor pulava para outra linha.
##
## A regra agora (como nos soulslike):
##   • a LINHA é uma parada só do controle (o "›" segura o foco);
##   • ← / → TROCAM O VALOR (não andam o foco);  ↑ / ↓ trocam de linha;
##   • ✕ / Enter também avançam (+1);
##   • no toque e no mouse, cada seta continua sendo um botão normal.
## Um componente só para a criação de personagem e para as Opções (DRY).

signal stepped(direction: int)

var minus: DSMenuButton
var plus: DSMenuButton
var value_label: Label
## Para onde o analógico está inclinado (-1, 0, 1). O analógico manda um evento
## a cada tremidinha: só conta quando ele SAI do centro, não enquanto fica lá.
var _stick_dir := 0


static func make(title: String, title_width: float, value_width: float, value_size: int = 10,
		value_font: Font = UIStyle.TITLE_FONT, extra: Control = null) -> StepperRow:
	var row := StepperRow.new()
	row.add_theme_constant_override("separation", 4)
	var name_label := UIStyle.label(title, 10, Color(0.8, 0.78, 0.74))
	name_label.custom_minimum_size = Vector2(title_width, 0)
	row.add_child(name_label)
	row.minus = DSMenuButton.make("‹", 14)
	row.minus.custom_minimum_size = Vector2(24, 0)
	row.add_child(row.minus)
	row.value_label = UIStyle.label("", value_size, UIStyle.GOLD, value_font)
	row.value_label.custom_minimum_size = Vector2(value_width, 0)
	row.value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.value_label.clip_text = true
	row.add_child(row.value_label)
	if extra:
		row.add_child(extra)
	row.plus = DSMenuButton.make("›", 14)
	row.plus.custom_minimum_size = Vector2(24, 0)
	row.add_child(row.plus)
	# O "‹" não é parada do controle; o mouse em cima dele acende a linha.
	row.minus.focus_mode = Control.FOCUS_NONE
	row.minus.focus_proxy = row.plus
	row.minus.pressed.connect(func(): row.stepped.emit(-1))
	row.plus.pressed.connect(func(): row.stepped.emit(1))
	row.plus.gui_input.connect(row._on_focus_input)
	row.plus.focus_entered.connect(func(): row.minus.light(true))
	row.plus.focus_exited.connect(func(): row.minus.light(false))
	return row


## O item que recebe o foco (para quem monta a navegação ↑/↓ do menu).
func focus_target() -> Control:
	return plus


## ← / → chegam AQUI antes de o Godot mover o foco; aceitar o evento impede o pulo.
func _on_focus_input(event: InputEvent) -> void:
	var motion := event as InputEventJoypadMotion
	if motion and motion.axis == JOY_AXIS_LEFT_X:
		var direction := 0 if absf(motion.axis_value) < 0.5 else signi(int(signf(motion.axis_value)))
		if direction != 0:
			plus.accept_event()
		if direction != _stick_dir and direction != 0:
			stepped.emit(direction)
		_stick_dir = direction
		return
	if event.is_action_pressed(&"ui_left", true):
		plus.accept_event()
		stepped.emit(-1)
	elif event.is_action_pressed(&"ui_right", true):
		plus.accept_event()
		stepped.emit(1)
