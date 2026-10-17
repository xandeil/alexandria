class_name BibliotecarioGelo
extends Enemy
## Bibliotecário de Gelo — Domínio Congelado.
## Bíblia: "Lança projéteis de gelo, foge quando chegam perto. Servos que
## guardam a coleção."
##
## Um conjurador covarde: de longe, mira (linha que trava) e lança dois
## estilhaços de gelo — quem leva fica LENTO por um instante. Chegou perto,
## ele foge para longe e recomeça. A resposta é encurralá-lo (ou cortar o
## caminho com o dash), não correr atrás em linha reta no gelo.

enum AI { IDLE, KEEP, AIM, CAST, FLEE, STAGGER }

@export var flee_range := 52.0
@export var keep_range := Vector2(90.0, 140.0)
@export var aim_time := 0.8
@export_range(0.1, 1.0) var lock_at := 0.7
@export var shards := 2
@export var shard_gap := 0.22
@export var shard_damage := 12.0
@export var shard_speed := 140.0
@export var shard_range := 240.0
@export var cooldown := 1.8
@export var flee_time := 1.1
@export var flee_speed_multiplier := 1.5

@onready var telegraph: TelegraphDrawer = $Telegraph

var ai := AI.IDLE
var _ai_time := 0.0
var _aim_dir := Vector2.LEFT
var _cast := 0
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
				_cast = 0
				_set_ai(AI.CAST)
		AI.CAST:
			velocity = Vector2.ZERO
			if _cast < shards and _ai_time >= _cast * shard_gap:
				_shoot()
				_cast += 1
			if _cast >= shards and _ai_time >= shards * shard_gap + 0.15:
				_cooldown = cooldown
				_set_ai(AI.KEEP)
		AI.FLEE:
			_flee(delta)
		AI.STAGGER:
			velocity = velocity.move_toward(Vector2.ZERO, 500.0 * delta)
			if _ai_time >= stagger_time:
				_set_ai(AI.FLEE)
	move_and_slide()
	update_body_animation(delta)
	_update_telegraph()


func _set_ai(new_ai: AI) -> void:
	ai = new_ai
	_ai_time = 0.0


func _keep(delta: float) -> void:
	if target == null or global_position.distance_to(home_position) > leash_range:
		velocity = velocity.move_toward((home_position - global_position).normalized() * move_speed, acceleration * delta)
		if global_position.distance_to(home_position) < 6.0:
			_set_ai(AI.IDLE)
		return
	var to_target := target.global_position - global_position
	var distance := to_target.length()
	facing = to_target.normalized()
	if distance <= flee_range:
		_set_ai(AI.FLEE)
		Sfx.play(&"crystal", -10.0, 0.2)
		return
	if _cooldown <= 0.0 and distance <= shard_range * 0.75 and can_see(target.global_position):
		_aim_dir = facing
		_set_ai(AI.AIM)
		Sfx.play(&"telegraph", -10.0)
		return
	var goal := facing.orthogonal() * sin(_ai_time * 1.1) * move_speed * 0.5
	if distance < keep_range.x:
		goal -= facing * move_speed
	elif distance > keep_range.y:
		goal += facing * move_speed
	velocity = velocity.move_toward(goal, acceleration * delta)


## Foge para longe do herói (um pouco de lado, para não ficar na mesma linha).
func _flee(delta: float) -> void:
	if target:
		var away := (global_position - target.global_position).normalized()
		var side := away.orthogonal() * (0.4 if int(home_position.x) % 2 == 0 else -0.4)
		velocity = velocity.move_toward((away + side).normalized() * move_speed * flee_speed_multiplier, acceleration * 1.5 * delta)
		facing = -away
	if _ai_time >= flee_time:
		_set_ai(AI.KEEP)


func _shoot() -> void:
	var muzzle := global_position + Vector2(0, -10) + _aim_dir * 8.0
	var spread := deg_to_rad(6.0) * (_cast - (shards - 1) * 0.5)
	Projectile.launch(get_parent(), muzzle, _aim_dir.rotated(spread), self, shard_damage, shard_speed, shard_range, Projectile.FROST)
	Sfx.play(&"ice_shot", -6.0, 0.15)


func _on_damaged(_amount: float, _info: HitInfo, _blocked: bool) -> void:
	if ai == AI.IDLE or ai == AI.KEEP or ai == AI.AIM:
		_set_ai(AI.FLEE)  # apanhou: some de perto


func _on_poise_broken(_info: HitInfo) -> void:
	_set_ai(AI.STAGGER)


func _update_telegraph() -> void:
	telegraph.line_visible = ai == AI.AIM
	if ai == AI.AIM:
		telegraph.line_origin = global_position + Vector2(0, -8)
		telegraph.line_direction = _aim_dir
		telegraph.line_length = 110.0
		telegraph.line_locked = _ai_time >= aim_time * lock_at
