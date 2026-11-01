class_name PeriodicTrap
extends Node2D
## ARMADILHA PERIÓDICA (v0.31, Etapa 1): dispara sozinha, num ritmo fixo.
## Base dos marteletes das Forjas, das fendas de lava da Montanha e de futuros
## pêndulos. Regra de leitura igual à das placas de raio:
##
##   descanso ──► AVISO (o chão pisca, cada vez mais rápido) ──► GOLPE ──► descanso
##
## O dash passa ileso (i-frames), como em todo o resto do jogo. O escudo não
## segura (vem de cima/de baixo). Cada tipo só muda o desenho e o "extra" do
## golpe — o ritmo e o dano são os mesmos para todos.
##
## No mapa: Level.traps → {"kind": "pilao", "cells": [Vector2i(10, 4)], "period": 2.4,
##   "offset": 0.0, "damage": 30}   (offset desencontra armadilhas vizinhas)

const TILE := 16
const KINDS := ["pilao", "lava", "espinhos"]

var kind := "espinhos"
var cells: Array[Vector2i] = []
## Um ciclo inteiro (segundos): descanso + aviso + golpe.
var period := 2.4
var warning := 0.7
var active_time := 0.25
var damage := 24.0
## Começa adiantada (desencontra armadilhas lado a lado).
var offset := 0.0

var _set := {}
var _time := 0.0
var _struck := false


static func spawn(parent: Node, def: Dictionary) -> PeriodicTrap:
	var trap := PeriodicTrap.new()
	trap.kind = str(def.get("kind", "espinhos"))
	for cell: Variant in def.get("cells", []):
		trap.cells.append(cell as Vector2i)
	trap.period = float(def.get("period", trap.period))
	trap.warning = float(def.get("warning", trap.warning))
	trap.damage = float(def.get("damage", trap.damage))
	trap.offset = float(def.get("offset", 0.0))
	parent.add_child(trap)
	return trap


func _ready() -> void:
	add_to_group("traps")
	top_level = true  # desenha em coordenadas do mundo
	global_position = Vector2.ZERO
	z_index = -1
	material = Fx.unshaded
	for cell in cells:
		_set[cell] = true
	_time = fposmod(offset, period)


## Em que parte do ciclo está: "descanso", "aviso" ou "golpe".
func phase() -> String:
	var t := fposmod(_time, period)
	var rest := period - warning - active_time
	if t < rest:
		return "descanso"
	if t < rest + warning:
		return "aviso"
	return "golpe"


func covers(point: Vector2) -> bool:
	return _set.has(Level.cell_at(point))


func _physics_process(delta: float) -> void:
	var before := phase()
	_time += delta
	var now := phase()
	if now == "golpe" and before != "golpe":
		_struck = false
		_on_strike()
	if now == "golpe" and not _struck:
		_try_hit()
	queue_redraw()


## O "extra" de cada tipo, na hora do golpe.
func _on_strike() -> void:
	match kind:
		"pilao":
			Sfx.play(&"slam", -8.0, 0.1)
			Fx.shake(1.2, 0.1)
		"lava":
			Sfx.play(&"fire_breath", -10.0, 0.1)
			for cell in cells:  # a fenda deixa fogo no chão (FirePatch)
				FirePatch.spawn(get_parent(), Vector2(cell * TILE) + Vector2(8, 10), 8.0, 1.0, 8.0)
		_:
			Sfx.play(&"crumble", -10.0, 0.1)


func _try_hit() -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null or player.is_dead() or not covers(player.global_position):
		return
	var info := HitInfo.create(damage, player.global_position + Vector2(0, -4), player.global_position)
	info.knockback = 80.0
	info.poise_damage = 25.0
	info.unblockable = true
	info.attack_name = {"pilao": "Martelete", "lava": "Fenda de lava"}.get(kind, "Armadilha")
	info.damage_type = "fogo" if kind == "lava" else "fisico"
	if player.hurtbox.receive_hit(info):
		_struck = true


func _draw() -> void:
	var now := phase()
	var rest := period - warning - active_time
	var t := clampf((fposmod(_time, period) - rest) / warning, 0.0, 1.0)
	var color: Color = {"pilao": Color(0.85, 0.7, 0.45), "lava": Color(1.0, 0.45, 0.15)}.get(kind, Color(0.8, 0.8, 0.85))
	for cell in cells:
		var rect := Rect2(Vector2(cell * TILE) + Vector2.ONE, Vector2(TILE - 2, TILE - 2))
		match now:
			"golpe":
				draw_rect(rect, Color(color, 0.75))
				if kind == "pilao":  # a cabeça do pilão bate no chão
					draw_rect(rect.grow(-2), Color(0.35, 0.3, 0.25, 0.95))
			"aviso":
				var pulse := 0.5 + 0.5 * sin(_time * (10.0 + 20.0 * t))
				draw_rect(rect, Color(color, 0.08 + 0.3 * t * pulse))
				draw_rect(rect, Color(color, 0.35 + 0.5 * t), false, 1.0)
			_:
				draw_rect(rect, Color(color, 0.12), false, 1.0)
