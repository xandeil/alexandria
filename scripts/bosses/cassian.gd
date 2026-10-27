class_name CassianVirel
extends Boss
## Cassian Virel, O Arconte do Zero — Ganância (Domínio Congelado).
## Bíblia: "Fase 1 — O Arquimago: magias de gelo e controle de espaço.
##          Fase 2 — O Colecionador: congela partes da arena, invoca estátuas
##          congeladas e rouba estamina do jogador temporariamente."
##
## FASE 1 — controle de espaço (ele decide ONDE você pode ficar):
##   • Lanças: leque de estilhaços (linha que trava). Quem leva fica lento.
##   • Geada: três retângulos no chão em volta de você congelam (dano + gelo).
##   • Pilares de gelo: erguem-se entre vocês e derretem sozinhos — bloqueiam
##     o caminho E os estilhaços (servem de abrigo para você também).
##   • Colou nele? O cajado — ou ele some num piscar e reaparece longe.
## FASE 2 (metade da vida; dano enorme não pula):
##   • Congela METADE da arena: quem estiver lá quando encher vira peça de
##     coleção (bloco de gelo; toques rápidos).
##   • Estátuas Vivas da coleção dele (só andam quando você vira as costas).
##   • Roubo: um raio que trava; pegou, a sua estamina vai a zero e demora a
##     voltar — guarde o dash para sair da linha.

enum Mode { DECIDE, ATTACK, LANCES, FROST, WALLS, BLINK, TRANSITION, FREEZE, SUMMON, STEAL, DEAD }

const STATUE_PATH := "res://scenes/enemies/estatua_viva.tscn"
const PILLAR_TEXTURE := preload("res://assets/props/ice_pillar.png")
const SPEECH_INTRO := "Mais um volume para a coleção. Fique parado — você vai durar para sempre."
const SPEECH_PHASE_2 := "Nada se perde aqui. NADA. Nem você."
const SPEECH_DEFEAT := "...Eu só queria... que alguma coisa ficasse."

@export var staff: AttackData

@export_group("Fase 1 — O Arquimago")
@export var lance_count := 5
@export var lance_damage := 14.0
@export var lance_speed := 160.0
@export var lance_aim := 0.75
@export var frost_count := 3
@export var frost_size := Vector2(42, 30)
@export var frost_warning := 1.0
@export var frost_damage := 16.0
@export var wall_every := 9.0
@export var wall_count := 2
@export var wall_life := 7.0
@export var blink_distance := 110.0

@export_group("Fase 2 — O Colecionador")
@export var freeze_every := 10.0
@export var freeze_warning := 1.6
@export var freeze_taps := 7
@export var summon_every := 12.0
@export var max_statues := 2
@export var steal_every := 8.0
@export var steal_aim := 0.9
@export var steal_width := 12.0
@export var steal_range := 200.0
@export var steal_suppress := 3.5

@onready var telegraph: TelegraphDrawer = $Telegraph

var phase := 1
var mode := Mode.DECIDE
var statues: Array[Enemy] = []
var _mode_time := 0.0
var _clock := 0.0
var _actions := 0
var _aim := Vector2.RIGHT
var _wall_timer := 5.0
var _freeze_timer := 4.0
var _summon_timer := 6.0
var _steal_timer := 3.0
var _close_time := 0.0


func enter_arena(_landing: Vector2) -> void:
	visible = true
	ready_to_fight.emit()


func start_fight() -> void:
	super.start_fight()
	speech.emit(SPEECH_INTRO)
	Sfx.play(&"crystal", -2.0)
	_go_decide(1.0)


func phase_label() -> String:
	return "O Arquimago" if phase == 1 else "O Colecionador"


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
		_update_visual()
		return
	target = find_target()
	if active and phase == 1 and mode != Mode.TRANSITION and stats.health_ratio() <= 0.5:
		_enter_collector()
	if active and target and not target.is_dead():
		_prune()
		_wall_timer -= delta
		if phase == 2:
			_freeze_timer -= delta
			_summon_timer -= delta
			_steal_timer -= delta
		_close_time = _close_time + delta if global_position.distance_to(target.global_position) < 36.0 else 0.0
		match mode:
			Mode.DECIDE:
				velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
				if _mode_time >= 0.0:
					_decide()
			Mode.ATTACK:
				velocity = _runner.step(delta, velocity)
			Mode.LANCES:
				_lances(delta)
			Mode.FROST:
				velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
				if _mode_time >= 0.5:
					_go_decide(0.6)
			Mode.WALLS, Mode.SUMMON, Mode.FREEZE:
				velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
				if _mode_time >= 0.8:
					_go_decide(0.5)
			Mode.BLINK:
				velocity = Vector2.ZERO
				if _mode_time >= 0.35:
					_go_decide(0.3)
			Mode.STEAL:
				_steal(delta)
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
	_actions += 1
	if _close_time > 1.2:
		blink()  # colou nele por tempo demais: some e reaparece longe
		return
	if phase == 2:
		if _freeze_timer <= 0.0:
			freeze_half()
			return
		if _summon_timer <= 0.0 and statues.size() < max_statues:
			summon()
			return
		if _steal_timer <= 0.0:
			start_steal()
			return
	if distance < 34.0:
		_set_mode(Mode.ATTACK)
		start_attack(staff, facing)
		Sfx.play(&"telegraph", -8.0)
		return
	if _wall_timer <= 0.0:
		raise_walls()
		return
	if _actions % 2 == 0:
		frost()
	else:
		_aim = facing
		_set_mode(Mode.LANCES)
		Sfx.play(&"telegraph", -6.0)


func _on_attack_finished() -> void:
	if mode == Mode.ATTACK:
		_go_decide(0.6)


# --- Fase 1 -------------------------------------------------------------------------

func _lances(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	if _mode_time < lance_aim * 0.7:
		_aim = (target.global_position - global_position).normalized()
		facing = _aim
	if _mode_time >= lance_aim:
		for i in lance_count:
			var spread := deg_to_rad(12.0) * (i - (lance_count - 1) * 0.5)
			Projectile.launch(get_parent(), global_position + Vector2(0, -14) + _aim * 10.0, _aim.rotated(spread), self,
				lance_damage, lance_speed, 280.0, Projectile.FROST)
		Sfx.play(&"ice_shot", -2.0)
		_go_decide(0.9 if phase == 1 else 0.6)


## Geada: retângulos no chão em volta do herói (um sempre bem embaixo dele).
func frost() -> void:
	for i in frost_count:
		var at := target.global_position
		if i > 0:
			at += Vector2.from_angle(TAU * i / frost_count + randf()) * randf_range(36.0, 60.0)
		at = clamp_to_arena(at, 20.0) if arena_rect.size != Vector2.ZERO else at
		var zone := FrostZone.spawn(get_parent(), Rect2(at - frost_size * 0.5, frost_size), frost_warning, 4.0, 0, self)
		zone.damage = frost_damage
	Sfx.play(&"crystal", -4.0, 0.1)
	_set_mode(Mode.FROST)


## Pilares de gelo entre ele e o herói: bloqueiam o caminho (e os estilhaços).
func raise_walls() -> Array[DestructibleCover]:
	_wall_timer = wall_every
	var made: Array[DestructibleCover] = []
	var to_target := target.global_position - global_position
	var mid := global_position + to_target * 0.5
	for i in wall_count:
		var side := to_target.normalized().orthogonal() * (i - (wall_count - 1) * 0.5) * 30.0
		var pillar := DestructibleCover.new()
		pillar.texture_override = PILLAR_TEXTURE
		pillar.lifetime = wall_life
		pillar.max_health = 40.0
		pillar.position = clamp_to_arena(mid + side, 18.0) if arena_rect.size != Vector2.ZERO else mid + side
		get_parent().add_child(pillar)
		made.append(pillar)
	Sfx.play(&"freeze", -2.0)
	Fx.shake(2.0, 0.2)
	_set_mode(Mode.WALLS)
	return made


## Some num piscar e reaparece longe do herói (dentro da arena).
func blink() -> void:
	_close_time = 0.0
	Fx.afterimage(body_sprite, Color(0.7, 0.9, 1.0, 0.6))
	var away := (global_position - target.global_position).normalized()
	if away == Vector2.ZERO:
		away = Vector2.UP
	var to := target.global_position + away.rotated(randf_range(-0.8, 0.8)) * blink_distance
	global_position = clamp_to_arena(to, 24.0) if arena_rect.size != Vector2.ZERO else to
	Sfx.play(&"mirror", -6.0, 0.1)
	_set_mode(Mode.BLINK)


# --- Fase 2 -------------------------------------------------------------------------

func _enter_collector() -> void:
	phase = 2
	_runner.cancel()
	hitbox.deactivate()
	_set_mode(Mode.TRANSITION)
	hurtbox.invulnerable = true
	phase_changed.emit(phase_label())
	speech.emit(SPEECH_PHASE_2)
	Sfx.play(&"boss_phase")
	Sfx.play(&"freeze", 0.0)
	Fx.shake(5.0, 0.6)
	_freeze_timer = 2.5
	_summon_timer = 5.0
	_steal_timer = 7.0
	await wait(2.0)
	if dead:
		return
	hurtbox.invulnerable = false
	_go_decide(0.2)


## Congela METADE da arena (o lado onde o herói está — com aviso longo).
func freeze_half() -> FrostZone:
	_freeze_timer = freeze_every
	var area := arena_rect if arena_rect.size != Vector2.ZERO else Rect2(global_position - Vector2(160, 110), Vector2(320, 220))
	var half := area
	if absf(target.global_position.x - area.get_center().x) > absf(target.global_position.y - area.get_center().y) * 1.3:
		half.size.x *= 0.5
		if target.global_position.x > area.get_center().x:
			half.position.x += half.size.x
	else:
		half.size.y *= 0.5
		if target.global_position.y > area.get_center().y:
			half.position.y += half.size.y
	var zone := FrostZone.spawn(get_parent(), half, freeze_warning, 5.0, freeze_taps, self)
	speech.emit("Fique. Exatamente aí.")
	Sfx.play(&"crystal", 0.0)
	_set_mode(Mode.FREEZE)
	return zone


## Duas peças da coleção: Estátuas Vivas (sem pagar memórias).
func summon() -> void:
	_summon_timer = summon_every
	var scene := load(STATUE_PATH) as PackedScene
	for i in maxi(max_statues - statues.size(), 0):
		var statue := scene.instantiate() as Enemy
		var spot := global_position + Vector2.from_angle(PI * i + randf_range(-0.4, 0.4)) * 70.0
		statue.position = clamp_to_arena(spot, 20.0) if arena_rect.size != Vector2.ZERO else spot
		statue.memory_reward = 0
		statue.aggro_range = 400.0
		get_parent().add_child(statue)
		statues.append(statue)
		Fx.sparks(statue.global_position + Vector2(0, -10), Vector2.UP, Color(0.8, 0.94, 1.0), 10)
	Sfx.play(&"crystal", -2.0)
	_set_mode(Mode.SUMMON)


func _prune() -> void:
	statues = statues.filter(func(s): return is_instance_valid(s) and not (s as Enemy).dead)


func start_steal() -> void:
	_steal_timer = steal_every
	_aim = (target.global_position - global_position).normalized()
	_set_mode(Mode.STEAL)
	Sfx.play(&"telegraph", -2.0)


func _steal(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	if _mode_time < steal_aim * 0.65:
		_aim = (target.global_position - global_position).normalized()
		facing = _aim
	if _mode_time >= steal_aim and _mode_time - delta < steal_aim:
		Sfx.play(&"slurp", -2.0)
		if in_steal_line(target.global_position) and not target.hurtbox.invulnerable:
			target.stats.drain_stamina(target.stats.max_stamina)
			target.stats.suppress_regen(steal_suppress)
			Fx.float_text(target.global_position + Vector2(-14, -28), "fôlego roubado", Color(0.7, 0.9, 1.0), 7)
			speech.emit("Isso também é meu.")
	if _mode_time >= steal_aim + 0.5:
		_go_decide(0.5)


func in_steal_line(point: Vector2) -> bool:
	var from := global_position + Vector2(0, -12)
	var closest := Geometry2D.get_closest_point_to_segment(point, from, from + _aim * steal_range)
	return closest.distance_to(point) <= steal_width


# --- Dano e morte -------------------------------------------------------------------

func _can_be_staggered() -> bool:
	return mode == Mode.DECIDE or mode == Mode.LANCES


func _on_poise_broken(_info: HitInfo) -> void:
	_go_decide(stagger_time)


func _on_died() -> void:
	if phase == 1:
		stats.revive()
		stats.set_health(stats.max_health * 0.5)  # dano enorme não pula o Colecionador
		_enter_collector()
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
	for statue in statues:
		if is_instance_valid(statue) and not statue.dead:
			statue.stats.take_damage(99999.0)  # a coleção se desfaz com o dono
	for zone in get_tree().get_nodes_in_group(&"frost_zones"):
		zone.queue_free()
	for block in get_tree().get_nodes_in_group(&"ice_blocks"):
		(block as IceBlock).shatter()
	speech.emit(SPEECH_DEFEAT)
	var reward := data.memory_reward if data else 2000
	Game.earn_memories(reward)
	if target:
		Fx.memory_motes(global_position + Vector2(0, -16), target, 26)
	Sfx.play(&"boss_phase")
	Sfx.play(&"shatter", -2.0)
	Fx.slow_motion(0.25, 0.9)
	var tween := create_tween()
	tween.tween_interval(0.8)
	tween.tween_property(visual, "modulate", Color(1.6, 1.8, 2.0, 0.0), 1.8)
	tween.tween_callback(queue_free)
	fight_won.emit(self)


# --- Visual ----------------------------------------------------------------------------

func _update_visual() -> void:
	if absf(facing.x) > 0.1 and mode != Mode.DEAD:
		body_sprite.flip_h = facing.x < 0.0
	var anim := &"idle2" if phase == 2 else &"idle"
	match mode:
		Mode.ATTACK:
			anim = &"cajado"
		Mode.LANCES, Mode.STEAL:
			anim = &"conjura"
		Mode.FROST, Mode.WALLS, Mode.FREEZE, Mode.SUMMON, Mode.TRANSITION:
			anim = &"ergue"
	if mode == Mode.DECIDE and velocity.length() > 5.0:
		anim = &"walk"
	if body_sprite.animation != anim:
		body_sprite.play(anim)
	telegraph.line_visible = mode == Mode.LANCES or mode == Mode.STEAL
	if telegraph.line_visible:
		var aim_time := lance_aim if mode == Mode.LANCES else steal_aim
		telegraph.line_origin = global_position + Vector2(0, -12)
		telegraph.line_direction = _aim
		telegraph.line_length = 120.0 if mode == Mode.LANCES else steal_range
		telegraph.line_locked = _mode_time >= aim_time * (0.7 if mode == Mode.LANCES else 0.65)
	queue_redraw()


## O raio do roubo (azul, fino no aviso, grosso no instante do roubo).
func _draw() -> void:
	if mode != Mode.STEAL or _mode_time < steal_aim or _mode_time > steal_aim + 0.3:
		return
	var from := Vector2(0, -12)
	draw_line(from, from + _aim * steal_range, Color(0.6, 0.85, 1.0, 0.7), steal_width * 2.0)
	draw_line(from, from + _aim * steal_range, Color(1, 1, 1, 0.8), 3.0)
