class_name Enemy
extends CharacterBody2D
## Base de todo inimigo: alvo, golpes (via AttackRunner), postura, morte e recompensa.
##
## Herança aqui faz sentido porque TODO inimigo precisa disso. O que muda de um
## para outro (escudo do soldado, armadura da Helena) entra pelos métodos
## "virtuais" _incoming_damage_multiplier() e _on_attack_finished().
##
## Bíblia: "Inimigos comuns também morreram muitas vezes tentando cumprir sua
## função e ficaram remendados, vazios e repetitivos. O jogador morre e aprende;
## eles morrem e estagnam."

signal defeated(enemy: Enemy)

@export_group("Recompensa")
## Memórias ganhas ao derrotar (moeda + XP).
@export var memory_reward := 40
## Item que PODE cair ao morrer (id do catálogo Items; "" = nada).
@export var drop_item := ""
@export_range(0.0, 1.0) var drop_chance := 0.0
@export var drop_count := 1

@export_group("Movimento")
@export var move_speed := 45.0
@export var acceleration := 600.0
@export var aggro_range := 110.0
## Desiste da perseguição se o herói se afastar demais de casa.
@export var leash_range := 240.0

@export_group("Postura (cambaleio)")
@export var max_poise := 40.0
@export var poise_regen_per_second := 22.0
@export var stagger_time := 0.7
## Multiplica o empurrão recebido (0 = inamovível).
@export_range(0.0, 2.0) var knockback_taken := 0.6

@onready var stats: StatsComponent = $Stats
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var hitbox: Hitbox = $HitboxPivot/Hitbox
@onready var hitbox_pivot: Node2D = $HitboxPivot
@onready var hitbox_shape: CollisionShape2D = $HitboxPivot/Hitbox/CollisionShape2D
@onready var visual: Node2D = $Visual
@onready var body_sprite: AnimatedSprite2D = $Visual/Body

var target: Player
var poise := 0.0
var home_position := Vector2.ZERO
var facing := Vector2.LEFT
var dead := false

var _runner := AttackRunner.new()
var _current_attack: AttackData
var _poise_delay := 0.0
var _walk_phase := 0.0


func _ready() -> void:
	add_to_group("enemies")
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	home_position = global_position
	poise = max_poise
	hitbox_shape.shape = hitbox_shape.shape.duplicate()
	hitbox.source = self
	hurtbox.owner_body = self
	if body_sprite.material:
		body_sprite.material = body_sprite.material.duplicate()
	_runner.phase_changed.connect(_on_attack_phase_changed)
	hurtbox.hit_received.connect(_on_hit_received)
	hitbox.hit_landed.connect(_on_hit_landed)
	stats.died.connect(_on_died)


## A mira assistida do herói ignora quem não é alvo válido.
func is_targetable() -> bool:
	return not dead and visible


func find_target() -> Player:
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null or player.is_dead():
		return null
	return player


## Linha de visão: um raio contra a camada "mundo" (paredes/obstáculos).
func can_see(point: Vector2) -> bool:
	var query := PhysicsRayQueryParameters2D.create(global_position + Vector2(0, -6), point + Vector2(0, -6), 1)
	query.exclude = [get_rid()]
	return get_world_2d().direct_space_state.intersect_ray(query).is_empty()


# --- Golpes ----------------------------------------------------------------------------

func start_attack(attack: AttackData, direction: Vector2, speed_multiplier: float = 1.0) -> void:
	_current_attack = attack
	hitbox.deactivate()
	facing = direction.normalized()
	hitbox_pivot.rotation = facing.angle()
	(hitbox_shape.shape as CircleShape2D).radius = attack.radius
	hitbox_shape.position = Vector2(attack.reach, 0.0)
	# Pólen (lento) e o Fuso do Arconte (exausto) atrasam o golpe. O status só
	# existe se alguma arma já pendurou um (EnemyStatus.of), senão não custa nada.
	var status := EnemyStatus.find(self)
	if status:
		speed_multiplier *= status.consume_attack_scale()
	_runner.start(attack, facing, speed_multiplier)


## Durante o windup a mira acompanha o herói... até travar (telegraph justo).
func track_target_during_windup() -> void:
	if target and _runner.can_track_target():
		var direction := (target.global_position - global_position).normalized()
		if direction != Vector2.ZERO:
			_runner.direction = direction
			facing = direction
			hitbox_pivot.rotation = direction.angle()


func _on_attack_phase_changed(phase: AttackRunner.Phase) -> void:
	if _current_attack == null:
		return
	match phase:
		AttackRunner.Phase.WINDUP:
			Fx.flash(body_sprite, 0.18, Color(1.0, 0.35, 0.3))  # aviso visual do golpe
		AttackRunner.Phase.LUNGE:
			Sfx.play(_current_attack.sound, -4.0)
			if _current_attack.active_during_lunge:
				_activate_hitbox()
		AttackRunner.Phase.ACTIVE:
			if not hitbox.active:
				_activate_hitbox()
			var angle := hitbox_pivot.rotation
			Fx.spawn_slash(global_position + Vector2(0, -8) + Vector2.from_angle(angle) * 4.0, angle, _current_attack, false)
		AttackRunner.Phase.RECOVERY:
			hitbox.deactivate()
		AttackRunner.Phase.IDLE:
			hitbox.deactivate()
			_on_attack_finished()


func _activate_hitbox() -> void:
	hitbox.activate_with(_current_attack, _current_attack.damage)


func _on_hit_landed(_target: Hurtbox, _info: HitInfo) -> void:
	pass


## Gancho para subclasses: chamado quando um golpe termina (ou é cancelado).
func _on_attack_finished() -> void:
	pass


# --- Dano recebido ------------------------------------------------------------------------

## Gancho: escudo frontal, armadura... (1.0 = dano cheio).
func _incoming_damage_multiplier(_info: HitInfo) -> float:
	return 1.0


func _on_hit_received(info: HitInfo) -> void:
	if dead:
		return
	var multiplier := _incoming_damage_multiplier(info)
	var blocked := multiplier < 0.5
	var damage := info.damage * multiplier
	stats.take_damage(damage)
	poise -= info.poise_damage
	_poise_delay = 1.0
	if blocked:
		Sfx.play(&"block")
		Fx.sparks(global_position + Vector2(0, -8) - info.direction * 4.0, -info.direction, Color(0.85, 0.9, 1.0), 9)
	else:
		Sfx.play(&"hit_heavy" if info.is_heavy else &"hit")
		Fx.flash(body_sprite, 0.1)
		Fx.sparks(global_position + Vector2(0, -8), info.direction, Color(1.0, 0.95, 0.8), 8)
	_on_damaged(damage, info, blocked)
	if dead:
		return
	if poise <= 0.0 and _can_be_staggered():
		poise = max_poise
		velocity = info.direction * info.knockback * maxf(knockback_taken, 0.8)
		_on_poise_broken(info)  # primeiro muda o estado...
		_runner.cancel()  # ...depois cancela o golpe (o gancho já sabe que foi cambaleio)
	else:
		# Postura zerada num momento "imune" (salto, troca de fase) NÃO se perde:
		# fica em 0 e o próximo golpe na hora certa derruba.
		poise = maxf(poise, 0.0)
		velocity += info.direction * info.knockback * knockback_taken * (0.4 if blocked else 1.0)


## Gancho: depois de aplicar o dano (Helena reage à armadura aqui).
func _on_damaged(_amount: float, _info: HitInfo, _blocked: bool) -> void:
	pass


## Gancho: postura quebrou (cambaleio longo — janela para punir).
func _on_poise_broken(_info: HitInfo) -> void:
	pass


## Gancho: pode cambalear AGORA? (a Helena não cambaleia no ar nem trocando de fase).
func _can_be_staggered() -> bool:
	return true


## Espera que respeita a pausa e MORRE junto com o inimigo.
## (Com get_tree().create_timer(), se a cena fosse trocada no meio da espera,
## o Godot tentaria continuar a função num nó que já não existe.)
func wait(seconds: float) -> void:
	var timer := Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.start(seconds)
	await timer.timeout
	timer.queue_free()


func regen_poise(delta: float) -> void:
	if _poise_delay > 0.0:
		_poise_delay -= delta
	else:
		poise = minf(poise + poise_regen_per_second * delta, max_poise)


# --- Parry e crítico (v0.21) ------------------------------------------------------------
# Como no DS3: aparar no tempo certo ABRE a guarda; de frente, o herói tem uma
# janela curta para o crítico. Pelas costas (sem estar olhando), também.

## Quanto tempo a guarda fica aberta depois de um parry (chefes: bem menos).
const RIPOSTE_WINDOW := 1.1
const RIPOSTE_WINDOW_BOSS := 0.7


## O herói aparou um golpe meu. Devolve true se a guarda abriu (alguns
## momentos não deixam cambalear: a Helena no ar, troca de fase...).
func parried(info: HitInfo) -> bool:
	if dead or not _can_be_staggered():
		return false
	poise = max_poise
	velocity = -info.direction * 40.0  # recua meio passo, desequilibrado
	_on_poise_broken(info)  # cada inimigo já sabe cambalear do seu jeito
	_runner.cancel()
	hitbox.deactivate()
	EnemyStatus.of(self).guard_open = RIPOSTE_WINDOW_BOSS if self is Boss else RIPOSTE_WINDOW
	Fx.float_text(global_position + Vector2(-16, -34), "ABERTO", Color(1.0, 0.9, 0.5), 7)
	return true


func is_guard_open() -> bool:
	var status := EnemyStatus.find(self)
	return status != null and status.guard_open > 0.0 and not dead


## Pelas costas: o herói está ATRÁS de onde eu olho. Chefes e gigantes, não.
func can_be_backstabbed(from: Vector2) -> bool:
	if dead or self is Boss or is_in_group("giants") or knockback_taken <= 0.05:
		return false
	var to_attacker := from - global_position
	if to_attacker.length() < 0.5:
		return false
	return facing.normalized().dot(to_attacker.normalized()) < -0.45


## O crítico entrou (de frente depois do parry, ou pelas costas).
func receive_critical(damage: float, from: Node2D) -> void:
	if dead:
		return
	var status := EnemyStatus.find(self)
	if status:
		status.guard_open = 0.0
	Fx.flash(body_sprite, 0.2, Color(1.0, 0.3, 0.3))
	Fx.sparks(global_position + Vector2(0, -8), Vector2.UP, Color(0.9, 0.1, 0.15), 18)
	Sfx.play(&"hit_heavy")
	stats.take_damage(damage)
	if not dead:
		var info := HitInfo.create(0.0, from.global_position, global_position)
		_on_poise_broken(info)  # ainda no chão depois do golpe
		_runner.cancel()


# --- Morte ---------------------------------------------------------------------------

func _on_died() -> void:
	dead = true
	_runner.cancel()
	hitbox.deactivate()
	remove_from_group("enemies")
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	hurtbox.set_deferred("monitorable", false)
	var reward := int(round(memory_reward * (1.0 + (Game.attributes.get("sorte", 10) - 10) * 0.02)))
	Game.add_memories(reward)
	var player := find_target()
	if player:
		Fx.memory_motes(global_position + Vector2(0, -8), player, clampi(reward / 10, 3, 14))
	Sfx.play(&"enemy_death")
	_try_drop()
	defeated.emit(self)
	_play_death()


## Sorte também ajuda aqui (+2% de chance relativa por ponto acima de 10).
func _try_drop() -> void:
	if drop_item.is_empty() or drop_chance <= 0.0:
		return
	var luck := 1.0 + (int(Game.attributes.get("sorte", 10)) - 10) * 0.02
	if randf() < drop_chance * luck:
		ItemPickup.drop(get_parent(), global_position, drop_item, drop_count)


## "A humanidade era extraída e transformada em líquido": o corpo derrete em branco.
func _play_death() -> void:
	var tween := create_tween()
	tween.tween_property(visual, "modulate", Color(2.2, 2.2, 2.4, 1.0), 0.12)
	tween.tween_property(visual, "scale", Vector2(1.4, 0.15), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(visual, "modulate:a", 0.0, 0.55)
	tween.tween_callback(queue_free)


# --- Visual compartilhado ---------------------------------------------------------------

func update_body_animation(delta: float) -> void:
	if absf(facing.x) > 0.15:
		body_sprite.flip_h = facing.x < 0.0
	var walking := velocity.length() > 6.0 and not _runner.is_running()
	if walking:
		if body_sprite.animation != &"walk":
			body_sprite.play(&"walk")
		body_sprite.speed_scale = clampf(velocity.length() / maxf(move_speed, 1.0), 0.4, 1.4)
		_walk_phase += delta * 10.0 * body_sprite.speed_scale
		visual.position.y = -absf(sin(_walk_phase)) * 1.2
	else:
		if body_sprite.animation != &"idle":
			body_sprite.play(&"idle")
		visual.position.y = lerpf(visual.position.y, 0.0, 10.0 * delta)
