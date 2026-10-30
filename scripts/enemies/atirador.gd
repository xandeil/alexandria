class_name AtiradorDeTelhado
extends Enemy
## Atirador de Telhado — Cidade Estilhaçada.
## Bíblia: "Tiro lento e telegrafado de longe. Mantém posição há décadas."
##
## Ele NUNCA sai do lugar. Quando te vê:
##   1. MIRA: uma linha vermelha fina segue você...
##   2. ...e TRAVA (fica grossa e pisca): agora é a hora de sair da linha.
##   3. ATIRA: a bala é lenta (dá para ver chegando) e para em paredes,
##      barricadas e coberturas — andar de cobertura em cobertura é a resposta.
##   4. RECARREGA: a janela para chegar perto. Colado nele, só sobra a coronhada.

enum AI { WATCH, AIM, RELOAD, MELEE, STAGGER }

@export var melee: AttackData
@export var aim_time := 1.1
## Fração da mira em que a linha TRAVA (depois disso ele não corrige mais).
@export_range(0.1, 1.0) var lock_at := 0.7
@export var reload_time := 1.5
@export var shot_damage := 16.0
@export var shot_speed := 150.0
@export var shot_range := 320.0
@export var melee_range := 24.0

@onready var rifle_pivot: Node2D = $Visual/RiflePivot
@onready var telegraph: TelegraphDrawer = $Telegraph

var ai := AI.WATCH
var _ai_time := 0.0
var _aim_dir := Vector2.LEFT


func _ready() -> void:
	super._ready()
	_aim_dir = facing


func _physics_process(delta: float) -> void:
	if dead:
		telegraph.hide_all()
		velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)
		move_and_slide()
		return
	_ai_time += delta
	regen_poise(delta)
	target = find_target()
	match ai:
		AI.WATCH:
			_watch(delta)
		AI.AIM:
			_aim(delta)
		AI.RELOAD:
			_hold_position(delta)
			if _ai_time >= reload_time:
				_set_ai(AI.WATCH)
		AI.MELEE:
			track_target_during_windup()
			velocity = _runner.step(delta, velocity)
		AI.STAGGER:
			velocity = velocity.move_toward(Vector2.ZERO, 500.0 * delta)
			if _ai_time >= stagger_time:
				_set_ai(AI.WATCH)
	move_and_slide()
	update_body_animation(delta)
	_update_rifle(delta)
	_update_telegraph()


func _set_ai(new_ai: AI) -> void:
	ai = new_ai
	_ai_time = 0.0


## "Mantém posição": se foi empurrado, volta ao posto devagar.
func _hold_position(delta: float) -> void:
	var to_home := home_position - global_position
	if to_home.length() > 2.0:
		velocity = velocity.move_toward(to_home.normalized() * move_speed * 0.5, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)


func _watch(delta: float) -> void:
	_hold_position(delta)
	if target == null:
		return
	var distance := global_position.distance_to(target.global_position)
	if distance <= melee_range:
		facing = (target.global_position - global_position).normalized()
		_set_ai(AI.MELEE)
		start_attack(melee, facing)
	elif distance <= aggro_range and can_see(target.global_position):
		_set_ai(AI.AIM)
		_aim_dir = (target.global_position - global_position).normalized()
		Sfx.play(&"telegraph", -8.0)


func is_locked() -> bool:
	return ai == AI.AIM and _ai_time >= aim_time * lock_at


func _aim(delta: float) -> void:
	_hold_position(delta)
	if target == null:
		_set_ai(AI.WATCH)
		return
	if global_position.distance_to(target.global_position) <= melee_range:
		facing = (target.global_position - global_position).normalized()
		_set_ai(AI.MELEE)
		start_attack(melee, facing)
		return
	if not is_locked():
		_aim_dir = (target.global_position - global_position).normalized()
	facing = _aim_dir
	if _ai_time >= aim_time:
		_fire()


func _fire() -> void:
	var muzzle := global_position + _aim_dir * 14.0
	var shot := Projectile.launch(get_parent(), muzzle, _aim_dir, self, shot_damage, shot_speed, shot_range)
	shot.friendly_fire = true  # acerta quem estiver no caminho (inimigo também)
	Sfx.play(&"shot", -2.0)
	Fx.sparks(muzzle + Vector2(0, -8), _aim_dir, Color(1.0, 0.8, 0.45), 5, 90.0)
	velocity = -_aim_dir * 40.0  # coice
	_set_ai(AI.RELOAD)


func _on_attack_finished() -> void:
	if ai == AI.MELEE:
		_set_ai(AI.RELOAD)
		_ai_time = reload_time * 0.6  # depois da coronhada ele volta a mirar mais cedo


func _on_damaged(_amount: float, _info: HitInfo, _blocked: bool) -> void:
	# Levar golpe atrapalha a mira: recomeça do zero.
	if ai == AI.AIM:
		_set_ai(AI.WATCH)


func _on_poise_broken(_info: HitInfo) -> void:
	_set_ai(AI.STAGGER)


func _update_rifle(delta: float) -> void:
	var side := -1.0 if body_sprite.flip_h else 1.0
	rifle_pivot.position = Vector2(2.0 * side, -9.0)
	var goal := _aim_dir.angle() if ai == AI.AIM else ((PI * 0.5 - 0.9) if side > 0.0 else (PI * 0.5 + 0.9))
	if ai == AI.MELEE and _runner.is_running():
		goal = hitbox_pivot.rotation + (-1.2 * side if _runner.phase == AttackRunner.Phase.WINDUP else 0.0)
	rifle_pivot.rotation = lerp_angle(rifle_pivot.rotation, goal, 14.0 * delta)
	(rifle_pivot.get_child(0) as Sprite2D).flip_v = cos(rifle_pivot.rotation) < 0.0


func _update_telegraph() -> void:
	telegraph.line_visible = ai == AI.AIM
	if ai == AI.AIM:
		telegraph.line_origin = global_position + Vector2(0, -4)
		telegraph.line_direction = _aim_dir
		telegraph.line_length = minf(shot_range, global_position.distance_to(target.global_position) + 30.0) if target else shot_range
		telegraph.line_locked = is_locked()
