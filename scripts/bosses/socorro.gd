class_name Socorro
extends MiniBoss
## Socorro, A Enfermeira da Estufa — mini-chefe opcional das Raízes
## (v0.35, Etapa 6; Enfermaria, corredor lateral). Cuidava dos doentes com
## humanidade líquida — e provou.
##
## A regra: TODO golpe dela que acerta você a cura em 150% do dano; se você
## bloqueou, metade disso. Golpes rápidos e fracos: deixar acertar é dar
## comida a ela. Fase 2, "Ronda da Noite": um combo longo de giros.

enum Mode { DECIDE, APPROACH, ATTACK }

const SPEECH_WAKE := "Abra a boca. Isso. Remédio amargo é o que cura."
const SPEECH_CARE := "Shh. Eu cuido. Eu sempre cuido."
const SPEECH_FED := "...Obrigada. Eu estava com tanta fome."
const SPEECH_PHASE_2 := "Hora da ronda! Ninguém dorme sem tomar o remédio!"
const SPEECH_DEFEAT := "Eu dava de comer a todo mundo... Ninguém nunca perguntou se eu tinha comido."
const HEAL_RATIO := 1.5
const BLOCKED_HEAL_RATIO := 0.75
const ROUND_SPINS := 5

@export var agulha: AttackData
@export var giro: AttackData

var mode := Mode.DECIDE
var phase := 1
var healed_total := 0.0
var _mode_time := 0.0
var _decision := 0.0
var _combo: Array[AttackData] = []
var _blocked_info: HitInfo
var _fed_said := false
var _care_said := false


func _ready() -> void:
	super._ready()
	hitbox.hit_landed.connect(_on_my_hit_landed)


func _on_wake() -> void:
	speech.emit(SPEECH_WAKE)
	_set_mode(Mode.DECIDE)
	_decision = 0.5
	if target and not target.blocked.is_connected(_on_target_blocked):
		target.blocked.connect(_on_target_blocked)


func _set_mode(new_mode: Mode) -> void:
	mode = new_mode
	_mode_time = 0.0


func _fight(delta: float) -> void:
	_mode_time += delta
	if phase == 1 and stats.health_ratio() <= 0.5:
		phase = 2
		phase_changed.emit("Ronda da Noite")
		speech.emit(SPEECH_PHASE_2)
	match mode:
		Mode.DECIDE:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
			var to_target := target.global_position - global_position
			facing = to_target.normalized()
			_decision -= delta
			if _decision > 0.0:
				return
			if to_target.length() < 30.0:
				if phase == 2 and randf() < 0.5:
					var spins: Array = []
					for i in ROUND_SPINS:
						spins.append(giro)
					_queue(spins)
				else:
					_queue([agulha, agulha, agulha] if randf() < 0.6 else [agulha, agulha])
			else:
				_set_mode(Mode.APPROACH)
		Mode.APPROACH:
			var to_target := target.global_position - global_position
			facing = to_target.normalized()
			velocity = velocity.move_toward(facing * move_speed, acceleration * delta)
			if to_target.length() < 26.0 or _mode_time > 1.5:
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
		_decision = randf_range(0.35, 0.6)
		if not _care_said and randf() < 0.3:
			_care_said = true
			speech.emit(SPEECH_CARE)
		return
	var attack: AttackData = _combo.pop_front()
	_set_mode(Mode.ATTACK)
	start_attack(attack, (target.global_position - global_position).normalized())


func _on_attack_finished() -> void:
	if mode == Mode.ATTACK:
		_next()


func _on_target_blocked(info: HitInfo) -> void:
	_blocked_info = info


## O golpe dela entrou: ela come. (Adiado um quadro: se você bloqueou, o aviso
## de bloqueio chega primeiro e ela come só metade.)
func _on_my_hit_landed(_hurtbox: Hurtbox, info: HitInfo) -> void:
	call_deferred("feed", info, false)


func feed(info: HitInfo, force_blocked: bool) -> float:
	if dead:
		return 0.0
	var blocked := force_blocked or info == _blocked_info
	var amount := info.damage * (BLOCKED_HEAL_RATIO if blocked else HEAL_RATIO)
	stats.heal(amount)
	healed_total += amount
	Fx.float_text(global_position + Vector2(-6, -28), "+%d" % int(amount), Color(0.6, 1.0, 0.6), 7)
	if not _fed_said:
		_fed_said = true
		speech.emit(SPEECH_FED)
	return amount


func _on_reset() -> void:
	phase = 1
	_combo.clear()
	_set_mode(Mode.DECIDE)


func _on_died() -> void:
	_defeat(SPEECH_DEFEAT)


func _after_move(delta: float) -> void:
	if mode == Mode.ATTACK and _runner.is_running() and _current_attack == giro:
		if body_sprite.animation != &"giro":
			body_sprite.play(&"giro")
		return
	update_body_animation(delta)
