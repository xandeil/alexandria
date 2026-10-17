class_name DragaoAlado
extends Enemy
## Dragão Alado Menor — Montanha Carbonizada.
## Bíblia: "Mergulha do céu e solta fogo. Filhotes do ninho."
##
## No ar ele é intocável: só a SOMBRA no chão mostra onde está. Escolhe um
## ponto perto de você (círculo vermelho enchendo) e MERGULHA. Depois do
## mergulho fica no chão um instante, cospe um pouco de fogo à frente e só
## então levanta voo — essa é a janela para cortá-lo.

enum AI { IDLE, CIRCLE, DIVE, GROUND, TAKEOFF }

@export var flight_height := 34.0
@export var circle_radius := 60.0
@export var circle_time := Vector2(2.2, 3.4)
@export var dive_warning := 0.8
@export var dive_radius := 18.0
@export var dive_damage := 20.0
@export var ground_time := 1.6
@export var fire_patches := 3
@export var fire_dps := 10.0

@onready var telegraph: TelegraphDrawer = $Telegraph

var ai := AI.IDLE
var _ai_time := 0.0
var _height := 34.0
var _circle_for := 2.5
var _angle := 0.0
var _dive_at := Vector2.ZERO
var _dive_from := Vector2.ZERO
var _flap := 0.0


func _ready() -> void:
	super._ready()
	_height = flight_height
	_angle = randf() * TAU


func is_targetable() -> bool:
	return ai == AI.GROUND and super.is_targetable()


func _physics_process(delta: float) -> void:
	if dead:
		telegraph.hide_all()
		_height = move_toward(_height, 0.0, 80.0 * delta)
		visual.position.y = -_height
		return
	_ai_time += delta
	regen_poise(delta)
	target = find_target()
	hurtbox.invulnerable = ai != AI.GROUND
	match ai:
		AI.IDLE:
			velocity = Vector2.ZERO
			if target and global_position.distance_to(target.global_position) <= aggro_range:
				_set_ai(AI.CIRCLE)
				_circle_for = randf_range(circle_time.x, circle_time.y)
		AI.CIRCLE:
			if target == null:
				_set_ai(AI.IDLE)
			else:
				_angle += delta * 1.4
				var goal := target.global_position + Vector2(cos(_angle), sin(_angle) * 0.6) * circle_radius
				velocity = (goal - global_position) * 2.0
				if _ai_time >= _circle_for:
					_start_dive()
		AI.DIVE:
			var t := clampf((_ai_time - dive_warning * 0.6) / (dive_warning * 0.4), 0.0, 1.0)
			velocity = Vector2.ZERO
			global_position = _dive_from.lerp(_dive_at, t)
			_height = flight_height * (1.0 - t)
			if _ai_time >= dive_warning:
				_land()
		AI.GROUND:
			velocity = velocity.move_toward(Vector2.ZERO, 400.0 * delta)
			if _ai_time >= ground_time * 0.35 and _ai_time - delta < ground_time * 0.35:
				_breathe()
			if _ai_time >= ground_time:
				_set_ai(AI.TAKEOFF)
				Sfx.play(&"wing", -6.0)
		AI.TAKEOFF:
			velocity = Vector2.ZERO
			_height = move_toward(_height, flight_height, 70.0 * delta)
			if _height >= flight_height:
				_set_ai(AI.CIRCLE)
				_circle_for = randf_range(circle_time.x, circle_time.y)
	move_and_slide()
	_update_visual(delta)


func _set_ai(new_ai: AI) -> void:
	ai = new_ai
	_ai_time = 0.0


func _start_dive() -> void:
	_dive_at = target.global_position + Vector2.from_angle(randf() * TAU) * randf_range(0.0, 14.0)
	_dive_from = global_position
	_set_ai(AI.DIVE)
	Sfx.play(&"telegraph", -8.0)


func _land() -> void:
	_height = 0.0
	Sfx.play(&"slam", -8.0)
	Fx.dust(global_position, 8)
	if target and target.global_position.distance_to(global_position) <= dive_radius:
		var info := HitInfo.create(dive_damage, global_position + Vector2(0, -4), target.global_position)
		info.knockback = 160.0
		info.poise_damage = 20.0
		info.attack_name = "Mergulho"
		info.source = self
		target.hurtbox.receive_hit(info)
	facing = (target.global_position - global_position).normalized() if target else facing
	_set_ai(AI.GROUND)


## Um jato curto de fogo à frente: chamas no chão em linha.
func _breathe() -> void:
	Sfx.play(&"fire_breath", -8.0, 0.1)
	for i in fire_patches:
		FirePatch.spawn(get_parent(), global_position + facing * (14.0 + i * 13.0), 10.0, 2.0, fire_dps, self)


func _on_poise_broken(_info: HitInfo) -> void:
	_ai_time = 0.0  # no chão e cambaleando: fica mais um pouco


func _update_visual(delta: float) -> void:
	_flap += delta * (10.0 if ai != AI.GROUND else 2.0)
	visual.position.y = -_height + (sin(_flap) * 2.0 if _height > 2.0 else 0.0)
	var anim := &"voa"
	if ai == AI.GROUND:
		anim = &"chao"
	elif ai == AI.DIVE and _ai_time > dive_warning * 0.6:
		anim = &"mergulho"
	if body_sprite.animation != anim:
		body_sprite.play(anim)
	if absf(facing.x) > 0.1:
		body_sprite.flip_h = facing.x < 0.0
	if absf(velocity.x) > 5.0:
		body_sprite.flip_h = velocity.x < 0.0
	telegraph.circle_visible = ai == AI.DIVE
	if ai == AI.DIVE:
		telegraph.circle_center = _dive_at
		telegraph.circle_radius = dive_radius
		telegraph.circle_progress = _ai_time / dive_warning
