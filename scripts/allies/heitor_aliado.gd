class_name HeitorAliado
extends Ally
## Heitor, o marido de Helena (v0.45, Etapa 8). Substitui o antigo Guarda Sem
## Posto. Alegre, armadura redonda, vive preso em lugares (poço, estátua, gelo).
## Salvo três vezes (heitor_gelo), ele entra com você na luta contra a Helena —
## ela não sabe que é ele. Ele também não.

const FRAMES := preload("res://assets/sprites/heitor_aliado_frames.tres")


func _setup() -> void:
	ally_id = "heitor"
	display_name = "Espada do Heitor"
	frames = FRAMES
	can_enter_arenas = true  # a única arena em que ele entra é a da Helena
	max_health = 190.0
	strike_damage = 15.0
	move_speed = 74.0


func _on_fall() -> String:
	return "Heitor caiu de joelhos. Ele volta para o lago do Domínio."
