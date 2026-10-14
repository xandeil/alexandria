class_name EchoChild
extends Node2D
## Fase 2 da Governanta: o ECO branco de uma criança. Aparece (aviso: ele
## surge devagar e mostra a direção), depois corre em linha reta até onde você
## estava. Não dá para bater num eco — só desviar.
## "No fim, restaram apenas ecos… e uma mesa vazia."

const SHEETS := [
	preload("res://assets/sprites/crianca_a.png"),
	preload("res://assets/sprites/crianca_b.png"),
]
const ECHO_MATERIAL := preload("res://shaders/echo_material.tres")
const GHOST := Color(1.0, 1.0, 1.0, 0.8)

var direction := Vector2.RIGHT
var speed := 150.0
var damage := 10.0
## Tempo surgindo (o aviso) e tempo correndo.
var appear_time := 0.65
var run_time := 1.3
## Some se sair daqui (não atravessa as paredes da sala).
var bounds := Rect2()
var source: Node2D

var _time := 0.0
var _hit := false
var _gone := false
var _sprite: Sprite2D


static func spawn(parent: Node, at: Vector2, toward: Vector2, owner_node: Node2D, echo_damage: float, echo_speed: float, area: Rect2) -> EchoChild:
	var echo := EchoChild.new()
	echo.direction = (toward - at).normalized() if toward.distance_to(at) > 1.0 else Vector2.RIGHT
	echo.source = owner_node
	echo.damage = echo_damage
	echo.speed = echo_speed
	echo.bounds = area
	parent.add_child(echo)
	echo.global_position = at
	return echo


func _ready() -> void:
	_sprite = Sprite2D.new()
	var atlas := AtlasTexture.new()
	atlas.atlas = SHEETS.pick_random()
	atlas.region = Rect2(0, 0, 24, 24)
	_sprite.texture = atlas
	_sprite.offset = Vector2(0, -12)
	_sprite.flip_h = direction.x < 0.0
	_sprite.material = ECHO_MATERIAL
	add_child(_sprite)
	modulate = Color(GHOST, 0.0)
	z_index = 2


func _physics_process(delta: float) -> void:
	if _gone:
		return
	_time += delta
	if _time < appear_time:
		modulate.a = GHOST.a * (_time / appear_time)
		queue_redraw()
		return
	var t := _time - appear_time
	global_position += direction * speed * delta
	_sprite.position.y = -absf(sin(t * 16.0)) * 2.0  # correndo
	queue_redraw()
	if not _hit:
		_try_hit()
	if t >= run_time or (bounds.size != Vector2.ZERO and not bounds.has_point(global_position)):
		vanish()


func _try_hit() -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null or player.is_dead():
		return
	if player.global_position.distance_to(global_position) > 10.0:
		return
	var info := HitInfo.create(damage, global_position - direction * 4.0, player.global_position)
	info.knockback = 110.0
	info.source = source
	info.attack_name = "Eco"
	if player.hurtbox.receive_hit(info):
		_hit = true
		vanish()


func vanish() -> void:
	if _gone:
		return
	_gone = true
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	tween.tween_callback(queue_free)


func _draw() -> void:
	# Aviso enquanto surge: um rastro tracejado para onde ele vai correr.
	if _time >= appear_time:
		return
	var alpha := 0.25 + 0.5 * (_time / appear_time)
	for i in 6:
		var a := direction * (8.0 + i * 10.0)
		draw_line(a, a + direction * 5.0, Color(1.0, 0.35, 0.3, alpha), 1.5)
