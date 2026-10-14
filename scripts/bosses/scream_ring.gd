class_name ScreamRing
extends Node2D
## O grito da Governanta: um ANEL que se expande a partir dela.
## Acerta UMA vez quem estiver na faixa do anel quando ele passa.
##
## Como escapar: ficar fora do alcance (o aviso vermelho no chão mostra até
## onde ele vai) ou ATRAVESSAR o anel com o dash — os i-frames do dash fazem
## o golpe "passar" por você (Hurtbox.receive_hit devolve false).

var radius := 10.0
var max_radius := 120.0
var speed := 150.0
## Largura da faixa que machuca (px).
var thickness := 10.0
var damage := 18.0
var knockback := 170.0
var source: Node2D

var _hit := false
var _fading := false


static func launch(parent: Node, at: Vector2, owner_node: Node2D, ring_damage: float, ring_speed: float, reach: float) -> ScreamRing:
	var ring := ScreamRing.new()
	ring.source = owner_node
	ring.damage = ring_damage
	ring.speed = ring_speed
	ring.max_radius = reach
	parent.add_child(ring)
	ring.global_position = at
	return ring


func _ready() -> void:
	z_index = -1  # desenhado no chão, por baixo dos personagens
	material = Fx.unshaded  # brilha mesmo no escuro do laboratório


func _physics_process(delta: float) -> void:
	if _fading:
		return
	radius += speed * delta
	queue_redraw()
	if not _hit:
		_try_hit()
	if radius >= max_radius:
		_fading = true
		var tween := create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.2)
		tween.tween_callback(queue_free)


func _try_hit() -> void:
	if damage <= 0.0:
		return  # anel só visual (ela se erguendo, troca de fase)
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null or player.is_dead():
		return
	var distance := player.global_position.distance_to(global_position)
	if absf(distance - radius) > thickness * 0.5 + 4.0:
		return
	var info := HitInfo.create(damage, global_position, player.global_position)
	info.knockback = knockback
	info.is_heavy = true
	info.source = source
	info.attack_name = "Grito"
	info.unblockable = true  # o grito atravessa o escudo: a lição é o dash
	if player.hurtbox.receive_hit(info):
		_hit = true


func _draw() -> void:
	var t := clampf(radius / max_radius, 0.0, 1.0)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 56, Color(1.0, 0.96, 0.95, 0.85 - 0.5 * t), thickness * 0.5)
	draw_arc(Vector2.ZERO, radius - thickness * 0.45, 0.0, TAU, 56, Color(1.0, 0.35, 0.3, 0.55 - 0.4 * t), 1.5)
	draw_arc(Vector2.ZERO, radius + thickness * 0.45, 0.0, TAU, 56, Color(1.0, 1.0, 1.0, 0.35 - 0.3 * t), 1.0)
