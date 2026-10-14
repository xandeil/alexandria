class_name RestChamber
extends StaticBody2D
## Câmara do jogador — a cápsula diante do palco. Ponto de descanso e salvamento.
## Bíblia: "Aos poucos o jogador percebe que é o quarto dele."
##
## Descansar: vida, estamina e Frascos de Vida de volta, os inimigos voltam a
## existir (eles "morrem e estagnam") e o jogo salva. A visão NÃO volta —
## só o Frasco de Sanidade devolve o que as mortes tiraram.

signal rest_requested(chamber: RestChamber)

@export var spawn_id := "camara"

@onready var interactable: Interactable = $Interactable
@onready var glow: PointLight2D = $Glow

var _time := 0.0


func _ready() -> void:
	interactable.interacted.connect(func(_player: Player): rest_requested.emit(self))


func _process(delta: float) -> void:
	_time += delta
	glow.energy = 0.55 + sin(_time * 1.6) * 0.12


func set_available(available: bool) -> void:
	interactable.enabled = available
	glow.color = Color(0.4, 0.86, 0.53) if available else Color(0.7, 0.2, 0.2)
