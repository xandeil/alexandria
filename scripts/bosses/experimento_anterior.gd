class_name ExperimentoAnterior
extends Boss
## O Experimento Anterior — o último chefe no NG+ depois do final Proteger.
##
## É VOCÊ. O personagem da jornada passada se ajoelhou diante dela e ficou.
## Quando o próximo experimento chega ao Coração, quem guarda o Núcleo é ele:
## o mesmo rosto, as mesmas armas nas mãos, a mesma armadura (Game.guardian
## guarda a "foto" do momento do final). Ficou tanto tempo ali que a arma
## chegou ao máximo do Ferreiro.
##
## Ele luta como um jogador luta:
##   • COMBOS com a arma dele (os golpes vêm da própria WeaponData), forte e
##     especial; duas armas, duas mãos, escudo — o que ele usava, ele usa.
##   • DESVIA: viu você começar um golpe por perto, rola para o lado (com
##     invencibilidade, igual ao seu dash).
##   • SE CURA: com pouca vida e longe de você, bebe um frasco (bata nele
##     bebendo: o gole é perdido).
##   • ESCUDO: se tinha um, ergue quando você chega e responde.
##   • ARCO/BESTA: guarda distância e atira.
## Na METADE da vida o Núcleo o escolhe de novo (fase 2): fica dourado, mais
## rápido, ganha um frasco, faz cair pedras de luz e solta anéis de gravidade
## — os poderes do Cavaleiro que ele substituiu.
##
## O número de "inteligência" mora nos @export (chance de desviar, distância
## para curar...). Nada de mágica escondida no meio do código.

enum Mode { DECIDE, APPROACH, STRAFE, ATTACK, ROLL, HEAL, GUARD, SHOOT, TRANSITION, DEAD }

const SPEECH_INTRO := "Eu também acordei numa cápsula. Também achei uma arma no chão."
const SPEECH_PHASE_2 := "Ela me escolheu uma vez. Vai me escolher de novo."
const SPEECH_HEAL := "(Ele bebe. Você conhece esse gesto.)"
const SPEECH_DEFEAT := "...Agora é você que fica."
## Os golpes do herói (para quem luta de mãos vazias ou com arma sem golpes próprios).
const BASE_COMBO: Array[AttackData] = [
	preload("res://data/attacks/player_light_1.tres"),
	preload("res://data/attacks/player_light_2.tres"),
	preload("res://data/attacks/player_light_3.tres"),
]
const BASE_HEAVY := preload("res://data/attacks/player_heavy.tres")
## O dano dele em relação ao que VOCÊ faria com a mesma build (o NG+ soma por cima).
const DAMAGE_RATIO := 0.8
## Arma "tunada": o reforço máximo do Ferreiro.
const WEAPON_DAMAGE_PER_LEVEL := 0.12

@export_group("Inteligência")
@export_range(0.0, 1.0) var dodge_chance := 0.55
@export_range(0.0, 1.0) var dodge_chance_phase_2 := 0.8
@export var dodge_range := 62.0
@export var roll_speed := 240.0
@export var roll_time := 0.32
@export var roll_cooldown := 1.1
## Cura abaixo destas frações da vida (na fase 1 a vida só vai até a metade).
@export_range(0.0, 1.0) var heal_below := 0.65
@export_range(0.0, 1.0) var heal_below_phase_2 := 0.4
@export var heal_distance := 70.0
@export var heal_time := 1.1
@export_range(0.0, 1.0) var heal_ratio := 0.25
@export var heal_cooldown := 5.0
@export var reach_to_attack := 34.0
@export var shoot_distance := 110.0

@export_group("Fase 2 — O Núcleo")
@export var stones_every := 8.0
@export var stone_count := 4
@export var stone_damage := 24.0
@export var stone_radius := 18.0
@export var repel_every := 10.0
@export var repel_damage := 16.0

@onready var weapon_pivot: Node2D = $Visual/WeaponPivot
@onready var weapon_sprite: Sprite2D = $Visual/WeaponPivot/Weapon
@onready var off_sprite: Sprite2D = $Visual/OffPivot/OffWeapon
@onready var shield_sprite: Sprite2D = $Visual/Shield

var build := {}
var right: WeaponData
var left: WeaponData
var has_shield := false
var two_hands := false
var attributes := {}
var flasks := 3
var phase := 1
var mode := Mode.DECIDE
var woman: Node2D

var _mode_time := 0.0
var _combo: Array[AttackData] = []
var _combo_index := 0
var _hand: WeaponData
var _roll_dir := Vector2.ZERO
var _roll_left := 0.0
var _roll_cd := 0.0
var _strafe_side := 1.0
var _reacted := false
var _heal_left := 0.0
var _heal_cd := 0.0
var _heal_done := false
var _stones_timer := 3.0
var _repel_timer := 6.0
var _attacks := 0
var _swing_from := 0.0
var _swing_to := 0.0
var _reach_mult := 1.0
var _damage_mult := 1.0
var _attack_time := 1.0


func _ready() -> void:
	_read_build()
	super._ready()  # (aqui o NG+ multiplica a vida)


## Lê a "foto" do experimento anterior (Game.guardian) e monta o lutador.
func _read_build() -> void:
	build = Game.guardian
	attributes = build.get("atributos", {})
	right = Items.get_weapon(str(build.get("direita", Game.FISTS)))
	if right == null:
		right = Items.get_weapon(Game.FISTS)
	var left_id := str(build.get("esquerda", ""))
	has_shield = left_id == Game.SHIELD
	left = Items.get_weapon(left_id)
	two_hands = bool(build.get("duas_maos", false)) and not right.ranged
	flasks = clampi(int(build.get("frascos", 3)), 2, 6)
	stats.health_scale = 1.0 + _armor_bonus("vida")
	stats.regen_bonus = 1.0 + _armor_bonus("folego")
	move_speed *= 1.0 + _armor_bonus("passo")
	_reach_mult = 1.0 + _armor_bonus("alcance")
	var tuned := 1.0 + WEAPON_DAMAGE_PER_LEVEL * Game.WEAPON_UPGRADES.size()
	_damage_mult = DAMAGE_RATIO * tuned * (1.0 + _armor_bonus("forca"))
	body_sprite.sprite_frames = Appearance.sprite_frames(build.get("aparencia", {}))
	body_sprite.play(&"idle")
	_dress_hands()


## O mesmo cálculo do Game.armor_bonus, mas com a armadura DELE.
func _armor_bonus(effect: String) -> float:
	var total := 0.0
	var worn: Dictionary = build.get("armadura", {})
	for slot in ArmorData.SLOTS:
		var piece := Items.get_armor(str(worn.get(slot, "")))
		if piece and ArmorSets.effect_of(piece.set_id) == effect:
			total += ArmorSets.per_piece(piece.set_id)
	return total


func _dress_hands() -> void:
	weapon_sprite.texture = right.hand_texture
	if right.hand_texture:
		weapon_sprite.offset = Vector2(right.hand_texture.get_width() * 0.5 - 2.0, 0.0)
	off_sprite.texture = left.hand_texture if left else null
	if left and left.hand_texture:
		off_sprite.offset = Vector2(left.hand_texture.get_width() * 0.5 - 2.0, 0.0)
	shield_sprite.visible = has_shield


# --- Boss -----------------------------------------------------------------------------

func display_name() -> String:
	return "O Experimento Anterior"


func display_title() -> String:
	var label := Game.cycle_label(int(build.get("ciclo", 0)))
	return "Guardião do Núcleo" + (" · era do %s" % label if not label.is_empty() else "")


func phase_label() -> String:
	return "Você" if phase == 1 else "O Núcleo o escolhe"


func victory_subtitle() -> String:
	return "O Experimento Anterior — Proteção que virou prisão"


func enter_arena(_landing: Vector2) -> void:
	visible = true
	ready_to_fight.emit()


func start_fight() -> void:
	super.start_fight()
	speech.emit(SPEECH_INTRO)
	Sfx.play(&"bell", -6.0)
	_go_decide(0.8)


func _set_mode(new_mode: Mode) -> void:
	mode = new_mode
	_mode_time = 0.0


func _go_decide(delay: float) -> void:
	_set_mode(Mode.DECIDE)
	_mode_time = -delay


# --- Ciclo ------------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	_mode_time += delta
	if dead:
		velocity = Vector2.ZERO
		_update_visual(delta)
		return
	if woman == null or not is_instance_valid(woman):
		woman = get_tree().get_first_node_in_group(&"nucleo_core") as Node2D
	target = find_target()
	_roll_cd -= delta
	_heal_cd -= delta
	if active and phase == 1 and mode != Mode.TRANSITION and stats.health_ratio() <= 0.5:
		_enter_core_phase()
	if active and target and not target.is_dead():
		regen_poise(delta)
		_watch_player()
		if phase == 2:
			_stones_timer -= delta
			_repel_timer -= delta
		match mode:
			Mode.DECIDE:
				velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
				if _mode_time >= 0.0:
					_decide()
			Mode.APPROACH:
				_approach(delta)
			Mode.STRAFE:
				_strafe(delta)
			Mode.ATTACK, Mode.SHOOT:
				velocity = _runner.step(delta, velocity)
			Mode.ROLL:
				_roll(delta)
			Mode.HEAL:
				_heal(delta)
			Mode.GUARD:
				velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
				facing = (target.global_position - global_position).normalized()
				if _mode_time >= 1.0:
					_start_combo()  # abaixou o escudo: responde
			Mode.TRANSITION:
				velocity = Vector2.ZERO
	else:
		velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	move_and_slide()
	_update_visual(delta)


# --- Decidir ----------------------------------------------------------------------------

func _decide() -> void:
	var to_target := target.global_position - global_position
	var distance := to_target.length()
	facing = to_target.normalized()
	if _wants_heal(distance):
		_start_heal()
		return
	if phase == 2:
		if _stones_timer <= 0.0:
			_rain_light()
			return
		if _repel_timer <= 0.0 and distance < 80.0:
			_repel()
			return
	if right.ranged:
		if distance < 60.0 and _roll_cd <= 0.0:
			_start_roll(-facing)  # perto demais para atirar: abre distância
			return
		_start_shot()
		return
	if distance <= reach_to_attack * _reach_mult:
		if has_shield and randf() < 0.35:
			_set_mode(Mode.GUARD)
			Sfx.play(&"shield_up", -4.0)
			return
		_start_combo()
		return
	if distance < 90.0 and randf() < 0.35:
		_strafe_side = 1.0 if randf() < 0.5 else -1.0
		_set_mode(Mode.STRAFE)  # rodeia, esperando você errar
		return
	_set_mode(Mode.APPROACH)


func _approach(delta: float) -> void:
	var to_target := target.global_position - global_position
	facing = to_target.normalized()
	velocity = velocity.move_toward(facing * move_speed, acceleration * delta)
	if to_target.length() <= reach_to_attack * _reach_mult or _mode_time >= 1.6:
		_go_decide(0.0)


## Anda de lado em volta de você, a meia distância.
func _strafe(delta: float) -> void:
	var to_target := target.global_position - global_position
	facing = to_target.normalized()
	var side := facing.orthogonal() * _strafe_side
	var keep := facing * (to_target.length() - 64.0) * 0.8
	velocity = velocity.move_toward((side * move_speed * 0.8 + keep).limit_length(move_speed), acceleration * delta)
	if _mode_time >= 1.0:
		_go_decide(0.0)


# --- Golpes -----------------------------------------------------------------------------

func _start_combo() -> void:
	_hand = right
	if left and not left.ranged and randf() < 0.4:
		_hand = left  # duas armas: às vezes abre com a esquerda
	_combo = _hand.light_combo if not _hand.light_combo.is_empty() else BASE_COMBO
	var heavy := _hand.heavy_attack if _hand.heavy_attack else BASE_HEAVY
	var roll := randf()
	if phase == 2 and _hand.special_attack and roll < 0.3:
		_combo = [_hand.special_attack]
	elif roll < 0.25:
		_combo = [heavy]
	elif randf() < 0.5:
		_combo = _combo.slice(0, mini(_combo.size(), 2 if phase == 1 else 3))
	_combo_index = 0
	_next_cut()


func _next_cut() -> void:
	if _combo_index >= _combo.size() or target == null:
		_go_decide(0.45 if phase == 1 else 0.25)
		return
	_set_mode(Mode.ATTACK)
	facing = (target.global_position - global_position).normalized()
	start_attack(_combo[_combo_index], facing, _hand.speed_scale * _attack_speed())
	_setup_swing(_combo[_combo_index])
	_combo_index += 1


func _attack_speed() -> float:
	return 1.0 if phase == 1 else 0.82


## Os golpes dele vão mais longe com a Couraça do Eco (igual aos seus).
func start_attack(attack: AttackData, direction: Vector2, speed_multiplier: float = 1.0) -> void:
	super.start_attack(attack, direction, speed_multiplier)
	(hitbox_shape.shape as CircleShape2D).radius = attack.radius * (1.0 + (_reach_mult - 1.0) * 0.8)
	hitbox_shape.position = Vector2(attack.reach * _reach_mult, 0.0)


func _activate_hitbox() -> void:
	if mode == Mode.SHOOT:
		return  # o tiro é o projétil, não a hitbox de perto
	hitbox.activate_with(_current_attack, attack_damage(_current_attack, _hand))
	_attacks += 1
	if phase == 2 and _current_attack.is_heavy:
		# Fase 2: o golpe forte solta um anel de luz em volta (o dash atravessa).
		var ring := ScreamRing.launch(get_parent(), global_position + Vector2(0, -8), self, repel_damage * 0.8, 170.0, 90.0)
		ring.knockback = 200.0


## Dano de um golpe: a SUA fórmula (arma × letras de escala × reforço máximo ×
## armadura de força) com os atributos dele.
func attack_damage(attack: AttackData, hand: WeaponData = null) -> float:
	var data := hand if hand else right
	var damage := attack.damage * data.damage_scale * data.scaling_multiplier(attributes) * _damage_mult
	if two_hands and data == right:
		damage *= 1.5
	return damage


func _on_attack_finished() -> void:
	match mode:
		Mode.ATTACK:
			if target and global_position.distance_to(target.global_position) <= reach_to_attack * _reach_mult * 1.5:
				_next_cut()
			else:
				_go_decide(0.4)
		Mode.SHOOT:
			_go_decide(0.5 if phase == 1 else 0.3)


func track_target_during_windup() -> void:
	pass


## Arco e besta: mira e atira um projétil de verdade (o seu escudo segura).
func _start_shot() -> void:
	_hand = right
	var attack := right.heavy_attack if randf() < 0.3 and right.heavy_attack else \
		(right.light_combo[0] if not right.light_combo.is_empty() else BASE_COMBO[0])
	_set_mode(Mode.SHOOT)
	facing = (target.global_position - global_position).normalized()
	start_attack(attack, facing, right.speed_scale * _attack_speed())
	hitbox.deactivate()
	_setup_swing(attack)
	var aim := facing
	var damage := attack_damage(attack)
	_shoot_after(attack.windup_time * right.speed_scale * _attack_speed(), aim, damage)


func _shoot_after(seconds: float, aim: Vector2, damage: float) -> void:
	await wait(seconds)
	if dead or mode != Mode.SHOOT or target == null:
		return
	aim = (target.global_position - global_position).normalized() if phase == 2 else aim  # fase 2: corrige a mira
	Projectile.launch(get_parent(), global_position + Vector2(0, -8) + aim * 8.0, aim, self, damage, 230.0,
		shoot_distance * 2.6 * _reach_mult)
	Sfx.play(&"swing_small", -4.0)


# --- Esquiva, cura, escudo ----------------------------------------------------------------

## Viu você começar um golpe por perto? Rola (às vezes). Uma reação por golpe.
func _watch_player() -> void:
	var attacking := target.state == Player.State.ATTACK
	if not attacking:
		_reacted = false
		return
	if _reacted or not (mode in [Mode.DECIDE, Mode.APPROACH, Mode.STRAFE, Mode.SHOOT, Mode.GUARD]):
		return
	_reacted = true
	if global_position.distance_to(target.global_position) > dodge_range or _roll_cd > 0.0:
		return
	if randf() < (dodge_chance if phase == 1 else dodge_chance_phase_2):
		var away := (global_position - target.global_position).normalized()
		var side := away.orthogonal() * (1.0 if randf() < 0.5 else -1.0)
		_start_roll((away * 0.6 + side).normalized())


func _start_roll(direction: Vector2) -> void:
	_runner.cancel()
	hitbox.deactivate()
	_roll_dir = direction if direction != Vector2.ZERO else Vector2.LEFT
	_roll_left = roll_time
	_roll_cd = roll_time + roll_cooldown
	hurtbox.invulnerable = true
	_set_mode(Mode.ROLL)
	Sfx.play(&"dash", -3.0)
	Fx.dust(global_position, 6)


func _roll(delta: float) -> void:
	var t := 1.0 - _roll_left / roll_time
	velocity = _roll_dir * roll_speed * (1.0 - t * t * 0.7)
	_roll_left -= delta
	if _roll_left <= roll_time * 0.2:
		hurtbox.invulnerable = false
	if _roll_left <= 0.0:
		hurtbox.invulnerable = false
		_go_decide(0.15)


func _wants_heal(distance: float) -> bool:
	var threshold := heal_below if phase == 1 else heal_below_phase_2
	return flasks > 0 and stats.health_ratio() < threshold and distance >= heal_distance and _heal_cd <= 0.0


func _start_heal() -> void:
	_heal_left = heal_time
	_heal_cd = heal_time + heal_cooldown
	_heal_done = false
	_set_mode(Mode.HEAL)
	speech.emit(SPEECH_HEAL)


func _heal(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	_heal_left -= delta
	if not _heal_done and _heal_left <= heal_time * 0.45:
		_heal_done = true
		flasks -= 1
		stats.set_health(minf(stats.health + stats.max_health * heal_ratio, stats.max_health))
		Sfx.play(&"heal", -2.0)
		Fx.splash(global_position + Vector2(0, -12), Color(1.0, 0.35, 0.3), 10)
	if _heal_left <= 0.0:
		_go_decide(0.2)


## Apanhou bebendo antes do gole: perdeu o frasco (igual a você).
func _on_damaged(_amount: float, _info: HitInfo, blocked: bool) -> void:
	if mode == Mode.HEAL and not _heal_done:
		flasks -= 1
		_heal_done = true
		_go_decide(0.3)
	if blocked and mode == Mode.GUARD:
		_start_combo()  # bateu no escudo: contragolpe


func _incoming_damage_multiplier(info: HitInfo) -> float:
	if mode != Mode.GUARD:
		return 1.0
	var toward := info.source_position - global_position
	return 0.15 if absf(rad_to_deg(facing.angle_to(toward))) <= 75.0 else 1.0


func _can_be_staggered() -> bool:
	return mode in [Mode.DECIDE, Mode.APPROACH, Mode.STRAFE, Mode.HEAL]


func _on_poise_broken(_info: HitInfo) -> void:
	_go_decide(stagger_time)


# --- Fase 2: o Núcleo -------------------------------------------------------------------

func _enter_core_phase() -> void:
	phase = 2
	_runner.cancel()
	hitbox.deactivate()
	_set_mode(Mode.TRANSITION)
	hurtbox.invulnerable = true
	phase_changed.emit(phase_label())
	speech.emit(SPEECH_PHASE_2)
	Sfx.play(&"boss_phase")
	Sfx.play(&"bell", -2.0)
	Fx.shake(4.0, 0.8)
	flasks += 1
	move_speed *= 1.15
	_stones_timer = 2.5
	_repel_timer = 6.0
	var glow := create_tween()
	glow.tween_property(visual, "modulate", Color(1.5, 1.35, 0.9), 1.6)
	await wait(2.2)
	if dead:
		return
	hurtbox.invulnerable = false
	_go_decide(0.2)


## Pedras de luz caem do alto (uma sempre em você).
func _rain_light() -> void:
	_stones_timer = stones_every
	for i in stone_count:
		var at := target.global_position
		if i > 0:
			at += Vector2.from_angle(TAU * i / stone_count + randf()) * randf_range(28.0, 64.0)
		if arena_rect.size != Vector2.ZERO:
			at = clamp_to_arena(at, 16.0)
		FleshBurst.spawn(get_parent(), at, stone_radius, 1.0 + i * 0.12, stone_damage, self, false,
			at + Vector2(randf_range(-20.0, 20.0), -150.0), "pedra")
	Sfx.play(&"gravity", -4.0, 0.1)
	_go_decide(0.5)


func _repel() -> void:
	_repel_timer = repel_every
	var ring := ScreamRing.launch(get_parent(), global_position + Vector2(0, -10), self, repel_damage, 150.0, 170.0)
	ring.knockback = 280.0
	Sfx.play(&"gravity", 0.0)
	Fx.shake(4.0, 0.4)
	_go_decide(0.6)


# --- Morte --------------------------------------------------------------------------------

func _on_died() -> void:
	if phase == 1:
		stats.revive()
		stats.set_health(stats.max_health * 0.5)  # dano enorme não pula o Núcleo
		_enter_core_phase()
		return
	dead = true
	active = false
	_set_mode(Mode.DEAD)
	_runner.cancel()
	hitbox.deactivate()
	remove_from_group("enemies")
	hurtbox.set_deferred("monitorable", false)
	set_deferred("collision_layer", 0)
	for burst in get_tree().get_nodes_in_group("flesh_bursts"):
		burst.queue_free()
	speech.emit(SPEECH_DEFEAT)
	if data:
		Game.mark_boss_defeated(data.id)  # "cavaleiro": a escolha diante dela se abre
	Sfx.play(&"boss_phase")
	Sfx.play(&"bell", -2.0)
	Fx.slow_motion(0.25, 0.9)
	var fade := create_tween()
	fade.tween_property(visual, "modulate", Color(1.0, 1.0, 1.0, 0.35), 1.5)
	fight_won.emit(self)


# --- Visual -------------------------------------------------------------------------------

func _setup_swing(attack: AttackData) -> void:
	var base := facing.angle()
	var half := deg_to_rad(attack.slash_arc_degrees) * 0.5
	_swing_from = base - half
	_swing_to = base + half


func _update_visual(delta: float) -> void:
	if absf(facing.x) > 0.1:
		body_sprite.flip_h = facing.x < 0.0
	var anim := &"walk" if velocity.length() > 8.0 else &"idle"
	if body_sprite.animation != anim:
		body_sprite.play(anim)
	# Rolando: gira o corpo (o mesmo "rolamento" do dash do herói).
	if mode == Mode.ROLL:
		visual.rotation = TAU * (1.0 - _roll_left / roll_time) * (1.0 if _roll_dir.x >= 0.0 else -1.0)
	else:
		visual.rotation = 0.0
	var angle := facing.angle() + PI * 0.35 * (1.0 if facing.x >= 0.0 else -1.0)
	if mode == Mode.ATTACK or mode == Mode.SHOOT:
		match _runner.phase:
			AttackRunner.Phase.WINDUP:
				angle = _swing_from
			AttackRunner.Phase.LUNGE, AttackRunner.Phase.ACTIVE:
				angle = lerp_angle(_swing_from, _swing_to, _runner.phase_progress())
			_:
				angle = _swing_to
		weapon_pivot.rotation = angle
	else:
		weapon_pivot.rotation = lerp_angle(weapon_pivot.rotation, angle, minf(12.0 * delta, 1.0))
	weapon_sprite.flip_v = cos(weapon_pivot.rotation) < 0.0
	weapon_pivot.z_index = -1 if sin(weapon_pivot.rotation) < -0.35 else 1
	shield_sprite.flip_h = body_sprite.flip_h
	shield_sprite.position = Vector2(-6 if facing.x >= 0.0 else 6, -6) if mode != Mode.GUARD else facing * 7.0 + Vector2(0, -7)
