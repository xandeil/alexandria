class_name Hurtbox
extends Area2D
## Área que RECEBE dano. Ela não calcula nada: só avisa o dono por sinal.
## O dono (herói, soldado, Helena) decide se bloqueia, cambaleia ou morre.

signal hit_received(info: HitInfo)

## Corpo dono desta hurtbox (evita que alguém acerte a si mesmo).
@export var owner_body: Node2D

## i-frames: true durante o dash, o descanso e logo após levar dano.
var invulnerable := false


func _ready() -> void:
	monitoring = false
	monitorable = true


## Retorna true se o golpe foi aceito (false = esquivou nos i-frames).
func receive_hit(info: HitInfo) -> bool:
	if invulnerable:
		return false
	hit_received.emit(info)
	return true
