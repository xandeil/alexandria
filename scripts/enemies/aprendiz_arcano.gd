class_name AprendizArcano
extends Enemy
## Aprendiz Arcano — Domínio Congelado.
## Bíblia: "Escudo mágico, curto alcance. Alunos que nunca se formaram."
##
## Uma bolha de gelo o protege de TUDO até se partir. O golpe forte parte a
## bolha de uma vez; cortes leves a desgastam aos poucos. Sem a bolha, ele
## fica atordoado um instante (a janela) e a bolha volta depois de um tempo.
## De perto, conjura um anel de gelo em volta de si (círculo de aviso): quem
## fica dentro leva dano e fica lento.

enum AI { IDLE, APPROACH, CAST, DAZED, STAGGER }

@export var shield_max := 36.0
@export var shield_regrow := 6.0
@export var dazed_time := 1.6
@export var cast_range := 30.0
@export var nova_radius := 32.0
@export var nova_windup := 0.85
@export var nova_damage := 18.0
@export var nova_chill := 2.0
@export var cooldown := 1.4

@onready var telegraph: TelegraphDrawer = $Telegraph

var ai := AI.IDLE
var shield := 36.0
var _ai_time := 0.0
var _cooldown := 0.0
var _regrow_in := 0.0


func _ready() -> void:
	super._ready()
	shield = shield_max


func _physics_process(delta: float) -> void:
	if dead:
		telegraph.hide_all()
		velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)
		move_and_slide()
		queue_redraw()
		return
	_ai_time += delta
	_cooldown -= delta
	regen_poise(delta)
	if shield <= 0.0:
		_regrow_in -= delta
		if _regrow_in <= 0.0 and ai != AI.DAZED:
			shield = shield_max
			Sfx.play(&"crystal", -8.0)
	target = find_target()
	match ai:
		AI.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
			if target and global_position.distance_to(target.global_position) <= aggro_range and can_see(target.global_position):
				_set_ai(AI.APPROACH)
		AI.APPROACH:
			if target == null or global_position.distance_to(home_position) > leash_range:
				_set_ai(AI.IDLE)
			else:
				var to_target := target.global_position - global_position
				facing = to_target.normalized()
				if to_target.length() <= cast_range and _cooldown <= 0.0:
					_set_ai(AI.CAST)
					Sfx.play(&"telegraph", -8.0)
				else:
					velocity = velocity.move_toward(facing * move_speed, acceleration * delta)
		AI.CAST:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
			if _ai_time >= nova_windup:
				_nova()
				_cooldown = cooldown
				_set_ai(AI.APPROACH)
		AI.DAZED, AI.STAGGER:
			velocity = velocity.move_toward(Vector2.ZERO, 500.0 * delta)
			if _ai_time >= (dazed_time if ai == AI.DAZED else stagger_time):
				_set_ai(AI.APPROACH)
	move_and_slide()
	update_body_animation(delta)
	_update_telegraph()
	queue_redraw()


func _set_ai(new_ai: AI) -> void:
	ai = new_ai
	_ai_time = 0.0


func has_shield() -> bool:
	return shield > 0.0


## A bolha segura tudo; o golpe forte parte de uma vez.
## (Fica no `_on_hit_received`, e não num "multiplicador de dano": um método
## que devolve um número não deve mudar o estado — quem lê não espera isso.)
func _on_hit_received(info: HitInfo) -> void:
	if dead:
		return
	if not has_shield():
		super._on_hit_received(info)
		return
	shield -= shield_max if info.is_heavy else info.damage
	if shield <= 0.0:
		_break_shield()
	else:
		Sfx.play(&"block")
		Fx.sparks(global_position + Vector2(0, -9) - info.direction * 10.0, -info.direction, Color(0.8, 0.94, 1.0), 8)


func _break_shield() -> void:
	shield = 0.0
	_regrow_in = shield_regrow
	Sfx.play(&"shatter", -2.0)
	Fx.sparks(global_position + Vector2(0, -10), Vector2.UP, Color(0.75, 0.9, 1.0), 16, 130.0)
	_set_ai(AI.DAZED)  # sem a bolha: atordoado (a janela)


func _can_be_staggered() -> bool:
	return not has_shield()


func _on_poise_broken(_info: HitInfo) -> void:
	_set_ai(AI.STAGGER)


func _nova() -> void:
	Sfx.play(&"freeze", -4.0, 0.1)
	Fx.sparks(global_position + Vector2(0, -4), Vector2.UP, Color(0.8, 0.94, 1.0), 12, 90.0)
	if target and target.global_position.distance_to(global_position) <= nova_radius:
		var info := HitInfo.create(nova_damage, global_position, target.global_position)
		info.knockback = 120.0
		info.poise_damage = 18.0
		info.attack_name = "Anel de gelo"
		info.source = self
		if target.hurtbox.receive_hit(info):
			target.apply_chill(nova_chill)


func _update_telegraph() -> void:
	telegraph.circle_visible = ai == AI.CAST
	if ai == AI.CAST:
		telegraph.circle_center = global_position
		telegraph.circle_radius = nova_radius
		telegraph.circle_progress = _ai_time / nova_windup


## A bolha (desenhada: um círculo azul que pisca quando está para quebrar).
func _draw() -> void:
	if dead or not has_shield():
		return
	var weak := shield / shield_max
	var alpha := 0.35 + 0.25 * weak
	draw_circle(Vector2(0, -9), 13.0, Color(0.6, 0.85, 1.0, alpha * 0.4))
	draw_arc(Vector2(0, -9), 13.0, 0.0, TAU, 28, Color(0.85, 0.96, 1.0, alpha + 0.2), 1.5)
