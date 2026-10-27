extends Node
## Autoload "Game": tudo que sobrevive à troca de cena e ao fechar o app.
##
## Memórias (moeda + XP), mortes, perda de visão, frascos, atributos, chefes
## derrotados e o último ponto de descanso. Também cuida de salvar/carregar
## (JSON em user://) e de viajar entre áreas.
##
## Regras da Bíblia implementadas aqui:
##   • "Morrer não é o problema; esquecer é." — cada morte tira memórias e
##     escurece a visão (até MAX_VISION_LOSS, quando quase só o herói aparece).
##   • Os olhos (e o cabelo) ficam mais brancos a cada morte — permanente.
##   • Frasco de Sanidade: humanidade líquida; devolve a visão.
##   • Prólogo: a primeira escolha moral, SEM AVISO. Cada golpe numa criança
##     soma em criancas_feridas — e a Governanta "já sabe o que você fez".
##   • Inventário (Sistema 7): itens são só NÚMEROS aqui (id → quantidade); o que
##     cada item É fica na ficha (data/items/*.tres, catálogo em Items).
##   • O Ferreiro "melhora armas" (weapon_level) e o Orbe Branco "purifica
##     fragmentos e aumenta os frascos de vida" (Fragmento Turvo → +1 frasco).
##
## SAVE À PROVA DE QUEDA (boa prática para celular, onde o sistema pode matar o
## app a qualquer momento):
##   1. grava tudo num arquivo temporário (.tmp) e confere se ele é legível;
##   2. o save atual vira cópia de segurança (.bak);
##   3. o .tmp é renomeado para o nome definitivo (renomear é atômico).
## Se o celular desligar no meio, sobra o save antigo ou o .bak — nunca meio arquivo.

signal memories_changed(total: int)
signal vision_changed(loss: int)
signal sanity_flasks_changed(count: int)
signal deaths_changed(count: int)
signal attributes_changed
signal boss_defeated(boss_id: String)
signal child_hurt(total: int)
## Qualquer mudança no inventário (o menu escuta para se redesenhar).
signal items_changed
## Item GANHO — o HUD mostra "+ Sucata Temperada x2" no canto.
signal item_added(id: String, count: int)
signal weapon_upgraded(level: int)
## Trocou a arma da mão direita (o herói troca o sprite e os golpes).
signal weapon_changed(id: String)
## Vestiu ou tirou uma peça de armadura (o herói recalcula vida e velocidade).
signal armor_changed

## Save das versões antigas (um só). Na primeira vez, ele vira o slot 1.
const SAVE_PATH := "user://alexandria_save.json"
## Saves no estilo Dark Souls: 3 "personagens" independentes.
const SLOT_COUNT := 3
## Qual slot foi usado por último ("Continuar" no título carrega esse).
const LAST_SLOT_PATH := "user://ultimo_save.cfg"
## Versão 2 = com o Prólogo. Versão 3 = com inventário.
## Saves antigos são MIGRADOS em _from_dict().
const SAVE_VERSION := 3
## Bíblia: "Depois de muitas mortes (referência: 8), quase só o próprio personagem fica visível."
const MAX_VISION_LOSS := 8
## Novo jogo começa no Prólogo, saindo da sua cápsula.
const START_SCENE := "res://scenes/world/prologo.tscn"
const START_SPAWN := "camara"
## O hub: depois da queda, a vida "mora" no Teatro.
const HUB_SCENE := "res://scenes/world/teatro.tscn"
const HUB_SPAWN := "camara"
const TITLE_SCENE := "res://scenes/ui/title_screen.tscn"
const ENDING_SCENE := "res://scenes/ui/ending.tscn"

# --- Balanceamento (mexa à vontade) ---------------------------------------------
## Fração das memórias perdidas ao morrer.
const MEMORY_LOSS_RATIO := 0.5
const SANITY_FLASK_PRICE := 150
## O Vendedor também troca memórias por sucata (para ninguém ficar preso
## esperando a sorte dos drops).
const SUCATA_PRICE := 200
const START_SANITY_FLASKS := 1
const START_HEALTH_FLASKS := 3
## Teto de Frascos de Vida (3 iniciais + 9 fragmentos purificados).
const MAX_HEALTH_FLASKS := 12

# --- Arma (Ferreiro) ----------------------------------------------------------------
## Cada nível da arma soma isso ao dano (0.12 = +12% por nível).
const WEAPON_DAMAGE_PER_LEVEL := 0.12
## Custo de cada melhoria: o índice é o nível ATUAL (0 → +1, 1 → +2...).
const WEAPON_UPGRADES := [
	{"memories": 250, "sucata_temperada": 2},
	{"memories": 500, "sucata_temperada": 4},
	{"memories": 900, "sucata_temperada": 6},
	{"memories": 1400, "sucata_temperada": 9},
	{"memories": 2000, "sucata_temperada": 12},
]
## Até onde o Ferreiro sabe ir sozinho. Bíblia: depois de Durgan, "o Ferreiro
## reconhece a memória do irmão e libera um novo nível de melhoria".
const WEAPON_LEVEL_CAP := 3
const WEAPON_LEVEL_CAP_AFTER_DURGAN := 5

## Armas de chefe: o Ferreiro forja com a Lembrança do Pecado (que NÃO é gasta).
const START_WEAPON := "espada"
## Lutar sem arma (v0.27): sempre "na mão" — as duas, aliás.
const FISTS := "punhos"
## As armas comuns: dá para escolher uma na criação de personagem (ela fica
## largada no chão do Prólogo) e o Ferreiro copia a que você já tem.
const BASIC_WEAPONS: Array[String] = ["espada", "espada_grande_cobaia", "lanca_cobaia", "martelo_cobaia",
	"adaga_cobaia", "arco_cobaia"]
## NG+ (v0.27): a partir deste ciclo o mundo para de endurecer.
const MAX_CYCLE := 7
const SHIELD := "escudo_remendado"
const FORGEABLE_WEAPONS: Array[String] = ["lamina_desolada", "pilar_estilhacada", "arco_sono", "presas_voragem",
	"replicador_bronze", "presa_caelis", "fuso_arconte", "ancora_gravidade"]
## Os golpes do herói (armas sem golpes próprios usam estes) — para a ficha do inventário.
const BASE_LIGHT := preload("res://data/attacks/player_light_1.tres")
const BASE_HEAVY := preload("res://data/attacks/player_heavy.tres")

## O que cada chefe deixa ao ser vencido PELA PRIMEIRA VEZ (além das memórias).
const BOSS_REWARDS := {
	"cavaleiro": {"lembranca_cavaleiro": 1},
	"governanta": {"lembranca_governanta": 1},
	"sargento": {"apito_sargento": 1, "fragmento_turvo": 1, "sucata_temperada": 2},
	"couraca": {"fragmento_turvo": 1, "sucata_temperada": 3},
	"aldir": {"lembranca_aldir": 1, "fragmento_turvo": 1, "sucata_temperada": 4},
	"helena": {"lembranca_helena": 1, "fragmento_turvo": 1},
	"vigia": {"fragmento_turvo": 1, "sucata_temperada": 3},
	"mae_esporos": {"fragmento_turvo": 1, "sucata_temperada": 2},
	"nyssa": {"lembranca_nyssa": 1, "fragmento_turvo": 1, "sucata_temperada": 4},
	"banqueteiro": {"fragmento_turvo": 1, "sucata_temperada": 3},
	"ninhada": {"fragmento_turvo": 1, "sucata_temperada": 3},
	"mabel": {"lembranca_mabel": 1, "fragmento_turvo": 1, "sucata_temperada": 5},
	"prototipo": {"sucata_temperada": 4},
	"guardiao_ancora": {"fragmento_turvo": 1, "sucata_temperada": 4},
	"durgan": {"lembranca_durgan": 1, "fragmento_turvo": 1, "sucata_temperada": 8},
	"capitao": {"fragmento_turvo": 1, "sucata_temperada": 4},
	"matriarca": {"fragmento_turvo": 1, "sucata_temperada": 4},
	"rachel": {"lembranca_rachel": 1, "fragmento_turvo": 2, "sucata_temperada": 10},
	"curadora": {"fragmento_turvo": 1, "sucata_temperada": 4},
	"golem_arquivo": {"fragmento_turvo": 1, "sucata_temperada": 5},
	"cassian": {"lembranca_cassian": 1, "fragmento_turvo": 2, "sucata_temperada": 12},
}

var memories := 0
var deaths := 0
var vision_loss := 0
var sanity_flasks := START_SANITY_FLASKS
var health_flasks_max := START_HEALTH_FLASKS
var attributes := {}
var defeated_bosses: Array[String] = []
var rest_scene := START_SCENE
var rest_spawn := START_SPAWN
## Inventário: id do item → quantidade. Os frascos NÃO moram aqui (têm regras
## próprias acima); o menu os mostra "de mentira", lendo os contadores.
var inventory := {}
## Melhoria da espada no Ferreiro (0 = de fábrica).
var weapon_level := 0
## Escudo na mão esquerda (só vale se você TIVER o escudo).
## Mão esquerda: "" (vazia), o escudo ou o id de uma arma. A direita é equipped_weapon.
var left_hand := ""
## Arma da direita segura com as DUAS mãos (segurar △): mais dano e mais estamina.
var two_handing := false
## Arma na mão direita (id do catálogo; sempre uma arma que você tem).
var equipped_weapon := START_WEAPON
## Armadura vestida: espaço do corpo ("capacete"...) → id da peça ("" = nada).
var armor := {}
## NG+ (v0.27): 0 = a primeira jornada; 1 = NG+, 2 = NG++...
var cycle := 0
## O experimento anterior que ficou no lugar do Cavaleiro (final Proteger):
## a "foto" de como ele estava ao vencer o Núcleo. {} = o Cavaleiro de sempre.
var guardian := {}
## Saves de antes da v0.27: a Espada de Cobaia vinha na mão de graça. Quem
## nasce pela criação nova começa de punhos e acha a arma no chão.
var starter_sword := true
## A arma escolhida na criação (fica largada no Prólogo).
var chosen_weapon := ""
## Itens do chão que já foram pegos ("cidade@13,3") — não voltam ao descansar.
var collected_pickups: Array[String] = []
## Câmaras onde você já descansou (dá para viajar entre elas).
var capsules: Array[String] = []
## Escolhas e acontecimentos que o mundo lembra ("vigia_evitado"...).
## Um dicionário de marcas é mais simples que uma variável por escolha — e o
## save não precisa mudar de versão a cada marca nova.
var flags := {}
## Aparência escolhida na criação de personagem (ver Appearance).
var appearance := Appearance.default_data()
## Id do ponto onde o herói aparece na próxima área carregada.
var pending_spawn := ""
## Testes automáticos desligam a gravação em disco.
var persistence_enabled := true
## Caminho do save (os testes usam um arquivo próprio para não tocar no seu).
var save_path := SAVE_PATH
## Slot atual (1..SLOT_COUNT). Os testes trocam slot_prefix para não tocar nos saves reais.
var slot := 1
var slot_prefix := "user://alexandria_save_"
## Tempo jogado (segundos) — aparece na escolha de save, como nos soulslike.
var play_seconds := 0.0
## Só existe "partida em andamento" depois de Novo jogo / Continuar (ou ao abrir
## uma fase direto pelo editor). Na tela de título não há nada para salvar: sem
## esta trava, minimizar o app no título gravaria o progresso ZERADO por cima do save.
var session_active := false
## Vida e frascos que o herói leva ao atravessar uma porta (-1 = nada guardado).
## Só a Câmara de descanso enche tudo — trocar de área não pode ser um "descanso grátis".
var carry_health := -1.0
var carry_flasks := -1

# --- Prólogo ---------------------------------------------------------------------
## Quantas vezes o herói acertou uma criança. 0 = a Governanta deixa passar.
var criancas_feridas := 0
var prologue_done := false
## Atravessou o prólogo sem ferir ninguém: a Criança Poupada aparece no Teatro.
var spared_child := false
## A próxima área começa com o herói saindo da cápsula (Novo jogo e depois da queda).
var wake_from_capsule := false

# --- Para os testes automáticos -----------------------------------------------------
## false = não troca de cena de verdade (o teste seria substituído pela fase);
## só anota o pedido em last_scene_request.
var scene_changes_enabled := true
var last_scene_request := ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Quem fecha o jogo somos nós (quit_game): dá tempo de salvar e silenciar.
	get_tree().auto_accept_quit = false
	reset_progress()
	_migrate_single_save()
	use_slot(_read_last_slot())
	load_game()  # já deixa o progresso e as opções (vibração) prontos no título


## Só conta o tempo de verdade jogando (pausado, menu e título não contam).
func _process(delta: float) -> void:
	if session_active and not get_tree().paused:
		play_seconds += delta

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_PAUSED:
			# Android: depois de ir para segundo plano, o app pode ser morto sem aviso.
			if session_active:
				save_game()
		NOTIFICATION_WM_CLOSE_REQUEST:
			quit_game()


## Fecha o jogo "com educação": salva (se houver partida), silencia o áudio e
## espera um instante para o servidor de áudio soltar os sons. Sair na hora
## deixava um aviso de "recurso ainda em uso" a cada fechamento.
func quit_game(exit_code: int = 0) -> void:
	if session_active:
		save_game()
	Sfx.shutdown()
	await get_tree().create_timer(0.15, true, false, true).timeout
	get_tree().quit(exit_code)


func reset_progress() -> void:
	memories = 0
	deaths = 0
	vision_loss = 0
	sanity_flasks = START_SANITY_FLASKS
	health_flasks_max = START_HEALTH_FLASKS
	attributes = {}
	for attribute in StatsComponent.ATTRIBUTE_NAMES:
		attributes[attribute] = StatsComponent.BASE_ATTRIBUTE
	defeated_bosses.clear()
	appearance = Appearance.default_data()
	rest_scene = START_SCENE
	rest_spawn = START_SPAWN
	pending_spawn = ""
	clear_carry()
	criancas_feridas = 0
	prologue_done = false
	spared_child = false
	wake_from_capsule = false
	inventory = {}
	weapon_level = 0
	equipped_weapon = START_WEAPON
	left_hand = ""
	two_handing = false
	armor = _empty_armor()
	cycle = 0
	guardian = {}
	starter_sword = true
	chosen_weapon = ""
	collected_pickups.clear()
	capsules.clear()
	play_seconds = 0.0
	shop_bought.clear()
	flags = {}


# --- Memórias e nível ---------------------------------------------------------------

## Memórias GANHAS no mundo (inimigos, chefes): crescem com o ciclo do NG+.
## Comprar, vender e recuperar a mancha usam add_memories direto (preço é preço).
func earn_memories(amount: int) -> void:
	add_memories(int(round(amount * difficulty())))


## NG+: vida, dano e memórias dos inimigos. ×1 na primeira jornada, ×1,5 no
## NG+, +0,25 por ciclo e para no NG+7 (×3).
func difficulty() -> float:
	return 1.0 if cycle <= 0 else 1.25 + 0.25 * mini(cycle, MAX_CYCLE)


## "NG+", "NG++"... (vazio na primeira jornada) — para a tela de saves.
static func cycle_label(n: int) -> String:
	if n <= 0:
		return ""
	return "NG+" if n == 1 else ("NG++" if n == 2 else "NG+%d" % n)


func add_memories(amount: int) -> void:
	if amount <= 0:
		return
	memories += amount
	memories_changed.emit(memories)


## Algo SUGA memórias (agarrão da Mabel, Larva de Seiva): uma fração do que
## você carrega, com um mínimo. Devolve quanto foi perdido (0 se não havia nada).
func drain_memories(ratio: float, minimum: int = 0) -> int:
	if memories <= 0 or (ratio <= 0.0 and minimum <= 0):
		return 0
	var lost := mini(maxi(int(floor(memories * ratio)), minimum), memories)
	memories -= lost
	memories_changed.emit(memories)
	return lost


func spend_memories(amount: int) -> bool:
	if amount > memories:
		return false
	memories -= amount
	memories_changed.emit(memories)
	return true


func level() -> int:
	var total := 0
	for value in attributes.values():
		total += int(value)
	return total - StatsComponent.ATTRIBUTE_NAMES.size() * StatsComponent.BASE_ATTRIBUTE + 1


## Custo do próximo nível: cresce mais rápido que linear (curva típica de Souls).
func level_up_cost() -> int:
	return int(round(80.0 + pow(float(level()), 1.6) * 20.0))


## A Fada troca memórias por um ponto de atributo.
func try_level_up(attribute: String) -> bool:
	if not attributes.has(attribute):
		return false
	var cost := level_up_cost()
	if not spend_memories(cost):
		return false
	attributes[attribute] = int(attributes[attribute]) + 1
	attributes_changed.emit()
	save_game()
	return true


# --- Morte, visão e sanidade -------------------------------------------------------------

## Registra uma morte e devolve quantas memórias foram perdidas.
## É chamada NO INSTANTE da morte (e salva na hora): fechar o app ou voltar ao
## título durante a animação não pode apagar a punição.
func register_death() -> int:
	deaths += 1
	vision_loss = mini(vision_loss + 1, MAX_VISION_LOSS)
	var lost := int(floor(memories * MEMORY_LOSS_RATIO))
	memories -= lost
	deaths_changed.emit(deaths)
	vision_changed.emit(vision_loss)
	memories_changed.emit(memories)
	save_game()
	return lost


## 0 = visão perfeita, 1 = quase cego.
func vision_loss_ratio() -> float:
	return float(vision_loss) / float(MAX_VISION_LOSS)


## Olhos/cabelo esbranquiçados: marca PERMANENTE das mortes (0..1).
func whiteness_ratio() -> float:
	return clampf(float(deaths) / float(MAX_VISION_LOSS), 0.0, 1.0)


func consume_sanity_flask() -> bool:
	if sanity_flasks <= 0:
		return false
	sanity_flasks -= 1
	sanity_flasks_changed.emit(sanity_flasks)
	return true


func restore_vision() -> void:
	vision_loss = 0
	vision_changed.emit(vision_loss)
	save_game()


## O Vendedor Dragonoide troca memórias por humanidade líquida. De quem era?
func buy_sanity_flask() -> bool:
	if not spend_memories(SANITY_FLASK_PRICE):
		return false
	sanity_flasks += 1
	sanity_flasks_changed.emit(sanity_flasks)
	save_game()
	return true


# --- Loja do Vendedor (v0.23): comprar e vender -------------------------------------------
## O que o Vendedor tem. "limite" = quantos ele tem no total (o resto é infinito).
const SHOP_STOCK := [
	{"id": "frasco_sanidade", "preco": SANITY_FLASK_PRICE},
	{"id": "sucata_temperada", "preco": SUCATA_PRICE},
	{"id": "fragmento_turvo", "preco": 900, "limite": 3},
]
## Quanto o Vendedor paga. Arma: um terço do custo de forja (mínimo 300).
const SELL_PRICES := {"sucata_temperada": 60, "fragmento_turvo": 300}
## Depois que a Rachel cai, ele "vende mais barato. Só um pouco." (diálogo dele)
const RACHEL_DISCOUNT := 0.8

## Quantos de cada item com limite você já comprou (id → quantidade).
var shop_bought := {}


func shop_price(item_id: String) -> int:
	for entry: Dictionary in SHOP_STOCK:
		if entry["id"] == item_id:
			var price := int(entry["preco"])
			return int(round(price * RACHEL_DISCOUNT)) if is_boss_defeated("rachel") else price
	return 0


## Quantos ainda restam (-1 = infinito).
func shop_left(item_id: String) -> int:
	for entry: Dictionary in SHOP_STOCK:
		if entry["id"] == item_id and entry.has("limite"):
			return maxi(int(entry["limite"]) - int(shop_bought.get(item_id, 0)), 0)
	return -1


## "" = pode comprar; senão o motivo: "memories", "esgotado" ou "cheio".
func shop_block_reason(item_id: String) -> String:
	if shop_left(item_id) == 0:
		return "esgotado"
	var item := Items.get_item(item_id)
	if item_id != "frasco_sanidade" and item and item_count(item_id) >= item.max_stack:
		return "cheio"
	if memories < shop_price(item_id):
		return "memories"
	return ""


func buy_from_shop(item_id: String) -> bool:
	if shop_block_reason(item_id) != "":
		return false
	spend_memories(shop_price(item_id))
	if item_id == "frasco_sanidade":
		sanity_flasks += 1  # o Frasco de Sanidade é um contador, não um item da mochila
		sanity_flasks_changed.emit(sanity_flasks)
	else:
		add_item(item_id, 1, false)
	if shop_left(item_id) >= 0:
		shop_bought[item_id] = int(shop_bought.get(item_id, 0)) + 1
	items_changed.emit()
	save_game()
	return true


## Preço de venda (0 = o Vendedor não compra isso).
func sell_price(item_id: String) -> int:
	if SELL_PRICES.has(item_id):
		return int(SELL_PRICES[item_id])
	var weapon := Items.get_weapon(item_id)
	if weapon and item_id != START_WEAPON and item_id != FISTS:
		return maxi(300, weapon.forge_memories / 3)
	return 0


## O que dá para vender agora: [{id, count, price}]. Lembranças, escudo e
## anel NÃO entram (são da história). Arma: só as cópias que não estão na mão.
func sellable_items() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item_id: String in Items.CATALOG:
		var price := sell_price(item_id)
		if price <= 0:
			continue
		var count := _sellable_count(item_id)
		if count > 0:
			result.append({"id": item_id, "count": count, "price": price})
	return result


func _sellable_count(item_id: String) -> int:
	if Items.get_weapon(item_id) == null:
		return item_count(item_id)
	var in_hands := (1 if equipped_weapon == item_id else 0) + (1 if left_hand == item_id else 0)
	return maxi(item_count(item_id) - in_hands, 0)


func sell_to_shop(item_id: String) -> bool:
	var price := sell_price(item_id)
	if price <= 0 or _sellable_count(item_id) <= 0:
		return false
	remove_item(item_id, 1)
	add_memories(price)
	items_changed.emit()
	save_game()
	return true


## Compra genérica de item do Vendedor.
func buy_item(item_id: String, price: int) -> bool:
	var item := Items.get_item(item_id)
	if item == null or item_count(item_id) >= item.max_stack:
		return false
	if not spend_memories(price):
		return false
	add_item(item_id, 1)
	save_game()
	return true


# --- Chefes e descanso ---------------------------------------------------------------------

func mark_boss_defeated(boss_id: String) -> void:
	if not defeated_bosses.has(boss_id):
		defeated_bosses.append(boss_id)
		_grant_boss_rewards(boss_id, true)  # recompensa só na PRIMEIRA vitória
	boss_defeated.emit(boss_id)
	save_game()


func _grant_boss_rewards(boss_id: String, announce: bool) -> void:
	var rewards: Dictionary = BOSS_REWARDS.get(boss_id, {})
	for item_id: String in rewards:
		add_item(item_id, int(rewards[item_id]), announce)


func is_boss_defeated(boss_id: String) -> bool:
	return defeated_bosses.has(boss_id)


## Os Sete Pecados (Bíblia): as sete memórias abrem o caminho até o Núcleo.
const SEVEN := ["aldir", "nyssa", "mabel", "durgan", "rachel", "cassian", "helena"]


func seven_memories() -> int:
	return SEVEN.filter(func(id): return defeated_bosses.has(id)).size()


## Uma condição de porta: o id de um chefe, ou "sete" (as sete memórias juntas).
func requirement_met(requires: String) -> bool:
	if requires.is_empty():
		return true
	if requires == "sete":
		return seven_memories() == SEVEN.size()
	return is_boss_defeated(requires)


func set_rest_point(scene_path: String, spawn_id: String) -> void:
	rest_scene = scene_path
	rest_spawn = spawn_id
	unlock_capsule(scene_path)
	save_game()


# --- Viagem entre Câmaras (menu de descanso) ------------------------------------------------
## Todas as Câmaras para onde dá para viajar, na ordem da jornada.
## O Prólogo fica de fora: ele é um caminho só de ida.
const CAPSULES := [
	{"scene": "res://scenes/world/teatro.tscn", "name": "Teatro Alexandria", "thumb": "teatro"},
	{"scene": "res://scenes/world/cidade.tscn", "name": "Cidade Estilhaçada", "thumb": "cidade"},
	{"scene": "res://scenes/world/bosque.tscn", "name": "Bosque do Sono Eterno", "thumb": "bosque"},
	{"scene": "res://scenes/world/raizes.tscn", "name": "Raízes da Fome", "thumb": "raizes"},
	{"scene": "res://scenes/world/forjas.tscn", "name": "Forjas Ocas", "thumb": "forjas"},
	{"scene": "res://scenes/world/montanha.tscn", "name": "Montanha Carbonizada", "thumb": "montanha"},
	{"scene": "res://scenes/world/dominio.tscn", "name": "Domínio Congelado", "thumb": "dominio"},
	{"scene": "res://scenes/world/nucleo.tscn", "name": "O Núcleo", "thumb": "nucleo"},
]


static func capsule_info(scene_path: String) -> Dictionary:
	for info: Dictionary in CAPSULES:
		if info["scene"] == scene_path:
			return info
	return {}


## Descansou numa Câmara: ela passa a aparecer no menu de viagem.
func unlock_capsule(scene_path: String) -> void:
	if not capsule_info(scene_path).is_empty() and not capsules.has(scene_path):
		capsules.append(scene_path)


## As Câmaras desbloqueadas, na ordem da jornada (não na ordem em que você achou).
func unlocked_capsules() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for info: Dictionary in CAPSULES:
		if is_capsule_unlocked(info["scene"]):
			result.append(info)
	return result


## O Teatro é a casa: depois do Prólogo, a Câmara dele está sempre aberta.
func is_capsule_unlocked(scene_path: String) -> bool:
	return capsules.has(scene_path) or (scene_path == HUB_SCENE and prologue_done)


## Viaja para outra Câmara: a próxima vez que morrer, renasce lá; e o herói
## sai de dentro da cápsula (a mesma animação do despertar).
func travel_to_capsule(scene_path: String) -> bool:
	if not is_capsule_unlocked(scene_path):
		return false
	set_rest_point(scene_path, "camara")
	clear_carry()
	wake_from_capsule = true
	travel(scene_path, "camara")
	return true


# --- Prólogo: a escolha sem aviso -----------------------------------------------------------

## Chamado pela Criança quando o herói a acerta.
func register_child_hurt() -> void:
	criancas_feridas += 1
	child_hurt.emit(criancas_feridas)
	if criancas_feridas == 1:
		save_game()  # a virada que importa (0 → 1) fica gravada na hora


## A queda: o chão some depois da porta e o herói acorda no Teatro.
## Daqui em diante, morrer leva de volta à Câmara do Teatro.
func finish_prologue() -> void:
	prologue_done = true
	spared_child = criancas_feridas == 0
	rest_scene = HUB_SCENE
	rest_spawn = HUB_SPAWN
	wake_from_capsule = true
	clear_carry()
	save_game()
	pending_spawn = HUB_SPAWN
	_change_scene(HUB_SCENE, 0.9)


# --- Inventário ------------------------------------------------------------------------

## Guarda um item. announce = false para ganhos "silenciosos" (migração do save).
## Devolve quantos realmente couberam (respeita o max_stack da ficha).
func add_item(item_id: String, count: int = 1, announce: bool = true) -> int:
	var item := Items.get_item(item_id)
	if item == null:
		push_warning("Item desconhecido: %s" % item_id)
		return 0
	if count <= 0:
		return 0
	var before := item_count(item_id)
	var after := mini(before + count, item.max_stack)
	inventory[item_id] = after
	var added := after - before
	if item_id == SHIELD and before == 0 and left_hand.is_empty():
		left_hand = SHIELD  # pegou o escudo com a mão livre: já vai para ela
	if item is WeaponData and equipped_weapon == FISTS and item_id != FISTS:
		equipped_weapon = item_id  # achou uma arma de mãos vazias: já empunha
		weapon_changed.emit(equipped_weapon)
	items_changed.emit()
	if announce and added > 0:
		item_added.emit(item_id, added)
	return added


func item_count(item_id: String) -> int:
	return int(inventory.get(item_id, 0))


func has_item(item_id: String, count: int = 1) -> bool:
	return item_count(item_id) >= count


## Padrão "try_": ou tira tudo, ou não tira nada.
func remove_item(item_id: String, count: int = 1) -> bool:
	if count <= 0 or not has_item(item_id, count):
		return false
	var left := item_count(item_id) - count
	if left > 0:
		inventory[item_id] = left
	else:
		inventory.erase(item_id)
	items_changed.emit()
	return true


func set_flag(flag: String) -> void:
	if not flags.get(flag, false):
		flags[flag] = true
		save_game()


func has_flag(flag: String) -> bool:
	return bool(flags.get(flag, false))


func is_pickup_collected(key: String) -> bool:
	return collected_pickups.has(key)


func collect_pickup(key: String) -> void:
	if not key.is_empty() and not collected_pickups.has(key):
		collected_pickups.append(key)


# --- Mão esquerda --------------------------------------------------------------------------

func has_shield() -> bool:
	return has_item("escudo_remendado")


## O herói só ergue o escudo se tem um E ele está equipado.
func shield_ready() -> bool:
	return shield_equipped() and not two_handing  # em duas mãos o escudo vai para as costas


## O escudo está na mão esquerda (mesmo que agora a arma esteja em duas mãos).
func shield_equipped() -> bool:
	return left_hand == SHIELD and has_shield()


func set_shield_equipped(equipped: bool) -> void:
	if equipped and has_shield():
		left_hand = SHIELD
	elif left_hand == SHIELD:
		left_hand = ""
	items_changed.emit()
	weapon_changed.emit(equipped_weapon)
	save_game()


# --- Armadura ---------------------------------------------------------------------------
# Cada peça vestida soma um pouco do efeito do conjunto dela (ArmorSets). O
# Game só guarda O QUE está vestido e responde "quanto vale o efeito X agora";
# quem aplica o número é quem cuida daquela regra (o herói, o inimigo, a arma).

func _empty_armor() -> Dictionary:
	var result := {}
	for slot in ArmorData.SLOTS:
		result[slot] = ""
	return result


## Veste a peça no espaço dela (troca o que estava lá). false = você não tem.
func equip_armor(id: String) -> bool:
	var piece := Items.get_armor(id)
	if piece == null or not has_item(id):
		return false
	armor[piece.slot] = id
	_armor_updated()
	return true


func unequip_armor(slot: String) -> void:
	if str(armor.get(slot, "")).is_empty():
		return
	armor[slot] = ""
	_armor_updated()


func is_armor_equipped(id: String) -> bool:
	var piece := Items.get_armor(id)
	return piece != null and armor.get(piece.slot, "") == id


func armor_in(slot: String) -> ArmorData:
	return Items.get_armor(str(armor.get(slot, "")))


## Quantas peças DESTE conjunto estão vestidas (0 a 5).
func armor_pieces(set_id: String) -> int:
	var count := 0
	for slot in ArmorData.SLOTS:
		var piece := armor_in(slot)
		if piece and piece.set_id == set_id:
			count += 1
	return count


## Quanto o efeito vale agora (0.18 = +18%). Soma TODAS as peças vestidas
## que mexem nesse efeito — misturar conjuntos funciona.
func armor_bonus(effect: String) -> float:
	var total := 0.0
	for slot in ArmorData.SLOTS:
		var piece := armor_in(slot)
		if piece and ArmorSets.effect_of(piece.set_id) == effect:
			total += ArmorSets.per_piece(piece.set_id)
	return total


## Peças do efeito X vestidas (o "passo" precisa da contagem, não da soma).
func armor_effect_pieces(effect: String) -> int:
	var count := 0
	for slot in ArmorData.SLOTS:
		var piece := armor_in(slot)
		if piece and ArmorSets.effect_of(piece.set_id) == effect:
			count += 1
	return count


## As peças que você tem (para o inventário), na ordem do catálogo.
func owned_armor() -> Array[String]:
	var result: Array[String] = []
	for id: String in Items.CATALOG:
		if Items.get_armor(id) and has_item(id):
			result.append(id)
	return result


func _armor_updated() -> void:
	items_changed.emit()
	armor_changed.emit()
	save_game()


# --- Ferreiro: melhoria da arma -------------------------------------------------------------

func weapon_damage_multiplier() -> float:
	return 1.0 + weapon_level * WEAPON_DAMAGE_PER_LEVEL


func weapon_level_cap() -> int:
	return WEAPON_LEVEL_CAP_AFTER_DURGAN if is_boss_defeated("durgan") else WEAPON_LEVEL_CAP


## Custo da próxima melhoria ({} = já está no máximo de tudo).
func next_upgrade_cost() -> Dictionary:
	if weapon_level >= WEAPON_UPGRADES.size():
		return {}
	return WEAPON_UPGRADES[weapon_level]


## "" = pode melhorar; senão, o MOTIVO (o menu do Ferreiro mostra o texto).
func upgrade_block_reason() -> String:
	var cost := next_upgrade_cost()
	if cost.is_empty():
		return "max"
	if weapon_level >= weapon_level_cap():
		return "cap"
	if memories < int(cost["memories"]):
		return "memories"
	if not has_item("sucata_temperada", int(cost["sucata_temperada"])):
		return "sucata"
	return ""


func try_upgrade_weapon() -> bool:
	if upgrade_block_reason() != "":
		return false
	var cost := next_upgrade_cost()
	# Confere ANTES e gasta DEPOIS: nunca fica com metade do pagamento feito.
	spend_memories(int(cost["memories"]))
	remove_item("sucata_temperada", int(cost["sucata_temperada"]))
	weapon_level += 1
	weapon_upgraded.emit(weapon_level)
	items_changed.emit()
	save_game()
	return true


# --- Armas de chefe: forjar e equipar ------------------------------------------------------

## Quantas desta arma você tem (a espada inicial já conta uma; o Ferreiro
## forja uma cópia para a outra mão — por isso o máximo é 2).
func weapon_count(id: String) -> int:
	if Items.get_weapon(id) == null:
		return 0
	if id == FISTS:
		return 2  # as duas mãos, sempre
	return (1 if id == START_WEAPON and starter_sword else 0) + item_count(id)


func owns_weapon(id: String) -> bool:
	return weapon_count(id) > 0


## As armas que você tem, na ordem da forja (os punhos no fim: sempre "tem").
func owned_weapons() -> Array[String]:
	var result: Array[String] = []
	for id in smith_weapons():
		if owns_weapon(id):
			result.append(id)
	result.append(FISTS)
	return result


func forgeable_weapons() -> Array[String]:
	return FORGEABLE_WEAPONS


## O que aparece na forja: as armas comuns (só cópia da que você tem) e as 8 de chefe.
func smith_weapons() -> Array[String]:
	var result: Array[String] = BASIC_WEAPONS.duplicate()
	result.append_array(FORGEABLE_WEAPONS)
	return result


func current_weapon() -> WeaponData:
	var weapon := Items.get_weapon(equipped_weapon)
	return weapon if weapon else Items.get_weapon(FISTS)


## A arma da mão esquerda (null = escudo ou mão vazia).
func left_weapon() -> WeaponData:
	return Items.get_weapon(left_hand)


## Cópias desta arma que sobram para uma mão (a outra mão pode estar usando uma).
func _copies_free(id: String, hand: String) -> int:
	var other := left_hand if hand == "direita" else equipped_weapon
	return weapon_count(id) - (1 if other == id else 0)


## Equipa uma arma numa mão ("direita" ou "esquerda").
## Sem uma cópia sobrando, a arma MUDA de mão: sai da esquerda e vai para a
## direita. A direita nunca fica vazia (o golpe precisa de uma arma).
func equip_weapon(id: String, hand: String = "direita") -> bool:
	if not owns_weapon(id):
		return false
	if id == FISTS and hand == "esquerda":
		clear_left_hand()  # punho na esquerda = mão vazia
		return true
	if hand == "esquerda":
		if _copies_free(id, "esquerda") <= 0:
			return false  # a única está na direita: forje uma cópia
		left_hand = id
	else:
		if left_hand == id and weapon_count(id) < 2:
			left_hand = ""
		equipped_weapon = id
	weapon_changed.emit(equipped_weapon)
	items_changed.emit()
	save_game()
	return true


func clear_left_hand() -> void:
	left_hand = ""
	weapon_changed.emit(equipped_weapon)
	items_changed.emit()
	save_game()


func set_two_handing(on: bool) -> void:
	if two_handing == on:
		return
	two_handing = on
	weapon_changed.emit(equipped_weapon)
	items_changed.emit()


## Como as mãos estão agora — decide o que L1, L2, R1 e R2 fazem:
##   "duas_maos" · "escudo" · "vazia" · "par" (duas do mesmo tipo) · "dupla" (tipos diferentes)
func hand_mode() -> String:
	if two_handing:
		return "duas_maos"
	if left_hand.is_empty():
		return "vazia"
	if left_hand == SHIELD:
		return "escudo" if has_shield() else "vazia"
	var left := left_weapon()
	if left == null:
		return "vazia"
	return "par" if left.weapon_class == current_weapon().weapon_class else "dupla"


## "" = pode forjar; senão o motivo (o menu do Ferreiro mostra a fala certa).
func forge_block_reason(id: String) -> String:
	var weapon := Items.get_weapon(id)
	if weapon == null or not smith_weapons().has(id):
		return "lembranca"
	if weapon_count(id) >= 2:
		return "owned"  # já tem uma para cada mão
	if BASIC_WEAPONS.has(id) and not owns_weapon(id):
		return "basica"  # arma comum: ele copia, não inventa
	if not weapon.memory_item.is_empty() and not has_item(weapon.memory_item):
		return "lembranca"
	if memories < weapon.forge_memories:
		return "memories"
	if not has_item("sucata_temperada", weapon.forge_sucata):
		return "sucata"
	return ""


func try_forge_weapon(id: String) -> bool:
	if forge_block_reason(id) != "":
		return false
	var weapon := Items.get_weapon(id)
	spend_memories(weapon.forge_memories)
	if weapon.forge_sucata > 0:
		remove_item("sucata_temperada", weapon.forge_sucata)
	add_item(id, 1, true)  # a Lembrança fica: ela é a chave do Núcleo
	save_game()
	return true


## Dano de um golpe desta arma com os atributos e o reforço atuais.
## O herói usa ESTA função ao bater — a ficha e o golpe nunca discordam.
func weapon_hit_damage(weapon: WeaponData, attack: AttackData) -> float:
	return attack.damage * weapon.damage_scale * weapon.scaling_multiplier(attributes) * weapon_damage_multiplier() \
		* (1.0 + armor_bonus("forca"))


## Ataque (leve, forte) para a ficha do inventário.
func weapon_power(weapon: WeaponData) -> Vector2i:
	var light: AttackData = weapon.light_combo[0] if not weapon.light_combo.is_empty() else BASE_LIGHT
	var heavy: AttackData = weapon.heavy_attack if weapon.heavy_attack else BASE_HEAVY
	return Vector2i(roundi(weapon_hit_damage(weapon, light)), roundi(weapon_hit_damage(weapon, heavy)))


# --- Orbe Branco: fragmentos → frascos -------------------------------------------------------

func can_purify_fragment() -> bool:
	return has_item("fragmento_turvo") and health_flasks_max < MAX_HEALTH_FLASKS


func purify_fragment() -> bool:
	if not can_purify_fragment():
		return false
	remove_item("fragmento_turvo")
	health_flasks_max += 1
	attributes_changed.emit()
	save_game()
	return true


# --- Vida/frascos levados pela porta --------------------------------------------------------

## Guarda o estado do herói antes de trocar de área (chamado pela AreaExit).
## Recebe números, não o Player: um autoload que cita a classe Player cria uma
## referência circular entre scripts (Game ↔ Player) e o Godot acusa vazamento ao fechar.
func carry(health: float, flasks: int) -> void:
	carry_health = health
	carry_flasks = flasks


func clear_carry() -> void:
	carry_health = -1.0
	carry_flasks = -1


# --- Slots de save (3, como nos soulslike) ---------------------------------------------------

func slot_path(n: int) -> String:
	return "%s%d.json" % [slot_prefix, n]


## Passa a ler e gravar no slot n (e lembra dele para o "Continuar").
func use_slot(n: int) -> void:
	slot = clampi(n, 1, SLOT_COUNT)
	save_path = slot_path(slot)
	if persistence_enabled:
		var config := ConfigFile.new()
		config.set_value("save", "ultimo", slot)
		config.save(LAST_SLOT_PATH)


func _read_last_slot() -> int:
	var config := ConfigFile.new()
	if config.load(LAST_SLOT_PATH) != OK:
		return 1
	return clampi(int(config.get_value("save", "ultimo", 1)), 1, SLOT_COUNT)


func slot_has_save(n: int) -> bool:
	var path := slot_path(n)
	return FileAccess.file_exists(path) or FileAccess.file_exists(path + ".bak")


## Existe pelo menos um save (o título mostra "Carregar").
func any_save() -> bool:
	for n in range(1, SLOT_COUNT + 1):
		if slot_has_save(n):
			return true
	return false


## O resumo que a tela de saves mostra, lido do arquivo SEM carregar o jogo:
## {nivel, memorias, mortes, area, tempo, aparencia, chefes}. Vazio = slot livre.
func slot_summary(n: int) -> Dictionary:
	var data := _read_save(slot_path(n))
	if data.is_empty():
		data = _read_save(slot_path(n) + ".bak")
	if data.is_empty():
		return {}
	var total := 0
	var saved_attributes: Variant = data.get("attributes", {})
	for attribute in StatsComponent.ATTRIBUTE_NAMES:
		total += int((saved_attributes as Dictionary).get(attribute, StatsComponent.BASE_ATTRIBUTE)) if saved_attributes is Dictionary else StatsComponent.BASE_ATTRIBUTE
	var rest := str(data.get("rest_scene", START_SCENE))
	var area := str(capsule_info(rest).get("name", ""))
	if area.is_empty():
		area = "Complexo das Cápsulas" if rest == START_SCENE else "?"
	var bosses: Variant = data.get("defeated_bosses", [])
	return {
		"nivel": total - StatsComponent.ATTRIBUTE_NAMES.size() * StatsComponent.BASE_ATTRIBUTE + 1,
		"memorias": int(data.get("memories", 0)),
		"mortes": int(data.get("deaths", 0)),
		"area": area,
		"tempo": float(data.get("play_seconds", 0.0)),
		"aparencia": Appearance.sanitized(data.get("appearance", {})),
		"pecados": SEVEN.filter(func(id): return (bosses as Array).has(id)).size() if bosses is Array else 0,
		"ciclo": maxi(int(data.get("ciclo", 0)), 0),
	}


## "12:05" (horas:minutos) para a tela de saves.
static func format_play_time(seconds: float) -> String:
	var minutes := int(seconds) / 60
	return "%d:%02d" % [minutes / 60, minutes % 60]


## Versões antigas tinham UM save. Ele vira o slot 1 (nada se perde).
func _migrate_single_save() -> void:
	if not persistence_enabled:
		return
	for suffix in ["", ".bak"]:
		var old: String = SAVE_PATH + suffix
		var new: String = slot_path(1) + suffix
		if FileAccess.file_exists(old) and not FileAccess.file_exists(new):
			DirAccess.rename_absolute(_absolute(old), _absolute(new))


# --- Persistência (JSON) ---------------------------------------------------------------------

func has_save() -> bool:
	return FileAccess.file_exists(save_path) or FileAccess.file_exists(_backup_path())


func save_game() -> void:
	if not persistence_enabled:
		return
	var text := JSON.stringify(_to_dict(), "\t")
	var tmp_path := save_path + ".tmp"
	var file := FileAccess.open(tmp_path, FileAccess.WRITE)
	if file == null:
		push_warning("Não foi possível salvar: %s" % error_string(FileAccess.get_open_error()))
		return
	file.store_string(text)
	file.close()  # fecha ANTES de renomear (no Windows, arquivo aberto não pode ser movido)
	# Disco cheio ou gravação cortada? Então o save antigo continua valendo.
	if _read_save(tmp_path).is_empty():
		push_warning("Save temporário ilegível; o save anterior foi mantido.")
		return
	if FileAccess.file_exists(save_path):
		DirAccess.copy_absolute(_absolute(save_path), _absolute(_backup_path()))
	var error := DirAccess.rename_absolute(_absolute(tmp_path), _absolute(save_path))
	if error != OK:
		push_warning("Não foi possível trocar o save: %s" % error_string(error))


## Carrega o save; se ele estiver corrompido, tenta a cópia de segurança (.bak).
func load_game() -> bool:
	for path in [save_path, _backup_path()]:
		var data := _read_save(path)
		if not data.is_empty():
			_from_dict(data)
			return true
	return false


func delete_save() -> void:
	for path in [save_path, _backup_path(), save_path + ".tmp"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(_absolute(path))


func _backup_path() -> String:
	return save_path + ".bak"


## Os métodos estáticos de DirAccess pedem caminho absoluto do sistema
## ("user://" vira a pasta de dados do app — no Android, a memória interna).
func _absolute(path: String) -> String:
	return ProjectSettings.globalize_path(path)


## Devolve o conteúdo do save ou {} se não existir / não for um JSON válido.
func _read_save(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	# JSON.new().parse() devolve um código de erro em silêncio; o atalho
	# JSON.parse_string() imprimiria um ERROR no log a cada save quebrado.
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK:
		return {}
	if typeof(json.data) != TYPE_DICTIONARY:
		return {}
	return json.data


## CÓPIAS (duplicate) dos arrays/dicionários: o dicionário devolvido não pode
## apontar para os mesmos objetos do Game. Senão um reset_progress() (que faz
## .clear()) esvaziaria também o "save" que ainda está na mão de quem chamou.
func _to_dict() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"memories": memories,
		"deaths": deaths,
		"vision_loss": vision_loss,
		"sanity_flasks": sanity_flasks,
		"health_flasks_max": health_flasks_max,
		"attributes": attributes.duplicate(),
		"defeated_bosses": defeated_bosses.duplicate(),
		"rest_scene": rest_scene,
		"rest_spawn": rest_spawn,
		"criancas_feridas": criancas_feridas,
		"prologue_done": prologue_done,
		"spared_child": spared_child,
		"inventory": inventory.duplicate(),
		"weapon_level": weapon_level,
		"left_hand": left_hand,
		"two_handing": two_handing,
		"equipped_weapon": equipped_weapon,
		"armor": armor.duplicate(),
		"ciclo": cycle,
		"guardiao": guardian.duplicate(true),
		"espada_inicial": starter_sword,
		"arma_escolhida": chosen_weapon,
		"collected_pickups": collected_pickups.duplicate(),
		"capsules": capsules.duplicate(),
		"play_seconds": play_seconds,
		"flags": flags.duplicate(),
		"shop_bought": shop_bought.duplicate(),
		"appearance": appearance.duplicate(),
	}


func _from_dict(data: Dictionary) -> void:
	reset_progress()
	var version := int(data.get("version", 1))
	memories = maxi(int(data.get("memories", 0)), 0)
	deaths = maxi(int(data.get("deaths", 0)), 0)
	vision_loss = clampi(int(data.get("vision_loss", 0)), 0, MAX_VISION_LOSS)
	sanity_flasks = maxi(int(data.get("sanity_flasks", START_SANITY_FLASKS)), 0)
	health_flasks_max = clampi(int(data.get("health_flasks_max", START_HEALTH_FLASKS)), 1, MAX_HEALTH_FLASKS)
	var saved_attributes: Variant = data.get("attributes", {})
	if typeof(saved_attributes) == TYPE_DICTIONARY:
		for attribute in StatsComponent.ATTRIBUTE_NAMES:
			attributes[attribute] = int(saved_attributes.get(attribute, StatsComponent.BASE_ATTRIBUTE))
	var saved_bosses: Variant = data.get("defeated_bosses", [])
	if typeof(saved_bosses) == TYPE_ARRAY:
		for boss in saved_bosses:
			defeated_bosses.append(str(boss))
	rest_scene = str(data.get("rest_scene", START_SCENE))
	rest_spawn = str(data.get("rest_spawn", START_SPAWN))
	if data.has("vibration"):  # saves antigos: a vibração agora mora nas Opções do aparelho
		Settings.import_legacy_vibration(bool(data["vibration"]))
	criancas_feridas = maxi(int(data.get("criancas_feridas", 0)), 0)
	# MIGRAÇÃO: um save da versão 1 é de antes do Prólogo existir — aquele jogo
	# já começou no Teatro, então o prólogo conta como feito.
	prologue_done = bool(data.get("prologue_done", version < 2))
	spared_child = bool(data.get("spared_child", false))
	# Inventário: só entra o que o catálogo conhece (um item removido do jogo
	# numa versão futura não pode quebrar o save de ninguém).
	var saved_items: Variant = data.get("inventory", {})
	if typeof(saved_items) == TYPE_DICTIONARY:
		for item_id in saved_items:
			var item := Items.get_item(str(item_id))
			if item:
				inventory[item.id] = clampi(int(saved_items[item_id]), 0, item.max_stack)
	weapon_level = clampi(int(data.get("weapon_level", 0)), 0, WEAPON_UPGRADES.size())
	# NG+ (v0.27). Saves antigos: primeira jornada, espada inicial de graça.
	cycle = maxi(int(data.get("ciclo", 0)), 0)
	var saved_guardian: Variant = data.get("guardiao", {})
	guardian = (saved_guardian as Dictionary).duplicate(true) if saved_guardian is Dictionary else {}
	starter_sword = bool(data.get("espada_inicial", true))
	chosen_weapon = str(data.get("arma_escolhida", ""))
	# Itens-chave de chefes já vencidos que faltem no save (ex.: a Lembrança do
	# Cavaleiro, que só existe desde a v0.20) são devolvidos. Como são únicos,
	# repetir isto não duplica nada.
	for boss in defeated_bosses:
		var rewards: Dictionary = BOSS_REWARDS.get(boss, {})
		for item_id: String in rewards:
			var item := Items.get_item(item_id)
			if item and item.kind == ItemData.Kind.LEMBRANCA and not inventory.has(item_id):
				inventory[item_id] = 1
	play_seconds = maxf(float(data.get("play_seconds", 0.0)), 0.0)
	var saved_shop: Variant = data.get("shop_bought", {})
	if typeof(saved_shop) == TYPE_DICTIONARY:
		for item_id in saved_shop:
			shop_bought[str(item_id)] = maxi(int(saved_shop[item_id]), 0)
	var saved_capsules: Variant = data.get("capsules", [])
	if typeof(saved_capsules) == TYPE_ARRAY:
		for scene_path in saved_capsules:
			unlock_capsule(str(scene_path))
	# MIGRAÇÃO (saves de antes da v0.22): a Câmara onde você descansou por último
	# e a do Teatro (depois do Prólogo) já contam como desbloqueadas.
	unlock_capsule(rest_scene)
	if prologue_done:
		unlock_capsule(HUB_SCENE)
	var saved_weapon := str(data.get("equipped_weapon", START_WEAPON))
	equipped_weapon = saved_weapon if owns_weapon(saved_weapon) else (START_WEAPON if owns_weapon(START_WEAPON) else FISTS)
	# MIGRAÇÃO v0.20 → v0.21: antes só existia "escudo equipado ou não".
	var saved_left := str(data.get("left_hand", SHIELD if bool(data.get("shield_equipped", false)) else ""))
	left_hand = ""
	if saved_left == SHIELD:
		left_hand = SHIELD if has_shield() else ""
	elif Items.get_weapon(saved_left) != null and _copies_free(saved_left, "esquerda") > 0:
		left_hand = saved_left
	two_handing = bool(data.get("two_handing", false))
	# Armadura: só volta o que você TEM e que serve naquele espaço (save
	# editado à mão ou de versão futura não veste uma calça na cabeça).
	var saved_armor: Variant = data.get("armor", {})
	if typeof(saved_armor) == TYPE_DICTIONARY:
		for slot in ArmorData.SLOTS:
			var piece := Items.get_armor(str(saved_armor.get(slot, "")))
			if piece and piece.slot == slot and has_item(piece.id):
				armor[slot] = piece.id
	var saved_pickups: Variant = data.get("collected_pickups", [])
	if typeof(saved_pickups) == TYPE_ARRAY:
		for key in saved_pickups:
			collected_pickups.append(str(key))
	var saved_flags: Variant = data.get("flags", {})
	if typeof(saved_flags) == TYPE_DICTIONARY:
		for flag in saved_flags:
			# Marcas não são só sim/não: "final" é um texto e "finais_vistos" uma
			# lista. Converter tudo para bool quebrava o save de quem viu um final.
			var value: Variant = saved_flags[flag]
			flags[str(flag)] = value if value is bool or value is String or value is Array else bool(value)
	# Saves de antes da criação de personagem não têm "appearance": ficam com
	# a aparência padrão (Homem/Magro/Sereno/Curto), que é o visual antigo.
	appearance = Appearance.sanitized(data.get("appearance", {}))
	# MIGRAÇÃO v2 → v3: quem já venceu chefes antes do inventário existir
	# recebe agora o que eles deixam (sem anúncio: é acerto de contas).
	if version < 3:
		for boss in defeated_bosses:
			_grant_boss_rewards(boss, false)
	if not ResourceLoader.exists(rest_scene):
		rest_scene = START_SCENE if not prologue_done else HUB_SCENE
		rest_spawn = START_SPAWN


## Save e cópia ilegíveis: guarda os arquivos com outro nome (dá para tentar
## recuperar à mão) em vez de apagá-los, e libera o "Novo jogo".
func _quarantine_broken_save() -> void:
	for path in [save_path, _backup_path()]:
		if FileAccess.file_exists(path):
			DirAccess.rename_absolute(_absolute(path), _absolute(path + ".corrompido"))


# --- Fluxo entre cenas -----------------------------------------------------------------------

## `look`: a aparência escolhida na tela de criação (vazio = a padrão) e,
## na chave "arma", a arma comum escolhida (fica no chão do Prólogo).
func new_game(look: Dictionary = {}) -> void:
	reset_progress()
	_awaken(look)


## NG+: "Iniciar nova jornada". Outro experimento acorda num mundo mais duro.
## Ele herda SÓ o nível (os atributos); o resto é de um corpo novo. O
## guardião (se o final foi Proteger) e os finais já vistos continuam.
func start_new_journey(look: Dictionary = {}) -> void:
	var keep_attributes := attributes.duplicate()
	var next_cycle := cycle + 1
	var keep_guardian := guardian.duplicate(true)
	var seen: Array = (flags.get("finais_vistos", []) as Array).duplicate()
	reset_progress()
	attributes = keep_attributes
	cycle = next_cycle
	guardian = keep_guardian
	flags["finais_vistos"] = seen
	_awaken(look)


## A jornada já terminou (viu um final)? Libera "Nova jornada" na Câmara.
func journey_complete() -> bool:
	return flags.has("final")


## "Explorar o mundo atual": volta para a última Câmara depois dos créditos.
func explore_after_ending() -> void:
	session_active = true
	clear_carry()
	pending_spawn = rest_spawn
	_change_scene(rest_scene)


## Como o experimento estava ao vencer o Núcleo: é assim que ele vai lutar
## quando o próximo chegar (a arma "tunada" é decidida na luta).
func _guardian_snapshot() -> Dictionary:
	return {
		"aparencia": appearance.duplicate(),
		"direita": equipped_weapon,
		"esquerda": left_hand,
		"duas_maos": two_handing,
		"armadura": armor.duplicate(),
		"atributos": attributes.duplicate(),
		"frascos": health_flasks_max,
		"ciclo": cycle,
	}


func _awaken(look: Dictionary) -> void:
	appearance = Appearance.sanitized(look)
	var weapon_id := str(look.get("arma", START_WEAPON))
	chosen_weapon = weapon_id if BASIC_WEAPONS.has(weapon_id) else START_WEAPON
	starter_sword = false
	equipped_weapon = FISTS  # a arma está no chão, perto da cápsula
	session_active = true
	save_game()
	pending_spawn = START_SPAWN
	wake_from_capsule = true
	_change_scene(START_SCENE)


## Devolve false se o save não pôde ser lido (o título avisa o jogador).
## Importante: NUNCA começa um jogo novo por conta própria — isso gravaria
## por cima do save que talvez ainda dê para recuperar.
func continue_game() -> bool:
	if not load_game():
		_quarantine_broken_save()
		return false
	session_active = true
	clear_carry()
	pending_spawn = rest_spawn
	_change_scene(rest_scene)
	return true


func travel(scene_path: String, spawn_id: String) -> void:
	pending_spawn = spawn_id
	_change_scene(scene_path)


## Depois da morte: renasce na Câmara com tudo cheio (nada é carregado pela porta).
func respawn() -> void:
	clear_carry()
	pending_spawn = rest_spawn
	_change_scene(rest_scene, 0.9)


## Os finais já vistos (lidos do save no disco; o título mostra antes de carregar).
func endings_seen() -> Array:
	if session_active:
		return flags.get("finais_vistos", [])
	var data := _read_save(save_path)
	var saved_flags: Variant = data.get("flags", {})
	return (saved_flags as Dictionary).get("finais_vistos", []) if saved_flags is Dictionary else []


## A escolha no Núcleo: grava qual final (e quais já foram vistos) e mostra o final.
func show_ending(kind: String) -> void:
	flags["final"] = kind
	# Proteger: este experimento fica no lugar do Cavaleiro no próximo ciclo.
	guardian = _guardian_snapshot() if kind == "proteger" else {}
	var seen: Array = flags.get("finais_vistos", [])
	if not seen.has(kind):
		seen.append(kind)
	flags["finais_vistos"] = seen
	save_game()
	clear_carry()
	_change_scene(ENDING_SCENE, 1.2)


func go_to_title() -> void:
	save_game()
	session_active = false
	clear_carry()
	_change_scene(TITLE_SCENE)


## Toda troca de cena passa por aqui (um ponto só = fácil de testar e de mudar).
func _change_scene(path: String, duration: float = 0.4) -> void:
	last_scene_request = path
	if scene_changes_enabled:
		Fader.change_scene(path, duration)
