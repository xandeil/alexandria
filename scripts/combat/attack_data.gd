class_name AttackData
extends Resource
## Os dados de UM golpe (do herói, dos inimigos e dos chefes).
##
## Por que um Resource? É o equivalente ao ScriptableObject da Unity: os números
## do golpe ficam num arquivo .tres que você ajusta no Inspector, sem tocar no
## código. Ex.: data/attacks/player_light_1.tres. Separar DADOS de COMPORTAMENTO
## é o que permite balancear o jogo rápido (e testar com o celular na mão).

@export var display_name := "Golpe"

@export_group("Custo e dano")
@export var stamina_cost := 18.0
@export var damage := 20.0
## Dano na postura/guarda: escudos dos Soldados Remendados e cambaleio.
@export var poise_damage := 20.0
@export var knockback := 110.0
## Golpes fortes quebram guarda mais fácil e têm sensação mais pesada.
@export var is_heavy := false

@export_group("Step and Anchor (segundos)")
## 1) Antecipação: o movimento trava e o corpo freia.
@export var windup_time := 0.10
## 2) Micro-impulso físico para frente (px/s) durante lunge_time.
@export var lunge_speed := 170.0
@export var lunge_time := 0.06
## 3) Freio seco: a hitbox fica ativa por active_time com o corpo PARADO.
@export var active_time := 0.08
## 4) Recuperação: vulnerável, não dá para cancelar. É aqui que o jogo pune.
@export var recovery_time := 0.22
## Últimos X segundos da recuperação aceitam o próximo golpe do combo.
@export var combo_window := 0.14
## Estocadas: a hitbox já machuca durante o avanço (ex.: estocada da Helena).
@export var active_during_lunge := false
## Agarrões (o abraço da Governanta, o civil): o escudo não segura — só o dash.
@export var unblockable := false

@export_group("Mira (inimigos)")
## Durante o windup a mira acompanha o alvo até esta fração do tempo...
## ...depois TRAVA. É isso que torna o golpe esquivável (telegraph justo).
@export_range(0.0, 1.0) var track_until := 0.6

@export_group("Hitbox")
## Distância do centro da hitbox até o corpo, na direção do golpe.
@export var reach := 13.0
@export var radius := 11.0

@export_group("Sensação (game feel)")
@export var hitstop := 0.06
@export var shake := 2.0
@export var slash_arc_degrees := 140.0
@export var slash_radius := 16.0
@export var slash_color := Color(1, 1, 1, 0.9)
@export var sound: StringName = &"swing"

@export_group("Escala por atributo")
@export_enum("nenhum", "forca", "destreza") var scaling_attribute := "destreza"
## +X de dano por ponto acima de 10 no atributo (0.03 = +3%).
@export var scaling_per_point := 0.03


## Duração total do golpe (útil para IA e para testes).
func total_time() -> float:
	return windup_time + lunge_time + active_time + recovery_time
