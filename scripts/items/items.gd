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
	# v0.33 (Etapa 3): o que cai de um baú quebrado, e os pertences dos antigos
	# donos das cápsulas (um por ilha, ao lado da segunda Câmara).
	"algo_quebrado": preload("res://data/items/algo_quebrado.tres"),
	"caixa_musica_bronze": preload("res://data/items/caixa_musica_bronze.tres"),
	"botao_socorro": preload("res://data/items/botao_socorro.tres"),
	"gelo_perpetuo": preload("res://data/items/gelo_perpetuo.tres"),
	"desenho_a_giz": preload("res://data/items/desenho_a_giz.tres"),
	"espada_madeira_pequena": preload("res://data/items/espada_madeira_pequena.tres"),
	# v0.45 (Etapa 8): os fios entre Helena e Heitor.
	"flor_de_pedra": preload("res://data/items/flor_de_pedra.tres"),
	"licor_da_vigilia": preload("res://data/items/licor_da_vigilia.tres"),
	# v0.48 (Etapa 9): o que o Galeno deixa (só com o Tito morto).
	"escudo_sem_dono": preload("res://data/items/escudo_sem_dono.tres"),
	# v0.49 (Etapa 10): o Damião, o Sucateiro.
	"meio_pingente": preload("res://data/items/meio_pingente.tres"),
	"fragmento_de_loja": preload("res://data/items/fragmento_de_loja.tres"),
	# v0.50 (Etapa 10): as magias (SpellData) — Dalva, Cícero, Benedita.
	"projetil_arcano": preload("res://data/spells/projetil_arcano.tres"),
	"lamina_magica": preload("res://data/spells/lamina_magica.tres"),
	"escudo_de_geada": preload("res://data/spells/escudo_de_geada.tres"),
	"feitico_dalva": preload("res://data/spells/feitico_dalva.tres"),
	"bola_de_fogo": preload("res://data/spells/bola_de_fogo.tres"),
	"chicote_de_chamas": preload("res://data/spells/chicote_de_chamas.tres"),
	"explosao_curta": preload("res://data/spells/explosao_curta.tres"),
	"rua_em_chamas": preload("res://data/spells/rua_em_chamas.tres"),
	"milagre_cura": preload("res://data/spells/milagre_cura.tres"),
	"cura_em_area": preload("res://data/spells/cura_em_area.tres"),
	"milagre_barreira": preload("res://data/spells/milagre_barreira.tres"),
	"lanca_de_raio": preload("res://data/spells/lanca_de_raio.tres"),
	"tempestade": preload("res://data/spells/tempestade.tres"),
	"ultimo_pedido": preload("res://data/items/ultimo_pedido.tres"),
	# v0.52 (Etapa 11): o presente do Amaro nas Forjas (vira botão na Etapa 12).
	"botao_arrancado": preload("res://data/items/botao_arrancado.tres"),
	# v0.53 (Etapa 12): a Lata de Botões e os botões (ButtonData).
	"lata_de_botoes": preload("res://data/items/lata_de_botoes.tres"),
	"botao_pijama": preload("res://data/items/botao_pijama.tres"),
	"botao_jaleco": preload("res://data/items/botao_jaleco.tres"),
	"botao_farda": preload("res://data/items/botao_farda.tres"),
	"botao_corneteiro": preload("res://data/items/botao_corneteiro.tres"),
	"botao_bombeiro": preload("res://data/items/botao_bombeiro.tres"),
	"botao_musgo": preload("res://data/items/botao_musgo.tres"),
	"botao_sino": preload("res://data/items/botao_sino.tres"),
	"botao_tunica_azul": preload("res://data/items/botao_tunica_azul.tres"),
	"botao_romeira": preload("res://data/items/botao_romeira.tres"),
	"botao_bronze": preload("res://data/items/botao_bronze.tres"),
	"botao_engrenagem": preload("res://data/items/botao_engrenagem.tres"),
	"botao_avental": preload("res://data/items/botao_avental.tres"),
	"botao_cerzido": preload("res://data/items/botao_cerzido.tres"),
	"botao_escama": preload("res://data/items/botao_escama.tres"),
	"botao_corrente": preload("res://data/items/botao_corrente.tres"),
	"botao_vidro": preload("res://data/items/botao_vidro.tres"),
	"botao_giz": preload("res://data/items/botao_giz.tres"),
	"botao_vestido": preload("res://data/items/botao_vestido.tres"),
	# v0.51 (Etapa 10): os conjuntos dos vendedores novos.
	"capacete_aprendiz": preload("res://data/items/capacete_aprendiz.tres"),
	"peitoral_aprendiz": preload("res://data/items/peitoral_aprendiz.tres"),
	"luvas_aprendiz": preload("res://data/items/luvas_aprendiz.tres"),
	"calca_aprendiz": preload("res://data/items/calca_aprendiz.tres"),
	"botas_aprendiz": preload("res://data/items/botas_aprendiz.tres"),
	"capacete_bombeiro": preload("res://data/items/capacete_bombeiro.tres"),
	"peitoral_bombeiro": preload("res://data/items/peitoral_bombeiro.tres"),
	"luvas_bombeiro": preload("res://data/items/luvas_bombeiro.tres"),
	"calca_bombeiro": preload("res://data/items/calca_bombeiro.tres"),
	"botas_bombeiro": preload("res://data/items/botas_bombeiro.tres"),
	"capacete_romeira": preload("res://data/items/capacete_romeira.tres"),
	"peitoral_romeira": preload("res://data/items/peitoral_romeira.tres"),
	"luvas_romeira": preload("res://data/items/luvas_romeira.tres"),
	"calca_romeira": preload("res://data/items/calca_romeira.tres"),
	"botas_romeira": preload("res://data/items/botas_romeira.tres"),
	"botao_de_casaco": preload("res://data/items/botao_de_casaco.tres"),
	"fita_desbotada": preload("res://data/items/fita_desbotada.tres"),
	"oculos_rachados": preload("res://data/items/oculos_rachados.tres"),
	"dente_de_leite": preload("res://data/items/dente_de_leite.tres"),
	"bolinha_de_gude": preload("res://data/items/bolinha_de_gude.tres"),
	"bilhete_dobrado": preload("res://data/items/bilhete_dobrado.tres"),
	# Armas básicas (v0.27): a escolhida na criação fica no chão do Prólogo.
	"punhos": preload("res://data/items/punhos.tres"),
	"espada_grande_cobaia": preload("res://data/items/espada_grande_cobaia.tres"),
	"lanca_cobaia": preload("res://data/items/lanca_cobaia.tres"),
	"corrente_igual": preload("res://data/items/corrente_igual.tres"),
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
