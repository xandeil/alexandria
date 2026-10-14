class_name Shockwave
extends Node2D
## Onda de Choque do Golpe Sísmico: uma fileira de estilhaços que corre pelo chão.
##
## • Machuca o herói uma vez (respeitando os i-frames do dash).
## • PAREDES e COBERTURAS seguram a onda (ela não atravessa a camada "mundo"):
##   é por isso que as coberturas existem na fase 1. Bater numa cobertura
##   também a desgasta um pouco.
## • Buraco aberto no caminho = sem chão para a onda correr: ela morre ali.

const ROCK := preload("res://assets/fx/shock_rock.png")
const STEP := 10.0  # a cada quantos pixels brota um estilhaço

var direction := Vector2.RIGHT
var speed := 170.0
var max_distance := 280.0
var damage := 24.0
var cover_damage := 12.0
var source: Node2D

var _travelled := 0.0
var _since_rock := STEP
var _hit_player := false


static func launch(parent: Node, from: Vector2, dir: Vector2, owner_node: Node2D, wave_damage: float, wave_speed: float, distance: float, damage_to_covers: float) -> Shockwave:
	var wave := Shockwave.new()
	wave.position = from
	wave.direction = dir.normalized()
	wave.source = owner_node
	wave.damage = wave_damage
	wave.speed = wave_speed
	wave.max_distance = distance
	wave.cover_damage = damage_to_covers
	parent.add_child(wave)
	return wave


func _ready() -> void:
	Sfx.play(&"shockwave", -6.0, 0.1)


func _physics_process(delta: float) -> void:
	var step := minf(speed * delta, max_distance - _travelled)
	var next := global_position + direction * step
	if _blocked(global_position, next) or _over_pit(next):
		_burst(global_position)
		queue_free()
		return
	global_position = next
	_travelled += step
	_since_rock += step
	if _since_rock >= STEP:
		_since_rock = 0.0
		_spawn_rock()
	_try_hit_player()
	if _travelled >= max_distance:
		queue_free()


## Raio contra a camada "mundo" (paredes e coberturas). Cobertura atingida leva dano.
func _blocked(from: Vector2, to: Vector2) -> bool:
	var query := PhysicsRayQueryParameters2D.create(from + Vector2(0, -3), to + direction * 4.0 + Vector2(0, -3), 1)
	if is_instance_valid(source) and source is CollisionObject2D:
		query.exclude = [(source as CollisionObject2D).get_rid()]
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return false
	var cover := hit.get("collider") as DestructibleCover
	if cover:
		cover.take_damage(cover_damage, direction)
	return true


func _over_pit(point: Vector2) -> bool:
	for node in get_tree().get_nodes_in_group(&"pits"):
		if (node as ArenaPit).contains_point(point, -2.0):
			return true
	return false


func _try_hit_player() -> void:
	if _hit_player:
		return
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null or player.is_dead():
		return
	if player.global_position.distance_to(global_position) > 12.0:
		return
	var info := HitInfo.create(damage, global_position - direction * 8.0, player.global_position)
	info.knockback = 150.0
	info.poise_damage = 20.0
	info.is_heavy = true
	info.attack_name = "Onda de Choque"
	info.unblockable = true  # corre pelo CHÃO: só a cobertura (ou o dash) segura
	info.source = source
	_hit_player = player.hurtbox.receive_hit(info)


func _spawn_rock() -> void:
	var rock := Sprite2D.new()
	rock.texture = ROCK
	rock.offset = Vector2(0, -5)
	rock.flip_h = randf() < 0.5
	rock.scale = Vector2(0.6, 0.1)
	get_parent().add_child(rock)
	rock.global_position = global_position + direction.orthogonal() * randf_range(-3.0, 3.0)
	var tween := rock.create_tween()
	tween.tween_property(rock, "scale", Vector2(1.45, 1.5), 0.07).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.2)
	tween.tween_property(rock, "scale", Vector2(1.1, 0.0), 0.22).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(rock, "modulate:a", 0.0, 0.22)
	tween.tween_callback(rock.queue_free)
	# Partículas em metade dos estilhaços: em celular fraco, criar nó demais pesa.
	if randf() < 0.5:
		Fx.sparks(rock.global_position + Vector2(0, -4), Vector2.UP, Color(1.0, 0.62, 0.3), 3, 60.0)
	elif randf() < 0.4:
		Fx.dust(rock.global_position, 2)


func _burst(at: Vector2) -> void:
	Fx.dust(at, 8)
	Fx.sparks(at + Vector2(0, -6), -direction, Color(1.0, 0.7, 0.4), 8)
