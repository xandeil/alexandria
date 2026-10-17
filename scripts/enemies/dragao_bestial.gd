class_name DragaoBestial
extends Enemy
## Dragão Bestial — Montanha Carbonizada.
## Bíblia: "Investida tipo dinossauro, mordida. Dragões que nunca subiram de status."
##
## Bicho, não soldado: rodeia, abaixa a cabeça (linha que trava) e DISPARA em
## linha reta, atropelando o que estiver no caminho. Bateu na parede? Tonto.
## De perto, morde. O dash para o lado é a resposta para a investida.

enum AI { IDLE, STALK, AIM, CHARGE, BITE, DAZED, STAGGER }

@export var charge: AttackData
@export var bite: AttackData
@export var charge_range := Vector2(46.0, 150.0)
@export var aim_time := 0.8
@export var bite_range := 20.0
@export var dazed_time := 1.6
@export var cooldown := 1.4

@onready var telegraph: TelegraphDrawer = $Telegraph

var ai := AI.IDLE
var _ai_time := 0.0
var _cooldown := 0.0
var _aim := Vector2.RIGHT


func _physics_process(delta: float) -> void:
	if dead:
		telegraph.hide_all()
		velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)
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
				_set_ai(AI.STALK)
				Sfx.play(&"roar", -12.0, 0.2)
		AI.STALK:
			_stalk(delta)
		AI.AIM:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
			if target and _ai_time < aim_time * 0.7:
				_aim = (target.global_position - global_position).normalized()
				facing = _aim
			if _ai_time >= aim_time:
				_set_ai(AI.CHARGE)
				set_collision_mask_value(2, false)  # atropela: não para no herói
				start_attack(charge, _aim)
				Sfx.play(&"hooves", -6.0)
		AI.CHARGE, AI.BITE:
			velocity = _runner.step(delta, velocity)
		AI.DAZED:
			velocity = velocity.move_toward(Vector2.ZERO, 500.0 * delta)
			if _ai_time >= dazed_time:
				_set_ai(AI.STALK)
		AI.STAGGER:
			velocity = velocity.move_toward(Vector2.ZERO, 500.0 * delta)
			if _ai_time >= stagger_time:
				_set_ai(AI.STALK)
	move_and_slide()
	if ai == AI.CHARGE and _charging_into_something():
		_hit_wall()
	update_body_animation(delta)
	_update_telegraph()


func _set_ai(new_ai: AI) -> void:
	ai = new_ai
	_ai_time = 0.0


func _stalk(delta: float) -> void:
	if target == null or global_position.distance_to(home_position) > leash_range:
		_set_ai(AI.IDLE)
		return
	var to_target := target.global_position - global_position
	var distance := to_target.length()
	facing = to_target.normalized()
	if _cooldown <= 0.0:
		if distance <= bite_range:
			_set_ai(AI.BITE)
			start_attack(bite, facing)
			return
		if distance >= charge_range.x and distance <= charge_range.y and can_see(target.global_position):
			_aim = facing
			_set_ai(AI.AIM)
			Sfx.play(&"telegraph", -8.0)
			return
	# rodeia de lado, aproximando
	var goal := facing * move_speed * (1.0 if distance > charge_range.x else 0.2) + facing.orthogonal() * move_speed * 0.5
	velocity = velocity.move_toward(goal, acceleration * delta)


## Bateu em algo DURANTE a corrida? (checado logo depois de mover: a batida
## pode acontecer no mesmo quadro em que a corrida acaba.)
func _charging_into_something() -> bool:
	var running := _runner.phase == AttackRunner.Phase.LUNGE or _runner.phase == AttackRunner.Phase.ACTIVE
	return running and get_slide_collision_count() > 0


func _hit_wall() -> void:
	_runner.cancel()
	hitbox.deactivate()
	set_collision_mask_value(2, true)
	velocity = -_aim * 60.0
	Sfx.play(&"slam", -6.0)
	Fx.shake(2.5, 0.2)
	Fx.float_text(global_position + Vector2(-8, -24), "tonto", Color(1.0, 0.85, 0.6), 7)
	_set_ai(AI.DAZED)


func _on_attack_finished() -> void:
	set_collision_mask_value(2, true)
	_cooldown = cooldown
	if ai == AI.CHARGE or ai == AI.BITE:
		_set_ai(AI.STALK)


func _on_damaged(_amount: float, _info: HitInfo, _blocked: bool) -> void:
	if ai == AI.IDLE:
		_set_ai(AI.STALK)


func _on_poise_broken(_info: HitInfo) -> void:
	set_collision_mask_value(2, true)
	_set_ai(AI.STAGGER)


func _can_be_staggered() -> bool:
	return ai != AI.CHARGE


func _update_telegraph() -> void:
	telegraph.line_visible = ai == AI.AIM
	if ai == AI.AIM:
		telegraph.line_origin = global_position + Vector2(0, -4)
		telegraph.line_direction = _aim
		telegraph.line_length = charge.lunge_speed * charge.lunge_time + charge.reach
		telegraph.line_locked = _ai_time >= aim_time * 0.7
