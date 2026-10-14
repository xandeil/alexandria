class_name SleepRing
extends Node2D
## Anel lilás que se expande (o bocejo do Vigia, a explosão da Mãe dos Esporos).
## Não machuca: dá SONO. Quem atravessa com o dash não sente nada.
## (Irmão do ScreamRing da Governanta — mesma leitura, outro efeito.)

var max_radius := 120.0
var speed := 110.0
var thickness := 14.0
var drowsiness := 45.0
var radius := 6.0

var _hit := false


static func spawn(parent: Node, at: Vector2, reach: float = 120.0, sleepiness: float = 45.0) -> SleepRing:
	var ring := SleepRing.new()
	ring.max_radius = reach
	ring.drowsiness = sleepiness
	ring.position = at
	parent.add_child(ring)
	return ring


func _ready() -> void:
	z_index = 6


func _physics_process(delta: float) -> void:
	radius += speed * delta
	if radius >= max_radius:
		queue_free()
		return
	queue_redraw()
	if _hit:
		return
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null or player.is_dead() or player.state == Player.State.DASH:
		return
	if absf(player.global_position.distance_to(global_position) - radius) <= thickness * 0.5 + 3.0:
		_hit = true
		player.add_drowsiness(drowsiness)
		Fx.splash(player.global_position + Vector2(0, -12), Color(0.75, 0.68, 1.0), 6)


func _draw() -> void:
	var t := clampf(radius / max_radius, 0.0, 1.0)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 56, Color(0.78, 0.7, 1.0, 0.75 - 0.5 * t), thickness * 0.5)
	draw_arc(Vector2.ZERO, radius + thickness * 0.4, 0.0, TAU, 56, Color(1.0, 1.0, 1.0, 0.3 - 0.25 * t), 1.0)
