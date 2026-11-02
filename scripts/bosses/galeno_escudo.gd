class_name GalenoEscudo
extends MiniBoss
## Galeno, O Escudo Que Chegou Tarde (v0.48, Etapa 9) — só com tito_morto.
## Depois do último fragmento, ele espera diante da cápsula do Teatro. Você
## escolhe o que dizer; depois, a luta. Vida 850.
##
##   Fase 1 (com escudo): batida de escudo, giro da espada curva, investida.
##     O escudo segura de frente (dano de frente reduzido).
##   Fase 2 (≤ 50%): joga o escudo fora — "Não tem mais nada atrás de mim." —
##     combos longos (3 golpes), salto com golpe de cima, e SEM defesa.
## Vencido: galeno_morto; recompensa, o Escudo Sem Dono.

enum Mode { DECIDE, APPROACH, ATTACK, THROW }

const SHIELDLESS := preload("res://assets/sprites/galeno_sem_escudo_frames.tres")
const SHIELD_PROP := preload("res://assets/props/escudo_jogado.png")
const SPEECH_START := "Fica atrás de mim, eu dizia! ATRÁS DE MIM!"
const SPEECH_PHASE_2 := "Não tem mais nada atrás de mim."
const SPEECH_MID := "Eu rindo por essas ilhas! RINDO! E ele lá, no chão!"
const SPEECH_DEFEAT := ["...Tito. O pai chegou.", "...Demorei, né?", "Fica com o escudo. Não tem mais nada pra proteger."]
## De frente, com o escudo, só isto do golpe entra.
const SHIELD_RATIO := 0.35

@export var batida: AttackData
@export var giro: AttackData
@export var investida: AttackData
@export var corte: AttackData
@export var salto: AttackData

var mode := Mode.DECIDE
var phase := 1
var _mode_time := 0.0
var _decision := 0.0
var _combo_left := 0
var _said_mid := false


func phase_label() -> String:
	return "Fase 1 — O Escudo" if phase == 1 else "Fase 2 — Sem Nada Atrás"


func _on_wake() -> void:
	speech.emit(SPEECH_START)
	_set_mode(Mode.DECIDE)
	_decision = 0.6


func _set_mode(new_mode: Mode) -> void:
	mode = new_mode
	_mode_time = 0.0


## Com o escudo, de frente, quase nada entra. Sem escudo, entra tudo.
func _incoming_damage_multiplier(info: HitInfo) -> float:
	if phase == 1 and info:
		var from := info.source_position - global_position
		if from != Vector2.ZERO and from.normalized().dot(facing) > 0.3:
			return SHIELD_RATIO
	return 1.0


func _fight(delta: float) -> void:
	_mode_time += delta
	if phase == 1 and stats.health <= stats.max_health * 0.5:
		_throw_shield()
		return
	if phase == 2 and not _said_mid and stats.health <= stats.max_health * 0.25:
		_said_mid = true
		speech.emit(SPEECH_MID)
	match mode:
		Mode.THROW:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
			if _mode_time > 1.2:
				_set_mode(Mode.DECIDE)
				_decision = 0.3
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
			if to_target.length() < 30.0 or _mode_time > 1.4:
				_set_mode(Mode.DECIDE)
		Mode.ATTACK:
			track_target_during_windup()
			velocity = _runner.step(delta, velocity)


func _choose(distance: float) -> void:
	if phase == 1:
		if distance > 70.0:
			_attack(investida)
		elif distance < 34.0:
			_attack(giro if randf() < 0.4 else batida)
		else:
			_set_mode(Mode.APPROACH)
	else:
		if distance > 60.0:
			_attack(salto)
		elif distance < 36.0:
			_combo_left = 2
			_attack(corte)
		else:
			_set_mode(Mode.APPROACH)


func _attack(data: AttackData) -> void:
	_set_mode(Mode.ATTACK)
	start_attack(data, facing)


func _on_attack_finished() -> void:
	if mode != Mode.ATTACK:
		return
	if _combo_left > 0 and target:
		_combo_left -= 1
		facing = (target.global_position - global_position).normalized()
		start_attack(corte, facing, 1.15)
		return
	_set_mode(Mode.DECIDE)
	_decision = randf_range(0.35, 0.7) if phase == 1 else randf_range(0.15, 0.4)


## Fase 2: o escudo vai para o chão. Sem defesa, mais rápido.
func _throw_shield() -> void:
	phase = 2
	_combo_left = 0
	_runner.cancel()
	hitbox.deactivate()
	_set_mode(Mode.THROW)
	speech.emit(SPEECH_PHASE_2)
	phase_changed.emit(phase_label())
	Sfx.play(&"clang", 0.0)
	Fx.shake(4.0, 0.3)
	body_sprite.sprite_frames = SHIELDLESS
	body_sprite.play(&"idle")
	move_speed *= 1.25
	var shield := Sprite2D.new()
	shield.texture = SHIELD_PROP
	shield.top_level = true
	shield.z_index = -1
	add_child(shield)
	shield.global_position = global_position + Vector2(0, -10)
	var land := global_position + Vector2(-34.0 if facing.x > 0.0 else 34.0, 6)
	var toss := shield.create_tween()
	toss.tween_property(shield, "global_position", land, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	toss.parallel().tween_property(shield, "rotation", 3.5, 0.45)
	shield.reparent.call_deferred(get_parent())


func _on_reset() -> void:
	_set_mode(Mode.DECIDE)


func _on_died() -> void:
	Game.set_flag("galeno_morto")
	Game.add_item("escudo_sem_dono")
	_defeat(SPEECH_DEFEAT[0])
	for i in [1, 2]:
		get_tree().create_timer(2.2 * i).timeout.connect(func():
			if is_instance_valid(self):
				speech.emit(SPEECH_DEFEAT[i]))
