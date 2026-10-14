class_name MaeDosEsporos
extends MiniBoss
## A Mãe dos Esporos — 2º mini-chefe do Bosque do Sono Eterno.
## Bíblia: "planta enorme cercada de Flores de Pólen. Ensina a Barra de
## Sonolência antes da luta de Nyssa."
##
## Ela não anda. Como se luta:
##   • CIPÓ: linha vermelha que trava; depois o cipó estala em linha reta.
##   • CHUVA DE ESPOROS: nuvens de pólen caem perto de você (círculos avisam).
##   • FLORESCER: incha inteira e solta um anel de sono enorme. Dash!
##   • Ela faz brotar Flores de Pólen em volta (até 3 dela).
##   • A LIÇÃO: dormiu perto dela? O próximo cipó é o pesado. Atacar espanta
##     o sono (a barra desce a cada golpe) — fique agressivo, como contra Nyssa.

enum Mode { DECIDE, VINE, SPORES, BLOOM }

const FLOWER_SCENE := preload("res://scenes/enemies/flor_polen.tscn")
const SPEECH_WAKE := "Durma... Durma, que a terra cuida de você..."
const SPEECH_DEFEAT := "...Quem vai... cuidar... do sono deles..."

@export var vine_damage := 22.0
@export var vine_sleeper_damage := 44.0
@export var vine_length := 120.0
@export var vine_aim_time := 0.85
@export var spore_count := 3
@export var bloom_every := 3
@export var bloom_reach := 170.0
@export var max_flowers := 3
@export var flower_every := 12.0

@onready var telegraph: TelegraphDrawer = $Telegraph

var mode := Mode.DECIDE
var my_flowers: Array[Enemy] = []
var _mode_time := 0.0
var _decision := 0.0
var _vine_dir := Vector2.RIGHT
var _vine_hit := false
var _vine_heavy := false
var _actions := 0
var _flower_timer := 0.0
var _spore_points: Array[Vector2] = []


func _on_wake() -> void:
	speech.emit(SPEECH_WAKE)
	Sfx.play(&"puff", 0.0, 0.0)
	_set_mode(Mode.DECIDE)
	_decision = 0.8
	_flower_timer = 4.0


func _on_reset() -> void:
	_set_mode(Mode.DECIDE)
	telegraph.clear()
	_wither_flowers()


func _set_mode(new_mode: Mode) -> void:
	mode = new_mode
	_mode_time = 0.0


func _fight(delta: float) -> void:
	_mode_time += delta
	velocity = Vector2.ZERO
	_grow_flowers(delta)
	match mode:
		Mode.DECIDE:
			_decide(delta)
		Mode.VINE:
			_vine(delta)
		Mode.SPORES:
			_spores()
		Mode.BLOOM:
			_bloom()
	queue_redraw()


func _decide(delta: float) -> void:
	facing = (target.global_position - global_position).normalized()
	# Dormiu perto dela? Ela não espera: cipó pesado já.
	if target.is_asleep() and global_position.distance_to(target.global_position) < vine_length:
		_start_vine(true)
		return
	_decision -= delta
	if _decision > 0.0:
		return
	_actions += 1
	if _actions % bloom_every == 0:
		_set_mode(Mode.BLOOM)
		Sfx.play(&"telegraph", -2.0)
	elif randf() < 0.6:
		_start_vine(false)
	else:
		_start_spores()


# --- Cipó --------------------------------------------------------------------------------

func _start_vine(heavy: bool) -> void:
	_set_mode(Mode.VINE)
	_vine_heavy = heavy
	_vine_hit = false
	_vine_dir = (target.global_position - global_position).normalized()
	Sfx.play(&"telegraph", -5.0)


func _vine(_delta: float) -> void:
	var aim := vine_aim_time * (0.5 if _vine_heavy else 1.0)
	if _mode_time < aim * 0.7 and target:
		_vine_dir = (target.global_position - global_position).normalized()  # depois TRAVA
	if _mode_time >= aim and _mode_time < aim + 0.2:
		if not _vine_hit:
			if _mode_time - get_physics_process_delta_time() < aim:
				Sfx.play(&"swing_heavy", -2.0)
			_try_vine_hit()
	elif _mode_time >= aim + 0.55:
		_set_mode(Mode.DECIDE)
		_decision = randf_range(0.5, 0.9)


## Um segmento de reta: acerta quem estiver a até 10 px dele.
func _try_vine_hit() -> void:
	if target == null or target.is_dead():
		return
	var from := global_position + Vector2(0, -10)
	var to := from + _vine_dir * vine_length
	var point := Geometry2D.get_closest_point_to_segment(target.global_position + Vector2(0, -6), from, to)
	if point.distance_to(target.global_position + Vector2(0, -6)) > 10.0:
		return
	var info := HitInfo.create(vine_sleeper_damage if _vine_heavy else vine_damage, global_position, target.global_position)
	info.knockback = 180.0
	info.poise_damage = 30.0
	info.is_heavy = _vine_heavy
	info.attack_name = "Cipó"
	info.source = self
	if target.hurtbox.receive_hit(info):
		_vine_hit = true


# --- Chuva de esporos ---------------------------------------------------------------------

func _start_spores() -> void:
	_set_mode(Mode.SPORES)
	_spore_points.clear()
	for i in spore_count:
		var offset := Vector2.from_angle(randf() * TAU) * randf_range(0.0, 46.0)
		_spore_points.append(target.global_position + offset)


func _spores() -> void:
	if _mode_time >= 0.8 and not _spore_points.is_empty():
		for point in _spore_points:
			PollenCloud.spawn(get_parent(), point, 30.0, 3.0)
		_spore_points.clear()
		Sfx.play(&"puff", -2.0, 0.1)
	if _mode_time >= 1.4:
		_set_mode(Mode.DECIDE)
		_decision = 0.6


# --- Florescer (o grande anel de sono) ----------------------------------------------------

func _bloom() -> void:
	if _mode_time >= 1.4 and _mode_time - get_physics_process_delta_time() < 1.4:
		SleepRing.spawn(get_parent(), global_position + Vector2(0, -12), bloom_reach, 60.0)
		for i in 4:
			PollenCloud.spawn(get_parent(), global_position + Vector2.from_angle(i * TAU / 4.0 + 0.4) * 48.0, 26.0, 2.5)
		Sfx.play(&"burst", 0.0)
		Fx.shake(3.0, 0.3)
	if _mode_time >= 2.2:
		_set_mode(Mode.DECIDE)
		_decision = 0.8


func _can_be_staggered() -> bool:
	return mode != Mode.BLOOM


func _on_poise_broken(_info: HitInfo) -> void:
	_set_mode(Mode.DECIDE)
	_decision = stagger_time


# --- Flores ----------------------------------------------------------------------------

func _grow_flowers(delta: float) -> void:
	for i in range(my_flowers.size() - 1, -1, -1):
		if not is_instance_valid(my_flowers[i]) or my_flowers[i].dead:
			my_flowers.remove_at(i)
	_flower_timer -= delta
	if _flower_timer > 0.0 or my_flowers.size() >= max_flowers:
		return
	_flower_timer = flower_every
	var flower := FLOWER_SCENE.instantiate() as Enemy
	flower.position = global_position + Vector2.from_angle(randf() * TAU) * randf_range(44.0, 64.0)
	flower.memory_reward = 0  # flor de brotação não paga (senão vira "fazenda")
	get_parent().add_child(flower)
	my_flowers.append(flower)
	Fx.dust(flower.global_position, 6)


## Morreu (ou desistiu): as flores DELA murcham junto.
func _wither_flowers() -> void:
	for flower in my_flowers:
		if is_instance_valid(flower) and not flower.dead:
			flower.stats.take_damage(9999.0)
	my_flowers.clear()


func _on_died() -> void:
	telegraph.clear()
	_wither_flowers()
	_defeat(SPEECH_DEFEAT)


# --- Visual --------------------------------------------------------------------------

func _after_move(_delta: float) -> void:
	var frame := 0
	if mode == Mode.BLOOM and _mode_time < 1.4:
		frame = 1
		visual.scale = Vector2.ONE * (1.0 + 0.08 * (_mode_time / 1.4)) + Vector2(sin(_mode_time * 30.0) * 0.02, 0)
	elif mode == Mode.BLOOM:
		frame = 2
		visual.scale = visual.scale.lerp(Vector2.ONE, 0.2)
	else:
		visual.scale = Vector2.ONE + Vector2(0, sin(Time.get_ticks_msec() * 0.003) * 0.02)
	if body_sprite.animation != &"idle":
		body_sprite.play(&"idle")
	body_sprite.frame = frame
	body_sprite.pause()
	_update_telegraph()


func _update_telegraph() -> void:
	telegraph.line_visible = false
	telegraph.circle_visible = false
	if mode == Mode.VINE:
		var aim := vine_aim_time * (0.5 if _vine_heavy else 1.0)
		if _mode_time < aim:
			telegraph.line_visible = true
			telegraph.line_origin = global_position + Vector2(0, -6)
			telegraph.line_direction = _vine_dir
			telegraph.line_length = vine_length
			telegraph.line_locked = _mode_time >= aim * 0.7
	elif mode == Mode.BLOOM and _mode_time < 1.4:
		telegraph.circle_visible = true
		telegraph.circle_center = global_position
		telegraph.circle_radius = 40.0
		telegraph.circle_progress = _mode_time / 1.4


## O cipó estalando (desenhado: uma linha grossa verde que some).
func _draw() -> void:
	if mode == Mode.SPORES and not _spore_points.is_empty():
		for point in _spore_points:
			var local := point - global_position
			draw_arc(local, 26.0 * clampf(_mode_time / 0.8, 0.2, 1.0), 0.0, TAU, 24, Color(1.0, 0.9, 0.5, 0.6), 1.5)
	if mode != Mode.VINE:
		return
	var aim := vine_aim_time * (0.5 if _vine_heavy else 1.0)
	if _mode_time < aim or _mode_time > aim + 0.45:
		return
	var t := clampf((_mode_time - aim) / 0.12, 0.0, 1.0)
	var fade := 1.0 - clampf((_mode_time - aim - 0.2) / 0.25, 0.0, 1.0)
	var from := Vector2(0, -10)
	var to := from + _vine_dir * vine_length * t
	draw_line(from, to, Color(0.16, 0.3, 0.14, fade), 5.0)
	draw_line(from, to, Color(0.45, 0.7, 0.32, fade), 2.0)
