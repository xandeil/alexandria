class_name BossBar
extends Control
## Barra de chefe no estilo Souls: nome + título, vida, armadura e fase.

var boss_name := ""
var boss_title := ""
var phase_text := ""
var ratio := 1.0
var trail := 1.0
var armor := -1.0  ## < 0 = sem barra de armadura

var _trail_delay := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_ratio(value: float) -> void:
	if value < ratio:
		_trail_delay = 0.6
	else:
		trail = maxf(trail, value)
	ratio = value
	queue_redraw()


func _process(delta: float) -> void:
	if _trail_delay > 0.0:
		_trail_delay -= delta
	elif trail > ratio:
		trail = move_toward(trail, ratio, 0.5 * delta)
	queue_redraw()


## Maior tamanho de fonte (entre max e min) em que o texto cabe; -1 se não couber.
func _fit_font_size(text: String, width: float, max_size: int, min_size: int) -> int:
	for font_size in range(max_size, min_size - 1, -1):
		if UIStyle.TITLE_FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x <= width:
			return font_size
	return -1


func _draw() -> void:
	var w := size.x
	var title := boss_name if boss_title.is_empty() else "%s, %s" % [boss_name, boss_title]
	var font_size := _fit_font_size(title, w, 9, 7)
	if font_size < 0:  # nem no menor tamanho: mostra só o nome
		title = boss_name
		font_size = _fit_font_size(title, w, 9, 6)
	draw_string(UIStyle.TITLE_FONT, Vector2(0, 9), title, HORIZONTAL_ALIGNMENT_CENTER, w, maxi(font_size, 6), UIStyle.TEXT)
	if not phase_text.is_empty():
		draw_string(UIStyle.FONT, Vector2(0, 31), phase_text, HORIZONTAL_ALIGNMENT_CENTER, w, 7, UIStyle.GOLD)
	var bar := Rect2(0, 13, w, 5)
	draw_rect(bar.grow(1), Color(0.5, 0.45, 0.45))
	draw_rect(bar, Color(0.05, 0.04, 0.06, 0.9))
	draw_rect(Rect2(bar.position, Vector2(w * clampf(trail, 0, 1), bar.size.y)), Color(0.95, 0.85, 0.7))
	draw_rect(Rect2(bar.position, Vector2(w * clampf(ratio, 0, 1), bar.size.y)), Color(0.62, 0.12, 0.16))
	if armor >= 0.0:
		var armor_bar := Rect2(0, 20, w, 2)
		draw_rect(armor_bar, Color(0.1, 0.1, 0.12, 0.9))
		draw_rect(Rect2(armor_bar.position, Vector2(w * armor, 2)), Color(0.74, 0.78, 0.84))
