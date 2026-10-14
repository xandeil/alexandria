class_name Imitador
extends Enemy
## Imitador — Forjas Ocas.
## Bíblia: "Copia a aparência do equipamento do jogador. Prévia da fase 2 de Durgan."
##
## Um reflexo de bronze escuro com o SEU equipamento (a sua espada; o seu
## escudo, se você usa um). Ele não tem vontade própria: faz o que você faz,
## um instante depois.
##   • Você ataca perto dele → ele devolve o MESMO golpe (leve ou forte).
##   • Você dá dash → ele dá dash também (para o lado oposto).
##   • Você ergue o escudo → ele ergue o dele (segura golpes de frente).
##   • Você bebe um frasco → ele "bebe" também (se cura).
## Como vencer: ataque quando ELE estiver ocupado copiando outra coisa, ou
## simplesmente varie. Quem repete a mesma coisa luta contra si mesmo.

enum AI { IDLE, STALK, ATTACK, DASH, GUARD, DRINK, STAGGER }

## O mesmo combo e o golpe forte do herói (lidos da cena do Player).
@export var light_attack: AttackData
@export var heavy_attack: AttackData
## O reflexo bate mais fraco que o original.
@export_range(0.1, 2.0) var damage_ratio := 0.6
@export var copy_delay := 0.28
@export var copy_range := 70.0
@export var stalk_distance := 40.0
@export var dash_speed := 210.0
@export var dash_time := 0.24
@export var guard_time := 1.2
@export_range(0.0, 1.0) var drink_heal := 0.3
@export var drink_cooldown := 6.0

@onready var weapon_pivot: Node2D = $Visual/WeaponPivot
@onready var shield_sprite: Sprite2D = $Visual/Shield

var ai := AI.IDLE
## Ações do herói esperando para serem copiadas: [{"action": &"leve", "at": tempo}].
var pending: Array[Dictionary] = []
var _ai_time := 0.0
var _clock := 0.0
var _dash_dir := Vector2.ZERO
var _drink_ready := 0.0
var _bound_player: Player


func _physics_process(delta: float) -> void:
	if dead:
		velocity = velocity.move_toward(Vector2.ZERO, 400.0 * delta)
		move_and_slide()
		return
	_clock += delta
	_ai_time += delta
	_drink_ready -= delta
	regen_poise(delta)
	target = find_target()
	_listen()
	match ai:
		AI.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
			if target and global_position.distance_to(target.global_position) <= aggro_range and can_see(target.global_position):
				_set_ai(AI.STALK)
		AI.STALK:
			_stalk(delta)
			_copy_pending()
		AI.ATTACK:
			velocity = _runner.step(delta, velocity)
		AI.DASH:
			velocity = _dash_dir * dash_speed * (1.0 - _ai_time / dash_time * 0.6)
			if fmod(_ai_time, 0.05) < delta:
				Fx.afterimage(body_sprite, Color(0.85, 0.6, 0.35, 0.5))
			if _ai_time >= dash_time:
				hurtbox.invulnerable = false
				_set_ai(AI.STALK)
		AI.GUARD:
			_stalk(delta, 0.4)
			if _ai_time >= guard_time:
				_set_ai(AI.STALK)
		AI.DRINK:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
			if _ai_time >= 0.6 and _ai_time - delta < 0.6:
				stats.heal(stats.max_health * drink_heal)
				Sfx.play(&"heal", -6.0)
				Fx.splash(global_position + Vector2(0, -12), Color(0.85, 0.5, 0.3), 8)
			if _ai_time >= 0.9:
				_set_ai(AI.STALK)
		AI.STAGGER:
			velocity = velocity.move_toward(Vector2.ZERO, 400.0 * delta)
			if _ai_time >= stagger_time:
				_set_ai(AI.STALK)
	move_and_slide()
	update_body_animation(delta)
	_update_equipment(delta)


func _set_ai(new_ai: AI) -> void:
	ai = new_ai
	_ai_time = 0.0


## Liga-se ao herói (uma vez) para "ver" o que ele faz.
func _listen() -> void:
	if target == _bound_player:
		return
	_bound_player = target
	if target and not target.action_used.is_connected(_on_player_action):
		target.action_used.connect(_on_player_action)


func _on_player_action(action: StringName) -> void:
	if dead or ai == AI.IDLE:
		return
	if global_position.distance_to(target.global_position) > copy_range:
		return
	pending.append({"action": action, "at": _clock + copy_delay})


func _copy_pending() -> void:
	if pending.is_empty() or _clock < float(pending[0]["at"]):
		return
	var action: StringName = pending.pop_front()["action"]
	pending.clear()  # copia UMA coisa por vez (o resto se perde)
	copy_action(action)


## Faz o que o herói fez.
func copy_action(action: StringName) -> void:
	if target == null:
		return
	var toward := (target.global_position - global_position).normalized()
	match action:
		&"leve", &"forte":
			_set_ai(AI.ATTACK)
			start_attack(heavy_attack if action == &"forte" else light_attack, toward)
		&"dash":
			_dash_dir = toward.orthogonal() * (1.0 if randf() < 0.5 else -1.0)
			hurtbox.invulnerable = true  # esquiva de verdade (i-frames)
			Sfx.play(&"dash", -8.0)
			_set_ai(AI.DASH)
		&"escudo":
			if Game.shield_ready():
				Sfx.play(&"shield_up", -8.0)
				_set_ai(AI.GUARD)
		&"cura":
			if _drink_ready <= 0.0 and stats.health < stats.max_health:
				_drink_ready = drink_cooldown
				_set_ai(AI.DRINK)


func _stalk(delta: float, speed_scale: float = 1.0) -> void:
	if target == null:
		_set_ai(AI.IDLE)
		return
	var to_target := target.global_position - global_position
	facing = to_target.normalized()
	# Mantém a distância e anda de lado, como quem estuda o outro.
	var goal := facing.orthogonal() * sin(_clock * 0.9) * move_speed * 0.6
	if to_target.length() > stalk_distance + 8.0:
		goal += facing * move_speed
	elif to_target.length() < stalk_distance - 12.0:
		goal -= facing * move_speed * 0.7
	velocity = velocity.move_toward(goal * speed_scale, acceleration * delta)


func _activate_hitbox() -> void:
	hitbox.activate_with(_current_attack, _current_attack.damage * damage_ratio)


func _on_attack_finished() -> void:
	if ai == AI.ATTACK:
		_set_ai(AI.STALK)


## Escudo erguido (só se você também usa um): segura golpes de frente.
func _incoming_damage_multiplier(info: HitInfo) -> float:
	if ai != AI.GUARD:
		return 1.0
	var toward := info.source_position - global_position
	return 0.1 if absf(rad_to_deg(facing.angle_to(toward))) <= 70.0 else 1.0


func _on_damaged(_amount: float, _info: HitInfo, _blocked: bool) -> void:
	if ai == AI.IDLE:
		_set_ai(AI.STALK)


func _on_poise_broken(_info: HitInfo) -> void:
	pending.clear()
	_set_ai(AI.STAGGER)


## O equipamento é o SEU: espada sempre; escudo só se você usa um.
func _update_equipment(delta: float) -> void:
	shield_sprite.visible = Game.shield_ready()
	var side := -1.0 if body_sprite.flip_h else 1.0
	shield_sprite.flip_h = side < 0.0
	if ai == AI.GUARD:
		shield_sprite.position = shield_sprite.position.lerp(Vector2(0, -7) + facing * 6.0, 20.0 * delta)
		shield_sprite.z_index = 1
	else:
		shield_sprite.position = shield_sprite.position.lerp(Vector2(-6.0 * side, -6.0), 14.0 * delta)
		shield_sprite.z_index = -1
	var goal := 1.15 if side > 0.0 else PI - 1.15
	if ai == AI.ATTACK and _runner.is_running():
		goal = hitbox_pivot.rotation
	weapon_pivot.rotation = lerp_angle(weapon_pivot.rotation, goal, 18.0 * delta)
	weapon_pivot.position = Vector2(4.0 * side, -7.0)
	(weapon_pivot.get_child(0) as Sprite2D).flip_v = cos(weapon_pivot.rotation) < 0.0
