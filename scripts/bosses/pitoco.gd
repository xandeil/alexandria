class_name Pitoco
extends MiniBoss
## O Pitoco (v0.52, Etapa 11) — o "cachorro" do Amaro: tentáculos e uma boca
## enorme, no fundo da Toca, embaixo das Raízes. Feliz de ver você. Com fome.
##
##   • pulo de alegria — uma investida longa (abana os tentáculos antes);
##   • "buscar" — um tentáculo agarra de longe e traz você até a boca
##     (Player.grab: toques em Ataque soltam; a boca morde e drena memórias);
##   • lambida — de perto; dói pouco e leva memórias;
##   • rolar no chão — tudo em volta é derrubado.
## Vencido: pitoco_morto (o Amaro vai procurar por ele).

enum Mode { DECIDE, APPROACH, ATTACK, FETCH_WINDUP, FETCH_HOLD }

const FETCH_RANGE := 100.0
const FETCH_WINDUP := 0.7
const FETCH_HOLD := 2.4
const LICK_MEMORY_RATIO := 0.04
const LICK_MEMORY_MIN := 15

@export var pulo: AttackData
@export var lambida: AttackData
@export var rolar: AttackData
@export var fetch_taps := 6
@export var bite_damage_per_second := 9.0

var mode := Mode.DECIDE
var _mode_time := 0.0
var _decision := 0.0
var _fetch_dir := Vector2.RIGHT
var _tentacle: Line2D


func _ready() -> void:
	super._ready()
	_tentacle = Line2D.new()
	_tentacle.width = 3.0
	_tentacle.default_color = Color(0.6, 0.36, 0.5)
	_tentacle.visible = false
	_tentacle.z_index = 4
	add_child(_tentacle)


func _on_wake() -> void:
	_set_mode(Mode.DECIDE)
	_decision = 0.6
	Sfx.play(&"bark", -2.0)


func _set_mode(new_mode: Mode) -> void:
	mode = new_mode
	_mode_time = 0.0


func _fight(delta: float) -> void:
	_mode_time += delta
	match mode:
		Mode.DECIDE:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
			var to_target := target.global_position - global_position
			facing = to_target.normalized()
			_decision -= delta
			if _decision > 0.0:
				return
			_choose(to_target.length())
		Mode.APPROACH:
			var to_target := target.global_position - global_position
			facing = to_target.normalized()
			velocity = velocity.move_toward(facing * move_speed, acceleration * delta)
			if to_target.length() < 34.0 or _mode_time > 1.4:
				_set_mode(Mode.DECIDE)
		Mode.ATTACK:
			track_target_during_windup()
			velocity = _runner.step(delta, velocity)
		Mode.FETCH_WINDUP:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
			body_sprite.modulate = Color(1.5, 1.1, 1.3) if int(_mode_time * 12.0) % 2 == 0 else Color.WHITE
			if _mode_time >= FETCH_WINDUP:
				body_sprite.modulate = Color.WHITE
				_throw_tentacle()
		Mode.FETCH_HOLD:
			velocity = Vector2.ZERO
			_tentacle.points = PackedVector2Array([Vector2(0, -10), target.global_position - global_position + Vector2(0, -8)])
			if not target.is_grabbed_by(self) or _mode_time >= FETCH_HOLD:
				if target.is_grabbed_by(self):
					target.release_grab()
				_tentacle.visible = false
				_set_mode(Mode.DECIDE)
				_decision = 0.8


func _choose(distance: float) -> void:
	if distance < 34.0:
		_attack(rolar if randf() < 0.35 else lambida)
	elif distance < FETCH_RANGE and randf() < 0.45:
		_fetch_dir = (target.global_position - global_position).normalized()
		_set_mode(Mode.FETCH_WINDUP)
		Sfx.play(&"telegraph", -4.0)
	elif distance < 150.0:
		_attack(pulo)
	else:
		_set_mode(Mode.APPROACH)


func _attack(data: AttackData) -> void:
	_set_mode(Mode.ATTACK)
	start_attack(data, facing)


## "Buscar": o tentáculo sai reto; pegou, traz até a boca.
func _throw_tentacle() -> void:
	_tentacle.visible = true
	var reach := _fetch_dir * FETCH_RANGE
	_tentacle.points = PackedVector2Array([Vector2(0, -10), reach + Vector2(0, -8)])
	var to_target := target.global_position - global_position
	var along := to_target.dot(_fetch_dir)
	var off_line := absf(to_target.cross(_fetch_dir))
	if along > 0.0 and along <= FETCH_RANGE and off_line < 18.0 \
			and target.grab(self, fetch_taps, Vector2(facing.x * 14.0, 4.0), bite_damage_per_second, 0.01, 4):
		Sfx.play(&"chomp", 0.0)
		_set_mode(Mode.FETCH_HOLD)
		return
	var fade := _tentacle.create_tween()
	fade.tween_interval(0.25)
	fade.tween_callback(func(): _tentacle.visible = false)
	_set_mode(Mode.DECIDE)
	_decision = 0.5


func _on_attack_finished() -> void:
	if mode != Mode.ATTACK:
		return
	# A lambida leva memórias de quem estava perto.
	if _current_attack == lambida and target and target.global_position.distance_to(global_position) < 36.0:
		var lost := Game.drain_memories(LICK_MEMORY_RATIO, LICK_MEMORY_MIN)
		if lost > 0:
			Fx.float_text(target.global_position + Vector2(-10, -26), "-%d" % lost, Color(0.85, 0.75, 1.0), 8)
	_set_mode(Mode.DECIDE)
	_decision = randf_range(0.4, 0.8)


func _on_damaged(_amount: float, _info: HitInfo, _blocked: bool) -> void:
	if mode == Mode.FETCH_HOLD and target and target.is_grabbed_by(self) and randf() < 0.25:
		target.release_grab()  # apanhou: às vezes larga


func _on_reset() -> void:
	if target and target.is_grabbed_by(self):
		target.release_grab()
	_tentacle.visible = false
	_set_mode(Mode.DECIDE)


func _on_died() -> void:
	if target and target.is_grabbed_by(self):
		target.release_grab()
	_tentacle.visible = false
	Game.set_flag("pitoco_morto")
	_defeat()
