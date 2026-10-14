class_name FadaMurcha
extends Enemy
## Fada Murcha — Bosque do Sono Eterno.
## Bíblia: "Voa em volta e cura outros inimigos. Fadas que também desistiram."
##
## Ela não ataca. Fica perto de quem está ferido e o CURA (um fio de luz
## lilás). Chegou perto dela? Foge voando. A lição é a mesma do Sargento, de
## outro jeito: quem sustenta o grupo morre primeiro.

enum AI { HOVER, HEAL, FLEE, FALLEN }

@export var heal_per_second := 12.0
## Cura no máximo isso por "conjuração" e descansa.
@export var heal_per_cast := 30.0
@export var heal_range := 64.0
@export var heal_cooldown := 2.5
## Procura feridos até esta distância.
@export var search_range := 150.0
@export var flee_distance := 44.0

var ai := AI.HOVER
var heal_target: Enemy
var _ai_time := 0.0
var _cooldown := 0.0
var _healed := 0.0
var _orbit := 0.0


func _ready() -> void:
	super._ready()
	_orbit = randf() * TAU


func _physics_process(delta: float) -> void:
	if dead:
		velocity = velocity.move_toward(Vector2.ZERO, 300.0 * delta)
		move_and_slide()
		queue_redraw()
		return
	_ai_time += delta
	_cooldown -= delta
	_orbit += delta * 1.6
	regen_poise(delta)
	target = find_target()
	if ai != AI.FALLEN and target and global_position.distance_to(target.global_position) < flee_distance:
		if ai != AI.FLEE:
			_set_ai(AI.FLEE)
	match ai:
		AI.HOVER:
			_hover(delta)
		AI.HEAL:
			_heal(delta)
		AI.FLEE:
			_flee(delta)
		AI.FALLEN:
			velocity = velocity.move_toward(Vector2.ZERO, 400.0 * delta)
			if _ai_time >= stagger_time:
				_set_ai(AI.HOVER)
	move_and_slide()
	_update_visual(delta)
	queue_redraw()


func _set_ai(new_ai: AI) -> void:
	ai = new_ai
	_ai_time = 0.0


## O ferido mais "grave" (menor % de vida) por perto — fora ela mesma.
func find_wounded() -> Enemy:
	var best: Enemy = null
	var best_ratio := 0.999
	for node in get_tree().get_nodes_in_group("enemies"):
		var ally := node as Enemy
		if ally == null or ally == self or ally.dead or ally is FadaMurcha:
			continue
		if ally.global_position.distance_to(global_position) > search_range:
			continue
		var ratio := ally.stats.health_ratio()
		if ratio < best_ratio:
			best = ally
			best_ratio = ratio
	return best


func _hover(delta: float) -> void:
	var anchor := home_position
	if _cooldown <= 0.0:
		heal_target = find_wounded()
		if heal_target:
			anchor = heal_target.global_position
			if global_position.distance_to(anchor) <= heal_range:
				_healed = 0.0
				_set_ai(AI.HEAL)
				Sfx.play(&"chime", -8.0, 0.1)
				return
	var goal := anchor + Vector2.from_angle(_orbit) * 26.0
	velocity = velocity.move_toward((goal - global_position).limit_length(1.0) * move_speed, acceleration * delta)


func _heal(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	if not is_instance_valid(heal_target) or heal_target.dead \
			or heal_target.global_position.distance_to(global_position) > heal_range * 1.3:
		_end_heal()
		return
	var amount := heal_per_second * delta
	heal_target.stats.heal(amount)
	_healed += amount
	if fmod(_ai_time, 0.3) < delta:
		Fx.splash(heal_target.global_position + Vector2(0, -12), Color(0.8, 0.72, 1.0), 3)
	if _healed >= heal_per_cast or heal_target.stats.health_ratio() >= 1.0:
		_end_heal()


func _end_heal() -> void:
	heal_target = null
	_cooldown = heal_cooldown
	_set_ai(AI.HOVER)


func _flee(delta: float) -> void:
	if target == null:
		_set_ai(AI.HOVER)
		return
	var away := (global_position - target.global_position).normalized()
	velocity = velocity.move_toward(away * move_speed * 1.3, acceleration * 1.5 * delta)
	if global_position.distance_to(target.global_position) > flee_distance * 2.2 or _ai_time > 1.6:
		_set_ai(AI.HOVER)


func _on_poise_broken(_info: HitInfo) -> void:
	heal_target = null
	_set_ai(AI.FALLEN)  # caiu no chão: a janela para acabar com ela


func is_healing() -> bool:
	return ai == AI.HEAL and is_instance_valid(heal_target)


func _update_visual(delta: float) -> void:
	if absf(velocity.x) > 4.0:
		body_sprite.flip_h = velocity.x < 0.0
	var fly := ai != AI.FALLEN
	var hover_y := (-10.0 + sin(_ai_time * 5.0) * 2.0) if fly else -1.0
	visual.position.y = lerpf(visual.position.y, hover_y, 10.0 * delta)
	body_sprite.speed_scale = 1.0 if fly else 0.0


## O fio de cura (lilás) até o aliado.
func _draw() -> void:
	if not is_healing():
		return
	var from := Vector2(0, visual.position.y - 6.0)
	var to := heal_target.global_position - global_position + Vector2(0, -10)
	var pulse := 0.6 + 0.4 * sin(_ai_time * 16.0)
	draw_line(from, to, Color(0.78, 0.7, 1.0, 0.35 * pulse), 3.0)
	draw_line(from, to, Color(1.0, 1.0, 1.0, 0.6 * pulse), 1.0)
