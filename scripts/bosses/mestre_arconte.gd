class_name MestreArconte
extends MiniBoss
## O Mestre do Arconte — mini-chefe opcional do Domínio (v0.35, Etapa 6; a
## sala de aula congelada). O professor de Cassian, a primeira pessoa que
## ele guardou.
##
## Fase 1: ele ANUNCIA a lição antes de cada feitiço — ouvir é a defesa.
##   Lição um: o gelo guarda!            → geada no chão em volta de você.
##   Lição dois: o que é guardado não muda! → leque de estilhaços.
##   Lição três...                       → ele esquece. Janela para bater.
## Fase 2 (metade da vida): esquece no meio e solta feitiços sorteados, SEM
## aviso.

enum Mode { DECIDE, LESSON, CAST, FORGET, ATTACK }

const LESSONS := [
	"Lição um: o gelo guarda!",
	"Lição dois: o que é guardado não muda!",
	"Lição três...",
]
const SPEECH_WAKE := "Lição um: o gelo guarda. Lição dois: o que é guardado não muda. Lição três..."
const SPEECH_FORGOT := "...Lição três. Qual era a lição três?"
const SPEECH_DEFEAT := "Ele aprendeu tudo comigo... menos a lição três. ...Soltar."

@export var staff: AttackData
@export var lesson_windup := 1.0
@export var frost_damage := 16.0
@export var lance_damage := 14.0
@export var lance_count := 5
@export var forget_time := 1.6

var mode := Mode.DECIDE
var phase := 1
var lesson := 0
var _mode_time := 0.0
var _decision := 0.0
var _forgot_said := false
var _spell := 0


func _on_wake() -> void:
	speech.emit(SPEECH_WAKE)
	_set_mode(Mode.DECIDE)
	_decision = 1.6


func _set_mode(new_mode: Mode) -> void:
	mode = new_mode
	_mode_time = 0.0


func _fight(delta: float) -> void:
	_mode_time += delta
	if phase == 1 and stats.health_ratio() <= 0.5:
		phase = 2
		phase_changed.emit("Fase 2")
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	if target:
		facing = (target.global_position - global_position).normalized()
	match mode:
		Mode.DECIDE:
			_decision -= delta
			if _decision > 0.0:
				return
			if global_position.distance_to(target.global_position) < 30.0:
				_set_mode(Mode.ATTACK)
				start_attack(staff, facing)
			elif phase == 1:
				announce()
			else:
				cast_spell(randi() % 2, false)  # fase 2: sem aviso
		Mode.LESSON:
			if _mode_time >= lesson_windup:
				if lesson == 2:
					forget()
				else:
					cast_spell(lesson, true)
		Mode.CAST:
			if _mode_time >= 0.6:
				_next_decision()
		Mode.FORGET:
			if _mode_time >= forget_time:
				_next_decision()
		Mode.ATTACK:
			velocity = _runner.step(delta, velocity)


## Fase 1: diz a próxima lição em voz alta (o aviso).
func announce() -> void:
	speech.emit(LESSONS[lesson])
	Sfx.play(&"telegraph", -4.0)
	_set_mode(Mode.LESSON)


func cast_spell(kind: int, warned: bool) -> void:
	_spell = kind
	match kind:
		0:
			for i in 3:
				var at := target.global_position
				if i > 0:
					at += Vector2.from_angle(TAU * i / 3.0 + randf()) * randf_range(36.0, 56.0)
				var zone := FrostZone.spawn(get_parent(), Rect2(at - Vector2(21, 15), Vector2(42, 30)), 0.9 if warned else 0.55, 3.5, 0, self)
				zone.damage = frost_damage
			Sfx.play(&"crystal", -4.0)
		_:
			var aim := (target.global_position - global_position).normalized()
			for i in lance_count:
				var spread := deg_to_rad(12.0) * (i - (lance_count - 1) * 0.5)
				Projectile.launch(get_parent(), global_position + Vector2(0, -14) + aim * 10.0, aim.rotated(spread), self,
					lance_damage, 150.0, 260.0, Projectile.FROST)
			Sfx.play(&"ice_shot", -2.0)
	if phase == 1:
		lesson = (lesson + 1) % LESSONS.size()
	_set_mode(Mode.CAST)


## "Lição três..." — e ele não lembra. Fica parado, pensando: a janela.
func forget() -> void:
	lesson = 0
	if not _forgot_said:
		_forgot_said = true
		speech.emit(SPEECH_FORGOT)
	_set_mode(Mode.FORGET)


func _next_decision() -> void:
	_set_mode(Mode.DECIDE)
	_decision = randf_range(0.5, 0.9) if phase == 1 else randf_range(0.3, 0.6)


func _on_attack_finished() -> void:
	if mode == Mode.ATTACK:
		_next_decision()


func _can_be_staggered() -> bool:
	return mode == Mode.FORGET


func _on_reset() -> void:
	phase = 1
	lesson = 0
	_set_mode(Mode.DECIDE)


func _on_died() -> void:
	_defeat(SPEECH_DEFEAT)


func _after_move(delta: float) -> void:
	update_body_animation(delta)
