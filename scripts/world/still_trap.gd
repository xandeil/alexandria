class_name StillTrap
extends Node2D
## VITRINES QUE FECHAM (v0.35, Etapa 6 — Arquivo Profundo e Sala do Arconte):
## no Domínio, quem fica PARADO tempo demais vira peça de coleção. Uma
## vitrine de gelo se fecha em volta (IceBlock: toques rápidos para sair).
##
## Avisa antes: um anel de geada fecha em volta do herói enquanto o tempo
## parado corre. Andar, rolar ou atacar com passo zera a conta.
##
## No mapa: Level.still_trap = 3.0 (segundos parado; 0 = desligado).

const MOVE_EPSILON := 6.0
const WARN_FROM := 0.45
const TAPS := 6

var limit := 3.0
var still_time := 0.0
var _player: Player


static func attach(level: Node, seconds: float) -> StillTrap:
	var trap := StillTrap.new()
	trap.limit = seconds
	level.add_child(trap)
	return trap


func _ready() -> void:
	add_to_group(&"still_traps")
	top_level = true
	z_index = 2
	material = Fx.unshaded


func _physics_process(delta: float) -> void:
	_player = get_tree().get_first_node_in_group("player") as Player
	if _player == null or _player.is_dead() or _player.is_grabbed() or get_tree().paused:
		still_time = 0.0
		queue_redraw()
		return
	global_position = _player.global_position
	if _player.velocity.length() > MOVE_EPSILON:
		still_time = 0.0
	else:
		still_time += delta
		if still_time >= limit:
			still_time = 0.0
			close_case()
	queue_redraw()


## A vitrine fecha (público: testes).
func close_case() -> IceBlock:
	Fx.float_text(_player.global_position + Vector2(-16, -34), "...peça rara.", Color(0.75, 0.9, 1.0), 7)
	return IceBlock.trap(_player, TAPS, 3.0)


func _draw() -> void:
	var t := still_time / limit
	if t < WARN_FROM:
		return
	var k := (t - WARN_FROM) / (1.0 - WARN_FROM)
	# Quatro paredes de vidro chegando perto (o retângulo encolhe).
	var half := lerpf(26.0, 10.0, k)
	draw_rect(Rect2(Vector2(-half, -half - 8.0), Vector2(half * 2.0, half * 2.0)), Color(0.75, 0.9, 1.0, 0.25 + 0.5 * k), false, 1.0)
