class_name Items
## Catálogo de itens: o ÚNICO lugar que sabe quais itens existem.
##
## Por que uma lista de preload() e não "ler a pasta data/items"? No APK o
## Godot converte os .tres e muda os nomes dos arquivos; listar a pasta em
## tempo de jogo funciona no editor e falha no celular. Uma lista explícita
## também vira documentação: bateu o olho, sabe tudo que o jogo tem.
##
## Para criar um item novo: rode tools/gen_resources.py (ou crie o .tres no
## Inspector), ponha o ícone em assets/items/ e acrescente uma linha aqui.

const CATALOG := {
	"espada": preload("res://data/items/espada.tres"),
	"escudo_remendado": preload("res://data/items/escudo_remendado.tres"),
	"frasco_vida": preload("res://data/items/frasco_vida.tres"),
	"frasco_sanidade": preload("res://data/items/frasco_sanidade.tres"),
	"sucata_temperada": preload("res://data/items/sucata_temperada.tres"),
	"fragmento_turvo": preload("res://data/items/fragmento_turvo.tres"),
	"apito_sargento": preload("res://data/items/apito_sargento.tres"),
	"lembranca_governanta": preload("res://data/items/lembranca_governanta.tres"),
	"lembranca_aldir": preload("res://data/items/lembranca_aldir.tres"),
	"lembranca_helena": preload("res://data/items/lembranca_helena.tres"),
	"lembranca_nyssa": preload("res://data/items/lembranca_nyssa.tres"),
	"lembranca_mabel": preload("res://data/items/lembranca_mabel.tres"),
	"lembranca_durgan": preload("res://data/items/lembranca_durgan.tres"),
	"lembranca_rachel": preload("res://data/items/lembranca_rachel.tres"),
	"lembranca_cassian": preload("res://data/items/lembranca_cassian.tres"),
	"anel_do_guarda": preload("res://data/items/anel_do_guarda.tres"),
}


static func exists(id: String) -> bool:
	return CATALOG.has(id)


static func get_item(id: String) -> ItemData:
	return CATALOG.get(id) as ItemData


static func display_name(id: String) -> String:
	var item := get_item(id)
	return item.display_name if item else id
