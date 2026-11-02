class_name UltimoIgual
extends MiniBoss
## O Último Igual — mini-chefe opcional da Montanha (v0.35, Etapa 6; Fosso das
## Correntes). Um dragão velho que a Rachel deixou acorrentado.
##
## Fase 1: a CORRENTE manda. Ele só alcança o raio dela (o círculo no chão
## mostra até onde): fora dele você está seguro — e ele sabe disso.
## Fase 2 (metade da vida): a corrente arrebenta. Agora ele vai aonde quiser.

enum Mode { DECIDE, APPROACH, ATTACK }

const SPEECH_WAKE := "Ela me deixou vivo. Foi o pior que ela me fez."
const SPEECH_DEFEAT := "...Agora eu olho pra baixo. Que alívio."

@export var mordida: AttackData
@export var investida: AttackData
## Até onde a corrente deixa ele ir (px, a partir do posto).
@export var chain_radius := 110.0

var mode := Mode.DECIDE
var chained := true
var _mode_time := 0.0
var _decision := 0.0
var _combo: Array[AttackData] = []
var _time := 0.0


func _on_wake() -> void:
	speech.emit(SPEECH_WAKE)
	Sfx.play(&"roar", -4.0)
	_set_mode(Mode.DECIDE)
	_decision = 0.8


func _set_mode(new_mode: Mode) -> void:
	mode = new_mode
	_mode_time = 0.0


func _fight(delta: float) -> void:
	_mode_time += delta
	if chained and stats.health_ratio() <= 0.5:
		break_chain()
	match mode:
		Mode.DECIDE:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
			var to_target := target.global_position - global_position
			facing = to_target.normalized()
			_decision -= delta
			if _decision > 0.0:
				return
			var distance := to_target.length()
			if distance < 34.0:
				_queue([mordida, mordida] if randf() < 0.4 else [mordida])
			elif distance < 120.0 and randf() < 0.5:
				_queue([investida])
			else:
				_set_mode(Mode.APPROACH)
		Mode.APPROACH:
			var to_target := target.global_position - global_position
			facing = to_target.normalized()
			velocity = velocity.move_toward(facing * move_speed, acceleration * delta)
			if to_target.length() < 30.0 or _mode_time > 1.4:
				_set_mode(Mode.DECIDE)
		Mode.ATTACK:
			track_target_during_windup()
			velocity = _runner.step(delta, velocity)


func _queue(attacks: Array) -> void:
	_combo.assign(attacks)
	_next()


func _next() -> void:
	if _combo.is_empty():
		_set_mode(Mode.DECIDE)
		_decision = randf_range(0.5, 0.9) if chained else randf_range(0.3, 0.6)
		return
	var attack: AttackData = _combo.pop_front()
	_set_mode(Mode.ATTACK)
	start_attack(attack, (target.global_position - global_position).normalized())


func _on_attack_finished() -> void:
	if mode == Mode.ATTACK:
		_next()


## A corrente arrebenta (fase 2): sem limite, e mais rápido.
func break_chain() -> void:
	chained = false
	phase_changed.emit("Fase 2")
	move_speed *= 1.35
	Sfx.play(&"crumble", 2.0)
	Sfx.play(&"clang", 0.0)
	Fx.shake(5.0, 0.6)
	Fx.sparks(global_position + Vector2(0, -10), Vector2.UP, Color(0.85, 0.85, 0.9), 16, 90.0)
	queue_redraw()


## Preso, ele não passa do raio da corrente (nem numa investida).
func clamp_to_chain() -> void:
	if not chained:
		return
	var from_home := global_position - home_position
	if from_home.length() > chain_radius:
		global_position = home_position + from_home.normalized() * chain_radius
		velocity = Vector2.ZERO


func _on_reset() -> void:
	_combo.clear()
	_set_mode(Mode.DECIDE)


func _on_died() -> void:
	_defeat(SPEECH_DEFEAT)


func _after_move(delta: float) -> void:
	clamp_to_chain()
	_time += delta
	update_body_animation(delta)
	queue_redraw()


## A corrente: do posto até o pescoço, e o círculo de até onde ela chega.
func _draw() -> void:
	if not chained or dead:
		return
	var anchor := home_position - global_position
	var neck := Vector2(0, -10)
	var links := 10
	for i in links + 1:
		var t := float(i) / links
		var sag := sin(t * PI) * 6.0
		draw_circle(anchor.lerp(neck, t) + Vector2(0, sag), 1.6, Color(0.55, 0.55, 0.6))
	draw_arc(anchor, chain_radius, 0.0, TAU, 48, Color(0.75, 0.75, 0.8, 0.25), 1.0)
