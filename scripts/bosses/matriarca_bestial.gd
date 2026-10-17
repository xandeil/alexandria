class_name MatriarcaBestial
extends MiniBoss
## A Matriarca Bestial — 2º mini-chefe da Montanha Carbonizada.
## Bíblia: "o maior Dragão Bestial; a arena dela tem chão que cede, como a de Rachel."
##
## Uma fera enorme. Como lutar:
##   • INVESTIDA: abaixa a cabeça (linha que trava) e dispara. Bateu na parede:
##     tonta (janela grande).
##   • PISOTEIO: ergue-se e cai (círculo). O chão em volta RACHA e, um
##     instante depois, cede — buracos que só o dash atravessa.
##   • MORDIDA de perto.
## Ensina o que Rachel vai cobrar: o chão desta montanha não é confiável.

enum Mode { DECIDE, AIM, CHARGE, STOMP, BITE, DAZED }

const SPEECH_WAKE := "(Um rugido que faz o chão inteiro tremer.)"

@export var charge: AttackData
@export var bite: AttackData
@export var aim_time := 0.9
@export var stomp_windup := 1.0
@export var stomp_radius := 34.0
@export var stomp_damage := 30.0
@export var pits_per_stomp := 2
@export var max_pits := 6
@export var dazed_time := 2.2

@onready var telegraph: TelegraphDrawer = $Telegraph

var mode := Mode.DECIDE
var pits: Array[ArenaPit] = []
var _mode_time := 0.0
var _aim := Vector2.RIGHT
var _actions := 0


func _on_wake() -> void:
	speech.emit(SPEECH_WAKE)
	Sfx.play(&"roar", 0.0)
	Fx.shake(4.0, 0.5)
	_set_mode(Mode.DECIDE)
	_mode_time = -0.8


func _on_reset() -> void:
	telegraph.clear()
	set_collision_mask_value(2, true)
	_set_mode(Mode.DECIDE)


func _set_mode(new_mode: Mode) -> void:
	mode = new_mode
	_mode_time = 0.0


func _fight(delta: float) -> void:
	_mode_time += delta
	match mode:
		Mode.DECIDE:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
			if _mode_time < 0.0:
				return
			var to_target := target.global_position - global_position
			var distance := to_target.length()
			facing = to_target.normalized()
			_actions += 1
			if distance < 30.0:
				_set_mode(Mode.BITE)
				start_attack(bite, facing)
			elif _actions % 3 == 0 or distance < 60.0:
				_set_mode(Mode.STOMP)
				Sfx.play(&"telegraph", -3.0)
			else:
				_aim = facing
				_set_mode(Mode.AIM)
				Sfx.play(&"telegraph", -5.0)
		Mode.AIM:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
			if _mode_time < aim_time * 0.7:
				_aim = (target.global_position - global_position).normalized()
				facing = _aim
			if _mode_time >= aim_time:
				_set_mode(Mode.CHARGE)
				set_collision_mask_value(2, false)
				start_attack(charge, _aim)
				Sfx.play(&"hooves", -2.0)
		Mode.CHARGE:
			velocity = _runner.step(delta, velocity)
		Mode.BITE:
			velocity = _runner.step(delta, velocity)
		Mode.STOMP:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
			if _mode_time >= stomp_windup and _mode_time - delta < stomp_windup:
				stomp()
			if _mode_time >= stomp_windup + 0.7:
				_set_mode(Mode.DECIDE)
				_mode_time = -0.5
		Mode.DAZED:
			velocity = velocity.move_toward(Vector2.ZERO, 500.0 * delta)
			if _mode_time >= dazed_time:
				_set_mode(Mode.DECIDE)


## Pisoteio: dano em volta e o chão cede perto do herói.
func stomp() -> void:
	Sfx.play(&"slam", 0.0)
	Fx.shake(5.0, 0.35)
	Fx.dust(global_position, 16)
	if target and target.global_position.distance_to(global_position) <= stomp_radius:
		var info := HitInfo.create(stomp_damage, global_position, target.global_position)
		info.knockback = 230.0
		info.poise_damage = 40.0
		info.is_heavy = true
		info.attack_name = "Pisoteio"
		info.source = self
		target.hurtbox.receive_hit(info)
	for i in pits_per_stomp:
		var at := global_position + Vector2.from_angle(randf() * TAU) * randf_range(46.0, 80.0)
		if target and i == 0:
			at = target.global_position + Vector2.from_angle(randf() * TAU) * randf_range(10.0, 28.0)
		_open_pit(clamp_to_arena(at, 20.0) if arena_rect.size != Vector2.ZERO else at)


func _open_pit(at: Vector2) -> void:
	var pit := ArenaPit.create(at, Vector2(19, 12), 0.9)
	get_parent().add_child(pit)
	pits.append(pit)
	while pits.size() > max_pits:
		var old: ArenaPit = pits.pop_front()
		if is_instance_valid(old):
			old.close()


func _crash() -> void:
	_runner.cancel()
	hitbox.deactivate()
	set_collision_mask_value(2, true)
	velocity = -_aim * 80.0
	Sfx.play(&"slam", 0.0)
	Fx.shake(5.0, 0.3)
	Fx.float_text(global_position + Vector2(-8, -40), "tonta", Color(1.0, 0.85, 0.6), 7)
	_set_mode(Mode.DAZED)


func _on_attack_finished() -> void:
	set_collision_mask_value(2, true)
	if mode == Mode.CHARGE or mode == Mode.BITE:
		_set_mode(Mode.DECIDE)
		_mode_time = -0.6


func _can_be_staggered() -> bool:
	return mode == Mode.DAZED or mode == Mode.DECIDE


func _on_poise_broken(_info: HitInfo) -> void:
	_set_mode(Mode.DAZED)
	_mode_time = dazed_time * 0.4


func _on_died() -> void:
	telegraph.clear()
	set_collision_mask_value(2, true)
	for pit in pits:
		if is_instance_valid(pit):
			pit.close()
	pits.clear()
	_defeat()


func _after_move(_delta: float) -> void:
	# A batida é checada DEPOIS de mover (pode cair no quadro em que a corrida acaba).
	var running := _runner.phase == AttackRunner.Phase.LUNGE or _runner.phase == AttackRunner.Phase.ACTIVE
	if mode == Mode.CHARGE and running and get_slide_collision_count() > 0:
		_crash()
	if absf(facing.x) > 0.05:
		body_sprite.flip_h = facing.x < 0.0
	var anim := &"walk" if velocity.length() > 6.0 else &"idle"
	match mode:
		Mode.STOMP:
			anim = &"ergue" if _mode_time < stomp_windup else &"idle"
		Mode.AIM, Mode.CHARGE:
			anim = &"investida"
		Mode.BITE:
			anim = &"morde"
	if body_sprite.animation != anim:
		body_sprite.play(anim)
	telegraph.line_visible = mode == Mode.AIM
	telegraph.circle_visible = mode == Mode.STOMP and _mode_time < stomp_windup
	if mode == Mode.AIM:
		telegraph.line_origin = global_position
		telegraph.line_direction = _aim
		telegraph.line_length = charge.lunge_speed * charge.lunge_time + charge.reach
		telegraph.line_locked = _mode_time >= aim_time * 0.7
	if telegraph.circle_visible:
		telegraph.circle_center = global_position
		telegraph.circle_radius = stomp_radius
		telegraph.circle_progress = _mode_time / stomp_windup
