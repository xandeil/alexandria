class_name CivilCinzento
extends Enemy
## Civil Cinzento — Cidade Estilhaçada.
## Bíblia: "Passivo; só ataca se for atacado ou se o jogador passar correndo.
## Moradores que Aldir não conseguiu salvar."
##
## A regra que o jogador aprende olhando: eles param e te observam quando você
## chega perto ("..."). Passe DEVAGAR (joystick pela metade) ou de longe e nada
## acontece. Dar dash perto deles, passar correndo colado, ou bater neles → eles
## se assustam ("?!") e atacam. Sem ninguém por perto, voltam a vagar.

enum AI { WANDER, WARY, HOSTILE, ATTACK, STAGGER }

@export var attack: AttackData
## Perto disso eles param e observam.
@export var wary_distance := 60.0
## Dash dentro deste raio assusta.
@export var dash_alarm_distance := 56.0
## Passar "correndo" (acima de running_speed) dentro deste raio assusta.
@export var brush_distance := 26.0
@export var running_speed := 70.0
## Sem apanhar e com o herói longe por tanto tempo, se acalmam.
@export var calm_time := 6.0
@export var attack_range := 16.0
@export var attack_cooldown := Vector2(1.4, 2.2)

var ai := AI.WANDER
var _ai_time := 0.0
var _cooldown := 0.0
var _calm := 0.0
var _goal := Vector2.ZERO
var _goal_timer := 0.0


func _ready() -> void:
	super._ready()
	_goal = home_position


## Passivos não puxam a mira assistida: só se bate num civil de propósito.
func is_targetable() -> bool:
	return is_hostile() and super.is_targetable()


func is_hostile() -> bool:
	return ai == AI.HOSTILE or ai == AI.ATTACK or ai == AI.STAGGER


func _physics_process(delta: float) -> void:
	if dead:
		velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)
		move_and_slide()
		return
	_ai_time += delta
	_cooldown -= delta
	regen_poise(delta)
	target = find_target()
	match ai:
		AI.WANDER, AI.WARY:
			_passive(delta)
		AI.HOSTILE:
			_hostile(delta)
		AI.ATTACK:
			track_target_during_windup()
			velocity = _runner.step(delta, velocity)
		AI.STAGGER:
			velocity = velocity.move_toward(Vector2.ZERO, 500.0 * delta)
			if _ai_time >= stagger_time:
				_set_ai(AI.HOSTILE)
	move_and_slide()
	update_body_animation(delta)
	_update_pose()


func _set_ai(new_ai: AI) -> void:
	ai = new_ai
	_ai_time = 0.0


# --- Passivo ------------------------------------------------------------------------

func _passive(delta: float) -> void:
	var distance := INF if target == null else global_position.distance_to(target.global_position)
	if target and _is_provoked(distance):
		alarm()
		return
	if distance <= wary_distance:
		# Param e acompanham o herói com os olhos. Só isso.
		if ai != AI.WARY:
			_set_ai(AI.WARY)
			Fx.float_text(global_position + Vector2(-4, -26), "...", Color(0.8, 0.8, 0.8), 7)
		facing = (target.global_position - global_position).normalized()
		velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
		return
	if ai == AI.WARY:
		_set_ai(AI.WANDER)
	_goal_timer -= delta
	if _goal_timer <= 0.0:
		_goal_timer = randf_range(1.5, 3.5)
		_goal = home_position + Vector2.from_angle(randf() * TAU) * randf_range(4.0, 26.0)
	var to_goal := _goal - global_position
	if to_goal.length() > 3.0:
		facing = to_goal.normalized()
		velocity = velocity.move_toward(facing * move_speed * 0.4, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)


## "Se o jogador passar correndo": dash por perto, ou passar rápido colado.
func _is_provoked(distance: float) -> bool:
	if target.state == Player.State.DASH and distance <= dash_alarm_distance:
		return true
	return distance <= brush_distance and target.velocity.length() > running_speed


## Assusta: vira hostil (som, "?!") — e chama quem estiver perto também.
func alarm(spread: bool = true) -> void:
	if is_hostile() or dead:
		return
	_set_ai(AI.HOSTILE)
	_calm = 0.0
	_cooldown = randf_range(0.3, 0.7)
	Sfx.play(&"moan", -6.0, 0.15)
	Fx.float_text(global_position + Vector2(-4, -26), "?!", Color(1.0, 0.75, 0.7), 8)
	if spread:
		for node in get_tree().get_nodes_in_group("enemies"):
			var other := node as CivilCinzento
			if other and other != self and other.global_position.distance_to(global_position) < 70.0:
				other.alarm(false)


# --- Hostil -------------------------------------------------------------------------

func _hostile(delta: float) -> void:
	if target == null:
		_calm_down()
		return
	var to_target := target.global_position - global_position
	var distance := to_target.length()
	_calm = _calm + delta if distance > 90.0 else 0.0
	if _calm >= calm_time or global_position.distance_to(home_position) > leash_range:
		_calm_down()
		return
	facing = to_target.normalized()
	if _cooldown <= 0.0 and distance <= attack_range:
		_set_ai(AI.ATTACK)
		start_attack(attack, facing)
		return
	velocity = velocity.move_toward(facing * move_speed, acceleration * delta)


func _calm_down() -> void:
	_set_ai(AI.WANDER)
	_goal = home_position
	_goal_timer = 3.0


func _on_attack_finished() -> void:
	_cooldown = randf_range(attack_cooldown.x, attack_cooldown.y)
	if ai == AI.ATTACK:
		_set_ai(AI.HOSTILE)


func _on_damaged(_amount: float, _info: HitInfo, _blocked: bool) -> void:
	_calm = 0.0
	alarm()


func _on_poise_broken(_info: HitInfo) -> void:
	_set_ai(AI.STAGGER)


func _update_pose() -> void:
	var grabbing := ai == AI.ATTACK and _runner.is_running() and _runner.phase != AttackRunner.Phase.RECOVERY
	if grabbing and body_sprite.animation != &"agarrar":
		body_sprite.play(&"agarrar")
	elif not grabbing and body_sprite.animation == &"agarrar":
		body_sprite.play(&"idle")
