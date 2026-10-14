class_name Sonambulo
extends Enemy
## Sonâmbulo — Bosque do Sono Eterno.
## Bíblia: "Só acorda se o jogador correr ou atacar por perto. Pessoas que
## Nyssa nunca deixou acordar."
##
## A regra: ele é CEGO (os olhos nunca abrem). Acorda com BARULHO
## (Player.make_noise: dash, golpe, passos apressados) e anda até o lugar do
## som — não até você. Ficou parado ou andando devagar? Ele chega no ponto,
## tateia o ar... e volta a dormir. É furtividade de verdade: "congele" e ele passa.

enum AI { SLEEP, SLEEPWALK, ATTACK, STAGGER, RETURN }

@export var attack: AttackData
## Encostar nele também acorda (ele sente o toque).
@export var touch_distance := 14.0
@export var attack_range := 18.0
@export var attack_cooldown := Vector2(1.2, 1.8)
## Chegou ao lugar do som e não ouviu mais nada: espera isso e volta a dormir.
@export var linger_time := 2.2

var ai := AI.SLEEP
var noise_point := Vector2.ZERO
var _ai_time := 0.0
var _cooldown := 0.0
var _linger := 0.0
var _zzz := 0.0


func _ready() -> void:
	super._ready()
	add_to_group("listeners")
	_zzz = randf() * 2.0


## Dormindo, não puxa a mira assistida (não se bate num sonâmbulo sem querer).
func is_targetable() -> bool:
	return ai != AI.SLEEP and ai != AI.RETURN and super.is_targetable()


func is_awake() -> bool:
	return ai == AI.SLEEPWALK or ai == AI.ATTACK or ai == AI.STAGGER


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
		AI.SLEEP:
			_sleep(delta)
		AI.SLEEPWALK:
			_sleepwalk(delta)
		AI.ATTACK:
			velocity = _runner.step(delta, velocity)
		AI.STAGGER:
			velocity = velocity.move_toward(Vector2.ZERO, 500.0 * delta)
			if _ai_time >= stagger_time:
				_set_ai(AI.SLEEPWALK)
		AI.RETURN:
			_return_home(delta)
	move_and_slide()
	update_body_animation(delta)
	_update_pose()


func _set_ai(new_ai: AI) -> void:
	ai = new_ai
	_ai_time = 0.0


func _hears_player() -> bool:
	if target == null:
		return false
	if global_position.distance_to(target.global_position) <= touch_distance:
		return true
	return target.is_heard_from(global_position)


# --- Dormindo -----------------------------------------------------------------------

func _sleep(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	_zzz -= delta
	if _zzz <= 0.0:
		_zzz = randf_range(2.2, 3.2)
		Fx.float_text(global_position + Vector2(2, -26), "z", Color(0.8, 0.78, 0.95), 7)
	if _hears_player():
		wake(target.global_position)


## Acorda e vai até o som (a fase também chama, ex.: barulho de luta perto).
func wake(at: Vector2) -> void:
	if dead or is_awake():
		noise_point = at
		return
	noise_point = at
	_linger = 0.0
	_cooldown = 0.6
	_set_ai(AI.SLEEPWALK)
	Sfx.play(&"moan", -10.0, 0.25)
	Fx.float_text(global_position + Vector2(-2, -26), "?", Color(0.85, 0.82, 1.0), 8)


# --- Sonambulando (vai até o som) -------------------------------------------------------

func _sleepwalk(delta: float) -> void:
	if _hears_player():
		noise_point = target.global_position  # barulho de novo: corrige o rumo
		_linger = 0.0
	if target and _cooldown <= 0.0 and global_position.distance_to(target.global_position) <= attack_range:
		# Esbarrou em alguém: os braços vão para frente.
		_set_ai(AI.ATTACK)
		start_attack(attack, (target.global_position - global_position).normalized())
		return
	var to_point := noise_point - global_position
	if to_point.length() > 6.0:
		facing = to_point.normalized()
		velocity = velocity.move_toward(facing * move_speed, acceleration * delta)
		if _ai_time > 8.0 or global_position.distance_to(home_position) > leash_range:
			_go_home()  # andou demais atrás de um eco
		return
	# Chegou e não há mais nada: tateia o ar um pouco e desiste.
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	_linger += delta
	if fmod(_linger, 0.8) < delta:
		facing = Vector2(-facing.x, facing.y) if facing.x != 0.0 else Vector2.LEFT  # vira para um lado e para o outro
	if _linger >= linger_time:
		_go_home()


func _go_home() -> void:
	_set_ai(AI.RETURN)
	Fx.float_text(global_position + Vector2(-2, -26), "...", Color(0.8, 0.78, 0.95), 7)


func _return_home(delta: float) -> void:
	if _hears_player():
		wake(target.global_position)
		return
	var to_home := home_position - global_position
	if to_home.length() > 4.0:
		facing = to_home.normalized()
		velocity = velocity.move_toward(facing * move_speed * 0.7, acceleration * delta)
	else:
		velocity = Vector2.ZERO
		_set_ai(AI.SLEEP)


func _on_attack_finished() -> void:
	_cooldown = randf_range(attack_cooldown.x, attack_cooldown.y)
	if ai == AI.ATTACK:
		_set_ai(AI.SLEEPWALK)


func _on_damaged(_amount: float, info: HitInfo, _blocked: bool) -> void:
	wake(info.source_position)


func _on_poise_broken(_info: HitInfo) -> void:
	_set_ai(AI.STAGGER)


func _update_pose() -> void:
	var reaching := ai == AI.ATTACK and _runner.is_running() and _runner.phase != AttackRunner.Phase.RECOVERY
	if reaching and body_sprite.animation != &"bracos":
		body_sprite.play(&"bracos")
	elif not reaching and body_sprite.animation == &"bracos":
		body_sprite.play(&"idle")
	# Dormindo em pé: o corpo balança devagar, a cabeça pende.
	if ai == AI.SLEEP:
		visual.rotation = sin(Time.get_ticks_msec() * 0.0015 + home_position.x) * 0.06
	else:
		visual.rotation = lerpf(visual.rotation, 0.0, 0.2)
