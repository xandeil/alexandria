class_name EstatuaViva
extends Enemy
## Estátua Viva — Domínio Congelado.
## Bíblia: "Só se move quando o jogador está de costas. Pessoas 'importantes'
## que Cassian guardou."
##
## Enquanto você OLHA para ela (ela está à sua frente, num cone largo), é pedra:
## não se mexe e quase não sente golpes. Vire as costas — para fugir, para
## lutar com outro — e ela anda depressa até você e golpeia.
## A regra ensina a posicionar o grupo: deixe a estátua sempre na sua frente.

enum AI { IDLE, STONE, STALK, STRIKE }

@export var strike: AttackData
## Meio-ângulo do "olhar" do herói (graus). Dentro dele, a estátua congela.
@export var gaze_half_angle := 70.0
@export var gaze_range := 240.0
@export var strike_range := 20.0
@export_range(0.0, 1.0) var stone_damage_ratio := 0.15

var ai := AI.IDLE
var _ai_time := 0.0


func _physics_process(delta: float) -> void:
	if dead:
		velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)
		move_and_slide()
		return
	_ai_time += delta
	regen_poise(delta)
	target = find_target()
	match ai:
		AI.IDLE:
			velocity = Vector2.ZERO
			if target and global_position.distance_to(target.global_position) <= aggro_range:
				_set_ai(AI.STONE if is_watched() else AI.STALK)
		AI.STONE:
			velocity = Vector2.ZERO
			if target == null:
				_set_ai(AI.IDLE)
			elif not is_watched():
				_set_ai(AI.STALK)
				Sfx.play(&"crystal", -12.0, 0.3)
		AI.STALK:
			if target == null:
				_set_ai(AI.IDLE)
			elif is_watched():
				_set_ai(AI.STONE)  # pego no flagra: congela no meio do passo
				velocity = Vector2.ZERO
			else:
				var to_target := target.global_position - global_position
				facing = to_target.normalized()
				if to_target.length() <= strike_range:
					_set_ai(AI.STRIKE)
					start_attack(strike, facing)
				else:
					velocity = velocity.move_toward(facing * move_speed, acceleration * delta)
		AI.STRIKE:
			# O golpe, uma vez começado, vai até o fim (mesmo se você virar).
			track_target_during_windup()
			velocity = _runner.step(delta, velocity)
	move_and_slide()
	_update_look(delta)


func _set_ai(new_ai: AI) -> void:
	ai = new_ai
	_ai_time = 0.0


## O herói está olhando para ela? (ela está no cone à frente dele)
func is_watched() -> bool:
	if target == null or target.is_dead():
		return false
	var to_me := global_position - target.global_position
	if to_me.length() > gaze_range:
		return false
	return absf(rad_to_deg(target.facing.angle_to(to_me))) <= gaze_half_angle


func is_stone() -> bool:
	return ai == AI.STONE or ai == AI.IDLE


## Pedra: o golpe quase não entra. Andando (de costas para você), é carne.
func _incoming_damage_multiplier(_info: HitInfo) -> float:
	return stone_damage_ratio if is_stone() else 1.0


func _can_be_staggered() -> bool:
	return not is_stone()


func _on_attack_finished() -> void:
	if ai == AI.STRIKE:
		_set_ai(AI.STONE if is_watched() else AI.STALK)


func _update_look(delta: float) -> void:
	if is_stone():
		body_sprite.pause()  # estátua de verdade: nem o quadro anda
		body_sprite.modulate = Color(0.86, 0.92, 1.0)
		return
	body_sprite.modulate = Color.WHITE
	if not body_sprite.is_playing():
		body_sprite.play()
	if ai == AI.STRIKE:
		if absf(facing.x) > 0.15:
			body_sprite.flip_h = facing.x < 0.0
		if body_sprite.animation != &"golpe":
			body_sprite.play(&"golpe")
		return
	update_body_animation(delta)
