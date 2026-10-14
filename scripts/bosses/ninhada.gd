class_name Ninhada
extends MiniBoss
## A Ninhada — 2º mini-chefe das Raízes da Fome.
## Bíblia: "um amontoado de Larvas que se divide ao levar dano. Testa controle
## de grupo e o agarrão."
##
## Como lutar:
##   • A cada pedaço de vida perdido (split_every), ela SOLTA larvas — que
##     roubam memórias. Bater sem parar enche a arena de larvas.
##   • ENGOLIR: ergue-se (círculo enchendo) e cai por cima. Pegou? Você fica
##     preso no meio das larvas: toque rápido no Ataque. Escapou: ela fica
##     tonta (janela para bater).
##   • ROLAR: avança em linha reta por cima de você.
##   • Vencida, as larvas que saíram dela se desfazem junto.

enum Mode { CRAWL, ATTACK, ENGULF, HOLD, DAZED }

const LARVA_SCENE := preload("res://scenes/enemies/larva_seiva.tscn")
const SPEECH_WAKE := "(Centenas de bocas pequenas mastigando ao mesmo tempo.)"

@export var roll: AttackData
## A cada fração da vida perdida: solta larvas.
@export_range(0.05, 0.5) var split_every := 0.2
@export var larvae_per_split := 2
@export var max_larvae := 6
@export var engulf_windup := 0.9
@export var engulf_radius := 26.0
@export var engulf_every := 5.5
@export var dazed_time := 2.4
@export_group("Agarrão")
@export var grab_taps := 7
@export var grab_damage_per_second := 6.0
@export var grab_memory_ratio := 0.03
@export var grab_memory_min := 5

@onready var telegraph: TelegraphDrawer = $Telegraph

var mode := Mode.CRAWL
var larvae: Array[Enemy] = []
var _mode_time := 0.0
var _cooldown := 0.0
var _engulf_timer := 0.0
var _splits_done := 0
var _engulf_at := Vector2.ZERO


func _on_wake() -> void:
	speech.emit(SPEECH_WAKE)
	Sfx.play(&"slurp", -4.0)
	_cooldown = 1.0
	_engulf_timer = 3.0
	_set_mode(Mode.CRAWL)


func _on_reset() -> void:
	telegraph.clear()
	_dismiss_larvae()
	_splits_done = 0
	_set_mode(Mode.CRAWL)


func _set_mode(new_mode: Mode) -> void:
	mode = new_mode
	_mode_time = 0.0


func _fight(delta: float) -> void:
	_mode_time += delta
	_cooldown -= delta
	_engulf_timer -= delta
	for i in range(larvae.size() - 1, -1, -1):
		if not is_instance_valid(larvae[i]) or larvae[i].dead:
			larvae.remove_at(i)
	match mode:
		Mode.CRAWL:
			_crawl(delta)
		Mode.ATTACK:
			velocity = _runner.step(delta, velocity)
		Mode.ENGULF:
			_engulf(delta)
		Mode.HOLD:
			velocity = Vector2.ZERO
			if target == null or not target.is_grabbed_by(self):
				_set_mode(Mode.DAZED)  # escapou: a ninhada se espalha, tonta
				Fx.float_text(global_position + Vector2(-8, -36), "tonta", Color(1.0, 0.8, 0.7), 7)
		Mode.DAZED:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
			if _mode_time >= dazed_time:
				_cooldown = 0.6
				_set_mode(Mode.CRAWL)


func _crawl(delta: float) -> void:
	var to_target := target.global_position - global_position
	var distance := to_target.length()
	facing = to_target.normalized()
	if _cooldown <= 0.0:
		if _engulf_timer <= 0.0 and distance < 70.0:
			_start_engulf()
			return
		if distance < 64.0 and distance > 24.0 and randf() < 0.5:
			_set_mode(Mode.ATTACK)
			start_attack(roll, facing)
			return
		if distance <= 24.0:
			_start_engulf()
			return
	velocity = velocity.move_toward(facing * move_speed, acceleration * delta)


func _on_attack_finished() -> void:
	_cooldown = randf_range(0.7, 1.2)
	if mode == Mode.ATTACK:
		_set_mode(Mode.CRAWL)


# --- Engolir (o agarrão) ------------------------------------------------------------

func _start_engulf() -> void:
	_set_mode(Mode.ENGULF)
	_engulf_at = target.global_position
	Sfx.play(&"telegraph", -4.0)


func _engulf(delta: float) -> void:
	if _mode_time < engulf_windup * 0.6 and target:
		_engulf_at = target.global_position  # acompanha... depois TRAVA
	if _mode_time < engulf_windup:
		velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
		return
	if _mode_time - delta < engulf_windup:
		# Cai por cima do ponto travado (move_and_collide: não atravessa parede).
		move_and_collide(_engulf_at - global_position)
		Sfx.play(&"splat", -2.0)
		Fx.shake(3.0, 0.2)
		Fx.splash(global_position + Vector2(0, -6), Color(0.9, 0.85, 0.65), 10)
		if target and target.global_position.distance_to(global_position) <= engulf_radius * 0.75:
			if target.grab(self, grab_taps, Vector2(0, -2), grab_damage_per_second, grab_memory_ratio, grab_memory_min):
				_engulf_timer = engulf_every
				_set_mode(Mode.HOLD)
				return
	if _mode_time >= engulf_windup + 0.5:
		_engulf_timer = engulf_every
		_cooldown = 0.6
		_set_mode(Mode.CRAWL)


# --- Dividir-se ----------------------------------------------------------------------

func _on_damaged(_amount: float, _info: HitInfo, _blocked: bool) -> void:
	var lost := 1.0 - stats.health_ratio()
	while _splits_done < int(floor(lost / split_every)) and not stats.is_dead:
		_splits_done += 1
		split()


## Solta larvas em volta (até o limite vivo).
func split() -> void:
	Sfx.play(&"splat", -6.0, 0.2)
	for i in larvae_per_split:
		if larvae.size() >= max_larvae:
			return
		var larva := LARVA_SCENE.instantiate() as Enemy
		larva.position = global_position + Vector2.from_angle(randf() * TAU) * 18.0
		larva.memory_reward = 0
		get_parent().add_child(larva)
		larvae.append(larva)
	Fx.splash(global_position + Vector2(0, -10), Color(0.9, 0.85, 0.65), 8)


func _can_be_staggered() -> bool:
	return mode == Mode.CRAWL or mode == Mode.ATTACK


func _on_poise_broken(_info: HitInfo) -> void:
	_set_mode(Mode.DAZED)


func _dismiss_larvae() -> void:
	for larva in larvae:
		if is_instance_valid(larva) and not larva.dead:
			larva.stats.take_damage(9999.0)  # devolvem o que roubaram (morrem "de verdade")
	larvae.clear()


func _on_died() -> void:
	telegraph.clear()
	if target and target.is_grabbed_by(self):
		target.release_grab()
	_dismiss_larvae()
	_defeat()


# --- Visual --------------------------------------------------------------------------

func _after_move(_delta: float) -> void:
	if absf(facing.x) > 0.05:
		body_sprite.flip_h = facing.x < 0.0
	var anim := &"walk" if velocity.length() > 4.0 else &"idle"
	if mode == Mode.ENGULF or mode == Mode.HOLD:
		anim = &"ergue"
	if body_sprite.animation != anim:
		body_sprite.play(anim)
	# Encolhe conforme perde vida (as larvas foram embora).
	var size := lerpf(0.65, 1.0, stats.health_ratio())
	var squash := 1.0
	if mode == Mode.ENGULF and _mode_time < engulf_windup:
		squash = 1.0 + 0.25 * (_mode_time / engulf_windup)
	elif mode == Mode.DAZED:
		squash = 0.85
	visual.scale = Vector2(size * (2.0 - squash) * 0.5 + size * 0.5, size * squash)
	_update_telegraph()


func _update_telegraph() -> void:
	telegraph.circle_visible = false
	if mode == Mode.ENGULF and _mode_time < engulf_windup:
		telegraph.circle_visible = true
		telegraph.circle_center = _engulf_at
		telegraph.circle_radius = engulf_radius
		telegraph.circle_progress = _mode_time / engulf_windup
