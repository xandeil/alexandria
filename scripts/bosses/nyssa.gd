class_name NyssaLumevel
extends Boss
## Nyssa Lumevel, A Que Não Desperta — Pecado da Preguiça (Bosque do Sono Eterno).
##
## Bíblia:
##   Fase 1 — O Sonho Leve: "ela flutua deitada e quase não ataca. O bosque luta
##   por ela com pólen, sonâmbulos e lentidão. Uma Barra de Sonolência sobe
##   quando o jogador fica parado, se cura ou fica perto das flores. Cheia, ele
##   adormece por 2 a 3 segundos. Atacar faz a barra descer, então a luta obriga
##   o jogador a ser agressivo."
##   Fase 2 — O Pesadelo (metade da vida): "a arena vira o sonho dela. Áreas
##   escuras do chão somem, e ela invoca ecos fracos de chefes já derrotados,
##   cada um com um único ataque."
##   Significado: "Preguiça não é cansaço do corpo; é desistir de mudar porque
##   mudar dói."
##
## Implementação: ela quase não tem golpes PRÓPRIOS. Quem luta são os sistemas
## que o Bosque já ensinou (Sonolência, sonâmbulos, pólen, buracos do Aldir,
## ecos da Governanta). Chefe novo com pouca arte nova — a dica da Bíblia.

enum Mode { DRIFT, TRANSITION, DEAD }

const SLEEPER_SCENE := preload("res://scenes/enemies/sonambulo.tscn")
const DREAM_SHADOW := preload("res://assets/fx/dream_shadow.png")
const DREAM_HOLE := preload("res://assets/fx/dream_hole.png")
## Ecos possíveis — só aparecem os de chefes que o herói JÁ venceu.
const ECHO_POOL := ["governanta", "aldir", "helena", "sargento", "couraca", "vigia", "mae_esporos"]
const NIGHTMARE_LIGHT := Color(0.55, 0.5, 0.8)

const SPEECH_INTRO := "Você acorda tudo o que toca. Como a minha irmã... Durma."
const SPEECH_INTRO_QUIET := "Você passou pelo Vigia sem acordá-lo... Então você entende. Fique. Ninguém precisa acordar."
const SPEECH_PHASE_2 := "Então você não vai dormir. ...Então eu sonho por nós dois."
const SPEECH_ROLL := "Mmm... só mais um pouco..."
const SPEECH_DEFEAT := "...Faz tanto tempo que eu não via ninguém acordado. Diga à minha irmã... que eu sonhei com ela."

@export_group("Movimento")
@export var drift_speed := 0.25
@export var nightmare_drift_speed := 0.45
@export var drift_size := Vector2(70, 34)
@export var hover_height := 14.0

@export_group("Sono (as regras da luta)")
## Sonolência por segundo: herói PARADO.
@export var still_drowsiness := 22.0
## ...bebendo um frasco.
@export var heal_drowsiness := 40.0
## ...perto de uma Flor de Pólen.
@export var flower_drowsiness := 10.0
@export var flower_distance := 56.0

@export_group("Fase 1 — O Sonho Leve")
@export var bubble_every := 4.0
@export var max_sleepwalkers := 3
@export var sleepwalker_every := 14.0
## Bateram nela tantas vezes em pouco tempo: ela "vira de lado" (anel de sono).
@export var roll_hits := 4
@export var roll_window := 2.0

@export_group("Fase 2 — O Pesadelo")
@export var nightmare_bubble_every := 5.0
@export var pit_every := 5.0
@export var pit_life := 5.0
@export var echo_every := 6.5

@onready var telegraph: TelegraphDrawer = $Telegraph

var phase := 1
var mode := Mode.DRIFT
var sleepers: Array[Enemy] = []
var pits: Array[ArenaPit] = []

var _drift_angle := 0.0
var _bubble_timer := 2.0
var _sleeper_timer := 0.0
var _pit_timer := 2.0
var _echo_timer := 3.0
var _recent_hits: Array[float] = []
var _roll_cooldown := 0.0
var _intro_timer := 0.6
var _clock := 0.0
var _center := Vector2.ZERO


func _ready() -> void:
	super._ready()
	_center = global_position


func enter_arena(_landing: Vector2) -> void:
	visible = true
	_center = arena_rect.get_center() if arena_rect.size != Vector2.ZERO else global_position
	ready_to_fight.emit()


func start_fight() -> void:
	super.start_fight()
	_center = arena_rect.get_center() if arena_rect.size != Vector2.ZERO else global_position
	for i in 2:
		_spawn_sleeper()
	_sleeper_timer = sleepwalker_every


func phase_label() -> String:
	return "O Sonho Leve" if phase == 1 else "O Pesadelo"


func _physics_process(delta: float) -> void:
	_clock += delta
	if dead:
		_update_visual(delta)
		return
	target = find_target()
	# O Pesadelo começa na METADE da vida — venha o dano de onde vier (golpe,
	# queda, efeito). Checar só no "levou golpe" deixaria brechas.
	if active and phase == 1 and mode == Mode.DRIFT and stats.health_ratio() <= 0.5:
		_enter_nightmare()
	if active and target:
		match mode:
			Mode.DRIFT:
				_drift(delta)
				_sleep_pressure(delta)
				_spawn_pressure(delta)
			Mode.TRANSITION:
				pass
	_close_old_pits()
	_update_visual(delta)


# --- Movimento: flutua num "oito" preguiçoso em volta do centro -----------------

func _drift(delta: float) -> void:
	_drift_angle += delta * (drift_speed if phase == 1 else nightmare_drift_speed)
	var goal := _center + Vector2(cos(_drift_angle) * drift_size.x, sin(_drift_angle * 2.0) * drift_size.y)
	global_position = global_position.move_toward(goal, 40.0 * delta)
	if _intro_timer > 0.0:
		_intro_timer -= delta
		if _intro_timer <= 0.0:
			speech.emit(SPEECH_INTRO_QUIET if Game.has_flag("vigia_evitado") else SPEECH_INTRO)


# --- A regra da luta: quem desiste, dorme --------------------------------------------

func _sleep_pressure(delta: float) -> void:
	if target.is_dead() or target.is_asleep():
		return
	if target.state == Player.State.HEAL:
		target.add_drowsiness(heal_drowsiness * delta)
	elif target.velocity.length() < 10.0 and (target.state == Player.State.FREE or target.state == Player.State.BLOCK):
		target.add_drowsiness(still_drowsiness * delta)
	for node in get_tree().get_nodes_in_group("enemies"):
		var flower := node as FlorDePolen
		if flower and not flower.dead and flower.global_position.distance_to(target.global_position) <= flower_distance:
			target.add_drowsiness(flower_drowsiness * delta)


func _spawn_pressure(delta: float) -> void:
	_bubble_timer -= delta
	if _bubble_timer <= 0.0:
		_bubble_timer = bubble_every if phase == 1 else nightmare_bubble_every
		DreamBubble.spawn(get_parent(), global_position, self)
	_roll_cooldown = maxf(_roll_cooldown - delta, 0.0)
	if phase == 1:
		_sleeper_timer -= delta
		if _sleeper_timer <= 0.0:
			_sleeper_timer = sleepwalker_every
			_spawn_sleeper()
		return
	_pit_timer -= delta
	if _pit_timer <= 0.0:
		_pit_timer = pit_every
		open_dream_pits()
	_echo_timer -= delta
	if _echo_timer <= 0.0:
		_echo_timer = echo_every
		summon_echo()


## "O bosque luta por ela": um Sonâmbulo já acordado, vindo do lado da arena.
func _spawn_sleeper() -> void:
	for i in range(sleepers.size() - 1, -1, -1):
		if not is_instance_valid(sleepers[i]) or sleepers[i].dead:
			sleepers.remove_at(i)
	if sleepers.size() >= max_sleepwalkers or target == null:
		return
	var sleeper := SLEEPER_SCENE.instantiate() as Sonambulo
	var side := Vector2.from_angle(randf() * TAU)
	sleeper.position = clamp_to_arena(_center + Vector2(side.x * 150.0, side.y * 80.0), 20.0)
	sleeper.memory_reward = 0  # convocados não pagam (senão vira "fazenda")
	get_parent().add_child(sleeper)
	sleeper.wake(target.global_position)
	sleepers.append(sleeper)
	Fx.splash(sleeper.global_position + Vector2(0, -12), Color(0.8, 0.72, 1.0), 8)


# --- Fase 2: o chão some e os ecos voltam -------------------------------------------

## Duas manchas escuras perto do herói: avisam (1 s), viram buraco, voltam depois.
func open_dream_pits() -> void:
	if target == null:
		return
	for i in 2:
		var offset := Vector2.from_angle(randf() * TAU) * randf_range(10.0, 56.0)
		var at := clamp_to_arena(target.global_position + offset, 24.0)
		var pit := ArenaPit.create(at, Vector2(19, 12), 1.0)
		pit.crack_texture = DREAM_SHADOW
		pit.hole_texture = DREAM_HOLE
		pit.set_meta("born", _clock)
		get_parent().add_child(pit)
		pits.append(pit)


func _close_old_pits() -> void:
	for i in range(pits.size() - 1, -1, -1):
		var pit := pits[i]
		if not is_instance_valid(pit):
			pits.remove_at(i)
		elif _clock - float(pit.get_meta("born")) >= pit.warning_time + pit_life:
			pit.close()
			pits.remove_at(i)


## Os chefes que o herói já venceu (no mínimo o Aldir: o Bosque abre depois dele).
func echo_pool() -> Array:
	var pool := ECHO_POOL.filter(func(id: String): return Game.is_boss_defeated(id))
	return pool if not pool.is_empty() else ["aldir"]


func summon_echo(boss_id: String = "") -> DreamEcho:
	if target == null:
		return null
	if boss_id.is_empty():
		boss_id = echo_pool().pick_random()
	var at := clamp_to_arena(target.global_position + Vector2.from_angle(randf() * TAU) * randf_range(70.0, 95.0), 20.0)
	return DreamEcho.spawn(get_parent(), at, boss_id, self)


# --- Dano, fases ------------------------------------------------------------------

func _on_damaged(_amount: float, _info: HitInfo, _blocked: bool) -> void:
	if dead:
		return
	_recent_hits.append(_clock)
	_recent_hits = _recent_hits.filter(func(t: float): return _clock - t <= roll_window)
	if _recent_hits.size() >= roll_hits and _roll_cooldown <= 0.0 and mode == Mode.DRIFT:
		# Colado nela batendo sem parar: ela vira de lado e o sono escorre.
		_roll_cooldown = 4.0
		_recent_hits.clear()
		speech.emit(SPEECH_ROLL)
		SleepRing.spawn(get_parent(), global_position, 80.0, 30.0)


func _can_be_staggered() -> bool:
	return false  # ela nem acorda direito para cambalear


func _enter_nightmare() -> void:
	phase = 2
	mode = Mode.TRANSITION
	hurtbox.invulnerable = true
	phase_changed.emit(phase_label())
	speech.emit(SPEECH_PHASE_2)
	Sfx.play(&"boss_phase")
	Fx.shake(4.0, 0.5)
	_dismiss_sleepers()
	_set_light(NIGHTMARE_LIGHT, 1.6)
	await wait(2.2)
	if dead:
		return
	hurtbox.invulnerable = false
	mode = Mode.DRIFT
	_pit_timer = 0.5
	_echo_timer = 2.0


func _on_died() -> void:
	if phase == 1:
		# Dano enorme de uma vez: não pula o Pesadelo.
		stats.revive()
		stats.set_health(stats.max_health * 0.5)
		_enter_nightmare()
		return
	dead = true
	active = false
	mode = Mode.DEAD
	remove_from_group("enemies")
	hurtbox.set_deferred("monitorable", false)
	telegraph.clear()
	_dismiss_sleepers()
	for pit in pits:
		if is_instance_valid(pit):
			pit.close()
	pits.clear()
	for group in ["dream_bubbles", "dream_echoes"]:
		for node in get_tree().get_nodes_in_group(group):
			node.queue_free()
	_set_light(Color.WHITE, 2.0, true)
	speech.emit(SPEECH_DEFEAT)
	var reward := data.memory_reward if data else 1300
	Game.add_memories(reward)
	if target:
		Fx.memory_motes(global_position + Vector2(0, -14), target, 22)
	Sfx.play(&"boss_phase")
	Fx.slow_motion(0.25, 0.8)
	# Ela se deita de novo, devagar... e se desfaz em pó lilás.
	var tween := create_tween()
	tween.tween_interval(1.0)
	tween.tween_property(visual, "modulate", Color(1.6, 1.5, 2.0, 0.0), 1.6)
	await tween.finished
	fight_won.emit(self)


func _dismiss_sleepers() -> void:
	for sleeper in sleepers:
		if is_instance_valid(sleeper) and not sleeper.dead:
			Fx.splash(sleeper.global_position + Vector2(0, -12), Color(0.8, 0.72, 1.0), 6)
			sleeper.queue_free()
	sleepers.clear()


## Escurece (ou devolve) a luz da área inteira — "a arena vira o sonho dela".
## restore = true volta à cor original da fase.
func _set_light(color: Color, seconds: float, restore: bool = false) -> void:
	var level := _level()
	if level == null:
		return
	var goal := level.darkness if restore else level.darkness * color
	create_tween().tween_property(level.canvas_modulate, "color", goal, seconds)


func _level() -> Level:
	var node := get_parent()
	while node and not node is Level:
		node = node.get_parent()
	return node as Level


# --- Visual ----------------------------------------------------------------------

func _update_visual(_delta: float) -> void:
	var anim := &"deitada" if phase == 1 or dead else &"sentada"
	if mode == Mode.TRANSITION:
		anim = &"conjura"
	if body_sprite.animation != anim:
		body_sprite.play(anim)
	if target and absf(target.global_position.x - global_position.x) > 4.0 and phase == 2:
		body_sprite.flip_h = target.global_position.x < global_position.x
	visual.position.y = -hover_height + sin(_clock * 1.6) * 3.0
