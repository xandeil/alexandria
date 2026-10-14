class_name TouchJoystick
extends Control
## Joystick virtual "flutuante" (o Godot 4.7 também tem um nó nativo VirtualJoystick;
## este aqui é nosso para você ver como funciona por dentro): nasce onde o polegar toca (lado esquerdo da tela).
## É mais confortável que um joystick fixo em telas de tamanhos variados.
##
## Ele não move ninguém diretamente: só aperta as ações move_* com intensidade
## analógica (Input.action_press(acao, forca)). O herói lê Input.get_vector()
## e nem sabe que o joystick existe — desacoplamento.

@export var max_radius := 28.0
@export var deadzone := 0.18
## Fração da largura da tela que aceita o toque do joystick.
@export_range(0.2, 0.7) var zone_width := 0.45

var _touch_index := -1
var _origin := Vector2.ZERO
var _knob := Vector2.ZERO
var _output := Vector2.ZERO
var rest_position := Vector2(56, 214)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_origin = rest_position


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		var zone := get_viewport_rect().size.x * zone_width
		if touch.pressed and _touch_index == -1 and touch.position.x < zone and touch.position.y > 40.0:
			_touch_index = touch.index
			_origin = touch.position
			_update_knob(touch.position)
			get_viewport().set_input_as_handled()
		elif not touch.pressed and touch.index == _touch_index:
			_reset()
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.index == _touch_index:
			_update_knob(drag.position)
			get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	# Mesmo motivo do TouchButton: pausado, o "soltar" do dedo nunca chegaria.
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_PAUSED, \
		NOTIFICATION_EXIT_TREE, NOTIFICATION_VISIBILITY_CHANGED:
			release()


## Larga o joystick: zera o movimento e volta o desenho para o lugar de repouso.
func release() -> void:
	_reset()


func _update_knob(point: Vector2) -> void:
	_knob = (point - _origin).limit_length(max_radius)
	var output := _knob / max_radius
	if output.length() < deadzone:
		output = Vector2.ZERO
	_apply(output)
	queue_redraw()


func _reset() -> void:
	_touch_index = -1
	_knob = Vector2.ZERO
	_origin = rest_position
	_apply(Vector2.ZERO)
	queue_redraw()


func _apply(value: Vector2) -> void:
	if value == _output:
		return
	_output = value
	_set_strength(&"move_right", maxf(value.x, 0.0))
	_set_strength(&"move_left", maxf(-value.x, 0.0))
	_set_strength(&"move_down", maxf(value.y, 0.0))
	_set_strength(&"move_up", maxf(-value.y, 0.0))


func _set_strength(action: StringName, strength: float) -> void:
	if strength > 0.0:
		Input.action_press(action, strength)
	else:
		Input.action_release(action)


func _draw() -> void:
	var active := _touch_index != -1
	var alpha := 1.0 if active else 0.5
	draw_circle(_origin, max_radius, Color(0.06, 0.05, 0.08, 0.35 * alpha))
	draw_arc(_origin, max_radius, 0.0, TAU, 40, Color(1, 1, 1, 0.3 * alpha), 1.5)
	draw_circle(_origin + _knob, max_radius * 0.42, Color(0.9, 0.9, 0.95, 0.45 * alpha))
	draw_arc(_origin + _knob, max_radius * 0.42, 0.0, TAU, 24, Color(1, 1, 1, 0.5 * alpha), 1.0)
