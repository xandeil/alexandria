class_name AcaroCristal
extends Enemy
## Ácaro de Cristal — Domínio Congelado.
## Bíblia: "Enxame que gruda e rouba estamina. Prévia do roubo de estamina de
## Cassian."
##
## Corre em volta, PULA e gruda no herói. Grudado, bebe estamina a cada segundo
## (sem tirar vida). O DASH sacode todos de uma vez (eles caem tontos) — e o
## jogador aprende a guardar estamina para o dash antes de chegar no Cassian.

enum AI { IDLE, CHASE, LEAP, CLING, FALLEN }

@export var leap_range := 30.0
@export var leap_time := 0.3
@export var drain_per_second := 14.0
@export var cling_max := 5.0
@export var fallen_time := 1.2

var ai := AI.IDLE
var _ai_time := 0.0
var _leap_from := Vector2.ZERO
var _leap_to := Vector2.ZERO
var _cling_offset := Vector2.ZERO
var _bound_to: Player
var _layer := 0
var _mask := 0


func _ready() -> void:
	super._ready()
	_layer = collision_layer
	_mask = collision_mask


func _physics_process(delta: float) -> void:
	if dead:
		return
	_ai_time += delta
	target = find_target()
	match ai:
		AI.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
			if target and global_position.distance_to(target.global_position) <= aggro_range:
				_set_ai(AI.CHASE)
		AI.CHASE:
			if target == null:
				_set_ai(AI.IDLE)
			else:
				var to_target := target.global_position - global_position
				facing = to_target.normalized()
				var zig := facing.orthogonal() * sin(_ai_time * 9.0) * 0.5
				velocity = velocity.move_toward((facing + zig).normalized() * move_speed, acceleration * delta)
				if to_target.length() <= leap_range:
					_leap()
		AI.LEAP:
			var t := clampf(_ai_time / leap_time, 0.0, 1.0)
			velocity = Vector2.ZERO
			global_position = _leap_from.lerp(_leap_to, t)
			visual.position.y = -sin(t * PI) * 10.0
			if t >= 1.0:
				visual.position.y = 0.0
				_try_cling()
		AI.CLING:
			_cling(delta)
			return
		AI.FALLEN:
			velocity = velocity.move_toward(Vector2.ZERO, 500.0 * delta)
			if _ai_time >= fallen_time:
				_set_ai(AI.CHASE)
	move_and_slide()
	update_body_animation(delta)


func _set_ai(new_ai: AI) -> void:
	ai = new_ai
	_ai_time = 0.0


func _leap() -> void:
	_leap_from = global_position
	_leap_to = target.global_position + Vector2.from_angle(randf() * TAU) * 4.0
	_set_ai(AI.LEAP)
	Sfx.play(&"crystal", -12.0, 0.3)


func _try_cling() -> void:
	if target == null or target.is_dead() or target.global_position.distance_to(global_position) > 12.0 \
			or target.hurtbox.invulnerable:
		_set_ai(AI.FALLEN)  # errou o pulo (ou o dash passou): cai no chão
		return
	_cling_offset = Vector2(randf_range(-6.0, 6.0), randf_range(-12.0, -4.0))
	collision_layer = 0  # grudado: não empurra nem é empurrado
	collision_mask = 0
	_set_ai(AI.CLING)
	if _bound_to != target:
		_bound_to = target
		target.action_used.connect(_on_player_action)


func is_clinging() -> bool:
	return ai == AI.CLING


func _cling(delta: float) -> void:
	if target == null or target.is_dead():
		shake_off()
		return
	global_position = target.global_position + Vector2(_cling_offset.x, 1.0)
	visual.position.y = _cling_offset.y
	target.stats.drain_stamina(drain_per_second * delta)
	if _ai_time >= cling_max:
		shake_off()


## Sacudido (dash do herói, ou cansou de grudar): cai tonto perto dele.
func shake_off() -> void:
	if ai != AI.CLING:
		return
	collision_layer = _layer
	collision_mask = _mask
	visual.position.y = 0.0
	velocity = Vector2.from_angle(randf() * TAU) * 120.0
	_set_ai(AI.FALLEN)


func _on_player_action(action: StringName) -> void:
	if action == &"dash" and ai == AI.CLING:
		shake_off()


func _on_damaged(_amount: float, _info: HitInfo, _blocked: bool) -> void:
	shake_off()
