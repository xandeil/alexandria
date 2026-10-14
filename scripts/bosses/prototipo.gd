class_name Prototipo
extends MiniBoss
## O Protótipo — 1º mini-chefe das Forjas Ocas.
## Bíblia: "um autômato com o formato do próprio jogador, mas inacabado. Usa só
## o ataque básico do jogador. É o primeiro sinal de que Durgan copia."
##
## É você, em bronze, maior e sem metade das peças. Sabe UM golpe — o seu
## corte leve — e o repete em sequências de 1 a 3, com o mesmo avanço curto
## (Step and Anchor). Para encurtar distância ele "dá dash" como você. Ele não
## sabe se defender nem variar: a lição é ler o próprio golpe de fora.

enum Mode { APPROACH, ATTACK, DASH, RECOVER }

const SPEECH_WAKE := "(Engrenagens tentando imitar uma respiração.)"

@export var basic_attack: AttackData
## O corpo é maior: o mesmo golpe pesa mais.
@export_range(0.5, 3.0) var damage_ratio := 1.3
@export var dash_speed := 230.0
@export var dash_time := 0.26
@export var dash_range := 90.0
@export var recover_time := 0.9

var mode := Mode.APPROACH
var _mode_time := 0.0
var _swings_left := 0
var _dash_dir := Vector2.RIGHT
var _cooldown := 0.0


func _on_wake() -> void:
	speech.emit(SPEECH_WAKE)
	Sfx.play(&"clank", -4.0)
	_cooldown = 0.6
	_set_mode(Mode.APPROACH)


func _on_reset() -> void:
	_set_mode(Mode.APPROACH)


func _set_mode(new_mode: Mode) -> void:
	mode = new_mode
	_mode_time = 0.0


func _fight(delta: float) -> void:
	_mode_time += delta
	_cooldown -= delta
	match mode:
		Mode.APPROACH:
			var to_target := target.global_position - global_position
			var distance := to_target.length()
			facing = to_target.normalized()
			if _cooldown <= 0.0 and distance <= 30.0:
				_swings_left = randi_range(1, 3)
				_swing()
				return
			if _cooldown <= 0.0 and distance > 50.0 and distance < dash_range:
				_dash(facing)
				return
			velocity = velocity.move_toward(facing * move_speed, acceleration * delta)
		Mode.ATTACK:
			velocity = _runner.step(delta, velocity)
		Mode.DASH:
			velocity = _dash_dir * dash_speed * (1.0 - _mode_time / dash_time * 0.6)
			if fmod(_mode_time, 0.05) < delta:
				Fx.afterimage(body_sprite, Color(0.9, 0.65, 0.35, 0.5))
			if _mode_time >= dash_time:
				_swings_left = 1
				_swing()  # chegou: o corte de sempre
		Mode.RECOVER:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
			if _mode_time >= recover_time:
				_cooldown = 0.3
				_set_mode(Mode.APPROACH)


func _dash(direction: Vector2) -> void:
	_dash_dir = direction
	Sfx.play(&"dash", -6.0)
	_set_mode(Mode.DASH)


func _swing() -> void:
	_swings_left -= 1
	_set_mode(Mode.ATTACK)
	start_attack(basic_attack, (target.global_position - global_position).normalized())


func _activate_hitbox() -> void:
	hitbox.activate_with(_current_attack, _current_attack.damage * damage_ratio)


func _on_attack_finished() -> void:
	if mode != Mode.ATTACK:
		return
	if _swings_left > 0 and target:
		_swing()
		return
	_set_mode(Mode.RECOVER)  # o mesmo "fim de combo" que você tem


func _on_poise_broken(_info: HitInfo) -> void:
	_swings_left = 0
	_set_mode(Mode.RECOVER)
	_mode_time = -stagger_time


func _on_died() -> void:
	_defeat()


func _after_move(delta: float) -> void:
	if absf(facing.x) > 0.05:
		body_sprite.flip_h = facing.x < 0.0
	var anim := &"walk" if velocity.length() > 6.0 and mode == Mode.APPROACH else &"idle"
	if mode == Mode.ATTACK and _runner.is_running():
		anim = &"golpe"
	if body_sprite.animation != anim:
		body_sprite.play(anim)
	visual.position.y = lerpf(visual.position.y, 0.0, 10.0 * delta)
