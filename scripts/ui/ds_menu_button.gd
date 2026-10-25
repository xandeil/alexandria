class_name DSMenuButton
extends Button
## Item de menu no estilo dos soulslike (Dark Souls / Lies of P):
## só o texto, sem caixa; ao focar (controle/teclado) ou passar o mouse, o texto
## clareia e uma faixa de luz suave aparece ATRÁS dele, sumindo nas pontas.
##
## Foco e mouse são a mesma coisa: passar o mouse FOCA o botão. Assim existe um
## só "item selecionado" — não um para o mouse e outro para o controle.

const DIM := Color(0.62, 0.6, 0.58)
const LIT := Color(0.98, 0.96, 0.92)

var _glow: TextureRect
var _tween: Tween


static func make(label: String, size: int = 12, font: Font = UIStyle.TITLE_FONT) -> DSMenuButton:
	var button := DSMenuButton.new()
	button.text = label
	button.add_theme_font_override("font", font)
	button.add_theme_font_size_override("font_size", size)
	return button


func _ready() -> void:
	flat = true
	alignment = HORIZONTAL_ALIGNMENT_CENTER
	focus_mode = Control.FOCUS_ALL
	custom_minimum_size = Vector2(0, 22)
	for state in ["normal", "hover", "pressed", "focus", "disabled", "hover_pressed"]:
		add_theme_stylebox_override(state, StyleBoxEmpty.new())
	add_theme_color_override("font_color", DIM)
	add_theme_color_override("font_hover_color", LIT)
	add_theme_color_override("font_focus_color", LIT)
	add_theme_color_override("font_pressed_color", Color(1.0, 0.92, 0.75))
	add_theme_color_override("font_hover_pressed_color", Color(1.0, 0.92, 0.75))
	add_theme_color_override("font_disabled_color", DIM * Color(1, 1, 1, 0.4))
	add_theme_color_override("font_outline_color", Color(0, 0, 0))
	add_theme_constant_override("outline_size", 2)
	_glow = TextureRect.new()
	_glow.texture = _glow_texture()
	_glow.stretch_mode = TextureRect.STRETCH_SCALE
	_glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	_glow.offset_left = -30
	_glow.offset_right = 30
	_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_glow.show_behind_parent = true  # a luz fica ATRÁS do texto
	_glow.modulate.a = 0.0
	add_child(_glow)
	focus_entered.connect(func(): _light(true))
	focus_exited.connect(func(): _light(false))
	mouse_entered.connect(func():
		if not disabled:
			grab_focus())


func _light(on: bool) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)  # funciona com o jogo pausado
	_tween.tween_property(_glow, "modulate:a", 1.0 if on else 0.0, 0.18 if on else 0.3)
	if on:
		Sfx.play(&"ui_click", -18.0, 0.02)


## Faixa horizontal: transparente nas pontas, luz suave no meio.
static func _glow_texture() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.3, 0.5, 0.7, 1.0])
	gradient.colors = PackedColorArray([
		Color(1, 0.95, 0.85, 0.0), Color(1, 0.95, 0.85, 0.12), Color(1, 0.95, 0.85, 0.2),
		Color(1, 0.95, 0.85, 0.12), Color(1, 0.95, 0.85, 0.0)])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 128
	texture.height = 8
	return texture
