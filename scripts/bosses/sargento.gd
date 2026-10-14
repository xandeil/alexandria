class_name SargentoSemPelotao
extends MiniBoss
## O Sargento Sem Pelotão — 1º mini-chefe da Cidade Estilhaçada.
## Bíblia: "Apita e chama reforços a cada 25% de vida perdida. Ensina a eliminar
## quem comanda antes do grupo."
##
## A lição vira regra: os soldados que ele chama obedecem a ELE. Se o Sargento
## cai, os reforços perdem a ordem e desabam na hora. Brigar com o pelotão é
## perder tempo; vá no oficial.

enum Mode { DECIDE, APPROACH, ATTACK, WHISTLE }

const SOLDIER_SCENE := preload("res://scenes/enemies/soldado_remendado.tscn")
const SPEECH_WAKE := "Recruta! Onde está o resto do pelotão?"
const SPEECH_WHISTLE := ["Pelotão, EM FORMA!", "Reforços! AGORA!", "Ninguém sai da posição!"]
const SPEECH_DEFEAT := "...Pelotão... dispensado."
## A cada quanto da vida perdida ele apita (0.25 = 75%, 50%, 25%).
const WHISTLE_STEP := 0.25

@export var sabre: AttackData
@export var estocada: AttackData
@export var reinforcements_per_whistle := 2
@export var whistle_time := 0.9

@onready var sabre_pivot: Node2D = $Visual/SabrePivot

var mode := Mode.DECIDE
var summoned: Array[SoldadoRemendado] = []
var _mode_time := 0.0
var _decision := 0.0
var _combo: Array[AttackData] = []
var _whistles_done := 0


func _on_wake() -> void:
	speech.emit(SPEECH_WAKE)
	Sfx.play(&"telegraph", -6.0)
	_set_mode(Mode.DECIDE)
	_decision = 0.6


func _set_mode(new_mode: Mode) -> void:
	mode = new_mode
	_mode_time = 0.0


func _fight(delta: float) -> void:
	_mode_time += delta
	match mode:
		Mode.DECIDE:
			_decide(delta)
		Mode.APPROACH:
			_approach(delta)
		Mode.ATTACK:
			track_target_during_windup()
			velocity = _runner.step(delta, velocity)
		Mode.WHISTLE:
			velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)
			if _mode_time >= whistle_time:
				_call_reinforcements()
				_set_mode(Mode.DECIDE)
				_decision = 0.4


func _decide(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	var to_target := target.global_position - global_position
	facing = to_target.normalized()
	if _pending_whistles() > 0:
		_start_whistle()
		return
	_decision -= delta
	if _decision > 0.0:
		return
	var distance := to_target.length()
	if distance < 32.0:
		_queue([sabre, sabre] if randf() < 0.5 else [sabre])
	elif distance < 90.0 and randf() < 0.45:
		_queue([estocada])
	else:
		_set_mode(Mode.APPROACH)


func _approach(delta: float) -> void:
	var to_target := target.global_position - global_position
	facing = to_target.normalized()
	velocity = velocity.move_toward(facing * move_speed, acceleration * delta)
	if to_target.length() < 28.0 or _mode_time > 1.4:
		_set_mode(Mode.DECIDE)


func _queue(attacks: Array) -> void:
	_combo.assign(attacks)
	_next()


func _next() -> void:
	if _combo.is_empty():
		_set_mode(Mode.DECIDE)
		_decision = randf_range(0.5, 0.9)
		return
	var attack: AttackData = _combo.pop_front()
	_set_mode(Mode.ATTACK)
	start_attack(attack, (target.global_position - global_position).normalized())
	if attack == estocada:
		Sfx.play(&"telegraph", -4.0)


func _on_attack_finished() -> void:
	if mode == Mode.ATTACK:
		_next()


# --- O apito ----------------------------------------------------------------------

## Quantos apitos estão "devendo" pela vida perdida (75%, 50%, 25%).
func _pending_whistles() -> int:
	var lost := 1.0 - stats.health_ratio()
	return mini(int(floor(lost / WHISTLE_STEP + 0.001)), 3) - _whistles_done


func _start_whistle() -> void:
	_whistles_done += 1
	_combo.clear()
	_runner.cancel()
	_set_mode(Mode.WHISTLE)
	body_sprite.play(&"apito")
	Sfx.play(&"whistle")
	Fx.float_text(global_position + Vector2(-10, -30), "PRIIII!", Color(1.0, 0.9, 0.6), 8)
	speech.emit(SPEECH_WHISTLE[(_whistles_done - 1) % SPEECH_WHISTLE.size()])


func _call_reinforcements() -> void:
	body_sprite.play(&"idle")
	for i in reinforcements_per_whistle:
		var at := _free_point_near(global_position, 46.0 + i * 12.0)
		var soldier := SOLDIER_SCENE.instantiate() as SoldadoRemendado
		soldier.position = at
		get_parent().add_child(soldier)
		soldier.ai = SoldadoRemendado.AI.CHASE  # já chega correndo
		summoned.append(soldier)
		Fx.dust(at, 8)


## Um ponto livre (sem parede) perto dele, para o reforço não nascer dentro de um prédio.
func _free_point_near(center: Vector2, radius: float) -> Vector2:
	var space := get_world_2d().direct_space_state
	for attempt in 12:
		var point := center + Vector2.from_angle(randf() * TAU) * radius
		var query := PhysicsPointQueryParameters2D.new()
		query.position = point
		query.collision_mask = 1
		if space.intersect_point(query, 1).is_empty():
			var ray := PhysicsRayQueryParameters2D.create(center, point, 1)
			if space.intersect_ray(ray).is_empty():
				return point
	return center + Vector2(radius * 0.5, 0)


func _on_poise_broken(_info: HitInfo) -> void:
	_combo.clear()
	_set_mode(Mode.DECIDE)
	_decision = stagger_time


func _can_be_staggered() -> bool:
	return mode != Mode.WHISTLE


func _on_reset() -> void:
	_set_mode(Mode.DECIDE)
	_whistles_done = 0
	_dismiss_platoon()


## Caiu o oficial: o pelotão perde a ordem.
func _on_died() -> void:
	_dismiss_platoon()
	_defeat(SPEECH_DEFEAT)


func _dismiss_platoon() -> void:
	for soldier in summoned:
		if is_instance_valid(soldier):
			soldier.dismiss()
	summoned.clear()


func _after_move(delta: float) -> void:
	if mode != Mode.WHISTLE:
		update_body_animation(delta)
	var side := -1.0 if body_sprite.flip_h else 1.0
	sabre_pivot.position = Vector2(4.0 * side, -8.0)
	if mode == Mode.ATTACK and _runner.is_running():
		var aim := hitbox_pivot.rotation
		match _runner.phase:
			AttackRunner.Phase.WINDUP:
				sabre_pivot.rotation = aim - 1.8 * side * _runner.phase_progress()
			AttackRunner.Phase.LUNGE, AttackRunner.Phase.ACTIVE:
				sabre_pivot.rotation = aim + 0.6 * side * _runner.phase_progress()
			_:
				sabre_pivot.rotation = aim + 0.6 * side
	else:
		var rest := (PI * 0.5 - 0.7) if side > 0.0 else (PI * 0.5 + 0.7)
		sabre_pivot.rotation = lerp_angle(sabre_pivot.rotation, rest, 10.0 * delta)
	(sabre_pivot.get_child(0) as Sprite2D).flip_v = cos(sabre_pivot.rotation) < 0.0
