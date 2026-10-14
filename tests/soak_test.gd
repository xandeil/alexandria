extends Node
## "Teste de resistência": um robô joga sozinho por alguns minutos de jogo
## (o Prólogo inteiro, soldados em grupo, Helena e Aldir) para pegar erros que
## só aparecem com o tempo. Rode e procure por "ERROR" na saída:
##   godot --headless --fixed-fps 60 --path . res://tests/soak_test.tscn

var _level: Level
var _time := 0.0


func _ready() -> void:
	Game.persistence_enabled = false
	Game.scene_changes_enabled = false  # a queda do Prólogo não pode trocar a cena do teste
	Sfx.muted = true
	# Durações opcionais (segundos de jogo; 0 pula):  ... soak_test.tscn -- 90 150 150 120 90 90 90
	# (Cidade, Helena, Aldir, Prólogo, Bosque, Raízes, Forjas)
	var args := OS.get_cmdline_user_args()
	var city_time := float(args[0]) if args.size() > 0 else 90.0
	var helena_time := float(args[1]) if args.size() > 1 else 150.0
	var aldir_time := float(args[2]) if args.size() > 2 else 150.0
	var prologue_time := float(args[3]) if args.size() > 3 else 120.0
	var forest_time := float(args[4]) if args.size() > 4 else 90.0
	var roots_time := float(args[5]) if args.size() > 5 else 90.0
	var forge_time := float(args[6]) if args.size() > 6 else 90.0
	if prologue_time > 0.0:
		await _soak_prologue(prologue_time)
	if city_time > 0.0:
		await _soak_city(city_time)
	if helena_time > 0.0:
		await _soak_helena(helena_time)
	if aldir_time > 0.0:
		await _soak_aldir(aldir_time)
	if forest_time > 0.0:
		await _soak_forest(forest_time)
	if roots_time > 0.0:
		await _soak_roots(roots_time)
	if forge_time > 0.0:
		await _soak_forge(forge_time)
	print("SOAK OK")
	get_tree().quit()


func _open(path: String, spawn: String) -> void:
	if is_instance_valid(_level):
		_level.queue_free()
		await get_tree().process_frame
	Game.pending_spawn = spawn
	_level = (load(path) as PackedScene).instantiate()
	add_child(_level)
	await get_tree().physics_frame


func _bot_step(player: Player, t: float, target: Node2D) -> void:
	if player.is_grabbed():
		# Preso: toca o Ataque rápido (aperta/solta a cada 3 quadros).
		for action in ["move_left", "move_right", "move_up", "move_down", "dash", "block"]:
			Input.action_release(action)
		if int(t * 60.0) % 6 < 3:
			Input.action_press("attack")
		else:
			Input.action_release("attack")
		return
	# Invencível (o objetivo é exercitar a IA dos inimigos)... exceto quando
	# está de escudo erguido: aí os golpes CHEGAM, para exercitar a defesa.
	var blocking := Game.shield_ready() and fmod(t, 5.0) > 2.5 and fmod(t, 5.0) < 3.4
	player._iframes_left = 0.0 if blocking else 1.0
	if blocking:
		Input.action_press("block")
	else:
		Input.action_release("block")
	if player.stats.health < 30.0:
		player.stats.revive()
	var dir := Vector2.from_angle(t * 0.9)
	if is_instance_valid(target):
		dir = (target.global_position - player.global_position).normalized()
		if player.global_position.distance_to(target.global_position) < 26.0:
			dir = dir.orthogonal()
	for action in ["move_left", "move_right", "move_up", "move_down"]:
		Input.action_release(action)
	if dir.x > 0.3:
		Input.action_press("move_right", dir.x)
	elif dir.x < -0.3:
		Input.action_press("move_left", -dir.x)
	if dir.y > 0.3:
		Input.action_press("move_down", dir.y)
	elif dir.y < -0.3:
		Input.action_press("move_up", -dir.y)
	var phase := fmod(t, 1.7)
	if phase < 0.04:
		Input.action_press("attack")
	elif phase < 0.1:
		Input.action_release("attack")
	if fmod(t, 4.3) < 0.03:
		Input.action_press("dash")
	else:
		Input.action_release("dash")
	if fmod(t, 7.0) < 0.4:
		Input.action_press("attack")  # golpe forte de vez em quando
	elif fmod(t, 7.0) < 0.45:
		Input.action_release("attack")


func _soak_city(duration: float) -> void:
	await _open("res://scenes/world/cidade.tscn", "porta")
	# Primeiro, o Escudo Remendado perto da entrada (para exercitar a defesa).
	for node in _level.entities.get_children():
		if node is ItemPickup and (node as ItemPickup).item_id == "escudo_remendado":
			_level.player.global_position = (node as ItemPickup).global_position
	for i in 4:
		await get_tree().physics_frame
	var blocks := [0, 0]  # [segurados, guardas quebradas]
	_level.player.blocked.connect(func(_i): blocks[0] += 1)
	_level.player.guard_broken.connect(func(): blocks[1] += 1)
	var t := 0.0
	var defeated := [0]  # array: lambdas capturam int por VALOR, array por referência
	for node in get_tree().get_nodes_in_group("respawnable"):
		(node as Enemy).defeated.connect(func(_e): defeated[0] += 1)
	while t < duration:
		await get_tree().physics_frame
		t += 1.0 / 60.0
		var nearest: Node2D = null
		var best := INF
		for node in get_tree().get_nodes_in_group("enemies"):
			var d: float = (node as Node2D).global_position.distance_to(_level.player.global_position)
			if d < best:
				best = d
				nearest = node
		_bot_step(_level.player, t, nearest)
	print("Cidade: %d inimigos derrotados em %.0f s; memórias=%d; escudo=%s, golpes segurados=%d, guardas quebradas=%d; sucata=%d" % [
		defeated[0], duration, Game.memories, Game.shield_ready(), blocks[0], blocks[1], Game.item_count("sucata_temperada")])
	# Os mini-chefes, um de cada vez, até o fim.
	for node in get_tree().get_nodes_in_group("minibosses"):
		var mini := node as MiniBoss
		if mini == null or mini.dead:
			continue
		var won := [false]
		mini.fight_won.connect(func(_b): won[0] = true)
		_level.player.global_position = mini.home_position + Vector2(-60, 10)
		var tt := 0.0
		while tt < 120.0 and not won[0]:
			await get_tree().physics_frame
			tt += 1.0 / 60.0
			t += 1.0 / 60.0
			if is_instance_valid(mini) and not mini.dead:
				_bot_step(_level.player, t, mini)
				if fmod(tt, 3.0) < 1.0 / 60.0 and mini.active:
					mini.stats.take_damage(35.0)
		var extra := ""
		if mini is SargentoSemPelotao:
			extra = " (reforços chamados: %d)" % (mini as SargentoSemPelotao)._whistles_done
		print("Mini-chefe %s: vitória=%s em %.0f s%s" % [mini.display_name() if is_instance_valid(mini) else "?", won[0], tt, extra])
	Input.action_release("block")
	await _soak_systems()


## Teatro: gasta o que a Cidade deu — forja, Orbe, Vendedor, inventário.
func _soak_systems() -> void:
	await _open("res://scenes/world/teatro.tscn", "camara")
	Game.memories += 5000
	for i in 6:
		await _level._on_dialogue_action("comprar_sucata")
	var upgrades := 0
	while Game.try_upgrade_weapon():
		upgrades += 1
	var purified := 0
	while Game.can_purify_fragment():
		await _level._on_dialogue_action("purificar")
		purified += 1
	_level.hud.open_inventory()
	for i in 10:
		await get_tree().process_frame
	_level.hud.inventory_menu.close()
	for i in 3:
		await get_tree().process_frame
	print("Sistemas: arma +%d (%d melhorias), %d fragmentos purificados, frascos=%d, inventário=%s" % [
		Game.weapon_level, upgrades, purified, Game.health_flasks_max, Game.inventory])


func _soak_helena(duration: float) -> void:
	Game.reset_progress()
	await _open("res://scenes/world/teatro.tscn", "camara")
	_level.boss_arena.arm()
	var helena := _level.boss_arena.boss as HelenaAltiva
	var t := 0.0
	var won := [false]
	helena.fight_won.connect(func(_b): won[0] = true)
	var phases_seen := {}
	while t < duration and not won[0]:
		await get_tree().physics_frame
		t += 1.0 / 60.0
		phases_seen[helena.phase] = true
		if is_instance_valid(helena) and not helena.dead:
			_bot_step(_level.player, t, helena)
			# empurra a luta: dano extra periódico para atravessar as 3 fases
			if fmod(t, 5.0) < 1.0 / 60.0 and helena.active and not helena.hurtbox.invulnerable:
				helena.stats.take_damage(45.0)
				helena._on_damaged(45.0, HitInfo.new(), false)
	print("Helena: fases vistas %s, vitória=%s em %.0f s, armadura=%.2f" % [phases_seen.keys(), won[0], t, helena.armor if is_instance_valid(helena) else -1.0])


## Aldir: buracos, coberturas, ondas e as duas fases, com o robô caindo nos buracos de vez em quando.
func _soak_aldir(duration: float) -> void:
	Game.reset_progress()
	await _open("res://scenes/world/arena_aldir.tscn", "porta")
	var aldir := _level.boss_arena.boss as AldirCornelios
	var t := 0.0
	var won := [false]
	aldir.fight_won.connect(func(_b): won[0] = true)
	var phases_seen := {}
	var falls := 0
	var was_falling := false
	while t < duration and not won[0]:
		await get_tree().physics_frame
		t += 1.0 / 60.0
		var player := _level.player
		var falling := player.state == Player.State.FALL
		if falling and not was_falling:
			falls += 1
		was_falling = falling
		if is_instance_valid(aldir) and not aldir.dead:
			phases_seen[aldir.phase] = true
			_bot_step(player, t, aldir)
			if fmod(t, 5.0) < 1.0 / 60.0 and aldir.active and not aldir.hurtbox.invulnerable:
				aldir.stats.take_damage(45.0)
				aldir._on_damaged(45.0, HitInfo.new(), false)
	var covers := get_tree().get_nodes_in_group("covers").size()
	var pits := 0
	for node in get_tree().get_nodes_in_group("pits"):
		if (node as ArenaPit).is_open():
			pits += 1
	print("Aldir: fases vistas %s, vitória=%s em %.0f s, quedas do robô=%d, coberturas de pé=%d, buracos abertos=%d" % [phases_seen.keys(), won[0], t, falls, covers, pits])


## Prólogo: o robô bate nas crianças (o caminho violento), enfrenta a
## Governanta inteira, vê a lembrança e cai pelo chão que some.
func _soak_prologue(duration: float) -> void:
	Game.reset_progress()
	await _open("res://scenes/world/prologo.tscn", "camara")
	var level := _level as Prologo
	var t := 0.0
	var falls := [0]
	for node in get_tree().get_nodes_in_group("respawnable"):
		var child := node as Crianca
		if child:
			child.stats.died.connect(func(): falls[0] += 1)
	# 1) O dormitório: o robô persegue e bate nas crianças.
	level.player.global_position = Vector2(15 * 16 + 8, 27 * 16)
	while t < duration * 0.4:
		await get_tree().physics_frame
		t += 1.0 / 60.0
		var nearest: Node2D = null
		var best := INF
		for node in get_tree().get_nodes_in_group("enemies"):
			var d: float = (node as Node2D).global_position.distance_to(level.player.global_position)
			if d < best:
				best = d
				nearest = node
		_bot_step(level.player, t, nearest)
	var hurt := Game.criancas_feridas
	# 2) A Governanta (ela já sabe).
	var gov := level.governess
	level.player.global_position = gov.global_position + Vector2(40, 100)
	var phases_seen := {}
	var won := [false]
	gov.fight_won.connect(func(_b): won[0] = true)
	while t < duration and not won[0]:
		await get_tree().physics_frame
		t += 1.0 / 60.0
		if is_instance_valid(gov) and not gov.dead:
			phases_seen[gov.phase] = true
			_bot_step(level.player, t, gov)
			if fmod(t, 4.0) < 1.0 / 60.0 and gov.active and not gov.hurtbox.invulnerable:
				gov.stats.take_damage(40.0)
				gov._on_damaged(40.0, HitInfo.new(), false)
	for action in ["move_left", "move_right", "move_up", "move_down", "attack", "dash"]:
		Input.action_release(action)
	# 3) A lembrança (pulando as frases) e a porta destrancando.
	# Prazos em tempo REAL: sem tela, o Godot roda quadros muito mais rápido que
	# o relógio, e a câmera lenta (medida em ms reais) dura milhares de quadros.
	var deadline := Time.get_ticks_msec() + 60000
	while Time.get_ticks_msec() < deadline:
		await get_tree().physics_frame
		for node in level.get_children():
			if node is Narration:
				(node as Narration).skip()
		if not level.exit_door.locked and level.player.state == Player.State.FREE:
			break
	# 4) A queda.
	level.player.global_position = level.exit_door.global_position + Vector2(0, 14)
	for i in 30:
		await get_tree().physics_frame
	level.player.global_position = level.exit_door.global_position + Vector2(0, -36)
	deadline = Time.get_ticks_msec() + 60000
	while Time.get_ticks_msec() < deadline:
		await get_tree().physics_frame
		for node in level.get_children():
			if node is Narration:
				(node as Narration).skip()
		if Game.prologue_done:
			break
	print("Prólogo: crianças feridas=%d, quedas delas=%d, fases da Governanta %s, vitória=%s, porta livre=%s, prólogo feito=%s → %s" % [
		hurt, falls[0], phases_seen.keys(), won[0], not level.exit_door.locked, Game.prologue_done, Game.last_scene_request])



## Bosque: o robô faz barulho de propósito (acorda os sonâmbulos), anda no
## pólen (dorme de verdade) e depois enfrenta o Vigia e a Mãe dos Esporos.
func _soak_forest(duration: float) -> void:
	Game.defeated_bosses.append("aldir")
	await _open("res://scenes/world/bosque.tscn", "porta")
	var t := 0.0
	var defeated := [0]
	var naps := [0]
	for node in get_tree().get_nodes_in_group("respawnable"):
		(node as Enemy).defeated.connect(func(_e): defeated[0] += 1)
	_level.player.sleep_changed.connect(func(asleep: bool): if asleep: naps[0] += 1)
	var woke := 0
	while t < duration:
		await get_tree().physics_frame
		t += 1.0 / 60.0
		var nearest: Node2D = null
		var best := INF
		for node in get_tree().get_nodes_in_group("enemies"):
			if node is MiniBoss:
				continue
			var d: float = (node as Node2D).global_position.distance_to(_level.player.global_position)
			if d < best:
				best = d
				nearest = node
		if nearest == null:  # os que dormem não estão no alvo? vai até um sonâmbulo
			for node in get_tree().get_nodes_in_group("listeners"):
				if node is Sonambulo:
					nearest = node
					break
		if t > 40.0 and t < 50.0:
			# Fica PARADO ao lado de uma flor: a nuvem tem que fazê-lo dormir.
			for action in ["move_left", "move_right", "move_up", "move_down", "attack", "dash", "block"]:
				Input.action_release(action)
			if t - 1.0 / 60.0 <= 40.0:
				for node in get_tree().get_nodes_in_group("respawnable"):
					if node is FlorDePolen and not (node as Enemy).dead:
						_level.player.global_position = (node as Node2D).global_position + Vector2(-30, 0)
						break
			_level.player._iframes_left = 1.0
			continue
		_bot_step(_level.player, t, nearest)
		if not _level.player.is_asleep():
			_level.player._iframes_left = 0.0 if fmod(t, 6.0) < 2.0 else 1.0  # às vezes apanha (acorda do sono)
	for node in get_tree().get_nodes_in_group("listeners"):
		if node is Sonambulo and (node as Sonambulo).is_awake():
			woke += 1
	print("Bosque: %d inimigos derrotados em %.0f s; cochilos do robô=%d; sonâmbulos acordados agora=%d; flags=%s" % [
		defeated[0], duration, naps[0], woke, Game.flags])
	for node in get_tree().get_nodes_in_group("minibosses"):
		var mini := node as MiniBoss
		if mini == null or mini.dead:
			continue
		var won := [false]
		mini.fight_won.connect(func(_b): won[0] = true)
		_level.player.global_position = mini.home_position + Vector2(-60, 10)
		var tt := 0.0
		while tt < 120.0 and not won[0]:
			await get_tree().physics_frame
			tt += 1.0 / 60.0
			t += 1.0 / 60.0
			if is_instance_valid(mini) and not mini.dead:
				_bot_step(_level.player, t, mini)
				if not mini.active and fmod(tt, 1.0) < 1.0 / 60.0:
					_level.player.make_noise(120.0)  # o Vigia só acorda com barulho
				if fmod(tt, 3.0) < 1.0 / 60.0 and mini.active:
					mini.stats.take_damage(40.0)
		print("Mini-chefe %s: vitória=%s em %.0f s" % [mini.display_name() if is_instance_valid(mini) else "?", won[0], tt])

	await _soak_nyssa(150.0)


## Nyssa: o robô ataca de vez em quando, fica parado de vez em quando (dorme),
## atravessa o Pesadelo (buracos, ecos) até vencer.
func _soak_nyssa(limit: float) -> void:
	Game.defeated_bosses.assign(["aldir", "governanta", "helena", "sargento", "couraca", "vigia", "mae_esporos"])
	await _open("res://scenes/world/arena_nyssa.tscn", "porta")
	var nyssa := _level.boss_arena.boss as NyssaLumevel
	var won := [false]
	var naps := [0]
	var echoes := [0]
	nyssa.fight_won.connect(func(_b): won[0] = true)
	_level.player.sleep_changed.connect(func(asleep: bool): if asleep: naps[0] += 1)
	_level.player.global_position = nyssa.global_position + Vector2(0, 60)
	var t := 0.0
	var phases := {}
	while t < limit and not won[0]:
		await get_tree().physics_frame
		t += 1.0 / 60.0
		if not is_instance_valid(nyssa):
			break
		phases[nyssa.phase] = true
		echoes[0] = maxi(echoes[0], get_tree().get_nodes_in_group("dream_echoes").size())
		if fmod(t, 8.0) < 2.5:
			for action in ["move_left", "move_right", "move_up", "move_down", "attack", "dash"]:
				Input.action_release(action)  # fica parado: a barra sobe
			_level.player._iframes_left = 1.0
		else:
			_bot_step(_level.player, t, nyssa)
		if _level.player.stats.health < 40.0:
			_level.player.stats.revive()
		if fmod(t, 2.0) < 1.0 / 60.0 and nyssa.active and not nyssa.hurtbox.invulnerable:
			nyssa.hurtbox.receive_hit(HitInfo.create(45.0, _level.player.global_position, nyssa.global_position))
	print("Nyssa: fases vistas %s, vitória=%s em %.0f s, cochilos do robô=%d, ecos ao mesmo tempo (máx)=%d" % [
		phases.keys(), won[0], t, naps[0], echoes[0]])



## Raízes da Fome: emboscadas, explosões, larvas que roubam, os dois mini-chefes
## e Mabel. O robô às vezes fica vulnerável para ser AGARRADO (e escapar).
func _soak_roots(duration: float) -> void:
	Game.defeated_bosses.assign(["aldir", "nyssa"])
	await _open("res://scenes/world/raizes.tscn", "porta")
	var t := 0.0
	var defeated := [0]
	var grabs := [0]
	for node in get_tree().get_nodes_in_group("respawnable"):
		(node as Enemy).defeated.connect(func(_e): defeated[0] += 1)
	_level.player.grab_changed.connect(func(grabbed: bool, _n: int): if grabbed: grabs[0] += 1)
	Game.memories = 3000
	while t < duration:
		await get_tree().physics_frame
		t += 1.0 / 60.0
		var nearest: Node2D = null
		var best := INF
		for node in get_tree().get_nodes_in_group("enemies"):
			if node is MiniBoss:
				continue
			var d: float = (node as Node2D).global_position.distance_to(_level.player.global_position)
			if d < best:
				best = d
				nearest = node
		if nearest == null:  # as bocas enterradas não são alvo: anda até uma
			for node in get_tree().get_nodes_in_group("respawnable"):
				if node is BocaDeRaiz and not (node as Enemy).dead:
					nearest = node
					break
		if fmod(t, 18.0) < 1.0 / 60.0:
			# De tempos em tempos pisa numa Boca de Raiz de propósito e ESPERA (exercita o agarrão).
			for node in get_tree().get_nodes_in_group("respawnable"):
				if node is BocaDeRaiz and (node as BocaDeRaiz).ai == BocaDeRaiz.AI.BURIED:
					_level.player.global_position = (node as Node2D).global_position + Vector2(3, 0)
					break
		if fmod(t, 18.0) < 0.8 and not _level.player.is_grabbed():
			for action in ["move_left", "move_right", "move_up", "move_down", "attack", "dash", "block"]:
				Input.action_release(action)
			_level.player._iframes_left = 0.0
			continue
		_bot_step(_level.player, t, nearest)
		if not _level.player.is_grabbed():
			_level.player._iframes_left = 0.0 if fmod(t, 6.0) < 2.0 else 1.0
	print("Raízes: %d inimigos derrotados em %.0f s; agarrões=%d; memórias=%d; explosões no chão agora=%d" % [
		defeated[0], duration, grabs[0], Game.memories, get_tree().get_nodes_in_group("flesh_bursts").size()])
	for node in get_tree().get_nodes_in_group("minibosses"):
		var mini := node as MiniBoss
		if mini == null or mini.dead:
			continue
		var won := [false]
		mini.fight_won.connect(func(_b): won[0] = true)
		_level.player.global_position = mini.home_position + Vector2(-60, 10)
		var tt := 0.0
		while tt < 120.0 and not won[0]:
			await get_tree().physics_frame
			tt += 1.0 / 60.0
			t += 1.0 / 60.0
			if is_instance_valid(mini) and not mini.dead:
				_bot_step(_level.player, t, mini)
				if not _level.player.is_grabbed():
					_level.player._iframes_left = 0.0 if fmod(tt, 5.0) < 1.5 else 1.0
				if fmod(tt, 3.0) < 1.0 / 60.0 and mini.active:
					mini.stats.take_damage(45.0)
		print("Mini-chefe %s: vitória=%s em %.0f s" % [mini.display_name() if is_instance_valid(mini) else "?", won[0], tt])
	await _soak_mabel(180.0)


## Mabel: tapas, frutos, o engolir (o robô escapa tocando), raízes e lacaios.
func _soak_mabel(limit: float) -> void:
	Game.defeated_bosses.assign(["aldir", "nyssa", "banqueteiro"])
	await _open("res://scenes/world/arena_mabel.tscn", "porta")
	var mabel := _level.boss_arena.boss as MabelVoragine
	var won := [false]
	var swallowed := [0]
	var max_roots := [0]
	var max_lackeys := [0]
	mabel.fight_won.connect(func(_b): won[0] = true)
	_level.player.grab_changed.connect(func(grabbed: bool, _n: int): if grabbed: swallowed[0] += 1)
	_level.player.global_position = mabel.global_position + Vector2(0, 90)
	Game.memories = 3000
	var t := 0.0
	var phases := {}
	while t < limit and not won[0]:
		await get_tree().physics_frame
		t += 1.0 / 60.0
		if not is_instance_valid(mabel):
			break
		phases[mabel.phase] = true
		max_roots[0] = maxi(max_roots[0], mabel.living_roots())
		max_lackeys[0] = maxi(max_lackeys[0], mabel.lackeys.size())
		# Fase 2: corta as raízes primeiro (a lição), depois Mabel.
		var goal: Node2D = mabel
		for root in mabel.roots:
			if is_instance_valid(root) and not root.dead:
				goal = root
				break
		if fmod(t, 15.0) < 1.0 / 60.0 and mabel.active and mabel.mode != MabelVoragine.Mode.TRANSITION:
			# Fica na linha da mão dela de propósito: engolido (e escapa tocando).
			mabel._runner.cancel()
			mabel._combo.clear()
			_level.player.global_position = mabel.clamp_to_arena(mabel.global_position + Vector2(50, 0), 20.0)
			mabel._start_reach()
		if mabel.mode == MabelVoragine.Mode.REACH:
			for action in ["move_left", "move_right", "move_up", "move_down", "attack", "dash", "block"]:
				Input.action_release(action)
			_level.player._iframes_left = 0.0
			continue
		_bot_step(_level.player, t, goal)
		if mabel.mode == MabelVoragine.Mode.REACH:
			_level.player._iframes_left = 0.0  # deixa a mão chegar
		elif not _level.player.is_grabbed():
			_level.player._iframes_left = 0.0 if fmod(t, 7.0) < 2.0 else 1.0
		if _level.player.stats.health < 40.0:
			_level.player.stats.revive()
		if fmod(t, 2.0) < 1.0 / 60.0 and mabel.active and not mabel.hurtbox.invulnerable:
			mabel.hurtbox.receive_hit(HitInfo.create(55.0, _level.player.global_position, mabel.global_position))
	print("Mabel: fases vistas %s, vitória=%s em %.0f s, engolido=%d vezes, raízes (máx)=%d, lacaios (máx)=%d, tamanho=%.2f" % [
		phases.keys(), won[0], t, swallowed[0], max_roots[0], max_lackeys[0], mabel.growth if is_instance_valid(mabel) else 0.0])



## Forjas Ocas: placas de raio, torretas, autômatos, o Imitador, os dois
## mini-chefes e Durgan (o robô alterna golpes, dash e escudo).
func _soak_forge(duration: float) -> void:
	Game.defeated_bosses.assign(["aldir", "nyssa", "mabel"])
	Game.add_item("escudo_remendado")
	Game.set_shield_equipped(true)
	await _open("res://scenes/world/forjas.tscn", "porta")
	var t := 0.0
	var defeated := [0]
	var shocks := [0]
	for node in get_tree().get_nodes_in_group("respawnable"):
		(node as Enemy).defeated.connect(func(_e): defeated[0] += 1)
	while t < duration:
		await get_tree().physics_frame
		t += 1.0 / 60.0
		shocks[0] = maxi(shocks[0], get_tree().get_nodes_in_group("plate_charges").size())
		if fmod(t, 15.0) < 1.0 / 60.0:
			# O robô não sabe achar caminho: de tempos em tempos, vai até um grupo de inimigos.
			var alive := get_tree().get_nodes_in_group("respawnable").filter(func(e): return not (e as Enemy).dead)
			if not alive.is_empty():
				_level.player.global_position = (alive[int(t / 15.0) % alive.size()] as Node2D).global_position + Vector2(-40, 0)
		var nearest: Node2D = null
		var best := INF
		for node in get_tree().get_nodes_in_group("enemies"):
			if node is MiniBoss:
				continue
			var d: float = (node as Node2D).global_position.distance_to(_level.player.global_position)
			if d < best:
				best = d
				nearest = node
		_bot_step(_level.player, t, nearest)
		if not _level.player.is_grabbed():
			_level.player._iframes_left = 0.0 if fmod(t, 6.0) < 2.0 else 1.0
	print("Forjas: %d inimigos derrotados em %.0f s; placas acesas ao mesmo tempo (máx)=%d; placas no mapa=%d" % [
		defeated[0], duration, shocks[0], _level.plate_cells.size()])
	for node in get_tree().get_nodes_in_group("minibosses"):
		var mini := node as MiniBoss
		if mini == null or mini.dead:
			continue
		var won := [false]
		mini.fight_won.connect(func(_b): won[0] = true)
		_level.player.global_position = mini.home_position + Vector2(-60, 30)
		var tt := 0.0
		while tt < 120.0 and not won[0]:
			await get_tree().physics_frame
			tt += 1.0 / 60.0
			t += 1.0 / 60.0
			if is_instance_valid(mini) and not mini.dead:
				_bot_step(_level.player, t, mini)
				_level.player._iframes_left = 0.0 if fmod(tt, 5.0) < 1.5 else 1.0
				if fmod(tt, 3.0) < 1.0 / 60.0 and mini.active:
					mini.stats.take_damage(60.0)
		print("Mini-chefe %s: vitória=%s em %.0f s" % [mini.display_name() if is_instance_valid(mini) else "?", won[0], tt])
	var unlocked := false
	for node in _level.entities.get_children():
		if node is AreaExit and (node as AreaExit).target_scene.contains("arena_durgan"):
			unlocked = true
	print("Forjas: porta da Forja do Eco aberta sem recarregar=%s" % unlocked)
	await _soak_durgan(180.0)


func _soak_durgan(limit: float) -> void:
	Game.defeated_bosses.assign(["aldir", "nyssa", "mabel", "guardiao_ancora"])
	await _open("res://scenes/world/arena_durgan.tscn", "porta")
	var durgan := _level.boss_arena.boss as DurganVell
	var won := [false]
	var copies := {}
	var max_helpers := [0]
	durgan.fight_won.connect(func(_b): won[0] = true)
	_level.player.global_position = durgan.global_position + Vector2(0, 90)
	var t := 0.0
	var phases := {}
	while t < limit and not won[0]:
		await get_tree().physics_frame
		t += 1.0 / 60.0
		if not is_instance_valid(durgan):
			break
		phases[durgan.phase] = true
		max_helpers[0] = maxi(max_helpers[0], durgan.helpers.size())
		if durgan.last_copy != &"":
			copies[durgan.last_copy] = true
		_bot_step(_level.player, t, durgan)
		_level.player._iframes_left = 0.0 if fmod(t, 7.0) < 2.0 else 1.0
		if _level.player.stats.health < 40.0:
			_level.player.stats.revive()
		if fmod(t, 2.0) < 1.0 / 60.0 and durgan.active and not durgan.hurtbox.invulnerable:
			# Dano de "atalho" baixo na fase 1: dá tempo de ele construir torretas e autômatos.
			var hit := HitInfo.create(18.0 if durgan.phase == 1 else 55.0, _level.player.global_position, durgan.global_position)
			hit.is_heavy = fmod(t, 4.0) < 1.0
			durgan.hurtbox.receive_hit(hit)
	print("Durgan: fases vistas %s, vitória=%s em %.0f s, contagem=%s, copiou=%s, ajudantes (máx)=%d" % [
		phases.keys(), won[0], t, durgan.counts if is_instance_valid(durgan) else {}, copies.keys(), max_helpers[0]])
