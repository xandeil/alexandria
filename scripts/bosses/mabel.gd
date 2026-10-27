class_name MabelVoragine
extends Boss
## Mabel Vorágine, A Fome Que Lembra — Pecado da Gula (Raízes da Fome).
##
## Bíblia:
##   História: "Mabel cuidava das estufas e das colheitas de Alexandria.
##   Alimentava funcionários e cobaias, e muitos a chamavam de mãe. Quando a
##   imortalidade chegou, ninguém mais precisou comer, e ela perdeu o motivo de
##   existir. Então provou a humanidade líquida... Não parou mais."
##   Fase 1 — A Anfitriã: "lenta e enorme. Tapas de palma aberta, arremesso de
##   frutos de carne que explodem e um agarrão. Se agarrar o jogador, engole e
##   drena memórias até ele escapar."
##   Fase 2 — A Vorágine (metade da vida): "come os próprios lacaios e raízes
##   para se curar e crescer. Uma boca se abre no ventre, o ponto fraco. Cortar
##   as raízes ligadas a ela interrompe a cura."
##   Dica: "O agarrão é um estado de 'preso': o jogador toca rápido no botão de
##   ataque para escapar e, a cada segundo preso, perde uma parte das memórias."
##
## Leitura para o jogador:
##   • Tapa: leque vermelho no chão, lento. Dash para trás ou para o lado.
##   • Frutos: círculos no chão onde eles vão cair. Saia de dentro.
##   • Agarrão: LINHA vermelha da mão até você — travou (pisca), esquive.
##     Engolido: toque rápido no Ataque. Escapou? Ela engasga: bata à vontade.
##   • Fase 2: as Raízes-Veia curam Mabel e cospem lacaios. Corte as raízes,
##     mate os lacaios antes que ela os coma, e bata no VENTRE (de frente).

enum Mode { SEATED, DECIDE, APPROACH, ATTACK, THROW, REACH, SWALLOW, GAG, EAT, TRANSITION, DEAD }

const LARVA_SCENE := preload("res://scenes/enemies/larva_seiva.tscn")
const INCHADO_SCENE := preload("res://scenes/enemies/inchado.tscn")
const ROOT_SCENE := preload("res://scenes/bosses/raiz_veia.tscn")

const SPEECH_INTRO := "Ah, visita! Sente-se, sente-se... Faz tanto tempo que ninguém come à minha mesa."
const SPEECH_GRAB := "Deixa eu provar... só um pouquinho de você."
const SPEECH_GAG := "Amargo! ...De quem é esse gosto?"
const SPEECH_PHASE_2 := "Ainda estou com FOME. Por que eu ainda estou com fome?!"
const SPEECH_EAT := "Mais..."
const SPEECH_ROOTS_CUT := "Não... não tirem a minha mesa..."
const SPEECH_DEFEAT := "...Eu só queria... que alguém dissesse que estava bom."
## O que ela "prova" enquanto engole (Bíblia: "sentia lembranças alheias").
const TASTED := [
	"Hmm... o primeiro beijo de um guarda.",
	"Um aniversário... velas... quem era essa criança?",
	"Pão quente. Alguém fazia pão para você.",
	"Uma música que você cantava sem saber a letra...",
	"Mãos dadas numa fila. Você tinha medo.",
]

@export var slap: AttackData
@export var slap_back: AttackData
@export var belly_bite: AttackData

@export_group("Fase 1 — A Anfitriã")
@export var slap_range := 46.0
@export var fruit_count := 3
@export var fruit_radius := 22.0
@export var fruit_damage := 22.0
@export var fruit_flight := 1.0
@export var throw_every := 5.0
@export var reach_length := 92.0
@export var reach_windup := 0.95
@export var reach_every := 7.5
## Engasgo depois que o herói escapa: janela para punir.
@export var gag_time := 2.4

@export_group("Agarrão (engolir)")
@export var grab_taps := 9
@export var grab_damage_per_second := 7.0
@export var grab_memory_ratio := 0.05
@export var grab_memory_min := 8
## Cada segundo engolindo, ela se cura isso (fração da vida máxima).
@export_range(0.0, 0.2) var swallow_heal := 0.015

@export_group("Fase 2 — A Vorágine")
@export var root_count := 4
## Cura por segundo POR RAIZ viva (fração da vida máxima).
@export_range(0.0, 0.05) var root_heal_per_second := 0.006
@export var root_regrow_every := 16.0
@export var lackey_every := 7.0
@export var max_lackeys := 4
@export var eat_windup := 1.0
@export_range(0.0, 0.5) var eat_heal := 0.06
@export var eat_every := 5.0
## Cresce a cada lacaio comido (até max_growth).
@export var growth_per_meal := 0.05
@export var max_growth := 1.25
## Golpes no ventre (de frente) na fase 2.
@export var belly_multiplier := 1.5
## ...e com a boca escancarada (comendo ou engasgada).
@export var open_belly_multiplier := 2.0

@onready var telegraph: TelegraphDrawer = $Telegraph

var phase := 1
var mode := Mode.SEATED
var roots: Array[Enemy] = []
var lackeys: Array[Enemy] = []
var growth := 1.0

var _mode_time := 0.0
var _clock := 0.0
var _throw_timer := 2.5
var _reach_timer := 4.0
var _reach_dir := Vector2.RIGHT
var _reach_hit := false
var _combo: Array[AttackData] = []
var _lackey_timer := 3.0
var _regrow_timer := 0.0
var _eat_timer := 2.0
var _meal: Enemy
var _eat_started := false
var _weak_text_cooldown := 0.0
var _root_slots: Array[Vector2] = []
var _all_roots_cut_said := false
var _tasted_said := false


func enter_arena(_landing: Vector2) -> void:
	visible = true
	_set_mode(Mode.SEATED)
	ready_to_fight.emit()


func start_fight() -> void:
	super.start_fight()
	speech.emit(SPEECH_INTRO)
	Sfx.play(&"step_heavy")
	Fx.dust(global_position, 14)
	_go_decide(1.2)


func phase_label() -> String:
	return "A Anfitriã" if phase == 1 else "A Vorágine"


func _set_mode(new_mode: Mode) -> void:
	mode = new_mode
	_mode_time = 0.0


func _go_decide(delay: float) -> void:
	_set_mode(Mode.DECIDE)
	_mode_time = -delay


func _physics_process(delta: float) -> void:
	_clock += delta
	_mode_time += delta
	if dead:
		velocity = Vector2.ZERO
		_update_visual(delta)
		return
	target = find_target()
	if active and phase == 1 and mode != Mode.TRANSITION and stats.health_ratio() <= 0.5:
		_enter_phase_2()
	if active and target and not target.is_dead():
		_throw_timer -= delta
		_reach_timer -= delta
		_eat_timer -= delta
		_weak_text_cooldown -= delta
		match mode:
			Mode.DECIDE:
				_decide(delta)
			Mode.APPROACH:
				_approach(delta)
			Mode.ATTACK:
				velocity = _runner.step(delta, velocity)
			Mode.THROW:
				_throw(delta)
			Mode.REACH:
				_reach(delta)
			Mode.SWALLOW:
				_swallow(delta)
			Mode.GAG:
				velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
				if _mode_time >= gag_time:
					_go_decide(0.3)
			Mode.EAT:
				_eat(delta)
			Mode.TRANSITION:
				velocity = Vector2.ZERO
		if phase == 2:
			_feed_from_roots(delta)
			_spawn_lackeys(delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	move_and_slide()
	_update_visual(delta)


# --- Decidir ------------------------------------------------------------------------

func _decide(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	if _mode_time < 0.0:
		return
	var to_target := target.global_position - global_position
	var distance := to_target.length()
	facing = to_target.normalized()
	_prune()
	# Fase 2: ferida e com lacaio por perto → vai comer.
	if phase == 2 and _eat_timer <= 0.0 and stats.health_ratio() < 0.95:
		_meal = _nearest_lackey(160.0)
		if _meal:
			_eat_started = false
			_set_mode(Mode.EAT)
			return
	if distance <= slap_range:
		if phase == 2 and distance < 34.0 and randf() < 0.35:
			_queue_combo([belly_bite])
		elif randf() < 0.45:
			_queue_combo([slap, slap_back])
		else:
			_queue_combo([slap])
		return
	if _reach_timer <= 0.0 and distance <= reach_length - 6.0:
		_start_reach()
		return
	if _throw_timer <= 0.0:
		_start_throw()
		return
	_set_mode(Mode.APPROACH)


func _approach(delta: float) -> void:
	var to_target := target.global_position - global_position
	facing = to_target.normalized()
	var speed := move_speed / growth
	velocity = velocity.move_toward(facing * speed, acceleration * delta)
	if to_target.length() <= slap_range - 4.0 or _mode_time >= 1.8:
		_go_decide(0.0)


# --- Tapas -------------------------------------------------------------------------

func _queue_combo(attacks: Array) -> void:
	_combo.assign(attacks)
	_next_in_combo()


func _next_in_combo() -> void:
	if _combo.is_empty():
		_go_decide(0.5 if phase == 1 else 0.3)
		return
	var attack: AttackData = _combo.pop_front()
	_set_mode(Mode.ATTACK)
	facing = (target.global_position - global_position).normalized()
	start_attack(attack, facing)
	Sfx.play(&"telegraph", -6.0)


func _on_attack_finished() -> void:
	if mode == Mode.ATTACK:
		_next_in_combo()


func track_target_during_windup() -> void:
	pass  # ela é lenta demais para corrigir a mira: o leque no chão é honesto


# --- Frutos de carne -------------------------------------------------------------------

func _start_throw() -> void:
	_set_mode(Mode.THROW)
	_throw_timer = throw_every * (0.8 if phase == 2 else 1.0)
	Sfx.play(&"swing_heavy", -6.0)


func _throw(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	if _mode_time >= 0.6 and _mode_time - delta < 0.6:
		throw_fruits()
	if _mode_time >= 1.1:
		_go_decide(0.4)


## Um fruto em cima do herói e os outros em volta (círculos avisam onde caem).
func throw_fruits() -> void:
	var count := fruit_count + (2 if phase == 2 else 0)
	var hand := global_position + Vector2(0, -48 * growth)
	for i in count:
		var at := target.global_position
		if i > 0:
			at += Vector2.from_angle(TAU * i / (count - 1) + randf() * 0.5) * randf_range(28.0, 52.0)
		at = clamp_to_arena(at, 16.0)
		var flight := fruit_flight + i * 0.12
		FleshBurst.spawn(get_parent(), at, fruit_radius, flight, fruit_damage, self, false, hand)


# --- Agarrão: engolir --------------------------------------------------------------------

func _start_reach() -> void:
	_set_mode(Mode.REACH)
	_reach_hit = false
	_reach_dir = (target.global_position - global_position).normalized()
	_reach_timer = reach_every * (0.75 if phase == 2 else 1.0)
	Sfx.play(&"telegraph", -3.0)


func _reach_windup() -> float:
	return reach_windup * (0.75 if phase == 2 else 1.0)


func _reach(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	var windup := _reach_windup()
	if _mode_time < windup * 0.7:
		_reach_dir = (target.global_position - global_position).normalized()  # depois TRAVA
		facing = _reach_dir
	if _mode_time >= windup and not _reach_hit:
		_reach_hit = true
		Sfx.play(&"swing_heavy", -2.0)
		if _hand_touches(target.global_position):
			if target.grab(self, grab_taps, Vector2(4, 0), grab_damage_per_second, grab_memory_ratio, grab_memory_min, true):
				speech.emit(SPEECH_GRAB)
				Sfx.play(&"gulp")
				_tasted_said = false
				_set_mode(Mode.SWALLOW)
				return
	if _mode_time >= windup + 0.8:
		_go_decide(0.3)


## A mão vai em linha reta: acerta quem estiver a até 12 px da linha.
func _hand_touches(point: Vector2) -> bool:
	var from := global_position + Vector2(0, -8)
	var to := from + _reach_dir * reach_length
	var closest := Geometry2D.get_closest_point_to_segment(point + Vector2(0, -8), from, to)
	return closest.distance_to(point + Vector2(0, -8)) <= 12.0


func _swallow(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	if not target.is_grabbed_by(self):
		# Escapou de dentro dela: engasga (e fica aberta).
		_set_mode(Mode.GAG)
		speech.emit(SPEECH_GAG)
		Sfx.play(&"gulp", 0.0, 0.2)
		Fx.splash(global_position + Vector2(0, -30), Color(0.62, 0.1, 0.16), 16)
		Fx.shake(4.0, 0.3)


## Chamado pelo herói a cada segundo engolido (Player._state_grabbed).
func on_memories_drained(amount: int) -> void:
	stats.heal(stats.max_health * swallow_heal)
	if not _tasted_said:
		_tasted_said = true
		speech.emit(TASTED.pick_random())
	Fx.float_text(global_position + Vector2(-6, -60 * growth), "nham", Color(1.0, 0.75, 0.7), 7)
	if amount > 0:
		Sfx.play(&"slurp", -6.0, 0.1)


# --- Fase 2: raízes, lacaios e o ventre ---------------------------------------------------

func _enter_phase_2() -> void:
	phase = 2
	_combo.clear()
	_runner.cancel()
	hitbox.deactivate()
	if target and target.is_grabbed_by(self):
		target.release_grab()
	_set_mode(Mode.TRANSITION)
	hurtbox.invulnerable = true
	phase_changed.emit(phase_label())
	speech.emit(SPEECH_PHASE_2)
	Sfx.play(&"boss_phase")
	Sfx.play(&"roar", -2.0)
	Fx.shake(5.0, 0.6)
	_root_slots = _make_root_slots()
	for slot in _root_slots:
		grow_root(slot)
	await wait(2.2)
	if dead:
		return
	hurtbox.invulnerable = false
	_lackey_timer = 2.0
	_regrow_timer = root_regrow_every
	_eat_timer = 3.0
	_go_decide(0.2)


## Quatro pontos em volta do centro da arena (perto das bordas).
func _make_root_slots() -> Array[Vector2]:
	var center := arena_rect.get_center() if arena_rect.size != Vector2.ZERO else global_position
	var half := arena_rect.size * 0.5 - Vector2(40, 34) if arena_rect.size != Vector2.ZERO else Vector2(110, 70)
	var slots: Array[Vector2] = []
	for i in root_count:
		var angle := TAU * i / root_count + PI * 0.25
		slots.append(center + Vector2(cos(angle) * half.x, sin(angle) * half.y))
	return slots


func grow_root(at: Vector2) -> RaizVeia:
	var root := ROOT_SCENE.instantiate() as RaizVeia
	root.position = at
	root.feeds = self
	get_parent().add_child(root)
	roots.append(root)
	Sfx.play(&"root_burst", -4.0, 0.15)
	return root


func living_roots() -> int:
	var count := 0
	for root in roots:
		if is_instance_valid(root) and not root.dead:
			count += 1
	return count


## Cada raiz viva bombeia vida para ela. Todas cortadas: a cura para.
func _feed_from_roots(delta: float) -> void:
	_prune()
	var alive := living_roots()
	if alive == 0 and not _all_roots_cut_said and mode != Mode.TRANSITION:
		_all_roots_cut_said = true
		speech.emit(SPEECH_ROOTS_CUT)
	if alive > 0:
		_all_roots_cut_said = false
		if stats.health < stats.max_health and mode != Mode.TRANSITION:
			stats.heal(stats.max_health * root_heal_per_second * alive * delta)
	_regrow_timer -= delta
	if _regrow_timer <= 0.0:
		_regrow_timer = root_regrow_every
		if alive < 2 and not _root_slots.is_empty():
			grow_root(_free_root_slot())


func _free_root_slot() -> Vector2:
	for slot in _root_slots:
		var taken := false
		for root in roots:
			if is_instance_valid(root) and not root.dead and root.global_position.distance_to(slot) < 8.0:
				taken = true
		if not taken:
			return slot
	return _root_slots.pick_random()


## Das raízes saem os lacaios (sem raiz, sem lacaio novo).
func _spawn_lackeys(delta: float) -> void:
	_lackey_timer -= delta
	if _lackey_timer > 0.0 or mode == Mode.TRANSITION:
		return
	_lackey_timer = lackey_every
	if lackeys.size() >= max_lackeys:
		return
	var sources: Array[Enemy] = []
	for root in roots:
		if is_instance_valid(root) and not root.dead:
			sources.append(root)
	if sources.is_empty():
		return
	var from: Enemy = sources.pick_random()
	var scene := INCHADO_SCENE if randf() < 0.25 else LARVA_SCENE
	var lackey := scene.instantiate() as Enemy
	lackey.position = from.global_position + Vector2(randf_range(-8, 8), 10)
	lackey.memory_reward = 0
	get_parent().add_child(lackey)
	lackeys.append(lackey)
	Fx.splash(lackey.global_position + Vector2(0, -6), Color(0.62, 0.1, 0.16), 8)


func _prune() -> void:
	for list: Array[Enemy] in [roots, lackeys]:
		for i in range(list.size() - 1, -1, -1):
			if not is_instance_valid(list[i]) or list[i].dead:
				list.remove_at(i)


func _nearest_lackey(max_distance: float) -> Enemy:
	var best: Enemy = null
	var best_distance := max_distance
	for lackey in lackeys:
		var d := global_position.distance_to(lackey.global_position)
		if d < best_distance:
			best = lackey
			best_distance = d
	return best


func _eat(delta: float) -> void:
	if not is_instance_valid(_meal) or _meal.dead:
		_go_decide(0.2)
		return
	var to_meal := _meal.global_position - global_position
	if not _eat_started:
		facing = to_meal.normalized()
		if to_meal.length() > 28.0:
			velocity = velocity.move_toward(facing * move_speed * 1.4 / growth, acceleration * delta)
			if _mode_time > 3.0:
				_eat_timer = eat_every
				_go_decide(0.0)
			return
		_eat_started = true
		_mode_time = 0.0
		speech.emit(SPEECH_EAT)
		Sfx.play(&"telegraph", -3.0)
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	_meal.velocity = Vector2.ZERO
	if _mode_time >= eat_windup:
		devour(_meal)
		_meal = null
		_eat_started = false
		_eat_timer = eat_every
		_go_decide(0.6)


## Come um lacaio: cura e CRESCE (mais lenta, mais vida).
func devour(meal: Enemy) -> void:
	var heal := stats.max_health * eat_heal
	stats.heal(heal)
	growth = minf(growth + growth_per_meal, max_growth)
	lackeys.erase(meal)
	meal.queue_free()
	Sfx.play(&"chomp")
	Sfx.play(&"gulp", -3.0)
	Fx.splash(global_position + Vector2(0, -30), Color(0.62, 0.1, 0.16), 14)
	Fx.float_text(global_position + Vector2(-8, -64 * growth), "+%d" % int(heal), Color(0.6, 1.0, 0.6), 9)


# --- Dano --------------------------------------------------------------------------

## Fase 2: o VENTRE é o ponto fraco — golpes de frente doem mais (e muito mais
## com a boca escancarada: comendo ou engasgada).
func _incoming_damage_multiplier(info: HitInfo) -> float:
	if mode == Mode.GAG:
		return open_belly_multiplier
	if phase < 2:
		return 1.0
	var toward := info.source_position - global_position
	var front := toward == Vector2.ZERO or absf(rad_to_deg(facing.angle_to(toward))) <= 70.0
	if not front:
		return 1.0
	var multiplier := open_belly_multiplier if (mode == Mode.EAT and _eat_started) else belly_multiplier
	if _weak_text_cooldown <= 0.0:
		_weak_text_cooldown = 1.5
		Fx.float_text(global_position + Vector2(-18, -40), "PONTO FRACO", Color(1.0, 0.85, 0.5), 7)
	return multiplier


func _on_damaged(_amount: float, info: HitInfo, _blocked: bool) -> void:
	# Golpe forte no meio da "refeição": ela larga a comida.
	if mode == Mode.EAT and _eat_started and info.is_heavy:
		Fx.float_text(global_position + Vector2(-14, -50), "interrompida", Color(1.0, 0.85, 0.6), 7)
		_meal = null
		_eat_started = false
		_eat_timer = eat_every
		_go_decide(0.8)


func _can_be_staggered() -> bool:
	return mode == Mode.DECIDE or mode == Mode.APPROACH or mode == Mode.EAT or mode == Mode.THROW


func _on_poise_broken(_info: HitInfo) -> void:
	_combo.clear()
	_meal = null
	_eat_started = false
	_set_mode(Mode.GAG)  # cambaleia de boca aberta: mesma janela do engasgo
	_mode_time = gag_time - stagger_time


func _on_died() -> void:
	if phase == 1:
		# Dano enorme de uma vez: não pula a Vorágine.
		stats.revive()
		stats.set_health(stats.max_health * 0.5)
		_enter_phase_2()
		return
	dead = true
	active = false
	_set_mode(Mode.DEAD)
	_runner.cancel()
	hitbox.deactivate()
	telegraph.clear()
	if target and target.is_grabbed_by(self):
		target.release_grab()
	remove_from_group("enemies")
	hurtbox.set_deferred("monitorable", false)
	set_deferred("collision_layer", 0)
	for list: Array[Enemy] in [roots, lackeys]:
		for node in list:
			if is_instance_valid(node) and not node.dead:
				node.stats.take_damage(9999.0)
		list.clear()
	for burst in get_tree().get_nodes_in_group("flesh_bursts"):
		burst.queue_free()
	speech.emit(SPEECH_DEFEAT)
	var reward := data.memory_reward if data else 1400
	Game.earn_memories(reward)
	if target:
		Fx.memory_motes(global_position + Vector2(0, -20), target, 24)
	Sfx.play(&"boss_phase")
	Fx.slow_motion(0.25, 0.8)
	# Ela senta devagar... e se desfaz em branco, como todo mundo.
	var tween := create_tween()
	tween.tween_property(visual, "scale", Vector2(growth * 1.05, growth * 0.9), 0.8)
	tween.tween_interval(0.8)
	tween.tween_property(visual, "modulate", Color(2.0, 2.0, 2.2, 0.0), 1.6)
	tween.tween_callback(queue_free)
	fight_won.emit(self)


# --- Visual ----------------------------------------------------------------------

func _update_visual(_delta: float) -> void:
	if absf(facing.x) > 0.05 and mode != Mode.DEAD:
		body_sprite.flip_h = facing.x < 0.0
	var anim := &"idle" if phase == 1 else &"idle2"
	match mode:
		Mode.APPROACH:
			anim = &"walk" if phase == 1 else &"walk2"
		Mode.EAT:
			anim = (&"come" if _eat_started else &"walk2")
		Mode.ATTACK:
			if _current_attack == belly_bite:
				anim = &"come"
			else:
				anim = &"tapa_prepara" if _runner.phase == AttackRunner.Phase.WINDUP else &"tapa"
		Mode.THROW:
			anim = &"arremesso"
		Mode.REACH:
			anim = &"agarrao" if _mode_time >= _reach_windup() else &"tapa_prepara"
		Mode.SWALLOW:
			anim = &"engole"
		Mode.GAG:
			anim = &"engole" if phase == 1 else &"come"
		Mode.TRANSITION:
			anim = &"engole"
	if body_sprite.animation != anim:
		body_sprite.play(anim)
	if mode != Mode.DEAD:
		var breathe := sin(_clock * 2.0) * 0.015
		visual.scale = Vector2(growth, growth * (1.0 + breathe))
	if mode == Mode.TRANSITION or mode == Mode.GAG:
		visual.position.x = sin(_clock * 40.0) * 1.5
	else:
		visual.position.x = 0.0
	_update_telegraph()
	queue_redraw()


func _update_telegraph() -> void:
	telegraph.line_visible = false
	telegraph.arc_visible = false
	telegraph.circle_visible = false
	if mode == Mode.REACH and _mode_time < _reach_windup():
		telegraph.line_visible = true
		telegraph.line_origin = global_position + Vector2(0, -8)
		telegraph.line_direction = _reach_dir
		telegraph.line_length = reach_length
		telegraph.line_locked = _mode_time >= _reach_windup() * 0.7
	elif mode == Mode.EAT and _eat_started:
		telegraph.circle_visible = true
		telegraph.circle_center = global_position
		telegraph.circle_radius = 20.0
		telegraph.circle_progress = _mode_time / eat_windup
	elif mode == Mode.ATTACK and _runner.phase == AttackRunner.Phase.WINDUP and _current_attack:
		telegraph.arc_visible = true
		telegraph.arc_center = global_position
		telegraph.arc_direction = _runner.direction
		telegraph.arc_radius = _current_attack.reach + _current_attack.radius
		telegraph.arc_angle = deg_to_rad(_current_attack.slash_arc_degrees)
		telegraph.arc_progress = _runner.phase_progress()


## As raízes ligadas a ela: linhas vermelhas que "bombeiam" (fase 2).
func _draw() -> void:
	if phase < 2 or dead:
		return
	var beat := 0.5 + 0.5 * sin(_clock * 5.0)
	for root in roots:
		if not is_instance_valid(root) or root.dead:
			continue
		var to := root.global_position + Vector2(0, -10) - global_position
		var from := Vector2(0, -20)
		draw_line(from, to, Color(0.35, 0.06, 0.1, 0.8), 3.0)
		draw_line(from, to, Color(0.95, 0.25, 0.25, 0.35 + 0.4 * beat), 1.0)
		# um "pulso" correndo da raiz até ela
		var t := fmod(_clock * 0.8 + root.global_position.x * 0.01, 1.0)
		draw_circle(to.lerp(from, t), 2.0, Color(1.0, 0.45, 0.4, 0.9))
