extends Node
## Passeio automático que tira screenshots do jogo (verificação visual).
## Precisa de tela (no Linux sem monitor: xvfb-run):
##   godot --path . --rendering-driver opengl3 res://tests/screenshot_tour.tscn -- --out=/caminho

var out_dir := "user://screenshots"
## "--only=bosque" tira só as fotos do Bosque (rápido enquanto se mexe nele).
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
	if only != "bosque":
		await _tour()
	await _tour_forest()
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
