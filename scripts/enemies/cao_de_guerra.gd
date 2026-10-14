class_name CaoDeGuerra
extends Enemy
## Cão de Guerra Mecânico — Cidade Estilhaçada.
## Bíblia: "Rápido, morde e recua. Equipamento militar que ainda obedece."
##
## Como ele luta: RODEIA o herói a uma distância segura (rápido demais para
## você alcançar andando), avisa (pisca em vermelho e agacha), dá o BOTE em
## linha reta e RECUA. A janela para punir é logo depois do bote, antes de ele
## fugir — ou espere o bote e esquive para o lado.

enum AI { PROWL, CIRCLE, BITE, RETREAT, STAGGER }

@export var attack: AttackData
## Distância em que ele rodeia antes do bote.
@export var circle_distance := 52.0
## Do alcance do bote para dentro, ele ataca.
@export var bite_range := 46.0
@export var attack_cooldown := Vector2(1.2, 2.0)
@export var retreat_time := 0.6

var ai := AI.PROWL
var _ai_time := 0.0
var _cooldown := 0.0
var _orbit := 1.0
var _prowl_goal := Vector2.ZERO
var _prowl_timer := 0.0


func _ready() -> void:
	super._ready()
	_orbit = 1.0 if randf() < 0.5 else -1.0
	_prowl_goal = home_position


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
		AI.PROWL:
			_prowl(delta)
		AI.CIRCLE:
			_circle(delta)
		AI.BITE:
			track_target_during_windup()
			velocity = _runner.step(delta, velocity)
		AI.RETREAT:
			if target:
				var away := (global_position - target.global_position).normalized()
				velocity = velocity.move_toward(away * move_speed * 1.2, acceleration * delta)
			if _ai_time >= retreat_time:
				_set_ai(AI.CIRCLE)
		AI.STAGGER:
			velocity = velocity.move_toward(Vector2.ZERO, 500.0 * delta)
			if _ai_time >= stagger_time:
				_set_ai(AI.CIRCLE)
	move_and_slide()
	update_body_animation(delta)
	_update_bite_pose()


func _set_ai(new_ai: AI) -> void:
	ai = new_ai
	_ai_time = 0.0


## Fareja em volta do posto (o mesmo trajeto, sempre).
func _prowl(delta: float) -> void:
	_prowl_timer -= delta
	if _prowl_timer <= 0.0:
		_prowl_timer = randf_range(1.0, 2.2)
		_prowl_goal = home_position + Vector2.from_angle(randf() * TAU) * randf_range(6.0, 30.0)
	var to_goal := _prowl_goal - global_position
	if to_goal.length() > 3.0:
		facing = to_goal.normalized()
		velocity = velocity.move_toward(facing * move_speed * 0.35, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	if target and global_position.distance_to(target.global_position) < aggro_range and can_see(target.global_position):
		_set_ai(AI.CIRCLE)
		_cooldown = maxf(_cooldown, 0.5)
		Sfx.play(&"bark", -6.0)


func _circle(delta: float) -> void:
	if target == null or global_position.distance_to(home_position) > leash_range:
		_set_ai(AI.PROWL)
		_prowl_goal = home_position
		return
	var to_target := target.global_position - global_position
	var distance := to_target.length()
	facing = to_target.normalized()
	if _cooldown <= 0.0 and can_see(target.global_position):
		if distance <= bite_range:
			_set_ai(AI.BITE)
			start_attack(attack, facing)
			return
		# Pronto para o bote: fecha a distância em espiral.
		velocity = velocity.move_toward((facing + facing.orthogonal() * _orbit * 0.3).normalized() * move_speed, acceleration * delta)
		return
	var desired := facing.orthogonal() * _orbit * move_speed * 0.8
	if distance > circle_distance + 10.0:
		desired += facing * move_speed
	elif distance < circle_distance - 10.0:
		desired -= facing * move_speed * 0.6
	if randf() < delta * 0.35:
		_orbit *= -1.0
	velocity = velocity.move_toward(desired, acceleration * delta)


func _on_attack_finished() -> void:
	_cooldown = randf_range(attack_cooldown.x, attack_cooldown.y)
	if ai == AI.BITE:
		_set_ai(AI.RETREAT)


func _on_damaged(_amount: float, _info: HitInfo, _blocked: bool) -> void:
	if ai == AI.PROWL:
		_set_ai(AI.CIRCLE)


func _on_poise_broken(_info: HitInfo) -> void:
	_set_ai(AI.STAGGER)
	Sfx.play(&"clang", -6.0)


## Boca aberta do aviso até o fim do bote.
func _update_bite_pose() -> void:
	var biting := ai == AI.BITE and _runner.is_running() and _runner.phase != AttackRunner.Phase.RECOVERY
	if biting and body_sprite.animation != &"morder":
		body_sprite.play(&"morder")
	elif not biting and body_sprite.animation == &"morder":
		body_sprite.play(&"idle")
	# Agacha no aviso: o corpo "carrega" o bote.
	if ai == AI.BITE and _runner.phase == AttackRunner.Phase.WINDUP:
		visual.scale = Vector2(1.08, 0.88)
	else:
		visual.scale = visual.scale.lerp(Vector2.ONE, 0.3)
