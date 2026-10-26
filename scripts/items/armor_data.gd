class_name ArmorData
extends ItemData
## Uma peça de armadura: é um item (nome, ícone, lore) que VESTE um dos cinco
## espaços do corpo e pertence a um CONJUNTO.
##
## A peça não guarda número de efeito nenhum. Quem sabe o que cada conjunto
## faz é o ArmorSets — a peça só diz "sou do conjunto X, vou na cabeça".
## Assim, mexer no balanceamento é mudar UMA tabela, não 35 arquivos.

## Os cinco espaços do corpo, na ordem em que aparecem no menu.
const SLOTS: Array[String] = ["capacete", "peitoral", "luvas", "calca", "botas"]
const SLOT_NAMES := {
	"capacete": "Capacete",
	"peitoral": "Peitoral",
	"luvas": "Luvas",
	"calca": "Calça",
	"botas": "Botas",
}

## Em qual espaço do corpo ela vai (um dos SLOTS).
@export var slot := "peitoral"
## De qual conjunto ela é (chave em ArmorSets.SETS).
@export var set_id := ""
