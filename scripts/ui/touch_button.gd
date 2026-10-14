class_name TouchButton
extends Control
## Botão circular de toque que "aperta" uma ação do InputMap.
## Componente reutilizável — a mesma ideia dos seus componentes React:
## configura por propriedades (action, icon, radius) e pronto.
##
## Multitoque: guardamos o índice do dedo (event.index). Assim o polegar
## esquerdo segura o joystick enquanto o direito ataca.

@export var action: StringName = &""
@export var icon: Texture2D
@export var radius := 22.0
@export var label_text := ""
@export var badge := -1  ## número no canto (frascos restantes); -1 = escondido
@export var dimmed := false
@export var accent := Color(1, 1, 1)

var _touch_index := -1
var _press_glow := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2.ONE * radius * 2.0
	size = custom_minimum_size


## Posiciona pelo CENTRO (mais intuitivo para círculos).
func place_at(center: Vector2) -> void:
	position = center - Vector2.ONE * radius


func is_held() -> bool:
	return _touch_index != -1


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	var touch := event as InputEventScreenTouch
	if touch == null:
		return
	if touch.pressed and _touch_index == -1 and _contains(touch.position):
		_touch_index = touch.index
		_press_glow = 1.0
		Input.action_press(action)
		get_viewport().set_input_as_handled()
		queue_redraw()
	elif not touch.pressed and touch.index == _touch_index:
		release()


func _notification(what: int) -> void:
	# Solta o botão sempre que o dedo pode "sumir" sem avisar:
	#  • app em segundo plano (FOCUS_OUT / APPLICATION_PAUSED);
	#  • jogo pausado (PAUSED): com a árvore pausada este nó não recebe _input,
	#    então o "soltar" do dedo se perderia e o herói voltaria atacando sozinho;
	#  • botão escondido ou removido.
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_PAUSED, \
		NOTIFICATION_EXIT_TREE, NOTIFICATION_VISIBILITY_CHANGED:
			release()


## Solta o botão (e a ação do InputMap) se estiver apertado.
func release() -> void:
	if _touch_index == -1:
		return
	_touch_index = -1
	Input.action_release(action)
	queue_redraw()


func _contains(point: Vector2) -> bool:
	# Área de toque 20% maior que o desenho: dedos são imprecisos.
	return point.distance_to(global_position + size * 0.5) <= radius * 1.2


func _process(delta: float) -> void:
	if _press_glow > 0.0:
		_press_glow = maxf(_press_glow - delta * 4.0, 0.0)
		queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	var alpha := 0.35 if dimmed else 1.0
	var fill := Color(0.06, 0.05, 0.08, 0.45 * alpha)
	if is_held():
		fill = Color(accent.r, accent.g, accent.b, 0.35)
	draw_circle(center, radius, fill)
	draw_arc(center, radius, 0.0, TAU, 40, Color(1, 1, 1, (0.35 + 0.4 * _press_glow) * alpha), 1.5)
	if icon:
		var icon_size := Vector2.ONE * minf(radius * 1.15, 32.0)
		draw_texture_rect(icon, Rect2(center - icon_size * 0.5 - Vector2(0, 2 if label_text != "" else 0), icon_size), false, Color(1, 1, 1, alpha))
	if label_text != "":
		# O texto pode ser mais largo que o botão ("Descansar"): centraliza numa faixa larga.
		var band := radius * 4.0
		draw_string(UIStyle.FONT_BOLD, Vector2(center.x - band * 0.5, center.y + radius * 0.62), label_text, HORIZONTAL_ALIGNMENT_CENTER, band, 7, Color(1, 1, 1, 0.95 * alpha))
	if badge >= 0:
		var badge_pos := center + Vector2(radius * 0.72, -radius * 0.72)
		draw_circle(badge_pos, 6.0, Color(0.1, 0.08, 0.1, 0.95))
		draw_arc(badge_pos, 6.0, 0.0, TAU, 16, Color(1, 1, 1, 0.5), 1.0)
		draw_string(UIStyle.FONT_NUMBERS, badge_pos + Vector2(-6, 3), str(badge), HORIZONTAL_ALIGNMENT_CENTER, 12, 8, Color.WHITE)
