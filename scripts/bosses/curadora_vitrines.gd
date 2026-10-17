class_name CuradoraVitrines
extends MiniBoss
## A Curadora de Vitrines — 1º mini-chefe do Domínio Congelado.
## Bíblia: "prende o jogador em blocos de gelo; quebrar o bloco exige toques
## rápidos. Ensina a reagir ao controle de espaço."
##
##   • VITRINE: um retângulo azul enche em volta de você. Saia antes de encher —
##     ou fica preso num bloco de gelo (toques rápidos no Ataque para quebrar).
##   • Preso, ela vem "catalogar": anda até o bloco e dá a bengalada pesada.
##     Quanto mais rápido você quebra o bloco, mais longe ela está quando você sai.
##   • De longe, leque de estilhaços de gelo; de perto, a bengala.

enum Mode { DECIDE, CASE, SHARDS, POKE, CATALOG }

const SPEECH_WAKE := "Não toque nas peças. Você ficaria ótimo numa vitrine."
const SPEECH_DEFEAT := "...Tanta coisa guardada... e ninguém nunca veio olhar."

@export var cane: AttackData
@export var cane_heavy: AttackData
@export var case_size := Vector2(52, 40)
@export var case_warning := 1.0
@export var case_taps := 6
@export var shard_count := 3
@export var shard_damage := 13.0
@export var shard_speed := 150.0
@export var aim_time := 0.6

@onready var telegraph: TelegraphDrawer = $Telegraph

var mode := Mode.DECIDE
var _mode_time := 0.0
var _actions := 0
var _aim := Vector2.RIGHT
var _case: FrostZone


func _on_wake() -> void:
	speech.emit(SPEECH_WAKE)
	Sfx.play(&"crystal", -4.0)
	_go_decide(0.8)


func _on_reset() -> void:
	telegraph.clear()
	if is_instance_valid(_case):
		_case.queue_free()
	_go_decide(0.0)


func _set_mode(new_mode: Mode) -> void:
	mode = new_mode
	_mode_time = 0.0


func _go_decide(delay: float) -> void:
	_set_mode(Mode.DECIDE)
	_mode_time = -delay


func _fight(delta: float) -> void:
	_mode_time += delta
	match mode:
		Mode.DECIDE:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
			if _mode_time >= 0.0:
				_decide()
		Mode.CASE:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
			if is_instance_valid(_case) and _case.is_frozen():
				if _trapped():
					_set_mode(Mode.CATALOG)
					Sfx.play(&"telegraph", -4.0)
				else:
					_go_decide(0.6)
			elif not is_instance_valid(_case):
				_go_decide(0.4)
		Mode.SHARDS:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
			if _mode_time < aim_time * 0.7:
				_aim = (target.global_position - global_position).normalized()
				facing = _aim
			if _mode_time >= aim_time:
				_fan()
				_go_decide(0.9)
		Mode.POKE:
			velocity = _runner.step(delta, velocity)
		Mode.CATALOG:
			# O herói preso: ela anda até o bloco e bate forte.
			if _runner.is_running():
				velocity = _runner.step(delta, velocity)
				return
			if not _trapped():
				_go_decide(0.5)  # quebrou o bloco a tempo
				return
			var to_target := target.global_position - global_position
			facing = to_target.normalized()
			if to_target.length() <= 26.0:
				start_attack(cane_heavy, facing)
			else:
				velocity = velocity.move_toward(facing * move_speed * 1.3, acceleration * delta)


func _decide() -> void:
	var to_target := target.global_position - global_position
	var distance := to_target.length()
	facing = to_target.normalized()
	_actions += 1
	if _actions % 3 == 1:
		open_case()
	elif distance < 30.0:
		_set_mode(Mode.POKE)
		start_attack(cane, facing)
	elif distance > 70.0 or _actions % 3 == 0:
		_aim = facing
		_set_mode(Mode.SHARDS)
		Sfx.play(&"telegraph", -8.0)
	else:
		velocity = facing * move_speed
		_go_decide(0.4)


## A vitrine: um retângulo em volta do herói que congela depois do aviso.
func open_case() -> FrostZone:
	var center := target.global_position + Vector2(0, -4)
	_case = FrostZone.spawn(get_parent(), Rect2(center - case_size * 0.5, case_size), case_warning, 2.5, case_taps, self)
	_set_mode(Mode.CASE)
	Sfx.play(&"crystal", -4.0, 0.1)
	return _case


func _trapped() -> bool:
	for block in get_tree().get_nodes_in_group(&"ice_blocks"):
		if (block as IceBlock).holds_player():
			return true
	return false


func _fan() -> void:
	for i in shard_count:
		var spread := deg_to_rad(16.0) * (i - (shard_count - 1) * 0.5)
		Projectile.launch(get_parent(), global_position + Vector2(0, -12) + _aim * 8.0, _aim.rotated(spread), self,
			shard_damage, shard_speed, 240.0, Projectile.FROST)
	Sfx.play(&"ice_shot", -4.0)


func _on_attack_finished() -> void:
	if mode == Mode.POKE or mode == Mode.CATALOG:
		_go_decide(0.7)


func _can_be_staggered() -> bool:
	return mode != Mode.CATALOG


func _on_poise_broken(_info: HitInfo) -> void:
	_go_decide(stagger_time)


func _on_died() -> void:
	telegraph.clear()
	for block in get_tree().get_nodes_in_group(&"ice_blocks"):
		(block as IceBlock).shatter()  # as vitrines quebram com ela
	_defeat(SPEECH_DEFEAT)


func _after_move(delta: float) -> void:
	update_body_animation(delta)
	telegraph.line_visible = mode == Mode.SHARDS
	if mode == Mode.SHARDS:
		telegraph.line_origin = global_position + Vector2(0, -10)
		telegraph.line_direction = _aim
		telegraph.line_length = 110.0
		telegraph.line_locked = _mode_time >= aim_time * 0.7
