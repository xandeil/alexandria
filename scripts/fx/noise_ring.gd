class_name NoiseRing
extends Node2D
## Anel fraco em volta do herói mostrando o RAIO do barulho que ele faz.
## Só aparece quando há alguém que "ouve" por perto (grupo "listeners":
## Sonâmbulos, o Vigia) — na Cidade não polui a tela.
##
## Furtividade sem feedback é adivinhação. O anel ensina a regra sozinho:
## dash e golpe = anel grande; andar devagar = nada.

const SHOW_DISTANCE := 240.0

var player: Player
var _alpha := 0.0


func _ready() -> void:
	z_index = -1
	position = Vector2(0, -2)


func _process(delta: float) -> void:
	var wanted := 0.0
	if is_instance_valid(player) and player.noise > 12.0 and _listener_nearby():
		wanted = clampf(player.noise / 110.0, 0.25, 0.6)
	_alpha = move_toward(_alpha, wanted, 3.0 * delta)
	queue_redraw()


func _listener_nearby() -> bool:
	for node in get_tree().get_nodes_in_group("listeners"):
		var listener := node as Node2D
		if listener and listener.global_position.distance_to(player.global_position) < SHOW_DISTANCE:
			return true
	return false


func _draw() -> void:
	if _alpha <= 0.01 or not is_instance_valid(player):
		return
	var radius := maxf(player.noise, 12.0)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, Color(1.0, 1.0, 1.0, _alpha * 0.5), 1.0)
	draw_arc(Vector2.ZERO, radius * 0.7, 0.0, TAU, 40, Color(0.8, 0.85, 1.0, _alpha * 0.25), 1.0)
