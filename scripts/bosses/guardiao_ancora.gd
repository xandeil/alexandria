class_name GuardiaoAncora
extends MiniBoss
## O Guardião da Âncora — 2º mini-chefe das Forjas Ocas.
## Bíblia: "máquina enorme presa a uma das correntes da ilha. Destruí-la faz a
## ilha tremer e abre o caminho até Durgan."
##
## Como lutar:
##   • A carcaça é grossa: golpes nela quase não entram (30%).
##   • Depois de dois ataques ela SUPERAQUECE: abre as grades, solta vapor e
##     o núcleo fica exposto (dano quase dobrado). É a sua janela.
##   • CORRENTE: um leque enorme em volta dela (aviso no chão). Dash para fora.
##   • PILÃO: bate no chão (círculo) e o raio corre pelas placas em volta —
##     não fique em cima das placas que acendem.
##   • Ferida (metade da vida), tudo fica mais rápido.

enum Mode { DECIDE, SWEEP, SLAM, VENT }

const SPEECH_WAKE := "(Uma sirene rouca. A corrente presa a ela estica, rangendo.)"
const SPEECH_DEFEAT := "(A corrente se solta. A ilha inteira estremece.)"

@export var sweep_reach := 76.0
@export var sweep_angle := 220.0
@export var sweep_damage := 28.0
@export var slam_radius := 40.0
@export var slam_damage := 30.0
@export var plate_ring := Vector2(36.0, 130.0)
@export var plate_damage := 22.0
@export var windup := 1.0
@export var vent_time := 2.6
@export_range(0.0, 1.0) var shell_damage_ratio := 0.3
@export_range(1.0, 3.0) var core_damage_ratio := 1.8

@onready var telegraph: TelegraphDrawer = $Telegraph

var mode := Mode.DECIDE
var _mode_time := 0.0
var _attacks := 0
var _aim := Vector2.RIGHT
var _struck := false


func _on_wake() -> void:
	speech.emit(SPEECH_WAKE)
	Sfx.play(&"stone_wake", -2.0)
	_set_mode(Mode.DECIDE)
	_mode_time = -0.8


func _on_reset() -> void:
	telegraph.clear()
	_attacks = 0
	_set_mode(Mode.DECIDE)


func _set_mode(new_mode: Mode) -> void:
	mode = new_mode
	_mode_time = 0.0
	_struck = false


func _windup() -> float:
	return windup * (0.75 if stats.health_ratio() <= 0.5 else 1.0)


func _fight(delta: float) -> void:
	_mode_time += delta
	velocity = Vector2.ZERO  # presa à corrente: não anda
	match mode:
		Mode.DECIDE:
			if _mode_time < 0.0:
				return
			_aim = (target.global_position - global_position).normalized()
			facing = _aim
			if _attacks >= 2:
				_attacks = 0
				_set_mode(Mode.VENT)
				Sfx.play(&"puff", 0.0, 0.1)
				return
			_attacks += 1
			var close := global_position.distance_to(target.global_position) < slam_radius + 10.0
			_set_mode(Mode.SLAM if close or randf() < 0.4 else Mode.SWEEP)
			Sfx.play(&"telegraph", -3.0)
		Mode.SWEEP:
			if _mode_time < _windup() * 0.6:
				_aim = (target.global_position - global_position).normalized()
			if _mode_time >= _windup() and not _struck:
				_struck = true
				_sweep_hit()
			if _mode_time >= _windup() + 0.6:
				_next()
		Mode.SLAM:
			if _mode_time >= _windup() and not _struck:
				_struck = true
				_slam_hit()
			if _mode_time >= _windup() + 0.8:
				_next()
		Mode.VENT:
			if fmod(_mode_time, 0.3) < delta:
				Fx.dust(global_position + Vector2(randf_range(-16, 16), -30), 3)
			if _mode_time >= vent_time:
				_next()


func _next() -> void:
	_set_mode(Mode.DECIDE)
	_mode_time = -0.4


func is_vented() -> bool:
	return mode == Mode.VENT


func _sweep_hit() -> void:
	Sfx.play(&"swing_heavy", 0.0)
	Sfx.play(&"clank", -4.0)
	Fx.shake(3.0, 0.2)
	if target == null:
		return
	var to_target := target.global_position - global_position
	var inside := to_target.length() <= sweep_reach and absf(rad_to_deg(_aim.angle_to(to_target))) <= sweep_angle * 0.5
	if inside:
		_hit_player(sweep_damage, 220.0, "Corrente")


func _slam_hit() -> void:
	Sfx.play(&"slam", 0.0)
	Fx.shake(5.0, 0.3)
	Fx.dust(global_position, 14)
	if target and target.global_position.distance_to(global_position) <= slam_radius:
		_hit_player(slam_damage, 240.0, "Pilão")
	var level := Level.find(self)
	if level:
		PlateCharge.spawn(get_parent(), level.plates_near(global_position, plate_ring.y, plate_ring.x), 0.55, plate_damage, self)


func _hit_player(damage: float, knockback: float, attack_name: String) -> void:
	var info := HitInfo.create(damage, global_position, target.global_position)
	info.knockback = knockback
	info.poise_damage = 40.0
	info.is_heavy = true
	info.attack_name = attack_name
	info.source = self
	target.hurtbox.receive_hit(info)


## A carcaça segura quase tudo; com as grades abertas, o núcleo sente.
func _incoming_damage_multiplier(_info: HitInfo) -> float:
	return core_damage_ratio if mode == Mode.VENT else shell_damage_ratio


func _on_damaged(_amount: float, _info: HitInfo, _blocked: bool) -> void:
	if mode != Mode.VENT:
		Sfx.play(&"clang", -8.0, 0.2)


func _can_be_staggered() -> bool:
	return false  # máquina presa ao chão


func _on_died() -> void:
	telegraph.clear()
	Sfx.play(&"quake", 0.0)
	Fx.shake(8.0, 1.2)
	Fx.vibrate(400)
	_defeat(SPEECH_DEFEAT)


# --- Visual --------------------------------------------------------------------------

func _after_move(_delta: float) -> void:
	var anim := &"idle"
	match mode:
		Mode.SWEEP, Mode.SLAM:
			anim = &"prepara" if _mode_time < _windup() else &"golpe"
		Mode.VENT:
			anim = &"vapor"
	if body_sprite.animation != anim:
		body_sprite.play(anim)
	if absf(_aim.x) > 0.1:
		body_sprite.flip_h = _aim.x < 0.0
	visual.position.x = sin(_mode_time * 50.0) * 0.8 if (mode != Mode.DECIDE and _mode_time < _windup()) else 0.0
	_update_telegraph()


func _update_telegraph() -> void:
	telegraph.circle_visible = false
	telegraph.arc_visible = false
	if mode == Mode.SWEEP and _mode_time < _windup():
		telegraph.arc_visible = true
		telegraph.arc_center = global_position
		telegraph.arc_direction = _aim
		telegraph.arc_radius = sweep_reach
		telegraph.arc_angle = deg_to_rad(sweep_angle)
		telegraph.arc_progress = _mode_time / _windup()
	elif mode == Mode.SLAM and _mode_time < _windup():
		telegraph.circle_visible = true
		telegraph.circle_center = global_position
		telegraph.circle_radius = slam_radius
		telegraph.circle_progress = _mode_time / _windup()
