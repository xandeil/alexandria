class_name Colhedor
extends Enemy
## Colhedor — Raízes da Fome.
## Bíblia: "Foice longa, ataque em arco. Antigos trabalhadores das estufas."
##
## Ele luta à DISTÂNCIA DA FOICE: mais longe do que a sua espada alcança.
## O arco é largo (200°) e lento — o leque vermelho no chão mostra a área.
## A brecha: entre na guarda dele logo depois do golpe (recuperação longa).
## Mas não fique colado tempo demais: ele gira a foice em volta (círculo).

enum AI { IDLE, CHASE, ATTACK, STAGGER, RETURN }

@export var sweep: AttackData
@export var spin: AttackData
## Distância que ele tenta manter (a ponta da foice).
@export var preferred_range := 30.0
@export var attack_cooldown := Vector2(1.0, 1.6)
## Colado nele por isso (s): gira.
@export var close_patience := 0.9
@export var close_range := 16.0

@onready var telegraph: TelegraphDrawer = $Telegraph

var ai := AI.IDLE
var _ai_time := 0.0
var _cooldown := 0.0
var _close_time := 0.0


func _physics_process(delta: float) -> void:
	if dead:
		velocity = velocity.move_toward(Vector2.ZERO, 500.0 * delta)
		move_and_slide()
		telegraph.hide_all()
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
		AI.CHASE:
			_chase(delta)
		AI.ATTACK:
			if _current_attack == sweep:
				track_target_during_windup()
			velocity = _runner.step(delta, velocity)
		AI.STAGGER:
			velocity = velocity.move_toward(Vector2.ZERO, 500.0 * delta)
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
	_update_pose()


func _set_ai(new_ai: AI) -> void:
	ai = new_ai
	_ai_time = 0.0


func _chase(delta: float) -> void:
	if target == null or global_position.distance_to(home_position) > leash_range:
		_set_ai(AI.RETURN)
		return
	var to_target := target.global_position - global_position
	var distance := to_target.length()
	facing = to_target.normalized()
	_close_time = _close_time + delta if distance <= close_range else maxf(_close_time - delta, 0.0)
	if _cooldown <= 0.0:
		if _close_time >= close_patience:
			_attack(spin)
			return
		if distance <= preferred_range + 6.0:
			_attack(sweep)
			return
	# Aproxima até a ponta da foice; perto demais, recua um passo.
	var goal := Vector2.ZERO
	if distance > preferred_range:
		goal = facing * move_speed
	elif distance < preferred_range - 10.0:
		goal = -facing * move_speed * 0.6
	velocity = velocity.move_toward(goal, acceleration * delta)


func _attack(attack: AttackData) -> void:
	_close_time = 0.0
	_set_ai(AI.ATTACK)
	start_attack(attack, facing)


func _on_attack_finished() -> void:
	_cooldown = randf_range(attack_cooldown.x, attack_cooldown.y)
	if ai == AI.ATTACK:
		_set_ai(AI.CHASE)


func _on_damaged(_amount: float, _info: HitInfo, _blocked: bool) -> void:
	if ai == AI.IDLE or ai == AI.RETURN:
		_set_ai(AI.CHASE)


func _on_poise_broken(_info: HitInfo) -> void:
	_set_ai(AI.STAGGER)


func _update_pose() -> void:
	var swinging := ai == AI.ATTACK and _runner.is_running()
	if swinging:
		var anim := &"prepara" if _runner.phase == AttackRunner.Phase.WINDUP else &"ceifa"
		if body_sprite.animation != anim:
			body_sprite.play(anim)
	elif body_sprite.animation == &"prepara" or body_sprite.animation == &"ceifa":
		body_sprite.play(&"idle")
	telegraph.circle_visible = false
	telegraph.arc_visible = false
	if not swinging or _runner.phase != AttackRunner.Phase.WINDUP:
		return
	if _current_attack == spin:
		telegraph.circle_visible = true
		telegraph.circle_center = global_position
		telegraph.circle_radius = spin.radius
		telegraph.circle_progress = _runner.phase_progress()
	else:
		telegraph.arc_visible = true
		telegraph.arc_center = global_position
		telegraph.arc_direction = _runner.direction
		telegraph.arc_radius = sweep.reach + sweep.radius
		telegraph.arc_angle = deg_to_rad(sweep.slash_arc_degrees)
		telegraph.arc_progress = _runner.phase_progress()
