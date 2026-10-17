extends Node
## Passeio automático que tira screenshots do jogo (verificação visual).
## Precisa de tela (no Linux sem monitor: xvfb-run):
##   godot --path . --rendering-driver opengl3 res://tests/screenshot_tour.tscn -- --out=/caminho

var out_dir := "user://screenshots"
## "--only=bosque" (ou "--only=raizes") tira só as fotos daquela área.
var only := ""
var _current: Node


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out_dir = arg.substr(6)
		elif arg.begins_with("--only="):
			only = arg.substr(7)
	DirAccess.make_dir_recursive_absolute(out_dir)
	Game.persistence_enabled = false
	Game.scene_changes_enabled = false  # a queda do Prólogo não pode trocar a cena do passeio
	if only == "raizes":
		await _tour_roots()
		Game.quit_game()
		return
	if only == "forjas":
		await _tour_forge()
		Game.quit_game()
		return
	if only == "montanha":
		await _tour_mountain()
		Game.quit_game()
		return
	if only == "dominio":
		await _tour_ice()
		Game.quit_game()
		return
	if only != "bosque":
		await _tour()
	await _tour_forest()
	await _tour_roots()
	await _tour_forge()
	await _tour_mountain()
	await _tour_ice()
	Game.quit_game()


func shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	image.save_png(out_dir.path_join(name + ".png"))
	print("screenshot: ", name)


func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds, true, false, true).timeout


func open(path: String) -> Node:
	if is_instance_valid(_current):
		_current.queue_free()
		await get_tree().process_frame
	_current = (load(path) as PackedScene).instantiate()
	add_child(_current)
	return _current


func hold(action: StringName, seconds: float) -> void:
	Input.action_press(action)
	await wait(seconds)
	Input.action_release(action)


func tap(action: StringName) -> void:
	Input.action_press(action)
	await wait(0.05)
	Input.action_release(action)


## Enquadra um ponto do mapa (sem mexer no herói).
func frame_point(level: Level, at: Vector2) -> Node2D:
	var marker := Node2D.new()
	level.add_child(marker)
	marker.global_position = at
	level.camera.target = marker
	level.camera.snap_to_target()
	return marker


func find_npc(level: Level, dialogue_id: String) -> NPC:
	for node in level.get_tree().get_nodes_in_group("npcs"):
		if (node as NPC).dialogue_id == dialogue_id:
			return node
	return null


func skip_narration(root: Node) -> void:
	for node in root.get_children():
		if node is Narration:
			(node as Narration).skip()


func _tour() -> void:
	# 1) Título
	await open("res://scenes/ui/title_screen.tscn")
	await wait(1.2)
	await shot("01_titulo")

	await _tour_prologue()

	# 2) Teatro, acordando na Câmara
	Game.reset_progress()
	Game.pending_spawn = "camara"
	var level := await open("res://scenes/world/teatro.tscn") as Level
	await wait(1.6)
	await shot("02_teatro_camara")
	await hold(&"move_down", 1.2)
	await wait(0.4)
	await shot("03_teatro_plateia")

	# 3) Ferreiro e boneco de treino: golpe com meia-lua e número de dano
	level.player.global_position = Vector2(9 * 16 + 8 - 20, 29 * 16 + 14)
	level.player.facing = Vector2.RIGHT
	level.camera.snap_to_target()
	await wait(0.3)
	await tap(&"attack")
	await wait(0.2)
	await shot("04_boneco_golpe")
	for i in 4:
		await tap(&"attack")
		await wait(0.35)
	level.player.stats.drain_stamina(999.0)  # força a Exaustão para a foto
	await tap(&"attack")
	await wait(0.15)
	await shot("05_exausto")

	# 4) Diálogo com a Fada e menu de nível
	Game.memories = 640
	level.player.stats.revive()
	var fada: NPC = null
	for node in level.get_tree().get_nodes_in_group("npcs"):
		if (node as NPC).dialogue_id == "fada":
			fada = node
	level.player.global_position = fada.global_position + Vector2(14, 6)
	level.camera.snap_to_target()
	level._on_npc_talked(fada)
	await wait(1.4)
	await shot("06_dialogo_fada")
	level.hud.dialogue._tap()
	await wait(0.1)
	level.hud.dialogue._tap()
	await wait(1.6)
	level.hud.dialogue._tap()
	await wait(0.3)
	await shot("07_opcoes_fada")
	level.hud.dialogue._chosen.emit("subir_nivel")
	await wait(0.4)
	level.hud.level_up_menu._level_up("vitalidade")
	await wait(0.2)
	await shot("08_menu_fada")
	level.hud.level_up_menu._closed.emit()
	await wait(0.3)

	# 4b) Forja do Ferreiro e inventário
	Game.memories = 900
	Game.add_item("sucata_temperada", 5, false)
	Game.add_item("fragmento_turvo", 1, false)
	Game.add_item("escudo_remendado", 1, false)
	Game.add_item("lembranca_aldir", 1, false)
	level._on_dialogue_action("melhorar_arma")
	await wait(0.4)
	level.hud.smith_menu._upgrade_button.pressed.emit()
	await wait(0.5)
	await shot("08a_forja")
	level.hud.smith_menu._closed.emit()
	await wait(0.3)
	level.hud.open_inventory()
	await wait(0.3)
	level.hud.inventory_menu._select("escudo_remendado")
	await wait(0.2)
	await shot("08b_inventario")
	level.hud.inventory_menu._select("lembranca_aldir")
	await wait(0.2)
	await shot("08c_inventario_lembranca")
	level.hud.inventory_menu.close()
	await wait(0.3)
	Game.inventory = {}
	Game.weapon_level = 0
	Game.items_changed.emit()

	# 5) Helena: desafio, salto ao palco, luta
	level.boss_arena.arm()
	await wait(1.2)
	level.player.global_position = Vector2(17 * 16, 12 * 16 + 8)
	level.camera.snap_to_target()
	await wait(1.0)
	await shot("09_helena_fase1")
	var helena := level.boss_arena.boss as HelenaAltiva
	level.player.global_position = helena.global_position + Vector2(-70, 30)
	helena._queue_combo([helena.estocada])
	await wait(0.45)
	await shot("10_helena_estocada_aviso")
	await wait(1.2)
	helena.stats.take_damage(helena.stats.max_health * 0.55)
	helena._on_damaged(0.0, HitInfo.new(), false)
	await wait(1.0)
	await shot("11_helena_fase2")
	await wait(1.5)
	helena._start_leap()
	await wait(0.4)
	await shot("12_helena_salto")
	await wait(1.5)
	helena.stats.take_damage(9999.0)
	await wait(1.0)
	await shot("13_helena_caida")
	await wait(3.6)
	await shot("14_helena_fase3")

	# 6) Morte: "VOCÊ ESQUECEU"
	Game.memories = 300
	level.player.stats.take_damage(9999.0)
	await wait(2.6)
	await shot("15_morte")

	# 7) Visão escurecida depois de várias mortes
	Game.vision_loss = 5
	Game.deaths = 5
	Game.pending_spawn = "camara"
	level = await open("res://scenes/world/teatro.tscn") as Level
	await wait(4.0)
	await shot("16_visao_perdida")
	Game.vision_loss = 0
	Game.deaths = 0

	# 8) Cidade Estilhaçada: o céu passando por baixo da ilha
	Game.pending_spawn = "porta"
	level = await open("res://scenes/world/cidade.tscn") as Level
	await wait(1.8)
	await shot("17_cidade_chegada")
	# O Escudo Remendado brilhando no chão, perto da entrada
	var shield_pickup: ItemPickup = null
	for node in level.entities.get_children():
		if node is ItemPickup and (node as ItemPickup).item_id == "escudo_remendado":
			shield_pickup = node
	level.player.global_position = shield_pickup.global_position + Vector2(-40, 14)
	level.camera.snap_to_target()
	await wait(0.8)
	await shot("17a_escudo_no_chao")
	level.player.global_position = shield_pickup.global_position
	await wait(0.7)
	await shot("17b_escudo_pego")
	level.player.global_position = Vector2(14 * 16, 12 * 16)
	level.camera.snap_to_target()
	await wait(2.5)
	await shot("18_cidade_soldados")
	level.player.global_position = Vector2(8 * 16, 26 * 16)
	level.camera.snap_to_target()
	await wait(0.8)
	await shot("19_cidade_borda")
	# Os outros moradores da Cidade
	level.player._iframes_left = 9999.0
	level.player.global_position = Vector2(31 * 16 + 8, 12 * 16)
	level.camera.snap_to_target()
	await wait(1.0)
	await shot("19a_atirador_mira")
	level.player.global_position = Vector2(20 * 16, 12 * 16)
	level.camera.snap_to_target()
	await wait(1.5)
	await shot("19b_cao_de_guerra")
	level.player.global_position = Vector2(11 * 16, 23 * 16)
	level.camera.snap_to_target()
	await wait(1.2)
	await shot("19c_civis_cinzentos")
	# Mini-chefes
	var sarge: SargentoSemPelotao = null
	var armor: CouracaAndante = null
	for node in level.get_tree().get_nodes_in_group("minibosses"):
		if node is SargentoSemPelotao:
			sarge = node
		elif node is CouracaAndante:
			armor = node
	level.player.global_position = sarge.global_position + Vector2(-60, 0)
	level.camera.snap_to_target()
	await wait(0.6)
	sarge.stats.take_damage(sarge.stats.max_health * 0.3)
	await wait(0.6)
	await shot("19d_sargento_apito")
	await wait(1.0)
	await shot("19e_sargento_pelotao")
	sarge.stats.take_damage(99999.0)
	await wait(5.6)  # o banner "INIMIGO VENCIDO" some antes da próxima foto
	level.player.global_position = armor.global_position + Vector2(-50, 10)
	level.camera.snap_to_target()
	await wait(1.0)
	armor._cooldown = 99.0
	level.player.global_position = armor.global_position + Vector2(24, 0)
	armor.facing = Vector2.LEFT
	armor._attack(armor.giro)
	await wait(0.5)
	await shot("19f_couraca_giro")
	# O escudo segurando o golpe de um soldado
	var soldier: SoldadoRemendado = null
	var best := INF
	for node in level.get_tree().get_nodes_in_group("enemies"):
		if node is SoldadoRemendado:
			var d: float = (node as Node2D).global_position.distance_to(Vector2(9 * 16, 13 * 16))
			if d < best:
				best = d
				soldier = node
	level.player.global_position = soldier.global_position + Vector2(-28, 0)
	level.player.facing = Vector2.RIGHT
	level.camera.snap_to_target()
	level.player._iframes_left = 0.0
	level.player.stats.revive()
	Input.action_press(&"block")
	var got := [false]
	level.player.blocked.connect(func(_i): got[0] = true, CONNECT_ONE_SHOT)
	var waited := 0.0
	while not got[0] and waited < 8.0:
		await get_tree().process_frame
		waited += get_process_delta_time()
	await wait(0.03)
	await shot("19g_escudo_defesa")
	Input.action_release(&"block")
	level.player._iframes_left = 9999.0

	# 9) Praça do Detentor: Aldir Cornélios
	Game.reset_progress()
	Game.pending_spawn = "porta"
	level = await open("res://scenes/world/arena_aldir.tscn") as Level
	await wait(1.6)
	level.player.global_position = Vector2(18 * 16 + 8, 16 * 16)  # passou da névoa: ela fecha
	level.camera.snap_to_target()
	await wait(1.4)
	await shot("20_aldir_ajoelhado")
	var aldir := level.boss_arena.boss as AldirCornelios
	level.player._iframes_left = 999.0  # o fotógrafo não pode morrer
	level.player.global_position = Vector2(18 * 16 + 8, 12 * 16)  # entra na praça: a luta começa
	await wait(2.0)
	aldir.global_position = Vector2(12 * 16, 4 * 16)
	level.player.global_position = Vector2(12 * 16 + 8, 11 * 16)
	aldir._queue_combo([aldir.sismico])
	await wait(0.75)
	await shot("21_aldir_sismico_aviso")
	await wait(0.45)
	await shot("22_aldir_onda")
	await wait(1.1)
	await shot("23_aldir_buraco")
	aldir.hurtbox.receive_hit(HitInfo.create(330.0, level.player.global_position, aldir.global_position))
	await wait(1.2)
	await shot("24_aldir_fase2")
	await wait(1.6)
	level.player.global_position = aldir.global_position + Vector2(70, 50)
	aldir._start_leap()
	await wait(0.5)
	await shot("25_aldir_salto")
	await wait(2.0)
	aldir.stats.take_damage(99999.0)
	await wait(5.5)
	await shot("26_aldir_memorial")


## Prólogo: o Complexo das Cápsulas (os dois caminhos da escolha sem aviso).
func _tour_prologue() -> void:
	Game.reset_progress()
	Game.pending_spawn = "camara"
	Game.wake_from_capsule = true
	var level := await open("res://scenes/world/prologo.tscn") as Prologo
	await wait(1.25)
	await shot("p01_despertar")
	await wait(1.8)
	await shot("p02_sala_das_capsulas")
	level.player._iframes_left = 9999.0  # o fotógrafo não pode morrer
	# A primeira criança: rindo, sem ódio.
	level.player.global_position = Vector2(19 * 16 + 8, 41 * 16)
	level.camera.snap_to_target()
	await wait(1.7)
	await shot("p03_crianca_rindo")
	level.player.global_position = Vector2(15 * 16 + 8, 26 * 16)
	level.camera.snap_to_target()
	await wait(2.2)
	await shot("p04_dormitorio")
	# Caminho sem violência: ela só observa.
	var gov := level.governess
	level.player.global_position = Vector2(15 * 16 + 8, 21 * 16)
	var marker := frame_point(level, gov.global_position + Vector2(0, 60))
	await wait(0.6)
	await shot("p05_governanta_sentada")
	level.player.global_position = gov.global_position + Vector2(44, 56)
	await wait(0.8)
	await shot("p06_governanta_observa")
	level.camera.target = level.player
	marker.queue_free()
	# Caminho da violência: acerta uma criança... e ela já sabe.
	level.player.global_position = Vector2(15 * 16 + 8, 26 * 16)
	level.camera.snap_to_target()
	await wait(0.3)
	var kid: Crianca = null
	for node in level.get_tree().get_nodes_in_group("respawnable"):
		var child := node as Crianca
		if child and (kid == null or child.global_position.distance_to(level.player.global_position) < kid.global_position.distance_to(level.player.global_position)):
			kid = child
	kid.global_position = level.player.global_position + Vector2(18, 0)
	level.player.facing = Vector2.RIGHT
	await tap(&"attack")
	await wait(0.12)
	await shot("p07_golpe_na_crianca")
	var hit := HitInfo.create(999.0, level.player.global_position, kid.global_position)
	hit.source = level.player
	kid.hurtbox.receive_hit(hit)
	level.player.global_position += Vector2(-34, 6)
	await wait(0.9)
	await shot("p08_crianca_caida")
	level.player.global_position = gov.global_position + Vector2(40, 96)
	level.camera.snap_to_target()
	await wait(0.95)
	await shot("p09_ela_se_levanta")
	await wait(2.4)
	level.player.global_position = gov.global_position + Vector2(-46, 20)
	gov._go_decide(99.0)
	await wait(0.3)
	gov._start_scream()
	await wait(0.95)
	await shot("p10_grito")
	await wait(1.4)
	level.player.global_position = gov.global_position + Vector2(-80, 30)
	gov._queue_combo([gov.abraco])
	await wait(0.45)
	await shot("p11_abraco_aviso")
	await wait(1.8)
	gov.stats.take_damage(gov.stats.max_health * 0.55)
	gov._on_damaged(0.0, HitInfo.new(), false)
	await wait(1.9)
	gov._go_decide(99.0)
	gov._start_call()
	await wait(0.45)
	await shot("p12_fase2_ecos")
	await wait(1.6)
	gov.stats.take_damage(99999.0)
	await wait(4.0)
	await shot("p13_lembranca")
	await wait(6.5)
	await shot("p14_mesa_vazia")
	for i in 12:
		skip_narration(level)
		await wait(0.3)
	await wait(1.6)
	# A queda.
	level.player.global_position = level.exit_door.global_position + Vector2(0, 14)
	await wait(0.6)
	level.player.global_position = level.exit_door.global_position + Vector2(0, -34)
	await wait(0.45)
	await shot("p15_o_chao_some")
	await wait(2.4)
	await shot("p16_queda_texto")
	# No Teatro: a Criança Poupada (para quem não feriu ninguém).
	Game.reset_progress()
	Game.spared_child = true
	Game.prologue_done = true
	Game.pending_spawn = "camara"
	var teatro := await open("res://scenes/world/teatro.tscn") as Level
	await wait(1.0)
	var spared := find_npc(teatro, Level.SPARED_CHILD_TALKS)
	teatro.player.global_position = spared.global_position + Vector2(-16, 8)
	teatro.camera.snap_to_target()
	await wait(0.6)
	await shot("p17_crianca_poupada")
	teatro._on_npc_talked(spared)
	await wait(1.6)
	await shot("p18_crianca_dica")
	teatro.hud.dialogue._tap()
	await wait(0.1)
	teatro.hud.dialogue._tap()
	await wait(0.2)
	Game.reset_progress()



func _forest_find(level: Level, script_name: String, near: Vector2 = Vector2.ZERO) -> Node2D:
	var best: Node2D = null
	var best_d := INF
	for node in level.entities.get_children():
		if node.get_script() and node.get_script().get_global_name() == script_name:
			var d: float = (node as Node2D).global_position.distance_to(near)
			if d < best_d:
				best_d = d
				best = node
	return best


## O Bosque do Sono Eterno.
func _tour_forest() -> void:
	Game.reset_progress()
	Game.defeated_bosses.append("aldir")
	Game.pending_spawn = "porta"
	var level := await open("res://scenes/world/bosque.tscn") as Level
	await wait(2.2)
	await shot("b01_bosque_chegada")
	level.player._iframes_left = 9999.0
	# Sonâmbulos dormindo em pé; um dash por perto e o anel de barulho aparece.
	level.player.global_position = Vector2(9 * 16, 16 * 16)
	level.camera.snap_to_target()
	await wait(1.4)
	await shot("b02_sonambulos_dormindo")
	await tap(&"dash")
	await wait(0.12)
	await shot("b03_barulho_acorda")
	# Campo de flores: a nuvem de pólen e a barra de sono.
	level.player.global_position = Vector2(19 * 16, 13 * 16)
	level.camera.snap_to_target()
	await wait(1.4)
	level.player.add_drowsiness(55.0)
	await wait(0.4)
	await shot("b04_polen_sonolencia")
	level.player.add_drowsiness(200.0)
	await wait(0.8)
	await shot("b05_dormindo")
	await wait(2.5)
	# O lago parado, a ponte e a cachoeira que cai da borda.
	level.player.global_position = Vector2(31 * 16, 17 * 16 + 8)
	level.camera.snap_to_target()
	await wait(1.0)
	await shot("b06_lago_ponte")
	var marker := frame_point(level, Vector2(31 * 16, 27 * 16))
	await wait(1.0)
	await shot("b07_cachoeira_borda")
	marker.queue_free()
	level.camera.target = level.player
	# Clareira dos cervos: a mira que trava.
	level.player.global_position = Vector2(45 * 16, 17 * 16)
	level.camera.snap_to_target()
	var deer := _forest_find(level, "CervoDeMusgo", Vector2(44 * 16, 13 * 16)) as CervoDeMusgo
	await wait(1.1)
	await shot("b08_cervo_mira")
	# A Fada Murcha curando um ferido.
	var fairy := _forest_find(level, "FadaMurcha", Vector2(20 * 16, 15 * 16)) as FadaMurcha
	var sleeper := _forest_find(level, "Sonambulo", Vector2(22 * 16, 16 * 16)) as Sonambulo
	sleeper.stats.take_damage(30.0)
	fairy.global_position = sleeper.global_position + Vector2(20, -10)
	level.player.global_position = sleeper.global_position + Vector2(-90, 30)
	level.camera.snap_to_target()
	await wait(1.6)
	await shot("b09_fada_cura")
	# O Vigia dormindo na passagem.
	var vigia := _forest_find(level, "VigiaQueDormiu", Vector2(54 * 16, 16 * 16)) as VigiaQueDormiu
	level.player.global_position = Vector2(50 * 16, 14 * 16 + 8)
	level.camera.snap_to_target()
	await wait(1.2)
	await shot("b10_vigia_dormindo")
	await tap(&"dash")
	await wait(1.5)
	vigia._start_yawn()
	await wait(vigia.yawn_inhale + 0.25)
	await shot("b11_vigia_bocejo")
	# A Mãe dos Esporos.
	vigia.reset_fight()
	var mae := _forest_find(level, "MaeDosEsporos", Vector2(64 * 16, 12 * 16)) as MaeDosEsporos
	level.player.global_position = mae.global_position + Vector2(-70, 50)
	level.camera.snap_to_target()
	await wait(2.0)
	mae._start_vine(false)
	await wait(0.5)
	await shot("b12_mae_cipo_aviso")
	await wait(1.2)
	mae._set_mode(MaeDosEsporos.Mode.BLOOM)
	await wait(1.55)
	await shot("b13_mae_florescer")
	await _tour_nyssa()


## A Clareira de Nyssa.
func _tour_nyssa() -> void:
	Game.reset_progress()
	Game.defeated_bosses.assign(["aldir", "governanta", "helena", "mae_esporos"])
	Game.pending_spawn = "porta"
	var level := await open("res://scenes/world/arena_nyssa.tscn") as Level
	Game.flags = {}  # (o Vigia da foto anterior ainda viu o herói passar no último quadro)
	await wait(1.8)
	await shot("n01_clareira")
	var nyssa := level.boss_arena.boss as NyssaLumevel
	level.player._iframes_left = 9999.0
	level.player.global_position = nyssa.global_position + Vector2(-30, 56)
	level.camera.snap_to_target()
	await wait(3.0)
	await shot("n02_sonho_leve")
	level.player.add_drowsiness(60.0)
	await wait(1.2)
	await shot("n03_sono_subindo")
	nyssa.stats.take_damage(nyssa.stats.max_health * 0.55)
	await wait(1.0)
	await shot("n04_pesadelo_transicao")
	await wait(1.6)
	nyssa._pit_timer = 99.0
	nyssa._echo_timer = 99.0
	nyssa.open_dream_pits()
	await wait(1.4)
	await shot("n05_chao_some")
	nyssa.summon_echo("helena")
	nyssa.summon_echo("aldir")
	await wait(0.7)
	await shot("n06_ecos")
	await wait(2.0)
	nyssa.stats.take_damage(99999.0)
	await wait(9.0)
	await shot("n07_cama_de_flores")



## Raízes da Fome (e a porta oeste do Teatro).
func _tour_roots() -> void:
	Game.reset_progress()
	Game.defeated_bosses.assign(["aldir", "nyssa"])
	Game.pending_spawn = "camara"
	var teatro := await open("res://scenes/world/teatro.tscn") as Level
	await wait(1.0)
	teatro.player.global_position = Vector2(3 * 16, 13 * 16)
	teatro.camera.snap_to_target()
	await wait(0.8)
	await shot("r01_teatro_porta_oeste")
	Game.pending_spawn = "porta"
	var level := await open("res://scenes/world/raizes.tscn") as Level
	await wait(2.2)
	await shot("r02_raizes_chegada")
	level.player._iframes_left = 9999.0
	# A Boca de Raiz enterrada no caminho... e o agarrão.
	var boca := _forest_find(level, "BocaDeRaiz", Vector2(60 * 16, 12 * 16)) as BocaDeRaiz
	level.player.global_position = boca.global_position + Vector2(-44, 4)
	level.camera.snap_to_target()
	await wait(1.0)
	await shot("r03_boca_enterrada")
	level.player._iframes_left = 0.0
	level.player.global_position = boca.global_position + Vector2(3, 0)
	await wait(1.3)
	await shot("r04_boca_agarrou")
	for i in boca.grab_taps:
		await tap(&"attack")
		await wait(0.05)
	level.player._iframes_left = 9999.0
	await wait(0.4)
	await shot("r05_boca_exposta")
	# Colhedor na estufa: o leque da foice.
	var reaper := _forest_find(level, "Colhedor", Vector2(34 * 16, 5 * 16)) as Colhedor
	level.player.global_position = reaper.global_position + Vector2(-30, 8)
	level.camera.snap_to_target()
	reaper._cooldown = 99.0
	await wait(0.8)
	reaper._attack(reaper.sweep)
	await wait(0.45)
	await shot("r06_estufa_colhedor_foice")
	# Larvas de Seiva: o enxame (uma brilhando com o que roubou).
	var larva := _forest_find(level, "LarvaSeiva", Vector2(62 * 16, 17 * 16)) as LarvaSeiva
	larva.stolen = 60
	level.player.global_position = larva.global_position + Vector2(-40, 0)
	level.camera.snap_to_target()
	await wait(0.9)
	await shot("r07_larvas")
	# O Inchado incha antes de estourar.
	var bloated := _forest_find(level, "Inchado", Vector2(17 * 16, 22 * 16)) as Inchado
	level.player.global_position = bloated.global_position + Vector2(-26, -6)
	level.camera.snap_to_target()
	await wait(0.6)
	bloated.stats.take_damage(9999.0)
	await wait(0.5)
	await shot("r08_inchado_vai_estourar")
	# A cozinha: o Banqueteiro serve e come.
	var cook := _forest_find(level, "Banqueteiro", Vector2(32 * 16, 20 * 16)) as Banqueteiro
	level.player.global_position = cook.global_position + Vector2(-70, 20)
	level.camera.snap_to_target()
	await wait(1.4)
	cook._set_mode(Banqueteiro.Mode.SERVE)
	await wait(1.0)
	await shot("r09_banqueteiro_serve")
	cook.stats.set_health(cook.stats.max_health * 0.6)
	cook._eat_timer = 0.0
	cook._set_mode(Banqueteiro.Mode.CHASE)
	for i in 60:
		await wait(0.05)
		if cook.mode == Banqueteiro.Mode.EAT and cook._eat_started:
			break
	await wait(0.4)
	await shot("r10_banqueteiro_come")
	cook.reset_fight()
	# O ninho: a Ninhada vai engolir.
	var brood := _forest_find(level, "Ninhada", Vector2(14 * 16, 5 * 16)) as Ninhada
	level.player.global_position = brood.global_position + Vector2(-40, 40)
	level.camera.snap_to_target()
	await wait(1.2)
	brood._start_engulf()
	await wait(0.6)
	await shot("r11_ninhada_engolir")
	brood.reset_fight()
	# A porta dos fundos (trancada até vencer o Banqueteiro).
	level.player.global_position = Vector2(4 * 16, 20 * 16 + 8)
	level.camera.snap_to_target()
	await wait(1.0)
	await shot("r12_porta_de_mabel")
	await _tour_mabel()


func _tour_mabel() -> void:
	Game.reset_progress()
	Game.defeated_bosses.assign(["aldir", "nyssa", "banqueteiro"])
	Game.pending_spawn = "porta"
	var level := await open("res://scenes/world/arena_mabel.tscn") as Level
	await wait(1.8)
	await shot("m01_salao_chegada")
	var mabel := level.boss_arena.boss as MabelVoragine
	level.player._iframes_left = 9999.0
	level.player.global_position = mabel.global_position + Vector2(30, 70)
	level.camera.snap_to_target()
	await wait(2.0)
	await shot("m02_anfitria")
	mabel._go_decide(99.0)
	level.player.global_position = mabel.global_position + Vector2(36, 16)
	mabel.facing = Vector2.RIGHT
	mabel._queue_combo([mabel.slap])
	await wait(0.6)
	await shot("m03_tapa_aviso")
	await wait(1.6)
	mabel._go_decide(99.0)
	level.player.global_position = mabel.global_position + Vector2(0, 90)
	mabel.throw_fruits()
	await wait(0.55)
	await shot("m04_frutos_de_carne")
	await wait(1.4)
	level.player.global_position = mabel.global_position + Vector2(60, 10)
	mabel._start_reach()
	await wait(0.8)
	await shot("m05_agarrao_linha")
	level.player._iframes_left = 0.0
	await wait(0.4)
	await wait(0.6)
	await shot("m06_engolido")
	for i in mabel.grab_taps:
		await tap(&"attack")
		await wait(0.05)
	level.player._iframes_left = 9999.0
	await wait(0.3)
	await shot("m07_engasgo")
	mabel.stats.take_damage(mabel.stats.max_health * 0.55)
	await wait(1.0)
	await shot("m08_voragine_raizes")
	await wait(1.6)
	mabel._go_decide(99.0)
	mabel._lackey_timer = 0.0
	await wait(0.2)
	mabel._lackey_timer = 0.0
	await wait(0.2)
	level.player.global_position = mabel.global_position + Vector2(-50, 60)
	await wait(0.6)
	mabel._eat_timer = 0.0
	if not mabel.lackeys.is_empty():
		var meal: Enemy = mabel.lackeys[0]
		meal.global_position = mabel.global_position + Vector2(20, 10)
		mabel._go_decide(0.0)
	await wait(0.9)
	await shot("m09_come_lacaio")
	await wait(1.2)
	mabel.stats.take_damage(99999.0)
	await wait(6.0)
	await shot("m10_mesa_posta")



## Forjas Ocas e a Forja do Eco.
func _tour_forge() -> void:
	Game.reset_progress()
	Game.defeated_bosses.assign(["aldir", "nyssa", "mabel"])
	Game.add_item("escudo_remendado")
	Game.set_shield_equipped(true)
	Game.pending_spawn = "porta"
	var level := await open("res://scenes/world/forjas.tscn") as Level
	await wait(2.2)
	await shot("f01_forjas_chegada")
	level.player._iframes_left = 9999.0
	# A galeria: estátuas com o rosto do Ferreiro, um Autômato e o Imitador.
	level.player.global_position = Vector2(12 * 16, 11 * 16)
	level.camera.snap_to_target()
	await wait(1.6)
	await shot("f02_galeria_estatuas")
	var mimic := _forest_find(level, "Imitador", Vector2(7 * 16, 9 * 16)) as Imitador
	level.player.global_position = mimic.global_position + Vector2(36, 6)
	level.camera.snap_to_target()
	await wait(1.0)
	level.player.facing = Vector2.LEFT
	await tap(&"attack")
	await wait(0.5)
	await shot("f03_imitador_copia")
	# A oficina e o Protótipo.
	var proto := _forest_find(level, "Prototipo", Vector2(35 * 16, 7 * 16)) as Prototipo
	level.player.global_position = proto.global_position + Vector2(-60, 30)
	level.camera.snap_to_target()
	await wait(1.6)
	await shot("f04_prototipo")
	proto.reset_fight()
	# A fábrica: torreta acendendo as placas.
	var turret := _forest_find(level, "TorretaFaisca", Vector2(49 * 16, 18 * 16)) as TorretaFaisca
	level.player.global_position = turret.global_position + Vector2(50, 20)
	level.camera.snap_to_target()
	await wait(1.4)
	turret._aim = (level.player.global_position - turret.global_position).normalized()
	turret.fire()
	await wait(0.5)
	await shot("f05_torreta_placas")
	# A mina: o Minerador ergue a picareta.
	var miner := _forest_find(level, "MineradorOco", Vector2(27 * 16, 24 * 16)) as MineradorOco
	level.player.global_position = miner.global_position + Vector2(20, 4)
	level.camera.snap_to_target()
	for i in 30:
		await wait(0.05)
		if miner._combo_index == 3 and miner._runner.phase == AttackRunner.Phase.WINDUP:
			break
	await shot("f06_minerador")
	# A câmara da Âncora: o Guardião.
	var guard := _forest_find(level, "GuardiaoAncora", Vector2(64 * 16, 8 * 16)) as GuardiaoAncora
	level.player.global_position = guard.global_position + Vector2(-50, 40)
	level.camera.snap_to_target()
	await wait(1.6)
	guard._aim = (level.player.global_position - guard.global_position).normalized()
	guard._set_mode(GuardiaoAncora.Mode.SWEEP)
	await wait(0.7)
	await shot("f07_guardiao_corrente")
	await wait(1.0)
	guard._set_mode(GuardiaoAncora.Mode.SLAM)
	await wait(guard.windup + 0.2)
	await shot("f08_guardiao_pilao_placas")
	await wait(0.8)
	guard._set_mode(GuardiaoAncora.Mode.VENT)
	await wait(0.6)
	await shot("f09_guardiao_nucleo")
	await _tour_durgan()


func _tour_durgan() -> void:
	Game.reset_progress()
	Game.defeated_bosses.assign(["aldir", "nyssa", "mabel", "guardiao_ancora"])
	Game.pending_spawn = "porta"
	var level := await open("res://scenes/world/arena_durgan.tscn") as Level
	await wait(1.8)
	await shot("d01_forja_do_eco")
	var durgan := level.boss_arena.boss as DurganVell
	level.player._iframes_left = 9999.0
	level.player.global_position = durgan.global_position + Vector2(10, 80)
	level.camera.snap_to_target()
	await wait(2.0)
	await shot("d02_engenheiro")
	durgan._go_decide(99.0)
	durgan.build_turret()
	durgan.call_automaton()
	durgan.charge_field()
	await wait(0.7)
	await shot("d03_torretas_placas")
	await wait(1.0)
	level.player.global_position = durgan.global_position + Vector2(10, 40)
	durgan._queue_combo([durgan.slam])
	await wait(durgan.slam.windup_time + 0.2)
	await shot("d04_martelada_eletrica")
	await wait(1.5)
	durgan.stats.take_damage(durgan.stats.max_health * 0.55)
	await wait(1.0)
	await shot("d05_reflexo")
	await wait(1.6)
	durgan._go_decide(99.0)
	durgan._copy(&"escudo", 30.0)
	await wait(0.4)
	await shot("d06_reflexo_escudo")
	await wait(1.4)
	durgan.stats.take_damage(99999.0)
	await wait(6.0)
	await shot("d07_chave_martelo")


func _tour_mountain() -> void:
	Game.reset_progress()
	Game.defeated_bosses.assign(["aldir", "nyssa", "mabel", "durgan"])
	Game.add_item("escudo_remendado")
	Game.set_shield_equipped(true)
	Game.pending_spawn = "lateral"
	await open("res://scenes/world/cidade.tscn")
	await wait(1.6)
	await shot("m00_cidade_ponte_baixada")
	Game.pending_spawn = "porta"
	var level := await open("res://scenes/world/montanha.tscn") as Level
	await wait(2.2)
	await shot("m01_montanha_chegada")
	level.player._iframes_left = 9999.0
	# O sopé: Atiradores guardando distância e uma Brasa Viva.
	var shooter := _forest_find(level, "DragonoideAtirador", Vector2(27 * 16, 23 * 16)) as DragonoideAtirador
	level.player.global_position = shooter.global_position + Vector2(70, 10)
	level.camera.snap_to_target()
	for i in 40:
		await wait(0.05)
		if shooter.ai == DragonoideAtirador.AI.FIRE:
			break
	await wait(0.15)
	await shot("m02_atirador_bolas_de_fogo")
	var ember := _forest_find(level, "BrasaViva", Vector2(35 * 16, 25 * 16)) as BrasaViva
	if ember:
		level.player.global_position = ember.global_position + Vector2(30, 0)
		level.camera.snap_to_target()
		for i in 40:
			await wait(0.05)
			if not is_instance_valid(ember) or ember.ai == BrasaViva.AI.IGNITE:
				break
		await wait(0.2)
		await shot("m03_brasa_viva")
	# O ossário: Dragão Bestial mirando a investida.
	var beast := _forest_find(level, "DragaoBestial", Vector2(10 * 16, 19 * 16)) as DragaoBestial
	level.player.global_position = beast.global_position + Vector2(90, 10)
	level.camera.snap_to_target()
	for i in 40:
		await wait(0.05)
		if beast.ai == DragaoBestial.AI.AIM:
			break
	await wait(0.4)
	await shot("m04_ossario_bestial")
	# A encosta: o Dragão Alado mergulha.
	var wyvern := _forest_find(level, "DragaoAlado", Vector2(53 * 16, 23 * 16)) as DragaoAlado
	level.player.global_position = wyvern.global_position + Vector2(20, 20)
	level.camera.snap_to_target()
	await wait(1.2)
	if wyvern.ai == DragaoAlado.AI.CIRCLE:
		wyvern._ai_time = 99.0
	await wait(0.5)
	await shot("m05_alado_mergulho")
	await wait(1.2)
	await shot("m06_alado_no_chao")
	# O acampamento: o Capitão de escudo, depois o lança-chamas.
	var captain := _forest_find(level, "CapitaoDragonoide", Vector2(35 * 16, 8 * 16)) as CapitaoDragonoide
	level.player.global_position = captain.global_position + Vector2(-60, 30)
	level.camera.snap_to_target()
	await wait(1.6)
	await shot("m07_capitao_escudo")
	captain._set_mode(CapitaoDragonoide.Mode.SWAP)
	captain._next = CapitaoDragonoide.Mode.FLAME
	await wait(captain.swap_time + 1.2)
	await shot("m08_capitao_lanca_chamas")
	captain.reset_fight()
	# A caldeira: a Matriarca pisoteia e o chão cede.
	var mother := _forest_find(level, "MatriarcaBestial", Vector2(65 * 16, 9 * 16)) as MatriarcaBestial
	level.player.global_position = mother.global_position + Vector2(-70, 30)
	level.camera.snap_to_target()
	await wait(1.6)
	mother._set_mode(MatriarcaBestial.Mode.STOMP)
	await wait(mother.stomp_windup * 0.7)
	await shot("m09_matriarca_ergue")
	await wait(0.9)
	await shot("m10_matriarca_buracos")
	await _tour_rachel()


func _tour_rachel() -> void:
	Game.reset_progress()
	Game.defeated_bosses.assign(["aldir", "nyssa", "mabel", "durgan", "matriarca"])
	Game.pending_spawn = "porta"
	var level := await open("res://scenes/world/arena_rachel.tscn") as Level
	await wait(1.8)
	await shot("r01_o_ninho")
	var rachel := level.boss_arena.boss as RachelCaelis
	level.player._iframes_left = 9999.0
	level.player.global_position = rachel.global_position + Vector2(-20, 110)
	level.camera.snap_to_target()
	await wait(2.4)
	await shot("r02_rachel_acorda")
	rachel._go_decide(99.0)
	rachel.start_breath()
	await wait(rachel.breath_windup * 0.6)
	await shot("r03_halito_aviso")
	await wait(rachel.breath_windup * 0.4 + rachel.breath_time * 0.5)
	await shot("r04_halito_de_fogo")
	await wait(rachel.breath_time * 0.6 + 0.3)
	rachel._go_decide(99.0)
	rachel._set_mode(RachelCaelis.Mode.ROAR)
	await wait(rachel.roar_windup + 0.25)
	await shot("r05_rugido_pedras")
	await wait(1.0)
	rachel.stats.set_health(rachel.stats.max_health * 0.45)
	await wait(1.6)
	await shot("r06_arena_desaba")
	rachel.facing = Vector2.UP
	level.player.global_position = rachel.global_position + Vector2(10, 34)
	rachel._go_decide(0.0)
	await wait(rachel.tail_windup * 0.8)
	await shot("r07_cauda")
	await wait(1.0)
	rachel.stats.take_damage(99999.0)
	await wait(6.0)
	await shot("r08_escama_do_orgulho")


func _tour_ice() -> void:
	Game.reset_progress()
	Game.defeated_bosses.assign(["aldir", "nyssa", "mabel", "durgan", "rachel"])
	Game.pending_spawn = "porta"
	var level := await open("res://scenes/world/dominio.tscn") as Level
	await wait(2.2)
	await shot("g01_dominio_chegada")
	level.player._iframes_left = 9999.0
	# O lago: gelo, buracos e um Bibliotecário mirando.
	var librarian := _forest_find(level, "BibliotecarioGelo", Vector2(24 * 16, 17 * 16)) as BibliotecarioGelo
	level.player.global_position = librarian.global_position + Vector2(80, 50)
	level.camera.snap_to_target()
	for i in 40:
		await wait(0.05)
		if librarian.ai == BibliotecarioGelo.AI.CAST:
			break
	await wait(0.2)
	await shot("g02_lago_bibliotecario")
	# Ácaros grudados.
	var mite := _forest_find(level, "AcaroCristal", Vector2(47 * 16, 21 * 16)) as AcaroCristal
	level.player.global_position = mite.global_position + Vector2(30, 0)
	level.player._iframes_left = 0.0
	level.camera.snap_to_target()
	await wait(1.4)
	level.player._iframes_left = 9999.0
	await shot("g03_acaros_grudados")
	# A galeria: Estátuas Vivas (de costas para elas, andam).
	var statue := _forest_find(level, "EstatuaViva", Vector2(30 * 16, 10 * 16)) as EstatuaViva
	level.player.global_position = statue.global_position + Vector2(40, 0)
	level.player.facing = Vector2.RIGHT
	level.camera.snap_to_target()
	await wait(0.8)
	await shot("g04_estatua_de_costas")
	# A Curadora: vitrine em volta do herói, depois o bloco.
	var curator := _forest_find(level, "CuradoraVitrines", Vector2(33 * 16, 7 * 16)) as CuradoraVitrines
	level.player.global_position = curator.global_position + Vector2(-50, 30)
	level.camera.snap_to_target()
	await wait(1.4)
	curator._go_decide(99.0)
	curator.open_case()
	await wait(0.6)
	await shot("g05_curadora_vitrine")
	level.player._iframes_left = 0.0
	await wait(0.6)
	await shot("g06_preso_no_gelo")
	level.player.release_grab(false)
	level.player._iframes_left = 9999.0
	curator.reset_fight()
	# O Aprendiz com a bolha.
	var apprentice := _forest_find(level, "AprendizArcano", Vector2(70 * 16, 19 * 16)) as AprendizArcano
	level.player.global_position = apprentice.global_position + Vector2(-40, 10)
	level.camera.snap_to_target()
	await wait(1.4)
	await shot("g07_aprendiz_bolha")
	# O Golem do Arquivo.
	var golem := _forest_find(level, "GolemArquivo", Vector2(66 * 16, 7 * 16)) as GolemArquivo
	level.player.global_position = golem.global_position + Vector2(-60, 30)
	level.camera.snap_to_target()
	await wait(1.6)
	golem._go_decide(99.0)
	golem._set_mode(GolemArquivo.Mode.SLAM)
	await wait(golem.slam_windup * 0.7)
	await shot("g08_golem_pilao")
	await wait(0.8)
	golem._aim = (level.player.global_position - golem.global_position).normalized()
	golem.throw_books()
	await wait(0.25)
	await shot("g09_golem_livros")
	golem.stats.take_damage(99999.0)
	await wait(3.0)
	await shot("g10_livro_do_arquivo")
	await _tour_cassian()


func _tour_cassian() -> void:
	Game.reset_progress()
	Game.defeated_bosses.assign(["aldir", "nyssa", "mabel", "durgan", "rachel", "golem_arquivo"])
	Game.pending_spawn = "porta"
	var level := await open("res://scenes/world/arena_cassian.tscn") as Level
	await wait(1.8)
	await shot("c01_sala_do_arconte")
	var cassian := level.boss_arena.boss as CassianVirel
	level.player._iframes_left = 9999.0
	level.player.global_position = cassian.global_position + Vector2(-20, 100)
	level.camera.snap_to_target()
	await wait(2.2)
	await shot("c02_arquimago")
	cassian._go_decide(99.0)
	cassian._aim = (level.player.global_position - cassian.global_position).normalized()
	cassian._set_mode(CassianVirel.Mode.LANCES)
	await wait(cassian.lance_aim + 0.15)
	await shot("c03_lancas_de_gelo")
	await wait(0.6)
	cassian._go_decide(99.0)
	cassian.frost()
	cassian.raise_walls()
	await wait(0.6)
	await shot("c04_geada_e_pilares")
	await wait(1.5)
	cassian.stats.take_damage(99999.0)
	await wait(2.6)
	await shot("c05_colecionador")
	cassian._go_decide(99.0)
	cassian.freeze_half()
	cassian.summon()
	await wait(cassian.freeze_warning * 0.7)
	await shot("c06_metade_congela")
	await wait(1.4)
	cassian._go_decide(99.0)
	level.player.release_grab(false)
	cassian.start_steal()
	await wait(cassian.steal_aim + 0.08)
	await shot("c07_roubo_de_estamina")
	await wait(1.0)
	cassian.stats.take_damage(99999.0)
	await wait(6.0)
	await shot("c08_cajado_do_arconte")

