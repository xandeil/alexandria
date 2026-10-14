class_name Interactable
extends Area2D
## Algo com que o herói pode interagir (NPC, Câmara, portão...).
##
## O herói detecta a Interactable mais próxima; o botão "Cura" vira
## "Interagir" (como pede a Bíblia: "Interação/Cura" no mesmo botão).
## Quem usa esta área conecta o sinal `interacted` e decide o que fazer.

signal interacted(player: Player)

## Texto que aparece no botão (ex.: "Falar", "Descansar").
@export var prompt := "Interagir"
@export var enabled := true:
	set(value):
		enabled = value
		set_deferred("monitorable", value)  # deferred: seguro durante callbacks de física


func _ready() -> void:
	monitoring = false
	monitorable = enabled
	collision_layer = 32  # camada 6: "interacao"
	collision_mask = 0


func interact(player: Player) -> void:
	if enabled:
		interacted.emit(player)
