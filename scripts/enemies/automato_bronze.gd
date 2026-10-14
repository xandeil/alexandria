class_name AutomatoBronze
extends Enemy
## Autômato de Bronze — Forjas Ocas.
## Bíblia: "Golpes lentos; rosto igual ao do Ferreiro do Teatro. As cópias que
## Durgan fez do irmão."
##
## Lento e blindado: o bronze segura parte de cada corte (30%) — só o golpe
## FORTE entra inteiro. Em troca, ele avisa muito (braço erguido, clarão) e
## demora a se recompor. Às vezes emenda um segundo golpe: não comemore cedo.

enum AI { IDLE, CHASE, ATTACK, STAGGER, RETURN }

@export var hammer: AttackData
@export var attack_range := 22.0
@export var attack_cooldown := Vector2(1.3, 2.0)
@export_range(0.0, 1.0) var double_chance := 0.35
## Quanto do corte leve o bronze deixa passar.
@export_range(0.0, 1.0) var light_damage_ratio := 0.7

var ai := AI.IDLE
var _ai_time := 0.0
var _cooldown := 0.0
var _swings_left := 0
var _step_timer := 0.0


func _physics_process(delta: float) -> void:
	if dead:
		velocity = velocity.move_toward(Vector2.ZERO, 400.0 * delta)
		move_and_slide()
		return
	_ai_time += delta
	_cooldown -= delta
	regen_poise(delta)
	target = find_target()
	match ai:
		AI.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
			if target and global_position.distance_to(target.global_position) <= aggro_range and can_see(target.global_position):
				_set_ai(AI.CHASE)
				Sfx.play(&"clank", -8.0, 0.2)
		AI.CHASE:
			_chase(delta)
		AI.ATTACK:
			track_target_during_windup()
			velocity = _runner.step(delta, velocity)
		AI.STAGGER:
			velocity = velocity.move_toward(Vector2.ZERO, 400.0 * delta)
			if _ai_time >= stagger_time:
				_set_ai(AI.CHASE)
		AI.RETURN:
			var to_home := home_position - global_position
			if to_home.length() > 4.0:
				facing = to_home.normalized()
				velocity = velocity.move_toward(facing * move_speed, acceleration * delta)
			else:
				velocity = Vector2.ZERO
				_set_ai(AI.IDLE)
	move_and_slide()
	update_body_animation(delta)
	if ai == AI.ATTACK and _runner.is_running() and _runner.phase == AttackRunner.Phase.WINDUP:
		body_sprite.play(&"ergue")  # o martelo sobe: o aviso do golpe
	_footsteps(delta)


func _set_ai(new_ai: AI) -> void:
	ai = new_ai
	_ai_time = 0.0


func _chase(delta: float) -> void:
	if target == null or global_position.distance_to(home_position) > leash_range:
		_set_ai(AI.RETURN)
		return
	var to_target := target.global_position - global_position
	facing = to_target.normalized()
	if to_target.length() <= attack_range and _cooldown <= 0.0:
		_swings_left = 2 if randf() < double_chance else 1
		_swing()
		return
	velocity = velocity.move_toward(facing * move_speed, acceleration * delta)


func _swing() -> void:
	_swings_left -= 1
	_set_ai(AI.ATTACK)
	start_attack(hammer, (target.global_position - global_position).normalized() if target else facing)


func _on_attack_finished() -> void:
	if ai != AI.ATTACK:
		return
	if _swings_left > 0 and target:
		_swing()
		return
	_cooldown = randf_range(attack_cooldown.x, attack_cooldown.y)
	_set_ai(AI.CHASE)


## Bronze: o corte leve perde força; o forte entra inteiro.
func _incoming_damage_multiplier(info: HitInfo) -> float:
	return 1.0 if info.is_heavy else light_damage_ratio


func _on_damaged(_amount: float, info: HitInfo, _blocked: bool) -> void:
	if not info.is_heavy:
		Sfx.play(&"clang", -10.0, 0.2)
	if ai == AI.IDLE or ai == AI.RETURN:
		_set_ai(AI.CHASE)


func _on_poise_broken(_info: HitInfo) -> void:
	_swings_left = 0
	_set_ai(AI.STAGGER)


func _footsteps(delta: float) -> void:
	if velocity.length() < 5.0:
		return
	_step_timer -= delta
	if _step_timer <= 0.0:
		_step_timer = 0.55
		Sfx.play(&"clank", -16.0, 0.25)
