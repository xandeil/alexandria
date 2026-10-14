class_name UIStyle
## Fontes, cores e caixas da interface num lugar só (DRY).
## Toda a UI é montada por código para o projeto ficar 100% em texto.

const FONT := preload("res://assets/fonts/PixelifySans-Regular.woff2")
const FONT_BOLD := preload("res://assets/fonts/PixelifySans-SemiBold.woff2")
const TITLE_FONT := preload("res://assets/fonts/Cinzel-Bold.woff2")
## Números (memórias, custos, frascos): na Pixelify o "5" parece "S"; a Tiny5 é clara.
const FONT_NUMBERS := preload("res://assets/fonts/Tiny5-Regular.woff2")

const TEXT := Color(0.92, 0.9, 0.86)
const TEXT_DIM := Color(0.62, 0.6, 0.58)
const GOLD := Color(0.86, 0.72, 0.42)
const CRIMSON := Color(0.72, 0.16, 0.2)
const PANEL_BG := Color(0.06, 0.05, 0.08, 0.92)
const PANEL_BORDER := Color(0.42, 0.37, 0.45)


static func panel_style(bg: Color = PANEL_BG, border: Color = PANEL_BORDER) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(1)
	box.set_corner_radius_all(2)
	box.content_margin_left = 8
	box.content_margin_right = 8
	box.content_margin_top = 6
	box.content_margin_bottom = 6
	return box


static func label(text: String, size: int = 10, color: Color = TEXT, font: Font = FONT) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", font)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0.03, 0.02, 0.04))
	l.add_theme_constant_override("outline_size", 3)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


static func button(text: String, size: int = 10) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_override("font", FONT_BOLD)
	b.add_theme_font_size_override("font_size", size)
	b.add_theme_color_override("font_color", TEXT)
	b.add_theme_color_override("font_hover_color", GOLD)
	b.add_theme_color_override("font_pressed_color", GOLD)
	b.add_theme_color_override("font_disabled_color", TEXT_DIM * Color(1, 1, 1, 0.6))
	b.add_theme_stylebox_override("normal", panel_style(Color(0.1, 0.09, 0.12, 0.95)))
	b.add_theme_stylebox_override("hover", panel_style(Color(0.16, 0.13, 0.17, 0.95), GOLD))
	b.add_theme_stylebox_override("pressed", panel_style(Color(0.2, 0.15, 0.12, 0.95), GOLD))
	b.add_theme_stylebox_override("disabled", panel_style(Color(0.08, 0.07, 0.09, 0.8), Color(0.25, 0.23, 0.27)))
	# Foco visível (moldura dourada) para jogar os menus no teclado ou no controle.
	var focus := StyleBoxFlat.new()
	focus.draw_center = false
	focus.border_color = GOLD
	focus.set_border_width_all(1)
	focus.set_corner_radius_all(2)
	b.add_theme_stylebox_override("focus", focus)
	b.custom_minimum_size = Vector2(0, 20)
	b.focus_mode = Control.FOCUS_ALL
	return b


## Dá o foco ao primeiro botão habilitado da lista (ou ao `fallback`).
static func focus_first(buttons: Array, fallback: Control = null) -> void:
	for node in buttons:
		var button := node as BaseButton
		if button and button.is_visible_in_tree() and not button.disabled:
			button.grab_focus()
			return
	if fallback:
		fallback.grab_focus()
