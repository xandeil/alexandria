class_name Inchado
extends Enemy
## Inchado — Raízes da Fome.
## Bíblia: "Anda devagar e explode ao morrer. Gente que absorveu humanidade demais."
##
## O perigo não é o tapa (lento, fácil de ler): é a MORTE dele. Ao morrer ele
## incha por um instante (círculo vermelho enchendo) e estoura — no herói e em
## quem mais estiver por perto. Mate-o e SAIA do círculo... ou mate-o no meio
## de um grupo de inimigos e deixe a explosão trabalhar por você.

enum AI { IDLE, CHASE, ATTACK, STAGGER, RETURN }

@export var slap: AttackData
@export var attack_range := 18.0
@export var attack_cooldown := Vector2(1.4, 2.2)
@export_group("Explosão")
@export var burst_radius := 34.0
@export var burst_delay := 0.85
@export var burst_damage := 30.0

var ai := AI.IDLE
var _ai_time := 0.0
var _cooldown := 0.0


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
				Sfx.play(&"moan", -10.0, 0.3)
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
		_set_ai(AI.ATTACK)
		start_attack(slap, facing)
		return
	velocity = velocity.move_toward(facing * move_speed, acceleration * delta)


func _on_attack_finished() -> void:
	_cooldown = randf_range(attack_cooldown.x, attack_cooldown.y)
	if ai == AI.ATTACK:
		_set_ai(AI.CHASE)


func _on_damaged(_amount: float, _info: HitInfo, _blocked: bool) -> void:
	if ai == AI.IDLE or ai == AI.RETURN:
		_set_ai(AI.CHASE)


func _on_poise_broken(_info: HitInfo) -> void:
	_set_ai(AI.STAGGER)


## Em vez de derreter em branco como os outros: incha... e estoura.
func _play_death() -> void:
	body_sprite.play(&"incha")
	FleshBurst.spawn(get_parent(), global_position, burst_radius, burst_delay, burst_damage, self, true)
	Sfx.play(&"slurp", -6.0, 0.1)
	var tween := create_tween()
	tween.tween_property(visual, "scale", Vector2(1.35, 1.25), burst_delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(visual, "modulate", Color(1.6, 0.8, 0.8), burst_delay)
	tween.tween_callback(queue_free)
