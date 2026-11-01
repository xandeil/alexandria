class_name BastiaoAliado
extends Ally
## Bastião, um dos brigões (v0.43, Etapa 7). Ajuda contra mini-chefes: você
## chama ("Me ajuda aqui?") e ele luta até o mini-chefe cair. Cada luta
## vencida junto soma 1 em "bastiao_ajudas". Com "brigoes_juntos", vêm os dois.

const FRAMES := preload("res://assets/sprites/bastiao_aliado_frames.tres")


func _setup() -> void:
	ally_id = "bastiao"
	display_name = "Vassoura do Bastião"
	frames = FRAMES
	max_health = 170.0
	strike_damage = 17.0
	move_speed = 84.0


## Venceram o mini-chefe: conta a ajuda e volta para o canto dele.
func _on_victory() -> void:
	Game.flags["bastiao_ajudas"] = int(Game.flags.get("bastiao_ajudas", 0)) + 1
	Game.flags["bastiao_acompanha"] = false


func _on_fall() -> String:
	Game.flags["bastiao_acompanha"] = false
	return "Bastião caiu. Ele volta reclamando para o canto dele."
