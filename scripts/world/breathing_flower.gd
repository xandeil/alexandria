class_name BreathingFlower
extends Node2D
## FLOR QUE RESPIRA (v0.35, Etapa 6 — Dormitório Sob o Musgo): uma variação
## do PollenCloud. Ela não ataca ninguém. Ela RESPIRA o ar em volta: quem
## corre ou rola perto dela agita o ar e ela solta uma nuvem de pólen.
## Andar devagar não dispara. A lição do Vigia, de novo: aqui se anda devagar.
##
## No mapa: Level.traps → {"kind": "flor", "cells": [Vector2i(8, 10), Vector2i(14, 12)]}

const TILE := 16
## Até onde a flor "sente" o ar mexer (px).
const REACH := 42.0
const COOLDOWN := 3.5

var _cooldown := 0.0
var _time := 0.0


static func spawn_all(parent: Node, def: Dictionary) -> Array[BreathingFlower]:
	var made: Array[BreathingFlower] = []
	for cell: Variant in def.get("cells", []):
		var flower := BreathingFlower.new()
		flower.position = Vector2((cell as Vector2i) * TILE) + Vector2(8, 12)
		parent.add_child(flower)
		made.append(flower)
	return made


func _ready() -> void:
	add_to_group(&"breathing_flowers")
	_time = randf() * TAU


## O jogador está agitando o ar perto dela?
func disturbed_by(player: Player) -> bool:
	if player == null or player.is_dead():
		return false
	if player.global_position.distance_to(global_position) > REACH:
		return false
	return player.sprinting or player.state == Player.State.DASH


func _physics_process(delta: float) -> void:
	_time += delta
	_cooldown = maxf(_cooldown - delta, 0.0)
	if _cooldown <= 0.0 and disturbed_by(get_tree().get_first_node_in_group("player") as Player):
		exhale()
	queue_redraw()


## Solta o pólen (público: testes).
func exhale() -> PollenCloud:
	_cooldown = COOLDOWN
	Sfx.play(&"crumble", -14.0, 0.2)
	return PollenCloud.spawn(get_parent(), global_position + Vector2(0, -4), 30.0, 3.0)


func _draw() -> void:
	# A flor "respira": abre e fecha devagar. Depois de soltar, murcha um pouco.
	var breath := 0.5 + 0.5 * sin(_time * 1.6)
	var open := lerpf(2.0, 3.6, breath) * (0.6 if _cooldown > 0.0 else 1.0)
	draw_line(Vector2(0, 2), Vector2(0, -3), Color(0.3, 0.5, 0.3), 1.0)
	for i in 5:
		var dir := Vector2.from_angle(TAU * i / 5.0 - PI * 0.5)
		draw_circle(Vector2(0, -5) + dir * open, 1.8, Color(0.78, 0.66, 0.92, 0.95))
	draw_circle(Vector2(0, -5), 1.5, Color(1.0, 0.92, 0.55))
