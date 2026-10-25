class_name PlayerShot
extends Node2D
## Projétil do HERÓI (virote da besta, flechas do arco).
##
## Irmão do Projectile dos inimigos, com a mesma defesa contra "tunneling"
## (raio do ponto anterior ao próximo contra as paredes). A diferença é o alvo:
## aqui procuramos HURTBOXES de inimigo com uma consulta de forma na camada
## delas — o mesmo filtro que a hitbox da espada usa.

signal struck(target: Hurtbox, info: HitInfo)
## Parou (acertou alguém, bateu na parede ou acabou o alcance). A nuvem de
## pólen nasce aqui.
signal landed(at: Vector2, parent: Node)

const BOLT := &"virote"
const ARROW := &"flecha"
const POLLEN := &"polen"
const HURTBOX_MASK := 16  # mesma camada que a hitbox do herói procura
const WORLD_MASK := 1

var kind := BOLT
var direction := Vector2.RIGHT
var speed := 300.0
var damage := 18.0
var poise_damage := 12.0
var knockback := 70.0
var max_distance := 220.0
var source: Node2D

var _traveled := 0.0
var _done := false
var _shape := CircleShape2D.new()


static func fire(parent: Node, from: Vector2, dir: Vector2, owner_node: Node2D, shot_damage: float,
		shot_kind: StringName) -> PlayerShot:
	var shot := PlayerShot.new()
	shot.kind = shot_kind
	shot.direction = dir.normalized() if dir != Vector2.ZERO else Vector2.RIGHT
	shot.source = owner_node
	shot.damage = shot_damage
	if shot_kind != BOLT:
		shot.speed = 240.0  # flecha: um pouco mais lenta, dá para ver o arco
	parent.add_child(shot)
	shot.global_position = from
	Sfx.play(&"swing", -4.0)
	return shot


func _ready() -> void:
	z_index = 6
	_shape.radius = 4.0
	if kind == POLLEN:
		material = Fx.unshaded


func _physics_process(delta: float) -> void:
	if _done:
		return
	var from := global_position
	var step := direction * speed * delta
	var space := get_world_2d().direct_space_state
	var ray := PhysicsRayQueryParameters2D.create(from, from + step, WORLD_MASK)
	if is_instance_valid(source) and source is CollisionObject2D:
		ray.exclude = [(source as CollisionObject2D).get_rid()]
	var wall := space.intersect_ray(ray)
	if not wall.is_empty():
		global_position = wall["position"]
		_finish(true)
		return
	global_position = from + step
	_traveled += step.length()
	if _try_hit(space):
		return
	if _traveled >= max_distance:
		_finish(false)
	queue_redraw()


func _try_hit(space: PhysicsDirectSpaceState2D) -> bool:
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = _shape
	query.transform = Transform2D(0.0, global_position + Vector2(0, -7))
	query.collision_mask = HURTBOX_MASK
	query.collide_with_areas = true
	query.collide_with_bodies = false
	for result in space.intersect_shape(query, 8):
		var target := result["collider"] as Hurtbox
		if target == null or (is_instance_valid(source) and target.owner_body == source):
			continue
		var info := HitInfo.create(damage, global_position - direction * 8.0, target.global_position)
		info.poise_damage = poise_damage
		info.knockback = knockback
		info.attack_name = {BOLT: "Virote", ARROW: "Flecha", POLLEN: "Flecha de pólen"}[kind]
		info.source = source
		if target.receive_hit(info):
			struck.emit(target, info)
			Fx.hitstop(0.03)
			_finish(true)
			return true
	return false


func _finish(spark: bool) -> void:
	_done = true
	if spark:
		Fx.sparks(global_position + Vector2(0, -7), -direction, Color(1.0, 0.9, 0.6), 5)
	landed.emit(global_position, get_parent())
	queue_free()


func _draw() -> void:
	var back := -direction * (7.0 if kind == BOLT else 9.0)
	var lift := Vector2(0, -7)
	match kind:
		BOLT:
			draw_line(lift + back, lift, Color(0.55, 0.36, 0.18), 2.0)
			draw_line(lift - direction * 2.0, lift + direction, Color(0.7, 0.95, 1.0), 2.0)  # ponta elétrica
		ARROW:
			draw_line(lift + back, lift, Color(0.62, 0.48, 0.34), 1.0)
			draw_circle(lift + back, 1.5, Color(0.9, 0.7, 0.8))
		POLLEN:
			draw_line(lift + back, lift, Color(0.62, 0.48, 0.34), 1.0)
			draw_circle(lift, 2.5, Color(1.0, 0.9, 0.45, 0.9))
