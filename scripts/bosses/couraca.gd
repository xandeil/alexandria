class_name CouracaAndante
extends MiniBoss
## A Couraça Andante — 2º mini-chefe da Cidade Estilhaçada.
## Bíblia: "Soldado fundido a uma armadura pesada; só leva dano real pelas
## costas. Prepara o jogador para os golpes lentos e pesados de Aldir."
##
## Como lutar:
##   • De frente, a chapa segura quase tudo (faíscas e "clang").
##   • Ele VIRA DEVAGAR. Depois de uma clavada (recuperação longa), contorne e
##     bata nas costas — lá a armadura tem uma fresta (dá para ver o uniforme).
##   • Ficou colado nas costas tempo demais? Ele avisa (círculo no chão) e GIRA
##     a clava em 360°. Dash para fora do círculo.

enum Mode { TURN, ATTACK }

## Do quanto o golpe precisa vir de trás (graus a partir da frente) para valer.
const BACK_ANGLE := 115.0

@export var clava: AttackData
@export var giro: AttackData
## Radianos por segundo: lento de propósito (é a brecha).
@export var turn_speed := 1.6
@export_range(0.0, 1.0) var front_damage_ratio := 0.08
## Tempo com o herói nas costas antes do giro.
@export var behind_patience := 1.2

@onready var mace_pivot: Node2D = $Visual/MacePivot
@onready var telegraph: TelegraphDrawer = $Telegraph

var mode := Mode.TURN
var _behind_time := 0.0
var _cooldown := 0.0
var _last_hit_from_back := false


func _on_wake() -> void:
	Sfx.play(&"step_heavy")
	Sfx.play(&"clang", -6.0)
	_cooldown = 0.6


## Ângulo (graus) entre a frente dele e um ponto.
func angle_to_point(point: Vector2) -> float:
	return rad_to_deg(absf(facing.angle_to(point - global_position)))


func is_behind(point: Vector2) -> bool:
	return angle_to_point(point) >= BACK_ANGLE


func _fight(delta: float) -> void:
	_cooldown -= delta
	match mode:
		Mode.TURN:
			_turn_and_walk(delta)
		Mode.ATTACK:
			velocity = _runner.step(delta, velocity)


func _turn_and_walk(delta: float) -> void:
	var to_target := target.global_position - global_position
	var distance := to_target.length()
	# Vira devagar na direção do herói.
	var goal := to_target.angle()
	var current := facing.angle()
	var step := clampf(angle_difference(current, goal), -turn_speed * delta, turn_speed * delta)
	facing = Vector2.from_angle(current + step)
	var behind := is_behind(target.global_position) and distance < 44.0
	_behind_time = _behind_time + delta if behind else maxf(_behind_time - delta, 0.0)
	if _cooldown <= 0.0:
		if _behind_time >= behind_patience:
			_attack(giro)
			return
		if distance < 40.0 and angle_to_point(target.global_position) < 35.0:
			_attack(clava)
			return
	# Anda devagar para a frente (só quando já está mais ou menos virado).
	var walk := facing * move_speed if angle_to_point(target.global_position) < 60.0 and distance > 30.0 else Vector2.ZERO
	velocity = velocity.move_toward(walk, acceleration * delta)


func _attack(attack: AttackData) -> void:
	mode = Mode.ATTACK
	_behind_time = 0.0
	start_attack(attack, facing)  # na direção em que ELE está virado, não na sua
	Sfx.play(&"telegraph", -4.0)


## Não corrige a mira durante o aviso: ele é lento demais para isso.
func track_target_during_windup() -> void:
	pass


func _on_attack_finished() -> void:
	mode = Mode.TURN
	_cooldown = randf_range(0.6, 1.1)


# --- A armadura ----------------------------------------------------------------------

func _incoming_damage_multiplier(info: HitInfo) -> float:
	_last_hit_from_back = is_behind(info.source_position)
	return 1.0 if _last_hit_from_back else front_damage_ratio


func _on_damaged(_amount: float, info: HitInfo, blocked: bool) -> void:
	if blocked:
		Sfx.play(&"clang", -4.0)
		poise = minf(poise + info.poise_damage, max_poise)  # de frente nem a postura sente


func _can_be_staggered() -> bool:
	return _last_hit_from_back and mode == Mode.TURN


func _on_poise_broken(_info: HitInfo) -> void:
	mode = Mode.TURN
	_cooldown = stagger_time + 0.4  # caiu a guarda: janela para bater nas costas


func _on_reset() -> void:
	mode = Mode.TURN
	_behind_time = 0.0


func _on_died() -> void:
	telegraph.clear()
	_defeat()


# --- Visual -----------------------------------------------------------------------

func _after_move(delta: float) -> void:
	if absf(facing.x) > 0.05:
		body_sprite.flip_h = facing.x < 0.0
	var walking := velocity.length() > 4.0 and mode == Mode.TURN
	if walking and body_sprite.animation != &"walk":
		body_sprite.play(&"walk")
	elif not walking and body_sprite.animation != &"idle":
		body_sprite.play(&"idle")
	var side := -1.0 if body_sprite.flip_h else 1.0
	mace_pivot.position = Vector2(8.0 * side, -12.0)
	if mode == Mode.ATTACK and _runner.is_running():
		var aim := hitbox_pivot.rotation
		var spin := _current_attack == giro
		match _runner.phase:
			AttackRunner.Phase.WINDUP:
				mace_pivot.rotation = aim - (PI * 0.9 if not spin else PI * 0.5) * side * _runner.phase_progress()
			AttackRunner.Phase.ACTIVE, AttackRunner.Phase.LUNGE:
				mace_pivot.rotation = aim + (TAU * _runner.phase_progress() if spin else 0.0)
			_:
				mace_pivot.rotation = aim
	else:
		var rest := (PI * 0.5 - 0.4) if side > 0.0 else (PI * 0.5 + 0.4)
		mace_pivot.rotation = lerp_angle(mace_pivot.rotation, rest, 8.0 * delta)
	(mace_pivot.get_child(0) as Sprite2D).flip_v = cos(mace_pivot.rotation) < 0.0
	_update_telegraph()


func _update_telegraph() -> void:
	telegraph.circle_visible = false
	telegraph.arc_visible = false
	if mode != Mode.ATTACK or _runner.phase != AttackRunner.Phase.WINDUP or _current_attack == null:
		return
	if _current_attack == giro:
		telegraph.circle_visible = true
		telegraph.circle_center = global_position
		telegraph.circle_radius = giro.radius
		telegraph.circle_progress = _runner.phase_progress()
	else:
		telegraph.arc_visible = true
		telegraph.arc_center = global_position
		telegraph.arc_direction = _runner.direction
		telegraph.arc_radius = clava.reach + clava.radius
		telegraph.arc_angle = deg_to_rad(clava.slash_arc_degrees)
		telegraph.arc_progress = _runner.phase_progress()
