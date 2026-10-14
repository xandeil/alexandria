extends CanvasLayer
## Autoload "Fader": escurece a tela nas transições (troca de área, morte, descanso).
## As elevações e túneis entre ilhas da Bíblia também servirão para esconder
## carregamento — este fade é a versão mínima disso.
##
## Cuidado clássico com corrotinas: um Tween "morto" (kill) NUNCA emite
## `finished`. Se alguém estiver esperando por ele, espera para sempre — e a
## troca de cena trava. Por isso todo fade termina pelo nosso próprio sinal
## `_fade_finished`, que também é emitido quando um fade novo substitui o antigo.

signal faded_out
signal faded_in
signal _fade_finished

## true durante uma troca de cena: nesse tempo o Fader é o "dono" da tela e
## pedidos de fade_in/fade_out de fora são ignorados (não podem atrapalhar a troca).
var busy := false
var _rect: ColorRect
var _tween: Tween


func _ready() -> void:
	layer = 128
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rect = ColorRect.new()
	_rect.color = Color(0.03, 0.025, 0.04, 0.0)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_rect)


func fade_out(duration: float = 0.35) -> void:
	if busy:
		return
	await _fade_to(1.0, duration)
	faded_out.emit()


func fade_in(duration: float = 0.35) -> void:
	if busy:
		return
	await _fade_to(0.0, duration)
	faded_in.emit()


func is_black() -> bool:
	return _rect.color.a >= 0.99


func change_scene(path: String, duration: float = 0.4) -> void:
	if busy:
		return
	busy = true
	_rect.mouse_filter = Control.MOUSE_FILTER_STOP  # bloqueia toques durante o fade
	await _fade_to(1.0, duration)
	get_tree().paused = false
	Fx.clear_time_effects()
	var error := get_tree().change_scene_to_file(path)
	if error != OK:
		push_error("Falha ao abrir a cena %s: %s" % [path, error_string(error)])
	await get_tree().process_frame
	await get_tree().process_frame
	await _fade_to(0.0, duration)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	busy = false


func _fade_to(alpha: float, duration: float) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	# Libera quem esperava o fade anterior (o tween morto não vai avisar ninguém).
	_fade_finished.emit()
	_tween = create_tween()
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween.set_ignore_time_scale(true)
	_tween.tween_property(_rect, "color:a", alpha, maxf(duration, 0.01))
	_tween.finished.connect(func(): _fade_finished.emit())
	await _fade_finished
