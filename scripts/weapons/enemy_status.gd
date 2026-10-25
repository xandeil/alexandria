class_name EnemyStatus
extends Node
## Efeitos que as armas de chefe deixam nos inimigos: lentidão (pólen),
## exaustão (Fuso do Arconte) e sangramento (Presas da Vorágine).
##
## Por que um nó separado e não variáveis no Enemy? Composição: são 30 tipos de
## inimigo, cada um com o seu _physics_process. Em vez de mexer em todos, este
## nó é PENDURADO no inimigo só quando um efeito pega (EnemyStatus.of) e cuida
## do próprio tempo. O Enemy só pergunta "quanto mais devagar eu ataco?".

const SLOW_FACTOR := 0.5  ## pólen: movimento e animação pela metade
const DRAIN_ATTACK_DELAY := 1.6  ## exausto: o próximo golpe demora 60% mais para sair
const BLEED_MAX := 100.0
const BLEED_DECAY := 8.0  ## por segundo, quando não está apanhando

var enemy: Enemy
var slow_left := 0.0
var drain_left := 0.0
var bleed := 0.0

var _base_move_speed := -1.0
var _tint := 0.0


## O status do inimigo (cria na primeira vez).
static func of(target: Enemy) -> EnemyStatus:
	var status := target.get_node_or_null(^"EnemyStatus") as EnemyStatus
	if status == null:
		status = EnemyStatus.new()
		status.name = "EnemyStatus"
		status.enemy = target
		target.add_child(status)
	return status


## Só consulta (não cria): para quem quer saber sem pendurar nada.
static func find(target: Node) -> EnemyStatus:
	return target.get_node_or_null(^"EnemyStatus") as EnemyStatus


func apply_slow(seconds: float) -> void:
	if slow_left <= 0.0:
		_base_move_speed = enemy.move_speed
		enemy.move_speed = _base_move_speed * SLOW_FACTOR
	slow_left = maxf(slow_left, seconds)


func apply_drain(seconds: float) -> void:
	drain_left = maxf(drain_left, seconds)


## Soma sangramento. Devolve true quando a barra enche (e esvazia: estourou).
func add_bleed(amount: float) -> bool:
	bleed += amount
	if bleed >= BLEED_MAX:
		bleed = 0.0
		return true
	return false


func is_slowed() -> bool:
	return slow_left > 0.0


## O Enemy multiplica a duração do golpe por isto ao começar um ataque.
## A exaustão vale para UM golpe: ao ser usada, acaba.
func consume_attack_scale() -> float:
	var scale := 1.0
	if slow_left > 0.0:
		scale /= SLOW_FACTOR
	if drain_left > 0.0:
		scale *= DRAIN_ATTACK_DELAY
		drain_left = 0.0
	return scale


func _physics_process(delta: float) -> void:
	if not is_instance_valid(enemy) or enemy.dead:
		return
	if slow_left > 0.0:
		slow_left -= delta
		var sprite := enemy.body_sprite
		if sprite:
			sprite.speed_scale = minf(sprite.speed_scale, SLOW_FACTOR)
		if slow_left <= 0.0:
			enemy.move_speed = _base_move_speed
			if sprite:
				sprite.speed_scale = 1.0
	if drain_left > 0.0:
		drain_left -= delta
	if bleed > 0.0:
		bleed = maxf(bleed - BLEED_DECAY * delta, 0.0)
	# Um véu de cor por cima do inimigo diz qual efeito pegou.
	var want := Color.WHITE
	if slow_left > 0.0:
		want = Color(1.0, 0.95, 0.7)  # pólen dourado
	elif drain_left > 0.0:
		want = Color(0.75, 0.88, 1.0)  # gelo do Arconte
	elif bleed > 30.0:
		want = Color(1.0, 0.8, 0.8)
	if enemy.body_sprite:
		enemy.body_sprite.self_modulate = enemy.body_sprite.self_modulate.lerp(want, 8.0 * delta)
