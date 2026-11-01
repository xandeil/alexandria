class_name TiaoAliado
extends Ally
## Tião, um dos brigões (v0.43, Etapa 7). Ajuda contra mini-chefes: você
## chama ("Me ajuda aqui?") e ele luta até o mini-chefe cair. Cada luta
## vencida junto soma 1 em "tiao_ajudas". Com "brigoes_juntos", vêm os dois.

const FRAMES := preload("res://assets/sprites/tiao_aliado_frames.tres")


func _setup() -> void:
	ally_id = "tiao"
	display_name = "Colher de pau do Tião"
	frames = FRAMES
	max_health = 200.0
	strike_damage = 15.0
	move_speed = 70.0


## Venceram o mini-chefe: conta a ajuda e volta para o canto dele.
func _on_victory() -> void:
	Game.flags["tiao_ajudas"] = int(Game.flags.get("tiao_ajudas", 0)) + 1
	Game.flags["tiao_acompanha"] = false


func _on_fall() -> String:
	Game.flags["tiao_acompanha"] = false
	return "Tião caiu. Ele volta reclamando para o canto dele."
