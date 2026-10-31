class_name GuardaAliado
extends Ally
## O Guarda Sem Posto lutando ao seu lado (Bíblia: "Ele pode ser chamado para
## ajudar contra alguns mini-chefes"). Toda a luta vem da base Ally (v0.31);
## aqui fica só quem ele é e o que acontece quando cai.

const FRAMES := preload("res://assets/sprites/guarda_frames.tres")


## Mantido para quem já chamava assim (Level e testes antigos).
static func spawn(parent: Node, near: Player) -> GuardaAliado:
	return Ally.spawn_by_id("guarda", parent, near) as GuardaAliado


func _setup() -> void:
	ally_id = "guarda"
	display_name = "Espada do Guarda"
	frames = FRAMES


## Caiu de joelhos: volta para o Teatro. Fale com ele lá para chamar de novo.
func _on_fall() -> String:
	Game.flags["guarda_acompanha"] = false
	return "O Guarda caiu de joelhos. Ele volta para o Teatro."
