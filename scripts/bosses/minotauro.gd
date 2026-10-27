class_name Minotauro
extends MiniBoss
## O Minotauro — o pai do Bezerro Dourado (farm da Montanha, v0.26).
##
## Mataram o filho dele: cai do céu no campo e começa a PULAR para todo lado.
##   • SALTO: agacha (o círculo vermelho mostra onde vai cair, perto de você),
##     some no alto e despenca. Ao cair fica um instante parado: é a janela.
##   • PULINHOS: três saltos curtos seguidos para pontos aleatórios do campo,
##     cada um com uma área menor. Fique de olho nas sombras.
##   • MACHADADA: chegou perto demais, ele ergue o machado.
##
## É um chefe que VOLTA: não fica no save como vencido. Morreu ele (ou você),
## o bezerro está pastando de novo como se nada tivesse acontecido — quem cuida
## desse ciclo é o FarmSpot. Este script só luta e paga a recompensa.

enum Mode { ENTER, DECIDE, CROUCH, AIR, LANDED, SWING, DAZED }

const REWARD_MEMORIES := 4000
const REWARD_SUCATA := 10
const SPEECH_ENTER := "(O chão treme. Alguém veio buscar o filho.)"

@export var axe: AttackData
@export var crouch_time := 0.55
@export var leap_air_time := 0.8
@export var leap_height := 90.0
@export var leap_radius := 42.0
@export var leap_damage := 34.0
@export var hops_per_combo := 3
@export var hop_air_time := 0.42
@export var hop_height := 34.0
@export var hop_radius := 28.0
@export var hop_damage := 20.0
## Parado depois de cair do salto grande: a janela para bater.
@export var landed_time := 0.9
@export var dazed_time := 2.0
@export var enter_fall_time := 0.9

@onready var telegraph: TelegraphDrawer = $Telegraph

var mode := Mode.ENTER
## Onde ele pode pular (o campo). O FarmSpot preenche.
var field := Rect2()
var _mode_time := 0.0
var _from := Vector2.ZERO
var _to := Vector2.ZERO
var _air_time := 0.0
var _height := 0.0
var _hop := false
var _hops_left := 0
var _actions := 0


func display_name() -> String:
	return "O Minotauro"


func display_title() -> String:
	return "Pai do Bezerro Dourado"


## O FarmSpot chama ao criar: cai do céu em `at` e a luta começa ao tocar o chão.
func erupt(at: Vector2) -> void:
	global_position = at
	_from = at
	_to = at
	visible = true
	hurtbox.invulnerable = true
	_set_air(true)
	_set_mode(Mode.ENTER)
	visual.position.y = -260.0
	speech.emit(SPEECH_ENTER)
	Sfx.play(&"roar", 0.0)


# --- Ciclo (MiniBoss) ----------------------------------------------------------------------

## Antes da luta só existe a QUEDA da entrada (ele não fica dormindo no posto).
func _dormant(delta: float) -> void:
	if mode != Mode.ENTER:
		super._dormant(delta)
		return
	_mode_time += delta
	velocity = Vector2.ZERO
	var t := minf(_mode_time / enter_fall_time, 1.0)
	visual.position.y = -260.0 * (1.0 - t * t)
	_show_circle(global_position, leap_radius, t)
	if t >= 1.0:
		_land(leap_radius, leap_damage)
		start_fight()
		_set_mode(Mode.DECIDE)
		_mode_time = -0.8


## Desiste quando o herói sai do CAMPO (não "do posto": ele pula o campo todo).
func _should_reset(delta: float) -> bool:
	if target == null:
		return true
	var far := field.size != Vector2.ZERO and not field.grow(48.0).has_point(target.global_position)
	_away_time = _away_time + delta if far else 0.0
	return _away_time >= reset_time


func _on_reset() -> void:
	telegraph.clear()
	_set_air(false)
	visual.position.y = 0.0


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
			_decide()
		Mode.CROUCH:
			velocity = Vector2.ZERO
			_show_circle(_to, _radius(), _mode_time / crouch_time)
			if _mode_time >= crouch_time:
				_take_off()
		Mode.AIR:
			var t := minf(_mode_time / _air_time, 1.0)
			velocity = (_to - _from) / _air_time
			visual.position.y = -sin(t * PI) * _height
			_show_circle(_to, _radius(), 1.0)
			if t >= 1.0:
				_touch_down()
		Mode.LANDED:
			velocity = velocity.move_toward(Vector2.ZERO, 900.0 * delta)
			if _mode_time >= landed_time:
				_set_mode(Mode.DECIDE)
				_mode_time = -0.3
		Mode.SWING:
			velocity = _runner.step(delta, velocity)
		Mode.DAZED:
			velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)
			if _mode_time >= dazed_time:
				_set_mode(Mode.DECIDE)


func _decide() -> void:
	var to_target := target.global_position - global_position
	facing = to_target.normalized() if to_target != Vector2.ZERO else facing
	_actions += 1
	if to_target.length() < 44.0 and _actions % 2 == 0:
		_set_mode(Mode.SWING)
		start_attack(axe, facing)
		return
	if _actions % 4 == 0:
		_hops_left = hops_per_combo  # "pra tudo que é lado"
		_hop = true
		_aim_jump(_random_point())
		return
	_hop = false
	var near := target.global_position + Vector2.from_angle(randf() * TAU) * randf_range(0.0, 22.0)
	_aim_jump(near)


func _aim_jump(point: Vector2) -> void:
	_from = global_position
	_to = _clamp_to_field(point)
	facing = (_to - _from).normalized() if _to != _from else facing
	_set_mode(Mode.CROUCH)
	Sfx.play(&"telegraph", -5.0)
	if _hop:
		_mode_time = crouch_time * 0.55  # pulinho: agacha menos


func _take_off() -> void:
	_air_time = hop_air_time if _hop else leap_air_time
	_height = hop_height if _hop else leap_height
	_from = global_position
	_set_air(true)
	_set_mode(Mode.AIR)
	Fx.dust(global_position, 8)


func _touch_down() -> void:
	global_position = _to
	velocity = Vector2.ZERO
	_land(_radius(), hop_damage if _hop else leap_damage)
	if _hop:
		_hops_left -= 1
		if _hops_left > 0:
			_aim_jump(_random_point())
			return
	_set_mode(Mode.LANDED)
	_mode_time = 0.0 if not _hop else landed_time * 0.4


## Toca o chão: área de dano em volta (o dash atravessa).
func _land(radius: float, damage: float) -> void:
	_set_air(false)
	visual.position.y = 0.0
	telegraph.circle_visible = false
	Sfx.play(&"slam", 0.0)
	Fx.shake(6.0 if radius >= leap_radius else 3.5, 0.35)
	Fx.dust(global_position, 18 if radius >= leap_radius else 10)
	if target and target.global_position.distance_to(global_position) <= radius + 6.0:
		var info := HitInfo.create(damage, global_position, target.global_position)
		info.knockback = 240.0
		info.poise_damage = 45.0
		info.is_heavy = true
		info.attack_name = "Queda do Minotauro"
		info.source = self
		target.hurtbox.receive_hit(info)


## No ar: atravessa tudo (árvores, inimigos) e não dá para acertá-lo.
func _set_air(on: bool) -> void:
	set_collision_mask_value(1, not on)
	set_collision_mask_value(2, not on)
	if mode != Mode.ENTER or not on:
		hurtbox.invulnerable = on


func _radius() -> float:
	return hop_radius if _hop else leap_radius


func _random_point() -> Vector2:
	if field.size == Vector2.ZERO:
		return global_position + Vector2.from_angle(randf() * TAU) * 60.0
	return Vector2(randf_range(field.position.x, field.end.x), randf_range(field.position.y, field.end.y))


func _clamp_to_field(point: Vector2) -> Vector2:
	if field.size == Vector2.ZERO:
		return point
	var inner := field.grow(-8.0)
	return Vector2(clampf(point.x, inner.position.x, inner.end.x), clampf(point.y, inner.position.y, inner.end.y))


func _show_circle(center: Vector2, radius: float, progress: float) -> void:
	telegraph.circle_visible = true
	telegraph.circle_center = center
	telegraph.circle_radius = radius
	telegraph.circle_progress = clampf(progress, 0.0, 1.0)


func _on_attack_finished() -> void:
	if mode == Mode.SWING:
		_set_mode(Mode.DECIDE)
		_mode_time = -0.4


## Só cambaleia no chão, parado (depois de cair ou decidindo).
func _can_be_staggered() -> bool:
	return mode == Mode.LANDED or mode == Mode.DECIDE or mode == Mode.DAZED


func _on_poise_broken(_info: HitInfo) -> void:
	telegraph.clear()
	_set_air(false)
	visual.position.y = 0.0
	_set_mode(Mode.DAZED)


# --- Recompensa (não fica no save: ele volta) --------------------------------------------

func _on_died() -> void:
	telegraph.clear()
	_set_air(false)
	visual.position.y = 0.0
	dead = true
	active = false
	_runner.cancel()
	hitbox.deactivate()
	remove_from_group("enemies")
	hurtbox.set_deferred("monitorable", false)
	set_deferred("collision_layer", 0)
	Game.add_memories(REWARD_MEMORIES)
	if target:
		Fx.memory_motes(global_position + Vector2(0, -20), target, 14)
	ItemPickup.drop(get_parent(), global_position, "sucata_temperada", REWARD_SUCATA)
	Sfx.play(&"boss_phase", -4.0)
	Fx.slow_motion(0.3, 0.5)
	fight_won.emit(self)
	_play_death()


func _after_move(_delta: float) -> void:
	if absf(facing.x) > 0.05:
		body_sprite.flip_h = facing.x < 0.0
	var anim := &"walk" if velocity.length() > 6.0 else &"idle"
	match mode:
		Mode.ENTER, Mode.AIR:
			anim = &"salto"
		Mode.CROUCH:
			anim = &"agacha"
		Mode.SWING:
			anim = &"ergue" if _runner.phase == AttackRunner.Phase.WINDUP else &"golpe"
		Mode.LANDED, Mode.DAZED:
			anim = &"idle"
	if body_sprite.animation != anim:
		body_sprite.play(anim)
	if mode != Mode.CROUCH and mode != Mode.AIR and mode != Mode.ENTER:
		telegraph.circle_visible = false
