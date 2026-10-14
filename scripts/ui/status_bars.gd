class_name StatusBars
extends Control
## Barras de Vida e Estamina desenhadas por código.
##   • Largura cresce com o máximo (subir Vitalidade/Fôlego "aumenta a barra", como nos Souls).
##   • "Rastro" claro mostra o dano recebido e some devagar.
##   • Exausto: a estamina pisca em vermelho e aparece "EXAUSTO".
##   • Sonolência (Bosque): uma barra lilás fina, só aparece quando sobe.

const HP_FILL := Color(0.66, 0.14, 0.18)
const HP_TRAIL := Color(0.95, 0.85, 0.7)
const ST_FILL := Color(0.48, 0.66, 0.36)
const ST_EXHAUSTED := Color(0.9, 0.36, 0.2)
const BACK := Color(0.05, 0.04, 0.06, 0.85)
const BORDER := Color(0.55, 0.5, 0.52)
const SLEEP_FILL := Color(0.67, 0.59, 0.87)

var hp := 100.0
var hp_max := 100.0
var hp_trail := 100.0
var st := 100.0
var st_max := 100.0
var exhausted := false
var sleep := 0.0
var sleep_max := 100.0
var asleep := false

var _trail_delay := 0.0
var _deny_flash := 0.0
var _time := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(210, 20)


func set_health(current: float, maximum: float) -> void:
	if current < hp:
		_trail_delay = 0.5
	else:
		hp_trail = maxf(hp_trail, current)
	hp = current
	hp_max = maximum
	queue_redraw()


func set_stamina(current: float, maximum: float) -> void:
	st = current
	st_max = maximum
	queue_redraw()


func set_drowsiness(current: float, maximum: float) -> void:
	sleep = current
	sleep_max = maximum
	queue_redraw()


func set_asleep(value: bool) -> void:
	asleep = value
	queue_redraw()


func set_exhausted(value: bool) -> void:
	exhausted = value
	queue_redraw()


## O herói tentou agir sem estamina: a barra pisca.
func flash_denied() -> void:
	_deny_flash = 0.35


func _process(delta: float) -> void:
	_time += delta
	if _trail_delay > 0.0:
		_trail_delay -= delta
	elif hp_trail > hp:
		hp_trail = move_toward(hp_trail, hp, hp_max * 0.6 * delta)
	_deny_flash = maxf(_deny_flash - delta, 0.0)
	queue_redraw()


func _bar_width(maximum: float) -> float:
	return clampf(30.0 + maximum * 0.6, 60.0, 180.0)


func _draw() -> void:
	var hp_w := _bar_width(hp_max)
	_draw_bar(Rect2(0, 0, hp_w, 6), hp / hp_max, hp_trail / hp_max, HP_FILL)
	var st_w := _bar_width(st_max)
	var st_color := ST_FILL
	if exhausted:
		st_color = ST_EXHAUSTED if fmod(_time, 0.5) < 0.3 else ST_EXHAUSTED.darkened(0.4)
	if _deny_flash > 0.0:
		st_color = st_color.lerp(Color.WHITE, _deny_flash / 0.35)
	_draw_bar(Rect2(0, 9, st_w, 4), st / st_max, 0.0, st_color)
	if exhausted:
		draw_string(UIStyle.FONT_BOLD, Vector2(st_w + 4, 15), "EXAUSTO", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, ST_EXHAUSTED)
	if sleep > 0.5 or asleep:
		var ratio := 1.0 if asleep else sleep / sleep_max
		var color := SLEEP_FILL
		if ratio > 0.7 and not asleep:  # quase dormindo: pisca
			color = SLEEP_FILL.lerp(Color.WHITE, 0.5 if fmod(_time, 0.4) < 0.2 else 0.0)
		_draw_bar(Rect2(0, 15, st_w, 2), ratio, 0.0, color)
		if asleep:
			draw_string(UIStyle.FONT_BOLD, Vector2(st_w + 4, 19), "DORMINDO", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, SLEEP_FILL)


func _draw_bar(rect: Rect2, ratio: float, trail: float, fill: Color) -> void:
	draw_rect(rect.grow(1), BORDER)
	draw_rect(rect, BACK)
	if trail > ratio:
		draw_rect(Rect2(rect.position, Vector2(rect.size.x * clampf(trail, 0, 1), rect.size.y)), HP_TRAIL)
	draw_rect(Rect2(rect.position, Vector2(rect.size.x * clampf(ratio, 0, 1), rect.size.y)), fill)
	draw_rect(Rect2(rect.position, Vector2(rect.size.x * clampf(ratio, 0, 1), 1)), fill.lightened(0.3))
