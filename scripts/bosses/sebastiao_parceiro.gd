class_name SebastiaoParceiro
extends CharacterBody2D
## O Bastião na luta em dupla (Sebastioes): corpo e VIDA próprios (a segunda
## barra). Cai antes do Tião? Fica no chão; e o Tião fica com raiva.
## Regra de leitura: ele PISCA antes de bater (aviso), e bate devagar.

const WINDUP := 0.55
const COOLDOWN := 1.5
const REACH := 26.0

signal downed_signal

@export var max_health := 260.0
var health := 260.0
var down := false

var leader: MiniBoss
var frames: SpriteFrames
var damage := 16.0
var speed := 58.0
var awake := false
var _sprite: AnimatedSprite2D
var _hurtbox: Hurtbox
var _windup_left := -1.0
var _cooldown := 0.6
var _side := 1.0


func _ready() -> void:
	top_level = true
	health = max_health
	global_position = leader.global_position + Vector2(26, 0)
	collision_layer = 0
	collision_mask = 1
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	var body := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 5.0
	body.shape = circle
	body.position = Vector2(0, -3)
	add_child(body)
	_sprite = AnimatedSprite2D.new()
	_sprite.sprite_frames = frames
	_sprite.offset = Vector2(0, -12)
	_sprite.play(&"idle")
	add_child(_sprite)
	_hurtbox = Hurtbox.new()
	_hurtbox.collision_layer = 16  # a camada das hurtboxes inimigas: os seus golpes acertam
	_hurtbox.collision_mask = 0
	_hurtbox.owner_body = self
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(12, 20)
	shape.shape = box
	shape.position = Vector2(0, -10)
	_hurtbox.add_child(shape)
	add_child(_hurtbox)
	_hurtbox.hit_received.connect(_on_hit)


## Bateu nele: desce a barra DELE.
func _on_hit(info: HitInfo) -> void:
	if down or not is_instance_valid(leader) or leader.dead or not leader.active:
		return
	health = maxf(health - info.damage, 0.0)
	Fx.flash(_sprite, 0.1)
	velocity += info.direction * info.knockback * 0.4
	if health <= 0.0:
		_go_down()


func health_ratio() -> float:
	return health / max_health if max_health > 0.0 else 0.0


func is_down() -> bool:
	return down


func _go_down() -> void:
	down = true
	awake = false
	_windup_left = -1.0
	_sprite.modulate = Color.WHITE
	_sprite.play(&"caido")
	Sfx.play(&"hit_heavy", -2.0)
	downed_signal.emit()


## O Tião caiu: o Bastião fica com raiva.
func enrage(factor: float) -> void:
	speed *= factor
	damage *= factor


## O herói fugiu: os dois voltam inteiros.
func reset() -> void:
	down = false
	awake = false
	health = max_health
	_sprite.play(&"idle")


func _physics_process(delta: float) -> void:
	if down or not awake or not is_instance_valid(leader) or leader.dead:
		velocity = Vector2.ZERO
		return
	var target := leader.target
	if target == null or target.is_dead():
		velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)
		move_and_slide()
		return
	_cooldown -= delta
	var to_target := target.global_position - global_position
	if _windup_left >= 0.0:
		velocity = velocity.move_toward(Vector2.ZERO, 900.0 * delta)
		_windup_left -= delta
		_sprite.modulate = Color(1.6, 1.2, 1.2) if int(_windup_left * 12.0) % 2 == 0 else Color.WHITE
		if _windup_left < 0.0:
			_sprite.modulate = Color.WHITE
			_strike(target)
	elif to_target.length() <= REACH and _cooldown <= 0.0:
		_windup_left = WINDUP
	else:
		# Chega pelo outro lado (os dois cercam você).
		var spot := target.global_position + Vector2(22.0 * _side, 4)
		var to_spot := spot - global_position
		velocity = velocity.move_toward(to_spot.normalized() * speed, 600.0 * delta) if to_spot.length() > 4.0 else Vector2.ZERO
		_side = 1.0 if (leader.global_position.x < target.global_position.x) else -1.0
	if absf(to_target.x) > 2.0:
		_sprite.flip_h = to_target.x < 0.0
	var anim := &"golpe" if _windup_left >= 0.0 else (&"walk" if velocity.length() > 8.0 else &"idle")
	if _sprite.animation != anim:
		_sprite.play(anim)
	move_and_slide()


func _strike(target: Player) -> void:
	_cooldown = COOLDOWN
	Sfx.play(&"swing", -4.0, 0.1)
	if target.global_position.distance_to(global_position) > REACH + 6.0:
		return
	var info := HitInfo.create(damage, global_position, target.global_position)
	info.knockback = 120.0
	info.poise_damage = 20.0
	info.attack_name = "Vassoura com faca"
	info.source = leader
	target.hurtbox.receive_hit(info)


func defeated() -> void:
	awake = false
	_hurtbox.set_deferred("monitorable", false)
	_sprite.play(&"caido")
	var tween := create_tween()
	tween.tween_interval(1.4)
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(queue_free)
