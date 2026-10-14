class_name VigiaQueDormiu
extends MiniBoss
## O Vigia que Dormiu — 1º mini-chefe do Bosque do Sono Eterno.
## Bíblia: "um guardião gigante adormecido. O jogador pode passar escondido ou
## acordá-lo e lutar, como na escolha da Governanta. Lutar dá recompensa;
## passar dá um diálogo diferente com Nyssa."
##
## A ESCOLHA, de novo sem aviso:
##   • Passe DEVAGAR (sem dash, sem golpe, sem passos apressados) pelo lado
##     dele: ele não acorda, e o jogo anota Game.flags["vigia_evitado"].
##   • Qualquer barulho perto dele (o anel no chão mostra o seu) — ou um golpe —
##     e ele levanta. Fugir para longe faz ele voltar a dormir no posto.
##
## A luta: lento e pesadíssimo. Martelada (círculo no chão), varredura (arco)
## e o BOCEJO: um anel lilás que dá sono — atravesse com o dash.

signal sneaked_past

enum Mode { DECIDE, APPROACH, ATTACK, YAWN }

const SPEECH_WAKE := "...Quem... anda no bosque... fazendo barulho?"
const SPEECH_DEFEAT := "...Enfim... posso... dormir de verdade."

@export var martelo: AttackData
@export var varredura: AttackData
## De que lado fica o "depois dele" no mapa (para saber se você PASSOU).
@export var pass_direction := Vector2.RIGHT
@export var pass_distance := 60.0
@export var yawn_inhale := 1.1
@export var yawn_reach := 130.0
@export var yawn_drowsiness := 55.0

@onready var club_pivot: Node2D = $Visual/ClubPivot
@onready var telegraph: TelegraphDrawer = $Telegraph

var mode := Mode.DECIDE
var _mode_time := 0.0
var _decision := 0.0
var _yawned := false
var _attacks_since_yawn := 0
## Neste "turno" de sono ele já foi acordado? (passar depois de acordá-lo não conta)
var _woken_once := false


func _ready() -> void:
	super._ready()
	add_to_group("listeners")


# --- Dormindo: acorda com BARULHO, não com a visão ---------------------------------------

func _dormant(delta: float) -> void:
	var to_home := home_position - global_position
	if to_home.length() > 3.0:
		velocity = velocity.move_toward(to_home.normalized() * move_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	if target == null:
		return
	if target.is_heard_from(global_position) or global_position.distance_to(target.global_position) < 24.0:
		_woken_once = true
		start_fight()
		_on_wake()
		return
	# Passou do outro lado sem acordá-lo.
	if not _woken_once and not Game.has_flag("vigia_evitado"):
		var past := (target.global_position - home_position).dot(pass_direction.normalized())
		if past > pass_distance and absf((target.global_position - home_position).cross(pass_direction.normalized())) < 90.0:
			Game.set_flag("vigia_evitado")
			sneaked_past.emit()


func _on_wake() -> void:
	speech.emit(SPEECH_WAKE)
	Sfx.play(&"stone_wake", -2.0)
	Fx.shake(3.0, 0.4)
	_set_mode(Mode.DECIDE)
	_decision = 1.0


func _on_reset() -> void:
	_set_mode(Mode.DECIDE)
	_yawned = false
	telegraph.clear()


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
			velocity = _runner.step(delta, velocity)
		Mode.YAWN:
			_yawn(delta)


func _decide(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	var to_target := target.global_position - global_position
	facing = to_target.normalized()
	_decision -= delta
	if _decision > 0.0:
		return
	var distance := to_target.length()
	# Um bocejo a cada 2–3 golpes — ou logo, se o herói fica longe "esperando".
	if _attacks_since_yawn >= 3 or (distance > 70.0 and _attacks_since_yawn >= 1 and randf() < 0.5):
		_start_yawn()
	elif distance < 44.0:
		_attack(martelo if randf() < 0.5 else varredura)
	else:
		_set_mode(Mode.APPROACH)


func _approach(delta: float) -> void:
	var to_target := target.global_position - global_position
	facing = to_target.normalized()
	velocity = velocity.move_toward(facing * move_speed, acceleration * delta)
	if to_target.length() < 40.0 or _mode_time > 2.2:
		_set_mode(Mode.DECIDE)


func _attack(attack: AttackData) -> void:
	_set_mode(Mode.ATTACK)
	_attacks_since_yawn += 1
	start_attack(attack, (target.global_position - global_position).normalized())
	Sfx.play(&"telegraph", -4.0)


func _on_attack_finished() -> void:
	if mode == Mode.ATTACK:
		if _current_attack == martelo:
			Fx.shake(4.0, 0.2)
			Fx.dust(global_position + facing * 30.0, 12)
		_set_mode(Mode.DECIDE)
		_decision = randf_range(0.6, 1.0)


func _start_yawn() -> void:
	_set_mode(Mode.YAWN)
	_yawned = false
	_attacks_since_yawn = 0
	Sfx.play(&"yawn", 2.0, 0.0)
	speech.emit("Haaaaa...")


## Puxa o ar (aviso: círculo lilás crescendo)... e solta o anel de sono.
func _yawn(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	if not _yawned and _mode_time >= yawn_inhale:
		_yawned = true
		SleepRing.spawn(get_parent(), global_position + Vector2(0, -8), yawn_reach, yawn_drowsiness)
		Fx.shake(2.0, 0.3)
	if _mode_time >= yawn_inhale + 0.9:
		_set_mode(Mode.DECIDE)
		_decision = 0.5


func _can_be_staggered() -> bool:
	return mode != Mode.YAWN


func _on_poise_broken(_info: HitInfo) -> void:
	_set_mode(Mode.DECIDE)
	_decision = stagger_time


func _on_died() -> void:
	telegraph.clear()
	_defeat(SPEECH_DEFEAT)


# --- Visual --------------------------------------------------------------------------

func _after_move(delta: float) -> void:
	if absf(facing.x) > 0.05:
		body_sprite.flip_h = facing.x < 0.0
	var anim := &"idle"
	if not active and not dead:
		anim = &"dormindo"
	elif mode == Mode.ATTACK and _runner.is_running() and _runner.phase == AttackRunner.Phase.WINDUP and _current_attack == martelo:
		anim = &"golpe"
	elif velocity.length() > 4.0:
		anim = &"walk"
	if body_sprite.animation != anim:
		body_sprite.play(anim)
	var side := -1.0 if body_sprite.flip_h else 1.0
	club_pivot.position = Vector2(14.0 * side, -20.0)
	club_pivot.visible = active or dead
	if mode == Mode.ATTACK and _runner.is_running():
		var aim := hitbox_pivot.rotation
		match _runner.phase:
			AttackRunner.Phase.WINDUP:
				club_pivot.rotation = aim - (2.4 if _current_attack == martelo else 1.6) * side * _runner.phase_progress()
			AttackRunner.Phase.ACTIVE, AttackRunner.Phase.LUNGE:
				club_pivot.rotation = aim + 0.4 * side * _runner.phase_progress()
			_:
				club_pivot.rotation = aim + 0.4 * side
	else:
		var rest := (PI * 0.5 - 0.5) if side > 0.0 else (PI * 0.5 + 0.5)
		club_pivot.rotation = lerp_angle(club_pivot.rotation, rest, 6.0 * delta)
	(club_pivot.get_child(0) as Sprite2D).flip_v = cos(club_pivot.rotation) < 0.0
	_update_telegraph()


func _update_telegraph() -> void:
	telegraph.circle_visible = false
	telegraph.arc_visible = false
	if mode == Mode.YAWN and not _yawned:
		telegraph.circle_visible = true
		telegraph.circle_center = global_position
		telegraph.circle_radius = 30.0 + 20.0 * (_mode_time / yawn_inhale)
		telegraph.circle_progress = _mode_time / yawn_inhale
		return
	if mode != Mode.ATTACK or _runner.phase != AttackRunner.Phase.WINDUP or _current_attack == null:
		return
	if _current_attack == martelo:
		telegraph.circle_visible = true
		telegraph.circle_center = global_position + _runner.direction * martelo.reach
		telegraph.circle_radius = martelo.radius
		telegraph.circle_progress = _runner.phase_progress()
	else:
		telegraph.arc_visible = true
		telegraph.arc_center = global_position
		telegraph.arc_direction = _runner.direction
		telegraph.arc_radius = varredura.reach + varredura.radius
		telegraph.arc_angle = deg_to_rad(varredura.slash_arc_degrees)
		telegraph.arc_progress = _runner.phase_progress()
