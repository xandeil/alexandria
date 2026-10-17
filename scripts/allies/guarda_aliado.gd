class_name GuardaAliado
extends CharacterBody2D
## O Guarda Sem Posto lutando ao seu lado (Bíblia: "Ele pode ser chamado para
## ajudar contra alguns mini-chefes").
##
## Regras simples e legíveis:
##   • Segue você de perto. Inimigo perto de VOCÊ? Ele vai até o inimigo e corta.
##   • Os golpes dele são HitInfo como os seus (o inimigo não sabe a diferença).
##   • Os golpes dos inimigos acertam ele também (a hurtbox dele está na mesma
##     camada que a sua). Os inimigos não o escolhem como alvo: ele se põe no meio.
##   • Caiu de joelhos? Recua para o Teatro. Fale com ele lá para chamar de novo.

const FRAMES := preload("res://assets/sprites/guarda_frames.tres")
const SHADOW := preload("res://assets/fx/shadow.png")

@export var max_health := 160.0
@export var move_speed := 78.0
@export var follow_distance := 26.0
@export var engage_range := 100.0
@export var strike_reach := 22.0
@export var strike_damage := 14.0
@export var windup := 0.35
@export var cooldown := 0.9

var health := 160.0
var player: Player
var target: Enemy
var facing := Vector2.RIGHT
var fallen := false

var _sprite: AnimatedSprite2D
var _hurtbox: Hurtbox
var _windup_left := -1.0
var _cooldown := 0.0
var _side := 1.0


static func spawn(parent: Node, near: Player) -> GuardaAliado:
	var guard := GuardaAliado.new()
	guard.player = near
	guard.position = near.position + Vector2(-18, 6)
	parent.add_child(guard)
	return guard


func _ready() -> void:
	add_to_group(&"allies")
	health = max_health
	collision_layer = 0  # não empurra você nem os inimigos
	collision_mask = 1  # mas respeita paredes
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	var body := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 4.5
	body.shape = circle
	body.position = Vector2(0, -3)
	add_child(body)
	var shadow := Sprite2D.new()
	shadow.texture = SHADOW
	shadow.position = Vector2(0, -1)
	add_child(shadow)
	_sprite = AnimatedSprite2D.new()
	_sprite.sprite_frames = FRAMES
	_sprite.offset = Vector2(0, -11)
	_sprite.play(&"idle")
	add_child(_sprite)
	_hurtbox = Hurtbox.new()
	_hurtbox.collision_layer = 8  # a mesma camada da sua hurtbox: golpes inimigos acertam
	_hurtbox.collision_mask = 0
	_hurtbox.owner_body = self
	var hurt_shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(12, 16)
	hurt_shape.shape = box
	hurt_shape.position = Vector2(0, -8)
	_hurtbox.add_child(hurt_shape)
	add_child(_hurtbox)
	_hurtbox.hit_received.connect(_on_hit)
	_side = -1.0 if randf() < 0.5 else 1.0


func _physics_process(delta: float) -> void:
	if fallen or not is_instance_valid(player):
		velocity = Vector2.ZERO
		return
	_cooldown -= delta
	if player.is_dead():
		velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)
		move_and_slide()
		return
	if global_position.distance_to(player.global_position) > 240.0:
		global_position = player.global_position + Vector2(-16 * _side, 8)  # ficou preso: alcança você
	target = _pick_target()
	if _windup_left >= 0.0:
		velocity = velocity.move_toward(Vector2.ZERO, 900.0 * delta)
		_windup_left -= delta
		if _windup_left < 0.0:
			_strike()
	elif target:
		var to_target := target.global_position - global_position
		facing = to_target.normalized()
		if to_target.length() <= strike_reach and _cooldown <= 0.0:
			_windup_left = windup
		else:
			velocity = velocity.move_toward(facing * move_speed, 700.0 * delta)
	else:
		var spot := player.global_position + Vector2(-follow_distance * _side, 6)
		var to_spot := spot - global_position
		if to_spot.length() > 6.0:
			velocity = velocity.move_toward(to_spot.normalized() * move_speed * clampf(to_spot.length() / 30.0, 0.4, 1.2), 700.0 * delta)
			facing = to_spot.normalized()
		else:
			velocity = velocity.move_toward(Vector2.ZERO, 700.0 * delta)
	move_and_slide()
	_update_visual()


## O inimigo mais perto de VOCÊ (ele protege você, não caça sozinho).
func _pick_target() -> Enemy:
	var best: Enemy = null
	var best_distance := engage_range
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy == null or enemy.dead or not enemy.is_targetable():
			continue
		var distance := enemy.global_position.distance_to(player.global_position)
		if distance < best_distance:
			best_distance = distance
			best = enemy
	return best


func _strike() -> void:
	_cooldown = cooldown
	Sfx.play(&"swing", -6.0, 0.1)
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy == null or enemy.dead:
			continue
		var to := enemy.global_position - global_position
		if to.length() > strike_reach + 8.0 or absf(rad_to_deg(facing.angle_to(to))) > 70.0:
			continue
		var info := HitInfo.create(strike_damage, global_position, enemy.global_position)
		info.knockback = 110.0
		info.poise_damage = 18.0
		info.attack_name = "Espada do Guarda"
		info.source = self
		enemy.hurtbox.receive_hit(info)


func _on_hit(info: HitInfo) -> void:
	if fallen:
		return
	health -= info.damage * 0.7  # um veterano: aguenta um pouco mais que você
	Fx.flash(_sprite, 0.1)
	velocity += info.direction * info.knockback * 0.5
	if health <= 0.0:
		fall()


## Caiu de joelhos: avisa, some aos poucos e volta para o Teatro.
func fall() -> void:
	fallen = true
	_hurtbox.set_deferred("monitorable", false)
	Game.flags["guarda_acompanha"] = false
	_sprite.play(&"caido")
	Sfx.play(&"hit_heavy", -4.0)
	var level := Level.find(self)
	if level and level.hud:
		level.hud.toast("O Guarda caiu de joelhos. Ele volta para o Teatro.")
	var tween := create_tween()
	tween.tween_interval(1.2)
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(queue_free)


func _update_visual() -> void:
	if absf(facing.x) > 0.15:
		_sprite.flip_h = facing.x < 0.0
	var anim := &"idle"
	if _windup_left >= 0.0 or _cooldown > cooldown - 0.2:
		anim = &"golpe"
	elif velocity.length() > 8.0:
		anim = &"walk"
	if _sprite.animation != anim:
		_sprite.play(anim)
