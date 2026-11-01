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

# --- v0.34 (Etapa 4): DEFESA e PESO -------------------------------------------------
## Os tipos de dano do jogo. Todo golpe tem um (HitInfo.damage_type, "fisico" se
## ninguém disser nada). A armadura reduz cada tipo pela sua própria defesa.
const DAMAGE_TYPES: Array[String] = ["fisico", "fogo", "magia", "raio", "gelo"]
const DAMAGE_NAMES := {"fisico": "Físico", "fogo": "Fogo", "magia": "Magia", "raio": "Raio", "gelo": "Gelo"}
## Com as 5 partes vestidas (de QUALQUER conjunto): +10% em toda a defesa.
const FULL_BODY_BONUS := 0.10
## Teto da redução somando tudo: sem ele, armadura pesada deixaria o herói imortal.
const DEFENSE_CAP := 0.60
## Quanto de cada conjunto cada parte carrega (somam 1.0): o peitoral protege
## e pesa mais que as luvas.
const SLOT_SHARE := {"capacete": 0.18, "peitoral": 0.32, "luvas": 0.14, "calca": 0.22, "botas": 0.14}
## Perfil do conjunto INTEIRO (as 5 peças): peso total e redução por tipo.
## Leve ~8, médio ~16, pesado ~26. "Forte contra" = aquele tipo bem acima.
const PROFILES := {
	"vigilia": {"peso": 8.0, "classe": "leve", "defesa": {"fisico": 0.12, "fogo": 0.08, "magia": 0.08, "raio": 0.08, "gelo": 0.08}},
	"sono": {"peso": 7.0, "classe": "leve", "defesa": {"fisico": 0.10, "fogo": 0.08, "magia": 0.26, "raio": 0.08, "gelo": 0.08}},
	"arconte": {"peso": 9.0, "classe": "leve", "defesa": {"fisico": 0.10, "fogo": 0.06, "magia": 0.22, "raio": 0.08, "gelo": 0.26}},
	"banquete": {"peso": 16.0, "classe": "medio", "defesa": {"fisico": 0.26, "fogo": 0.12, "magia": 0.12, "raio": 0.12, "gelo": 0.12}},
	"caelis": {"peso": 17.0, "classe": "medio", "defesa": {"fisico": 0.18, "fogo": 0.34, "magia": 0.12, "raio": 0.12, "gelo": 0.10}},
	"detentor": {"peso": 27.0, "classe": "pesado", "defesa": {"fisico": 0.32, "fogo": 0.16, "magia": 0.14, "raio": 0.16, "gelo": 0.16}},
	"eco": {"peso": 25.0, "classe": "pesado", "defesa": {"fisico": 0.26, "fogo": 0.14, "magia": 0.14, "raio": 0.36, "gelo": 0.14}},
}


## Quanto UMA peça (deste conjunto, neste espaço) reduz deste tipo de dano.
static func piece_defense(set_id: String, slot: String, damage_type: String) -> float:
	var profile: Dictionary = PROFILES.get(set_id, {})
	return float((profile.get("defesa", {}) as Dictionary).get(damage_type, 0.0)) * float(SLOT_SHARE.get(slot, 0.2))


static func piece_weight(set_id: String, slot: String) -> float:
	var profile: Dictionary = PROFILES.get(set_id, {})
	return snappedf(float(profile.get("peso", 0.0)) * float(SLOT_SHARE.get(slot, 0.2)), 0.1)


static func weight_class(set_id: String) -> String:
	return str((PROFILES.get(set_id, {}) as Dictionary).get("classe", "leve"))


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
