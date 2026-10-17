class_name BrasaViva
extends Enemy
## Brasa Viva — Montanha Carbonizada.
## Bíblia: "Pequena chama que persegue e explode. O fogo de Rachel que nunca apagou."
##
## Rápida e fraca (um golpe apaga). Chegou perto: para, INCHA (círculo de aviso)
## e estoura — deixando fogo no chão. Corte antes de ela chegar, ou dê dash
## para fora do círculo. Apagada a golpe, ela só solta faíscas.

enum AI { IDLE, CHASE, IGNITE }

@export var ignite_range := 16.0
@export var ignite_time := 0.55
@export var burst_radius := 24.0
@export var burst_damage := 16.0

var ai := AI.IDLE
var _ai_time := 0.0
var _flicker := 0.0


func _physics_process(delta: float) -> void:
	if dead:
		return
	_ai_time += delta
	_flicker += delta
	target = find_target()
	match ai:
		AI.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
			if target and global_position.distance_to(target.global_position) <= aggro_range:
				ai = AI.CHASE
		AI.CHASE:
			if target == null:
				ai = AI.IDLE
			else:
				var to_target := target.global_position - global_position
				facing = to_target.normalized()
				var wobble := facing.orthogonal() * sin(_flicker * 7.0) * 0.4
				velocity = velocity.move_toward((facing + wobble).normalized() * move_speed, acceleration * delta)
				if to_target.length() <= ignite_range:
					_ignite()
		AI.IGNITE:
			velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)
			visual.scale = Vector2.ONE * (1.0 + 0.6 * _ai_time / ignite_time)
			if _ai_time >= ignite_time:
				_burst()
	move_and_slide()
	body_sprite.speed_scale = 1.0 + (2.0 if ai == AI.IGNITE else 0.0)


func _ignite() -> void:
	ai = AI.IGNITE
	_ai_time = 0.0
	Sfx.play(&"hum", -10.0, 0.2)
	# O aviso e o estouro são os mesmos da explosão de carne, em versão fogo.
	FleshBurst.spawn(get_parent(), global_position, burst_radius, ignite_time, burst_damage, self, false, Vector2.INF, "fogo")


## Estourou sozinha: some (a explosão já está no chão).
func _burst() -> void:
	dead = true
	remove_from_group("enemies")
	hurtbox.set_deferred("monitorable", false)
	queue_free()


## Apagada a golpe ANTES de estourar: só faíscas (e cancela a explosão).
func _on_died() -> void:
	if ai == AI.IGNITE:
		for node in get_tree().get_nodes_in_group("flesh_bursts"):
			var burst := node as FleshBurst
			if burst and burst.source == self:
				burst.queue_free()
	Fx.sparks(global_position + Vector2(0, -6), Vector2.UP, Color(1.0, 0.6, 0.2), 10)
	super._on_died()
