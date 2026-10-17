class_name FirePatch
extends Node2D
## Fogo no chão (Montanha Carbonizada): o hálito de Rachel, o lança-chamas do
## Capitão, a Brasa Viva e as bolas de fogo deixam chamas que QUEIMAM quem
## fica em cima — um pouco de vida a cada meio segundo, sem cambalear.
## O dash por cima não queima (i-frames). A chama encolhe e apaga sozinha.

const TICK := 0.5

var radius := 14.0
var duration := 2.5
## Dano por segundo (aplicado em pedaços a cada TICK).
var dps := 10.0
var source: Node2D

var _time := 0.0
var _tick := 0.0
var _seed := 0.0


static func spawn(parent: Node, at: Vector2, patch_radius: float, seconds: float, damage_per_second: float,
		owner_node: Node2D = null) -> FirePatch:
	var patch := FirePatch.new()
	patch.radius = patch_radius
	patch.duration = seconds
	patch.dps = damage_per_second
	patch.source = owner_node
	patch.position = at
	parent.add_child(patch)
	return patch


func _ready() -> void:
	add_to_group("fire_patches")
	z_index = -1
	material = Fx.unshaded  # fogo brilha no escuro da caverna
	_seed = randf() * 10.0


func current_radius() -> float:
	var fade := clampf((duration - _time) / 0.6, 0.0, 1.0)  # encolhe no fim
	return radius * (0.4 + 0.6 * fade)


func covers(point: Vector2) -> bool:
	var r := current_radius()
	var d := point - global_position
	return (d.x * d.x) / (r * r) + (d.y * d.y) / (r * r * 0.45) <= 1.0  # elipse (vista 3/4)


func _physics_process(delta: float) -> void:
	_time += delta
	queue_redraw()
	if _time >= duration:
		queue_free()
		return
	_tick -= delta
	if _tick > 0.0:
		return
	_tick = TICK
	var player := get_tree().get_first_node_in_group("player") as Player
	if player and covers(player.global_position):
		player.apply_burn(dps * TICK)


func _draw() -> void:
	var r := current_radius()
	var t := _time * 9.0 + _seed
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.67))
	draw_circle(Vector2.ZERO, r, Color(0.55, 0.12, 0.04, 0.35))
	draw_circle(Vector2.ZERO, r * 0.7, Color(0.95, 0.4, 0.08, 0.35))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	for k in 5:  # labaredas tremendo
		var a := k * TAU / 5.0 + sin(t + k) * 0.3
		var p := Vector2.from_angle(a) * r * 0.45 * Vector2(1.0, 0.67)
		var h := 4.0 + 3.0 * (0.5 + 0.5 * sin(t * 1.7 + k * 2.1))
		draw_colored_polygon(PackedVector2Array([p + Vector2(-2.5, 0), p + Vector2(2.5, 0), p + Vector2(0, -h)]),
			Color(1.0, 0.75, 0.25, 0.8))
