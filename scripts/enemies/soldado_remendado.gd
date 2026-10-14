class_name SoldadoRemendado
extends Enemy
## Soldado Remendado — Cidade Estilhaçada.
## Bíblia: "Ataca em grupo, bloqueia com escudo. Exército do governo preso à última missão."
##
## Como lutar contra ele (combate metódico):
##   • De frente, o escudo segura quase tudo (15% do dano) e gasta a GUARDA dele.
##   • Pelas costas/lados o escudo não protege.
##   • Quando ATACA, o escudo abaixa: esquive (dash) e puna na recuperação.
##   • Golpe forte (segurar Ataque) destrói a guarda rápido → cambaleio longo.
##
## "Ataca em grupo": usamos FICHAS DE ATAQUE. Só MAX_ATTACKERS soldados podem
## atacar ao mesmo tempo; os outros cercam o herói esperando a vez. É um padrão
## clássico de IA de grupo — sem ele, 4 soldados batendo juntos seria injusto.
## Regras para a ficha não ficar "presa": só pega quem está PERTO e VENDO o
## herói, e quem segura a ficha por TOKEN_TIMEOUT sem conseguir atacar devolve.

enum AI { PATROL, CHASE, ATTACK, STAGGER }

const MAX_ATTACKERS := 2
## Segundos que um soldado pode segurar a ficha sem atacar.
const TOKEN_TIMEOUT := 2.5
static var _attack_tokens := 0

@export var attack: AttackData
@export var patrol_distance := 22.0
@export var attack_range := 24.0
@export var preferred_distance := 42.0
## Pausa aleatória entre ataques (segundos): min, max.
@export var attack_cooldown := Vector2(0.9, 1.7)
## Ângulo do cone protegido pelo escudo (a partir da frente).
@export var block_angle := 70.0
@export_range(0.0, 1.0) var blocked_damage_ratio := 0.15

@onready var shield: Sprite2D = $Visual/Shield
@onready var baton_pivot: Node2D = $Visual/BatonPivot

var ai := AI.PATROL
var _ai_time := 0.0
var _cooldown := 0.0
var _has_token := false
var _token_time := 0.0
var _patrol_dir := 1.0
var _patrol_pause := 0.0
var _strafe_dir := 1.0
var _strafe_timer := 0.0


func _ready() -> void:
	super._ready()
	_strafe_dir = 1.0 if randf() < 0.5 else -1.0


func _exit_tree() -> void:
	_release_token()


func is_guarding() -> bool:
	return not dead and (ai == AI.PATROL or ai == AI.CHASE)


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
		AI.PATROL:
			_ai_patrol(delta)
		AI.CHASE:
			_ai_chase(delta)
		AI.ATTACK:
			track_target_during_windup()
			velocity = _runner.step(delta, velocity)
		AI.STAGGER:
			velocity = velocity.move_toward(Vector2.ZERO, 500.0 * delta)
			if _ai_time >= stagger_time:
				_set_ai(AI.CHASE)
	move_and_slide()
	update_body_animation(delta)
	_update_gear(delta)


func _set_ai(new_ai: AI) -> void:
	ai = new_ai
	_ai_time = 0.0


# --- Patrulha: repetitiva de propósito ---------------------------------------------------

func _ai_patrol(delta: float) -> void:
	if _patrol_pause > 0.0:
		_patrol_pause -= delta
		velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	else:
		var goal := home_position + Vector2(patrol_distance * _patrol_dir, 0.0)
		var to_goal := goal - global_position
		if to_goal.length() < 3.0:
			_patrol_dir *= -1.0
			_patrol_pause = 0.8  # para, "olha", volta. Sempre igual.
		else:
			facing = to_goal.normalized()
			velocity = velocity.move_toward(facing * move_speed * 0.35, acceleration * delta)
	if target and global_position.distance_to(target.global_position) < aggro_range and can_see(target.global_position):
		_set_ai(AI.CHASE)
		Sfx.play(&"telegraph", -8.0, 0.2)


# --- Perseguição em grupo --------------------------------------------------------------------

func _ai_chase(delta: float) -> void:
	if target == null or global_position.distance_to(home_position) > leash_range:
		_release_token()
		_set_ai(AI.PATROL)
		return
	var to_target := target.global_position - global_position
	var distance := to_target.length()
	facing = to_target.normalized()
	# Ficha só para quem pode mesmo atacar logo: perto e com linha de visão.
	# (Antes, dois soldados presos atrás de um carro seguravam as 2 fichas para
	# sempre e o soldado colado no herói nunca atacava.)
	var in_reach := distance < preferred_distance + 16.0 and can_see(target.global_position)
	if _has_token:
		_token_time += delta
		if not in_reach or _token_time > TOKEN_TIMEOUT:
			_release_token()
			_cooldown = maxf(_cooldown, randf_range(0.3, 0.8))  # dá a vez aos outros
	var wants_to_attack := _cooldown <= 0.0 and in_reach and _acquire_token()
	var desired := Vector2.ZERO
	if wants_to_attack:
		if distance <= attack_range:
			_begin_attack()
			return
		desired = facing * move_speed
	else:
		# Sem ficha: cerca o herói mantendo distância, escudo erguido.
		_strafe_timer -= delta
		if _strafe_timer <= 0.0:
			_strafe_timer = randf_range(0.8, 1.8)
			_strafe_dir *= -1.0
		if distance > preferred_distance + 10.0:
			desired = facing * move_speed
		elif distance < preferred_distance - 10.0:
			desired = -facing * move_speed * 0.6
		else:
			desired = facing.orthogonal() * _strafe_dir * move_speed * 0.45
	velocity = velocity.move_toward(desired, acceleration * delta)


func _begin_attack() -> void:
	_set_ai(AI.ATTACK)
	start_attack(attack, facing)


func _on_attack_finished() -> void:
	_release_token()
	_cooldown = randf_range(attack_cooldown.x, attack_cooldown.y)
	if ai == AI.ATTACK:
		_set_ai(AI.CHASE)


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


# --- Escudo ------------------------------------------------------------------------------

func _incoming_damage_multiplier(info: HitInfo) -> float:
	if not is_guarding():
		return 1.0
	# O golpe vem de onde? info.direction aponta da fonte para mim.
	var from_dir := -info.direction
	var angle := rad_to_deg(absf(facing.angle_to(from_dir)))
	if angle <= block_angle:
		return blocked_damage_ratio
	return 1.0


func _on_damaged(_amount: float, _info: HitInfo, _blocked: bool) -> void:
	if ai == AI.PATROL:
		_set_ai(AI.CHASE)  # quem apanha acorda


func _on_poise_broken(_info: HitInfo) -> void:
	_release_token()
	_set_ai(AI.STAGGER)
	Sfx.play(&"clang", -2.0)
	shield.rotation = 0.6


func _on_died() -> void:
	_release_token()
	super._on_died()


## O oficial caiu: sem ordem, o soldado chamado pelo apito simplesmente
## desaba (sem memórias — ele não foi vencido, foi dispensado).
func dismiss() -> void:
	if dead:
		return
	dead = true
	_release_token()
	_runner.cancel()
	hitbox.deactivate()
	remove_from_group("enemies")
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	hurtbox.set_deferred("monitorable", false)
	Fx.float_text(global_position + Vector2(-4, -26), "...", Color(0.8, 0.8, 0.8), 7)
	_play_death()


# --- Visual do escudo e do bastão ---------------------------------------------------------

func _update_gear(delta: float) -> void:
	var side := -1.0 if body_sprite.flip_h else 1.0
	shield.flip_h = side < 0.0
	if is_guarding():
		shield.position = shield.position.lerp(Vector2(6.0 * side, -8.0), 14.0 * delta)
		shield.rotation = lerpf(shield.rotation, 0.0, 10.0 * delta)
		shield.z_index = 1
	else:
		shield.position = shield.position.lerp(Vector2(-4.0 * side, -7.0), 14.0 * delta)
		shield.z_index = -1
	var baton_angle := (PI * 0.5 - 0.6 * side) if side > 0.0 else (PI * 0.5 + 0.6)
	if ai == AI.ATTACK and _runner.is_running():
		var aim := hitbox_pivot.rotation
		match _runner.phase:
			AttackRunner.Phase.WINDUP:
				baton_angle = aim - 2.2 * side * _runner.phase_progress()
			AttackRunner.Phase.LUNGE, AttackRunner.Phase.ACTIVE:
				baton_angle = aim
			_:
				baton_angle = aim + 0.3 * side
		baton_pivot.rotation = baton_angle
	else:
		baton_pivot.rotation = lerp_angle(baton_pivot.rotation, baton_angle, 10.0 * delta)
	baton_pivot.position = Vector2(-3.0 * side, -8.0)
