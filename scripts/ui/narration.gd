class_name Narration
extends CanvasLayer
## Texto narrado, uma frase por vez: a abertura do jogo, a queda do Prólogo e a
## lembrança da Governanta. Toque na tela (ou Ataque/Confirmar) pula a frase.
##
## Componente REUTILIZÁVEL: antes, a tela de título tinha o próprio código de
## "frase aparece, espera, some". Quando o Prólogo precisou do mesmo efeito,
## em vez de copiar e colar, o código virou esta peça. (DRY: Don't Repeat Yourself.)
##
## Uso (corrotina):
##   var narration := Narration.new()
##   add_child(narration)
##   await narration.play(linhas, Narration.Style.SCREEN)
## O sinal line_started(i) deixa quem chamou sincronizar a cena com cada frase.

signal line_started(index: int)
signal finished

enum Style {
	SCREEN,  ## tela inteira: fundo escuro e texto no centro (abertura, queda)
	SUBTITLE,  ## legenda: o jogo continua visível, texto embaixo (lembranças)
}

## Tempo MÍNIMO de cada frase na tela (segundos reais).
@export var hold_time := 3.2
## v0.30.2: frase longa fica mais tempo — o tempo vem do tamanho do texto
## (cerca de 14 letras por segundo, um ritmo de leitura confortável).
const READ_BASE := 1.5
const READ_CHARS_PER_SECOND := 14.0
@export var fade_time := 0.7

var _backdrop: ColorRect
var _band: ColorRect
var _label: Label
var _skip := false
var _playing := false


func _ready() -> void:
	layer = 50  # acima do HUD, dos botões de toque e do diálogo
	process_mode = Node.PROCESS_MODE_ALWAYS
	_backdrop = ColorRect.new()
	_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	_backdrop.color = Color(0.02, 0.015, 0.03, 0.0)
	_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP  # o toque pula a frase (e não vaza para o jogo)
	_backdrop.gui_input.connect(_on_backdrop_input)
	add_child(_backdrop)
	_band = ColorRect.new()
	_band.color = Color(0.02, 0.015, 0.03, 0.0)
	_band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_band)
	_label = UIStyle.label("", 11, Color(0.92, 0.9, 0.86))
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.modulate.a = 0.0
	add_child(_label)


func is_playing() -> bool:
	return _playing


## Mostra as frases em sequência. backdrop: cor do fundo no estilo SCREEN
## (alfa 0 = sem fundo, como na tela de título, que escurece o mapa sozinha).
func play(lines: Array, style: Style = Style.SCREEN, backdrop: Color = Color(0.02, 0.015, 0.03, 1.0)) -> void:
	_playing = true
	_layout(style)
	if style == Style.SCREEN and backdrop.a > 0.0:
		var dark := create_tween()
		dark.tween_property(_backdrop, "color", backdrop, 0.6)
		await dark.finished
	elif style == Style.SUBTITLE:
		create_tween().tween_property(_band, "color:a", 0.55, 0.4)
	for i in lines.size():
		_skip = false
		_label.text = str(lines[i])
		line_started.emit(i)
		var fade_in := create_tween()
		fade_in.tween_property(_label, "modulate:a", 1.0, fade_time)
		var start := Time.get_ticks_msec()
		# Tempo REAL: câmera lenta (Engine.time_scale) não estica a leitura.
		var hold := reading_time(_label.text)
		while (Time.get_ticks_msec() - start) < int(hold * 1000.0) and not _skip:
			await get_tree().process_frame
		var fade_out := create_tween()
		fade_out.tween_property(_label, "modulate:a", 0.0, fade_time * 0.6)
		await fade_out.finished
	if style == Style.SUBTITLE:
		var band_out := create_tween()
		band_out.tween_property(_band, "color:a", 0.0, 0.3)
		await band_out.finished
	_playing = false
	finished.emit()


## Quanto tempo uma frase fica na tela: nunca menos que hold_time.
func reading_time(text: String) -> float:
	return maxf(hold_time, READ_BASE + text.length() / READ_CHARS_PER_SECOND)


## Pula a frase atual (toque, Ataque ou Confirmar; os testes também usam).
func skip() -> void:
	_skip = true


func _layout(style: Style) -> void:
	var view := get_viewport().get_visible_rect().size
	if style == Style.SCREEN:
		_label.position = Vector2(view.x * 0.5 - 190.0, view.y * 0.5 - 40.0)
		_label.size = Vector2(380, 80)
		_label.add_theme_font_size_override("font_size", 11)
		_band.size = Vector2.ZERO
	else:
		_backdrop.color.a = 0.0
		_band.position = Vector2(0, view.y - 50.0)
		_band.size = Vector2(view.x, 42)
		_label.position = Vector2(view.x * 0.5 - 200.0, view.y - 48.0)
		_label.size = Vector2(400, 38)
		_label.add_theme_font_size_override("font_size", 10)


func _on_backdrop_input(event: InputEvent) -> void:
	var mouse := event as InputEventMouseButton
	if _playing and mouse and mouse.pressed:
		skip()


func _unhandled_input(event: InputEvent) -> void:
	if _playing and (event.is_action_pressed(&"ui_accept") or event.is_action_pressed(&"attack")):
		skip()
		get_viewport().set_input_as_handled()
