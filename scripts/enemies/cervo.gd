class_name CervoDeMusgo
extends Enemy
## Cervo de Musgo — Bosque do Sono Eterno.
## Bíblia: "Investida em linha reta. Animais parados no meio do salto."
##
## Ele começa CONGELADO no ar, no meio do salto (parece estátua). Chegou perto,
## ele termina o salto e cai no chão. Daí: mira (linha vermelha que TRAVA),
## dispara em linha reta e só para quando bate em algo. Bateu numa árvore ou
## num tronco caído? Fica tonto — é a sua janela. Dica de cenário: lute perto
## dos troncos.

enum AI { FROZEN, LAND, AIM, CHARGE, STUN, RECOVER, RETURN }

@export var charge_damage := 26.0
@export var charge_speed := 240.0
@export var charge_max_time := 1.1
@export var aim_time := 0.9
## A mira acompanha até esta fração do aviso; depois TRAVA.
@export_range(0.0, 1.0) var aim_lock_at := 0.65
@export var stun_time := 1.6
@export var recover_time := 0.7

@onready var telegraph: TelegraphDrawer = $Telegraph

var ai := AI.FROZEN
var _ai_time := 0.0
var _charge_dir := Vector2.RIGHT


func _ready() -> void:
	super._ready()
	body_sprite.play(&"salto")


## Congelado no ar parece estátua: a mira assistida ignora.
func is_targetable() -> bool:
	return ai != AI.FROZEN and super.is_targetable()


func is_aim_locked() -> bool:
	return ai == AI.AIM and _ai_time >= aim_time * aim_lock_at


func _physics_process(delta: float) -> void:
	if dead:
		velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)
		move_and_slide()
		telegraph.hide_all()
		return
	_ai_time += delta
	regen_poise(delta)
	target = find_target()
	match ai:
		AI.FROZEN:
			velocity = Vector2.ZERO
			if target and global_position.distance_to(target.global_position) <= aggro_range:
				_land()
		AI.LAND:
			velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)
			if _ai_time >= 0.45:
				_start_aim()
		AI.AIM:
			_aim(delta)
		AI.CHARGE:
			_charge(delta)
		AI.STUN:
			velocity = velocity.move_toward(Vector2.ZERO, 800.0 * delta)
			visual.rotation = sin(_ai_time * 14.0) * 0.12
			if _ai_time >= stun_time:
				visual.rotation = 0.0
				_after_charge()
		AI.RECOVER:
			velocity = velocity.move_toward(Vector2.ZERO, 800.0 * delta)
			if _ai_time >= recover_time:
				_after_charge()
		AI.RETURN:
			_return(delta)
	move_and_slide()
	if ai == AI.CHARGE:
		_check_collisions()
	_update_visual(delta)


func _set_ai(new_ai: AI) -> void:
	ai = new_ai
	_ai_time = 0.0


func _land() -> void:
	_set_ai(AI.LAND)
	visual.position.y = -8.0
	var tween := create_tween()
	tween.tween_property(visual, "position:y", 0.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(func(): Fx.dust(global_position, 8); Sfx.play(&"step_heavy", -6.0))


func _start_aim() -> void:
	if target == null:
		_set_ai(AI.RETURN)
		return
	_set_ai(AI.AIM)
	_charge_dir = (target.global_position - global_position).normalized()
	Fx.flash(body_sprite, 0.2, Color(1.0, 0.35, 0.3))
	Sfx.play(&"telegraph", -6.0)


func _aim(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)
	if target and not is_aim_locked():
		_charge_dir = (target.global_position - global_position).normalized()
	facing = _charge_dir
	if _ai_time >= aim_time:
		_set_ai(AI.CHARGE)
		hitbox_pivot.rotation = _charge_dir.angle()
		(hitbox_shape.shape as CircleShape2D).radius = 12.0
		hitbox_shape.position = Vector2(10.0, 0.0)
		hitbox.activate_raw(charge_damage, 50.0, 220.0, true, "Investida")
		set_collision_mask_value(2, false)  # atropela o herói e segue até bater em algo
		Sfx.play(&"hooves", -2.0)


func _charge(delta: float) -> void:
	velocity = _charge_dir * charge_speed
	if fmod(_ai_time, 0.07) < delta:
		Fx.dust(global_position, 2)
	if _ai_time >= charge_max_time:
		_end_charge(false)


## Bateu em parede, árvore ou tronco: tonto. (No herói, não para: atravessa.)
func _check_collisions() -> void:
	for i in get_slide_collision_count():
		var collider := get_slide_collision(i).get_collider()
		if collider is Player or collider is Enemy:
			continue
		if collider != null:
			_end_charge(true)
			return


func _end_charge(hit_something: bool) -> void:
	hitbox.deactivate()
	set_collision_mask_value(2, true)
	velocity = Vector2.ZERO
	if hit_something:
		_set_ai(AI.STUN)
		Fx.shake(3.0, 0.15)
		Fx.dust(global_position + _charge_dir * 8.0, 10)
		Sfx.play(&"hit_heavy", -4.0)
		Fx.float_text(global_position + Vector2(-6, -30), "@", Color(1.0, 0.95, 0.6), 8)
		poise = 0.0  # tonto: o primeiro golpe derruba
	else:
		_set_ai(AI.RECOVER)


func _after_charge() -> void:
	if target == null or global_position.distance_to(home_position) > leash_range:
		_set_ai(AI.RETURN)
	else:
		_start_aim()


func _return(delta: float) -> void:
	var to_home := home_position - global_position
	if to_home.length() > 4.0:
		facing = to_home.normalized()
		velocity = velocity.move_toward(facing * move_speed, acceleration * delta)
		if target and global_position.distance_to(target.global_position) <= aggro_range * 0.7:
			_start_aim()
	else:
		velocity = Vector2.ZERO
		_set_ai(AI.FROZEN)  # volta a ser estátua, no meio do salto


## Na investida ele não cambaleia (é uma tonelada de musgo vindo em linha reta).
func _can_be_staggered() -> bool:
	return ai != AI.CHARGE


func _on_damaged(_amount: float, _info: HitInfo, _blocked: bool) -> void:
	if ai == AI.FROZEN:
		_land()


func _on_poise_broken(_info: HitInfo) -> void:
	hitbox.deactivate()
	set_collision_mask_value(2, true)
	_set_ai(AI.STUN)
	_ai_time = stun_time * 0.4


func _update_visual(delta: float) -> void:
	telegraph.line_visible = ai == AI.AIM
	if ai == AI.AIM:
		telegraph.line_origin = global_position + Vector2(0, -4)
		telegraph.line_direction = _charge_dir
		telegraph.line_length = charge_speed * charge_max_time * 0.6
		telegraph.line_locked = is_aim_locked()
	if absf(facing.x) > 0.15:
		body_sprite.flip_h = facing.x < 0.0
	var anim := &"idle"
	match ai:
		AI.FROZEN:
			anim = &"salto"
		AI.CHARGE, AI.AIM:
			anim = &"investida"
		AI.RETURN:
			anim = &"walk"
	if body_sprite.animation != anim:
		body_sprite.play(anim)
	if ai == AI.AIM:
		visual.scale = Vector2(1.06, 0.92)  # agacha: vai disparar
	elif ai != AI.STUN:
		visual.scale = visual.scale.lerp(Vector2.ONE, 10.0 * delta)
