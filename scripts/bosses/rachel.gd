class_name RachelCaelis
extends Boss
## Rachel Azheryon Caelis, O Orgulho do Céu — Pecado do Orgulho (Montanha Carbonizada).
##
## Bíblia:
##   História: "No continente de origem, os outros dragões ignoravam Rachel. Ela
##   não aceitou e partiu atrás de um lugar onde fosse soberana. Ao encontrar
##   Alexandria, não viu beleza, viu posse. Queimou cidades, começando pela de
##   Aldir... Dorme sobre as ruínas do mundo."
##   A luta (fase única): "Ela não é técnica nem emocional: é domínio.
##     Hálito de fogo massivo que cobre grandes áreas.
##     Golpes de cauda que quebram o chão.
##     Rugidos que derrubam estruturas e desestabilizam o jogador.
##     A arena desmorona aos poucos, encolhendo o espaço seguro."
##   Significado: "Orgulho é domínio sem arrependimento."
##
## Leitura para o jogador:
##   • HÁLITO: ela puxa a cabeça para trás (o leque no chão mostra a varredura)
##     e cospe fogo de um lado ao outro. As PEDRAS seguram o fogo — esconda-se.
##   • CAUDA: ficou atrás dela? A cauda varre um círculo e o chão quebra.
##   • RUGIDO: um anel que derruba você (atravesse com o dash) e DESTRÓI as
##     pedras da arena — o esconderijo de agora não é o de daqui a pouco.
##   • A cada quarto da vida perdida, a borda da arena desaba.

enum Mode { SLEEP, DECIDE, APPROACH, ATTACK, BREATH, TAIL, ROAR, DEAD }

const SPEECH_WAKE := "Quem ousa acordar a dona deste mundo?"
const SPEECH_CRUMBLE := ["Ajoelhe-se. O chão já está aprendendo.", "Tudo isto é meu. Até o abismo.", "Você ainda está de pé? Que insolência."]
const SPEECH_DEFEAT := "...Lá embaixo... ninguém olhava para mim. Aqui... tudo era meu."

@export var claw: AttackData
@export var bite: AttackData

@export_group("Hálito de fogo")
@export var breath_every := 6.0
@export var breath_windup := 1.1
@export var breath_time := 1.8
@export var breath_range := 190.0
@export var breath_sweep := 80.0
@export var breath_dps := 30.0
@export var breath_width := 14.0
@export var patch_every := 0.08

@export_group("Cauda")
@export var tail_windup := 0.8
@export var tail_radius := 54.0
@export var tail_damage := 34.0
@export var tail_pits := 2

@export_group("Rugido")
@export var roar_every := 15.0
@export var roar_windup := 0.7
@export var roar_reach := 180.0
@export var roar_damage := 12.0

@export_group("A arena desmorona")
## Frações da vida em que a borda desaba (uma faixa por vez).
@export var crumble_at: Array[float] = [0.75, 0.5, 0.25]
@export var crumble_step := 28.0
@export var crumble_spacing := 22.0

@onready var telegraph: TelegraphDrawer = $Telegraph

var mode := Mode.SLEEP
var crumbled := 0
var edge_pits: Array[ArenaPit] = []
var tail_pit_list: Array[ArenaPit] = []

var _mode_time := 0.0
var _clock := 0.0
var _breath_timer := 3.0
var _roar_timer := 9.0
var _breath_from := 0.0
var _breath_to := 0.0
var _breath_dir := Vector2.RIGHT
var _breath_end := Vector2.ZERO
var _patch_timer := 0.0
var _burn_timer := 0.0
var _tail_at := Vector2.ZERO
var _combo: Array[AttackData] = []


func enter_arena(_landing: Vector2) -> void:
	visible = true
	_set_mode(Mode.SLEEP)
	ready_to_fight.emit()


func start_fight() -> void:
	super.start_fight()
	speech.emit(SPEECH_WAKE)
	Sfx.play(&"roar", 0.0)
	Fx.shake(6.0, 0.8)
	_breath_timer = 3.0
	_roar_timer = roar_every * 0.6
	_go_decide(1.4)


func phase_label() -> String:
	return "Domínio" if crumbled == 0 else "Domínio · o chão cede (%d/%d)" % [crumbled, crumble_at.size()]


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
	if active:
		_check_crumble()
	if active and target and not target.is_dead():
		_breath_timer -= delta
		_roar_timer -= delta
		match mode:
			Mode.DECIDE:
				_decide(delta)
			Mode.APPROACH:
				_approach(delta)
			Mode.ATTACK:
				velocity = _runner.step(delta, velocity)
			Mode.BREATH:
				_breath(delta)
			Mode.TAIL:
				_tail(delta)
			Mode.ROAR:
				_roar(delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	move_and_slide()
	_update_visual(delta)


# --- Decidir -----------------------------------------------------------------------

func _decide(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	if _mode_time < 0.0:
		return
	var to_target := target.global_position - global_position
	var distance := to_target.length()
	var behind := absf(rad_to_deg(facing.angle_to(to_target))) > 110.0
	if behind and distance < tail_radius + 30.0:
		_start_tail()
		return
	facing = to_target.normalized()
	if _roar_timer <= 0.0:
		_start_roar()
		return
	# O hálito tem relógio próprio: colar nela NÃO evita o fogo (quem fica
	# grudado na garra ainda precisa achar uma pedra ou dar dash para o lado).
	if _breath_timer <= 0.0 or distance > 110.0:
		start_breath()
		return
	if distance < 44.0:
		_queue_combo([claw, bite] if randf() < 0.4 else [claw])
		return
	_set_mode(Mode.APPROACH)


func _approach(delta: float) -> void:
	var to_target := target.global_position - global_position
	facing = to_target.normalized()
	velocity = velocity.move_toward(facing * move_speed, acceleration * delta)
	if to_target.length() <= 42.0 or _mode_time >= 1.6:
		_go_decide(0.0)


func _queue_combo(attacks: Array) -> void:
	_combo.assign(attacks)
	_next_in_combo()


func _next_in_combo() -> void:
	if _combo.is_empty():
		_go_decide(0.6)
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
	pass


# --- Hálito de fogo -----------------------------------------------------------------

## A varredura vai de um lado ao outro, passando por cima do herói.
func start_breath() -> void:
	var center := (target.global_position - global_position).angle()
	var side := 1.0 if randf() < 0.5 else -1.0
	_breath_from = center - deg_to_rad(breath_sweep) * 0.5 * side
	_breath_to = center + deg_to_rad(breath_sweep) * 0.5 * side
	_breath_timer = breath_every
	facing = Vector2.from_angle(center)
	_set_mode(Mode.BREATH)
	Sfx.play(&"telegraph", -2.0)


func _mouth() -> Vector2:
	return global_position + Vector2(0, -14) + facing * 18.0


func _breath(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	if _mode_time < breath_windup:
		return
	if _mode_time - delta < breath_windup:
		Sfx.play(&"fire_breath", 2.0)
	var t := clampf((_mode_time - breath_windup) / breath_time, 0.0, 1.0)
	_breath_dir = Vector2.from_angle(lerp_angle(_breath_from, _breath_to, t))
	_breath_end = breath_hit_point(_breath_dir)
	_patch_timer -= delta
	if _patch_timer <= 0.0:
		_patch_timer = patch_every
		var along := _mouth().distance_to(_breath_end)
		var at := _mouth() + _breath_dir * randf_range(minf(30.0, along), along)
		FirePatch.spawn(get_parent(), at, 13.0, 3.0, 12.0, self)
	_burn_timer -= delta
	if _burn_timer <= 0.0:
		_burn_timer = 0.2
		if in_breath(target.global_position):
			target.apply_burn(breath_dps * 0.2)
	if t >= 1.0:
		_go_decide(0.8)


## Até onde o fogo chega nesta direção: para na primeira parede ou PEDRA.
func breath_hit_point(direction: Vector2) -> Vector2:
	var from := _mouth()
	var to := from + direction * breath_range
	var query := PhysicsRayQueryParameters2D.create(from, to, 1)
	query.exclude = [get_rid()]
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	return hit["position"] if not hit.is_empty() else to


## O herói está dentro do jato AGORA? (atrás de uma pedra, não)
func in_breath(point: Vector2) -> bool:
	if mode != Mode.BREATH or _mode_time < breath_windup:
		return false
	var closest := Geometry2D.get_closest_point_to_segment(point, _mouth(), _breath_end)
	return closest.distance_to(point) <= breath_width


# --- Cauda ------------------------------------------------------------------------------

func _start_tail() -> void:
	_tail_at = global_position - facing * 26.0
	_set_mode(Mode.TAIL)
	Sfx.play(&"telegraph", -3.0)


func _tail(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	if _mode_time >= tail_windup and _mode_time - delta < tail_windup:
		Sfx.play(&"swing_heavy", 0.0)
		Fx.shake(4.0, 0.3)
		if target and target.global_position.distance_to(_tail_at) <= tail_radius:
			var info := HitInfo.create(tail_damage, _tail_at, target.global_position)
			info.knockback = 260.0
			info.poise_damage = 50.0
			info.is_heavy = true
			info.attack_name = "Cauda"
			info.source = self
			target.hurtbox.receive_hit(info)
		# "Golpes de cauda que quebram o chão."
		for i in tail_pits:
			var at := _tail_at + Vector2.from_angle(randf() * TAU) * randf_range(10.0, tail_radius * 0.8)
			var pit := ArenaPit.create(clamp_to_arena(at, 24.0), Vector2(19, 12), 0.7)
			get_parent().add_child(pit)
			tail_pit_list.append(pit)
		while tail_pit_list.size() > 6:
			var old: ArenaPit = tail_pit_list.pop_front()
			if is_instance_valid(old):
				old.close()
	if _mode_time >= tail_windup + 0.7:
		facing = -facing  # vira para encarar de novo
		_go_decide(0.3)


# --- Rugido -------------------------------------------------------------------------

func _start_roar() -> void:
	_roar_timer = roar_every
	_set_mode(Mode.ROAR)


func _roar(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	if _mode_time >= roar_windup and _mode_time - delta < roar_windup:
		roar()
	if _mode_time >= roar_windup + 1.0:
		_go_decide(0.4)


## O anel derruba quem não atravessar com o dash — e as pedras caem.
func roar() -> void:
	Sfx.play(&"roar", 2.0)
	Fx.shake(7.0, 0.7)
	Fx.vibrate(250)
	var ring := ScreamRing.launch(get_parent(), global_position + Vector2(0, -8), self, roar_damage, 170.0, roar_reach)
	ring.knockback = 280.0
	for node in get_tree().get_nodes_in_group("covers"):
		var cover := node as DestructibleCover
		if cover and cover.global_position.distance_to(global_position) <= roar_reach * 1.6:
			cover.smash()


# --- A arena desmorona ------------------------------------------------------------------

func _check_crumble() -> void:
	if crumbled >= crumble_at.size() or mode == Mode.SLEEP:
		return
	if stats.health_ratio() <= crumble_at[crumbled]:
		crumble()


## Uma faixa da borda da arena cede (para sempre): o espaço seguro encolhe.
func crumble() -> void:
	crumbled += 1
	phase_changed.emit(phase_label())
	speech.emit(SPEECH_CRUMBLE[mini(crumbled - 1, SPEECH_CRUMBLE.size() - 1)])
	Sfx.play(&"crumble", 2.0)
	Sfx.play(&"quake", -2.0)
	Fx.shake(6.0, 1.0)
	if arena_rect.size == Vector2.ZERO:
		return
	var inset := 18.0 + crumble_step * (crumbled - 1)
	var ring := arena_rect.grow(-inset)
	if ring.size.x <= 40.0 or ring.size.y <= 40.0:
		return
	var points: Array[Vector2] = []
	var x := ring.position.x
	while x <= ring.end.x:
		points.append(Vector2(x, ring.position.y))
		points.append(Vector2(x, ring.end.y))
		x += crumble_spacing
	var y := ring.position.y + crumble_spacing
	while y < ring.end.y:
		points.append(Vector2(ring.position.x, y))
		points.append(Vector2(ring.end.x, y))
		y += crumble_spacing
	for point in points:
		var pit := ArenaPit.create(point, Vector2(15, 10), 1.2)
		get_parent().add_child(pit)
		edge_pits.append(pit)


# --- Morte --------------------------------------------------------------------------

func _can_be_staggered() -> bool:
	return false  # é domínio: ela não cambaleia


func _on_died() -> void:
	dead = true
	active = false
	_set_mode(Mode.DEAD)
	_runner.cancel()
	hitbox.deactivate()
	telegraph.clear()
	remove_from_group("enemies")
	hurtbox.set_deferred("monitorable", false)
	set_deferred("collision_layer", 0)
	for node in get_tree().get_nodes_in_group("fire_patches"):
		node.queue_free()
	for pit in tail_pit_list:
		if is_instance_valid(pit):
			pit.close()
	tail_pit_list.clear()
	speech.emit(SPEECH_DEFEAT)
	var reward := data.memory_reward if data else 1600
	Game.earn_memories(reward)
	if target:
		Fx.memory_motes(global_position + Vector2(0, -24), target, 26)
	Sfx.play(&"boss_phase")
	Sfx.play(&"roar", -4.0)
	Fx.slow_motion(0.25, 0.9)
	var tween := create_tween()
	tween.tween_property(visual, "rotation", 0.25, 1.0)
	tween.tween_interval(0.6)
	tween.tween_property(visual, "modulate", Color(2.0, 1.6, 1.2, 0.0), 1.8)
	tween.tween_callback(queue_free)
	fight_won.emit(self)


# --- Visual ----------------------------------------------------------------------

func _update_visual(_delta: float) -> void:
	if absf(facing.x) > 0.05 and mode != Mode.DEAD:
		body_sprite.flip_h = facing.x < 0.0
	var anim := &"idle"
	match mode:
		Mode.SLEEP:
			anim = &"dorme"
		Mode.APPROACH:
			anim = &"walk"
		Mode.ATTACK:
			anim = &"garra"
		Mode.BREATH:
			anim = &"prepara" if _mode_time < breath_windup else &"fogo"
		Mode.TAIL:
			anim = &"cauda"
		Mode.ROAR:
			anim = &"ruge"
	if body_sprite.animation != anim:
		body_sprite.play(anim)
	if mode == Mode.SLEEP:
		visual.scale = Vector2(1.0, 1.0 + sin(_clock * 1.2) * 0.02)
	_update_telegraph()
	queue_redraw()


func _update_telegraph() -> void:
	telegraph.arc_visible = false
	telegraph.circle_visible = false
	if mode == Mode.BREATH and _mode_time < breath_windup:
		telegraph.arc_visible = true
		telegraph.arc_center = _mouth()
		telegraph.arc_direction = Vector2.from_angle(lerp_angle(_breath_from, _breath_to, 0.5))
		telegraph.arc_radius = breath_range
		telegraph.arc_angle = deg_to_rad(breath_sweep)
		telegraph.arc_progress = _mode_time / breath_windup
	elif mode == Mode.TAIL and _mode_time < tail_windup:
		telegraph.circle_visible = true
		telegraph.circle_center = _tail_at
		telegraph.circle_radius = tail_radius
		telegraph.circle_progress = _mode_time / tail_windup
	elif mode == Mode.ROAR and _mode_time < roar_windup:
		telegraph.circle_visible = true
		telegraph.circle_center = global_position
		telegraph.circle_radius = 30.0
		telegraph.circle_progress = _mode_time / roar_windup
	elif mode == Mode.ATTACK and _runner.phase == AttackRunner.Phase.WINDUP and _current_attack:
		telegraph.arc_visible = true
		telegraph.arc_center = global_position
		telegraph.arc_direction = _runner.direction
		telegraph.arc_radius = _current_attack.reach + _current_attack.radius
		telegraph.arc_angle = deg_to_rad(maxf(_current_attack.slash_arc_degrees, 60.0))
		telegraph.arc_progress = _runner.phase_progress()


## O jato de fogo (desenhado: uma língua grossa até onde bate).
func _draw() -> void:
	if mode != Mode.BREATH or _mode_time < breath_windup:
		return
	var from := _mouth() - global_position
	var to := _breath_end - global_position
	var t := _clock * 30.0
	# A largura desenhada É a largura que queima (breath_width para cada lado):
	# o que o jogador vê é o que o acerta.
	var full := breath_width * 2.0
	for k in 5:
		var wobble := _breath_dir.orthogonal() * sin(t + k * 1.3) * 3.0
		draw_line(from, to + wobble, Color(1.0, 0.4 + 0.1 * k, 0.12, 0.35 + 0.1 * k), full * (1.0 - k * 0.18))
	draw_circle(to, breath_width, Color(1.0, 0.7, 0.3, 0.6))
	draw_circle(to, 8.0, Color(1.0, 0.8, 0.3, 0.6))
