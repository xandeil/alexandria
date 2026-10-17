class_name CapitaoDragonoide
extends MiniBoss
## O Capitão Dragonoide — 1º mini-chefe da Montanha Carbonizada.
## Bíblia: "líder dos atiradores, alterna entre escudo e lança-chamas. O
## Vendedor do Teatro comenta a morte dele."
##
## Duas posturas, uma de cada vez:
##   • ESCUDO: avança devagar atrás de um escudo de escamas (de frente, quase
##     nada entra) e dá pancadas com ele. Contorne: as costas ficam abertas.
##   • LANÇA-CHAMAS: planta os pés e varre um cone de fogo na sua direção,
##     deixando o chão em chamas. Sem escudo — mas chegar perto é atravessar o fogo.
##   • A TROCA de postura leva um instante e ele fica exposto: a janela.

enum Mode { SHIELD, SWAP, FLAME }

const SPEECH_WAKE := "Em nome da Senhora do Céu. Formação!"
const SPEECH_DEFEAT := "...Diga ao desertor... que ele tinha razão."

@export var bash: AttackData
@export var shield_time := 6.0
@export var flame_time := 4.5
@export var swap_time := 0.9
@export_range(0.0, 1.0) var shield_ratio := 0.1
@export var flame_range := 92.0
@export var flame_angle := 46.0
@export var flame_sweep_speed := 0.9
@export var flame_dps := 22.0
@export var patch_every := 0.22

@onready var telegraph: TelegraphDrawer = $Telegraph

var mode := Mode.SHIELD
var _mode_time := 0.0
var _next := Mode.FLAME
var _cooldown := 0.0
var _flame_dir := Vector2.RIGHT
var _patch_timer := 0.0
var _burn_timer := 0.0


func _on_wake() -> void:
	speech.emit(SPEECH_WAKE)
	Sfx.play(&"clang", -6.0)
	_set_mode(Mode.SHIELD)


func _on_reset() -> void:
	telegraph.clear()
	_set_mode(Mode.SHIELD)


func _set_mode(new_mode: Mode) -> void:
	mode = new_mode
	_mode_time = 0.0


func _fight(delta: float) -> void:
	_mode_time += delta
	_cooldown -= delta
	match mode:
		Mode.SHIELD:
			if _runner.is_running():
				velocity = _runner.step(delta, velocity)
				return
			var to_target := target.global_position - global_position
			facing = facing.slerp(to_target.normalized(), minf(3.0 * delta, 1.0))  # vira devagar
			if _cooldown <= 0.0 and to_target.length() < 30.0:
				start_attack(bash, facing)
				_cooldown = 1.2
				return
			velocity = velocity.move_toward(facing * move_speed * 0.6, acceleration * delta)
			if _mode_time >= shield_time:
				_next = Mode.FLAME
				_set_mode(Mode.SWAP)
				Sfx.play(&"clank", -4.0)
		Mode.SWAP:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
			if _mode_time >= swap_time:
				_set_mode(_next)
				if mode == Mode.FLAME:
					_flame_dir = (target.global_position - global_position).normalized()
					Sfx.play(&"fire_breath", -2.0)
		Mode.FLAME:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
			# A boca do lança-chamas persegue o herói devagar.
			var want := (target.global_position - global_position).normalized()
			_flame_dir = _flame_dir.slerp(want, minf(flame_sweep_speed * delta, 1.0)).normalized()
			facing = _flame_dir
			_burn(delta)
			if _mode_time >= flame_time:
				_next = Mode.SHIELD
				_set_mode(Mode.SWAP)
				Sfx.play(&"clank", -4.0)


func _burn(delta: float) -> void:
	_patch_timer -= delta
	if _patch_timer <= 0.0:
		_patch_timer = patch_every
		var reach := randf_range(24.0, flame_range)
		var spread := deg_to_rad(randf_range(-flame_angle, flame_angle) * 0.5)
		FirePatch.spawn(get_parent(), global_position + _flame_dir.rotated(spread) * reach, 11.0, 2.2, 10.0, self)
	_burn_timer -= delta
	if _burn_timer > 0.0:
		return
	_burn_timer = 0.25
	if in_flame(target.global_position):
		target.apply_burn(flame_dps * 0.25)


## Dentro do cone do lança-chamas?
func in_flame(point: Vector2) -> bool:
	var to := point - global_position
	return to.length() <= flame_range and absf(rad_to_deg(_flame_dir.angle_to(to))) <= flame_angle * 0.5


## Escudo de frente na postura de escudo; nas costas, nada segura.
func _incoming_damage_multiplier(info: HitInfo) -> float:
	if mode != Mode.SHIELD:
		return 1.0
	var toward := info.source_position - global_position
	return shield_ratio if absf(rad_to_deg(facing.angle_to(toward))) <= 70.0 else 1.0


func _on_damaged(_amount: float, _info: HitInfo, blocked: bool) -> void:
	if blocked:
		Sfx.play(&"clang", -6.0)


func _can_be_staggered() -> bool:
	return mode == Mode.SWAP


func _on_poise_broken(_info: HitInfo) -> void:
	_mode_time = minf(_mode_time, swap_time - stagger_time)  # cambaleio: a troca demora mais


func _on_died() -> void:
	telegraph.clear()
	_defeat(SPEECH_DEFEAT)


func _after_move(_delta: float) -> void:
	if absf(facing.x) > 0.05:
		body_sprite.flip_h = facing.x < 0.0
	var anim := &"escudo"
	match mode:
		Mode.SWAP:
			anim = &"troca"
		Mode.FLAME:
			anim = &"chamas"
	if mode == Mode.SHIELD and velocity.length() > 4.0:
		anim = &"escudo_anda"
	if body_sprite.animation != anim:
		body_sprite.play(anim)
	telegraph.arc_visible = mode == Mode.FLAME or (mode == Mode.SWAP and _next == Mode.FLAME)
	if telegraph.arc_visible:
		telegraph.arc_center = global_position
		telegraph.arc_direction = _flame_dir if mode == Mode.FLAME else (target.global_position - global_position).normalized() if target else facing
		telegraph.arc_radius = flame_range
		telegraph.arc_angle = deg_to_rad(flame_angle)
		telegraph.arc_progress = 1.0 if mode == Mode.FLAME else _mode_time / swap_time
	queue_redraw()


## O jato do lança-chamas (desenhado: língua de fogo tremendo).
func _draw() -> void:
	if mode != Mode.FLAME:
		return
	var t := Time.get_ticks_msec() * 0.02
	for k in 6:
		var spread := deg_to_rad(sin(t + k * 1.7) * flame_angle * 0.35)
		var tip := _flame_dir.rotated(spread) * flame_range * (0.6 + 0.4 * (0.5 + 0.5 * sin(t * 1.3 + k)))
		draw_line(Vector2(0, -10), tip + Vector2(0, -6), Color(1.0, 0.55 + 0.05 * k, 0.15, 0.55), 5.0 - k * 0.5)
