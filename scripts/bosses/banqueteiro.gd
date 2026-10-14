class_name Banqueteiro
extends MiniBoss
## O Banqueteiro — 1º mini-chefe das Raízes da Fome.
## Bíblia: "antigo cozinheiro do projeto que serve 'pratos' de lacaios a Mabel.
## Se demorar, ele come os próprios lacaios e se cura. Ensina a matar a fonte
## de cura primeiro."
##
## Como lutar:
##   • SERVIR: ergue a cloche e "serve" lacaios (larvas ou um Inchado).
##   • COMER: ferido e com lacaio por perto, ele anda até um, ergue o garfo
##     (aviso) e COME — cura um bom pedaço. Golpe forte ou postura quebrada
##     no aviso interrompe. Melhor ainda: não deixe lacaio vivo.
##   • Cutelo (curto, pesado) e concha (arco largo, empurra).
##   • Dica: o Inchado servido explode em quem estiver perto... inclusive nele.

enum Mode { CHASE, ATTACK, SERVE, EAT }

const LARVA_SCENE := preload("res://scenes/enemies/larva_seiva.tscn")
const INCHADO_SCENE := preload("res://scenes/enemies/inchado.tscn")
const SPEECH_WAKE := "Mais um convidado! Sente-se, sente-se... a Senhora já vai comer."
const SPEECH_EAT := "Hmm... só uma provinha."
const SPEECH_DEFEAT := "...Ninguém... nunca... repetiu o prato..."

@export var cleaver: AttackData
@export var ladle: AttackData
@export var serve_every := 9.0
@export var max_lackeys := 4
## Come quando a vida está abaixo disso (0..1).
@export_range(0.0, 1.0) var eat_below := 0.9
@export var eat_every := 6.0
@export var eat_windup := 1.2
## Cura por lacaio comido (fração da vida máxima).
@export_range(0.0, 1.0) var eat_heal := 0.14
@export var eat_reach := 20.0

@onready var telegraph: TelegraphDrawer = $Telegraph

var mode := Mode.CHASE
var lackeys: Array[Enemy] = []
var _mode_time := 0.0
var _cooldown := 0.0
var _serve_timer := 0.0
var _eat_timer := 0.0
var _meal: Enemy
var _eat_started := false


func _on_wake() -> void:
	speech.emit(SPEECH_WAKE)
	Sfx.play(&"laugh", -8.0, 0.0)
	_serve_timer = 2.5
	_eat_timer = eat_every
	_cooldown = 0.8
	_set_mode(Mode.CHASE)


func _on_reset() -> void:
	telegraph.clear()
	_dismiss_lackeys()
	_set_mode(Mode.CHASE)


func _set_mode(new_mode: Mode) -> void:
	mode = new_mode
	_mode_time = 0.0


func _fight(delta: float) -> void:
	_mode_time += delta
	_cooldown -= delta
	_serve_timer -= delta
	_eat_timer -= delta
	_prune_lackeys()
	match mode:
		Mode.CHASE:
			_chase(delta)
		Mode.ATTACK:
			velocity = _runner.step(delta, velocity)
		Mode.SERVE:
			_serve(delta)
		Mode.EAT:
			_eat(delta)


func _chase(delta: float) -> void:
	# Ferido e com comida por perto: vai comer.
	if _eat_timer <= 0.0 and stats.health_ratio() < eat_below and not lackeys.is_empty():
		_meal = _nearest_lackey()
		if _meal:
			_eat_started = false
			_set_mode(Mode.EAT)
			return
	if _serve_timer <= 0.0 and lackeys.size() < max_lackeys:
		_set_mode(Mode.SERVE)
		Sfx.play(&"telegraph", -6.0)
		return
	var to_target := target.global_position - global_position
	var distance := to_target.length()
	facing = to_target.normalized()
	if _cooldown <= 0.0 and distance < 40.0:
		_set_mode(Mode.ATTACK)
		var attack := cleaver if distance < 30.0 and randf() < 0.6 else ladle
		start_attack(attack, facing)
		return
	velocity = velocity.move_toward(facing * move_speed if distance > 26.0 else Vector2.ZERO, acceleration * delta)


func _on_attack_finished() -> void:
	_cooldown = randf_range(0.8, 1.4)
	if mode == Mode.ATTACK:
		_set_mode(Mode.CHASE)


# --- Servir -------------------------------------------------------------------------

func _serve(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	if _mode_time >= 0.9 and _mode_time - delta < 0.9:
		serve()
	if _mode_time >= 1.4:
		_serve_timer = serve_every
		_set_mode(Mode.CHASE)


## Abre a cloche: 3 larvas... ou (às vezes) um Inchado.
func serve() -> void:
	var front := global_position + Vector2(facing.x if facing.x != 0.0 else 1.0, 0.3).normalized() * 22.0
	Sfx.play(&"door_slide", -8.0, 0.2)
	Fx.splash(front + Vector2(0, -8), Color(0.62, 0.1, 0.16), 10)
	if randf() < 0.35 and lackeys.size() <= max_lackeys - 1:
		_add_lackey(INCHADO_SCENE, front)
		return
	for i in mini(3, max_lackeys - lackeys.size()):
		_add_lackey(LARVA_SCENE, front + Vector2.from_angle(TAU * i / 3.0) * 8.0)


func _add_lackey(scene: PackedScene, at: Vector2) -> void:
	var lackey := scene.instantiate() as Enemy
	lackey.position = at
	lackey.memory_reward = 0  # servido não paga (senão vira "fazenda")
	lackey.home_position = at
	get_parent().add_child(lackey)
	lackeys.append(lackey)


func _prune_lackeys() -> void:
	for i in range(lackeys.size() - 1, -1, -1):
		if not is_instance_valid(lackeys[i]) or lackeys[i].dead:
			lackeys.remove_at(i)


func _nearest_lackey() -> Enemy:
	var best: Enemy = null
	var best_distance := INF
	for lackey in lackeys:
		var d := global_position.distance_to(lackey.global_position)
		if d < best_distance:
			best = lackey
			best_distance = d
	return best


# --- Comer (a lição: mate a fonte de cura primeiro) ---------------------------------------

func _eat(delta: float) -> void:
	if not is_instance_valid(_meal) or _meal.dead:
		_finish_eating(false)
		return
	var to_meal := _meal.global_position - global_position
	if not _eat_started:
		facing = to_meal.normalized()
		if to_meal.length() > eat_reach:
			velocity = velocity.move_toward(facing * move_speed * 1.3, acceleration * delta)
			if _mode_time > 4.0:
				_finish_eating(false)  # não alcançou: desiste
			return
		_eat_started = true
		_mode_time = 0.0
		speech.emit(SPEECH_EAT)
		Sfx.play(&"telegraph", -4.0)
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	_meal.velocity = Vector2.ZERO  # segura o "prato" no garfo
	if _mode_time >= eat_windup:
		_devour(_meal)
		_finish_eating(true)


func _devour(meal: Enemy) -> void:
	var heal := stats.max_health * eat_heal
	stats.heal(heal)
	Sfx.play(&"chomp", 0.0)
	Sfx.play(&"gulp", -4.0)
	Fx.splash(global_position + Vector2(0, -26), Color(0.62, 0.1, 0.16), 12)
	Fx.float_text(global_position + Vector2(-8, -44), "+%d" % int(heal), Color(0.6, 1.0, 0.6), 9)
	lackeys.erase(meal)
	meal.queue_free()


func _finish_eating(_ate: bool) -> void:
	_meal = null
	_eat_started = false
	_eat_timer = eat_every
	_cooldown = 0.5
	_set_mode(Mode.CHASE)


## Golpe forte (ou postura quebrada) no aviso: o garfo cai.
func _on_damaged(_amount: float, info: HitInfo, _blocked: bool) -> void:
	if mode == Mode.EAT and _eat_started and info.is_heavy:
		Fx.float_text(global_position + Vector2(-14, -44), "interrompido", Color(1.0, 0.85, 0.6), 7)
		_finish_eating(false)


func _on_poise_broken(_info: HitInfo) -> void:
	_finish_eating(false)
	_cooldown = stagger_time + 0.3


func _can_be_staggered() -> bool:
	return mode != Mode.SERVE


func _dismiss_lackeys() -> void:
	for lackey in lackeys:
		if is_instance_valid(lackey) and not lackey.dead:
			Fx.splash(lackey.global_position + Vector2(0, -6), Color(0.62, 0.1, 0.16), 6)
			lackey.queue_free()
	lackeys.clear()


func _on_died() -> void:
	telegraph.clear()
	_dismiss_lackeys()
	_defeat(SPEECH_DEFEAT)


# --- Visual --------------------------------------------------------------------------

func _after_move(delta: float) -> void:
	if absf(facing.x) > 0.05:
		body_sprite.flip_h = facing.x < 0.0
	var anim := &"idle"
	if mode == Mode.SERVE:
		anim = &"serve"
	elif mode == Mode.EAT and _eat_started:
		anim = &"come"
	elif mode == Mode.ATTACK and _runner.is_running() and _runner.phase == AttackRunner.Phase.WINDUP:
		anim = &"cutelo"
	elif velocity.length() > 4.0:
		anim = &"walk"
	if body_sprite.animation != anim:
		body_sprite.play(anim)
	visual.position.y = lerpf(visual.position.y, 0.0, 10.0 * delta)
	_update_telegraph()


func _update_telegraph() -> void:
	telegraph.circle_visible = false
	telegraph.arc_visible = false
	if mode == Mode.EAT and _eat_started:
		telegraph.circle_visible = true  # "ele vai comer": um aviso para correr e cortar
		telegraph.circle_center = global_position
		telegraph.circle_radius = 14.0
		telegraph.circle_progress = _mode_time / eat_windup
		return
	if mode != Mode.ATTACK or _runner.phase != AttackRunner.Phase.WINDUP or _current_attack == null:
		return
	telegraph.arc_visible = true
	telegraph.arc_center = global_position
	telegraph.arc_direction = _runner.direction
	telegraph.arc_radius = _current_attack.reach + _current_attack.radius
	telegraph.arc_angle = deg_to_rad(maxf(_current_attack.slash_arc_degrees, 60.0))
	telegraph.arc_progress = _runner.phase_progress()
