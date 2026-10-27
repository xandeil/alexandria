class_name AldirCornelios
extends Boss
## Ira — Aldir Cornélios, O Detentor do Caos. Arena: Praça do Detentor (Cidade Estilhaçada).
##
## Da Bíblia:
##   • Fase 1 — O Soldado que Ainda Pensa: martelo de guerra gigante, golpes
##     pesados e calculados que quebram o chão, técnica militar e algumas falas.
##   • Fase 2 — O Caos (metade da vida): a razão some; golpes brutais e
##     imprevisíveis; destrói o cenário, inclusive as coberturas da fase 1.
##
## A ARENA É A MECÂNICA (a "mecânica única" da ficha dele):
##   • Golpe Sísmico: a Onda de Choque corre pelo chão. As coberturas de concreto
##     (DestructibleCover) seguram a onda — esconda-se atrás delas na fase 1.
##   • O martelo abre BURACOS (ArenaPit): o chão racha (aviso) e desaba. Quem
##     anda para dentro cai; o dash passa por cima.
##   • Fase 2: cada martelada abre um buraco, ele salta, avança em linha reta e
##     quebra as coberturas. Imprevisível no TEMPO, mas sempre com aviso no chão.
##
## Reaproveita tudo da base: AttackRunner (Step and Anchor), AttackData (.tres),
## Hitbox/Hurtbox, postura, BossArena, barra de chefe. Só o comportamento é novo.

enum Mode { DORMANT, RISING, DECIDE, APPROACH, ATTACK, LEAP, CHARGE, STUNNED, TRANSITION, DEAD }
enum LeapStage { TELEGRAPH, AIR, LAND }
enum ChargeStage { TELEGRAPH, RUN, RECOVER }

# Falas provisórias (reescreva!). A Ira dele é impotência: não protegeu ninguém.
const SPEECH_INTRO := "Mais um recruta. Quem te mandou? ...Ninguém manda mais ninguém."
const SPEECH_PHASE_1 := [
	"Postura. Respira. Golpe. Eu ainda lembro.",
	"Eu avisei que o fogo vinha. Ninguém ouviu.",
	"De pé, recruta. A cidade não espera.",
]
const SPEECH_COVER := "Atrás da cobertura. Bom. Foi o que eu ensinei."
const SPEECH_PHASE_2 := "CHEGA DE PENSAR. Se eu não protejo nada... eu quebro tudo."
const SPEECH_PHASE_2_RANDOM := [
	"Inimigo, aliado... TANTO FAZ!",
	"QUEM É VOCÊ?!",
	"Era para eu estar lá!",
]
const SPEECH_DEFEAT := "Eu tinha alguém para proteger... Não lembro o nome."
const PHASE_LABELS := ["Fase 1 — O Soldado que Ainda Pensa", "Fase 2 — O Caos"]
## No máximo tantos buracos abertos: o mais velho entope de entulho.
const MAX_PITS := 6
## Abertura do leque de ondas da fase 2 (radianos).
const FAN_ANGLE := 0.42

@export_group("Golpes")
@export var martelada: AttackData
@export var varredura: AttackData
@export var empurrao: AttackData
@export var sismico: AttackData
@export var caos: AttackData
@export var caos_final: AttackData

@export_group("Onda de Choque")
@export var shockwave_damage := 24.0
@export var shockwave_speed := 170.0
@export var shockwave_distance := 280.0

@export_group("Salto (fase 2)")
@export var leap_damage := 34.0
@export var leap_radius := 30.0
@export var leap_air_time := 0.6
@export var leap_telegraph_time := 0.85

@export_group("Investida (fase 2)")
@export var charge_damage := 30.0
@export var charge_speed := 280.0
@export var charge_max_time := 0.8
@export var charge_telegraph_time := 0.75
## Bateu na parede: fica tonto — a janela de punição da investida.
@export var stun_time := 1.2

@export_group("Buracos")
@export var pit_radius := Vector2(19, 12)

@onready var kneel_sprite: Sprite2D = $Visual/Kneel
@onready var eyes: Sprite2D = $Visual/Eyes
@onready var hammer_pivot: Node2D = $Visual/HammerPivot
@onready var hammer: Sprite2D = $Visual/HammerPivot/Hammer
@onready var telegraph: TelegraphDrawer = $Telegraph
@onready var shadow: Sprite2D = $Shadow

var phase := 1
var mode := Mode.DORMANT

var _mode_time := 0.0
var _decision_delay := 0.0
var _combo_queue: Array[AttackData] = []
var _pits: Array[ArenaPit] = []
var _speech_cooldown := 8.0
var _intro_said := false
var _cover_line_said := false
var _close_time := 0.0
var _flank_side := 1.0
var _base_speed := 0.0
var _leap_stage := LeapStage.TELEGRAPH
var _leap_from := Vector2.ZERO
var _leap_to := Vector2.ZERO
var _charge_stage := ChargeStage.TELEGRAPH
var _charge_dir := Vector2.RIGHT
var _transition_token := 0
var _pose_tween: Tween


func _ready() -> void:
	super._ready()
	_base_speed = move_speed
	kneel_sprite.visible = true
	body_sprite.visible = false
	eyes.visible = false
	eyes.material = Fx.unshaded  # olhos em brasa brilham no escuro
	hammer_pivot.rotation = PI * 0.5  # cravado no chão diante dele
	hammer_pivot.position = Vector2(11, -28)


# --- Entrada e início da luta ------------------------------------------------------

## Ele já está na arena, ajoelhado diante do martelo: pronto para quando você entrar.
func enter_arena(_landing: Vector2) -> void:
	visible = true
	_set_mode(Mode.DORMANT)
	ready_to_fight.emit()


func start_fight() -> void:
	super.start_fight()
	kneel_sprite.visible = false
	body_sprite.visible = true
	_set_mode(Mode.RISING)
	Sfx.play(&"step_heavy")
	Fx.dust(global_position, 10)
	var tween := _restart_pose_tween()
	visual.scale = Vector2(1.1, 0.85)
	tween.tween_property(visual, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func phase_label() -> String:
	return PHASE_LABELS[clampi(phase - 1, 0, PHASE_LABELS.size() - 1)]


## Quanto um golpe dele estraga as coberturas: na fase 1 ele "ainda pensa".
func cover_damage_multiplier() -> float:
	return 0.15 if phase == 1 else 3.0


# --- Loop ------------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	_mode_time += delta
	target = find_target()
	if active:
		regen_poise(delta)
		_speech_cooldown -= delta
	match mode:
		Mode.DORMANT, Mode.DEAD, Mode.TRANSITION:
			velocity = velocity.move_toward(Vector2.ZERO, 900.0 * delta)
		Mode.RISING:
			velocity = Vector2.ZERO
			if not _intro_said and _mode_time >= 0.25:
				_intro_said = true
				speech.emit(SPEECH_INTRO)
			if _mode_time >= 1.3:
				_go_decide(0.3)
		Mode.DECIDE:
			_decide(delta)
		Mode.APPROACH:
			_approach(delta)
		Mode.ATTACK:
			track_target_during_windup()
			velocity = _runner.step(delta, velocity)
		Mode.LEAP:
			_leap(delta)
		Mode.CHARGE:
			_charge(delta)
		Mode.STUNNED:
			velocity = velocity.move_toward(Vector2.ZERO, 900.0 * delta)
			if _mode_time >= stun_time:
				_go_decide(0.2)
	if not (mode == Mode.LEAP and _leap_stage == LeapStage.AIR):
		move_and_slide()
		if mode == Mode.CHARGE and _charge_stage == ChargeStage.RUN:
			_check_charge_collisions()
	if mode != Mode.DORMANT and mode != Mode.DEAD:
		update_body_animation(delta)
	_update_hammer(delta)
	_update_telegraph()


func _set_mode(new_mode: Mode) -> void:
	mode = new_mode
	_mode_time = 0.0
	if new_mode == Mode.APPROACH:
		_flank_side = 1.0 if randf() < 0.5 else -1.0


func _go_decide(delay: float) -> void:
	_set_mode(Mode.DECIDE)
	_decision_delay = delay


## Pausa entre ações. Fase 2: curta e irregular — "imprevisível".
func _rest_time() -> float:
	return randf_range(0.7, 1.1) if phase == 1 else randf_range(0.25, 0.6)


## Multiplicador do windup. Na fase 2 varia a cada golpe: o tempo engana, o aviso não.
func _windup_scale() -> float:
	return 1.0 if phase == 1 else randf_range(0.72, 1.05)


func _speed() -> float:
	return _base_speed * (1.0 if phase == 1 else 1.35)


# --- Decisões --------------------------------------------------------------------------

func _decide(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	if target == null:
		return
	var to_target := target.global_position - global_position
	facing = to_target.normalized()
	var distance := to_target.length()
	_close_time = _close_time + delta if distance < 40.0 else 0.0
	_decision_delay -= delta
	if _decision_delay > 0.0:
		return
	var behind_cover := _cover_between() != null
	if phase == 1:
		_decide_phase_1(distance, behind_cover)
	else:
		_decide_phase_2(distance, behind_cover)


## O Soldado que Ainda Pensa: escolhe o golpe pela distância, flanqueia a cobertura.
func _decide_phase_1(distance: float, behind_cover: bool) -> void:
	if behind_cover:
		_say_cover_line()
		_set_mode(Mode.APPROACH)  # contorna a cobertura, como manda o manual
		return
	var roll := randf()
	if distance < 38.0:
		if _close_time > 1.2 and roll < 0.6:
			_queue_combo([empurrao])  # "Distância, recruta." Empurra (às vezes para um buraco)
		elif roll < 0.55:
			_queue_combo([martelada])
		else:
			_queue_combo([varredura])
	elif distance < 140.0:
		if roll < 0.55:
			_queue_combo([sismico])
		else:
			_set_mode(Mode.APPROACH)
	else:
		_set_mode(Mode.APPROACH)
	_maybe_speak(SPEECH_PHASE_1)


## O Caos: brutal, variado, e a cobertura não salva mais ninguém.
func _decide_phase_2(distance: float, behind_cover: bool) -> void:
	if behind_cover:
		_start_charge()  # atravessa a cobertura
		return
	var roll := randf()
	if distance < 40.0:
		if roll < 0.55:
			_queue_combo(_chaos_combo())
		elif roll < 0.8:
			_queue_combo([varredura])
		else:
			_queue_combo([empurrao, caos_final])
	elif distance < 160.0:
		if roll < 0.35:
			_start_leap()
		elif roll < 0.65:
			_start_charge()
		else:
			_queue_combo([sismico])
	else:
		_start_leap()
	_maybe_speak(SPEECH_PHASE_2_RANDOM)


func _chaos_combo() -> Array[AttackData]:
	var combo: Array[AttackData] = []
	for i in randi_range(1, 2):
		combo.append(caos)
	combo.append(caos_final)
	return combo


func _approach(delta: float) -> void:
	if target == null:
		_go_decide(0.5)
		return
	var to_target := target.global_position - global_position
	facing = to_target.normalized()
	var heading := facing
	if phase == 1 and _cover_between() != null:
		heading = (facing + facing.orthogonal() * _flank_side * 1.3).normalized()
	velocity = velocity.move_toward(_avoid_pits(heading * _speed()), acceleration * delta)
	if to_target.length() <= 30.0 or _mode_time > 2.2:
		_go_decide(0.05)


## Desvia dos buracos abertos: um "campo de repulsão" simples (steering).
func _avoid_pits(desired: Vector2) -> Vector2:
	var push := Vector2.ZERO
	for pit in _pits:
		if not is_instance_valid(pit) or not pit.is_open():
			continue
		var away := global_position - pit.global_position
		var reach := pit.radius.x + 24.0
		var distance := away.length()
		if distance < reach and distance > 0.1:
			push += away / distance * (reach - distance) / reach
	if push == Vector2.ZERO or desired == Vector2.ZERO:
		return desired
	return (desired.normalized() + push * 1.6).normalized() * desired.length()


## Uma cobertura entre ele e o herói? (raio na camada "mundo")
func _cover_between() -> DestructibleCover:
	if target == null:
		return null
	var query := PhysicsRayQueryParameters2D.create(global_position + Vector2(0, -6), target.global_position + Vector2(0, -6), 1)
	query.exclude = [get_rid()]
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return null
	return hit.get("collider") as DestructibleCover


# --- Golpes do martelo ----------------------------------------------------------------

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
	if attack == sismico:
		Sfx.play(&"telegraph", -2.0)


func _on_attack_finished() -> void:
	if mode == Mode.ATTACK:
		_next_in_combo()


func _on_attack_phase_changed(new_phase: AttackRunner.Phase) -> void:
	super._on_attack_phase_changed(new_phase)
	if mode == Mode.ATTACK and _current_attack != null and new_phase == AttackRunner.Phase.ACTIVE:
		_hammer_impact(_current_attack)


## Onde a cabeça do martelo bate no chão.
func _impact_point(attack: AttackData) -> Vector2:
	return global_position + facing * (attack.reach + 2.0)


func _hammer_impact(attack: AttackData) -> void:
	var point := _impact_point(attack)
	if attack == varredura:
		Fx.shake(3.0, 0.15)
		Fx.dust(point, 8)
	elif attack == empurrao:
		Fx.shake(2.0, 0.1)
	elif attack == sismico:
		_slam_fx(point, 6.0)
		_open_pit(point + facing * 8.0)
		if phase == 1:
			_launch_waves(point, [facing])
		else:
			_launch_waves(point, [facing.rotated(-FAN_ANGLE), facing, facing.rotated(FAN_ANGLE)])
	elif attack == caos or attack == caos_final:
		_slam_fx(point, 5.0 if attack == caos else 7.0)
		_open_pit(point + facing * 6.0)
	else:  # martelada: na fase 1 racha o chão ("calculado"); na 2, abre buraco
		_slam_fx(point, 4.5)
		if phase == 2:
			_open_pit(point + facing * 6.0)
		else:
			_spawn_crack(point)


func _slam_fx(point: Vector2, strength: float) -> void:
	Fx.shake(strength, 0.25)
	Fx.dust(point, 12)
	Fx.sparks(point + Vector2(0, -4), Vector2.UP, Color(1.0, 0.62, 0.32), 10)
	Fx.vibrate(40)
	Sfx.play(&"slam", -1.0)


func _launch_waves(origin: Vector2, directions: Array) -> void:
	var speed := shockwave_speed * (1.15 if phase == 2 else 1.0)
	var cover_damage := 12.0 if phase == 1 else 30.0
	for direction in directions:
		Shockwave.launch(get_parent(), origin, direction, self, shockwave_damage, speed, shockwave_distance, cover_damage)


# --- Buracos e rachaduras -------------------------------------------------------------

func _open_pit(at: Vector2) -> ArenaPit:
	var margin := pit_radius.x + 6.0
	var point := clamp_to_arena(at, margin)
	var away := point - global_position
	if away.length() < pit_radius.x + 12.0:  # nunca embaixo dos próprios pés
		var direction := away.normalized() if away != Vector2.ZERO else facing
		point = clamp_to_arena(global_position + direction * (pit_radius.x + 14.0), margin)
	var pit := ArenaPit.create(point, pit_radius)
	get_parent().add_child(pit)
	_pits.append(pit)
	_trim_pits()
	return pit


## Mantém no máximo MAX_PITS buracos: o mais velho entope (a arena não some).
func _trim_pits() -> void:
	var alive: Array[ArenaPit] = []
	for pit in _pits:
		if is_instance_valid(pit) and pit.is_active():
			alive.append(pit)
	while alive.size() > MAX_PITS:
		alive.pop_front().fill()
	_pits = alive


func _spawn_crack(at: Vector2) -> void:
	var crack := Sprite2D.new()
	crack.texture = preload("res://assets/fx/crack_decal.png")
	crack.z_index = -9
	crack.flip_h = randf() < 0.5
	get_parent().add_child(crack)
	crack.global_position = at
	var tween := crack.create_tween()
	tween.tween_interval(6.0)
	tween.tween_property(crack, "modulate:a", 0.0, 1.5)
	tween.tween_callback(crack.queue_free)


func _random_arena_point() -> Vector2:
	var area := arena_rect.grow(-40.0) if arena_rect.size != Vector2.ZERO else Rect2(global_position - Vector2(120, 80), Vector2(240, 160))
	var best := area.get_center()
	for i in 12:
		var candidate := area.position + Vector2(randf() * area.size.x, randf() * area.size.y)
		var far_from_player := target == null or candidate.distance_to(target.global_position) > 60.0
		if far_from_player and candidate.distance_to(global_position) > 50.0:
			return candidate
		best = candidate
	return best


# --- Salto do martelo (fase 2) ----------------------------------------------------------

func _start_leap() -> void:
	if target == null:
		_go_decide(0.3)
		return
	_set_mode(Mode.LEAP)
	_leap_stage = LeapStage.TELEGRAPH
	_leap_from = global_position
	_leap_to = clamp_to_arena(target.global_position, 20.0)
	Sfx.play(&"telegraph", -2.0)


func _leap(_delta: float) -> void:
	var telegraph_time := leap_telegraph_time * 0.9
	match _leap_stage:
		LeapStage.TELEGRAPH:
			velocity = Vector2.ZERO
			# Acompanha o herói na primeira metade, depois TRAVA o ponto de queda.
			if target and _mode_time < telegraph_time * 0.5:
				_leap_to = clamp_to_arena(target.global_position, 20.0)
				facing = (_leap_to - global_position).normalized() if _leap_to != global_position else facing
			visual.scale = Vector2(1.12, 0.86)  # agacha antes de saltar
			if _mode_time >= telegraph_time:
				_leap_stage = LeapStage.AIR
				_mode_time = 0.0
				visual.scale = Vector2.ONE
				hurtbox.invulnerable = true
				Sfx.play(&"swing_heavy")
		LeapStage.AIR:
			var t := clampf(_mode_time / leap_air_time, 0.0, 1.0)
			global_position = _leap_from.lerp(_leap_to, t)
			visual.position.y = -sin(t * PI) * 42.0
			if t >= 1.0:
				_leap_stage = LeapStage.LAND
				_mode_time = 0.0
				visual.position.y = 0.0
				hurtbox.invulnerable = false
				_leap_impact()
		LeapStage.LAND:
			velocity = Vector2.ZERO
			if _mode_time >= 1.0:  # recuperação longa: a janela de punição
				_go_decide(_rest_time())


func _leap_impact() -> void:
	var squash := _restart_pose_tween()
	visual.scale = Vector2(1.2, 0.8)
	squash.tween_property(visual, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_slam_fx(global_position, 7.0)
	Fx.dust(global_position, 20)
	if target and target.global_position.distance_to(global_position) <= leap_radius:
		var info := HitInfo.create(leap_damage, global_position, target.global_position)
		info.knockback = 200.0
		info.poise_damage = 40.0
		info.is_heavy = true
		info.attack_name = "Salto do Martelo"
		info.source = self
		target.hurtbox.receive_hit(info)
	for node in get_tree().get_nodes_in_group(&"covers"):
		var cover := node as DestructibleCover
		if cover and cover.global_position.distance_to(global_position) <= leap_radius + 16.0:
			cover.smash()
	_open_pit(global_position + facing * (pit_radius.x + 16.0))
	_launch_waves(global_position, [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT])


# --- Investida (fase 2) ----------------------------------------------------------------

func _start_charge() -> void:
	if target == null:
		_go_decide(0.3)
		return
	_set_mode(Mode.CHARGE)
	_charge_stage = ChargeStage.TELEGRAPH
	_charge_dir = (target.global_position - global_position).normalized()
	facing = _charge_dir
	Sfx.play(&"roar", -8.0)


func _charge(delta: float) -> void:
	var telegraph_time := charge_telegraph_time * 0.9
	match _charge_stage:
		ChargeStage.TELEGRAPH:
			velocity = velocity.move_toward(Vector2.ZERO, 900.0 * delta)
			if target and _mode_time < telegraph_time * 0.7:  # depois disso a direção TRAVA
				_charge_dir = (target.global_position - global_position).normalized()
				facing = _charge_dir
			visual.scale = Vector2(0.92, 1.06)
			if _mode_time >= telegraph_time:
				_charge_stage = ChargeStage.RUN
				_mode_time = 0.0
				visual.scale = Vector2.ONE
				hitbox_pivot.rotation = _charge_dir.angle()
				(hitbox_shape.shape as CircleShape2D).radius = 14.0
				hitbox_shape.position = Vector2(14.0, 0.0)
				hitbox.activate_raw(charge_damage, 60.0, 260.0, true, "Investida")
				Sfx.play(&"swing_heavy")
		ChargeStage.RUN:
			velocity = _charge_dir * charge_speed
			if fmod(_mode_time, 0.06) < delta:
				Fx.dust(global_position, 2)
			if _mode_time >= charge_max_time or _pit_ahead(global_position + _charge_dir * 16.0):
				_end_charge(false)
		ChargeStage.RECOVER:
			velocity = velocity.move_toward(Vector2.ZERO, 900.0 * delta)
			if _mode_time >= 0.5:
				_go_decide(_rest_time())


## Bateu em algo durante a investida: cobertura quebra; parede deixa ele tonto.
func _check_charge_collisions() -> void:
	for i in get_slide_collision_count():
		var collider := get_slide_collision(i).get_collider()
		if collider is DestructibleCover:
			(collider as DestructibleCover).smash()
		elif collider is Player:
			continue
		elif collider != null:
			_end_charge(true)
			return


func _end_charge(hit_wall: bool) -> void:
	hitbox.deactivate()
	velocity = Vector2.ZERO
	if hit_wall:
		_slam_fx(global_position + _charge_dir * 10.0, 6.0)
		_set_mode(Mode.STUNNED)
		var side := -1.0 if body_sprite.flip_h else 1.0
		var tween := _restart_pose_tween()
		tween.tween_property(visual, "rotation", -0.2 * side, 0.15)
		tween.tween_property(visual, "rotation", 0.12 * side, 0.4)
		tween.tween_property(visual, "rotation", 0.0, 0.4)
	else:
		_charge_stage = ChargeStage.RECOVER
		_mode_time = 0.0


func _pit_ahead(point: Vector2) -> bool:
	for pit in _pits:
		if is_instance_valid(pit) and pit.contains_point(point):
			return true
	return false


# --- Dano, postura e fases ----------------------------------------------------------

func _on_damaged(_amount: float, _info: HitInfo, _blocked: bool) -> void:
	if phase == 1 and not stats.is_dead and stats.health <= stats.max_health * 0.5:
		_enter_phase_2()


func _can_be_staggered() -> bool:
	match mode:
		Mode.DECIDE, Mode.APPROACH, Mode.ATTACK, Mode.STUNNED:
			return true
		Mode.LEAP:
			return _leap_stage == LeapStage.LAND
		Mode.CHARGE:
			return _charge_stage == ChargeStage.RECOVER
	return false


## Postura quebrada (golpes fortes acumulados): cambaleio longo para punir.
func _on_poise_broken(_info: HitInfo) -> void:
	_combo_queue.clear()
	hitbox.deactivate()
	_set_mode(Mode.TRANSITION)
	var token := _new_transition_token()
	var side := -1.0 if body_sprite.flip_h else 1.0
	var tween := _restart_pose_tween()
	tween.tween_property(visual, "rotation", 0.18 * side, 0.12)
	tween.tween_property(visual, "rotation", 0.0, 0.6)
	Sfx.play(&"clang", -4.0)
	await wait(stagger_time)
	if token == _transition_token and mode == Mode.TRANSITION and not dead:
		_go_decide(0.15)


func _new_transition_token() -> int:
	_transition_token += 1
	return _transition_token


func _restart_pose_tween(reset_pose: bool = true) -> Tween:
	if _pose_tween and _pose_tween.is_valid():
		_pose_tween.kill()
	if reset_pose:
		visual.rotation = 0.0
		visual.scale = Vector2.ONE
	_pose_tween = create_tween()
	return _pose_tween


## Metade da vida: a razão some. Três marteladas no chão: as duas primeiras
## racham as coberturas, a terceira derruba todas (Bíblia: "destrói o cenário,
## inclusive as coberturas da fase 1"). Abrem os primeiros buracos; os olhos acendem.
func _enter_phase_2() -> void:
	phase = 2
	_set_mode(Mode.TRANSITION)
	_combo_queue.clear()
	_runner.cancel()
	hitbox.deactivate()
	telegraph.clear()
	hurtbox.invulnerable = true
	var token := _new_transition_token()
	phase_changed.emit(phase_label())
	speech.emit(SPEECH_PHASE_2)
	Sfx.play(&"roar")
	Sfx.play(&"boss_phase", -6.0)
	Fx.shake(7.0, 0.8)
	Fx.slow_motion(0.3, 0.45)
	eyes.visible = true
	visual.modulate = Color(1.08, 0.94, 0.9)
	for i in 3:
		await wait(0.45)
		if token != _transition_token or dead:
			return
		_slam_in_place(i)
	await wait(0.6)
	if token == _transition_token and not dead:
		hurtbox.invulnerable = false
		_go_decide(0.3)


func _slam_in_place(index: int) -> void:
	var tween := _restart_pose_tween()
	visual.scale = Vector2(1.15, 0.85)
	tween.tween_property(visual, "scale", Vector2.ONE, 0.25)
	_slam_fx(global_position + facing * 20.0, 5.0)
	_spawn_crack(global_position + Vector2(randf_range(-16.0, 16.0), 8.0))
	for node in get_tree().get_nodes_in_group(&"covers"):
		var cover := node as DestructibleCover
		if cover == null:
			continue
		if index < 2:
			cover.take_damage(cover.max_health * 0.26)
		else:
			cover.smash()
	if index >= 1:
		_open_pit(_random_arena_point())


func _on_died() -> void:
	if phase == 1:
		# Dano enorme de uma vez: não pula a fase 2.
		stats.revive()
		stats.set_health(stats.max_health * 0.5)
		_enter_phase_2()
		return
	dead = true
	active = false
	_new_transition_token()  # invalida esperas pendentes (transições, cambaleio)
	_set_mode(Mode.DEAD)
	_runner.cancel()
	hitbox.deactivate()
	telegraph.clear()
	remove_from_group("enemies")
	hurtbox.set_deferred("monitorable", false)
	set_deferred("collision_layer", 0)
	speech.emit(SPEECH_DEFEAT)
	var reward := data.memory_reward if data else 1200
	Game.earn_memories(reward)
	if target:
		Fx.memory_motes(global_position + Vector2(0, -14), target, 22)
	Sfx.play(&"boss_phase")
	Fx.slow_motion(0.25, 0.8)
	eyes.visible = false
	# Cai de joelhos e o martelo tomba à frente — do jeito que você o encontrou.
	body_sprite.visible = false
	kneel_sprite.visible = true
	var side := -1.0 if body_sprite.flip_h else 1.0
	var tween := _restart_pose_tween()
	tween.tween_property(hammer_pivot, "rotation", PI * 0.5, 0.35)
	tween.parallel().tween_property(hammer_pivot, "position", Vector2(11.0 * side, -28.0), 0.35)
	tween.tween_interval(1.4)
	# "A humanidade vira líquido": ele se desfaz em branco — e a sombra junto.
	tween.tween_property(visual, "modulate", Color(2.0, 2.0, 2.2, 0.0), 1.6)
	tween.parallel().tween_property(shadow, "modulate:a", 0.0, 1.6)
	tween.tween_callback(queue_free)  # os buracos ficam: o cenário conta a luta
	fight_won.emit(self)


# --- Visual do martelo e avisos no chão ---------------------------------------------------

func _update_hammer(delta: float) -> void:
	var side := -1.0 if body_sprite.flip_h else 1.0
	kneel_sprite.flip_h = body_sprite.flip_h
	eyes.flip_h = body_sprite.flip_h
	if mode == Mode.DEAD:
		return
	var rest_angle := (PI * 0.5 - 0.7) if side > 0.0 else (PI * 0.5 + 0.7)
	var target_angle := rest_angle
	var target_pos := Vector2(7.0 * side, -15.0)
	var snappy := false
	match mode:
		Mode.DORMANT:
			target_angle = PI * 0.5  # cravado no chão, cabeça para baixo
			target_pos = Vector2(11.0 * side, -28.0)
		Mode.ATTACK:
			if _runner.is_running() and _current_attack:
				snappy = true
				var aim := hitbox_pivot.rotation
				var progress := _runner.phase_progress()
				if _current_attack == varredura:
					var back := aim - 2.4 * side
					var front := aim + 1.6 * side
					match _runner.phase:
						AttackRunner.Phase.WINDUP:
							target_angle = lerp_angle(rest_angle, back, progress)
						AttackRunner.Phase.LUNGE:
							target_angle = back
						AttackRunner.Phase.ACTIVE:
							target_angle = lerp_angle(back, front, progress)
						_:
							target_angle = front
					target_pos = Vector2(0, -14)
				elif _current_attack == empurrao:
					target_angle = aim
					var pull := 6.0 * progress if _runner.phase == AttackRunner.Phase.WINDUP else -5.0
					target_pos = Vector2(0, -12) - Vector2.from_angle(aim) * pull
				else:  # marteladas: sobe acima da cabeça e crava no chão à frente
					match _runner.phase:
						AttackRunner.Phase.WINDUP:
							target_angle = lerp_angle(rest_angle, -PI * 0.5, minf(progress * 1.6, 1.0))
							target_pos = Vector2(0, -24)
						AttackRunner.Phase.LUNGE:
							target_angle = lerp_angle(-PI * 0.5, aim, 0.5)
							target_pos = Vector2(0, -20)
						_:
							target_angle = aim
							target_pos = Vector2(0, -8) + Vector2.from_angle(aim) * 4.0
		Mode.LEAP:
			snappy = true
			if _leap_stage == LeapStage.LAND:
				target_angle = facing.angle()
				target_pos = Vector2(0, -8) + facing * 4.0
			else:
				target_angle = -PI * 0.5
				target_pos = Vector2(0, -24)
		Mode.CHARGE:
			target_angle = _charge_dir.angle() + 0.5 * side
			target_pos = Vector2(0, -12)
		Mode.STUNNED:
			target_angle = PI * 0.5 + 0.25 * side  # martelo arrastando no chão
	var weight := minf(1.0, (30.0 if snappy else 10.0) * delta)
	hammer_pivot.rotation = lerp_angle(hammer_pivot.rotation, target_angle, weight)
	hammer_pivot.position = hammer_pivot.position.lerp(target_pos, minf(1.0, 16.0 * delta))
	hammer.flip_v = cos(hammer_pivot.rotation) < -0.01
	hammer_pivot.z_index = -1 if sin(hammer_pivot.rotation) < -0.35 else 1


func _update_telegraph() -> void:
	telegraph.hide_all()
	if mode == Mode.ATTACK and _current_attack and _runner.phase == AttackRunner.Phase.WINDUP:
		var progress := _runner.phase_progress()
		if _current_attack == varredura:
			telegraph.arc_visible = true
			telegraph.arc_center = global_position + Vector2(0, -2)
			telegraph.arc_direction = facing
			telegraph.arc_radius = varredura.reach + varredura.radius
			telegraph.arc_angle = deg_to_rad(200.0)
			telegraph.arc_progress = progress
		elif _current_attack != empurrao:
			telegraph.circle_visible = true
			telegraph.circle_center = _impact_point(_current_attack)
			telegraph.circle_radius = _current_attack.radius + 2.0
			telegraph.circle_progress = progress
			if _current_attack == sismico:
				telegraph.line_visible = true
				telegraph.line_origin = _impact_point(sismico)
				telegraph.line_direction = facing
				telegraph.line_length = 96.0
				telegraph.line_locked = not _runner.can_track_target()
				if phase == 2:
					telegraph.extra_line_directions.assign([facing.rotated(-FAN_ANGLE), facing.rotated(FAN_ANGLE)])
	elif mode == Mode.LEAP and _leap_stage != LeapStage.LAND:
		telegraph.circle_visible = true
		telegraph.circle_center = _leap_to
		telegraph.circle_radius = leap_radius
		telegraph.circle_progress = clampf(_mode_time / (leap_telegraph_time * 0.9), 0.0, 1.0) if _leap_stage == LeapStage.TELEGRAPH else 1.0
	elif mode == Mode.CHARGE and _charge_stage == ChargeStage.TELEGRAPH:
		telegraph.line_visible = true
		telegraph.line_origin = global_position + Vector2(0, -4)
		telegraph.line_direction = _charge_dir
		telegraph.line_length = charge_speed * charge_max_time
		telegraph.line_locked = _mode_time >= charge_telegraph_time * 0.9 * 0.7


# --- Falas -----------------------------------------------------------------------------

func _maybe_speak(lines: Array) -> void:
	if _speech_cooldown > 0.0 or randf() > 0.35:
		return
	_speech_cooldown = 14.0
	speech.emit(str(lines.pick_random()))


func _say_cover_line() -> void:
	if _cover_line_said:
		return
	_cover_line_said = true
	_speech_cooldown = 10.0
	speech.emit(SPEECH_COVER)
