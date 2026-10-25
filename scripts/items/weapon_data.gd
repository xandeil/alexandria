class_name WeaponData
extends ItemData
## Uma arma: é um item (nome, ícone, lore, aparece no inventário) COM números de
## combate. Herdar de ItemData é o "L" do SOLID (Liskov): todo lugar que lida
## com itens continua funcionando com armas, sem saber que elas são armas.
##
## O golpe em si continua nos AttackData (.tres). A arma só diz:
##   • QUAIS golpes usar (combo leve e golpe forte próprios, ou os do herói);
##   • quanto eles rendem (dano, velocidade, estamina) e com quais atributos
##     escalam (as letras S/A/B/C/D/E, como nos soulslike);
##   • qual HABILIDADE única ela tem (skill → WeaponSkills).
##
## Duas da mesma arma = uma em cada mão: por isso max_stack é 2 (o Ferreiro
## forja uma cópia).

## Quanto cada letra rende por ponto de atributo acima de 10.
const SCALING_PER_POINT := {"S": 0.045, "A": 0.035, "B": 0.028, "C": 0.021, "D": 0.013, "E": 0.007}
## Nomes curtos para a tabela de escalas (inventário).
const ATTRIBUTE_SHORT := {"forca": "FOR", "destreza": "DES", "magia": "MAG", "fe": "FÉ", "sorte": "SOR"}
const SCALING_ATTRIBUTES: Array[String] = ["forca", "destreza", "magia", "fe", "sorte"]

## "Espada", "Martelo", "Besta"...
@export var weapon_class := "Espada"
## Atributo → letra. Ex.: {"forca": "B", "magia": "C"}.
@export var scaling := {}
## Golpes próprios (vazio/null = os do herói).
@export var light_combo: Array[AttackData] = []
@export var heavy_attack: AttackData
## Ataque especial: L2 com a arma em DUAS MÃOS. Nas armas de chefe é onde mora
## a habilidade (a onda do Pilar, o fogo da Presa de Caelis...).
@export var special_attack: AttackData
@export var damage_scale := 1.0
## Multiplica o tempo de preparo e de recuperação (0.8 = 20% mais rápida).
@export var speed_scale := 1.0
@export var stamina_scale := 1.0
## Habilidade única (id em WeaponSkills; "" = nenhuma).
@export var skill := ""
@export var skill_name := ""
@export_multiline var skill_text := ""
## Arma de longe: o golpe dispara um projétil em vez de ligar a hitbox.
@export var ranged := false
## O desenho na mão do herói (deitado, apontando para a direita).
@export var hand_texture: Texture2D
## Forja: de qual chefe é a alma (a Lembrança NÃO é gasta) e quanto custa.
@export var boss_id := ""
@export var memory_item := ""
@export var forge_memories := 0
@export var forge_sucata := 0


## Multiplicador de dano para estes atributos (dicionário nome → pontos).
## Pontos acima do "soft cap" (25) rendem metade, igual aos atributos de vida.
func scaling_multiplier(attributes: Dictionary) -> float:
	var bonus := 0.0
	for attribute: String in scaling:
		var per_point: float = SCALING_PER_POINT.get(str(scaling[attribute]), 0.0)
		var points := int(attributes.get(attribute, 10)) - 10
		var full := mini(points, 15)
		var extra := maxi(points - 15, 0)
		bonus += full * per_point + extra * per_point * 0.5
	return maxf(0.5, 1.0 + bonus)


## "FOR B · MAG C" — para listas curtas.
func scaling_text() -> String:
	var parts: Array[String] = []
	for attribute in SCALING_ATTRIBUTES:
		if scaling.has(attribute):
			parts.append("%s %s" % [ATTRIBUTE_SHORT[attribute], scaling[attribute]])
	return " · ".join(parts)


## Letra do atributo ("-" quando a arma não escala com ele).
func letter(attribute: String) -> String:
	return str(scaling.get(attribute, "-"))
