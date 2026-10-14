class_name MineradorOco
extends Enemy
## Minerador Oco — Forjas Ocas.
## Bíblia: "Picareta, ataque em sequência de três. Anões que trabalham sem
## lembrar por quê."
##
## Sempre TRÊS picaretadas: duas curtas e a terceira pesada (ele ergue a
## picareta bem alto). Depois fica um bom tempo recuperando o fôlego — a
## janela. Esquivar a primeira e fugir não basta: ele emenda as três.

enum AI { IDLE, CHASE, ATTACK, STAGGER, RETURN }

@export var combo: Array[AttackData] = []
@export var attack_range := 18.0
@export var rest_after_combo := Vector2(1.1, 1.6)

var ai := AI.IDLE
var _ai_time := 0.0
var _cooldown := 0.0
var _combo_index := 0


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
		AI.CHASE:
			if target == null or global_position.distance_to(home_position) > leash_range:
				_set_ai(AI.RETURN)
			else:
				var to_target := target.global_position - global_position
				facing = to_target.normalized()
				if to_target.length() <= attack_range and _cooldown <= 0.0:
					_combo_index = 0
					_next_swing()
				else:
					velocity = velocity.move_toward(facing * move_speed, acceleration * delta)
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
	_update_pose()


func _set_ai(new_ai: AI) -> void:
	ai = new_ai
	_ai_time = 0.0


func _next_swing() -> void:
	_set_ai(AI.ATTACK)
	var direction := (target.global_position - global_position).normalized() if target else facing
	start_attack(combo[_combo_index], direction)
	_combo_index += 1


func _on_attack_finished() -> void:
	if ai != AI.ATTACK:
		return
	if _combo_index < combo.size():
		_next_swing()
		return
	_cooldown = randf_range(rest_after_combo.x, rest_after_combo.y)
	_set_ai(AI.CHASE)


func _on_damaged(_amount: float, _info: HitInfo, _blocked: bool) -> void:
	if ai == AI.IDLE or ai == AI.RETURN:
		_set_ai(AI.CHASE)


func _on_poise_broken(_info: HitInfo) -> void:
	_combo_index = combo.size()
	_set_ai(AI.STAGGER)


func _update_pose() -> void:
	var swinging := ai == AI.ATTACK and _runner.is_running()
	var anim := &"idle"
	if swinging:
		var raised := _runner.phase == AttackRunner.Phase.WINDUP
		anim = (&"ergue_alto" if _combo_index == combo.size() else &"ergue") if raised else &"golpe"
	elif velocity.length() > 6.0:
		anim = &"walk"
	if body_sprite.animation != anim:
		body_sprite.play(anim)
