class_name ItemData
extends Resource
## Ficha de UM item (data/items/*.tres): nome, texto de lore, ícone e tipo.
##
## A ficha não guarda QUANTOS você tem — isso é estado do jogador e mora no
## Game.inventory (um dicionário id → quantidade). Separar "o que a coisa É"
## de "quanto eu TENHO" é o mesmo padrão do AttackData: dado fixo num
## Resource, estado vivo no autoload. Assim o save guarda só números.

enum Kind {
	EQUIPAMENTO,  ## Espada, escudo: aparecem nas mãos do herói.
	CONSUMIVEL,   ## Frascos: gastos e repostos.
	MATERIAL,     ## Sucata, fragmentos: trocados com o Ferreiro e o Orbe.
	LEMBRANCA,    ## Itens-chave de lore: não servem para nada além de lembrar.
}

const KIND_NAMES := {
	Kind.EQUIPAMENTO: "Equipamento",
	Kind.CONSUMIVEL: "Consumíveis",
	Kind.MATERIAL: "Materiais",
	Kind.LEMBRANCA: "Lembranças",
}

@export var id := ""
@export var display_name := ""
@export_multiline var description := ""
@export var kind := Kind.MATERIAL
@export var icon: Texture2D
## Quantos cabem no inventário (1 = item único).
@export var max_stack := 99
