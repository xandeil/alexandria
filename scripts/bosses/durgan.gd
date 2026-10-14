class_name DurganVell
extends Boss
## Durgan Vell, O Eco de Bronze — Pecado da Inveja (Forjas Ocas).
##
## Bíblia:
##   História: "Durgan é irmão do Ferreiro do Teatro... O irmão sempre foi o
##   escolhido: o nome dele ficou nas placas. Durgan fazia o mesmo trabalho, às
##   vezes melhor, e ninguém via... Se não podia ser o irmão, copiaria todo
##   mundo. No fim, não sobrou um rosto que fosse dele."
##   Fase 1 — O Engenheiro: "chave-martelo elétrica, torretas e autômatos. O
##   chão é de placas metálicas e o raio corre por elas; placas acesas indicam
##   onde não pisar."
##   Fase 2 — O Reflexo (metade da vida): "veste uma armadura espelhada e passa
##   a copiar o jogador. Usa os ataques que o jogador mais usou na luta."
##   Dica: "conte quantas vezes o jogador usa cada ação (um dicionário de ação
##   para número). Na fase 2, escolha o próximo ataque com peso proporcional."
##
## Implementação: o herói avisa cada ação (Player.action_used). Durgan só
## CONTA — e na fase 2 sorteia a próxima com peso = contagem + 1. Variar não
## é dica de jogo: é a arma contra ele.

enum Mode { DECIDE, APPROACH, ATTACK, DODGE, GUARD, DRINK, BUILD, TRANSITION, DEAD }

## Carregadas na hora (load, não preload): a torreta usa a classe Level, e a
## Level carrega Durgan — um preload aqui fecharia um ciclo de carregamento
## (a cena chegaria vazia).
const TURRET_PATH := "res://scenes/enemies/torreta_faisca.tscn"
const AUTOMATON_PATH := "res://scenes/enemies/automato_bronze.tscn"
const ACTIONS: Array[StringName] = [&"leve", &"forte", &"dash", &"escudo", &"cura"]

const SPEECH_INTRO := "Mais um rosto. Fica parado... deixa eu ver como você é feito."
const SPEECH_PHASE_2 := "Agora eu sou VOCÊ. Vamos ver se você gosta."
const SPEECH_DEFEAT := "...Diga a ele... que eu fazia igual. Às vezes melhor."
## O que ele diz na primeira vez que copia cada coisa.
const COPY_LINES := {
	&"leve": "Corta, corta, corta... É assim que você faz, não é?",
	&"forte": "Tudo na força. Igualzinho ao meu irmão.",
	&"dash": "Fugir também se aprende.",
	&"escudo": "Se esconder atrás de um escudo? Eu também sei.",
	&"cura": "Beber quando dói. Eu também posso.",
}

@export var wrench: AttackData
@export var slam: AttackData
## Fase 2: as cópias do SEU combo, do seu golpe forte e do seu dash com golpe.
@export var copy_light: Array[AttackData] = []
@export var copy_heavy: AttackData
@export var dash_strike: AttackData

@export_group("Fase 1 — O Engenheiro")
@export var build_every := 11.0
@export var max_turrets := 2
@export var automaton_every := 15.0
@export var max_automata := 1
@export var field_every := 6.5
@export var field_radius := 52.0
@export var plate_damage := 20.0
@export var slam_ring := Vector2(28.0, 110.0)

@export_group("Fase 2 — O Reflexo")
@export var dash_speed := 260.0
@export var dash_time := 0.24
@export var guard_time := 1.4
@export_range(0.0, 1.0) var guard_ratio := 0.15
@export_range(0.0, 0.3) var drink_heal := 0.06
@export var max_drinks := 3

@onready var telegraph: TelegraphDrawer = $Telegraph
@onready var weapon_pivot: Node2D = $Visual/WeaponPivot

var phase := 1
var mode := Mode.DECIDE
## Quantas vezes o herói usou cada ação NESTA luta.
var counts := {&"leve": 0, &"forte": 0, &"dash": 0, &"escudo": 0, &"cura": 0}
var helpers: Array[Enemy] = []
var last_copy: StringName = &""

var _mode_time := 0.0
var _clock := 0.0
## Momentos (no relógio da luta) em que ele pode construir de novo.
var _build_timer := 4.0
var _automaton_timer := 8.0
var _field_timer := 3.0
var _combo: Array[AttackData] = []
var _dodge_dir := Vector2.ZERO
var _drinks := 0
var _said := {}
var _bound := false


func enter_arena(_landing: Vector2) -> void:
	visible = true
	ready_to_fight.emit()


func start_fight() -> void:
	super.start_fight()
	speech.emit(SPEECH_INTRO)
	Sfx.play(&"zap", -4.0)
	_bind_player()
	_build_timer = _clock + 3.0
	_automaton_timer = _clock + 8.0
	_go_decide(0.8)


func _bind_player() -> void:
	var player := find_target()
	if player and not _bound:
		_bound = true
		player.action_used.connect(_on_player_action)


func phase_label() -> String:
	return "O Engenheiro" if phase == 1 else "O Reflexo"


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
		_enter_reflection()
	if active and target and not target.is_dead():
		_prune()
		_field_timer -= delta
		if _field_timer <= 0.0 and mode != Mode.TRANSITION:
			_field_timer = field_every * (0.8 if phase == 2 else 1.0)
			charge_field()
		match mode:
			Mode.DECIDE:
				_decide(delta)
			Mode.APPROACH:
				_approach(delta)
			Mode.ATTACK:
				velocity = _runner.step(delta, velocity)
			Mode.DODGE:
				velocity = _dodge_dir * dash_speed * (1.0 - _mode_time / dash_time * 0.6)
				if fmod(_mode_time, 0.05) < delta:
					Fx.afterimage(body_sprite, Color(0.75, 0.85, 1.0, 0.5))
				if _mode_time >= dash_time:
					hurtbox.invulnerable = false
					_go_decide(0.1)
			Mode.GUARD:
				velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
				facing = (target.global_position - global_position).normalized()
				if _mode_time >= guard_time:
					_go_decide(0.2)
			Mode.DRINK:
				velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
				if _mode_time >= 0.8 and _mode_time - delta < 0.8:
					stats.heal(stats.max_health * drink_heal)
					Sfx.play(&"heal", -4.0)
					Fx.splash(global_position + Vector2(0, -16), Color(0.75, 0.85, 1.0), 10)
				if _mode_time >= 1.1:
					_go_decide(0.3)
			Mode.BUILD:
				velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
				if _mode_time >= 0.9:
					_go_decide(0.3)
			Mode.TRANSITION:
				velocity = Vector2.ZERO
	else:
		velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	move_and_slide()
	_update_visual(delta)


# --- Contar o herói (a dica da Bíblia) -----------------------------------------------

func _on_player_action(action: StringName) -> void:
	if not counts.has(action) or dead:
		return
	counts[action] += 1
	# Fase 2: quem abusa do dash enfrenta alguém que esquiva — ele REAGE ao seu golpe.
	if phase == 2 and (action == &"leve" or action == &"forte") and (mode == Mode.DECIDE or mode == Mode.APPROACH):
		if target and global_position.distance_to(target.global_position) < 56.0 and randf() < dodge_chance():
			dodge((global_position - target.global_position).normalized().rotated(randf_range(-0.6, 0.6)))


## Peso de cada ação = vezes usadas + 1 (ninguém fica com chance zero).
func weights() -> Dictionary:
	var result := {}
	var total := 0.0
	for action in ACTIONS:
		total += counts[action] + 1.0
	for action in ACTIONS:
		result[action] = (counts[action] + 1.0) / total
	return result


func pick_copy() -> StringName:
	var w := weights()
	var roll := randf()
	for action in ACTIONS:
		roll -= w[action]
		if roll <= 0.0:
			return action
	return ACTIONS[-1]


func dodge_chance() -> float:
	return clampf(weights()[&"dash"] * 1.4, 0.1, 0.8)


# --- Decidir ---------------------------------------------------------------------

func _decide(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	if _mode_time < 0.0:
		return
	var to_target := target.global_position - global_position
	var distance := to_target.length()
	facing = to_target.normalized()
	if phase == 1:
		if _build_timer <= _clock and _count_helpers(TorretaFaisca) < max_turrets:
			_build_timer = _clock + build_every
			build_turret()
			return
		if _automaton_timer <= _clock and _count_helpers(AutomatoBronze) < max_automata:
			_automaton_timer = _clock + automaton_every
			call_automaton()
			return
		if distance <= 36.0:
			_queue_combo([slam] if randf() < 0.4 else [wrench])
			return
		_set_mode(Mode.APPROACH)
		return
	_copy(pick_copy(), distance)


func _approach(delta: float) -> void:
	var to_target := target.global_position - global_position
	facing = to_target.normalized()
	velocity = velocity.move_toward(facing * move_speed, acceleration * delta)
	if to_target.length() <= (30.0 if phase == 2 else 34.0) or _mode_time >= 1.6:
		if phase == 2 and not _combo.is_empty():
			_next_in_combo()
		else:
			_go_decide(0.0)


## Fase 2: faz o que VOCÊ mais fez.
func _copy(action: StringName, distance: float) -> void:
	last_copy = action
	if not _said.has(action):
		_said[action] = true
		speech.emit(COPY_LINES[action])
	match action:
		&"leve":
			var hits := randi_range(1, copy_light.size())
			var chain: Array = copy_light.slice(0, hits)
			_start_or_approach(chain, distance)
		&"forte":
			_start_or_approach([copy_heavy], distance)
		&"dash":
			if distance > 44.0:
				_queue_combo([dash_strike])
			else:
				dodge(facing.orthogonal() * (1.0 if randf() < 0.5 else -1.0))
		&"escudo":
			_set_mode(Mode.GUARD)
			Sfx.play(&"shield_up", -4.0)
		&"cura":
			if _drinks < max_drinks and stats.health < stats.max_health:
				_drinks += 1
				_set_mode(Mode.DRINK)
			else:
				_start_or_approach([copy_light[0]], distance)


func _start_or_approach(chain: Array, distance: float) -> void:
	_combo.assign(chain)
	if distance <= 30.0:
		_next_in_combo()
	else:
		_set_mode(Mode.APPROACH)


func _queue_combo(attacks: Array) -> void:
	_combo.assign(attacks)
	_next_in_combo()


func _next_in_combo() -> void:
	if _combo.is_empty():
		_go_decide(0.5 if phase == 1 else 0.35)
		return
	var attack: AttackData = _combo.pop_front()
	_set_mode(Mode.ATTACK)
	facing = (target.global_position - global_position).normalized()
	start_attack(attack, facing)
	if attack == slam or attack.is_heavy:
		Sfx.play(&"telegraph", -5.0)


func _on_attack_finished() -> void:
	if mode == Mode.ATTACK:
		_next_in_combo()


## A martelada elétrica: no impacto, o raio corre pelas placas em volta.
func _on_attack_phase_changed(new_phase: AttackRunner.Phase) -> void:
	super._on_attack_phase_changed(new_phase)
	if new_phase == AttackRunner.Phase.ACTIVE and _current_attack == slam:
		Sfx.play(&"slam", -2.0)
		Fx.shake(4.0, 0.25)
		var level := Level.find(self)
		var impact := global_position + _runner.direction * slam.reach
		if level:
			PlateCharge.spawn(get_parent(), level.plates_near(impact, slam_ring.y, slam_ring.x), 0.5, plate_damage, self)


# --- Engenharia (fase 1) -------------------------------------------------------------

## As placas em volta do herói acendem (e ele precisa sair delas).
func charge_field() -> PlateCharge:
	var level := Level.find(self)
	if level == null or target == null:
		return null
	var cells := level.plates_near(target.global_position, field_radius)
	if cells.is_empty():
		return null
	return PlateCharge.spawn(get_parent(), cells, 1.0, plate_damage, self)


## Arremessa uma torreta numa placa entre ele e o herói.
func build_turret() -> Enemy:
	_set_mode(Mode.BUILD)
	Sfx.play(&"clank", -2.0)
	var at := clamp_to_arena(target.global_position + Vector2.from_angle(randf() * TAU) * randf_range(60.0, 100.0), 24.0)
	return _spawn_helper(load(TURRET_PATH), at)


## Um autômato desperta na beira da arena.
func call_automaton() -> Enemy:
	_set_mode(Mode.BUILD)
	Sfx.play(&"stone_wake", -6.0)
	var center := arena_rect.get_center() if arena_rect.size != Vector2.ZERO else global_position
	var side := Vector2.from_angle(randf() * TAU)
	var at := clamp_to_arena(center + Vector2(side.x * 170.0, side.y * 100.0), 24.0)
	var automaton := _spawn_helper(load(AUTOMATON_PATH), at)
	automaton.set("aggro_range", 999.0)
	return automaton


func _spawn_helper(scene: PackedScene, at: Vector2) -> Enemy:
	var helper := scene.instantiate() as Enemy
	helper.position = at
	helper.memory_reward = 0  # fabricado por ele: não paga
	get_parent().add_child(helper)
	helpers.append(helper)
	Fx.sparks(at + Vector2(0, -8), Vector2.UP, Color(0.75, 0.85, 1.0), 10)
	Fx.dust(at, 8)
	return helper


func _count_helpers(kind: Variant) -> int:
	var count := 0
	for helper in helpers:
		if is_instance_of(helper, kind):
			count += 1
	return count


func _prune() -> void:
	for i in range(helpers.size() - 1, -1, -1):
		if not is_instance_valid(helpers[i]) or helpers[i].dead:
			helpers.remove_at(i)


# --- O Reflexo (fase 2) ---------------------------------------------------------------

func dodge(direction: Vector2) -> void:
	_combo.clear()
	_runner.cancel()
	hitbox.deactivate()
	_dodge_dir = direction.normalized() if direction != Vector2.ZERO else Vector2.RIGHT
	hurtbox.invulnerable = true
	Sfx.play(&"dash", -4.0)
	_set_mode(Mode.DODGE)


func _enter_reflection() -> void:
	phase = 2
	_combo.clear()
	_runner.cancel()
	hitbox.deactivate()
	_set_mode(Mode.TRANSITION)
	hurtbox.invulnerable = true
	phase_changed.emit(phase_label())
	speech.emit(SPEECH_PHASE_2)
	Sfx.play(&"boss_phase")
	Sfx.play(&"mirror", -2.0)
	Fx.shake(4.0, 0.5)
	for helper in helpers:
		if helper is AutomatoBronze and is_instance_valid(helper) and not helper.dead:
			helper.stats.take_damage(9999.0)  # os rostos de bronze caem: agora o rosto é o seu
	await wait(2.2)
	if dead:
		return
	hurtbox.invulnerable = false
	_go_decide(0.2)


## Escudo espelhado erguido: de frente, quase nada entra — e ele revida.
func _incoming_damage_multiplier(info: HitInfo) -> float:
	if mode != Mode.GUARD:
		return 1.0
	var toward := info.source_position - global_position
	return guard_ratio if absf(rad_to_deg(facing.angle_to(toward))) <= 75.0 else 1.0


func _on_damaged(_amount: float, info: HitInfo, blocked: bool) -> void:
	if mode == Mode.GUARD and blocked:
		Sfx.play(&"block", -2.0)
		_queue_combo([wrench])  # aparou: revida na hora
	elif mode == Mode.DRINK and info.is_heavy:
		Fx.float_text(global_position + Vector2(-14, -40), "interrompido", Color(1.0, 0.85, 0.6), 7)
		_go_decide(0.6)


func _can_be_staggered() -> bool:
	return mode == Mode.DECIDE or mode == Mode.APPROACH or mode == Mode.DRINK or mode == Mode.BUILD


func _on_poise_broken(_info: HitInfo) -> void:
	_combo.clear()
	_go_decide(stagger_time)


func _on_died() -> void:
	if phase == 1:
		stats.revive()
		stats.set_health(stats.max_health * 0.5)
		_enter_reflection()
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
	for helper in helpers:
		if is_instance_valid(helper) and not helper.dead:
			helper.stats.take_damage(9999.0)
	helpers.clear()
	for node in get_tree().get_nodes_in_group("plate_charges"):
		node.queue_free()
	speech.emit(SPEECH_DEFEAT)
	var reward := data.memory_reward if data else 1500
	Game.add_memories(reward)
	if target:
		Fx.memory_motes(global_position + Vector2(0, -14), target, 22)
	Sfx.play(&"boss_phase")
	Fx.slow_motion(0.25, 0.8)
	# A armadura espelhada racha; por baixo, o rosto que sobrou — e some em branco.
	var tween := create_tween()
	tween.tween_interval(0.8)
	tween.tween_property(visual, "modulate", Color(2.0, 2.0, 2.2, 0.0), 1.6)
	tween.tween_callback(queue_free)
	fight_won.emit(self)


# --- Visual ----------------------------------------------------------------------

func _update_visual(delta: float) -> void:
	if absf(facing.x) > 0.05 and mode != Mode.DEAD:
		body_sprite.flip_h = facing.x < 0.0
	var mirror := phase == 2
	var anim := &"idle2" if mirror else &"idle"
	match mode:
		Mode.APPROACH:
			anim = &"walk2" if mirror else &"walk"
		Mode.DRINK:
			anim = &"bebe"
		Mode.GUARD:
			anim = &"guarda"
		Mode.TRANSITION:
			anim = &"guarda"
	if body_sprite.animation != anim:
		body_sprite.play(anim)
	if mirror and mode != Mode.DEAD:
		# o espelho "pisca" com a luz
		body_sprite.self_modulate = Color(1, 1, 1).lerp(Color(1.35, 1.4, 1.6), 0.5 + 0.5 * sin(_clock * 3.0))
	_update_weapon(delta)
	_update_telegraph()


func _update_weapon(delta: float) -> void:
	var side := -1.0 if body_sprite.flip_h else 1.0
	weapon_pivot.position = Vector2(9.0 * side, -12.0)
	weapon_pivot.visible = mode != Mode.DRINK
	if mode == Mode.ATTACK and _runner.is_running():
		var aim := hitbox_pivot.rotation
		match _runner.phase:
			AttackRunner.Phase.WINDUP:
				weapon_pivot.rotation = aim - PI * 0.8 * side * _runner.phase_progress()
			_:
				weapon_pivot.rotation = aim
	else:
		var rest := (PI * 0.5 - 0.5) if side > 0.0 else (PI * 0.5 + 0.5)
		weapon_pivot.rotation = lerp_angle(weapon_pivot.rotation, rest, 8.0 * delta)
	(weapon_pivot.get_child(0) as Sprite2D).flip_v = cos(weapon_pivot.rotation) < 0.0


func _update_telegraph() -> void:
	telegraph.circle_visible = false
	telegraph.arc_visible = false
	telegraph.line_visible = false
	if mode != Mode.ATTACK or _runner.phase != AttackRunner.Phase.WINDUP or _current_attack == null:
		return
	if _current_attack == slam:
		telegraph.circle_visible = true
		telegraph.circle_center = global_position + _runner.direction * slam.reach
		telegraph.circle_radius = slam.radius + 4.0
		telegraph.circle_progress = _runner.phase_progress()
	elif _current_attack == dash_strike:
		telegraph.line_visible = true
		telegraph.line_origin = global_position
		telegraph.line_direction = _runner.direction
		telegraph.line_length = dash_strike.lunge_speed * dash_strike.lunge_time + dash_strike.reach
		telegraph.line_locked = _runner.phase_progress() > 0.6
	elif _current_attack.is_heavy or _current_attack == wrench:
		telegraph.arc_visible = true
		telegraph.arc_center = global_position
		telegraph.arc_direction = _runner.direction
		telegraph.arc_radius = _current_attack.reach + _current_attack.radius
		telegraph.arc_angle = deg_to_rad(maxf(_current_attack.slash_arc_degrees, 60.0))
		telegraph.arc_progress = _runner.phase_progress()
