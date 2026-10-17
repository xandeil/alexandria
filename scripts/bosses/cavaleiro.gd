class_name CavaleiroDesolado
extends Boss
## O Cavaleiro Desolado — chefe final, no Núcleo.
## Bíblia: "Não é um vilão clássico. [...] o objetivo nunca foi conquista, foi
## proteção. Ele protege quem está ligada ao núcleo; enquanto ela existir, a
## ilha flutua e o ciclo continua." Leitura da Bíblia: ele é o que restou do
## Cientista da Gravidade — por isso luta com a gravidade.
##
## A REGRA DA LUTA é a dele: ficar SEMPRE entre você e ela.
## FASE 1 — O Guardião:
##   • Espadão em até três tempos (o terceiro, pesado: "A Promessa").
##   • Apanhou três vezes seguidas? Ergue a guarda: de frente quase nada entra,
##     e quem bate na guarda leva o contragolpe. Contorne ou espere.
##   • Você longe dele: a mão se abre e a GRAVIDADE puxa você (o dash escapa).
## FASE 2 — A Promessa (metade da vida; não dá para pular):
##   • Pedras de mármore caem do alto (círculos no chão).
##   • Um anel de gravidade empurra para longe (atravesse com o dash).
##   • Ajoelhado diante dela, RENOVA O ELO: uma linha de luz a liga a ele e o
##     cura. Fique no caminho da luz para cortar a cura — proteção virou prisão.

enum Mode { DECIDE, APPROACH, ATTACK, GUARD, PULL, STONES, REPEL, KNEEL, TRANSITION, DEAD }

const SPEECH_INTRO := "...Não. Não chegue perto dela."
const SPEECH_PHASE_2 := "Eu prometi. Não lembro a quem... mas prometi."
const SPEECH_KNEEL := "Fique comigo. Só mais um pouco."
const SPEECH_DEFEAT := "...Eu só queria que ela não caísse."

@export var combo: Array[AttackData] = []
@export var guard_radius := 56.0
@export var reach_to_attack := 46.0

@export_group("Fase 1 — O Guardião")
@export var guard_after_hits := 3
@export var guard_time := 1.4
@export_range(0.0, 1.0) var guard_ratio := 0.1
@export var pull_range := 130.0
@export var pull_windup := 0.8
@export var pull_time := 1.3
@export var pull_speed := 58.0

@export_group("Fase 2 — A Promessa")
@export var stones_every := 7.0
@export var stone_count := 5
@export var stone_damage := 22.0
@export var stone_radius := 18.0
@export var repel_every := 11.0
@export var repel_damage := 14.0
@export var kneel_every := 16.0
@export var kneel_time := 3.4
@export_range(0.0, 0.1) var kneel_heal_per_second := 0.03
@export var bond_width := 12.0

@onready var telegraph: TelegraphDrawer = $Telegraph

var phase := 1
var mode := Mode.DECIDE
var woman: Node2D
var _mode_time := 0.0
var _clock := 0.0
var _combo_index := 0
var _hits := 0
var _hit_clock := 0.0
var _stones_timer := 4.0
var _repel_timer := 7.0
var _kneel_timer := 10.0
var _healed := 0.0


func enter_arena(_landing: Vector2) -> void:
	visible = true
	ready_to_fight.emit()


func start_fight() -> void:
	super.start_fight()
	speech.emit(SPEECH_INTRO)
	Sfx.play(&"bell", -6.0)
	_go_decide(1.0)


func phase_label() -> String:
	return "O Guardião" if phase == 1 else "A Promessa"


func victory_subtitle() -> String:
	return "A Promessa — Proteção que virou prisão"


func _set_mode(new_mode: Mode) -> void:
	mode = new_mode
	_mode_time = 0.0


func _go_decide(delay: float) -> void:
	_set_mode(Mode.DECIDE)
	_mode_time = -delay


## O ponto que ele quer ocupar: entre você e ela, a guard_radius dela.
func guard_point() -> Vector2:
	if not is_instance_valid(woman) or target == null:
		return global_position
	var away := (target.global_position - woman.global_position).normalized()
	if away == Vector2.ZERO:
		away = Vector2.DOWN
	return woman.global_position + away * guard_radius


func _physics_process(delta: float) -> void:
	_clock += delta
	_mode_time += delta
	_hit_clock -= delta
	if dead:
		velocity = Vector2.ZERO
		_update_visual()
		return
	if woman == null or not is_instance_valid(woman):
		woman = get_tree().get_first_node_in_group(&"nucleo_core") as Node2D
	target = find_target()
	if active and phase == 1 and mode != Mode.TRANSITION and stats.health_ratio() <= 0.5:
		_enter_promise()
	if active and target and not target.is_dead():
		if phase == 2:
			_stones_timer -= delta
			_repel_timer -= delta
			_kneel_timer -= delta
		match mode:
			Mode.DECIDE:
				velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
				if _mode_time >= 0.0:
					_decide()
			Mode.APPROACH:
				_approach(delta)
			Mode.ATTACK:
				velocity = _runner.step(delta, velocity)
			Mode.GUARD:
				velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
				facing = facing.slerp((target.global_position - global_position).normalized(), minf(4.0 * delta, 1.0))
				if _mode_time >= guard_time:
					_go_decide(0.2)
			Mode.PULL:
				_pull(delta)
			Mode.STONES, Mode.REPEL:
				velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
				if _mode_time >= 0.9:
					_go_decide(0.4)
			Mode.KNEEL:
				_kneel(delta)
			Mode.TRANSITION:
				velocity = Vector2.ZERO
	else:
		velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	move_and_slide()
	_update_visual()


# --- Decidir -----------------------------------------------------------------------

func _decide() -> void:
	var to_target := target.global_position - global_position
	var distance := to_target.length()
	facing = to_target.normalized()
	if phase == 2:
		if _kneel_timer <= 0.0 and is_instance_valid(woman):
			start_kneel()
			return
		if _stones_timer <= 0.0:
			rain_stones()
			return
		if _repel_timer <= 0.0 and distance < 90.0:
			repel()
			return
	if distance <= reach_to_attack:
		_combo_index = 0
		_next_cut()
		return
	if distance > pull_range:
		start_pull()
		return
	_set_mode(Mode.APPROACH)


## Anda até o ponto de guarda (ou até você, se você já está perto dela).
func _approach(delta: float) -> void:
	var goal := guard_point()
	if target.global_position.distance_to(global_position) < reach_to_attack * 1.6:
		goal = target.global_position
	var to_goal := goal - global_position
	facing = (target.global_position - global_position).normalized()
	if to_goal.length() > 4.0:
		velocity = velocity.move_toward(to_goal.normalized() * move_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	if global_position.distance_to(target.global_position) <= reach_to_attack or _mode_time >= 1.4:
		_go_decide(0.0)


func _next_cut() -> void:
	var count := 2 if phase == 1 else 3
	if _combo_index >= mini(count, combo.size()):
		_go_decide(0.7)
		return
	_set_mode(Mode.ATTACK)
	facing = (target.global_position - global_position).normalized()
	start_attack(combo[_combo_index], facing)
	_combo_index += 1


func _on_attack_finished() -> void:
	if mode == Mode.ATTACK:
		if target and global_position.distance_to(target.global_position) <= reach_to_attack * 1.4:
			_next_cut()
		else:
			_go_decide(0.5)


func track_target_during_windup() -> void:
	pass


# --- Fase 1: guarda e gravidade ------------------------------------------------------

## A mão se abre e a gravidade puxa o herói para perto (o dash escapa).
func start_pull() -> void:
	_set_mode(Mode.PULL)
	Sfx.play(&"gravity", -2.0)


func _pull(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	facing = (target.global_position - global_position).normalized()
	var pulling := _mode_time >= pull_windup and _mode_time < pull_windup + pull_time
	if pulling and not target.is_dead() and not target.hurtbox.invulnerable and not target.is_grabbed():
		target.move_and_collide((global_position - target.global_position).normalized() * pull_speed * delta)
	if _mode_time >= pull_windup + pull_time:
		_go_decide(0.2)


func is_pulling() -> bool:
	return mode == Mode.PULL and _mode_time >= pull_windup and _mode_time < pull_windup + pull_time


## De frente, na guarda, quase nada entra — e o golpe na guarda é respondido.
func _incoming_damage_multiplier(info: HitInfo) -> float:
	if mode != Mode.GUARD:
		return 1.0
	var toward := info.source_position - global_position
	return guard_ratio if absf(rad_to_deg(facing.angle_to(toward))) <= 75.0 else 1.0


func _on_damaged(_amount: float, _info: HitInfo, blocked: bool) -> void:
	if blocked and mode == Mode.GUARD:
		# Bateu na guarda: o contragolpe (o corte pesado).
		_combo_index = 2 if combo.size() > 2 else 0
		_next_cut()
		return
	if phase != 1 or mode == Mode.ATTACK or mode == Mode.TRANSITION:
		return
	_hits = _hits + 1 if _hit_clock > 0.0 else 1
	_hit_clock = 2.0
	if _hits >= guard_after_hits:
		_hits = 0
		_set_mode(Mode.GUARD)
		Sfx.play(&"clang", -4.0)


# --- Fase 2: a promessa ------------------------------------------------------------

func _enter_promise() -> void:
	phase = 2
	_runner.cancel()
	hitbox.deactivate()
	_set_mode(Mode.TRANSITION)
	hurtbox.invulnerable = true
	phase_changed.emit(phase_label())
	speech.emit(SPEECH_PHASE_2)
	Sfx.play(&"boss_phase")
	Sfx.play(&"bell", -2.0)
	Fx.shake(4.0, 0.6)
	_stones_timer = 2.0
	_repel_timer = 6.0
	_kneel_timer = 9.0
	await wait(2.0)
	if dead:
		return
	hurtbox.invulnerable = false
	_go_decide(0.2)


## Pedras de mármore caem do alto: círculos no chão (um sempre em cima de você).
func rain_stones() -> void:
	_stones_timer = stones_every
	for i in stone_count:
		var at := target.global_position
		if i > 0:
			at += Vector2.from_angle(TAU * i / stone_count + randf()) * randf_range(30.0, 70.0)
		if arena_rect.size != Vector2.ZERO:
			at = clamp_to_arena(at, 16.0)
		FleshBurst.spawn(get_parent(), at, stone_radius, 1.0 + i * 0.12, stone_damage, self, false,
			at + Vector2(randf_range(-20.0, 20.0), -150.0), "pedra")
	Sfx.play(&"gravity", -4.0, 0.1)
	_set_mode(Mode.STONES)


## Um anel de gravidade que empurra para longe (o dash atravessa).
func repel() -> void:
	_repel_timer = repel_every
	var ring := ScreamRing.launch(get_parent(), global_position + Vector2(0, -10), self, repel_damage, 150.0, 170.0)
	ring.knockback = 280.0
	Sfx.play(&"gravity", 0.0)
	Fx.shake(4.0, 0.4)
	_set_mode(Mode.REPEL)


func start_kneel() -> void:
	_kneel_timer = kneel_every
	_healed = 0.0
	speech.emit(SPEECH_KNEEL)
	Sfx.play(&"bell", -6.0)
	_set_mode(Mode.KNEEL)


## Ajoelhado diante dela: a luz o cura — a não ser que você fique no caminho.
func _kneel(delta: float) -> void:
	if not is_instance_valid(woman):
		_go_decide(0.0)
		return
	var spot := woman.global_position + (global_position - woman.global_position).normalized() * 30.0
	if global_position.distance_to(spot) > 6.0 and _mode_time < 1.0:
		velocity = velocity.move_toward((spot - global_position).normalized() * move_speed * 1.5, acceleration * delta)
		return
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	facing = (woman.global_position - global_position).normalized()
	if not bond_blocked():
		var heal := stats.max_health * kneel_heal_per_second * delta
		stats.set_health(minf(stats.health + heal, stats.max_health))
		_healed += heal
	if _mode_time >= kneel_time:
		_go_decide(0.3)


## Você está no caminho da luz entre ela e ele? (corta a cura)
func bond_blocked() -> bool:
	if target == null or not is_instance_valid(woman):
		return false
	var closest := Geometry2D.get_closest_point_to_segment(target.global_position, woman.global_position, global_position)
	return closest.distance_to(target.global_position) <= bond_width


func is_kneeling() -> bool:
	return mode == Mode.KNEEL


# --- Dano e morte -------------------------------------------------------------------

func _can_be_staggered() -> bool:
	return mode == Mode.DECIDE or mode == Mode.APPROACH or mode == Mode.KNEEL


func _on_poise_broken(_info: HitInfo) -> void:
	_go_decide(stagger_time)


func _on_died() -> void:
	if phase == 1:
		stats.revive()
		stats.set_health(stats.max_health * 0.5)  # dano enorme não pula a Promessa
		_enter_promise()
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
	for burst in get_tree().get_nodes_in_group("flesh_bursts"):
		burst.queue_free()
	speech.emit(SPEECH_DEFEAT)
	if data:
		Game.mark_boss_defeated(data.id)
	Sfx.play(&"boss_phase")
	Sfx.play(&"bell", -2.0)
	Fx.slow_motion(0.25, 0.9)
	# Ele não some: fica ajoelhado diante dela. A escolha é sua agora.
	fight_won.emit(self)


# --- Visual -------------------------------------------------------------------------

func _update_visual() -> void:
	if absf(facing.x) > 0.1:
		body_sprite.flip_h = facing.x < 0.0
	var anim := &"idle"
	match mode:
		Mode.APPROACH:
			anim = &"walk"
		Mode.ATTACK:
			anim = &"ergue" if _runner.phase == AttackRunner.Phase.WINDUP else &"corte"
		Mode.GUARD:
			anim = &"guarda"
		Mode.PULL, Mode.REPEL, Mode.STONES:
			anim = &"atrai"
		Mode.KNEEL, Mode.DEAD, Mode.TRANSITION:
			anim = &"ajoelha"
	if body_sprite.animation != anim:
		body_sprite.play(anim)
	telegraph.circle_visible = mode == Mode.PULL and _mode_time < pull_windup
	if telegraph.circle_visible:
		telegraph.circle_center = global_position
		telegraph.circle_radius = pull_range
		telegraph.circle_progress = _mode_time / pull_windup
	queue_redraw()


## A gravidade (linhas que puxam) e o elo de luz entre ela e ele.
func _draw() -> void:
	if is_pulling() and target:
		var to := target.global_position - global_position
		for k in 3:
			var t := fmod(_clock * 1.6 + k / 3.0, 1.0)
			draw_line(to * (1.0 - t) + Vector2(0, -8), to * (1.0 - t - 0.1) + Vector2(0, -8), Color(0.85, 0.85, 1.0, 0.6), 2.0)
	if mode == Mode.KNEEL and is_instance_valid(woman):
		var from := woman.global_position - global_position + Vector2(0, -20)
		var color := Color(1.0, 0.9, 0.55, 0.25 if bond_blocked() else 0.7)
		draw_line(from, Vector2(0, -16), color, bond_width * (0.5 if bond_blocked() else 1.0))
		draw_line(from, Vector2(0, -16), Color(1, 1, 1, 0.5), 2.0)
