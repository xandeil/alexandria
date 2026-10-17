class_name DragonoideAtirador
extends Enemy
## Dragonoide Atirador — Montanha Carbonizada.
## Bíblia: "Armas de fogo, mantém distância. Servos de Rachel (o Vendedor do
## Teatro é um desertor)."
##
## Diferente do Atirador de Telhado (parado no telhado), este ANDA: guarda
## distância, recua quando você chega perto e atira uma rajada de três bolas
## de fogo. A mira tem a linha que trava; as bolas deixam fogo onde batem.
## Colado nele, ele dá uma coronhada e pula para trás.

enum AI { IDLE, KEEP, AIM, FIRE, MELEE, STAGGER }

@export var melee: AttackData
@export var keep_range := Vector2(80.0, 130.0)
@export var aim_time := 0.9
@export_range(0.1, 1.0) var lock_at := 0.7
@export var shots := 3
@export var shot_gap := 0.18
@export var spread_degrees := 9.0
@export var shot_damage := 14.0
@export var shot_speed := 150.0
@export var shot_range := 260.0
@export var cooldown := 1.6
@export var melee_range := 20.0

@onready var telegraph: TelegraphDrawer = $Telegraph

var ai := AI.IDLE
var _ai_time := 0.0
var _aim_dir := Vector2.LEFT
var _fired := 0
var _cooldown := 0.0


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
				_set_ai(AI.KEEP)
		AI.KEEP:
			_keep(delta)
		AI.AIM:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
			if target and _ai_time < aim_time * lock_at:
				_aim_dir = (target.global_position - global_position).normalized()
				facing = _aim_dir
			if _ai_time >= aim_time:
				_fired = 0
				_set_ai(AI.FIRE)
		AI.FIRE:
			velocity = Vector2.ZERO
			if _ai_time >= _fired * shot_gap and _fired < shots:
				_shoot(_fired)
				_fired += 1
			if _fired >= shots and _ai_time >= shots * shot_gap + 0.2:
				_cooldown = cooldown
				_set_ai(AI.KEEP)
		AI.MELEE:
			track_target_during_windup()
			velocity = _runner.step(delta, velocity)
		AI.STAGGER:
			velocity = velocity.move_toward(Vector2.ZERO, 500.0 * delta)
			if _ai_time >= stagger_time:
				_set_ai(AI.KEEP)
	move_and_slide()
	update_body_animation(delta)
	_update_telegraph()


func _set_ai(new_ai: AI) -> void:
	ai = new_ai
	_ai_time = 0.0


## Guarda distância: perto demais recua, longe demais se aproxima.
func _keep(delta: float) -> void:
	if target == null or global_position.distance_to(home_position) > leash_range:
		velocity = velocity.move_toward((home_position - global_position).normalized() * move_speed, acceleration * delta)
		if global_position.distance_to(home_position) < 6.0:
			_set_ai(AI.IDLE)
		return
	var to_target := target.global_position - global_position
	var distance := to_target.length()
	facing = to_target.normalized()
	if distance <= melee_range and _cooldown <= 0.5:
		_set_ai(AI.MELEE)
		start_attack(melee, facing)
		return
	if _cooldown <= 0.0 and distance <= shot_range * 0.8 and can_see(target.global_position):
		_aim_dir = facing
		_set_ai(AI.AIM)
		Sfx.play(&"telegraph", -10.0)
		return
	var goal := facing.orthogonal() * sin(_ai_time * 1.3) * move_speed * 0.5
	if distance < keep_range.x:
		goal -= facing * move_speed
	elif distance > keep_range.y:
		goal += facing * move_speed
	velocity = velocity.move_toward(goal, acceleration * delta)


func _shoot(index: int) -> void:
	var offset := deg_to_rad(spread_degrees) * (index - (shots - 1) * 0.5)
	var muzzle := global_position + Vector2(0, -9) + _aim_dir * 10.0
	Projectile.launch(get_parent(), muzzle, _aim_dir.rotated(offset), self, shot_damage, shot_speed, shot_range, true)
	Sfx.play(&"fireball", -6.0, 0.15)


func _on_attack_finished() -> void:
	if ai == AI.MELEE:
		# Coronhada e um pulo para trás: volta a guardar distância.
		if target:
			velocity = (global_position - target.global_position).normalized() * 160.0
		_cooldown = 0.4
		_set_ai(AI.KEEP)


func _on_damaged(_amount: float, _info: HitInfo, _blocked: bool) -> void:
	if ai == AI.IDLE:
		_set_ai(AI.KEEP)


func _on_poise_broken(_info: HitInfo) -> void:
	_set_ai(AI.STAGGER)


func _update_telegraph() -> void:
	telegraph.line_visible = ai == AI.AIM
	if ai == AI.AIM:
		telegraph.line_origin = global_position + Vector2(0, -6)
		telegraph.line_direction = _aim_dir
		telegraph.line_length = 120.0
		telegraph.line_locked = _ai_time >= aim_time * lock_at
