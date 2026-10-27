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
	"lembranca_cavaleiro": preload("res://data/items/lembranca_cavaleiro.tres"),
	# Armas básicas (v0.27): a escolhida na criação fica no chão do Prólogo.
	"punhos": preload("res://data/items/punhos.tres"),
	"espada_grande_cobaia": preload("res://data/items/espada_grande_cobaia.tres"),
	"lanca_cobaia": preload("res://data/items/lanca_cobaia.tres"),
	"martelo_cobaia": preload("res://data/items/martelo_cobaia.tres"),
	"adaga_cobaia": preload("res://data/items/adaga_cobaia.tres"),
	"arco_cobaia": preload("res://data/items/arco_cobaia.tres"),
	# Armas de chefe (WeaponData — também são itens).
	"lamina_desolada": preload("res://data/items/lamina_desolada.tres"),
	"pilar_estilhacada": preload("res://data/items/pilar_estilhacada.tres"),
	"arco_sono": preload("res://data/items/arco_sono.tres"),
	"presas_voragem": preload("res://data/items/presas_voragem.tres"),
	"replicador_bronze": preload("res://data/items/replicador_bronze.tres"),
	"presa_caelis": preload("res://data/items/presa_caelis.tres"),
	"fuso_arconte": preload("res://data/items/fuso_arconte.tres"),
	"ancora_gravidade": preload("res://data/items/ancora_gravidade.tres"),
	# Armaduras (ArmorData): 7 conjuntos x 5 peças. Os efeitos ficam no ArmorSets.
	"capacete_vigilia": preload("res://data/items/capacete_vigilia.tres"),
	"peitoral_vigilia": preload("res://data/items/peitoral_vigilia.tres"),
	"luvas_vigilia": preload("res://data/items/luvas_vigilia.tres"),
	"calca_vigilia": preload("res://data/items/calca_vigilia.tres"),
	"botas_vigilia": preload("res://data/items/botas_vigilia.tres"),
	"capacete_detentor": preload("res://data/items/capacete_detentor.tres"),
	"peitoral_detentor": preload("res://data/items/peitoral_detentor.tres"),
	"luvas_detentor": preload("res://data/items/luvas_detentor.tres"),
	"calca_detentor": preload("res://data/items/calca_detentor.tres"),
	"botas_detentor": preload("res://data/items/botas_detentor.tres"),
	"capacete_sono": preload("res://data/items/capacete_sono.tres"),
	"peitoral_sono": preload("res://data/items/peitoral_sono.tres"),
	"luvas_sono": preload("res://data/items/luvas_sono.tres"),
	"calca_sono": preload("res://data/items/calca_sono.tres"),
	"botas_sono": preload("res://data/items/botas_sono.tres"),
	"capacete_banquete": preload("res://data/items/capacete_banquete.tres"),
	"peitoral_banquete": preload("res://data/items/peitoral_banquete.tres"),
	"luvas_banquete": preload("res://data/items/luvas_banquete.tres"),
	"calca_banquete": preload("res://data/items/calca_banquete.tres"),
	"botas_banquete": preload("res://data/items/botas_banquete.tres"),
	"capacete_eco": preload("res://data/items/capacete_eco.tres"),
	"peitoral_eco": preload("res://data/items/peitoral_eco.tres"),
	"luvas_eco": preload("res://data/items/luvas_eco.tres"),
	"calca_eco": preload("res://data/items/calca_eco.tres"),
	"botas_eco": preload("res://data/items/botas_eco.tres"),
	"capacete_caelis": preload("res://data/items/capacete_caelis.tres"),
	"peitoral_caelis": preload("res://data/items/peitoral_caelis.tres"),
	"luvas_caelis": preload("res://data/items/luvas_caelis.tres"),
	"calca_caelis": preload("res://data/items/calca_caelis.tres"),
	"botas_caelis": preload("res://data/items/botas_caelis.tres"),
	"capacete_arconte": preload("res://data/items/capacete_arconte.tres"),
	"peitoral_arconte": preload("res://data/items/peitoral_arconte.tres"),
	"luvas_arconte": preload("res://data/items/luvas_arconte.tres"),
	"calca_arconte": preload("res://data/items/calca_arconte.tres"),
	"botas_arconte": preload("res://data/items/botas_arconte.tres"),
}


static func exists(id: String) -> bool:
	return CATALOG.has(id)


static func get_item(id: String) -> ItemData:
	return CATALOG.get(id) as ItemData


static func get_weapon(id: String) -> WeaponData:
	return CATALOG.get(id) as WeaponData


static func get_armor(id: String) -> ArmorData:
	return CATALOG.get(id) as ArmorData


static func display_name(id: String) -> String:
	var item := get_item(id)
	return item.display_name if item else id
