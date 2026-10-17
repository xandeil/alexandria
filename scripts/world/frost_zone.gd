class_name FrostZone
extends Node2D
## Um pedaço da arena que CONGELA (Cassian, fase 2: "congela partes da arena").
##
## Mesma linguagem de sempre: primeiro o AVISO (o retângulo azul enchendo),
## depois o efeito. Quando congela:
##   • quem estiver dentro fica preso num bloco de gelo (toques rápidos para sair);
##   • o chão ali vira GELO (escorrega) até derreter.
## Fora do aviso, nada acontece: é a regra "saia da área marcada".

var rect := Rect2(-24, -16, 48, 32)  # relativo à posição
var warning := 1.2
var duration := 6.0
## Toques para quebrar o bloco de quem ficou dentro (0 = não prende).
var trap_taps := 6
## Dano (e frio) em quem está dentro na hora em que congela (0 = só o gelo).
var damage := 0.0
var source: Node2D

var _time := 0.0
var _frozen := false


static func spawn(parent: Node, area: Rect2, warn: float, seconds: float, taps: int = 6,
		owner_node: Node2D = null) -> FrostZone:
	var zone := FrostZone.new()
	zone.position = area.get_center()
	zone.rect = Rect2(-area.size * 0.5, area.size)
	zone.warning = warn
	zone.duration = seconds
	zone.trap_taps = taps
	zone.source = owner_node
	parent.add_child(zone)
	return zone


func _ready() -> void:
	add_to_group(&"frost_zones")
	z_index = -2  # no chão, por baixo de quem anda
	material = Fx.unshaded


func is_frozen() -> bool:
	return _frozen


func covers(point: Vector2) -> bool:
	return Rect2(global_position + rect.position, rect.size).has_point(point)


func _physics_process(delta: float) -> void:
	_time += delta
	queue_redraw()
	if not _frozen and _time >= warning:
		_freeze()
	if _time >= warning + duration:
		queue_free()


func _freeze() -> void:
	_frozen = true
	Sfx.play(&"freeze", -2.0, 0.1)
	Fx.shake(2.0, 0.15)
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null or player.is_dead() or not covers(player.global_position):
		return
	# Primeiro prende, depois dói: um golpe normal daria i-frames ao herói e o
	# bloco não "pegaria". A geada vem do chão: dano sem empurrão nem cambaleio
	# (o mesmo caminho da queimadura), e o dash na hora certa escapa de tudo.
	if trap_taps > 0:
		IceBlock.trap(player, trap_taps)
	if damage > 0.0 and not player.hurtbox.invulnerable:
		player.apply_burn(damage)
		player.apply_chill(2.0)


func _draw() -> void:
	var fade := clampf((warning + duration - _time) / 0.8, 0.0, 1.0)
	if not _frozen:
		var t := clampf(_time / warning, 0.0, 1.0)
		draw_rect(rect, Color(0.55, 0.8, 1.0, 0.18))
		draw_rect(Rect2(rect.position, Vector2(rect.size.x, rect.size.y * t)), Color(0.55, 0.8, 1.0, 0.25))
		draw_rect(rect, Color(0.75, 0.92, 1.0, 0.9), false, 1.5)
		return
	# Congelado: placa de gelo com brilho (some devagar no fim).
	draw_rect(rect, Color(0.72, 0.9, 1.0, 0.42 * fade))
	for k in 4:
		var x := rect.position.x + rect.size.x * (0.15 + 0.22 * k)
		draw_line(Vector2(x, rect.position.y + 3), Vector2(x + 6, rect.end.y - 3), Color(1, 1, 1, 0.35 * fade), 1.0)
	draw_rect(rect, Color(0.85, 0.96, 1.0, 0.7 * fade), false, 1.0)
