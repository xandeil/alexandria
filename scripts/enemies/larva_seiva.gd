class_name LarvaSeiva
extends Enemy
## Larva de Seiva — Raízes da Fome.
## Bíblia: "Enxame pequeno que rouba memórias ao tocar. Restos do que Mabel
## não terminou de comer."
##
## Cada mordida que acerta ROUBA memórias (uma fração do que você carrega).
## A larva que roubou brilha e FOGE com elas. Matá-la devolve tudo o que ela
## levou — então persiga a que está brilhando antes que ela se esconda.
## Fracas sozinhas (morrem com um golpe), perigosas em grupo.

enum AI { IDLE, CHASE, ATTACK, FLEE, STAGGER }

@export var bite: AttackData
@export var attack_range := 12.0
@export var attack_cooldown := Vector2(0.7, 1.3)
@export var steal_ratio := 0.04
@export var steal_min := 6
## Depois de roubar, foge por isso (s) antes de voltar.
@export var flee_time := 2.5
@export var flee_speed_multiplier := 1.3

var ai := AI.IDLE
## Memórias que esta larva carrega (voltam para você se ela morrer).
var stolen := 0
var _ai_time := 0.0
var _cooldown := 0.0


func _ready() -> void:
	super._ready()
	_cooldown = randf_range(0.0, 0.6)  # o enxame não morde em uníssono


func _physics_process(delta: float) -> void:
	if dead:
		return
	_ai_time += delta
	_cooldown -= delta
	regen_poise(delta)
	target = find_target()
	match ai:
		AI.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
			if target and global_position.distance_to(target.global_position) <= aggro_range and can_see(target.global_position):
				_set_ai(AI.CHASE)
		AI.CHASE:
			_chase(delta)
		AI.ATTACK:
			track_target_during_windup()
			velocity = _runner.step(delta, velocity)
		AI.FLEE:
			if target:
				var away := (global_position - target.global_position).normalized()
				facing = away
				velocity = velocity.move_toward(away * move_speed * flee_speed_multiplier, acceleration * delta)
			if _ai_time >= flee_time:
				_set_ai(AI.CHASE)
		AI.STAGGER:
			velocity = velocity.move_toward(Vector2.ZERO, 400.0 * delta)
			if _ai_time >= stagger_time:
				_set_ai(AI.CHASE)
	move_and_slide()
	update_body_animation(delta)
	_update_pose()


func _set_ai(new_ai: AI) -> void:
	ai = new_ai
	_ai_time = 0.0


func _chase(delta: float) -> void:
	if target == null:
		_set_ai(AI.IDLE)
		return
	var to_target := target.global_position - global_position
	facing = to_target.normalized()
	if to_target.length() <= attack_range and _cooldown <= 0.0:
		_set_ai(AI.ATTACK)
		start_attack(bite, facing)
		return
	if to_target.length() > leash_range:
		_set_ai(AI.IDLE)
		return
	# Rasteja em zigue-zague (enxame que "ferve").
	var wiggle := facing.orthogonal() * sin(_ai_time * 9.0 + home_position.x) * 0.5
	velocity = velocity.move_toward((facing + wiggle).normalized() * move_speed, acceleration * delta)


## Mordeu: rouba e foge.
func _on_hit_landed(hurtbox_hit: Hurtbox, _info: HitInfo) -> void:
	var player := hurtbox_hit.owner_body as Player
	if player and player.state == Player.State.BLOCK:
		return  # mordeu o escudo: não roubou nada
	var lost := Game.drain_memories(steal_ratio, steal_min)
	if lost <= 0:
		return
	stolen += lost
	Sfx.play(&"slurp", -8.0, 0.2)
	Fx.float_text(global_position + Vector2(-6, -18), "−%d" % lost, Color(0.85, 0.9, 1.0), 7)


func _on_attack_finished() -> void:
	_cooldown = randf_range(attack_cooldown.x, attack_cooldown.y)
	if ai == AI.ATTACK:
		_set_ai(AI.FLEE if stolen > 0 else AI.CHASE)


func _on_damaged(_amount: float, _info: HitInfo, _blocked: bool) -> void:
	if ai == AI.IDLE:
		_set_ai(AI.CHASE)


func _on_poise_broken(_info: HitInfo) -> void:
	_set_ai(AI.STAGGER)


## Morreu: o que ela levou volta (além da recompensa normal).
func _on_died() -> void:
	if stolen > 0:
		Game.add_memories(stolen)
		var player := find_target()
		if player:
			Fx.memory_motes(global_position + Vector2(0, -4), player, clampi(stolen / 8, 3, 12))
		Fx.float_text(global_position + Vector2(-8, -18), "+%d" % stolen, Color(0.95, 0.97, 1.0), 7)
		stolen = 0
	super._on_died()


func _update_pose() -> void:
	var biting := ai == AI.ATTACK and _runner.is_running() and _runner.phase != AttackRunner.Phase.RECOVERY
	if biting and body_sprite.animation != &"morde":
		body_sprite.play(&"morde")
	elif not biting and body_sprite.animation == &"morde":
		body_sprite.play(&"idle")
	# Carregando memórias: brilha branco (dá para ver quem roubou).
	var glow := clampf(stolen / 40.0, 0.0, 1.0)
	body_sprite.self_modulate = Color(1, 1, 1).lerp(Color(1.7, 1.7, 1.9), glow * (0.6 + 0.4 * sin(Time.get_ticks_msec() * 0.01)))
