class_name BocaDeRaiz
extends Enemy
## Boca de Raiz — Raízes da Fome.
## Bíblia: "Emboscada que sai do chão e agarra. As veias de Mabel caçando
## humanidade."
##
## Ciclo (legível, mas castiga quem anda distraído):
##   ENTERRADA: só um montinho de terra com uma fenda vermelha — dá para ver,
##     se você OLHAR. Não leva dano (está debaixo da terra).
##   SOBE: chegou perto → o monte incha e treme (aviso de 0,5 s). Dash agora!
##   AGARRA: se você ainda estiver em cima → preso (toque rápido no Ataque).
##     Cada segundo preso: memórias e um pouco de vida.
##   EXPOSTA: errou o bote, ou você escapou → fica de pé, tonta, mordendo quem
##     chega perto. É a hora de cortar.
##   AFUNDA: depois de um tempo volta para a terra e espera de novo.

enum AI { BURIED, RISING, HOLD, EXPOSED, SINKING, STAGGER }

@export var bite: AttackData
## Pisou neste raio: ela sobe.
@export var trigger_range := 26.0
## Ainda está neste raio quando ela termina de subir: agarrou.
@export var grab_range := 18.0
@export var rise_time := 0.5
@export var exposed_time := 3.0
## Escapar do agarrão deixa a boca tonta por mais tempo (recompensa).
@export var dazed_time := 3.2
@export var sink_time := 0.5
@export var rearm_time := 2.5
@export_group("Agarrão")
@export var grab_taps := 5
@export var grab_damage_per_second := 5.0
@export var grab_memory_ratio := 0.03
@export var grab_memory_min := 4

var ai := AI.BURIED
var _ai_time := 0.0
var _cooldown := 0.0
var _rearm := 0.0
var _exposed_for := 0.0


func _ready() -> void:
	super._ready()
	_bury()
	_rearm = 0.0  # recém-plantada já está pronta para o bote


## Enterrada, ela não existe para a mira assistida nem para os golpes.
func is_targetable() -> bool:
	return ai != AI.BURIED and ai != AI.SINKING and super.is_targetable()


func _set_ai(new_ai: AI) -> void:
	ai = new_ai
	_ai_time = 0.0


func _physics_process(delta: float) -> void:
	if dead:
		return
	_ai_time += delta
	_cooldown -= delta
	_rearm -= delta
	regen_poise(delta)
	target = find_target()
	velocity = Vector2.ZERO  # raiz não anda
	match ai:
		AI.BURIED:
			if _rearm <= 0.0 and target and global_position.distance_to(target.global_position) <= trigger_range:
				_rise()
		AI.RISING:
			visual.position.x = sin(_ai_time * 60.0) * 1.2  # o chão treme
			if _ai_time >= rise_time:
				visual.position.x = 0.0
				_snap()
		AI.HOLD:
			if target == null or not target.is_grabbed_by(self):
				# Escapou (ou morreu): a boca fica tonta, de pé — corte agora.
				_expose(dazed_time)
				Fx.float_text(global_position + Vector2(-8, -28), "tonta", Color(1.0, 0.8, 0.7), 7)
		AI.EXPOSED:
			if _runner.is_running():
				velocity = _runner.step(delta, velocity)
			elif target and _cooldown <= 0.0 and global_position.distance_to(target.global_position) <= bite.reach + bite.radius + 4.0:
				facing = (target.global_position - global_position).normalized()
				start_attack(bite, facing)
			elif _ai_time >= _exposed_for:
				_sink()
		AI.SINKING:
			if _ai_time >= sink_time:
				_bury()
		AI.STAGGER:
			if _ai_time >= stagger_time:
				_expose(exposed_time * 0.6)
	move_and_slide()
	_update_pose()


func _rise() -> void:
	_set_ai(AI.RISING)
	Sfx.play(&"root_burst", -6.0, 0.15)
	Fx.dust(global_position, 8)


## O bote: se o herói ainda está em cima, agarra; senão, fica exposta.
func _snap() -> void:
	hurtbox.invulnerable = false
	add_to_group("enemies")
	Sfx.play(&"chomp", -3.0, 0.1)
	Fx.shake(2.0, 0.12)
	if target and global_position.distance_to(target.global_position) <= grab_range:
		if target.grab(self, grab_taps, Vector2(0, -3), grab_damage_per_second, grab_memory_ratio, grab_memory_min):
			_set_ai(AI.HOLD)
			return
	_expose(exposed_time)


func _expose(seconds: float) -> void:
	_exposed_for = seconds
	_cooldown = 0.5
	_set_ai(AI.EXPOSED)


func _sink() -> void:
	_set_ai(AI.SINKING)
	hurtbox.invulnerable = true
	Fx.dust(global_position, 6)


func _bury() -> void:
	_set_ai(AI.BURIED)
	hurtbox.invulnerable = true
	remove_from_group("enemies")
	_rearm = rearm_time
	poise = max_poise


func _on_attack_finished() -> void:
	_cooldown = randf_range(0.7, 1.1)


## Levou golpe preso a alguém? Solta (a raiz se encolhe de dor).
func _on_damaged(_amount: float, _info: HitInfo, _blocked: bool) -> void:
	if ai == AI.HOLD and target and target.is_grabbed_by(self):
		target.release_grab()


func _on_poise_broken(_info: HitInfo) -> void:
	if ai == AI.HOLD and target and target.is_grabbed_by(self):
		target.release_grab()
	_set_ai(AI.STAGGER)


func _on_died() -> void:
	if target and target.is_grabbed_by(self):
		target.release_grab()
	super._on_died()


func _update_pose() -> void:
	var anim := &"oculta"
	match ai:
		AI.RISING:
			anim = &"inchando"
		AI.HOLD:
			anim = &"mastiga"
		AI.EXPOSED, AI.STAGGER:
			anim = &"aberta"
		AI.SINKING:
			anim = &"afunda"
	if body_sprite.animation != anim:
		body_sprite.play(anim)
	if target and absf(target.global_position.x - global_position.x) > 3.0:
		body_sprite.flip_h = target.global_position.x < global_position.x
	# Enterrada: a fenda "respira" devagar (a raiz pulsa como veia).
	if ai == AI.BURIED:
		body_sprite.modulate = Color(1, 1, 1).lerp(Color(1.25, 0.85, 0.85), 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.004 + home_position.x))
	else:
		body_sprite.modulate = Color.WHITE
