class_name Player
extends CharacterBody2D
## O protagonista: uma cobaia do Projeto Alexandria que acordou sem memórias.
##
## ARQUITETURA — Máquina de Estados Finita (FSM):
## em cada momento o herói está em UM estado, e cada estado tem sua função.
## Isso elimina o "inferno de booleanos" (is_attacking && !is_dashing && ...)
## que todo iniciante acaba criando — e que gera bugs como atacar no meio do dash.
##
##   FREE ──atacar──► ATTACK ──fim──► FREE
##     │ └─dash────► DASH   ──fim──► FREE
##     │ └─cura────► HEAL / SANITY ─► FREE
##     └─levou golpe──► STAGGER ─────► FREE        (qualquer estado) ──► DEAD
##     └─segurou defesa (com escudo) ► BLOCK ─soltou─► FREE
##     └─Sonolência cheia (pólen do Bosque) ► SLEEP ─2,5 s ou levou golpe─► FREE
##                                     └─sem estamina no golpe ► STAGGER longo (guarda quebrada)
##     └─pisou num buraco ► FALL ──(volta à borda, perde vida)──► FREE
##     └─agarrado (Boca de Raiz, Mabel) ► GRABBED ─toques em Ataque─► FREE
##
## COMBATE "STEP AND ANCHOR": quem executa o golpe é o AttackRunner (o mesmo dos
## inimigos). Aqui só decidimos QUAL golpe sai e reagimos às fases dele.
##
## CONTROLES: o Player só conhece AÇÕES ("attack", "dash"...), nunca a origem.
## O joystick virtual, os botões de toque e o teclado apertam as mesmas ações.

signal health_flasks_changed(current: int, maximum: int)
signal interact_target_changed(target: Interactable)
signal stamina_denied
signal hurt(amount: float)
signal died
## Golpe segurado pelo escudo (testes e efeitos escutam).
signal blocked(info: HitInfo)
signal guard_broken
signal drowsiness_changed(current: float, maximum: float)
signal sleep_changed(asleep: bool)
## Agarrado (true) ou solto (false). taps_needed = toques em Ataque para escapar.
signal grab_changed(grabbed: bool, taps_needed: int)
signal grab_progress(taps: int, taps_needed: int)
## O herói USOU uma ação (&"leve", &"forte", &"dash", &"cura", &"escudo").
## Durgan conta isso durante a luta e, na fase 2, copia o que você mais usou.
signal action_used(action: StringName)

enum State { FREE, ATTACK, DASH, HEAL, SANITY, STAGGER, LOCKED, DEAD, FALL, BLOCK, SLEEP, GRABBED }

## Ações de comando (o movimento fica de fora: andar logo após o diálogo é normal).
const INPUT_ACTIONS: Array[StringName] = [&"attack", &"attack_heavy", &"dash", &"heal", &"sanity", &"block"]
## Estados "com os pés no chão": só neles dá para cair num buraco. No DASH o herói
## está no ar — é assim que se atravessa um buraco.
const GROUNDED_STATES := [State.FREE, State.ATTACK, State.HEAL, State.SANITY, State.STAGGER, State.BLOCK, State.SLEEP]

## Ângulo da espada em repouso (abaixada, apontando para frente e para baixo).
const IDLE_SWORD_ANGLE := 1.15

@export_group("Movimento")
@export var move_speed := 80.0
## Quão rápido atinge a velocidade — dá peso ao andar.
@export var acceleration := 900.0
## Quão rápido para ao soltar o joystick.
@export var friction := 1100.0
## Exausto anda mais devagar: o corpo sente o cansaço.
@export_range(0.1, 1.0) var exhausted_speed_multiplier := 0.7

@export_group("Ataques")
## Combo de golpes leves (toque rápido). Cada um é um AttackData (.tres).
@export var light_combo: Array[AttackData] = []
## Golpe forte (segurar o botão de ataque).
@export var heavy_attack: AttackData
## Segurar por mais que isso = golpe forte.
@export var heavy_hold_time := 0.25
## Mira assistida: no touch não existe mira precisa, então o golpe "puxa"
## para o inimigo mais próximo dentro de um cone à frente.
@export var soft_aim_range := 72.0
@export var soft_aim_angle := 75.0
## Aceita o próximo comando um pouco antes de poder executá-lo.
## Sem isso, o toque parece "comido" pelo jogo.
@export var input_buffer_time := 0.2

@export_group("Dash (esquiva)")
@export var dash_stamina_cost := 22.0
@export var dash_speed := 250.0
@export var dash_time := 0.26
## Janela de invencibilidade (i-frames) no começo do dash.
@export var dash_iframe_time := 0.18
@export var dash_recovery_time := 0.08
## Passar por dentro dos inimigos durante o dash (paredes continuam sólidas).
@export var dash_through_enemies := true

@export_group("Frasco de Vida")
@export var heal_amount := 45.0
@export var heal_time := 0.9
## Em que fração da animação a vida volta (antes disso, um golpe desperdiça o frasco).
@export_range(0.0, 1.0) var heal_apply_at := 0.55
@export_range(0.0, 1.0) var heal_move_multiplier := 0.35

@export_group("Frasco de Sanidade")
@export var sanity_time := 1.1
@export_range(0.0, 1.0) var sanity_apply_at := 0.6

@export_group("Escudo (mão esquerda)")
## Metade do ângulo protegido pela frente (70 = um cone de 140°).
@export var block_angle := 70.0
## Quanto do dano o escudo segura (0.85 = passam 15%, o "dano de raspão").
@export_range(0.0, 1.0) var shield_absorption := 0.85
## Estamina gasta por ponto de dano segurado.
@export var block_stamina_per_damage := 1.1
## Golpe pesado cansa mais o braço.
@export var block_heavy_extra := 8.0
## Andar com o escudo erguido é devagar.
@export_range(0.1, 1.0) var block_move_multiplier := 0.45
## Erguido, o escudo regenera a estamina mais devagar (não dá para "morar" atrás dele).
@export_range(0.0, 1.0) var block_regen_multiplier := 0.35
## Radianos por segundo que o escudo gira para a ameaça.
@export var block_turn_speed := 10.0
## O escudo vira sozinho para o inimigo mais próximo dentro desta distância
## (no touch não dá para "mirar" o escudo com precisão).
@export var block_face_range := 110.0
## Guarda quebrada: cambaleio longo — é a janela do inimigo.
@export var guard_break_time := 0.9
@export_range(0.0, 1.0) var guard_break_damage_ratio := 0.5

@export_group("Sono (Barra de Sonolência)")
## Bíblia (Nyssa): "Uma Barra de Sonolência sobe [...] Cheia, ele adormece por
## 2 a 3 segundos. Atacar faz a barra descer, então a luta obriga o jogador a
## ser agressivo." O pólen do Bosque usa a mesma barra.
@export var drowsiness_max := 100.0
## Quanto a barra desce sozinha por segundo (longe do pólen).
@export var drowsiness_decay := 9.0
## Cada golpe desferido espanta o sono.
@export var drowsiness_attack_relief := 14.0
@export var sleep_time := 2.5
## Com sono, o corpo pesa: na barra cheia anda a esta fração da velocidade
## ("o bosque luta por ela com pólen, sonâmbulos e LENTIDÃO").
@export_range(0.1, 1.0) var drowsy_speed_multiplier := 0.6
## Depois de acordar, um respiro antes de o sono poder subir de novo.
@export var sleep_grace := 1.5

@export_group("Barulho (furtividade)")
## Raio do barulho de cada ação. Sonâmbulos e o Vigia "ouvem" quem está dentro.
@export var noise_dash := 72.0
@export var noise_attack := 80.0
@export var noise_heavy := 110.0
@export var noise_hit := 96.0
## Andar RÁPIDO (joystick quase todo) faz barulho; andar devagar, não.
@export var noise_run := 44.0
@export_range(0.0, 1.0) var noise_run_threshold := 0.65

@export_group("Dano recebido")
@export var stagger_time := 0.3
## Invencibilidade curta após levar dano (evita "travar" no meio de 3 soldados).
@export var hurt_iframes := 0.4

@export_group("Queda (buracos da arena)")
@export var fall_time := 0.55
## Cair custa uma fração da vida máxima (com um mínimo).
@export_range(0.0, 1.0) var fall_damage_ratio := 0.2
@export var fall_min_damage := 15.0
@export var fall_iframes := 1.0

@export_group("Agarrão (preso)")
## Depois de se soltar: invencível por um instante (senão o mesmo braço agarra de novo).
@export var grab_escape_iframes := 0.7
## Empurrão para longe de quem agarrava, ao escapar.
@export var grab_escape_push := 170.0

@onready var stats: StatsComponent = $Stats
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var hitbox: Hitbox = $HitboxPivot/Hitbox
@onready var hitbox_pivot: Node2D = $HitboxPivot
@onready var hitbox_shape: CollisionShape2D = $HitboxPivot/Hitbox/CollisionShape2D
@onready var visual: Node2D = $Visual
@onready var body_sprite: AnimatedSprite2D = $Visual/Body
@onready var weapon_pivot: Node2D = $Visual/WeaponPivot
@onready var sword: Sprite2D = $Visual/WeaponPivot/Sword
@onready var shield_sprite: Sprite2D = $Visual/Shield
@onready var interaction_area: Area2D = $InteractionArea

var state := State.FREE
var facing := Vector2.RIGHT
var health_flasks := 3
var health_flasks_max := 3

var _runner := AttackRunner.new()
var _current_attack: AttackData
var _combo_index := 0
var _combo_grace := 0.0
var _state_time := 0.0
var _dash_dir := Vector2.RIGHT
var _effect_applied := false
var _buffered: StringName = &""
var _buffer_left := 0.0
var _attack_held := false
var _attack_hold_time := 0.0
var _heavy_fired := false
var _iframes_left := 0.0
var _interactable: Interactable
var _anim_time := 0.0
var _walk_phase := 0.0
var _afterimage_timer := 0.0
var _swing_from := 0.0
var _swing_to := 0.0
var _swing_reverse := false
## Ao destravar (fim de diálogo/menu), ignora as teclas que AINDA estão apertadas:
## a mesma tecla que fechou o diálogo (E, J, Espaço) não pode virar cura, golpe ou dash.
var _held_on_unlock: Array[StringName] = []
var _input_grace_frames := 0
## Último ponto seguro (longe de buracos): é para onde a queda devolve o herói.
var _last_safe_position := Vector2.ZERO
var _fall_tween: Tween
## A queda do Prólogo: sem borda para voltar — quem cuida do visual é o tween.
var _plunging := false
## Duração do STAGGER atual (golpe comum × guarda quebrada).
var _stagger_duration := 0.3
## Tranco visual do escudo ao segurar um golpe (s).
var _shield_recoil := 0.0
## Barra de Sonolência (0 = desperto).
var drowsiness := 0.0
var _sleep_grace_left := 0.0
var _zzz_timer := 0.0
## Raio do barulho AGORA (some rápido). Veja make_noise() e is_heard_from().
var noise := 0.0
## Quem está segurando o herói (estado GRABBED) e as regras desse agarrão.
var _grabber: Node2D
var _grab_offset := Vector2.ZERO
var _grab_taps := 0
var _grab_needed := 6
var _grab_damage_per_second := 0.0
var _grab_drain_ratio := 0.0
var _grab_drain_min := 0
var _grab_tick := 0.0
var _grab_hidden := false


func _ready() -> void:
	add_to_group("player")
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING  # top-down: sem chão/parede
	hitbox_shape.shape = hitbox_shape.shape.duplicate()  # forma própria (muda por golpe)
	hitbox.source = self
	hurtbox.owner_body = self
	_runner.phase_changed.connect(_on_attack_phase_changed)
	hitbox.hit_landed.connect(_on_hit_landed)
	hurtbox.hit_received.connect(_on_hit_received)
	stats.died.connect(_on_died)
	body_sprite.material = body_sprite.material.duplicate()
	_last_safe_position = global_position
	var ring := NoiseRing.new()
	ring.player = self
	add_child(ring)
	apply_progress(true)


## Lê atributos e frascos do Game (save) para o herói.
func apply_progress(refill: bool) -> void:
	stats.apply_attributes(Game.attributes, refill)
	var gained := Game.health_flasks_max - health_flasks_max
	health_flasks_max = Game.health_flasks_max
	if refill:
		health_flasks = health_flasks_max
	elif gained > 0:
		health_flasks += gained  # o Orbe purificou um fragmento: o frasco novo já vem cheio
	health_flasks_changed.emit(health_flasks, health_flasks_max)
	_update_death_marks()


## Câmara de descanso: vida, estamina e frascos de volta.
func rest() -> void:
	_runner.cancel()
	stats.revive()
	health_flasks = health_flasks_max
	health_flasks_changed.emit(health_flasks, health_flasks_max)
	if state != State.LOCKED:  # durante o descanso a fase mantém o herói travado
		_set_state(State.FREE)


## Trava/destrava o controle (diálogos, menus, descanso, portas).
func lock_input(locked: bool) -> void:
	if state == State.DEAD or _plunging:
		return
	if state == State.FALL:
		_finish_fall()  # termina a queda antes (volta para a borda)
		if state == State.DEAD:
			return
	if locked:
		_runner.cancel()
		_set_state(State.LOCKED)
	elif state == State.LOCKED:
		_set_state(State.FREE)
		_clear_input()
		_input_grace_frames = 2
		_held_on_unlock.clear()
		for action: StringName in INPUT_ACTIONS:
			if Input.is_action_pressed(action):
				_held_on_unlock.append(action)


func is_dead() -> bool:
	return state == State.DEAD


# --- Loop principal -------------------------------------------------------------

func _physics_process(delta: float) -> void:
	_state_time += delta
	_anim_time += delta
	_combo_grace = maxf(_combo_grace - delta, 0.0)
	_iframes_left = maxf(_iframes_left - delta, 0.0)
	_update_drowsiness(delta)
	noise = move_toward(noise, 0.0, 260.0 * delta)
	_read_input(delta)

	match state:
		State.FREE:
			_state_free(delta)
		State.ATTACK:
			_state_attack(delta)
		State.DASH:
			_state_dash(delta)
		State.HEAL:
			_state_heal(delta)
		State.SANITY:
			_state_sanity(delta)
		State.STAGGER:
			_state_stagger(delta)
		State.FALL:
			_state_fall(delta)
		State.BLOCK:
			_state_block(delta)
		State.SLEEP:
			_state_sleep(delta)
		State.GRABBED:
			_state_grabbed(delta)
		State.LOCKED, State.DEAD:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	move_and_slide()  # colisão sólida: o corpo nunca atravessa o mundo
	_check_pits()
	hurtbox.invulnerable = _is_invulnerable()
	_update_interactable()
	_update_visuals(delta)


func _set_state(new_state: State) -> void:
	_exit_state(state)
	state = new_state
	_state_time = 0.0
	_effect_applied = false


## Limpeza ao SAIR de um estado: garante que nada "vaze" (ex.: levar um golpe
## no meio do ataque não deixa a hitbox ligada para sempre).
func _exit_state(old_state: State) -> void:
	match old_state:
		State.ATTACK:
			hitbox.deactivate()
		State.DASH:
			set_collision_mask_value(3, true)  # volta a colidir com inimigos
		State.BLOCK:
			stats.regen_scale = 1.0  # abaixou o escudo: estamina volta ao ritmo normal
		State.GRABBED:
			_end_grab()
		State.SLEEP:
			drowsiness = 0.0
			_sleep_grace_left = sleep_grace
			drowsiness_changed.emit(drowsiness, drowsiness_max)
			sleep_changed.emit(false)


func _is_invulnerable() -> bool:
	if state == State.DEAD or state == State.FALL or _plunging or _iframes_left > 0.0:
		return true
	return state == State.DASH and _state_time < dash_iframe_time


# --- Input (com buffer) --------------------------------------------------------------

func _move_input() -> Vector2:
	# get_vector preserva a intensidade analógica: joystick meio inclinado = anda devagar.
	return Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")


func _read_input(delta: float) -> void:
	if state == State.LOCKED or state == State.DEAD or state == State.SLEEP:
		_clear_input()
		return
	_update_unlock_filter()
	if state == State.GRABBED:
		_read_grab_input()
		return
	# Ataque: TOQUE = golpe leve (ao soltar). SEGURAR = golpe forte.
	if _just_pressed(&"attack"):
		_attack_held = true
		_attack_hold_time = 0.0
		_heavy_fired = false
	if _attack_held:
		_attack_hold_time += delta
		if not _heavy_fired and _attack_hold_time >= heavy_hold_time:
			_heavy_fired = true
			_buffer(&"heavy")
		if not Input.is_action_pressed(&"attack"):
			if not _heavy_fired:
				_buffer(&"light")
			_attack_held = false
	if _just_pressed(&"attack_heavy"):
		_buffer(&"heavy")
	if _just_pressed(&"dash"):
		_buffer(&"dash")
	if _just_pressed(&"heal"):
		_buffer(&"heal")
	if _just_pressed(&"sanity"):
		_buffer(&"sanity")
	if _buffer_left > 0.0:
		_buffer_left -= delta
		if _buffer_left <= 0.0:
			_buffered = &""


func _buffer(action: StringName) -> void:
	_buffered = action
	_buffer_left = input_buffer_time


func _clear_input() -> void:
	_buffered = &""
	_buffer_left = 0.0
	_attack_held = false


## "Acabou de apertar" — exceto teclas que já estavam apertadas no destravamento.
func _just_pressed(action: StringName) -> bool:
	if _input_grace_frames > 0 or _held_on_unlock.has(action):
		return false
	return Input.is_action_just_pressed(action)


## "Está segurando" — com o mesmo filtro do destravamento (segurar a tecla que
## fechou o diálogo não pode erguer o escudo sozinho).
func _is_held(action: StringName) -> bool:
	if _input_grace_frames > 0 or _held_on_unlock.has(action):
		return false
	return Input.is_action_pressed(action)


## Uma tecla volta a valer assim que é solta.
func _update_unlock_filter() -> void:
	if _input_grace_frames > 0:
		_input_grace_frames -= 1
	for i in range(_held_on_unlock.size() - 1, -1, -1):
		if not Input.is_action_pressed(_held_on_unlock[i]):
			_held_on_unlock.remove_at(i)


## Tenta executar o comando guardado. Se a ação falhar (ex.: exausto), descarta.
## allow_heal = false (janela de combo): cura/sanidade ficam GUARDADAS e saem
## assim que o golpe terminar — antes eram descartadas e o toque "sumia".
func _consume_buffer(allow_heal: bool = true) -> void:
	if _buffered == &"":
		return
	if not allow_heal and (_buffered == &"heal" or _buffered == &"sanity"):
		_buffer_left = maxf(_buffer_left, 0.1)  # segura o comando até o golpe acabar
		return
	var action := _buffered
	_buffered = &""
	_buffer_left = 0.0
	match action:
		&"light":
			_start_light_attack()
		&"heavy":
			_start_attack(heavy_attack, -1)
		&"dash":
			_start_dash()
		&"heal":
			if _interactable != null:
				_interactable.interact(self)
			else:
				_start_heal()
		&"sanity":
			_start_sanity()


# --- FREE ------------------------------------------------------------------------------

func _state_free(delta: float) -> void:
	var input := _move_input()
	var speed := move_speed * (exhausted_speed_multiplier if stats.is_exhausted else 1.0)
	speed *= lerpf(1.0, drowsy_speed_multiplier, drowsiness / drowsiness_max)
	if input != Vector2.ZERO:
		facing = input.normalized()
		velocity = velocity.move_toward(input * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	if velocity.length() > move_speed * noise_run_threshold:
		make_noise(noise_run)  # passos apressados
	_consume_buffer()
	if state == State.FREE and _wants_block():
		_start_block()


# --- BLOCK (escudo na mão esquerda) --------------------------------------------------------
# Bíblia: "Combate e movimento (ataque fraco e forte, mão direita e esquerda...)".
# Segurar = escudo erguido. Ele segura golpes pela FRENTE, mas cada golpe custa
# estamina; sem estamina, a guarda QUEBRA (cambaleio longo + Exaustão).
# Não segura o que não é golpe de arma: grito, onda no chão, agarrão (info.unblockable).

func _wants_block() -> bool:
	return Game.shield_ready() and _is_held(&"block")


func _start_block() -> void:
	_set_state(State.BLOCK)
	stats.regen_scale = block_regen_multiplier
	Sfx.play(&"shield_up", -6.0)
	action_used.emit(&"escudo")


func _state_block(delta: float) -> void:
	if not _wants_block():
		_set_state(State.FREE)
		return
	var input := _move_input()
	velocity = velocity.move_toward(input * move_speed * block_move_multiplier, acceleration * delta)
	var goal := _block_direction(input)
	facing = Vector2.from_angle(lerp_angle(facing.angle(), goal.angle(), minf(block_turn_speed * delta, 1.0)))
	# Golpe, dash ou cura saem direto do escudo (abaixá-lo é instantâneo).
	_consume_buffer()


## Para onde o escudo aponta: o inimigo (ou bala) mais perto; senão, o joystick.
func _block_direction(input: Vector2) -> Vector2:
	var best: Node2D = null
	var best_distance := block_face_range
	for group: StringName in [&"enemies", &"projectiles"]:
		for node in get_tree().get_nodes_in_group(group):
			var threat := node as Node2D
			if threat == null or not threat.is_visible_in_tree():
				continue
			if threat.has_method("is_targetable") and not threat.is_targetable():
				continue
			var distance := global_position.distance_to(threat.global_position)
			if distance < best_distance and distance > 0.5:
				best = threat
				best_distance = distance
	if best:
		return (best.global_position - global_position).normalized()
	if input.length() > 0.2:
		return input.normalized()
	return facing


func _can_block(info: HitInfo) -> bool:
	if info.unblockable:
		return false
	var toward_source := -info.direction  # info.direction vai da fonte PARA o herói
	if toward_source == Vector2.ZERO:
		return true
	return absf(rad_to_deg(facing.angle_to(toward_source))) <= block_angle


func _absorb_hit(info: HitInfo) -> void:
	var cost := info.damage * block_stamina_per_damage + (block_heavy_extra if info.is_heavy else 0.0)
	if stats.is_exhausted or stats.stamina < cost:
		_guard_break(info)
		return
	stats.drain_stamina(cost)
	stats.take_damage(info.damage * (1.0 - shield_absorption))  # raspão: a barra desce um pouco
	velocity = info.direction * info.knockback * 0.5
	_shield_recoil = 0.15
	Sfx.play(&"block")
	make_noise(noise_hit)
	Fx.sparks(global_position + Vector2(0, -8) + facing * 7.0, facing, Color(0.85, 0.9, 1.0), 10)
	Fx.hitstop(0.05)
	Fx.shake(2.0, 0.1)
	Fx.vibrate(25)
	blocked.emit(info)


## Sem estamina para segurar: o braço cede. Exaustão + cambaleio longo.
func _guard_break(info: HitInfo) -> void:
	stats.drain_stamina(stats.max_stamina)
	var applied := stats.take_damage(info.damage * guard_break_damage_ratio)
	Sfx.play(&"guard_break")
	Fx.flash(body_sprite, 0.15)
	Fx.shake(5.0, 0.25)
	Fx.hitstop(0.1)
	Fx.vibrate(80)
	Fx.float_text(global_position + Vector2(-26, -30), "GUARDA QUEBRADA", Color(1.0, 0.75, 0.6), 7)
	hurt.emit(applied)
	guard_broken.emit()
	if stats.is_dead:
		return
	_iframes_left = 0.2
	_runner.cancel()
	velocity = info.direction * info.knockback
	_set_state(State.STAGGER)
	_stagger_duration = guard_break_time


# --- SONO (Barra de Sonolência) ---------------------------------------------------------

## Pólen, o sonho da Nyssa... quem quer que dê sono chama isto.
func add_drowsiness(amount: float) -> void:
	if amount <= 0.0 or _sleep_grace_left > 0.0:
		return
	if state == State.DEAD or state == State.SLEEP or state == State.LOCKED or _plunging:
		return
	drowsiness = minf(drowsiness + amount, drowsiness_max)
	drowsiness_changed.emit(drowsiness, drowsiness_max)
	if drowsiness >= drowsiness_max:
		_fall_asleep()


func relieve_drowsiness(amount: float) -> void:
	if drowsiness <= 0.0:
		return
	drowsiness = maxf(drowsiness - amount, 0.0)
	drowsiness_changed.emit(drowsiness, drowsiness_max)


func is_asleep() -> bool:
	return state == State.SLEEP


func _update_drowsiness(delta: float) -> void:
	_sleep_grace_left = maxf(_sleep_grace_left - delta, 0.0)
	if state != State.SLEEP and drowsiness > 0.0:
		relieve_drowsiness(drowsiness_decay * delta)


func _fall_asleep() -> void:
	_runner.cancel()
	hitbox.deactivate()
	_clear_input()
	_set_state(State.SLEEP)
	_zzz_timer = 0.0
	sleep_changed.emit(true)
	Sfx.play(&"yawn", -2.0)


## Dormindo: parado, sem comandos. Acorda sozinho... ou com o primeiro golpe.
func _state_sleep(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	_zzz_timer -= delta
	if _zzz_timer <= 0.0:
		_zzz_timer = 0.6
		Fx.float_text(global_position + Vector2(4, -26), "z", Color(0.85, 0.82, 1.0), 8)
	if _state_time >= sleep_time:
		_set_state(State.FREE)


# --- BARULHO (furtividade no Bosque) -----------------------------------------------------

## Cada ação "faz barulho" num raio; o raio some sozinho (≈ 0,3 s).
func make_noise(radius: float) -> void:
	noise = maxf(noise, radius)


## Quem está em `point` ouviu o herói agora?
func is_heard_from(point: Vector2) -> bool:
	return noise > 0.0 and global_position.distance_to(point) <= noise


# --- AGARRÃO (preso: toque rápido no Ataque para escapar) ------------------------------
# Bíblia (Mabel): "O agarrão é um estado de 'preso': o jogador toca rápido no
# botão de ataque para escapar e, a cada segundo preso, perde uma parte das
# memórias. Funciona bem no celular."
# Quem agarra só chama grab(); o herói cuida do resto (e de soltar se o
# agarrador morrer ou sumir). Assim a Boca de Raiz, a Ninhada e a Mabel usam a
# MESMA regra — e o jogador aprende uma vez.

## Tenta agarrar. Falha (false) se o herói estiver esquivando, caindo, morto...
## offset: onde o herói fica em relação a quem agarra. hide: "engolido" (some).
func grab(by: Node2D, taps_needed: int, offset: Vector2 = Vector2.ZERO, damage_per_second: float = 0.0,
		memory_ratio_per_second: float = 0.0, memory_min_per_second: int = 0, hide: bool = false) -> bool:
	if by == null or state == State.DEAD or state == State.FALL or state == State.LOCKED or state == State.GRABBED:
		return false
	if _plunging or _is_invulnerable():
		return false  # o dash na hora certa escapa do agarrão
	_runner.cancel()
	hitbox.deactivate()
	_clear_input()
	_set_state(State.GRABBED)
	_grabber = by
	_grab_offset = offset
	_grab_taps = 0
	_grab_needed = maxi(taps_needed, 1)
	_grab_damage_per_second = damage_per_second
	_grab_drain_ratio = memory_ratio_per_second
	_grab_drain_min = memory_min_per_second
	_grab_tick = 0.0
	_grab_hidden = hide
	visual.visible = not hide
	set_collision_mask_value(3, false)  # preso DENTRO de quem agarra: sem empurra-empurra
	velocity = Vector2.ZERO
	Sfx.play(&"grab", -2.0)
	Fx.shake(3.0, 0.2)
	Fx.vibrate(90)
	grab_changed.emit(true, _grab_needed)
	grab_progress.emit(0, _grab_needed)
	return true


func is_grabbed() -> bool:
	return state == State.GRABBED


func is_grabbed_by(node: Node2D) -> bool:
	return state == State.GRABBED and _grabber == node


## Quem agarrava solta (cambaleou, morreu, terminou de "mastigar").
func release_grab(push: bool = true) -> void:
	if state != State.GRABBED:
		return
	var from := _grabber.global_position if is_instance_valid(_grabber) else global_position
	_set_state(State.FREE)
	_iframes_left = grab_escape_iframes
	if push:
		var away := (global_position - from).normalized()
		if away == Vector2.ZERO:
			away = -facing
		velocity = away * grab_escape_push


## Toques em Ataque (ou golpe forte, ou o botão do dash: no desespero, qualquer
## um serve — o importante é tocar RÁPIDO).
func _read_grab_input() -> void:
	for action: StringName in [&"attack", &"attack_heavy", &"dash"]:
		if _just_pressed(action):
			_grab_taps += 1
			grab_progress.emit(_grab_taps, _grab_needed)
			visual.position.x = 2.0 if _grab_taps % 2 == 0 else -2.0  # se debatendo
			Fx.vibrate(15)
			if _grab_taps >= _grab_needed:
				Sfx.play(&"block", -4.0)
				Fx.dust(global_position, 8)
				release_grab(true)
				return


func _state_grabbed(delta: float) -> void:
	velocity = Vector2.ZERO
	if not is_instance_valid(_grabber) or (_grabber.get("dead") == true):
		release_grab(false)
		return
	global_position = global_position.lerp(_grabber.global_position + _grab_offset, minf(18.0 * delta, 1.0))
	_grab_tick += delta
	if _grab_tick < 1.0:
		return
	_grab_tick -= 1.0
	# Cada segundo preso: memórias e um pouco de vida.
	var lost := Game.drain_memories(_grab_drain_ratio, _grab_drain_min)
	if lost > 0:
		Fx.float_text(global_position + Vector2(-10, -30), "−%d" % lost, Color(0.85, 0.9, 1.0), 8)
		if _grabber.has_method("on_memories_drained"):
			_grabber.call("on_memories_drained", lost)
	if _grab_damage_per_second > 0.0:
		var applied := stats.take_damage(_grab_damage_per_second)
		Fx.flash(body_sprite, 0.1)
		hurt.emit(applied)


## Limpeza ao sair do GRABBED (por qualquer caminho: escapou, soltaram, morreu).
func _end_grab() -> void:
	visual.visible = true
	set_collision_mask_value(3, true)
	visual.position.x = 0.0
	_grabber = null
	_grab_hidden = false
	grab_changed.emit(false, 0)


# --- ATTACK (Step and Anchor) -----------------------------------------------------------

func _start_light_attack() -> bool:
	if light_combo.is_empty():
		return false
	var chaining := (state == State.ATTACK and _runner.in_combo_window()) or _combo_grace > 0.0
	var index := (_combo_index + 1) % light_combo.size() if chaining else 0
	return _start_attack(light_combo[index], index)


## combo_index = -1 para o golpe forte.
func _start_attack(attack: AttackData, combo_index: int) -> bool:
	if attack == null:
		return false
	if not stats.try_spend_stamina(attack.stamina_cost):
		_deny_stamina()  # exausto ou sem estamina: o comando simplesmente não sai
		return false
	_current_attack = attack
	_combo_index = combo_index  # -1 depois do golpe forte: o próximo leve abre o combo do zero
	relieve_drowsiness(drowsiness_attack_relief)  # bater espanta o sono
	var direction := _aim_direction()
	facing = direction
	hitbox.deactivate()
	hitbox_pivot.rotation = direction.angle()
	(hitbox_shape.shape as CircleShape2D).radius = attack.radius
	hitbox_shape.position = Vector2(attack.reach, 0.0)
	_setup_swing(attack, direction, combo_index)
	_set_state(State.ATTACK)
	_runner.start(attack, direction)
	action_used.emit(&"forte" if attack.is_heavy else &"leve")
	return true


func _state_attack(delta: float) -> void:
	# A velocidade vem do AttackRunner: o input de movimento é IGNORADO (travado).
	velocity = _runner.step(delta, velocity)
	if _runner.in_combo_window():
		_consume_buffer(false)


func _on_attack_phase_changed(phase: AttackRunner.Phase) -> void:
	if state != State.ATTACK:
		return
	match phase:
		AttackRunner.Phase.LUNGE:
			Sfx.play(_current_attack.sound, -2.0)
			make_noise(noise_heavy if _current_attack.is_heavy else noise_attack)
			if _current_attack.active_during_lunge:
				_activate_hitbox()
		AttackRunner.Phase.ACTIVE:
			if not hitbox.active:
				_activate_hitbox()
			var angle := hitbox_pivot.rotation
			Fx.spawn_slash(global_position + Vector2(0, -7) + Vector2.from_angle(angle) * 4.0, angle, _current_attack, _swing_reverse)
			visual.scale = Vector2(1.12, 0.9)  # pequeno "esmagamento" no impacto
		AttackRunner.Phase.RECOVERY:
			hitbox.deactivate()
		AttackRunner.Phase.IDLE:
			hitbox.deactivate()
			_combo_grace = 0.2
			_set_state(State.FREE)


func _activate_hitbox() -> void:
	var multiplier := stats.damage_multiplier(_current_attack.scaling_attribute, _current_attack.scaling_per_point)
	multiplier *= Game.weapon_damage_multiplier()  # melhoria do Ferreiro
	hitbox.activate_with(_current_attack, _current_attack.damage * multiplier)


func _on_hit_landed(_target: Hurtbox, _info: HitInfo) -> void:
	if _current_attack == null:
		return
	make_noise(noise_hit)
	Fx.hitstop(_current_attack.hitstop)
	Fx.shake(_current_attack.shake, 0.12)
	Fx.vibrate(35 if _current_attack.is_heavy else 18)


func _aim_direction() -> Vector2:
	var base := _move_input()
	if base.length() < 0.2:
		base = facing
	base = base.normalized()
	var best: Node2D = null
	var best_distance := soft_aim_range
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Node2D
		if enemy == null or not enemy.is_visible_in_tree():
			continue
		if enemy.has_method("is_targetable") and not enemy.is_targetable():
			continue
		var to_enemy := enemy.global_position - global_position
		var distance := to_enemy.length()
		if distance > best_distance or distance < 0.5:
			continue
		if absf(rad_to_deg(base.angle_to(to_enemy))) > soft_aim_angle:
			continue
		best = enemy
		best_distance = distance
	if best:
		return (best.global_position - global_position).normalized()
	return base


func _setup_swing(attack: AttackData, direction: Vector2, combo_index: int) -> void:
	var base := direction.angle()
	var half := deg_to_rad(attack.slash_arc_degrees) * 0.5
	_swing_reverse = combo_index % 2 == 1  # o 2º golpe volta pelo outro lado
	if attack.slash_arc_degrees <= 10.0:
		_swing_from = base
		_swing_to = base
	elif _swing_reverse:
		_swing_from = base + half
		_swing_to = base - half
	else:
		_swing_from = base - half
		_swing_to = base + half


# --- DASH ----------------------------------------------------------------------------

func _start_dash() -> bool:
	if not stats.try_spend_stamina(dash_stamina_cost):
		_deny_stamina()
		return false
	var input := _move_input()
	_dash_dir = input.normalized() if input.length() > 0.2 else facing
	facing = _dash_dir
	_runner.cancel()
	_set_state(State.DASH)
	if dash_through_enemies:
		set_collision_mask_value(3, false)
	Sfx.play(&"dash", -3.0)
	action_used.emit(&"dash")
	make_noise(noise_dash)
	Fx.dust(global_position, 6)
	visual.scale = Vector2(1.25, 0.8)
	return true


func _state_dash(delta: float) -> void:
	if _state_time < dash_time:
		# Começa rápido e desacelera no fim: sensação de rolamento, não de teleporte.
		var t := _state_time / dash_time
		velocity = _dash_dir * dash_speed * (1.0 - t * t * 0.7)
		_afterimage_timer -= delta
		if _afterimage_timer <= 0.0:
			_afterimage_timer = 0.035
			Fx.afterimage(body_sprite)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * 2.0 * delta)
	if _state_time >= dash_time + dash_recovery_time:
		_set_state(State.FREE)


# --- Frascos ----------------------------------------------------------------------------

func _start_heal() -> bool:
	if health_flasks <= 0 or stats.health >= stats.max_health:
		return false
	health_flasks -= 1
	health_flasks_changed.emit(health_flasks, health_flasks_max)
	_set_state(State.HEAL)
	action_used.emit(&"cura")
	return true


func _state_heal(delta: float) -> void:
	# Dá para andar devagar enquanto bebe. Levar golpe antes de heal_apply_at
	# desperdiça o frasco — risco e recompensa.
	velocity = velocity.move_toward(_move_input() * move_speed * heal_move_multiplier, acceleration * delta)
	if not _effect_applied and _state_time >= heal_time * heal_apply_at:
		_effect_applied = true
		stats.heal(heal_amount)
		Sfx.play(&"heal", -2.0)
		Fx.splash(global_position + Vector2(0, -12), Color(0.9, 0.25, 0.25), 12)
	if _state_time >= heal_time:
		_set_state(State.FREE)


## Frasco de Sanidade: o personagem joga o líquido no próprio rosto e a pele absorve.
func _start_sanity() -> bool:
	if Game.vision_loss <= 0 or not Game.consume_sanity_flask():
		return false
	_set_state(State.SANITY)
	return true


func _state_sanity(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	if not _effect_applied and _state_time >= sanity_time * sanity_apply_at:
		_effect_applied = true
		Game.restore_vision()
		Sfx.play(&"sanity", -2.0)
		Fx.splash(global_position + Vector2(0, -14), Color(0.95, 0.97, 1.0), 18)
	if _state_time >= sanity_time:
		_set_state(State.FREE)


func _deny_stamina() -> void:
	stamina_denied.emit()


# --- Dano, morte ------------------------------------------------------------------------

func _on_hit_received(info: HitInfo) -> void:
	if state == State.DEAD:
		return
	if state == State.BLOCK and _can_block(info):
		_absorb_hit(info)
		return
	var applied := stats.take_damage(info.damage)
	_iframes_left = hurt_iframes
	Fx.flash(body_sprite, 0.12)
	Fx.shake(4.0, 0.2)
	Fx.hitstop(0.08)
	Fx.vibrate(60)
	Fx.sparks(global_position + Vector2(0, -8), info.direction, Color(1, 0.4, 0.35), 10)
	Sfx.play(&"hurt")
	hurt.emit(applied)
	if stats.is_dead:
		return  # _on_died já assumiu
	if state == State.GRABBED:
		return  # preso: apanha, mas continua preso (só os toques soltam)
	_runner.cancel()
	velocity = info.direction * info.knockback
	_set_state(State.STAGGER)
	_stagger_duration = stagger_time


func _state_stagger(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	if _state_time >= _stagger_duration:
		_set_state(State.FREE)


# --- Buracos (arena do Aldir) -------------------------------------------------------

## Pisou num buraco aberto? Cai. Longe de buracos? Guarda o ponto como seguro.
func _check_pits() -> void:
	if not GROUNDED_STATES.has(state):
		return
	if not get_tree().has_group(&"pits"):
		_last_safe_position = global_position
		return
	var near_edge := false
	for node in get_tree().get_nodes_in_group(&"pits"):
		var pit := node as ArenaPit
		if pit.contains_point(global_position, -3.0):  # 3 px de folga na borda
			_start_fall(pit)
			return
		if pit.contains_point(global_position, 10.0):
			near_edge = true
	if not near_edge:
		_last_safe_position = global_position


func _start_fall(pit: ArenaPit) -> void:
	_runner.cancel()
	hitbox.deactivate()
	_set_state(State.FALL)
	velocity = Vector2.ZERO
	Sfx.play(&"fall")
	Fx.dust(global_position, 6)
	if _fall_tween and _fall_tween.is_valid():
		_fall_tween.kill()
	_fall_tween = create_tween()
	_fall_tween.tween_property(visual, "scale", Vector2(0.15, 0.15), fall_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_fall_tween.parallel().tween_property(visual, "modulate", Color(0.4, 0.45, 0.6, 0.0), fall_time)
	_fall_tween.parallel().tween_property(self, "global_position", global_position.lerp(pit.global_position, 0.5), fall_time * 0.8)


func _state_fall(_delta: float) -> void:
	velocity = Vector2.ZERO
	if _state_time >= fall_time:
		_finish_fall()


## Volta para o último ponto seguro, pagando a queda com vida.
func _finish_fall() -> void:
	if _fall_tween and _fall_tween.is_valid():
		_fall_tween.kill()
	global_position = _last_safe_position
	visual.scale = Vector2.ONE
	visual.modulate = Color.WHITE
	_clear_input()
	_set_state(State.FREE)
	_iframes_left = fall_iframes
	var applied := stats.take_damage(maxf(fall_min_damage, stats.max_health * fall_damage_ratio))
	Fx.flash(body_sprite, 0.15)
	Fx.shake(3.0, 0.2)
	Fx.vibrate(60)
	Sfx.play(&"hurt")
	hurt.emit(applied)


## Prólogo: "Passando pela porta, o chão some." Não há borda para onde voltar —
## a fase troca de cena enquanto ele cai.
func plunge(center: Vector2, duration: float = 0.9) -> void:
	if state == State.DEAD or _plunging:
		return
	_runner.cancel()
	hitbox.deactivate()
	_set_state(State.LOCKED)
	_plunging = true
	velocity = Vector2.ZERO
	if _fall_tween and _fall_tween.is_valid():
		_fall_tween.kill()
	_fall_tween = create_tween()
	_fall_tween.tween_property(self, "global_position", center, duration * 0.35)
	_fall_tween.parallel().tween_property(visual, "scale", Vector2(0.1, 0.1), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_fall_tween.parallel().tween_property(visual, "modulate", Color(0.35, 0.4, 0.5, 0.0), duration)


func _on_died() -> void:
	_runner.cancel()
	hitbox.deactivate()
	_set_state(State.DEAD)
	Sfx.play(&"death")
	Fx.vibrate(220)
	Fx.slow_motion(0.35, 0.5)
	var tween := create_tween()
	tween.tween_property(visual, "rotation", deg_to_rad(-90.0 if body_sprite.flip_h else 90.0), 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(visual, "modulate", Color(0.55, 0.55, 0.6, 1.0), 0.8)
	died.emit()


## Cabelo e olhos clareiam a cada morte (shader troca as cores-chave).
func _update_death_marks() -> void:
	var material := body_sprite.material as ShaderMaterial
	if material == null:
		return
	var t := Game.whiteness_ratio()
	material.set_shader_parameter("swap_amount", t)


# --- Interação ------------------------------------------------------------------------

func _update_interactable() -> void:
	var nearest: Interactable = null
	if state == State.FREE or state == State.ATTACK:
		var best := INF
		for area in interaction_area.get_overlapping_areas():
			var candidate := area as Interactable
			if candidate == null or not candidate.enabled:
				continue
			var d := global_position.distance_squared_to(candidate.global_position)
			if d < best:
				best = d
				nearest = candidate
	if nearest != _interactable:
		_interactable = nearest
		interact_target_changed.emit(nearest)


# --- Visual (provisório: troque por animações quando tiver a arte final) ------------------

func _update_visuals(delta: float) -> void:
	if absf(facing.x) > 0.15:
		body_sprite.flip_h = facing.x < 0.0
	var side := -1.0 if body_sprite.flip_h else 1.0
	var speed := velocity.length()
	var walking := speed > 10.0 and (state == State.FREE or state == State.HEAL or state == State.BLOCK)

	if state == State.DEAD or state == State.FALL or _plunging:
		return  # na queda (e na morte) quem mexe no visual é o tween
	if walking:
		if body_sprite.animation != &"walk":
			body_sprite.play(&"walk")
		body_sprite.speed_scale = clampf(speed / move_speed, 0.4, 1.3)
		_walk_phase += delta * 11.0 * body_sprite.speed_scale
		visual.position.y = -absf(sin(_walk_phase)) * 1.5
	else:
		if body_sprite.animation != &"idle":
			body_sprite.play(&"idle")
		visual.position.y = lerpf(visual.position.y, 0.0, 12.0 * delta)

	# Respiração / cansaço e "esmagamento" voltando ao normal.
	var breath := sin(_anim_time * (5.0 if stats.is_exhausted else 2.6)) * (0.05 if stats.is_exhausted else 0.025)
	var target_scale := Vector2(1.0 - breath * 0.5, 1.0 + breath) if not walking else Vector2.ONE
	visual.scale = visual.scale.lerp(target_scale, 14.0 * delta)
	visual.position.x = lerpf(visual.position.x, 0.0, 20.0 * delta)  # o "debater-se" do agarrão
	var tilt := 0.0
	if state == State.GRABBED:
		tilt = sin(_anim_time * 22.0) * 0.12
	elif state == State.HEAL or state == State.SANITY:
		tilt = 0.12 * side
	elif state == State.SLEEP:
		tilt = 0.35 * side  # cabeceando de sono
	visual.rotation = lerpf(visual.rotation, tilt, 10.0 * delta)
	if state == State.GRABBED:
		body_sprite.modulate = Color(1.0, 0.72, 0.72)
	else:
		body_sprite.modulate = Color(0.78, 0.84, 1.0) if stats.is_exhausted else Color.WHITE
	_update_weapon(side, delta)
	_update_shield(side, delta)


## Escudo: no braço (atrás do corpo) ou erguido À FRENTE, na direção da defesa.
func _update_shield(side: float, delta: float) -> void:
	shield_sprite.visible = Game.shield_ready()
	if not shield_sprite.visible:
		return
	_shield_recoil = maxf(_shield_recoil - delta, 0.0)
	shield_sprite.flip_h = side < 0.0
	if state == State.BLOCK:
		var front := Vector2(0, -7) + facing * (6.0 - _shield_recoil * 20.0)
		shield_sprite.position = shield_sprite.position.lerp(front, 25.0 * delta)
		shield_sprite.z_index = -1 if facing.y < -0.4 else 1  # de costas, o escudo some atrás
	else:
		shield_sprite.position = shield_sprite.position.lerp(Vector2(-6.0 * side, -6.0), 14.0 * delta)  # aparece por trás do ombro
		shield_sprite.z_index = -1


func _update_weapon(side: float, delta: float) -> void:
	var target_angle := IDLE_SWORD_ANGLE if side > 0.0 else PI - IDLE_SWORD_ANGLE
	var target_pos := Vector2(4.0 * side, -7.0)
	if state == State.ATTACK and _current_attack:
		target_pos = Vector2(0, -8)
		var pull := -0.5 if not _swing_reverse else 0.5
		match _runner.phase:
			AttackRunner.Phase.WINDUP:
				target_angle = _swing_from + pull * _runner.phase_progress()
				if _swing_from == _swing_to:  # estocada: recolhe a espada
					target_pos -= Vector2.from_angle(_swing_from) * 3.0 * _runner.phase_progress()
			AttackRunner.Phase.LUNGE:
				target_angle = _swing_from
			AttackRunner.Phase.ACTIVE:
				target_angle = lerp_angle(_swing_from, _swing_to, _runner.phase_progress())
				if _swing_from == _swing_to:
					target_pos += Vector2.from_angle(_swing_from) * 5.0
			_:
				target_angle = _swing_to
		weapon_pivot.rotation = target_angle  # durante o golpe a arma é exata
	elif state == State.HEAL or state == State.SANITY:
		target_angle = PI * 0.5 + 0.3 * side
		weapon_pivot.rotation = lerp_angle(weapon_pivot.rotation, target_angle, 12.0 * delta)
	else:
		weapon_pivot.rotation = lerp_angle(weapon_pivot.rotation, target_angle, 14.0 * delta)
	weapon_pivot.position = weapon_pivot.position.lerp(target_pos, 20.0 * delta)
	sword.flip_v = cos(weapon_pivot.rotation) < 0.0
	# A espada fica atrás do corpo quando aponta para cima.
	weapon_pivot.z_index = -1 if sin(weapon_pivot.rotation) < -0.35 else 1
