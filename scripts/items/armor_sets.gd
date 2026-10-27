class_name ArmorSets
## Os sete conjuntos de armadura e o que cada um faz.
##
## A regra é a mesma para todos (como o Anel de Lâminas do Dark Souls 2, só
## que em pedaços): CADA PEÇA VESTIDA soma um pouco do efeito do conjunto.
## Uma peça = um gostinho; as cinco = o efeito inteiro. E dá para misturar:
## 3 peças de força + 2 de velocidade é uma "build" válida.
##
## Balanceamento: todos os números moram em `per_piece`. O teto (5 peças) foi
## pensado para não quebrar o jogo:
##   força +20%      (o reforço +5 do Ferreiro dá +60%)
##   vida +30%       (uns 10 pontos de Vitalidade)
##   estamina +60% de regeneração (não aumenta a barra, só a pressa)
##   alcance +30%    (o golpe chega mais longe, não fica maior que um martelo)
##   drop +75%       (os 3% de arma viram ~5%)
##   memórias +40%
##   passo: andar = correr (sem gastar estamina); correr fica 30% mais rápido

const MAX_PIECES := 5

## set_id → ficha do conjunto.
##   name:      nome do conjunto (aparece na ficha);
##   suffix:    como as peças se chamam ("Capacete DA VIGÍLIA");
##   effect:    qual regra do jogo ele mexe (Game.armor_bonus(effect));
##   per_piece: quanto CADA peça soma nessa regra;
##   text:      a regra explicada para o jogador ({p} = % por peça).
const SETS := {
	"vigilia": {
		"name": "Traje da Vigília", "suffix": "da Vigília", "effect": "vida", "per_piece": 0.06,
		"text": "Vida máxima +{p}% por peça.",
	},
	"detentor": {
		"name": "Armadura do Detentor", "suffix": "do Detentor", "effect": "forca", "per_piece": 0.04,
		"text": "Dano de todos os golpes +{p}% por peça.",
	},
	"sono": {
		"name": "Vestes do Sono Leve", "suffix": "do Sono Leve", "effect": "folego", "per_piece": 0.12,
		"text": "Estamina volta +{p}% mais rápido por peça.",
	},
	"banquete": {
		"name": "Trapos do Banquete", "suffix": "do Banquete", "effect": "fartura", "per_piece": 0.15,
		"text": "Chance de os inimigos deixarem itens e armas +{p}% por peça.",
	},
	"eco": {
		"name": "Couraça do Eco", "suffix": "do Eco", "effect": "alcance", "per_piece": 0.06,
		"text": "Alcance dos golpes +{p}% por peça, com qualquer arma.",
	},
	"caelis": {
		"name": "Escamas de Caelis", "suffix": "de Caelis", "effect": "passo", "per_piece": 0.12,
		"text": "Andar +{p}% por peça: com as 5, andar é tão rápido quanto correr. Correndo, vai mais rápido ainda.",
	},
	"arconte": {
		"name": "Manto do Arconte", "suffix": "do Arconte", "effect": "memoria", "per_piece": 0.08,
		"text": "Memórias de cada inimigo +{p}% por peça.",
	},
}

## Passo (Escamas de Caelis): quanto a CORRIDA ganha por peça, além do andar.
const SPRINT_PER_PIECE := 0.1


static func exists(set_id: String) -> bool:
	return SETS.has(set_id)


static func info(set_id: String) -> Dictionary:
	return SETS.get(set_id, {})


static func effect_of(set_id: String) -> String:
	return str(info(set_id).get("effect", ""))


static func per_piece(set_id: String) -> float:
	return float(info(set_id).get("per_piece", 0.0))


## O texto da regra com o número no lugar ("+6% por peça").
static func rule_text(set_id: String) -> String:
	var text := str(info(set_id).get("text", ""))
	return text.replace("{p}", str(roundi(per_piece(set_id) * 100.0)))


## O id da peça de um conjunto num espaço ("capacete" + "vigilia" → "capacete_vigilia").
static func piece_id(slot: String, set_id: String) -> String:
	return "%s_%s" % [slot, set_id]


## As cinco peças de um conjunto, na ordem dos espaços.
static func pieces(set_id: String) -> Array[String]:
	var result: Array[String] = []
	for slot in ArmorData.SLOTS:
		result.append(piece_id(slot, set_id))
	return result
