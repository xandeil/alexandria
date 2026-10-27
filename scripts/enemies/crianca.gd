class_name Crianca
extends Enemy
## Criança de olhos brancos — Prólogo (Complexo das Cápsulas).
## Bíblia: "atacam rindo, sem ódio, como quem repete uma brincadeira antiga."
##
## A BRINCADEIRA (pega-pega): chega perto, espeta com a espada de madeira
## (golpe fraco e BEM avisado) e foge rindo. Depois volta. Não persegue para
## sempre: cada uma tem o seu cantinho (leash_range) — dá para atravessar a
## sala desviando, sem revidar.
##
## NINGUÉM MORRE AQUI: com a vida zerada ela CAI, fica no chão e levanta de
## novo — um pouco MENOR a cada vez ("as crianças se matando repetidamente e
## regredindo"). Não dá memórias: bater nelas não rende nada.
##
## A ESCOLHA SEM AVISO: qualquer golpe do herói conta em Game.criancas_feridas.
## Quem decide o que isso significa é a Governanta (e o Prologo).

enum AI { PLAY, CHASE, ATTACK, FLEE, STAGGER, DOWN }

## Variações (o mapa escolhe: "*" = pequena, "+" = adolescente).
const VARIANTS := [
	{"frames": preload("res://assets/sprites/crianca_a_frames.tres"), "attack": preload("res://data/attacks/crianca_espetada.tres"), "health": 40.0, "speed": 52.0},
	{"frames": preload("res://assets/sprites/crianca_b_frames.tres"), "attack": preload("res://data/attacks/crianca_espetada.tres"), "health": 40.0, "speed": 56.0},
	{"frames": preload("res://assets/sprites/adolescente_frames.tres"), "attack": preload("res://data/attacks/adolescente_golpe.tres"), "health": 70.0, "speed": 48.0},
]
## Fichas de ataque (mesma ideia do Soldado): no máximo 2 crianças batem juntas.
const MAX_ATTACKERS := 2
const TOKEN_TIMEOUT := 2.0
## Menor tamanho possível depois de muitas quedas.
const MIN_SIZE := 0.72
const LAUGHS := ["hi hi", "he he", "hihi!", "ha ha"]
static var _attack_tokens := 0

@export_range(0, 2) var variant := 0
## Raio da "brincadeira" em volta de casa quando ninguém está por perto.
@export var play_radius := 26.0
@export var attack_range := 16.0
## Distância que ela gosta de manter rodeando o herói enquanto espera a vez.
@export var circle_distance := 34.0
@export var flee_time := Vector2(0.7, 1.2)
@export var attack_cooldown := Vector2(1.1, 2.0)
## Tempo caída antes de levantar de novo.
@export var down_time := 4.0
## A cada queda ela volta menor (0.9 = 10% menor).
@export_range(0.5, 1.0) var regression_per_fall := 0.9

@onready var sword_pivot: Node2D = $Visual/SwordPivot
@onready var shadow: Sprite2D = $Shadow

var ai := AI.PLAY
var down := false
var falls := 0
var size_scale := 1.0

var _attack: AttackData
var _ai_time := 0.0
var _cooldown := 0.0
var _has_token := false
var _token_time := 0.0
var _flee_left := 0.0
var _play_goal := Vector2.ZERO
var _play_timer := 0.0
var _laugh_cooldown := 0.0
var _strafe_dir := 1.0
var _pose_tween: Tween


func _ready() -> void:
	super._ready()
	var spec: Dictionary = VARIANTS[clampi(variant, 0, VARIANTS.size() - 1)]
	body_sprite.sprite_frames = spec["frames"]
	body_sprite.play(&"idle")
	_attack = spec["attack"]
	move_speed = spec["speed"]
	stats.base_health = spec["health"]
	stats.recalculate(true)
	_strafe_dir = 1.0 if randf() < 0.5 else -1.0
	_play_goal = home_position
	_cooldown = randf_range(0.2, 0.8)


func _exit_tree() -> void:
	_release_token()


func is_targetable() -> bool:
	return not down and super.is_targetable()


func _physics_process(delta: float) -> void:
	_ai_time += delta
	_cooldown -= delta
	_laugh_cooldown -= delta
	if not down:
		regen_poise(delta)
	target = find_target()
	match ai:
		AI.PLAY:
			_ai_play(delta)
		AI.CHASE:
			_ai_chase(delta)
		AI.ATTACK:
			track_target_during_windup()
			velocity = _runner.step(delta, velocity)
		AI.FLEE:
			_ai_flee(delta)
		AI.STAGGER:
			velocity = velocity.move_toward(Vector2.ZERO, 500.0 * delta)
			if _ai_time >= stagger_time:
				_set_ai(AI.CHASE)
		AI.DOWN:
			velocity = velocity.move_toward(Vector2.ZERO, 420.0 * delta)
			if _ai_time >= down_time:
				_get_up()
	move_and_slide()
	if ai != AI.DOWN:
		update_body_animation(delta)
	_update_sword(delta)


func _set_ai(new_ai: AI) -> void:
	ai = new_ai
	_ai_time = 0.0


# --- Brincando (ninguém por perto) ------------------------------------------------------

func _ai_play(delta: float) -> void:
	_play_timer -= delta
	if _play_timer <= 0.0:
		_play_timer = randf_range(0.8, 2.0)
		_play_goal = home_position + Vector2.from_angle(randf() * TAU) * randf_range(4.0, play_radius)
	var to_goal := _play_goal - global_position
	if to_goal.length() > 3.0:
		facing = to_goal.normalized()
		velocity = velocity.move_toward(facing * move_speed * 0.45, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	if target and _sees_target(aggro_range):
		_set_ai(AI.CHASE)
		laugh()


func _sees_target(distance: float) -> bool:
	return global_position.distance_to(target.global_position) < distance and can_see(target.global_position)


# --- Pega-pega ----------------------------------------------------------------------

func _ai_chase(delta: float) -> void:
	if target == null or global_position.distance_to(home_position) > leash_range \
			or global_position.distance_to(target.global_position) > aggro_range * 1.8:
		_go_home()
		return
	var to_target := target.global_position - global_position
	var distance := to_target.length()
	facing = to_target.normalized()
	var in_reach := distance < circle_distance + 8.0 and can_see(target.global_position)
	if _has_token:
		_token_time += delta
		if not in_reach or _token_time > TOKEN_TIMEOUT:
			_release_token()
			_cooldown = maxf(_cooldown, randf_range(0.3, 0.7))
	var desired := Vector2.ZERO
	if _cooldown <= 0.0 and in_reach and _acquire_token():
		if distance <= attack_range:
			_begin_attack()
			return
		desired = facing * move_speed
	elif distance > circle_distance + 6.0:
		desired = facing * move_speed
	elif distance < circle_distance - 8.0:
		desired = -facing * move_speed * 0.7
	else:
		# Rodeia o herói esperando a vez, como numa roda de brincadeira.
		desired = facing.orthogonal() * _strafe_dir * move_speed * 0.6
		if randf() < delta * 0.4:
			_strafe_dir *= -1.0
	velocity = velocity.move_toward(desired, acceleration * delta)


func _go_home() -> void:
	_release_token()
	_set_ai(AI.PLAY)
	_play_goal = home_position
	_play_timer = 2.0


func _begin_attack() -> void:
	_set_ai(AI.ATTACK)
	start_attack(_attack, facing)


func _on_attack_finished() -> void:
	_release_token()
	_cooldown = randf_range(attack_cooldown.x, attack_cooldown.y)
	if ai == AI.ATTACK:
		# Espetou: foge rindo (pega-pega). É aqui que dá para passar por ela.
		_set_ai(AI.FLEE)
		_flee_left = randf_range(flee_time.x, flee_time.y)
		laugh()


func _ai_flee(delta: float) -> void:
	_flee_left -= delta
	if target == null or _flee_left <= 0.0 or global_position.distance_to(home_position) > leash_range:
		_set_ai(AI.CHASE)
		return
	var away := (global_position - target.global_position).normalized()
	facing = -away
	velocity = velocity.move_toward(away * move_speed * 1.1, acceleration * delta)


func _acquire_token() -> bool:
	if _has_token:
		return true
	if _attack_tokens >= MAX_ATTACKERS:
		return false
	_attack_tokens += 1
	_has_token = true
	_token_time = 0.0
	return true


func _release_token() -> void:
	if _has_token:
		_has_token = false
		_attack_tokens = maxi(_attack_tokens - 1, 0)


# --- Levar golpe, cair, levantar -------------------------------------------------------

func _on_damaged(_amount: float, info: HitInfo, _blocked: bool) -> void:
	# A escolha sem aviso: o jogo não diz nada. Só conta.
	if is_instance_valid(info.source) and info.source.is_in_group("player"):
		Game.register_child_hurt()
	if ai == AI.PLAY:
		_set_ai(AI.CHASE)


func _can_be_staggered() -> bool:
	return not down


func _on_poise_broken(_info: HitInfo) -> void:
	_release_token()
	_set_ai(AI.STAGGER)


## "Morrer" aqui é só cair. Nada de memórias, nada de sumir.
func _on_died() -> void:
	down = true
	falls += 1
	_release_token()
	_runner.cancel()
	hitbox.deactivate()
	hurtbox.invulnerable = true  # caída: ninguém acerta quem está no chão
	remove_from_group("enemies")  # a mira assistida a ignora
	_set_ai(AI.DOWN)
	Sfx.play(&"step_heavy", -8.0)
	var side := -1.0 if body_sprite.flip_h else 1.0
	var tween := _restart_pose_tween()
	tween.tween_property(visual, "rotation", deg_to_rad(88.0) * side, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(visual, "modulate", Color(0.7, 0.72, 0.76), 0.4)


## Levanta de novo — menor. Rindo.
func _get_up() -> void:
	down = false
	size_scale = maxf(size_scale * regression_per_fall, MIN_SIZE)
	stats.revive()
	poise = max_poise
	hurtbox.invulnerable = false
	add_to_group("enemies")
	var tween := _restart_pose_tween()
	tween.tween_property(visual, "rotation", 0.0, 0.35).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(visual, "modulate", Color.WHITE, 0.35)
	tween.parallel().tween_property(visual, "scale", Vector2.ONE * size_scale, 0.35)
	shadow.scale = Vector2.ONE * size_scale
	_set_ai(AI.PLAY)
	_play_timer = 0.0
	laugh()


func _restart_pose_tween() -> Tween:
	if _pose_tween and _pose_tween.is_valid():
		_pose_tween.kill()
	_pose_tween = create_tween()
	return _pose_tween


## O riso: som + um "hi hi" flutuando (para quem joga sem som).
func laugh() -> void:
	if _laugh_cooldown > 0.0 or down:
		return
	_laugh_cooldown = randf_range(1.8, 3.0)
	Sfx.play(&"laugh", -9.0, 0.14)
	Fx.float_text(global_position + Vector2(-6, -24 * size_scale), LAUGHS.pick_random(), Color(0.93, 0.96, 1.0), 7)


# --- Espada de madeira -------------------------------------------------------------------

func _update_sword(delta: float) -> void:
	var side := -1.0 if body_sprite.flip_h else 1.0
	sword_pivot.visible = not down
	var rest_angle := (PI * 0.5 - 0.5) if side > 0.0 else (PI * 0.5 + 0.5)
	if ai == AI.ATTACK and _runner.is_running():
		var aim := hitbox_pivot.rotation
		match _runner.phase:
			AttackRunner.Phase.WINDUP:
				sword_pivot.rotation = aim - 2.0 * side * _runner.phase_progress()
			AttackRunner.Phase.LUNGE, AttackRunner.Phase.ACTIVE:
				sword_pivot.rotation = aim
			_:
				sword_pivot.rotation = aim + 0.3 * side
	else:
		sword_pivot.rotation = lerp_angle(sword_pivot.rotation, rest_angle, 10.0 * delta)
	sword_pivot.position = Vector2(3.0 * side, -6.0)
	sword_pivot.z_index = -1 if sin(sword_pivot.rotation) < -0.3 else 1


## NG+ não muda as crianças: a escolha moral do Prólogo é a mesma em todo ciclo.
func scales_with_cycle() -> bool:
	return false
