class_name GalenoAliado
extends Ally
## Galeno Vaz, o Escudo Sem Dono, lutando ao seu lado (v0.42, Etapa 7).
## Ajuda contra Durgan, Mabel e Rachel ("Lute comigo").
##
## É feliz de verdade porque esqueceu. Cada chefe vencido com ele devolve um
## FRAGMENTO de memória (galeno_fragmentos +1) — e ele ri menos. Quando cai,
## esquece um fragmento (−1) e fica mais feliz. É o inverso da Lúcia.
## Enorme, lento, escudo gigante: aguenta muito mais pancada que você.

const FRAMES := preload("res://assets/sprites/galeno_aliado_frames.tres")
const MAX_FRAGMENTS := 3


func _setup() -> void:
	ally_id = "galeno"
	display_name = "Espada curva de Galeno"
	frames = FRAMES
	max_health = 260.0
	strike_damage = 20.0
	move_speed = 66.0
	strike_reach = 24.0
	cooldown = 1.1


## O escudo gigante: metade do que chega nele.
func _on_hit(info: HitInfo) -> void:
	info.damage *= 0.5
	super._on_hit(info)


## Venceram juntos: um fragmento volta.
func _on_victory() -> void:
	Game.flags["galeno_fragmentos"] = mini(int(Game.flags.get("galeno_fragmentos", 0)) + 1, MAX_FRAGMENTS)


## Caiu: esquece um fragmento — e fica mais feliz.
func _on_fall() -> String:
	Game.flags["galeno_fragmentos"] = maxi(int(Game.flags.get("galeno_fragmentos", 0)) - 1, 0)
	Game.set_flag("galeno_caiu")
	Game.flags["galeno_acompanha"] = false
	return "Galeno caiu. Ele levanta rindo, um pouco mais leve."
