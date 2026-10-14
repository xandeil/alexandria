class_name Governanta
extends Boss
## A Governanta — mini-chefe do Prólogo (Complexo das Cápsulas).
##
## Bíblia: "Antes da porta de saída, uma mulher está sentada à mesa, cabeça
## baixa. Ela já sabe o que o jogador fez."
##   • Não acertou nenhuma criança → ela só observa e deixa passar. Sem diálogo.
##   • Acertou alguma → ela se levanta gritando, a porta tranca e vira
##     mini-chefe: "maior e mais forte que tudo visto até ali".
##
## Quem decide SE ela luta não é ela: é a fase (Prologo), olhando o contador
## Game.criancas_feridas. Ela só sabe ficar sentada, observar e lutar
## (responsabilidade única — e dá para testar cada parte separada).
##
## Golpes (todos com aviso: morre-se por errar o tempo, nunca por não ver):
##   • Molho de chaves: varredura larga (leque vermelho no chão).
##   • Abraço: avança em linha reta de braços abertos (linha vermelha que TRAVA).
##   • Grito: um ANEL que se expande (círculo no chão = alcance). Atravesse com o
##     dash ou fique longe. "O grito não era de raiva. Era de falha."
## Fase 2 — A Conta Que Não Fecha (metade da vida): o coque se desfaz, grito
## duplo, chaves em dois tempos e os ECOS das crianças correndo até você.

enum Mode { SEATED, RISING, DECIDE, APPROACH, ATTACK, SCREAM, CALL, TRANSITION, DEAD }
enum ScreamStage { WINDUP, RECOVER }

# Falas provisórias (reescreva!).
const SPEECH_RISE := "Eu contei. Todas as noites, eu contei."
const SPEECH_PHASE_2 := "A conta nunca fecha. NUNCA FECHA."
const SPEECH_DEFEAT := "Era para eles crescerem..."
const PHASE_LABELS := ["Fase 1 — A Que Ainda Cuida", "Fase 2 — A Conta Que Não Fecha"]
const SEATED_DOWN := preload("res://assets/sprites/governanta_sentada.png")
const SEATED_UP := preload("res://assets/sprites/governanta_olhando.png")
const LOOSE_FRAMES := preload("res://assets/sprites/governanta_solto_frames.tres")
## De pé ela cresce: "maior e mais forte que tudo visto até ali".
const STANDING_SCALE := 1.4

@export_group("Golpes")
@export var chaves: AttackData
@export var chaves_volta: AttackData
@export var abraco: AttackData

@export_group("Grito")
@export var scream_damage := 18.0
@export var scream_windup := 0.8
@export var scream_reach := 120.0
@export var scream_speed := 150.0

@export_group("Ecos (fase 2)")
@export var echo_damage := 10.0
@export var echo_count := 3
@export var echo_speed := 150.0
@export var echo_cooldown := 8.0

@export_group("Sentada")
## Distância em que ela levanta os olhos para o herói (sem lutar).
@export var watch_distance := 150.0

@onready var seated: Sprite2D = $Visual/Seated
@onready var keys_pivot: Node2D = $Visual/KeysPivot
@onready var keys: Sprite2D = $Visual/KeysPivot/Keys
@onready var telegraph: TelegraphDrawer = $Telegraph
@onready var shadow: Sprite2D = $Shadow

var phase := 1
var mode := Mode.SEATED
## Sentada, de olhos erguidos acompanhando o herói (o caminho sem violência).
var watching := false

var _mode_time := 0.0
var _decision_delay := 0.0
var _combo_queue: Array[AttackData] = []
var _base_speed := 0.0
var _scream_stage := ScreamStage.WINDUP
var _screams_left := 0
var _echo_cooldown := 0.0
var _intro_said := false
var _swing_from := 0.0
var _swing_to := 0.0
var _transition_token := 0
var _pose_tween: Tween
var _base_scale := Vector2.ONE


func _ready() -> void:
	super._ready()
	_base_speed = move_speed
	seated.visible = true
	seated.texture = SEATED_DOWN
	body_sprite.visible = false
	keys_pivot.visible = false
	shadow.visible = false
	visual.z_index = 1  # sentada: desenhada por cima da mesa (os braços apoiados nela)


# --- Sentada: observar sem dizer nada ------------------------------------------------

func _seated() -> void:
	velocity = Vector2.ZERO
	var look := target != null and global_position.distance_to(target.global_position) <= watch_distance
	if look != watching:
		watching = look
		seated.texture = SEATED_UP if watching else SEATED_DOWN


## Chamado pela BossArena quando a fase decide que ela luta: levanta GRITANDO.
func enter_arena(_landing: Vector2) -> void:
	visible = true
	_set_mode(Mode.RISING)
	var token := _new_transition_token()
	seated.texture = SEATED_UP
	await wait(0.4)
	if token != _transition_token or dead:
		return
	seated.visible = false
	body_sprite.visible = true
	body_sprite.play(&"grito")
	keys_pivot.visible = true
	shadow.visible = true
	visual.z_index = 0
	Sfx.play(&"scream")
	Fx.shake(5.0, 0.9)
	Fx.vibrate(120)
	ScreamRing.launch(get_parent(), global_position, self, 0.0, 200.0, 70.0)  # o grito ao se erguer (não machuca)
	_base_scale = Vector2.ONE * STANDING_SCALE
	var tween := _restart_pose_tween(false)
	visual.scale = Vector2(0.9, 0.9)
	tween.tween_property(visual, "scale", _base_scale, 0.9).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await wait(1.1)
	if token != _transition_token or dead:
		return
	body_sprite.play(&"idle")
	ready_to_fight.emit()


func start_fight() -> void:
	super.start_fight()
	_go_decide(0.5)


func phase_label() -> String:
	return PHASE_LABELS[clampi(phase - 1, 0, PHASE_LABELS.size() - 1)]


## A lembrança dela (no Prólogo) toma o lugar do subtítulo de "Pecado".
func victory_subtitle() -> String:
	return "Um cuidado que virou prisão"


# --- Loop ---------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	_mode_time += delta
	_echo_cooldown -= delta
	target = find_target()
	if active:
		regen_poise(delta)
	match mode:
		Mode.SEATED:
			_seated()
		Mode.RISING, Mode.TRANSITION, Mode.DEAD:
			velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)
		Mode.DECIDE:
			_decide(delta)
		Mode.APPROACH:
			_approach(delta)
		Mode.ATTACK:
			track_target_during_windup()
			velocity = _runner.step(delta, velocity)
		Mode.SCREAM:
			_scream(delta)
		Mode.CALL:
			velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)
			if _mode_time >= 1.0:
				_go_decide(_rest_time())
	if mode != Mode.SEATED:
		move_and_slide()
	if mode in [Mode.DECIDE, Mode.APPROACH, Mode.ATTACK]:
		update_body_animation(delta)
		_update_attack_pose()
	_update_keys(delta)
	_update_telegraph()


func _set_mode(new_mode: Mode) -> void:
	mode = new_mode
	_mode_time = 0.0


func _go_decide(delay: float) -> void:
	_set_mode(Mode.DECIDE)
	_decision_delay = delay


func _rest_time() -> float:
	return 0.75 if phase == 1 else 0.45


func _windup_scale() -> float:
	return 1.0 if phase == 1 else 0.82


func _speed() -> float:
	return _base_speed * (1.0 if phase == 1 else 1.3)


# --- Decisões -----------------------------------------------------------------------

func _decide(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	if target == null:
		return
	var to_target := target.global_position - global_position
	facing = to_target.normalized()
	_decision_delay -= delta
	if _decision_delay > 0.0:
		return
	if not _intro_said:
		_intro_said = true
		speech.emit(SPEECH_RISE)
	var distance := to_target.length()
	var roll := randf()
	if phase == 2 and _echo_cooldown <= 0.0 and roll < 0.35:
		_start_call()
	elif distance < 42.0:
		if roll < 0.6:
			_queue_combo([chaves] if phase == 1 else [chaves, chaves_volta])
		else:
			_start_scream()
	elif distance < scream_reach - 10.0:
		if roll < 0.45:
			_queue_combo([abraco])
		elif roll < 0.75:
			_start_scream()
		else:
			_set_mode(Mode.APPROACH)
	else:
		_set_mode(Mode.APPROACH)


func _approach(delta: float) -> void:
	if target == null:
		_go_decide(0.5)
		return
	var to_target := target.global_position - global_position
	facing = to_target.normalized()
	velocity = velocity.move_toward(facing * _speed(), acceleration * delta)
	if to_target.length() <= 34.0 or _mode_time > 1.6:
		_go_decide(0.05)


# --- Chaves e abraço (AttackRunner: Step and Anchor) ----------------------------------------

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
	var half := deg_to_rad(attack.slash_arc_degrees) * 0.5
	var side := 1.0 if randf() < 0.5 else -1.0
	_swing_from = direction.angle() - half * side
	_swing_to = direction.angle() + half * side
	if attack == abraco:
		Sfx.play(&"telegraph", -2.0)


func _on_attack_finished() -> void:
	if mode == Mode.ATTACK:
		_next_in_combo()


# --- O grito -------------------------------------------------------------------------

func _start_scream() -> void:
	_set_mode(Mode.SCREAM)
	_scream_stage = ScreamStage.WINDUP
	_screams_left = 1 if phase == 1 else 2
	body_sprite.play(&"grito")
	Sfx.play(&"telegraph", -4.0)


func _scream_windup_time() -> float:
	var base := scream_windup * _windup_scale()
	return base if _screams_left >= (1 if phase == 1 else 2) else base * 0.6


func _scream(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)
	match _scream_stage:
		ScreamStage.WINDUP:
			# Puxa o ar: o corpo estica (aviso) e o círculo no chão enche.
			var t := clampf(_mode_time / _scream_windup_time(), 0.0, 1.0)
			visual.scale = _base_scale * Vector2(1.0 - 0.08 * t, 1.0 + 0.12 * t)
			telegraph.circle_progress = t
			if t >= 1.0:
				_release_scream()
		ScreamStage.RECOVER:
			visual.scale = visual.scale.lerp(_base_scale, 10.0 * delta)
			if _mode_time >= 0.55:
				if _screams_left > 0:
					_scream_stage = ScreamStage.WINDUP
					_mode_time = 0.0
				else:
					body_sprite.play(&"idle")
					_go_decide(_rest_time())


func _release_scream() -> void:
	_screams_left -= 1
	_scream_stage = ScreamStage.RECOVER
	_mode_time = 0.0
	visual.scale = _base_scale * Vector2(1.12, 0.92)
	Sfx.play(&"scream", -2.0)
	Fx.shake(4.0, 0.45)
	Fx.vibrate(60)
	ScreamRing.launch(get_parent(), global_position, self, scream_damage, scream_speed, scream_reach)


# --- Fase 2: os ecos ------------------------------------------------------------------

func _start_call() -> void:
	_set_mode(Mode.CALL)
	_echo_cooldown = echo_cooldown
	body_sprite.play(&"abraco")  # braços abertos: chamando as crianças
	Sfx.play(&"echo")
	if target == null:
		return
	for i in echo_count:
		var at := _echo_point(i)
		var aim := target.global_position + Vector2(randf_range(-10, 10), randf_range(-8, 8))
		EchoChild.spawn(get_parent(), at, aim, self, echo_damage, echo_speed, arena_rect.grow(-6.0))


## Um ponto da sala, longe o bastante do herói para dar tempo de ver o eco.
func _echo_point(index: int) -> Vector2:
	var center := target.global_position
	for attempt in 12:
		var angle := TAU * (float(index) / maxf(echo_count, 1)) + randf_range(-0.6, 0.6)
		var point := clamp_to_arena(center + Vector2.from_angle(angle) * randf_range(80.0, 120.0), 18.0)
		if point.distance_to(center) >= 60.0:
			return point
	return clamp_to_arena(center + Vector2(90, 0), 18.0)


# --- Dano, cambaleio, fases -------------------------------------------------------------------

func _on_damaged(_amount: float, _info: HitInfo, _blocked: bool) -> void:
	if phase == 1 and not stats.is_dead and stats.health <= stats.max_health * 0.5:
		_enter_phase_2()


func _can_be_staggered() -> bool:
	return mode in [Mode.DECIDE, Mode.APPROACH, Mode.ATTACK, Mode.CALL]


func _on_poise_broken(_info: HitInfo) -> void:
	_combo_queue.clear()
	_set_mode(Mode.TRANSITION)
	var token := _new_transition_token()
	var side := -1.0 if body_sprite.flip_h else 1.0
	var tween := _restart_pose_tween()
	tween.tween_property(visual, "rotation", 0.22 * side, 0.1)
	tween.tween_property(visual, "rotation", 0.0, 0.45)
	await wait(stagger_time)
	if token == _transition_token and mode == Mode.TRANSITION and not dead:
		_go_decide(0.1)


func _enter_phase_2() -> void:
	phase = 2
	_set_mode(Mode.TRANSITION)
	_combo_queue.clear()
	_runner.cancel()
	hitbox.deactivate()
	hurtbox.invulnerable = true
	telegraph.clear()
	var token := _new_transition_token()
	phase_changed.emit(PHASE_LABELS[1])
	speech.emit(SPEECH_PHASE_2)
	# O coque se desfaz: o cabelo cai solto (o mesmo corpo, outra folha).
	body_sprite.sprite_frames = LOOSE_FRAMES
	body_sprite.play(&"grito")
	Sfx.play(&"scream")
	Sfx.play(&"boss_phase", -6.0)
	Fx.shake(6.0, 0.8)
	Fx.slow_motion(0.35, 0.4)
	_push_player_away(80.0, 230.0)
	ScreamRing.launch(get_parent(), global_position, self, 0.0, 190.0, scream_reach)  # sem aviso = sem dano
	var tween := _restart_pose_tween()
	tween.tween_property(visual, "scale", _base_scale * Vector2(0.86, 1.16), 0.2)
	tween.tween_property(visual, "scale", _base_scale, 0.35)
	_echo_cooldown = 2.5
	await wait(1.5)
	if token == _transition_token and not dead:
		hurtbox.invulnerable = false
		body_sprite.play(&"idle")
		_go_decide(0.3)


func _on_died() -> void:
	if phase == 1:
		# Dano enorme de uma vez: não pula a fase 2.
		stats.revive()
		stats.set_health(stats.max_health * 0.5)
		_enter_phase_2()
		return
	dead = true
	active = false
	_new_transition_token()
	_set_mode(Mode.DEAD)
	_runner.cancel()
	hitbox.deactivate()
	telegraph.clear()
	remove_from_group("enemies")
	hurtbox.set_deferred("monitorable", false)
	set_deferred("collision_layer", 0)
	speech.emit(SPEECH_DEFEAT)
	var reward := data.memory_reward if data else 250
	Game.add_memories(reward)
	if target:
		Fx.memory_motes(global_position + Vector2(0, -14), target, 14)
	Sfx.play(&"boss_phase")
	Fx.slow_motion(0.25, 0.8)
	body_sprite.play(&"idle")
	keys_pivot.visible = false
	# Ajoelha devagar... e se desfaz em branco, como todo mundo aqui.
	var tween := _restart_pose_tween()
	tween.tween_property(visual, "scale", _base_scale * Vector2(1.08, 0.72), 0.6).set_trans(Tween.TRANS_SINE)
	tween.tween_interval(0.6)
	tween.tween_property(visual, "modulate", Color(2.0, 2.0, 2.2, 0.0), 1.2)
	tween.parallel().tween_property(shadow, "modulate:a", 0.0, 1.2)
	tween.tween_callback(queue_free)
	# As chaves ficam no chão.
	_drop_keys()
	fight_won.emit(self)


func _drop_keys() -> void:
	var dropped := Sprite2D.new()
	dropped.texture = keys.texture
	dropped.rotation = 0.6
	dropped.z_index = -1
	get_parent().add_child(dropped)
	dropped.global_position = global_position + Vector2(10, -2)
	Sfx.play(&"clang", -8.0)


func _push_player_away(radius: float, force: float) -> void:
	if target and target.global_position.distance_to(global_position) < radius:
		target.velocity = (target.global_position - global_position).normalized() * force


func _new_transition_token() -> int:
	_transition_token += 1
	return _transition_token


## Um único tween para a pose (mata o anterior). reset_pose: volta ao tamanho base.
func _restart_pose_tween(reset_pose: bool = true) -> Tween:
	if _pose_tween and _pose_tween.is_valid():
		_pose_tween.kill()
	if reset_pose:
		visual.rotation = 0.0
		visual.scale = _base_scale
	_pose_tween = create_tween()
	return _pose_tween


# --- Visual: pose do golpe, chaves e avisos ------------------------------------------------------

func _update_attack_pose() -> void:
	if mode == Mode.ATTACK and _current_attack == abraco and _runner.is_running():
		if body_sprite.animation != &"abraco":
			body_sprite.play(&"abraco")
	elif body_sprite.animation == &"abraco" and mode != Mode.CALL:
		body_sprite.play(&"idle")


func _update_keys(delta: float) -> void:
	if not keys_pivot.visible:
		return
	var side := -1.0 if body_sprite.flip_h else 1.0
	var target_pos := Vector2(5.0 * side, -13.0)
	if mode == Mode.ATTACK and _runner.is_running() and _current_attack != abraco:
		match _runner.phase:
			AttackRunner.Phase.WINDUP:
				keys_pivot.rotation = _swing_from - 0.5 * signf(_swing_to - _swing_from) * _runner.phase_progress()
			AttackRunner.Phase.LUNGE:
				keys_pivot.rotation = _swing_from
			AttackRunner.Phase.ACTIVE:
				keys_pivot.rotation = lerp_angle(_swing_from, _swing_to, _runner.phase_progress())
			_:
				keys_pivot.rotation = _swing_to
	else:
		var rest := (PI * 0.5 - 0.35) if side > 0.0 else (PI * 0.5 + 0.35)
		keys_pivot.rotation = lerp_angle(keys_pivot.rotation, rest, 8.0 * delta)
	keys_pivot.position = keys_pivot.position.lerp(target_pos, 16.0 * delta)
	keys.flip_v = cos(keys_pivot.rotation) < 0.0
	keys_pivot.z_index = -1 if sin(keys_pivot.rotation) < -0.35 else 1


func _update_telegraph() -> void:
	telegraph.line_visible = false
	telegraph.circle_visible = false
	telegraph.arc_visible = false
	if mode == Mode.ATTACK and _runner.phase == AttackRunner.Phase.WINDUP and _current_attack:
		if _current_attack == abraco:
			telegraph.line_visible = true
			telegraph.line_origin = global_position + Vector2(0, -4)
			telegraph.line_direction = _runner.direction
			telegraph.line_length = abraco.lunge_speed * abraco.lunge_time + abraco.reach
			telegraph.line_locked = not _runner.can_track_target()
		else:
			telegraph.arc_visible = true
			telegraph.arc_center = global_position
			telegraph.arc_direction = _runner.direction
			telegraph.arc_radius = _current_attack.reach + _current_attack.radius
			telegraph.arc_angle = deg_to_rad(_current_attack.slash_arc_degrees)
			telegraph.arc_progress = _runner.phase_progress()
	elif mode == Mode.SCREAM and _scream_stage == ScreamStage.WINDUP:
		telegraph.circle_visible = true
		telegraph.circle_center = global_position
		telegraph.circle_radius = scream_reach
