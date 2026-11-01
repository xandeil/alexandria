class_name Sebastioes
extends MiniBoss
## Os Sebastiões — o mini-chefe em DUPLA da briga da ponte (v0.43, Etapa 7).
## Quem entra no meio da briga do Tião e do Bastião apanha dos dois:
##   "Quem é esse?" / "Sei lá. Mas não fui com a cara dele."
##
## Este nó é o Tião (baixinho, colher de pau). O Bastião (alto, vassoura com
## faca, tampa de bueiro) é o PARCEIRO: corpo e vida PRÓPRIOS. Como no Dark
## Souls: DUAS barras, uma em cima da outra. Derrubou um? O outro fica com
## raiva (mais rápido e mais forte). A luta só acaba com os dois no chão.
## Vencidos: "Sebastião e Sebastião." / "Cabe os dois. Sempre coube."
## (brigoes_juntos: dali em diante, os dois aparecem juntos nas lutas).

enum Mode { DECIDE, APPROACH, ATTACK }

const PARTNER_FRAMES := preload("res://assets/sprites/bastiao_aliado_frames.tres")
const SPEECH_DEFEAT_1 := "Sebastião e Sebastião."
const SPEECH_DEFEAT_2 := "Cabe os dois. Sempre coube."

@export var colher: AttackData
@export var partner_damage := 16.0
@export var partner_speed := 58.0

const ENRAGE := 1.3

var mode := Mode.DECIDE
var partner: SebastiaoParceiro
## O Tião caiu, mas o Bastião ainda luta: o corpo fica no chão, sem barra.
var downed := false
var _mode_time := 0.0
var _decision := 0.0


func _ready() -> void:
	super._ready()
	partner = SebastiaoParceiro.new()
	partner.leader = self
	partner.frames = PARTNER_FRAMES
	partner.damage = partner_damage
	partner.speed = partner_speed
	partner.position = Vector2(26, 0)
	partner.downed_signal.connect(_on_partner_down)
	add_child(partner)


func display_name() -> String:
	return "Tião"


func display_title() -> String:
	return ""


func phase_label() -> String:
	return ""


## A segunda barra: o Bastião.
func partner_bar() -> Dictionary:
	if not is_instance_valid(partner):
		return {"name": "Bastião", "ratio": 0.0}
	return {"name": "Bastião", "ratio": partner.health_ratio()}


func _on_wake() -> void:
	_set_mode(Mode.DECIDE)
	_decision = 0.5
	partner.awake = true


func _set_mode(new_mode: Mode) -> void:
	mode = new_mode
	_mode_time = 0.0


func _fight(delta: float) -> void:
	_mode_time += delta
	if downed:
		velocity = Vector2.ZERO
		return
	match mode:
		Mode.DECIDE:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
			var to_target := target.global_position - global_position
			facing = to_target.normalized()
			_decision -= delta
			if _decision > 0.0:
				return
			if to_target.length() < 30.0:
				_set_mode(Mode.ATTACK)
				start_attack(colher, facing)
			else:
				_set_mode(Mode.APPROACH)
		Mode.APPROACH:
			var to_target := target.global_position - global_position
			facing = to_target.normalized()
			velocity = velocity.move_toward(facing * move_speed, acceleration * delta)
			if to_target.length() < 26.0 or _mode_time > 1.3:
				_set_mode(Mode.DECIDE)
		Mode.ATTACK:
			track_target_during_windup()
			velocity = _runner.step(delta, velocity)


func _on_attack_finished() -> void:
	if mode == Mode.ATTACK:
		_set_mode(Mode.DECIDE)
		_decision = randf_range(0.4, 0.8)


func _on_reset() -> void:
	_set_mode(Mode.DECIDE)
	downed = false
	body_sprite.play(&"idle")
	if is_instance_valid(partner):
		partner.reset()
		partner.global_position = home_position + Vector2(26, 0)


## O Tião caiu. Se o Bastião ainda está de pé, a luta continua (e ele fica
## com raiva). Se não, acabou.
func _on_died() -> void:
	if is_instance_valid(partner) and not partner.is_down():
		downed = true
		_runner.cancel()
		hitbox.deactivate()
		hurtbox.invulnerable = true
		body_sprite.play(&"caido")
		partner.enrage(ENRAGE)
		Sfx.play(&"hit_heavy", -2.0)
		return
	_finish()


## O Bastião caiu: se o Tião ainda luta, ele fica com raiva; se o Tião já
## estava no chão, acabou.
func _on_partner_down() -> void:
	if downed:
		_finish()
	else:
		move_speed *= ENRAGE
		Sfx.play(&"roar", -8.0)


func _finish() -> void:
	Game.set_flag("brigoes_juntos")
	if is_instance_valid(partner):
		partner.defeated()
	downed = false
	_defeat(SPEECH_DEFEAT_1)
	# A segunda fala é do outro: vem logo depois, escrita na tela.
	var level := Level.find(self)
	if level and level.hud:
		level.hud.toast("“%s”" % SPEECH_DEFEAT_2)


func _after_move(delta: float) -> void:
	if not downed:
		update_body_animation(delta)
