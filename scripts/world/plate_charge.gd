class_name PlateCharge
extends Node2D
## Placas de metal que vão levar um CHOQUE (Forjas Ocas).
## Bíblia: "O chão é de placas metálicas e o raio corre por elas; placas acesas
## indicam onde não pisar."
##
## Ciclo: as placas ACENDEM (aviso amarelo pulsando) → o raio corre (branco,
## faíscas) → apagam. Quem estiver em cima de uma placa no choque leva dano.
## O escudo não segura (o raio vem do chão); o dash por cima passa ileso.

const TILE := 16

var cells: Array[Vector2i] = []
var warning := 0.9
var active_time := 0.3
var damage := 20.0
var source: Node2D

var _set := {}
var _time := 0.0
var _hit := false
var _zapped := false


static func spawn(parent: Node, plate_cells: Array[Vector2i], warning_time: float, shock_damage: float,
		owner_node: Node2D = null) -> PlateCharge:
	var charge := PlateCharge.new()
	charge.cells = plate_cells
	charge.warning = warning_time
	charge.damage = shock_damage
	charge.source = owner_node
	parent.add_child(charge)
	return charge


func _ready() -> void:
	add_to_group("plate_charges")
	top_level = true  # desenha em coordenadas do mundo
	global_position = Vector2.ZERO
	z_index = -1
	material = Fx.unshaded  # placa acesa brilha no escuro da fábrica
	for cell in cells:
		_set[cell] = true
	if cells.is_empty():
		queue_free()


func is_live() -> bool:
	return _time >= warning and _time < warning + active_time


func covers(point: Vector2) -> bool:
	return _set.has(Level.cell_at(point))


func _physics_process(delta: float) -> void:
	_time += delta
	queue_redraw()
	if _time >= warning and not _zapped:
		_zapped = true
		Sfx.play(&"zap", -4.0, 0.1)
		Fx.shake(1.5, 0.12)
	if is_live() and not _hit:
		var player := get_tree().get_first_node_in_group("player") as Player
		if player and not player.is_dead() and covers(player.global_position):
			var info := HitInfo.create(damage, player.global_position + Vector2(0, 6), player.global_position)
			info.knockback = 60.0
			info.poise_damage = 20.0
			info.unblockable = true
			info.attack_name = "Raio nas placas"
			info.source = source if is_instance_valid(source) else null
			if player.hurtbox.receive_hit(info):
				_hit = true
				Fx.sparks(player.global_position + Vector2(0, -6), Vector2.UP, Color(1.0, 0.95, 0.5), 12)
	if _time >= warning + active_time:
		queue_free()


func _draw() -> void:
	var live := is_live()
	var t := clampf(_time / warning, 0.0, 1.0)
	for cell in cells:
		var rect := Rect2(Vector2(cell * TILE) + Vector2.ONE, Vector2(TILE - 2, TILE - 2))
		if live:
			draw_rect(rect, Color(1.0, 0.98, 0.75, 0.55))
			var a := rect.position + Vector2(1, randf() * rect.size.y)
			for k in 4:  # um zigue-zague de raio dentro da placa
				var b := rect.position + Vector2((k + 1) * rect.size.x / 4.0, randf() * rect.size.y)
				draw_line(a, b, Color(1, 1, 1, 0.95), 1.0)
				a = b
		else:
			var pulse := 0.5 + 0.5 * sin(_time * (12.0 + 18.0 * t))
			draw_rect(rect, Color(1.0, 0.85, 0.2, 0.08 + 0.22 * t * pulse))
			draw_rect(rect, Color(1.0, 0.85, 0.25, 0.4 + 0.5 * t), false, 1.0)
