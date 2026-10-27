class_name HelenaAltiva
extends Boss
## Luxúria — Helena Altiva, A Cavaleira Desolada. Arena: Teatro Alexandria.
##
## Da Bíblia + do design pedido ("fica agressiva e perde a armadura com o tempo"):
##   • Fase 1 — A Cavaleira Técnica: confiante, rápida, elegante e precisa.
##   • Fase 2 — O Desespero (metade da vida): muito mais rápida e agressiva.
##   • Fase 3 — A Mulher Sem Armadura (depois de "derrotada"): volta sem espada e
##     sem armadura. Alcance e velocidade menores, dano altíssimo.
##
## ARMADURA (0..1): cai sozinha com o tempo e a cada golpe recebido.
##   - Reduz o dano que ela recebe (até max_damage_reduction).
##   - Quanto MENOS armadura, MAIS agressiva: windups mais curtos, menos pausa,
##     anda mais rápido. As peças caem de verdade e ficam espalhadas no palco.

enum Mode { DORMANT, ENTER, AWAIT, DECIDE, APPROACH, STRAFE, BACKSTEP, ATTACK, LEAP, TRANSITION, FALLEN, DEAD }
enum LeapStage { TELEGRAPH, AIR, LAND }

const SPEECH_PHASE_2 := "Não. Não de novo."
const SPEECH_PHASE_3 := "...Eu ainda estou no posto."
const SPEECH_DEFEAT := "Ninguém ocupa o lugar de ninguém... Fique com ela. Eu não consigo mais segurar."
## Bíblia: "Na fase 3, sem armadura, Helena reconhece o anel dele com o jogador.
## É o golpe emocional da luta."
const SPEECH_RING := "Esse anel... Onde você... Ele esteve aqui? Todo esse tempo... e eu não..."
const SPEECH_DEFEAT_RING := "Ele voltou para o posto. E eu nem olhei... Fique com o anel. Eu não consigo mais segurar."
## Quanto tempo ela fica parada ao reconhecer o anel (e quanto o golpe dói nesse tempo).
const RING_HESITATION := 3.0
const RING_DAMAGE_MULTIPLIER := 1.5

@export_group("Golpes")
@export var corte_1: AttackData
@export var corte_2: AttackData
@export var estocada: AttackData
@export var furia: AttackData
@export var furia_final: AttackData
@export var golpe_sem_armadura: AttackData

@export_group("Armadura")
## Fase 1: ~80 s para a armadura cair inteira. Na fase 2 cai em dobro.
@export var armor_decay_per_second := 0.0125
@export var armor_loss_per_hit := 0.02
@export_range(0.0, 0.9) var max_damage_reduction := 0.4

@export_group("Fase 3 — A Mulher Sem Armadura")
@export var phase3_health := 220.0
@export var phase3_speed_multiplier := 0.6

@export_group("Salto (fase 2)")
@export var leap_damage := 30.0
@export var leap_radius := 26.0
@export var leap_air_time := 0.55
@export var leap_telegraph_time := 0.7

@onready var cape: Sprite2D = $Visual/Cape
@onready var pauldron_back: Sprite2D = $Visual/PauldronBack
@onready var breastplate: Sprite2D = $Visual/Breastplate
@onready var pauldron_front: Sprite2D = $Visual/PauldronFront
@onready var helmet: Sprite2D = $Visual/Helmet
@onready var sword_pivot: Node2D = $Visual/SwordPivot
@onready var sword: Sprite2D = $Visual/SwordPivot/Sword
@onready var telegraph: TelegraphDrawer = $Telegraph
@onready var shadow: Sprite2D = $Shadow

var phase := 1
var armor := 1.0
var mode := Mode.DORMANT

var _mode_time := 0.0
var _decision_delay := 0.0
var _combo_queue: Array[AttackData] = []
var _pieces: Array[Dictionary] = []
var _strafe_dir := 1.0
var _mode_duration := 1.0
var _leap_stage := LeapStage.TELEGRAPH
var _leap_from := Vector2.ZERO
var _leap_to := Vector2.ZERO
var _swing_from := 0.0
var _swing_to := 0.0
var _base_speed := 0.0
var _transition_token := 0
var _clock := 0.0
var _hesitate_until := -1.0
## Um único tween para a "pose" (giro/escala do corpo): começar um novo mata o
## anterior. Dois tweens mexendo no mesmo corpo = pose errada (ex.: o cambaleio
## desfazendo a queda da fase 3).
var _pose_tween: Tween


func _ready() -> void:
	super._ready()
	_base_speed = move_speed
	_pieces = [
		{"node": pauldron_back, "at": 0.8},
		{"node": pauldron_front, "at": 0.65},
		{"node": helmet, "at": 0.45},  # o elmo cai e o cabelo ruivo aparece
		{"node": breastplate, "at": 0.2},
	]
	visible = false


# --- Entrada e início da luta ----------------------------------------------------------

## Chamado pela BossArena depois do diálogo: ela salta da plateia para o palco.
func enter_arena(landing: Vector2) -> void:
	visible = true
	_set_mode(Mode.ENTER)
	Sfx.play(&"swing_heavy")
	var from := global_position
	var tween := create_tween()
	tween.tween_method(func(t: float):
		global_position = from.lerp(landing, t)
		visual.position.y = -sin(t * PI) * 36.0
		, 0.0, 1.0, 0.8).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func():
		visual.position.y = 0.0
		Fx.shake(5.0, 0.3)
		Fx.dust(global_position, 14)
		Sfx.play(&"step_heavy")
		_set_mode(Mode.AWAIT)
		ready_to_fight.emit())


func start_fight() -> void:
	super.start_fight()
	_set_mode(Mode.DECIDE)
	_decision_delay = 0.9
	armor_ratio_changed.emit(armor)


func phase_label() -> String:
	match phase:
		1:
			return "Fase 1 — A Cavaleira Técnica"
		2:
			return "Fase 2 — O Desespero"
	return "Fase 3 — A Mulher Sem Armadura"


func armor_ratio() -> float:
	return armor if phase < 3 else -1.0


# --- Loop ---------------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	_clock += delta
	_mode_time += delta
	target = find_target()
	if active:
		regen_poise(delta)  # sem isso, depois do 1º cambaleio ela cambalearia a cada golpe
	if active and phase < 3 and mode != Mode.TRANSITION and mode != Mode.FALLEN and mode != Mode.DEAD:
		_lose_armor(armor_decay_per_second * (2.0 if phase == 2 else 1.0) * delta)
	match mode:
		Mode.DORMANT, Mode.ENTER, Mode.AWAIT, Mode.DEAD:
			velocity = Vector2.ZERO
		Mode.DECIDE:
			_decide(delta)
		Mode.APPROACH:
			_approach(delta)
		Mode.STRAFE:
			_strafe(delta)
		Mode.BACKSTEP:
			velocity = velocity.move_toward(Vector2.ZERO, 900.0 * delta)
			if _mode_time >= 0.3:
				_go_decide(0.15)
		Mode.ATTACK:
			track_target_during_windup()
			velocity = _runner.step(delta, velocity)
		Mode.LEAP:
			_leap(delta)
		Mode.TRANSITION, Mode.FALLEN:
			velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)
	if mode != Mode.ENTER and mode != Mode.LEAP:
		move_and_slide()
	if mode != Mode.FALLEN and mode != Mode.DEAD:
		update_body_animation(delta)
	_update_sword(delta)
	_update_telegraph()


## Parada, olhando o anel (fase 3, se você carrega o anel do Guarda).
func is_hesitating() -> bool:
	return phase >= 3 and _clock < _hesitate_until


func _set_mode(new_mode: Mode) -> void:
	mode = new_mode
	_mode_time = 0.0


func _go_decide(delay: float) -> void:
	_set_mode(Mode.DECIDE)
	_decision_delay = delay


## Pausa entre ações: encurta conforme a armadura cai (mais agressiva).
func _rest_time() -> float:
	match phase:
		1:
			return lerpf(0.9, 0.4, 1.0 - armor)
		2:
			return lerpf(0.45, 0.2, 1.0 - armor)
	return 0.75


## Multiplicador dos windups (menor = mais rápido).
func _windup_scale() -> float:
	match phase:
		1:
			return lerpf(1.0, 0.8, 1.0 - armor)
		2:
			return lerpf(0.8, 0.62, 1.0 - armor)
	return 1.0


func _speed() -> float:
	match phase:
		1:
			return _base_speed * lerpf(1.0, 1.25, 1.0 - armor)
		2:
			return _base_speed * lerpf(1.3, 1.5, 1.0 - armor)
	return _base_speed * phase3_speed_multiplier


# --- Decisões -------------------------------------------------------------------------

func _decide(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	if target == null:
		return
	var to_target := target.global_position - global_position
	facing = to_target.normalized()
	_decision_delay -= delta
	if _decision_delay > 0.0:
		return
	var distance := to_target.length()
	var roll := randf()
	match phase:
		1:
			if distance < 34.0:
				if roll < 0.7:
					_queue_combo([corte_1, corte_2])
				else:
					_backstep()
			elif distance < 120.0 and roll < 0.5:
				_queue_combo([estocada])
			elif roll < 0.75:
				_begin_strafe()
			else:
				_set_mode(Mode.APPROACH)
		2:
			if distance < 34.0:
				if roll < 0.55:
					_queue_combo([furia, furia, furia, furia_final])
				else:
					_queue_combo([corte_1, corte_2])
			elif distance < 150.0:
				if roll < 0.35:
					_start_leap()
				elif roll < 0.75:
					_queue_combo([estocada])
				else:
					_set_mode(Mode.APPROACH)
			elif roll < 0.5:
				_start_leap()
			else:
				_set_mode(Mode.APPROACH)
		3:
			if distance < 22.0:
				_queue_combo([golpe_sem_armadura])
			else:
				_set_mode(Mode.APPROACH)


func _approach(delta: float) -> void:
	if target == null:
		_go_decide(0.5)
		return
	var to_target := target.global_position - global_position
	facing = to_target.normalized()
	var stop_distance := 20.0 if phase == 3 else 28.0
	velocity = velocity.move_toward(facing * _speed(), acceleration * delta)
	if to_target.length() <= stop_distance or _mode_time > (3.0 if phase == 3 else 1.6):
		_go_decide(0.05)


## Passo elegante: circula o herói mantendo a distância (fase 1 = técnica).
func _begin_strafe() -> void:
	_set_mode(Mode.STRAFE)
	_mode_duration = randf_range(0.6, 1.2)
	_strafe_dir = 1.0 if randf() < 0.5 else -1.0


func _strafe(delta: float) -> void:
	if target == null:
		_go_decide(0.5)
		return
	var to_target := target.global_position - global_position
	facing = to_target.normalized()
	var desired := facing.orthogonal() * _strafe_dir * _speed() * 0.7
	if to_target.length() > 70.0:
		desired += facing * _speed() * 0.4
	velocity = velocity.move_toward(desired, acceleration * delta)
	if _mode_time >= _mode_duration:
		_go_decide(0.0)


func _backstep() -> void:
	_set_mode(Mode.BACKSTEP)
	velocity = -facing * 190.0
	Sfx.play(&"dash", -6.0)
	Fx.dust(global_position, 4)


# --- Golpes ------------------------------------------------------------------------------

func _queue_combo(attacks: Array) -> void:
	_combo_queue.assign(attacks)
	_next_in_combo()


func _next_in_combo() -> void:
	if _combo_queue.is_empty() or target == null:
		_go_decide(_rest_time())
		return
	var attack: AttackData = _combo_queue.pop_front()
	var direction := (target.global_position - global_position).normalized()
	_set_mode(Mode.ATTACK)
	start_attack(attack, direction, _windup_scale())
	_setup_swing(attack, direction)
	if attack == estocada:
		Sfx.play(&"telegraph", -2.0)


func _on_attack_finished() -> void:
	if mode == Mode.ATTACK:
		_next_in_combo()


func _setup_swing(attack: AttackData, direction: Vector2) -> void:
	var base := direction.angle()
	var half := deg_to_rad(attack.slash_arc_degrees) * 0.5
	if attack.slash_arc_degrees <= 10.0:
		_swing_from = base
		_swing_to = base
	elif randf() < 0.5:
		_swing_from = base - half
		_swing_to = base + half
	else:
		_swing_from = base + half
		_swing_to = base - half


# --- Salto (fase 2) ------------------------------------------------------------------------

func _start_leap() -> void:
	if target == null:
		return
	_set_mode(Mode.LEAP)
	_leap_stage = LeapStage.TELEGRAPH
	_leap_from = global_position
	_leap_to = _clamp_to_arena(target.global_position)
	Sfx.play(&"telegraph", -2.0)


func _leap(delta: float) -> void:
	match _leap_stage:
		LeapStage.TELEGRAPH:
			velocity = Vector2.ZERO
			var telegraph_time := leap_telegraph_time * _windup_scale()
			# Acompanha o herói na primeira metade, depois TRAVA o ponto de queda.
			if target and _mode_time < telegraph_time * 0.5:
				_leap_to = _clamp_to_arena(target.global_position)
			visual.scale = Vector2(1.1, 0.88)  # agacha antes de saltar
			if _mode_time >= telegraph_time:
				_leap_stage = LeapStage.AIR
				_mode_time = 0.0
				visual.scale = Vector2.ONE  # desfaz o agachamento
				hurtbox.invulnerable = true
				Sfx.play(&"swing_heavy")
		LeapStage.AIR:
			var t := clampf(_mode_time / leap_air_time, 0.0, 1.0)
			global_position = _leap_from.lerp(_leap_to, t)
			visual.position.y = -sin(t * PI) * 34.0
			if t >= 1.0:
				_leap_stage = LeapStage.LAND
				_mode_time = 0.0
				visual.position.y = 0.0
				hurtbox.invulnerable = false
				_leap_impact()
		LeapStage.LAND:
			velocity = Vector2.ZERO
			if _mode_time >= 0.8:  # recuperação longa: a janela de punição
				_go_decide(_rest_time())
	telegraph.circle_progress = clampf(_mode_time / (leap_telegraph_time * _windup_scale()), 0.0, 1.0) if _leap_stage == LeapStage.TELEGRAPH else 1.0


func _leap_impact() -> void:
	var squash := _restart_pose_tween()
	visual.scale = Vector2(1.18, 0.82)  # "esmaga" na aterrissagem e volta
	squash.tween_property(visual, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	Fx.shake(6.0, 0.3)
	Fx.dust(global_position, 18)
	Sfx.play(&"hit_heavy")
	Fx.vibrate(40)
	if target and target.global_position.distance_to(global_position) <= leap_radius:
		var info := HitInfo.create(leap_damage, global_position, target.global_position)
		info.knockback = 170.0
		info.is_heavy = true
		info.source = self
		target.hurtbox.receive_hit(info)


func _clamp_to_arena(point: Vector2) -> Vector2:
	return clamp_to_arena(point, 12.0)


# --- Armadura ----------------------------------------------------------------------------

func _lose_armor(amount: float) -> void:
	if amount <= 0.0 or armor <= 0.0:
		return
	armor = maxf(armor - amount, 0.0)
	armor_ratio_changed.emit(armor)
	for piece in _pieces:
		if not piece.get("dropped", false) and armor <= float(piece["at"]):
			piece["dropped"] = true
			_drop_piece(piece["node"])


## A peça se solta do corpo, quica e fica no chão do palco até o fim da luta.
func _drop_piece(piece: Sprite2D) -> void:
	if not is_instance_valid(piece) or not piece.visible:
		return
	var debris := Sprite2D.new()
	debris.texture = piece.texture
	debris.flip_h = body_sprite.flip_h
	debris.offset = piece.offset
	debris.material = piece.material
	get_parent().add_child(debris)
	debris.global_position = piece.global_position
	debris.z_index = -1
	piece.visible = false
	var side := -1.0 if randf() < 0.5 else 1.0
	var land := debris.global_position + Vector2(randf_range(10.0, 22.0) * side, randf_range(4.0, 10.0))
	var start := debris.global_position
	var tween := debris.create_tween()
	tween.tween_method(func(t: float):
		debris.global_position = start.lerp(land, t) + Vector2(0, -sin(t * PI) * 14.0)
		debris.rotation = t * 2.5 * side
		, 0.0, 1.0, 0.55)
	tween.tween_property(debris, "modulate", Color(0.9, 0.9, 0.95), 0.4)
	Sfx.play(&"armor_break")
	Fx.sparks(piece.global_position, Vector2.UP, Color(0.85, 0.9, 1.0), 12, 140.0)
	Fx.shake(3.0, 0.15)


func _incoming_damage_multiplier(_info: HitInfo) -> float:
	if phase >= 3:
		return RING_DAMAGE_MULTIPLIER if is_hesitating() else 1.0
	return 1.0 - armor * max_damage_reduction


func _on_damaged(_amount: float, _info: HitInfo, _blocked: bool) -> void:
	if phase < 3:
		if armor > 0.4:
			Sfx.play(&"clang", -6.0)
		_lose_armor(armor_loss_per_hit)
	if phase == 1 and not stats.is_dead and stats.health <= stats.max_health * 0.5:
		_enter_phase_2()


## Só cambaleia em pé e lutando — inclusive na aterrissagem do salto, que é
## justamente a janela de punição. No ar ou trocando de fase, a postura zerada
## fica "guardada" para o próximo golpe (veja Enemy._on_hit_received).
func _can_be_staggered() -> bool:
	if mode == Mode.LEAP:
		return _leap_stage == LeapStage.LAND
	return mode in [Mode.DECIDE, Mode.APPROACH, Mode.STRAFE, Mode.ATTACK, Mode.BACKSTEP]


## Helena não cambaleia com golpes leves; só quando a postura quebra.
func _on_poise_broken(_info: HitInfo) -> void:
	_combo_queue.clear()
	_set_mode(Mode.TRANSITION)  # cambaleia: janela para punir
	var token := _new_transition_token()
	var side := -1.0 if body_sprite.flip_h else 1.0
	var tween := _restart_pose_tween()
	tween.tween_property(visual, "rotation", 0.25 * side, 0.1)
	tween.tween_property(visual, "rotation", 0.0, 0.5)
	await wait(stagger_time)
	if token == _transition_token and mode == Mode.TRANSITION and not dead:
		_go_decide(0.1)


## Mata o tween de pose anterior e começa um novo (reset_pose: volta ao normal antes).
func _restart_pose_tween(reset_pose: bool = true) -> Tween:
	if _pose_tween and _pose_tween.is_valid():
		_pose_tween.kill()
	if reset_pose:
		visual.rotation = 0.0
		visual.scale = Vector2.ONE
	_pose_tween = create_tween()
	return _pose_tween


## Cada transição (cambaleio, troca de fase) ganha um "ticket". Se outra
## transição começar no meio do caminho, o ticket antigo perde a validade —
## assim um await antigo nunca sobrescreve o estado novo.
func _new_transition_token() -> int:
	_transition_token += 1
	return _transition_token


# --- Fases --------------------------------------------------------------------------------

func _enter_phase_2() -> void:
	phase = 2
	_set_mode(Mode.TRANSITION)
	_combo_queue.clear()
	_runner.cancel()
	hurtbox.invulnerable = true
	telegraph.clear()
	if armor > 0.5:
		_lose_armor(armor - 0.5)
	var token := _new_transition_token()
	phase_changed.emit("Fase 2 — O Desespero")
	speech.emit(SPEECH_PHASE_2)
	Sfx.play(&"boss_phase")
	Fx.shake(6.0, 0.6)
	Fx.slow_motion(0.3, 0.45)
	_push_player_away(70.0, 220.0)
	var tween := _restart_pose_tween()
	tween.tween_property(visual, "scale", Vector2(0.85, 1.15), 0.2)
	tween.tween_property(visual, "scale", Vector2.ONE, 0.3)
	await wait(1.4)
	if token == _transition_token and not dead:
		hurtbox.invulnerable = false
		_go_decide(0.2)


## Fim da fase 2: ela "morre"... e se levanta sem espada e sem armadura.
func _enter_phase_3() -> void:
	phase = 3
	var token := _new_transition_token()
	_set_mode(Mode.FALLEN)
	_combo_queue.clear()
	_runner.cancel()
	hitbox.deactivate()
	hurtbox.invulnerable = true
	telegraph.clear()
	for piece in _pieces:
		if not piece.get("dropped", false):
			piece["dropped"] = true
			_drop_piece(piece["node"])
	_drop_piece(cape)
	_drop_piece(sword)
	armor = 0.0
	armor_ratio_changed.emit(0.0)
	Sfx.stop_ambience(0.4)
	var side := -1.0 if body_sprite.flip_h else 1.0
	var fall := _restart_pose_tween()
	fall.tween_property(visual, "rotation", deg_to_rad(80.0) * side, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	await wait(2.6)
	if dead or not is_inside_tree() or token != _transition_token:
		return
	stats.base_health = phase3_health
	stats.health_per_vitalidade = 0.0
	stats.revive()
	var rise := _restart_pose_tween(false)  # levanta a partir de onde caiu
	rise.tween_property(visual, "rotation", 0.0, 0.8).set_trans(Tween.TRANS_SINE)
	await wait(0.8)
	if dead or token != _transition_token:
		return
	title_changed.emit("Helena", "")  # sem título: só ela
	phase_changed.emit("Fase 3 — A Mulher Sem Armadura")
	Sfx.play(&"boss_phase", -6.0)
	Sfx.play_ambience(&"amb_boss", -16.0)
	hurtbox.invulnerable = false
	if Game.has_item("anel_do_guarda"):
		# Ela vê o anel na sua mão e para. A janela é longa — e dói.
		speech.emit(SPEECH_RING)
		Sfx.play(&"bell", -6.0)
		_hesitate_until = _clock + RING_HESITATION
		_go_decide(RING_HESITATION)
	else:
		speech.emit(SPEECH_PHASE_3)
		_go_decide(0.9)


func _on_died() -> void:
	if phase == 1:
		# Dano enorme de uma vez: não pula a fase 2.
		stats.revive()
		stats.set_health(stats.max_health * 0.5)
		_enter_phase_2()
		return
	if phase == 2:
		_enter_phase_3()
		return
	dead = true
	active = false
	_set_mode(Mode.DEAD)
	_runner.cancel()
	hitbox.deactivate()
	telegraph.clear()
	remove_from_group("enemies")
	hurtbox.set_deferred("monitorable", false)
	set_deferred("collision_layer", 0)
	speech.emit(SPEECH_DEFEAT_RING if Game.has_item("anel_do_guarda") else SPEECH_DEFEAT)
	var reward := data.memory_reward if data else 1500
	Game.earn_memories(reward)
	if target:
		Fx.memory_motes(global_position + Vector2(0, -10), target, 24)
	Sfx.play(&"boss_phase")
	Fx.slow_motion(0.25, 0.8)
	var side := -1.0 if body_sprite.flip_h else 1.0
	var tween := _restart_pose_tween()
	tween.tween_property(visual, "rotation", deg_to_rad(15.0) * side, 0.6)
	tween.parallel().tween_property(visual, "position:y", 3.0, 0.6)
	tween.tween_interval(1.2)
	# "A humanidade vira líquido": ela se desfaz em branco — e a sombra junto.
	tween.tween_property(visual, "modulate", Color(2.0, 2.0, 2.2, 0.0), 1.6)
	tween.parallel().tween_property(shadow, "modulate:a", 0.0, 1.6)
	tween.tween_callback(queue_free)  # as peças de armadura continuam no palco
	fight_won.emit(self)


func _push_player_away(radius: float, force: float) -> void:
	if target and target.global_position.distance_to(global_position) < radius:
		target.velocity = (target.global_position - global_position).normalized() * force


# --- Visual da espada e avisos ----------------------------------------------------------------

func _update_sword(delta: float) -> void:
	if not sword.visible:
		return
	var side := -1.0 if body_sprite.flip_h else 1.0
	var target_angle := (PI * 0.5 - 0.9) if side > 0.0 else (PI * 0.5 + 0.9)
	var target_pos := Vector2(5.0 * side, -11.0)
	if mode == Mode.ATTACK and _runner.is_running():
		target_pos = Vector2(0, -12)
		match _runner.phase:
			AttackRunner.Phase.WINDUP:
				target_angle = _swing_from + (-0.6 if _swing_to >= _swing_from else 0.6) * _runner.phase_progress()
				if _swing_from == _swing_to:
					target_pos -= Vector2.from_angle(_swing_from) * 4.0 * _runner.phase_progress()
			AttackRunner.Phase.LUNGE:
				target_angle = _swing_from
				if _swing_from == _swing_to:
					target_pos += Vector2.from_angle(_swing_from) * 6.0
			AttackRunner.Phase.ACTIVE:
				target_angle = lerp_angle(_swing_from, _swing_to, _runner.phase_progress())
			_:
				target_angle = _swing_to
		sword_pivot.rotation = target_angle
	elif mode == Mode.LEAP:
		target_angle = -PI * 0.5
		sword_pivot.rotation = lerp_angle(sword_pivot.rotation, target_angle, 12.0 * delta)
	else:
		sword_pivot.rotation = lerp_angle(sword_pivot.rotation, target_angle, 10.0 * delta)
	sword_pivot.position = sword_pivot.position.lerp(target_pos, 18.0 * delta)
	sword.flip_v = cos(sword_pivot.rotation) < 0.0
	sword_pivot.z_index = -1 if sin(sword_pivot.rotation) < -0.35 else 1
	# As peças de armadura acompanham o espelhamento do corpo.
	for piece: Sprite2D in [cape, pauldron_back, breastplate, pauldron_front, helmet]:
		piece.flip_h = body_sprite.flip_h


func _update_telegraph() -> void:
	telegraph.line_visible = false
	telegraph.circle_visible = false
	if mode == Mode.ATTACK and _current_attack == estocada and _runner.phase == AttackRunner.Phase.WINDUP:
		telegraph.line_visible = true
		telegraph.line_origin = global_position + Vector2(0, -4)
		telegraph.line_direction = _runner.direction
		telegraph.line_length = estocada.lunge_speed * estocada.lunge_time + estocada.reach
		telegraph.line_locked = not _runner.can_track_target()
	elif mode == Mode.LEAP and _leap_stage != LeapStage.LAND:
		telegraph.circle_visible = true
		telegraph.circle_center = _leap_to
		telegraph.circle_radius = leap_radius
