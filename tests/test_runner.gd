extends Node
## Testes automáticos das regras do jogo (rodam sem tela):
##   godot --headless --fixed-fps 60 --path . res://tests/test_runner.tscn
## Saída: lista de PASSOU/FALHOU e código de saída = número de falhas.
## Só alguns:  ... test_runner.tscn -- vigia sono   (nomes que contêm as palavras)
##
## Boa prática de mercado: regra de combate que não tem teste QUEBRA sem
## ninguém perceber quando você mexe em outra coisa.

const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const SOLDIER_SCENE := preload("res://scenes/enemies/soldado_remendado.tscn")
const HELENA_SCENE := preload("res://scenes/bosses/helena_altiva.tscn")
const ALDIR_SCENE := preload("res://scenes/bosses/aldir_cornelios.tscn")
const CHILD_SCENE := preload("res://scenes/enemies/crianca.tscn")
const GOVERNESS_SCENE := preload("res://scenes/bosses/governanta.tscn")
const PROLOGO := "res://scenes/world/prologo.tscn"
const DOG_SCENE := preload("res://scenes/enemies/cao_de_guerra.tscn")
const SNIPER_SCENE := preload("res://scenes/enemies/atirador.tscn")
const CIVIL_SCENE := preload("res://scenes/enemies/civil_cinzento.tscn")
const SARGENTO_SCENE := preload("res://scenes/bosses/sargento.tscn")
const COURACA_SCENE := preload("res://scenes/bosses/couraca.tscn")
const DUMMY_SCENE := preload("res://scenes/world/training_dummy.tscn")
const SLEEPER_SCENE := preload("res://scenes/enemies/sonambulo.tscn")
const FLOWER_SCENE := preload("res://scenes/enemies/flor_polen.tscn")
const DEER_SCENE := preload("res://scenes/enemies/cervo.tscn")
const WITHER_SCENE := preload("res://scenes/enemies/fada_murcha.tscn")
const VIGIA_SCENE := preload("res://scenes/bosses/vigia.tscn")
const MAE_SCENE := preload("res://scenes/bosses/mae_esporos.tscn")
const BOSQUE := "res://scenes/world/bosque.tscn"
const ARENA_NYSSA := "res://scenes/world/arena_nyssa.tscn"
const BOCA_SCENE := preload("res://scenes/enemies/boca_de_raiz.tscn")
const INCHADO_SCENE := preload("res://scenes/enemies/inchado.tscn")
const COLHEDOR_SCENE := preload("res://scenes/enemies/colhedor.tscn")
const LARVA_SCENE := preload("res://scenes/enemies/larva_seiva.tscn")
const BANQUETEIRO_SCENE := preload("res://scenes/bosses/banqueteiro.tscn")
const NINHADA_SCENE := preload("res://scenes/bosses/ninhada.tscn")
const RAIZES := "res://scenes/world/raizes.tscn"
const ARENA_MABEL := "res://scenes/world/arena_mabel.tscn"
const FORJAS := "res://scenes/world/forjas.tscn"
const ARENA_DURGAN := "res://scenes/world/arena_durgan.tscn"
const AUTOMATO_SCENE := preload("res://scenes/enemies/automato_bronze.tscn")
const TORRETA_SCENE := preload("res://scenes/enemies/torreta_faisca.tscn")
const MINERADOR_SCENE := preload("res://scenes/enemies/minerador_oco.tscn")
const IMITADOR_SCENE := preload("res://scenes/enemies/imitador.tscn")
const PROTOTIPO_SCENE := preload("res://scenes/bosses/prototipo.tscn")
const GUARDIAO_SCENE := preload("res://scenes/bosses/guardiao_ancora.tscn")
const CIDADE := "res://scenes/world/cidade.tscn"
const MONTANHA := "res://scenes/world/montanha.tscn"
const ARENA_RACHEL := "res://scenes/world/arena_rachel.tscn"
const ATIRADOR_DRAGAO_SCENE := preload("res://scenes/enemies/dragonoide_atirador.tscn")
const BESTIAL_SCENE := preload("res://scenes/enemies/dragao_bestial.tscn")
const ALADO_SCENE := preload("res://scenes/enemies/dragao_alado.tscn")
const BRASA_SCENE := preload("res://scenes/enemies/brasa_viva.tscn")
const CAPITAO_SCENE := preload("res://scenes/bosses/capitao_dragonoide.tscn")
const MATRIARCA_SCENE := preload("res://scenes/bosses/matriarca_bestial.tscn")
const DOMINIO := "res://scenes/world/dominio.tscn"
const TEATRO := "res://scenes/world/teatro.tscn"
const NUCLEO := "res://scenes/world/nucleo.tscn"
const CORACAO := "res://scenes/world/coracao.tscn"
const ENDING_SCENE := preload("res://scenes/ui/ending.tscn")
const ARENA_CASSIAN := "res://scenes/world/arena_cassian.tscn"
const BIBLIOTECARIO_SCENE := preload("res://scenes/enemies/bibliotecario_gelo.tscn")
const ESTATUA_SCENE := preload("res://scenes/enemies/estatua_viva.tscn")
const ACARO_SCENE := preload("res://scenes/enemies/acaro_cristal.tscn")
const APRENDIZ_SCENE := preload("res://scenes/enemies/aprendiz_arcano.tscn")
const CURADORA_SCENE := preload("res://scenes/bosses/curadora_vitrines.tscn")
const GOLEM_SCENE := preload("res://scenes/bosses/golem_arquivo.tscn")
## Os testes gravam num arquivo próprio: o seu save de verdade nunca é tocado.
const TEST_SAVE := "user://teste_automatico_save.json"

var _failures: Array[String] = []
var _passed := 0
var _current := ""
var _world: Node2D


func _ready() -> void:
	Fx.enabled = false
	Game.persistence_enabled = false
	Game.save_path = TEST_SAVE
	Game.scene_changes_enabled = false  # Game.travel() & cia. só anotam o pedido
	Game.delete_save()
	Sfx.muted = true
	await get_tree().process_frame
	var tests := [
		"test_stats_rules",
		"test_attack_runner_timeline",
		"test_player_step_and_anchor",
		"test_exhaustion_blocks_actions",
		"test_dash_iframes",
		"test_solid_walls",
		"test_light_combo_and_heavy",
		"test_hit_training_dummy",
		"test_soldier_shield",
		"test_heal_flask",
		"test_death_memory_vision",
		"test_helena_phases",
		"test_save_roundtrip",
		"test_title_pause_keeps_save",
		"test_levels_build",
		"test_touch_controls",
		"test_input_after_unlock_and_buffer",
		"test_level_flow",
		"test_soldier_tokens",
		"test_helena_details",
		"test_fader_supersede",
		"test_pit_fall_and_dash",
		"test_cover_blocks_shockwave",
		"test_aldir_phase_1",
		"test_aldir_phase_2",
		"test_aldir_arena_and_gate",
		"test_child_play_and_fall",
		"test_child_counter_only_player",
		"test_governess_attacks",
		"test_prologue_peaceful",
		"test_prologue_governess_fight",
		"test_save_v2_migration",
		"test_new_game_starts_prologue",
		"test_fx_time_effects_stack",
		"test_dog_bites_and_retreats",
		"test_sniper_aims_locks_and_shoots",
		"test_projectile_walls_and_dash",
		"test_civilian_passive_and_provoked",
		"test_sargento_whistles_and_platoon",
		"test_miniboss_resets_when_player_flees",
		"test_couraca_back_only",
		"test_inventory_and_save_v3",
		"test_smith_upgrade",
		"test_orb_purifies_fragments",
		"test_pickups_and_drops",
		"test_shield_block",
		"test_inventory_menu",
		"test_drowsiness_and_sleep",
		"test_noise",
		"test_sleepwalker",
		"test_pollen_flower",
		"test_deer_charge",
		"test_wither_fairy_heals",
		"test_vigia_sneak_or_fight",
		"test_spore_mother",
		"test_forest_gate",
		"test_nyssa_fight",
		"test_dream_echoes",
		"test_nyssa_phase_from_any_damage",
		"test_grab_and_escape",
		"test_root_mouth_ambush",
		"test_bloated_explodes",
		"test_reaper_scythe",
		"test_sap_larva_steals_and_returns",
		"test_banqueteiro_serves_and_eats",
		"test_ninhada_splits_and_engulfs",
		"test_roots_gate",
		"test_mabel_fight",
		"test_new_areas_build",
		"test_live_exit_unlock",
		"test_plate_charge",
		"test_bronze_automaton",
		"test_spark_turret",
		"test_hollow_miner",
		"test_imitator_copies",
		"test_prototype",
		"test_anchor_guardian",
		"test_forge_gate_and_smith",
		"test_durgan_fight",
		"test_fire_patch_and_ember_shot",
		"test_dragonoid_shooter",
		"test_beast_charge_and_daze",
		"test_wyvern_dive",
		"test_living_ember",
		"test_dragonoid_captain",
		"test_beast_matriarch",
		"test_mountain_gate",
		"test_rachel_fight",
		"test_ice_slides",
		"test_frost_shard_chills",
		"test_ice_block_taps",
		"test_frost_zone_traps",
		"test_ice_librarian",
		"test_living_statue",
		"test_crystal_mite",
		"test_arcane_apprentice",
		"test_curator",
		"test_archive_golem",
		"test_frozen_domain_gate",
		"test_cassian_fight",
		"test_seven_memories_gate",
		"test_core_garden",
		"test_knight_fight",
		"test_endings",
	]
	# Filtro opcional: "... test_runner.tscn -- sono vigia" roda só os testes
	# cujo nome contém alguma dessas palavras (útil enquanto se mexe numa coisa).
	var filters := Array(OS.get_cmdline_user_args())
	if not filters.is_empty():
		tests = tests.filter(func(name: String): return filters.any(func(f: String): return name.contains(f)))
	for test in tests:
		_current = test
		_reset_world()
		Game.reset_progress()
		Game.session_active = false
		var before := _failures.size()
		await call(test)
		_release_all_actions()
		get_tree().paused = false  # um teste que falhou no meio não contamina o próximo
		if _failures.size() == before:
			_passed += 1
			print("  PASSOU  ", test)
		else:
			print("  FALHOU  ", test)
	Game.delete_save()
	print("\n%d passaram, %d falharam" % [_passed, _failures.size()])
	for failure in _failures:
		print("   - ", failure)
	get_tree().quit(_failures.size())


# --- utilidades -------------------------------------------------------------------

func check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append("%s: %s" % [_current, message])


func frames(count: int) -> void:
	for i in count:
		await get_tree().physics_frame


func seconds(duration: float) -> void:
	await frames(int(ceil(duration * 60.0)))


func _reset_world() -> void:
	if is_instance_valid(_world):
		_world.free()
	_world = Node2D.new()
	add_child(_world)


func _release_all_actions() -> void:
	for action in ["move_left", "move_right", "move_up", "move_down", "attack", "attack_heavy", "dash", "heal", "sanity", "block", "inventory"]:
		Input.action_release(action)


func spawn_player(at: Vector2 = Vector2(200, 200)) -> Player:
	var player := PLAYER_SCENE.instantiate() as Player
	player.position = at
	_world.add_child(player)
	return player


func tap(action: StringName) -> void:
	Input.action_press(action)
	await frames(2)
	Input.action_release(action)
	await frames(1)


func touch_event(index: int, pressed: bool, at: Vector2) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.pressed = pressed
	event.position = at
	get_viewport().push_input(event, true)  # coordenadas do jogo (480x270)


func drag_event(index: int, at: Vector2) -> void:
	var event := InputEventScreenDrag.new()
	event.index = index
	event.position = at
	get_viewport().push_input(event, true)


func open_level(path: String, spawn: String) -> Level:
	Game.pending_spawn = spawn
	var level := (load(path) as PackedScene).instantiate() as Level
	_world.add_child(level)
	await frames(5)
	return level


func find_npc(dialogue_id: String) -> NPC:
	for node in get_tree().get_nodes_in_group("npcs"):
		if (node as NPC).dialogue_id == dialogue_id:
			return node
	return null


func write_text(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func add_wall(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = rect.size
	shape.shape = box
	body.position = rect.get_center()
	body.add_child(shape)
	_world.add_child(body)


# --- testes -----------------------------------------------------------------------

func test_stats_rules() -> void:
	var stats := StatsComponent.new()
	_world.add_child(stats)
	check(is_equal_approx(stats.max_health, 100.0), "Vitalidade 10 deveria dar 100 de vida (deu %s)" % stats.max_health)
	check(is_equal_approx(stats.max_stamina, 100.0), "Fôlego 10 deveria dar 100 de estamina")
	stats.apply_attributes({"vitalidade": 30}, true)
	check(is_equal_approx(stats.max_health, 170.0), "retorno decrescente acima de 25 (esperado 170, deu %s)" % stats.max_health)
	stats.apply_attributes({"vitalidade": 10}, true)
	check(stats.try_spend_stamina(60.0), "deveria gastar 60 de estamina")
	check(stats.try_spend_stamina(60.0), "regra Souls: com 40 ainda dá para gastar 60")
	check(stats.is_exhausted, "zerou → Exaustão")
	check(not stats.try_spend_stamina(1.0), "exausto não pode gastar estamina")
	await seconds(0.3)
	check(stats.stamina == 0.0, "não regenera durante o regen_delay")
	await seconds(1.0)
	check(stats.stamina > 0.0, "regenera sozinha depois da pausa")
	check(stats.is_exhausted, "continua exausto até recuperar o mínimo")
	await seconds(1.0)
	check(not stats.is_exhausted, "sai da Exaustão ao recuperar 35%% (estamina=%s)" % stats.stamina)
	var died := [false]
	stats.died.connect(func(): died[0] = true)
	stats.take_damage(250.0)
	check(died[0] and stats.is_dead, "vida zerada → died")
	stats.revive()
	check(not stats.is_dead and stats.health == stats.max_health, "revive enche tudo")


func test_attack_runner_timeline() -> void:
	var attack := AttackData.new()
	attack.windup_time = 0.1
	attack.lunge_speed = 200.0
	attack.lunge_time = 0.05
	attack.active_time = 0.05
	attack.recovery_time = 0.1
	var runner := AttackRunner.new()
	var phases: Array = []
	runner.phase_changed.connect(func(p): phases.append(p))
	runner.start(attack, Vector2.RIGHT)
	var v := Vector2(80, 0)
	var dt := 1.0 / 60.0
	var saw_lunge_speed := false
	var active_velocity_zero := true
	for i in 40:
		v = runner.step(dt, v)
		if runner.phase == AttackRunner.Phase.LUNGE and is_equal_approx(v.x, 200.0):
			saw_lunge_speed = true
		if runner.phase == AttackRunner.Phase.ACTIVE and v != Vector2.ZERO:
			active_velocity_zero = false
	check(phases == [AttackRunner.Phase.WINDUP, AttackRunner.Phase.LUNGE, AttackRunner.Phase.ACTIVE, AttackRunner.Phase.RECOVERY, AttackRunner.Phase.IDLE], "ordem das fases: %s" % [phases])
	check(saw_lunge_speed, "micro-impulso na velocidade do lunge")
	check(active_velocity_zero, "freio seco: velocidade 0 na fase ativa")


func test_player_step_and_anchor() -> void:
	var player := spawn_player()
	await frames(2)
	var start := player.global_position
	var stamina_before := player.stats.stamina
	Input.action_press(&"move_left")  # tenta andar para TRÁS durante o golpe
	player.facing = Vector2.RIGHT
	Input.action_release(&"move_left")
	await tap(&"attack")
	check(player.state == Player.State.ATTACK, "toque curto inicia golpe leve (estado=%s)" % player.state)
	check(is_equal_approx(player.stats.stamina, stamina_before - 16.0), "golpe leve gasta 16 de estamina")
	Input.action_press(&"move_left")
	var max_x := start.x
	var active_still := true
	var saw_active := false
	for i in 30:
		await frames(1)
		max_x = maxf(max_x, player.global_position.x)
		if player._runner.phase == AttackRunner.Phase.ACTIVE:
			saw_active = true
			if player.velocity != Vector2.ZERO:
				active_still = false
	Input.action_release(&"move_left")
	check(saw_active, "o golpe passou pela fase ativa")
	check(max_x - start.x >= 6.0, "micro-impulso para FRENTE apesar do input para trás (avançou %.1f px)" % (max_x - start.x))
	check(active_still, "corpo parado (âncora) enquanto a hitbox está ativa")


func test_exhaustion_blocks_actions() -> void:
	var player := spawn_player()
	await frames(2)
	player.stats.drain_stamina(999.0)
	check(player.stats.is_exhausted, "drenado → exausto")
	var denied := [0]
	player.stamina_denied.connect(func(): denied[0] += 1)
	await tap(&"attack")
	await frames(2)
	check(player.state == Player.State.FREE, "exausto NÃO ataca")
	await tap(&"dash")
	check(player.state == Player.State.FREE, "exausto NÃO dá dash")
	check(denied[0] >= 2, "avisa o HUD que faltou estamina")
	Input.action_press(&"move_right")
	await frames(20)
	check(player.velocity.length() <= player.move_speed * player.exhausted_speed_multiplier + 1.0, "exausto anda mais devagar")
	Input.action_release(&"move_right")
	await seconds(2.5)
	check(not player.stats.is_exhausted, "recupera da Exaustão com o tempo")
	await tap(&"attack")
	check(player.state == Player.State.ATTACK, "recuperado: ataca de novo")


func test_dash_iframes() -> void:
	var player := spawn_player()
	await frames(2)
	var start := player.global_position
	Input.action_press(&"move_right")
	await frames(1)
	await tap(&"dash")
	check(player.state == Player.State.DASH, "dash começou")
	check(player.hurtbox.invulnerable, "i-frames no início do dash")
	await seconds(0.25)
	check(not player.hurtbox.invulnerable, "i-frames acabam antes do fim do dash")
	await seconds(0.3)
	Input.action_release(&"move_right")
	var distance := player.global_position.x - start.x
	check(distance > 40.0, "dash percorre distância (%.1f px)" % distance)


func test_solid_walls() -> void:
	var player := spawn_player(Vector2(200, 200))
	add_wall(Rect2(220, 150, 20, 100))
	await frames(2)
	Input.action_press(&"move_right")
	await seconds(1.5)
	check(player.global_position.x < 220.0, "andando não atravessa a parede (x=%.1f)" % player.global_position.x)
	player.facing = Vector2.RIGHT
	Input.action_release(&"move_right")
	for i in 3:
		await tap(&"attack")
		await seconds(0.5)
	check(player.global_position.x < 220.0, "o micro-impulso do golpe também respeita a parede")
	player.stats.revive()
	Input.action_press(&"move_right")
	await tap(&"dash")
	await seconds(0.5)
	Input.action_release(&"move_right")
	check(player.global_position.x < 220.0, "o dash não atravessa parede")


func test_light_combo_and_heavy() -> void:
	var player := spawn_player()
	await frames(2)
	var names: Array[String] = []
	player._runner.phase_changed.connect(func(p):
		if p == AttackRunner.Phase.WINDUP:
			names.append(player._current_attack.display_name))
	for i in 3:
		await tap(&"attack")
		await seconds(0.3)
	await seconds(0.6)
	check(names == ["Corte", "Contracorte", "Estocada"], "combo de 3 golpes leves: %s" % [names])
	names.clear()
	player.stats.revive()
	Input.action_press(&"attack")
	await seconds(0.35)
	Input.action_release(&"attack")
	await frames(2)
	check(names == ["Golpe Forte"], "segurar = golpe forte: %s" % [names])


func test_hit_training_dummy() -> void:
	var player := spawn_player(Vector2(200, 200))
	var dummy := DUMMY_SCENE.instantiate()
	dummy.position = Vector2(220, 200)
	_world.add_child(dummy)
	var hits: Array = []
	(dummy.get_node("Hurtbox") as Hurtbox).hit_received.connect(func(info: HitInfo): hits.append(info.damage))
	await frames(2)
	player.facing = Vector2.RIGHT
	await tap(&"attack")
	await seconds(0.5)
	check(hits.size() == 1, "um golpe = um acerto (acertos: %d)" % hits.size())
	if hits.size() > 0:
		check(is_equal_approx(hits[0], 20.0), "dano do Corte com Destreza 10 = 20 (deu %s)" % hits[0])


func test_soldier_shield() -> void:
	var player := spawn_player(Vector2(200, 200))
	var soldier := SOLDIER_SCENE.instantiate() as SoldadoRemendado
	soldier.position = Vector2(222, 200)
	_world.add_child(soldier)
	await frames(2)
	soldier.set_physics_process(false)  # parado, escudo virado para o herói
	soldier.facing = Vector2.LEFT
	soldier.ai = SoldadoRemendado.AI.CHASE
	var hp := soldier.stats.health
	player.facing = Vector2.RIGHT
	await tap(&"attack")
	await seconds(0.5)
	var frontal := hp - soldier.stats.health
	check(frontal > 0.0 and frontal < 5.0, "escudo segura golpe frontal (dano %.1f)" % frontal)
	hp = soldier.stats.health
	soldier.facing = Vector2.RIGHT  # agora de costas para o herói
	player.stats.revive()
	await tap(&"attack")
	await seconds(0.5)
	var back := hp - soldier.stats.health
	check(back >= 19.0, "pelas costas o escudo não protege (dano %.1f)" % back)
	soldier.facing = Vector2.LEFT
	soldier.poise = 50.0
	player.stats.revive()
	Input.action_press(&"attack")
	await seconds(0.32)
	Input.action_release(&"attack")
	await seconds(0.6)
	check(soldier.ai == SoldadoRemendado.AI.STAGGER, "golpe forte quebra a guarda (ai=%s)" % soldier.ai)


func test_heal_flask() -> void:
	var player := spawn_player()
	await frames(2)
	player.stats.take_damage(60.0)
	var flasks := player.health_flasks
	await tap(&"heal")
	check(player.state == Player.State.HEAL, "bebe o frasco")
	check(player.health_flasks == flasks - 1, "gasta um frasco")
	await seconds(1.0)
	check(is_equal_approx(player.stats.health, 85.0), "cura 45 (vida %s)" % player.stats.health)
	check(player.state == Player.State.FREE, "volta ao normal")


func test_death_memory_vision() -> void:
	Game.memories = 200
	var lost := Game.register_death()
	check(lost == 100 and Game.memories == 100, "morrer tira metade das memórias")
	check(Game.vision_loss == 1 and Game.deaths == 1, "morte escurece a visão")
	for i in 20:
		Game.register_death()
	check(Game.vision_loss == Game.MAX_VISION_LOSS, "visão para no máximo (8)")
	check(is_equal_approx(Game.whiteness_ratio(), 1.0), "olhos/cabelo totalmente brancos")
	var player := spawn_player()
	await frames(2)
	await tap(&"sanity")
	check(player.state == Player.State.SANITY, "usa o Frasco de Sanidade")
	await seconds(1.2)
	check(Game.vision_loss == 0, "a visão volta")
	check(Game.sanity_flasks == 0, "frasco consumido")
	Game.memories = 500
	check(Game.buy_sanity_flask() and Game.sanity_flasks == 1 and Game.memories == 350, "Vendedor troca 150 memórias por um frasco")
	var cost := Game.level_up_cost()
	check(Game.try_level_up("vitalidade") and Game.attributes["vitalidade"] == 11, "Fada sobe Vitalidade")
	check(Game.memories == 350 - cost, "Fada cobra memórias")


func test_helena_phases() -> void:
	var player := spawn_player(Vector2(200, 300))
	var helena := HELENA_SCENE.instantiate() as HelenaAltiva
	helena.position = Vector2(200, 200)
	_world.add_child(helena)
	await frames(2)
	var won := [false]
	var phase_names: Array[String] = []
	helena.fight_won.connect(func(_b): won[0] = true)
	helena.phase_changed.connect(func(n: String): phase_names.append(n))
	helena.visible = true
	helena.start_fight()
	var armor_start := helena.armor
	await seconds(2.0)
	check(helena.armor < armor_start, "armadura cai com o tempo (%.3f)" % helena.armor)
	check(helena._incoming_damage_multiplier(HitInfo.new()) < 1.0, "armadura reduz o dano recebido")
	player.hurtbox.invulnerable = true
	player.set_physics_process(false)
	var info := HitInfo.create(1000.0, player.global_position, helena.global_position)
	helena.hurtbox.receive_hit(info)  # golpe enorme: NÃO pode pular a fase 2
	await frames(2)
	check(helena.phase == 2, "metade da vida → Fase 2 (fase=%d)" % helena.phase)
	check(helena.armor <= 0.5, "na fase 2 a armadura já está pela metade")
	await seconds(1.6)
	helena.stats.take_damage(9999.0)
	await frames(2)
	check(helena.phase == 3 and helena.mode == HelenaAltiva.Mode.FALLEN, "'morre' e cai antes da fase 3")
	await seconds(4.0)
	check(is_equal_approx(helena.stats.max_health, 180.0) and not helena.stats.is_dead, "levanta sem armadura com vida nova")
	check(not helena.sword.visible and not helena.helmet.visible, "sem espada e sem elmo na fase 3")
	var memories_before := Game.memories
	helena.stats.take_damage(9999.0)
	await frames(2)
	check(won[0], "vitória emitida")
	check(Game.memories >= memories_before + 2000, "recompensa de memórias")
	check(phase_names.size() >= 2, "fases anunciadas: %s" % [phase_names])


func test_save_roundtrip() -> void:
	Game.persistence_enabled = true
	Game.memories = 777
	Game.deaths = 3
	Game.vision_loss = 2
	Game.attributes["forca"] = 14
	Game.defeated_bosses.append("helena")
	Game.save_game()
	Game.reset_progress()
	check(Game.memories == 0, "reset limpa")
	check(Game.load_game(), "carrega o save")
	check(Game.memories == 777 and Game.deaths == 3 and Game.vision_loss == 2, "memórias/mortes/visão voltam")
	check(Game.attributes["forca"] == 14 and Game.is_boss_defeated("helena"), "atributos e chefes voltam")
	check(not FileAccess.file_exists(Game.save_path + ".tmp"), "não sobra arquivo temporário")
	# Save cortado no meio (app morto gravando) → recupera pela cópia .bak.
	Game.memories = 10
	Game.save_game()
	Game.memories = 20
	Game.save_game()
	write_text(Game.save_path, "{\n\t\"memories\": 90")
	Game.reset_progress()
	check(Game.load_game() and Game.memories == 10, "save corrompido → carrega a cópia .bak (memórias=%d)" % Game.memories)
	# Save e cópia ilegíveis → "Continuar" NÃO inicia jogo novo por cima.
	write_text(Game.save_path, "{oops")
	write_text(Game.save_path + ".bak", "")
	check(not Game.continue_game(), "Continuar com save ilegível devolve false")
	check(not Game.session_active, "...e não começa partida nenhuma")
	check(FileAccess.file_exists(Game.save_path + ".corrompido"), "guarda o save quebrado com outro nome")
	check(not Game.has_save(), "libera o Novo jogo")
	for suffix in [".corrompido", ".bak.corrompido"]:
		if FileAccess.file_exists(Game.save_path + suffix):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(Game.save_path + suffix))
	Game.memories = 5
	Game.save_game()
	Game.delete_save()
	check(not Game.has_save(), "apaga o save (e a cópia)")
	Game.persistence_enabled = false


## Android: ir para segundo plano na tela de título NÃO pode gravar o progresso
## zerado por cima do save (antes, isso apagava o jogo inteiro).
func test_title_pause_keeps_save() -> void:
	Game.persistence_enabled = true
	Game.memories = 4321
	Game.save_game()
	Game.reset_progress()  # título: estado zerado na memória, nenhuma partida aberta
	Game.session_active = false
	Game.notification(NOTIFICATION_APPLICATION_PAUSED)
	check(int(Game._read_save(Game.save_path).get("memories", -1)) == 4321, "minimizar no título não mexe no save")
	Game.session_active = true
	Game.memories = 99
	Game.notification(NOTIFICATION_APPLICATION_PAUSED)
	check(int(Game._read_save(Game.save_path).get("memories", -1)) == 99, "durante o jogo, minimizar salva")
	Game.session_active = false
	Game.delete_save()
	Game.persistence_enabled = false


func test_levels_build() -> void:
	for path in ["res://scenes/world/teatro.tscn", "res://scenes/world/cidade.tscn", "res://scenes/world/arena_aldir.tscn", PROLOGO, BOSQUE, ARENA_NYSSA]:
		Game.pending_spawn = "camara" if path.contains("teatro") or path.contains("prologo") else "porta"
		var level := (load(path) as PackedScene).instantiate() as Level
		_world.add_child(level)
		await frames(5)
		check(level.player != null and is_instance_valid(level.player), "%s: herói criado" % path)
		if not path.contains("prologo"):
			check(level.spawns.has("porta"), "%s: tem ponto de chegada pela porta" % path)
		if path.contains("prologo"):
			var prologo := level as Prologo
			check(prologo.rest_chamber != null and prologo.spawns.has("camara"), "Prólogo: a sua cápsula é a Câmara")
			var children := level.get_tree().get_nodes_in_group("respawnable").size()
			check(children == 5, "Prólogo: 5 crianças (%d)" % children)
			check(prologo.governess != null and prologo.governess.mode == Governanta.Mode.SEATED, "Prólogo: a Governanta sentada à mesa")
			check(prologo.boss_arena != null and prologo.boss_arena.state == BossArena.State.IDLE, "Prólogo: arena NÃO arma sozinha")
			check(prologo.exit_door != null and not prologo.exit_door.locked, "Prólogo: porta de saída destrancada")
			check(prologo._fall_area != null and prologo._fall_area.get_child_count() == 4, "Prólogo: 4 células de queda")
			check(level._fog_walls.size() == 5, "Prólogo: névoa com 5 células (%d)" % level._fog_walls.size())
			var lore := 0
			for npc in level.get_tree().get_nodes_in_group("npcs"):
				if (npc as NPC).interactable.prompt == "Examinar":
					lore += 1
			check(lore == 7, "Prólogo: 7 pontos de inspeção (%d)" % lore)
		elif path.contains("nyssa"):
			check(level.boss_arena != null and level.boss_arena.boss is NyssaLumevel, "Clareira: Nyssa deitada no ar")
			check(level.boss_arena.state == BossArena.State.ARMED, "Clareira: névoa armada ao chegar")
			check(level._fog_walls.size() == 3, "Clareira: névoa com 3 células (%d)" % level._fog_walls.size())
			check(not level.boss_arena.arena_rect.has_point(level.player.global_position), "Clareira: herói chega no corredor")
			var flowers := 0
			for node in level.get_tree().get_nodes_in_group("respawnable"):
				if node is FlorDePolen:
					flowers += 1
			check(flowers == 4, "Clareira: 4 Flores de Pólen (%d)" % flowers)
		elif path.contains("arena"):
			check(level.boss_arena != null and level.boss_arena.boss is AldirCornelios, "Arena: Aldir na praça")
			check(level.boss_arena.state == BossArena.State.ARMED, "Arena: névoa armada ao chegar (sem diálogo)")
			check(level._fog_walls.size() == 5, "Arena: névoa com 5 células (%d)" % level._fog_walls.size())
			var covers := level.get_tree().get_nodes_in_group("covers").size()
			check(covers == 10, "Arena: 10 coberturas (%d)" % covers)
			var rect := level.boss_arena.arena_rect
			check(not rect.has_point(level.player.global_position), "Arena: herói chega no corredor, fora da arena")
		elif path.contains("bosque"):
			var kinds := {}
			for node in level.get_tree().get_nodes_in_group("respawnable"):
				var kind: String = node.get_script().get_global_name()
				kinds[kind] = kinds.get(kind, 0) + 1
			check(kinds == {"Sonambulo": 5, "FlorDePolen": 5, "CervoDeMusgo": 2, "FadaMurcha": 2}, "Bosque: inimigos (%s)" % kinds)
			var minis := []
			for node in level.get_tree().get_nodes_in_group("minibosses"):
				minis.append(str(node.get_script().get_global_name()))
			minis.sort()
			check(minis == ["MaeDosEsporos", "VigiaQueDormiu"], "Bosque: os 2 mini-chefes (%s)" % [minis])
			check(level.rest_chamber != null and level.spawns.has("camara"), "Bosque: Câmara de descanso na entrada")
			check(level.spawns["porta"].x < 3 * 16 + 8, "Bosque: chega pela borda oeste, 2 células para dentro")
			var waterfalls := 0
			for child in level.floor_layer.get_children():
				if child is AnimatedSprite2D:
					waterfalls += 1
			check(waterfalls == 3, "Bosque: 3 quadros de cachoeira na borda (%d)" % waterfalls)
			var lake := Vector2i(31, 20)
			check(level.wall_layer.get_cell_source_id(lake) != -1, "Bosque: o lago é sólido (camada de paredes)")
			var bridge := Vector2i(31, 17)
			check(level.wall_layer.get_cell_source_id(bridge) == -1 and level.floor_layer.get_cell_source_id(bridge) != -1, "Bosque: a ponte é chão")
			var lore := 0
			for npc in level.get_tree().get_nodes_in_group("npcs"):
				if (npc as NPC).interactable.prompt == "Examinar":
					lore += 1
			# 4 de lore + a trilha das Forjas (trancada até vencer Mabel).
			check(lore == 5, "Bosque: 5 pontos de inspeção (%d)" % lore)
			var items := 0
			for node in level.entities.get_children():
				if node is ItemPickup:
					items += 1
			check(items == 3, "Bosque: 3 itens no chão (%d)" % items)
		elif path.contains("teatro"):
			check(level.rest_chamber != null, "Teatro: tem a Câmara de descanso")
			check(level.spawns.has("camara"), "Teatro: spawn na Câmara")
			check(level.boss_arena != null and level.boss_arena.boss != null, "Teatro: arena da Helena montada")
			check(level._fog_walls.size() == 34, "Teatro: névoa com 34 células (%d)" % level._fog_walls.size())
			var npcs := level.get_tree().get_nodes_in_group("npcs").size()
			check(npcs >= 5, "Teatro: NPCs (Fada, Vendedor, Ferreiro, Orbe, Helena) = %d" % npcs)
			check(find_npc(Level.SPARED_CHILD_TALKS) == null, "Teatro: sem a Criança Poupada (ninguém foi poupado ainda)")
		else:
			var kinds := {}
			for node in level.get_tree().get_nodes_in_group("respawnable"):
				var kind: String = node.get_script().get_global_name()
				kinds[kind] = kinds.get(kind, 0) + 1
			check(kinds.get("SoldadoRemendado", 0) == 9, "Cidade: 9 Soldados Remendados (%s)" % kinds)
			var minis := []
			for node in level.get_tree().get_nodes_in_group("minibosses"):
				minis.append(str(node.get_script().get_global_name()))
			minis.sort()
			check(minis == ["CouracaAndante", "SargentoSemPelotao"], "Cidade: os 2 mini-chefes (%s)" % [minis])
			check(kinds.get("CaoDeGuerra", 0) == 3 and kinds.get("AtiradorDeTelhado", 0) == 3 and kinds.get("CivilCinzento", 0) == 5, "Cidade: 3 cães, 3 atiradores, 5 civis (%s)" % kinds)
			check(level.rest_chamber != null and level.spawns.has("camara"), "Cidade: Câmara de descanso perto do portão")
			check(level.spawns.has("portao"), "Cidade: ponto de chegada diante do portão do Aldir")
		check(level.floor_layer.get_used_cells().size() > 300, "%s: piso desenhado" % path)
		var leaks := _find_open_edges(level)
		check(leaks.is_empty(), "%s: mapa fechado (bordas abertas em %s)" % [path, leaks.slice(0, 5)])
		check(level.wall_layer.get_used_cells().size() > 50, "%s: paredes com colisão" % path)
		level.queue_free()
		await frames(2)


## Toda célula andável deve ter, em volta, só piso ou parede/barreira com colisão.
func _find_open_edges(level: Level) -> Array:
	var open: Array = []
	for y in range(level._height):
		for x in range(level._width):
			if not level._is_floor_char(level._char_at(x, y)) or level._is_wall_char(level._char_at(x, y)):
				continue
			for offset: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var n: Vector2i = Vector2i(x, y) + offset
				var c := level._char_at(n.x, n.y)
				if level._is_floor_char(c):
					continue
				if level.wall_layer.get_cell_source_id(n) == -1:
					open.append(n)
	return open


func test_touch_controls() -> void:
	var layer := TouchControls.new()
	_world.add_child(layer)
	await frames(2)
	var start := layer.joystick.rest_position
	var press := InputEventScreenTouch.new()
	press.index = 0
	press.pressed = true
	press.position = Vector2(60, 200)
	get_viewport().push_input(press, true)  # coordenadas do jogo (480x270)
	var drag := InputEventScreenDrag.new()
	drag.index = 0
	drag.position = Vector2(100, 200)
	get_viewport().push_input(drag, true)
	await frames(2)
	check(Input.get_action_strength(&"move_right") > 0.9, "arrastar o joystick para a direita aperta move_right (%.2f)" % Input.get_action_strength(&"move_right"))
	var release := InputEventScreenTouch.new()
	release.index = 0
	release.pressed = false
	release.position = Vector2(100, 200)
	get_viewport().push_input(release, true)
	await frames(2)
	check(Input.get_action_strength(&"move_right") == 0.0, "soltar zera o movimento")
	check(layer.joystick.rest_position == start, "joystick volta ao lugar")
	var button := layer.attack_button
	var center := button.global_position + button.size * 0.5
	var touch := InputEventScreenTouch.new()
	touch.index = 1
	touch.pressed = true
	touch.position = center
	get_viewport().push_input(touch, true)
	await frames(2)
	check(Input.is_action_pressed(&"attack"), "botão de Ataque aperta a ação attack")
	touch = touch.duplicate()
	touch.pressed = false
	get_viewport().push_input(touch, true)
	await frames(2)
	check(not Input.is_action_pressed(&"attack"), "soltar o botão solta a ação")
	# Dedos levantados com o jogo PAUSADO: o evento não chega a quem está pausado.
	touch_event(0, true, Vector2(60, 200))
	drag_event(0, Vector2(100, 200))
	touch_event(1, true, center)
	await frames(2)
	check(Input.get_action_strength(&"move_right") > 0.9 and Input.is_action_pressed(&"attack"), "segurando joystick e Ataque")
	get_tree().paused = true
	await frames(1)
	touch_event(0, false, Vector2(100, 200))
	touch_event(1, false, center)
	await frames(1)
	get_tree().paused = false
	await frames(2)
	check(Input.get_action_strength(&"move_right") == 0.0, "pausar solta o joystick (herói não anda sozinho depois)")
	check(not Input.is_action_pressed(&"attack"), "pausar solta o botão de Ataque")
	check(layer.joystick._touch_index == -1 and button._touch_index == -1, "nenhum dedo 'fantasma' preso")
	touch_event(2, true, center)
	await frames(1)
	layer.set_enabled(false)  # diálogo abrindo
	await frames(1)
	check(not Input.is_action_pressed(&"attack"), "esconder os controles solta os botões")
	layer.set_enabled(true)
	touch_event(2, false, center)


## Fechar um diálogo com E/J/Espaço não pode virar cura, golpe ou dash;
## cura apertada no fim do golpe fica guardada; leve depois do forte abre o combo.
func test_input_after_unlock_and_buffer() -> void:
	var player := spawn_player()
	await frames(2)
	player.stats.take_damage(40.0)
	var flasks := player.health_flasks
	player.lock_input(true)
	await frames(2)
	Input.action_press(&"heal")  # a tecla que "fecha o diálogo"...
	Input.action_press(&"dash")
	player.lock_input(false)  # ...no mesmo quadro em que o herói é destravado
	await frames(3)
	check(player.state == Player.State.FREE, "tecla ainda apertada no destravamento é ignorada (estado=%s)" % Player.State.keys()[player.state])
	check(player.health_flasks == flasks, "nenhum frasco gasto sem querer")
	Input.action_release(&"heal")
	Input.action_release(&"dash")
	await frames(2)
	await tap(&"heal")
	check(player.state == Player.State.HEAL, "depois de soltar, a tecla volta a funcionar")
	await seconds(1.0)

	flasks = player.health_flasks
	player.stats.take_damage(30.0)
	await tap(&"attack")
	var guard := 0
	while not player._runner.in_combo_window() and guard < 60:
		await frames(1)
		guard += 1
	await tap(&"heal")
	await seconds(1.3)
	check(player.health_flasks == flasks - 1, "cura apertada no fim do golpe sai logo depois dele")

	var names: Array[String] = []
	player._runner.phase_changed.connect(func(p):
		if p == AttackRunner.Phase.WINDUP:
			names.append(player._current_attack.display_name))
	player.stats.revive()
	await tap(&"attack_heavy")
	guard = 0
	while not player._runner.in_combo_window() and guard < 90:
		await frames(1)
		guard += 1
	await tap(&"attack")
	await seconds(0.6)
	check(names == ["Golpe Forte", "Corte"], "leve depois do forte começa no 1º golpe do combo: %s" % [names])


func test_level_flow() -> void:
	# Diálogo pausa o mundo; fechar com a tecla de cura não bebe frasco.
	var level := await open_level("res://scenes/world/teatro.tscn", "camara")
	var orbe := find_npc("orbe")
	level.player.stats.take_damage(40.0)
	var flasks := level.player.health_flasks
	level._on_npc_talked(orbe)
	await frames(2)
	check(get_tree().paused, "diálogo pausa o mundo (soldados não batem em quem está lendo)")
	check(level.player.state == Player.State.LOCKED, "herói travado durante o diálogo")
	var guard := 0
	while level.hud.dialogue.visible and guard < 80:
		Input.action_press(&"heal")  # E também avança o diálogo
		level.hud.dialogue._tap()
		await frames(2)
		Input.action_release(&"heal")
		await frames(2)
		guard += 1
	await frames(3)
	check(not get_tree().paused, "fim do diálogo despausa")
	check(level.player.state == Player.State.FREE and level.player.health_flasks == flasks, "fechar com E não vira cura (estado=%s, frascos %d→%d)" % [Player.State.keys()[level.player.state], flasks, level.player.health_flasks])
	# Botão Voltar do Android: abre e fecha a pausa (um toque = uma ação).
	level.hud.propagate_notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	check(level.hud.pause_menu.visible and get_tree().paused, "Voltar abre a pausa")
	level.hud.propagate_notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	check(not level.hud.pause_menu.visible and not get_tree().paused, "Voltar de novo fecha a pausa")
	# Morte: a punição vale na hora, e não dá para pausar por cima.
	Game.memories = 200
	level.player.stats.take_damage(9999.0)
	await frames(2)
	check(Game.deaths == 1 and Game.memories == 100, "morte registrada no instante (mortes=%d, memórias=%d)" % [Game.deaths, Game.memories])
	check(not level.hud.can_pause(), "não pausa com o herói morto")
	level.hud.propagate_notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	check(not level.hud.pause_menu.visible, "Voltar com o herói morto não abre a pausa")
	level.queue_free()  # a espera da tela de morte morre junto com a fase
	await frames(2)

	# Porta: vida e frascos atravessam junto (só a Câmara enche tudo).
	var traveler := spawn_player(Vector2(100, 100))
	await frames(2)
	traveler.stats.take_damage(70.0)
	traveler.health_flasks = 1
	Game.carry(traveler.stats.health, traveler.health_flasks)
	traveler.queue_free()
	level = await open_level("res://scenes/world/cidade.tscn", "porta")
	check(is_equal_approx(level.player.stats.health, 30.0), "chega com a mesma vida (%.0f)" % level.player.stats.health)
	check(level.player.health_flasks == 1, "chega com os mesmos frascos (%d)" % level.player.health_flasks)
	check(Game.carry_health < 0.0 and Game.carry_flasks < 0, "o que veio pela porta é usado uma vez só")
	level.queue_free()
	await frames(2)


## Dois soldados presos atrás de um obstáculo não podem prender as 2 fichas de
## ataque: o soldado colado no herói precisa conseguir atacar.
func test_soldier_tokens() -> void:
	var player := spawn_player(Vector2(200, 200))
	add_wall(Rect2(290, 60, 16, 280))
	var stuck: Array[SoldadoRemendado] = []
	for y in [190, 214]:
		var soldier := SOLDIER_SCENE.instantiate() as SoldadoRemendado
		soldier.position = Vector2(330, y)
		_world.add_child(soldier)
		stuck.append(soldier)
	await frames(2)
	player.set_physics_process(false)
	player.hurtbox.invulnerable = true
	for soldier in stuck:
		soldier._set_ai(SoldadoRemendado.AI.CHASE)
	await seconds(1.0)
	var near := SOLDIER_SCENE.instantiate() as SoldadoRemendado
	near.position = Vector2(226, 200)
	_world.add_child(near)
	await frames(2)
	near._set_ai(SoldadoRemendado.AI.CHASE)
	var attacks := [0]
	near._runner.phase_changed.connect(func(p):
		if p == AttackRunner.Phase.WINDUP:
			attacks[0] += 1)
	await seconds(6.0)
	check(attacks[0] > 0, "o soldado perto do herói ataca (ataques em 6 s: %d)" % attacks[0])
	check(not stuck[0]._has_token and not stuck[1]._has_token, "soldados sem linha de visão não seguram ficha")
	check(SoldadoRemendado._attack_tokens <= SoldadoRemendado.MAX_ATTACKERS, "fichas dentro do limite")


func test_helena_details() -> void:
	var player := spawn_player(Vector2(200, 300))
	var helena := HELENA_SCENE.instantiate() as HelenaAltiva
	helena.position = Vector2(200, 200)
	_world.add_child(helena)
	await frames(2)
	helena.visible = true
	helena.start_fight()
	player.set_physics_process(false)
	player.hurtbox.invulnerable = true
	# Postura regenera (antes, a Helena nunca recuperava: cambaleava a cada golpe).
	helena.poise = 10.0
	await seconds(2.5)
	check(helena.poise > 30.0, "postura da Helena regenera (%.0f)" % helena.poise)
	# Aviso da estocada: depois do golpe, o último desenho NÃO pode ter a linha.
	var draws: Array = []
	helena.telegraph.draw.connect(func(): draws.append(helena.telegraph.line_visible))
	helena._queue_combo([helena.estocada])
	await seconds(2.0)
	check(draws.size() >= 2 and draws.has(true), "a linha da estocada aparece (%d desenhos)" % draws.size())
	check(not draws.is_empty() and draws[-1] == false, "a linha some da tela depois do golpe")
	# Salto: postura zerada no agachamento fica guardada; na aterrissagem, cambaleia.
	helena.phase = 2
	helena._start_leap()
	await frames(2)
	var info := HitInfo.create(1.0, player.global_position, helena.global_position)
	info.poise_damage = 999.0
	helena.hurtbox.receive_hit(info)
	check(helena.mode == HelenaAltiva.Mode.LEAP and helena.poise <= 0.0, "no agachamento do salto não cambaleia, mas a postura fica zerada")
	var guard := 0
	while not (helena.mode == HelenaAltiva.Mode.LEAP and helena._leap_stage == HelenaAltiva.LeapStage.LAND) and guard < 240:
		await frames(1)
		guard += 1
	await frames(10)
	helena.poise = 5.0
	var tap_info := HitInfo.create(1.0, player.global_position, helena.global_position)
	tap_info.poise_damage = 10.0
	helena.hurtbox.receive_hit(tap_info)
	check(helena.mode == HelenaAltiva.Mode.TRANSITION, "na aterrissagem (janela de punição) ela cambaleia (modo=%s)" % HelenaAltiva.Mode.keys()[helena.mode])
	await seconds(1.5)
	check(helena.visual.scale.is_equal_approx(Vector2.ONE), "corpo volta ao tamanho normal depois do salto (%s)" % helena.visual.scale)
	# Cambaleio seguido da "morte" da fase 2: a pose de queda tem que vencer.
	helena.stats.set_health(30.0)
	var wobble := HitInfo.create(1.0, player.global_position, helena.global_position)
	wobble.poise_damage = 999.0
	helena.hurtbox.receive_hit(wobble)
	await frames(3)
	helena.hurtbox.receive_hit(HitInfo.create(999.0, player.global_position, helena.global_position))
	await seconds(1.0)
	check(helena.mode == HelenaAltiva.Mode.FALLEN and absf(rad_to_deg(helena.visual.rotation)) > 70.0, "caída de verdade antes da fase 3 (%.0f°)" % rad_to_deg(helena.visual.rotation))
	await seconds(4.0)
	helena.stats.take_damage(99999.0)
	await seconds(4.0)
	check(not is_instance_valid(helena), "depois da vitória o nó da Helena é liberado (sombra junto)")


## Um fade novo por cima de outro não pode deixar ninguém esperando para sempre.
func test_fader_supersede() -> void:
	var finished := [false]
	var first := func():
		await Fader.fade_out(1.0)
		finished[0] = true
	first.call()
	await frames(5)
	await Fader.fade_in(0.1)
	await frames(2)
	check(finished[0], "o fade interrompido também termina (antes: travava a troca de cena)")
	check(Fader._rect.color.a < 0.05, "tela clara no fim")
	Fader.busy = true  # simulando uma troca de cena em andamento
	await Fader.fade_out(0.5)
	check(Fader._rect.color.a < 0.05, "durante a troca de cena, fades de fora são ignorados")
	Fader.busy = false


# --- Aldir Cornélios e a arena destrutível ---------------------------------------------

func spawn_aldir(at: Vector2 = Vector2(300, 150)) -> AldirCornelios:
	var aldir := ALDIR_SCENE.instantiate() as AldirCornelios
	aldir.position = at
	_world.add_child(aldir)
	aldir.arena_rect = Rect2(40, 40, 560, 340)
	return aldir


func add_cover(at: Vector2) -> DestructibleCover:
	var cover := DestructibleCover.new()
	cover.position = at
	_world.add_child(cover)
	return cover


func wait_for(condition: Callable, max_frames: int = 240) -> bool:
	for i in max_frames:
		if condition.call():
			return true
		await frames(1)
	return condition.call()


## Buraco: andar para dentro = cair (perde 20% da vida, volta à borda).
## Dash por cima = atravessa (Hyper Light Drifter).
func test_pit_fall_and_dash() -> void:
	var player := spawn_player(Vector2(100, 200))
	await frames(2)
	var pit := ArenaPit.create(Vector2(160, 200), Vector2(19, 12), 0.05)
	_world.add_child(pit)
	check(not pit.contains_point(Vector2(160, 200)), "durante o aviso (rachando) ainda dá para pisar")
	await seconds(0.2)
	check(pit.is_open(), "o buraco abre depois do aviso")
	Input.action_press(&"move_right")
	var fell := await wait_for(func(): return player.state == Player.State.FALL, 150)
	Input.action_release(&"move_right")
	check(fell, "andar para dentro do buraco = queda")
	await seconds(0.8)
	check(player.state == Player.State.FREE, "volta a ficar de pé depois da queda")
	check(player.global_position.x < 160.0 - 19.0, "volta para a borda segura (x=%.0f)" % player.global_position.x)
	check(is_equal_approx(player.stats.health, 80.0), "a queda custa 20%% da vida (vida=%s)" % player.stats.health)
	await seconds(1.2)  # passam os i-frames da queda
	player.global_position = Vector2(128, 200)
	await frames(2)
	Input.action_press(&"move_right")
	await frames(1)
	await tap(&"dash")
	var fell_again := false
	for i in 40:
		await frames(1)
		fell_again = fell_again or player.state == Player.State.FALL
	Input.action_release(&"move_right")
	check(not fell_again, "durante o dash não cai")
	check(player.global_position.x > 160.0 + 16.0, "o dash atravessa o buraco (x=%.0f)" % player.global_position.x)
	pit.fill()
	check(not pit.contains_point(Vector2(160, 200)), "buraco entupido de entulho é chão de novo")


## Cobertura de concreto segura a Onda de Choque (e é desgastada por ela).
func test_cover_blocks_shockwave() -> void:
	var player := spawn_player(Vector2(300, 200))
	player.set_physics_process(false)
	var cover := add_cover(Vector2(200, 206))
	await frames(2)
	Shockwave.launch(_world, Vector2(100, 200), Vector2.RIGHT, null, 24.0, 300.0, 300.0, 12.0)
	await seconds(1.0)
	check(is_equal_approx(player.stats.health, 100.0), "a cobertura segura a onda (vida=%s)" % player.stats.health)
	check(is_equal_approx(cover.health, cover.max_health - 12.0), "a onda desgasta a cobertura (%.0f)" % cover.health)
	cover.smash()
	check(cover.broken and not cover.is_in_group("covers"), "cobertura destruída vira entulho")
	await frames(3)
	Shockwave.launch(_world, Vector2(100, 200), Vector2.RIGHT, null, 24.0, 300.0, 300.0, 12.0)
	await seconds(1.0)
	check(is_equal_approx(player.stats.health, 76.0), "sem cobertura, a onda acerta (vida=%s)" % player.stats.health)
	player.stats.revive()
	player.hurtbox.invulnerable = true  # i-frames (dash): a onda passa sem machucar
	Shockwave.launch(_world, Vector2(100, 200), Vector2.RIGHT, null, 24.0, 300.0, 300.0, 12.0)
	await seconds(1.0)
	check(is_equal_approx(player.stats.health, 100.0), "dash (i-frames) atravessa a onda")


func test_aldir_phase_1() -> void:
	var player := spawn_player(Vector2(300, 182))
	var aldir := spawn_aldir(Vector2(300, 150))
	await frames(2)
	check(aldir.kneel_sprite.visible and not aldir.body_sprite.visible, "ajoelhado diante do martelo antes da luta")
	check(aldir.hurtbox.invulnerable and not aldir.is_targetable(), "intocável antes da luta")
	aldir.enter_arena(Vector2.ZERO)
	aldir.start_fight()
	check(aldir.body_sprite.visible and aldir.mode == AldirCornelios.Mode.RISING, "levanta quando a luta começa")
	check(aldir.phase_label().contains("Soldado"), "barra mostra a fase 1: %s" % aldir.phase_label())
	check(aldir.armor_ratio() < 0.0, "Aldir não usa barra de armadura")
	player.set_physics_process(false)
	# Martelada: aviso redondo no chão, dano pesado, fase 1 não abre buraco.
	aldir._queue_combo([aldir.martelada])
	await frames(10)
	check(aldir.telegraph.circle_visible, "a martelada avisa onde vai bater (círculo no chão)")
	var hit := await wait_for(func(): return aldir._runner.phase == AttackRunner.Phase.RECOVERY, 120)
	check(hit, "a martelada chega à recuperação")
	check(is_equal_approx(player.stats.health, 66.0), "martelada tira 34 (vida=%s)" % player.stats.health)
	check(get_tree().get_nodes_in_group("pits").is_empty(), "fase 1: a martelada racha o chão, mas não abre buraco")
	# Golpe Sísmico: abre um buraco e solta a onda, que a cobertura segura.
	player.stats.revive()
	player.global_position = Vector2(300, 260)
	aldir.global_position = Vector2(300, 100)
	var cover := add_cover(Vector2(300, 196))
	await frames(2)
	aldir._queue_combo([aldir.sismico])
	await frames(20)
	check(aldir.telegraph.line_visible, "o Golpe Sísmico mostra a linha da onda")
	await seconds(1.8)
	check(get_tree().get_nodes_in_group("pits").size() == 1, "o Golpe Sísmico abre um buraco")
	check(is_equal_approx(player.stats.health, 100.0), "atrás da cobertura a onda não acerta (vida=%s)" % player.stats.health)
	check(cover.health < cover.max_health and not cover.broken, "a cobertura segura e só racha um pouco (%.0f)" % cover.health)
	check(aldir.cover_damage_multiplier() < 1.0, "fase 1: ele 'ainda pensa' (mal arranha coberturas)")


func test_aldir_phase_2() -> void:
	var player := spawn_player(Vector2(300, 300))
	var aldir := spawn_aldir(Vector2(300, 150))
	var cover := add_cover(Vector2(200, 250))
	await frames(2)
	aldir.enter_arena(Vector2.ZERO)
	aldir.start_fight()
	player.set_physics_process(false)
	player.hurtbox.invulnerable = true
	var won := [false]
	var phases: Array[String] = []
	aldir.fight_won.connect(func(_b): won[0] = true)
	aldir.phase_changed.connect(func(text: String): phases.append(text))
	aldir.hurtbox.receive_hit(HitInfo.create(330.0, player.global_position, aldir.global_position))
	check(aldir.phase == 2 and aldir.mode == AldirCornelios.Mode.TRANSITION, "metade da vida: fase 2 (O Caos)")
	check(aldir.eyes.visible, "olhos em brasa na fase 2")
	check(aldir.hurtbox.invulnerable, "invulnerável durante a transição")
	await seconds(2.6)
	check(aldir.mode != AldirCornelios.Mode.TRANSITION and not aldir.hurtbox.invulnerable, "a luta segue depois da transição")
	check(cover.broken, "a terceira martelada da transição derruba as coberturas")
	check(get_tree().get_nodes_in_group("pits").size() >= 2, "a transição abre buracos na arena")
	check(aldir.cover_damage_multiplier() > 1.0, "fase 2: destrói o cenário")
	check(phases.size() == 1 and phases[0].contains("Caos"), "fase anunciada: %s" % [phases])
	# Salto: cai onde o herói estava, abre buraco e solta ondas em cruz.
	var pits_before := get_tree().get_nodes_in_group("pits").size()
	aldir._start_leap()
	var landed := await wait_for(func(): return aldir.mode == AldirCornelios.Mode.LEAP and aldir._leap_stage == AldirCornelios.LeapStage.LAND, 180)
	check(landed, "o salto aterrissa")
	# (cai em cima do herói: os corpos se empurram, por isso a folga)
	check(aldir.global_position.distance_to(player.global_position) < 20.0, "aterrissa no ponto marcado (%.0f px)" % aldir.global_position.distance_to(player.global_position))
	check(get_tree().get_nodes_in_group("pits").size() > pits_before, "a aterrissagem abre um buraco")
	await seconds(1.4)
	# Investida: quebra a cobertura no caminho e fica tonto ao bater na parede.
	# (Os buracos da transição caem em lugares SORTEADOS; um deles no caminho
	# encerraria a investida antes da parede. Teste não pode depender da sorte.)
	for pit in get_tree().get_nodes_in_group("pits"):
		(pit as ArenaPit).fill()
	aldir.global_position = Vector2(150, 250)
	player.global_position = Vector2(260, 250)
	var cover_2 := add_cover(Vector2(220, 256))
	add_wall(Rect2(330, 150, 20, 200))
	await frames(2)
	aldir._start_charge()
	await seconds(0.55)  # a direção trava em 70% do aviso (~0,47 s)
	player.global_position = Vector2(150, 360)  # sai da frente
	var stunned := await wait_for(func(): return aldir.mode == AldirCornelios.Mode.STUNNED, 120)
	check(stunned, "a investida termina na parede: tonto (janela de punição)")
	check(cover_2.broken, "a investida atravessa a cobertura")
	await seconds(1.4)
	# Vitória
	var memories := Game.memories
	aldir.stats.take_damage(99999.0)
	await frames(2)
	check(won[0] and aldir.dead, "vitória emitida")
	check(Game.memories >= memories + 1200, "1200 memórias")
	var pits_after := get_tree().get_nodes_in_group("pits").size()
	await seconds(4.0)
	check(not is_instance_valid(aldir), "o corpo se desfaz depois da vitória")
	check(get_tree().get_nodes_in_group("pits").size() == pits_after, "os buracos ficam: o cenário conta a luta")


func test_aldir_arena_and_gate() -> void:
	var entry := DialogueData.get_entry("portao_aldir")
	var actions: Array = []
	for option in entry.get("opcoes", []):
		actions.append(option.get("acao", ""))
	check(actions.has("entrar_aldir"), "o portão oferece atravessar")
	# Depois da vitória: arena sem chefe, sem névoa e com o martelo cravado.
	Game.defeated_bosses.append("aldir")
	var level := await open_level("res://scenes/world/arena_aldir.tscn", "porta")
	check(level.boss_arena.state == BossArena.State.DONE, "Aldir derrotado não volta")
	check(find_npc("martelo_aldir") != null, "o martelo fica na praça (memorial)")
	var fog_up := false
	for fog in level._fog_walls:
		fog_up = fog_up or fog.visible
	check(not fog_up, "sem névoa depois da vitória")
	level.queue_free()
	await frames(2)
	level = await open_level("res://scenes/world/cidade.tscn", "porta")
	check(find_npc("portao_aldir_aberto") != null, "o portão muda depois da vitória")
	level.queue_free()
	await frames(2)


# --- Prólogo: o Complexo das Cápsulas --------------------------------------------------

func spawn_child(at: Vector2, variant: int = 0) -> Crianca:
	var child := CHILD_SCENE.instantiate() as Crianca
	child.variant = variant
	child.position = at
	_world.add_child(child)
	return child


## Pula as frases de uma Narração em andamento (as cenas têm ~3 s por frase).
func skip_narration(root: Node, max_frames: int = 900) -> bool:
	for i in max_frames:
		var playing := false
		for node in root.get_children():
			if node is Narration and (node as Narration).is_playing():
				playing = true
				(node as Narration).skip()
		if not playing and i > 2:
			return true
		await frames(1)
	return false


## A brincadeira: chega, espeta (golpe fraco), foge rindo. Não morre: cai e
## levanta MENOR. Bater nela conta na escolha e não dá memória nenhuma.
func test_child_play_and_fall() -> void:
	var player := spawn_player(Vector2(200, 200))
	var child := spawn_child(Vector2(240, 200))
	await frames(2)
	var start_health := player.stats.health
	var saw := {"flee": false}
	var hurt := await wait_for(func():
		if child.ai == Crianca.AI.FLEE:
			saw["flee"] = true
		return player.stats.health < start_health, 360)
	check(hurt, "a criança chega e espeta o herói")
	check(start_health - player.stats.health <= 8.0, "golpe fraco (%.0f de dano)" % (start_health - player.stats.health))
	await wait_for(func():
		if child.ai == Crianca.AI.FLEE:
			saw["flee"] = true
		return saw["flee"], 120)
	check(saw["flee"], "depois de espetar, ela foge (pega-pega)")
	# Agora o herói bate: cada golpe conta, nenhuma memória.
	Game.memories = 0
	player._iframes_left = 99.0
	var guard := 0
	while not child.down and guard < 40:
		child.global_position = player.global_position + Vector2(14, 0)
		player.facing = Vector2.RIGHT
		await tap(&"attack")
		await seconds(0.35)
		guard += 1
	check(child.down, "com a vida zerada ela CAI (não some)")
	check(is_instance_valid(child) and child.is_inside_tree(), "...e continua lá")
	check(Game.criancas_feridas >= 2, "cada golpe conta (criancas_feridas=%d)" % Game.criancas_feridas)
	check(Game.memories == 0, "bater em criança não dá memórias (%d)" % Game.memories)
	check(not child.is_targetable() and not child.is_in_group("enemies"), "caída: a mira assistida ignora")
	var counted := Game.criancas_feridas
	child.hurtbox.receive_hit(HitInfo.create(10.0, player.global_position, child.global_position))
	check(Game.criancas_feridas == counted, "ninguém acerta quem está no chão")
	await seconds(child.down_time + 0.5)
	check(not child.down and child.is_in_group("enemies"), "levanta de novo")
	check(child.size_scale < 1.0, "...menor (regrediu: %.2f)" % child.size_scale)


func test_child_counter_only_player() -> void:
	var child := spawn_child(Vector2(300, 200))
	await frames(2)
	var info := HitInfo.create(5.0, Vector2(280, 200), child.global_position)  # sem fonte (cenário)
	child.hurtbox.receive_hit(info)
	check(Game.criancas_feridas == 0, "dano que não veio do herói não conta")
	var player := spawn_player(Vector2(100, 100))
	await frames(1)
	var by_player := HitInfo.create(5.0, player.global_position, child.global_position)
	by_player.source = player
	child.hurtbox.receive_hit(by_player)
	check(Game.criancas_feridas == 1, "golpe do herói conta (%d)" % Game.criancas_feridas)


func spawn_governess(at: Vector2 = Vector2(300, 160)) -> Governanta:
	var gov := GOVERNESS_SCENE.instantiate() as Governanta
	gov.position = at
	_world.add_child(gov)
	gov.arena_rect = Rect2(60, 40, 480, 300)
	return gov


func test_governess_attacks() -> void:
	var player := spawn_player(Vector2(250, 160))
	var gov := spawn_governess()
	await frames(2)
	check(gov.mode == Governanta.Mode.SEATED and gov.seated.visible, "começa sentada")
	await frames(3)
	check(gov.watching, "herói perto: ela levanta os olhos (só observa)")
	gov.enter_arena(Vector2.ZERO)
	var risen := await wait_for(func(): return gov.body_sprite.visible, 60)
	await seconds(1.0)
	check(risen and gov.visual.scale.x > 1.2, "levanta e cresce (maior que tudo até ali: %.2f)" % gov.visual.scale.x)
	await seconds(0.6)
	gov.start_fight()
	await frames(2)
	# Grito: quem fica parado na faixa do anel apanha.
	player.global_position = gov.global_position + Vector2(-50, 0)
	var before := player.stats.health
	gov._start_scream()
	await seconds(0.3)
	check(gov.telegraph.circle_visible, "o grito avisa (círculo no chão)")
	await seconds(1.2)
	check(player.stats.health < before, "o anel acerta quem ficou parado (%.0f → %.0f)" % [before, player.stats.health])
	gov._go_decide(99.0)  # quieta: daqui em diante o teste escolhe os golpes
	await wait_for(func():
		for node in _world.get_children():
			if node is ScreamRing:
				return false
		return true, 120)
	# Atravessar o anel com o dash (i-frames) = nenhum dano.
	await seconds(0.5)
	player.stats.revive()
	player._iframes_left = 0.0
	player.global_position = gov.global_position + Vector2(-50, 0)
	await frames(2)
	before = player.stats.health
	gov._start_scream()
	var crossed := await wait_for(func(): return gov.mode == Governanta.Mode.SCREAM and gov._scream_stage == Governanta.ScreamStage.RECOVER, 90)
	check(crossed, "o grito sai")
	await seconds(0.12)  # o anel chega perto (raio ~28 px)
	Input.action_press(&"move_right")
	await tap(&"dash")
	Input.action_release(&"move_right")
	await seconds(1.0)
	check(is_equal_approx(player.stats.health, before), "dash ATRAVÉS do anel não leva dano (%.0f → %.0f)" % [before, player.stats.health])
	# Abraço: linha vermelha que trava antes do avanço.
	gov._go_decide(0.0)
	player.global_position = gov.global_position + Vector2(-70, 0)
	gov._queue_combo([gov.abraco])
	await seconds(0.2)
	check(gov.telegraph.line_visible, "o abraço avisa com a linha no chão")
	await seconds(2.0)
	# Fase 2: o coque se desfaz e ela chama os ecos.
	gov.stats.take_damage(gov.stats.max_health * 0.55)
	gov._on_damaged(0.0, HitInfo.new(), false)
	check(gov.phase == 2 and gov.body_sprite.sprite_frames == Governanta.LOOSE_FRAMES, "fase 2: cabelo solto")
	await seconds(1.8)
	gov._start_call()
	await frames(2)
	var echoes := 0
	for node in _world.get_children():
		if node is EchoChild:
			echoes += 1
	check(echoes == gov.echo_count, "ela chama %d ecos (%d)" % [gov.echo_count, echoes])
	await seconds(2.4)
	var left := 0
	for node in _world.get_children():
		if node is EchoChild:
			left += 1
	check(left == 0, "os ecos somem sozinhos (%d)" % left)


func test_prologue_peaceful() -> void:
	Game.wake_from_capsule = true
	var level := await open_level(PROLOGO, "camara") as Prologo
	check(level.player.state == Player.State.LOCKED, "o jogo começa saindo da cápsula (herói travado)")
	var free := await wait_for(func(): return level.player.state == Player.State.FREE, 240)
	check(free, "depois de sair da cápsula, o controle volta")
	check(not Game.wake_from_capsule, "a cena de acordar roda uma vez só")
	# Sem nenhuma criança ferida: ela só observa, sem luta e sem diálogo.
	var gov := level.governess
	level.player.global_position = gov.global_position + Vector2(40, 60)
	await seconds(0.6)
	check(level.boss_arena.state == BossArena.State.IDLE, "0 crianças feridas: a arena não arma")
	check(gov.mode == Governanta.Mode.SEATED and gov.watching, "ela só levanta os olhos")
	check(find_npc("governanta") == null, "sem diálogo (nada para conversar)")
	# A porta abre quando o herói chega perto.
	level.player.global_position = level.exit_door.global_position + Vector2(0, 14)
	var opened := await wait_for(func(): return level.exit_door.is_open, 30)
	check(opened, "a porta de saída abre")
	# Passando pela porta, o chão some.
	level.player.global_position = level.exit_door.global_position + Vector2(0, -36)
	var falling := await wait_for(func(): return level.is_falling(), 30)
	check(falling, "o chão some depois da porta")
	await seconds(1.8)
	check(level.player._plunging, "o herói cai (sem borda para voltar)")
	var done := await skip_narration(level)
	check(done, "a narração da queda termina")
	await frames(3)
	check(Game.prologue_done and Game.spared_child, "prólogo feito, criança poupada")
	check(Game.rest_scene == Game.HUB_SCENE and Game.last_scene_request == Game.HUB_SCENE, "acorda no Teatro (%s)" % Game.last_scene_request)
	check(Game.wake_from_capsule, "...saindo da cápsula do Teatro")
	level.queue_free()
	await frames(2)
	# No Teatro, a Criança Poupada aparece.
	Game.wake_from_capsule = false
	var teatro := await open_level("res://scenes/world/teatro.tscn", "camara")
	check(find_npc(Level.SPARED_CHILD_TALKS) != null, "a Criança Poupada está no Teatro")
	teatro.queue_free()
	await frames(2)


func test_prologue_governess_fight() -> void:
	Game.criancas_feridas = 2
	var level := await open_level(PROLOGO, "camara") as Prologo
	var gov := level.governess
	level.player._iframes_left = 9999.0  # o teste é do fluxo, não da luta
	level.player.global_position = gov.global_position + Vector2(40, 90)
	await frames(3)
	check(level.boss_arena.state != BossArena.State.IDLE, "1+ crianças feridas: ela se levanta")
	check(level.exit_door.locked, "a porta tranca")
	var fighting := await wait_for(func(): return level.boss_arena.state == BossArena.State.FIGHTING, 240)
	check(fighting, "a luta começa")
	var fog_solid := true
	for fog in level._fog_walls:
		fog_solid = fog_solid and fog.visible and not fog.shape.disabled
	check(fog_solid, "a névoa fecha o refeitório")
	check(level.hud._boss_bar.visible, "barra de chefe: A Governanta")
	var memories := Game.memories
	gov.stats.take_damage(gov.stats.max_health * 0.6)
	gov._on_damaged(0.0, HitInfo.new(), false)
	await seconds(1.8)
	gov.stats.take_damage(99999.0)
	var won := await wait_for(func(): return level.boss_arena.state == BossArena.State.DONE, 60)
	check(won and Game.is_boss_defeated("governanta"), "vitória registrada")
	check(Game.memories >= memories + 250, "ela dá memórias (%d)" % (Game.memories - memories))
	# A lembrança: ecos em volta da mesa vazia, com o texto da Bíblia.
	var memory := await wait_for(func():
		for node in level.get_children():
			if node is Narration:
				return true
		return false, 400)
	check(memory, "a lembrança dela começa")
	await seconds(0.5)
	check(level._echoes.size() == 6 and level._governess_echo != null, "ecos sentados à mesa (%d)" % level._echoes.size())
	await skip_narration(level)
	await seconds(1.5)
	check(level._echoes.is_empty(), "no fim, restaram apenas ecos... e uma mesa vazia")
	check(not level.exit_door.locked, "a porta destranca depois da lembrança")
	check(level.player.state == Player.State.FREE, "o controle volta")
	level.queue_free()
	await frames(2)
	# Voltando ao prólogo (ex.: morreu depois): ela não está mais lá.
	level = await open_level(PROLOGO, "camara") as Prologo
	check(level.boss_arena.state == BossArena.State.DONE and not is_instance_valid(level.boss_arena.boss), "a cadeira dela fica vazia")
	check(not level.exit_door.locked, "porta livre")
	level.queue_free()
	await frames(2)


func test_save_v2_migration() -> void:
	# Save da 0.4.0 (versão 1): o jogo dele já começou no Teatro.
	Game._from_dict({"version": 1, "memories": 300, "rest_scene": "res://scenes/world/cidade.tscn", "rest_spawn": "camara"})
	check(Game.prologue_done, "save v1 → prólogo conta como feito")
	check(Game.criancas_feridas == 0 and not Game.spared_child, "v1: sem escolha registrada")
	check(Game.rest_scene == "res://scenes/world/cidade.tscn", "v1: continua de onde parou")
	# Versão 2: a escolha vai e volta pelo save.
	Game.reset_progress()
	Game.criancas_feridas = 3
	Game.prologue_done = false
	var data := Game._to_dict()
	check(int(data["version"]) == 3, "save atual é a versão 3")
	Game.reset_progress()
	Game._from_dict(data)
	check(Game.criancas_feridas == 3 and not Game.prologue_done, "criancas_feridas e prólogo voltam do save")
	check(Game.rest_scene == Game.START_SCENE, "no meio do prólogo, renasce na cápsula do prólogo")


func test_new_game_starts_prologue() -> void:
	Game.criancas_feridas = 4
	Game.new_game()
	check(Game.last_scene_request == Game.START_SCENE and Game.START_SCENE.contains("prologo"), "Novo jogo abre o Prólogo")
	check(Game.pending_spawn == "camara" and Game.wake_from_capsule, "...saindo da cápsula")
	check(Game.criancas_feridas == 0, "...com a escolha zerada")
	Game.session_active = false
	Game.wake_from_capsule = false
	Game.delete_save()


## Hitstop curto + câmera lenta longa: vale o mais lento ENQUANTO durar; depois
## o outro assume. (Antes, o golpe final congelava o jogo pela câmera lenta inteira.)
func test_fx_time_effects_stack() -> void:
	var now := Time.get_ticks_msec()
	Fx._time_effects = [[0.05, now - 1], [0.25, now + 60000]]
	Fx._apply_time_scale()
	check(is_equal_approx(Engine.time_scale, 0.25), "hitstop acabou: a câmera lenta assume (%.2f)" % Engine.time_scale)
	check(Fx._time_effects.size() == 1, "efeito vencido sai da lista")
	Fx._time_effects.append([0.05, now + 60000])
	Fx._apply_time_scale()
	check(is_equal_approx(Engine.time_scale, 0.05), "dois ativos: vale o mais lento")
	Fx.clear_time_effects()
	check(Engine.time_scale == 1.0 and Fx._time_effects.is_empty(), "trocar de cena limpa tudo")
	# A pausa não abre por cima de uma cena curta.
	var level := await open_level(PROLOGO, "camara")
	level.begin_cutscene()
	check(not level.hud.can_pause(), "sem pausa durante a cena")
	level.end_cutscene()
	check(level.hud.can_pause(), "pausa volta depois da cena")
	level.queue_free()
	await frames(2)


# --- Cidade: Cão de Guerra, Atirador de Telhado, Civil Cinzento ---------------------------

func spawn_enemy_scene(scene: PackedScene, at: Vector2) -> Enemy:
	var enemy := scene.instantiate() as Enemy
	enemy.position = at
	_world.add_child(enemy)
	return enemy


## "Rápido, morde e recua."
func test_dog_bites_and_retreats() -> void:
	var player := spawn_player(Vector2(200, 200))
	var dog := spawn_enemy_scene(DOG_SCENE, Vector2(280, 200)) as CaoDeGuerra
	await frames(2)
	var start := player.stats.health
	var seen := {"circle": false, "retreat": false}
	var bitten := await wait_for(func():
		if dog.ai == CaoDeGuerra.AI.CIRCLE:
			seen["circle"] = true
		return player.stats.health < start, 400)
	check(seen["circle"], "ele rodeia antes do bote")
	check(bitten, "o bote morde")
	var retreated := await wait_for(func(): return dog.ai == CaoDeGuerra.AI.RETREAT, 60)
	check(retreated, "depois da mordida ele recua")
	check(dog.move_speed > player.move_speed, "mais rápido que o herói andando")


## Mira (linha que segue) → TRAVA → tiro lento. Sair da linha depois de travar = errou.
func test_sniper_aims_locks_and_shoots() -> void:
	var player := spawn_player(Vector2(140, 200))
	var sniper := spawn_enemy_scene(SNIPER_SCENE, Vector2(300, 200)) as AtiradorDeTelhado
	player._iframes_left = 0.0
	await frames(2)
	var aiming := await wait_for(func(): return sniper.ai == AtiradorDeTelhado.AI.AIM, 30)
	check(aiming and sniper.telegraph.line_visible, "ele mira (linha vermelha no chão)")
	check(not sniper.is_locked(), "no começo a mira ainda acompanha")
	var locked := await wait_for(func(): return sniper.is_locked(), 90)
	check(locked, "a mira TRAVA antes do tiro")
	player.global_position = Vector2(140, 150)  # sai da linha depois da trava
	var before := player.stats.health
	var fired := await wait_for(func(): return sniper.ai == AtiradorDeTelhado.AI.RELOAD, 60)
	check(fired, "atira e recarrega")
	await seconds(1.6)
	check(is_equal_approx(player.stats.health, before), "saiu da linha depois da trava: o tiro erra")
	# Parado na linha: acerta.
	player.global_position = Vector2(140, 200)
	await wait_for(func(): return sniper.ai == AtiradorDeTelhado.AI.RELOAD, 240)
	await seconds(1.4)
	check(player.stats.health < before, "parado na linha, o tiro acerta (%.0f → %.0f)" % [before, player.stats.health])
	# Colado nele: coronhada em vez de tiro.
	player.global_position = sniper.global_position + Vector2(-16, 0)
	var meleed := await wait_for(func(): return sniper.ai == AtiradorDeTelhado.AI.MELEE, 150)
	check(meleed, "colado nele, só sobra a coronhada")
	check(sniper.global_position.distance_to(sniper.home_position) < 30.0, "ele não sai do posto")


func test_projectile_walls_and_dash() -> void:
	var player := spawn_player(Vector2(300, 200))
	await frames(2)
	add_wall(Rect2(240, 150, 12, 100))
	var hp := player.stats.health
	var shot := Projectile.launch(_world, Vector2(150, 200), Vector2.RIGHT, null, 16.0, 300.0, 320.0)
	await seconds(0.8)
	check(not is_instance_valid(shot) and is_equal_approx(player.stats.health, hp), "a parede segura o tiro")
	# Sem parede, com i-frames (dash): o tiro passa por dentro.
	player.global_position = Vector2(300, 320)
	player._iframes_left = 1.0
	var through := Projectile.launch(_world, Vector2(150, 320), Vector2.RIGHT, null, 16.0, 300.0, 320.0)
	await seconds(1.3)
	check(is_equal_approx(player.stats.health, hp), "com i-frames o tiro passa direto")
	check(not is_instance_valid(through), "e some ao fim do alcance")
	player._iframes_left = 0.0
	Projectile.launch(_world, Vector2(150, 320), Vector2.RIGHT, null, 16.0, 300.0, 320.0)
	await seconds(0.7)
	check(player.stats.health < hp, "sem i-frames, acerta")


## "Passivo; só ataca se for atacado ou se o jogador passar correndo."
func test_civilian_passive_and_provoked() -> void:
	var player := spawn_player(Vector2(100, 200))
	var civil := spawn_enemy_scene(CIVIL_SCENE, Vector2(150, 200)) as CivilCinzento
	await frames(3)
	check(civil.ai == CivilCinzento.AI.WARY and not civil.is_hostile(), "herói perto e parado: ele só observa")
	check(not civil.is_targetable(), "passivo não puxa a mira assistida")
	# Andando DEVAGAR colado nele: nada.
	player.set_physics_process(false)
	player.velocity = Vector2(40, 0)
	player.global_position = civil.global_position + Vector2(-20, 0)
	await frames(10)
	check(not civil.is_hostile(), "passar devagar não assusta")
	# Passar CORRENDO colado: assusta.
	player.velocity = Vector2(80, 0)
	await frames(3)
	check(civil.is_hostile() and civil.is_targetable(), "passar correndo colado: ele ataca")
	# Longe por um tempo: se acalma.
	player.velocity = Vector2.ZERO
	player.global_position = Vector2(400, 400)
	await seconds(civil.calm_time + 0.5)
	check(not civil.is_hostile(), "sem ninguém por perto, se acalma")
	# Dash por perto: assusta também.
	player.set_physics_process(true)
	player.global_position = civil.global_position + Vector2(-50, 0)
	await frames(2)
	Input.action_press(&"move_up")
	await tap(&"dash")
	Input.action_release(&"move_up")
	await frames(2)
	check(civil.is_hostile(), "dash perto dele: assusta")
	# Bater em um assusta os vizinhos.
	await seconds(civil.calm_time + 1.0)
	player.global_position = Vector2(600, 600)
	var neighbor := spawn_enemy_scene(CIVIL_SCENE, civil.global_position + Vector2(30, 0)) as CivilCinzento
	await seconds(civil.calm_time + 0.5)
	var hit := HitInfo.create(5.0, civil.global_position - Vector2(10, 0), civil.global_position)
	hit.source = player
	civil.hurtbox.receive_hit(hit)
	await frames(2)
	check(civil.is_hostile() and neighbor.is_hostile(), "apanhou: ele e quem está perto se assustam")


# --- Mini-chefes da Cidade -------------------------------------------------------------

func spawn_mini(scene: PackedScene, at: Vector2) -> MiniBoss:
	var mini := scene.instantiate() as MiniBoss
	mini.position = at
	_world.add_child(mini)
	return mini


## "Apita e chama reforços a cada 25% de vida perdida." Caiu o oficial → o pelotão desaba.
func test_sargento_whistles_and_platoon() -> void:
	var player := spawn_player(Vector2(200, 200))
	player._iframes_left = 9999.0
	var sarge := spawn_mini(SARGENTO_SCENE, Vector2(280, 200)) as SargentoSemPelotao
	var started := [false]
	sarge.fight_started.connect(func(_b): started[0] = true)
	await frames(3)
	check(started[0] and sarge.active, "acorda quando vê o herói (barra de chefe)")
	sarge.stats.take_damage(sarge.stats.max_health * 0.3)
	var whistled := await wait_for(func(): return sarge.summoned.size() == 2, 120)
	check(whistled, "perdeu 25%: apita e chama 2 soldados")
	sarge.stats.take_damage(sarge.stats.max_health * 0.25)
	var again := await wait_for(func(): return sarge.summoned.size() == 4, 120)
	check(again, "perdeu 50%: mais 2")
	var platoon := sarge.summoned.duplicate()
	var memories := Game.memories
	sarge.stats.take_damage(99999.0)
	await frames(2)
	var all_down := true
	for soldier in platoon:
		all_down = all_down and (not is_instance_valid(soldier) or soldier.dead)
	check(all_down, "caiu o oficial: o pelotão desaba")
	check(Game.memories == memories + 300, "só o Sargento dá memórias (%d)" % (Game.memories - memories))
	check(Game.is_boss_defeated("sargento"), "fica vencido (não volta)")


func test_miniboss_resets_when_player_flees() -> void:
	var player := spawn_player(Vector2(200, 200))
	player._iframes_left = 9999.0
	var sarge := spawn_mini(SARGENTO_SCENE, Vector2(280, 200)) as SargentoSemPelotao
	var resets := [0]
	sarge.fight_reset.connect(func(_b): resets[0] += 1)
	await frames(3)
	sarge.stats.take_damage(40.0)
	player.global_position = Vector2(900, 900)
	await seconds(sarge.reset_time + 0.5)
	check(resets[0] == 1 and not sarge.active, "herói fugiu: ele desiste")
	check(is_equal_approx(sarge.stats.health, sarge.stats.max_health), "volta com a vida cheia")
	check(not sarge.is_in_group("enemies"), "fora da luta não é alvo")


## "Só leva dano real pelas costas." Vira devagar; quem cola nas costas leva o giro.
func test_couraca_back_only() -> void:
	var player := spawn_player(Vector2(200, 200))
	player._iframes_left = 9999.0
	var armor := spawn_mini(COURACA_SCENE, Vector2(240, 200)) as CouracaAndante
	await frames(3)
	check(armor.active, "acorda")
	armor.facing = Vector2.LEFT  # de frente para o herói
	var hp := armor.stats.health
	armor.hurtbox.receive_hit(HitInfo.create(40.0, Vector2(200, 200), armor.global_position))
	var front := hp - armor.stats.health
	check(front < 5.0, "de frente quase nada passa (%.1f)" % front)
	hp = armor.stats.health
	armor.facing = Vector2.LEFT
	armor.hurtbox.receive_hit(HitInfo.create(40.0, Vector2(290, 200), armor.global_position))
	check(is_equal_approx(hp - armor.stats.health, 40.0), "pelas costas: dano cheio (%.1f)" % (hp - armor.stats.health))
	# Vira devagar: meio segundo depois ainda não está de frente para quem foi para trás.
	armor._cooldown = 99.0
	armor.mode = CouracaAndante.Mode.TURN
	armor.facing = Vector2.LEFT
	player.global_position = armor.global_position + Vector2(30, 0)
	await seconds(0.5)
	check(armor.is_behind(player.global_position) or armor.angle_to_point(player.global_position) > 60.0, "ele vira devagar (a brecha)")
	# Colado nas costas tempo demais: o giro (com aviso de círculo).
	armor._cooldown = 0.0
	armor.turn_speed = 0.0
	armor.facing = Vector2.LEFT
	var spun := await wait_for(func(): return armor.mode == CouracaAndante.Mode.ATTACK and armor._current_attack == armor.giro, 150)
	check(spun, "quem fica nas costas leva o giro")
	await frames(2)
	check(armor.telegraph.circle_visible, "o giro avisa com o círculo")




# --- Sistemas: inventário, Ferreiro, Orbe, escudo -------------------------------------

func test_inventory_and_save_v3() -> void:
	var announced := []
	var listener := func(id: String, count: int): announced.append([id, count])
	Game.item_added.connect(listener)
	check(Game.add_item("sucata_temperada", 3) == 3 and Game.item_count("sucata_temperada") == 3, "guarda 3 sucatas")
	check(announced.size() == 1 and announced[0] == ["sucata_temperada", 3], "anuncia o ganho para o HUD (%s)" % [announced])
	Game.add_item("escudo_remendado")
	check(Game.add_item("escudo_remendado") == 0 and Game.item_count("escudo_remendado") == 1, "item único não empilha (max_stack 1)")
	check(Game.shield_ready(), "pegou o escudo: já vai para a mão esquerda")
	check(not Game.remove_item("sucata_temperada", 5) and Game.item_count("sucata_temperada") == 3, "remover mais do que tem não tira nada")
	check(Game.remove_item("sucata_temperada", 2) and Game.item_count("sucata_temperada") == 1, "remove 2")
	Game.item_added.disconnect(listener)
	# Recompensa de chefe: só na PRIMEIRA vitória.
	Game.mark_boss_defeated("couraca")
	Game.mark_boss_defeated("couraca")
	check(Game.item_count("fragmento_turvo") == 1 and Game.item_count("sucata_temperada") == 4, "Couraça deixa 1 fragmento e 3 sucatas, uma vez só")
	# Ida e volta pelo save.
	Game.weapon_level = 2
	Game.collect_pickup("cidade@13,3")
	Game.set_shield_equipped(false)
	var data := Game._to_dict()
	Game.reset_progress()
	Game._from_dict(data)
	check(Game.item_count("sucata_temperada") == 4 and Game.has_shield() and not Game.shield_ready(), "inventário e escudo guardado voltam do save")
	check(Game.weapon_level == 2 and Game.is_pickup_collected("cidade@13,3"), "nível da arma e itens pegos voltam do save")
	# Item que não existe mais (versão futura) não quebra o save.
	data["inventory"]["item_que_nao_existe"] = 5
	Game._from_dict(data)
	check(not Game.inventory.has("item_que_nao_existe"), "item desconhecido é ignorado ao carregar")
	# MIGRAÇÃO v2 → v3: chefes vencidos antes do inventário pagam o que devem.
	Game._from_dict({"version": 2, "defeated_bosses": ["aldir", "sargento"], "prologue_done": true})
	check(Game.item_count("fragmento_turvo") == 2 and Game.item_count("sucata_temperada") == 6, "v2: Aldir e Sargento entregam fragmentos e sucata")
	check(Game.has_item("lembranca_aldir") and Game.has_item("apito_sargento"), "v2: lembranças entregues")


func test_smith_upgrade() -> void:
	check(Game.upgrade_block_reason() == "memories", "sem memórias: não melhora")
	Game.memories = 250
	check(Game.upgrade_block_reason() == "sucata", "sem sucata: não melhora")
	Game.add_item("sucata_temperada", 2)
	check(Game.upgrade_block_reason() == "", "250 memórias + 2 sucatas: pode")
	check(Game.try_upgrade_weapon() and Game.weapon_level == 1, "+1")
	check(Game.memories == 0 and Game.item_count("sucata_temperada") == 0, "pagou tudo")
	check(not Game.try_upgrade_weapon() and Game.weapon_level == 1, "sem recursos: nada muda")
	# O dano sobe de verdade no golpe.
	var player := spawn_player(Vector2(200, 200))
	var dummy := DUMMY_SCENE.instantiate() as TrainingDummy
	dummy.position = Vector2(220, 200)
	_world.add_child(dummy)
	var hits := []
	dummy.hurtbox.hit_received.connect(func(info: HitInfo): hits.append(info.damage))
	await frames(2)
	Game.weapon_level = 0
	player.facing = Vector2.RIGHT
	await tap(&"attack")
	await seconds(1.0)  # longe da janela de combo: o próximo é o 1º golpe de novo
	Game.weapon_level = 2
	await tap(&"attack")
	await seconds(1.0)
	check(hits.size() == 2 and is_equal_approx(hits[1] / hits[0], 1.24), "+2 = +24%% de dano (%s)" % [hits])
	# Teto: sem Durgan, o Ferreiro para no +3.
	Game.weapon_level = 3
	Game.memories = 99999
	Game.add_item("sucata_temperada", 50)
	check(Game.upgrade_block_reason() == "cap", "+3 é o teto antes de Durgan")
	Game.defeated_bosses.append("durgan")
	check(Game.upgrade_block_reason() == "" and Game.try_upgrade_weapon() and Game.weapon_level == 4, "depois de Durgan, o Ferreiro vai além")
	Game.weapon_level = 5
	check(Game.upgrade_block_reason() == "max", "+5 é o máximo")
	# Pelo menu da forja, no Teatro.
	player.queue_free()
	Game.reset_progress()
	Game.memories = 300
	Game.add_item("sucata_temperada", 2)
	var level := await open_level("res://scenes/world/teatro.tscn", "camara")
	check(find_npc("ferreiro,ferreiro_forja") != null, "Ferreiro no Teatro com as duas falas")
	level._on_dialogue_action("melhorar_arma")
	await frames(2)
	check(level.hud.smith_menu.visible and not level.hud.smith_menu._upgrade_button.disabled, "forja aberta, botão Melhorar ativo")
	level.hud.smith_menu._upgrade_button.pressed.emit()
	await frames(1)
	check(Game.weapon_level == 1 and Game.memories == 50, "melhorou pela forja (nível %d, memórias %d)" % [Game.weapon_level, Game.memories])
	check(level.hud.smith_menu._upgrade_button.disabled, "sem recursos: botão desativa")
	level.hud.smith_menu._close_button.pressed.emit()
	await frames(2)
	check(not level.hud.smith_menu.visible, "Sair fecha a forja")
	level.queue_free()
	await frames(2)


func test_orb_purifies_fragments() -> void:
	var level := await open_level("res://scenes/world/teatro.tscn", "camara")
	check(level._dialogue_variant("orbe") == "orbe", "sem fragmento: fala normal do Orbe")
	Game.add_item("fragmento_turvo", 2)
	check(level._dialogue_variant("orbe") == "orbe_purificar", "com fragmento: o Orbe oferece purificar")
	var entry := DialogueData.get_entry("orbe_purificar")
	check(entry.get("opcoes", []).size() == 2, "fala de purificar tem as opções")
	var flasks := level.player.health_flasks
	await level._on_dialogue_action("purificar")
	check(Game.health_flasks_max == 4 and level.player.health_flasks_max == 4, "fragmento → 4 frascos")
	check(level.player.health_flasks == flasks + 1, "o frasco novo já vem cheio")
	check(Game.item_count("fragmento_turvo") == 1, "gastou um fragmento")
	Game.health_flasks_max = Game.MAX_HEALTH_FLASKS
	check(level._dialogue_variant("orbe") == "orbe_cheio" and not Game.purify_fragment(), "no teto de frascos o Orbe recusa")
	level.queue_free()
	await frames(2)


func test_pickups_and_drops() -> void:
	var level := await open_level("res://scenes/world/cidade.tscn", "porta")
	var pickups: Array[ItemPickup] = []
	for node in level.entities.get_children():
		if node is ItemPickup:
			pickups.append(node)
	check(pickups.size() == 4, "4 itens no chão da Cidade (%d)" % pickups.size())
	var shield: ItemPickup = null
	for pickup in pickups:
		if pickup.item_id == "escudo_remendado":
			shield = pickup
	check(shield != null and shield.persist_key == "cidade@13,3", "escudo perto da entrada (%s)" % (shield.persist_key if shield else "?"))
	level.player.global_position = shield.global_position
	await frames(4)
	check(Game.shield_ready() and Game.is_pickup_collected("cidade@13,3"), "encostou: pegou e equipou o escudo")
	level.queue_free()
	await frames(2)
	level = await open_level("res://scenes/world/cidade.tscn", "porta")
	var left := 0
	for node in level.entities.get_children():
		if node is ItemPickup:
			left += 1
			check((node as ItemPickup).item_id != "escudo_remendado", "o escudo não volta")
	check(left == 3, "sobram 3 itens (%d)" % left)
	level.queue_free()
	await frames(2)
	# Drop de inimigo.
	var player := spawn_player(Vector2(100, 100))
	var soldier := SOLDIER_SCENE.instantiate() as SoldadoRemendado
	soldier.position = Vector2(220, 200)
	soldier.drop_chance = 1.0
	_world.add_child(soldier)
	await frames(2)
	soldier.stats.take_damage(9999.0)
	await seconds(0.5)
	var drop: ItemPickup = null
	for node in _world.get_children():
		if node is ItemPickup:
			drop = node
	check(drop != null and drop.item_id == "sucata_temperada" and drop.persist_key == "", "soldado deixa sucata (drop sem chave de save)")
	if drop:
		player.global_position = drop.global_position
		await frames(4)
	check(Game.item_count("sucata_temperada") == 1, "pegou a sucata do chão")


func test_shield_block() -> void:
	var player := spawn_player(Vector2(200, 200))
	await frames(2)
	Input.action_press(&"block")
	await frames(3)
	check(player.state == Player.State.FREE, "sem escudo, segurar defesa não faz nada")
	Input.action_release(&"block")
	Game.add_item("escudo_remendado")
	await frames(2)
	check(player.shield_sprite.visible, "escudo aparece no braço")
	player.facing = Vector2.RIGHT
	Input.action_press(&"block")
	await frames(3)
	check(player.state == Player.State.BLOCK, "segurou: escudo erguido")
	check(is_equal_approx(player.stats.regen_scale, player.block_regen_multiplier), "erguido regenera devagar")
	# Golpe pela frente: raspão + estamina.
	var blocked := []
	player.blocked.connect(func(info: HitInfo): blocked.append(info))
	var hp := player.stats.health
	var stamina := player.stats.stamina
	player.hurtbox.receive_hit(HitInfo.create(20.0, Vector2(230, 200), player.global_position))
	await frames(1)
	check(blocked.size() == 1 and player.state == Player.State.BLOCK, "frente: segurou e continua defendendo")
	check(is_equal_approx(hp - player.stats.health, 3.0), "passa só 15%% do dano (%.1f)" % (hp - player.stats.health))
	check(is_equal_approx(stamina - player.stats.stamina, 22.0), "custa estamina (%.1f)" % (stamina - player.stats.stamina))
	# Por trás: dano cheio.
	player.stats.revive()
	player.hurtbox.invulnerable = false
	player.facing = Vector2.RIGHT
	hp = player.stats.health
	player.hurtbox.receive_hit(HitInfo.create(20.0, Vector2(170, 200), player.global_position))
	await frames(1)
	check(is_equal_approx(hp - player.stats.health, 20.0) and player.state == Player.State.STAGGER, "pelas costas o escudo não protege")
	await seconds(0.8)
	# Grito/onda/agarrão: passam por cima do escudo.
	player.stats.revive()
	player.facing = Vector2.RIGHT
	await frames(3)
	check(player.state == Player.State.BLOCK, "ergueu de novo")
	var scream := HitInfo.create(20.0, Vector2(230, 200), player.global_position)
	scream.unblockable = true
	hp = player.stats.health
	player.hurtbox.receive_hit(scream)
	await frames(1)
	check(is_equal_approx(hp - player.stats.health, 20.0), "golpe indefensável passa inteiro")
	await seconds(0.8)
	# Guarda quebrada: sem estamina para segurar.
	player.stats.revive()
	player.facing = Vector2.RIGHT
	await frames(3)
	var broken := []
	player.guard_broken.connect(func(): broken.append(true))
	player.stats.drain_stamina(player.stats.stamina - 5.0)
	player.stats.is_exhausted = false
	hp = player.stats.health
	player.hurtbox.receive_hit(HitInfo.create(20.0, Vector2(230, 200), player.global_position))
	await frames(1)
	check(broken.size() == 1 and player.state == Player.State.STAGGER, "sem estamina: guarda quebra")
	check(player.stats.is_exhausted and is_equal_approx(hp - player.stats.health, 10.0), "quebra = Exaustão + metade do dano")
	await seconds(0.6)
	check(player.state == Player.State.STAGGER, "cambaleio longo (0,9 s)")
	await seconds(0.5)
	# A bala do Atirador: o escudo se vira sozinho para ela e segura.
	Input.action_release(&"block")
	player.stats.revive()
	player.stats.is_exhausted = false
	player.facing = Vector2.LEFT
	await frames(2)
	Input.action_press(&"block")
	await frames(2)
	blocked.clear()
	Projectile.launch(_world, Vector2(290, 200), Vector2.LEFT, null, 16.0, 150.0, 320.0)
	await seconds(1.0)
	check(blocked.size() == 1, "o escudo virou para a bala e segurou")
	check(player.facing.x > 0.9, "virado para a direita, de onde veio a bala (%s)" % player.facing)
	Input.action_release(&"block")
	await frames(2)
	check(player.state == Player.State.FREE and is_equal_approx(player.stats.regen_scale, 1.0), "soltou: abaixa e volta a regenerar normal")
	# Guardado no inventário: some o escudo e o botão.
	var touch := TouchControls.new()
	_world.add_child(touch)
	await frames(1)
	check(touch.block_button.visible, "botão do escudo aparece com escudo equipado")
	Game.set_shield_equipped(false)
	await frames(1)
	check(not touch.block_button.visible and not player.shield_sprite.visible, "guardou o escudo: botão e sprite somem")
	Input.action_press(&"block")
	await frames(3)
	check(player.state == Player.State.FREE, "escudo guardado não ergue")


func test_inventory_menu() -> void:
	Game.add_item("sucata_temperada", 3)
	Game.add_item("escudo_remendado")
	Game.add_item("lembranca_aldir")
	var level := await open_level("res://scenes/world/teatro.tscn", "camara")
	var hud := level.hud
	hud.open_inventory()
	await frames(2)
	check(hud.inventory_menu.visible and get_tree().paused, "I/Tab: inventário abre e pausa")
	var ids := []
	for entry in hud.inventory_menu.entries():
		ids.append(entry["id"])
	check(ids == ["espada", "escudo_remendado", "frasco_vida", "frasco_sanidade", "sucata_temperada", "lembranca_aldir"], "lista agrupada: %s" % [ids])
	hud.inventory_menu._select("escudo_remendado")
	check(hud.inventory_menu._action_button.visible, "escudo tem botão de equipar/guardar")
	hud.inventory_menu._action_button.pressed.emit()
	await frames(1)
	check(not Game.shield_ready(), "guardou o escudo pelo menu")
	hud.inventory_menu._select("lembranca_aldir")
	check(hud.inventory_menu._detail_text.text.contains("impotência"), "lembrança mostra a lore")
	hud.propagate_notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	await frames(2)
	check(not hud.inventory_menu.visible and not get_tree().paused, "Voltar fecha o inventário e despausa")
	# Pela pausa: abre por cima e volta para a pausa.
	hud.pause_menu.open()
	hud.pause_menu._inventory_button.pressed.emit()
	await frames(2)
	check(hud.inventory_menu.visible and not hud.pause_menu.visible, "inventário pela pausa")
	hud.inventory_menu.close()
	await frames(2)
	check(hud.pause_menu.visible and get_tree().paused, "fechou: volta para a pausa")
	hud.pause_menu.close()
	await frames(1)
	check(not get_tree().paused, "pausa fechada")
	level.queue_free()
	await frames(2)



# --- Bosque do Sono Eterno ---------------------------------------------------------------

func test_drowsiness_and_sleep() -> void:
	var player := spawn_player(Vector2(200, 200))
	var asleep := []
	player.sleep_changed.connect(func(value: bool): asleep.append(value))
	await frames(2)
	player.add_drowsiness(50.0)
	check(is_equal_approx(player.drowsiness, 50.0), "barra sobe")
	await seconds(1.0)
	check(player.drowsiness > 38.0 and player.drowsiness < 44.0, "desce sozinha ~9/s (%.1f)" % player.drowsiness)
	var before := player.drowsiness
	player.facing = Vector2.RIGHT
	await tap(&"attack")
	check(player.drowsiness < before - 12.0, "golpe espanta o sono (%.1f → %.1f)" % [before, player.drowsiness])
	await seconds(0.6)
	player.add_drowsiness(200.0)
	check(player.state == Player.State.SLEEP and asleep == [true], "cheia: dorme")
	await tap(&"attack")
	await tap(&"dash")
	check(player.state == Player.State.SLEEP, "dormindo não obedece comandos")
	await seconds(2.6)
	check(player.state == Player.State.FREE and player.drowsiness == 0.0 and asleep == [true, false], "acorda sozinho em 2,5 s")
	player.add_drowsiness(30.0)
	check(player.drowsiness == 0.0, "respiro de 1,5 s depois de acordar")
	await seconds(1.6)
	# Golpe acorda.
	player.add_drowsiness(200.0)
	check(player.state == Player.State.SLEEP, "dormiu de novo")
	player.hurtbox.receive_hit(HitInfo.create(10.0, Vector2(230, 200), player.global_position))
	await frames(1)
	check(player.state == Player.State.STAGGER and asleep.back() == false, "levar golpe acorda")
	await seconds(1.8)
	# Nuvem de pólen: parado dentro enche; dash dentro não.
	player.stats.revive()
	var cloud := PollenCloud.spawn(_world, player.global_position, 34.0, 3.0)
	await seconds(1.0)
	check(player.drowsiness > 15.0, "dentro da nuvem a barra sobe (%.1f)" % player.drowsiness)
	player.drowsiness = 0.0
	player._start_dash()
	await frames(8)
	check(player.drowsiness == 0.0, "o dash prende a respiração")
	cloud.queue_free()


func test_noise() -> void:
	var player := spawn_player(Vector2(200, 200))
	await frames(3)
	check(player.noise == 0.0 and not player.is_heard_from(Vector2(210, 200)), "parado: silêncio")
	await tap(&"dash")
	check(player.noise >= 60.0 and player.is_heard_from(Vector2(250, 200)), "dash faz barulho (%.0f)" % player.noise)
	check(not player.is_heard_from(Vector2(320, 200)), "longe não ouve")
	await seconds(0.8)
	check(player.noise == 0.0, "o barulho some")
	Input.action_press(&"move_right", 0.4)
	await seconds(0.5)
	check(player.noise == 0.0, "andar devagar não faz barulho (vel %.0f)" % player.velocity.length())
	Input.action_release(&"move_right")
	Input.action_press(&"move_right", 1.0)
	await seconds(0.5)
	check(player.noise >= 40.0, "andar rápido faz barulho (%.0f)" % player.noise)
	Input.action_release(&"move_right")


func test_sleepwalker() -> void:
	var player := spawn_player(Vector2(200, 200))
	var sleeper := SLEEPER_SCENE.instantiate() as Sonambulo
	sleeper.position = Vector2(260, 200)
	_world.add_child(sleeper)
	await seconds(1.0)
	check(sleeper.ai == Sonambulo.AI.SLEEP and not sleeper.is_targetable(), "parado perto: ele dorme (e a mira ignora)")
	player.make_noise(80.0)
	await frames(2)
	check(sleeper.ai == Sonambulo.AI.SLEEPWALK and sleeper.noise_point.distance_to(player.global_position) < 2.0, "barulho: acorda e vai até o som")
	# O herói se afasta EM SILÊNCIO (teleporte = sem passos).
	player.global_position = Vector2(200, 300)
	var deadline := 10.0
	while sleeper.ai != Sonambulo.AI.SLEEP and deadline > 0.0:
		await seconds(0.25)
		deadline -= 0.25
	check(sleeper.ai == Sonambulo.AI.SLEEP, "chegou no som, não achou nada, voltou a dormir")
	check(sleeper.global_position.distance_to(sleeper.home_position) < 6.0, "dorme de novo no lugar dele")
	# Encostar acorda e ele ataca.
	player.global_position = sleeper.global_position + Vector2(-10, 0)
	var hp := player.stats.health
	await seconds(2.0)
	check(player.stats.health < hp, "encostou: ele acorda e agarra (vida %.0f→%.0f)" % [hp, player.stats.health])


func test_pollen_flower() -> void:
	var player := spawn_player(Vector2(200, 200))
	var flower := FLOWER_SCENE.instantiate() as FlorDePolen
	flower.position = Vector2(300, 200)
	_world.add_child(flower)
	await seconds(0.6)
	check(flower.ai == FlorDePolen.AI.IDLE, "longe: a flor fica aberta")
	player.global_position = Vector2(250, 200)
	await frames(3)
	check(flower.ai == FlorDePolen.AI.SWELL, "perto: incha (aviso)")
	await seconds(1.0)
	check(get_tree().get_nodes_in_group("pollen_clouds").size() == 1 and flower.ai == FlorDePolen.AI.CLOSED, "solta a nuvem e fecha")
	await seconds(3.2)
	# Cortar no meio do inchaço impede a nuvem.
	for cloud in get_tree().get_nodes_in_group("pollen_clouds"):
		cloud.queue_free()
	await frames(2)
	flower._set_ai(FlorDePolen.AI.SWELL)
	flower.poise = 1.0
	var info := HitInfo.create(10.0, player.global_position, flower.global_position)
	info.poise_damage = 20.0
	flower.hurtbox.receive_hit(info)
	await seconds(1.0)
	check(get_tree().get_nodes_in_group("pollen_clouds").is_empty() and flower.ai != FlorDePolen.AI.CLOSED, "cortada no aviso: não solta")


func test_deer_charge() -> void:
	var player := spawn_player(Vector2(300, 200))
	add_wall(Rect2(380, 120, 16, 160))
	var deer := DEER_SCENE.instantiate() as CervoDeMusgo
	deer.position = Vector2(160, 200)
	_world.add_child(deer)
	await seconds(0.5)
	check(deer.ai == CervoDeMusgo.AI.FROZEN and not deer.is_targetable(), "longe: congelado no meio do salto")
	player.global_position = Vector2(240, 200)
	await frames(3)
	check(deer.ai == CervoDeMusgo.AI.LAND, "perto: termina o salto")
	await seconds(0.5)
	check(deer.ai == CervoDeMusgo.AI.AIM, "mira (linha)")
	await seconds(0.65)
	check(deer.is_aim_locked() and deer.telegraph.line_locked, "a linha TRAVA antes da investida")
	var hp := player.stats.health
	await seconds(0.4)
	check(deer.ai == CervoDeMusgo.AI.CHARGE or deer.ai == CervoDeMusgo.AI.STUN, "investida")
	var deadline := 2.0
	while deer.ai != CervoDeMusgo.AI.STUN and deadline > 0.0:
		await frames(2)
		deadline -= 2.0 / 60.0
	check(player.stats.health < hp, "a investida acerta quem fica na linha")
	check(deer.ai == CervoDeMusgo.AI.STUN, "bateu na parede: tonto (ai=%s)" % CervoDeMusgo.AI.keys()[deer.ai])


func test_wither_fairy_heals() -> void:
	var player := spawn_player(Vector2(100, 100))
	var soldier := SOLDIER_SCENE.instantiate() as SoldadoRemendado
	soldier.position = Vector2(300, 220)
	_world.add_child(soldier)
	var fairy := WITHER_SCENE.instantiate() as FadaMurcha
	fairy.position = Vector2(320, 200)
	_world.add_child(fairy)
	await frames(2)
	soldier.set_physics_process(false)
	soldier.stats.take_damage(40.0)
	var hp := soldier.stats.health
	await seconds(3.0)
	check(soldier.stats.health > hp + 10.0, "a fada cura o ferido (%.0f → %.0f)" % [hp, soldier.stats.health])
	player.global_position = fairy.global_position + Vector2(-20, 0)
	await frames(3)
	check(fairy.ai == FadaMurcha.AI.FLEE, "chegou perto: ela foge")


func test_vigia_sneak_or_fight() -> void:
	var player := spawn_player(Vector2(200, 168))
	var vigia := VIGIA_SCENE.instantiate() as VigiaQueDormiu
	vigia.position = Vector2(300, 200)
	_world.add_child(vigia)
	var sneaked := []
	vigia.sneaked_past.connect(func(): sneaked.append(true))
	await frames(3)
	# Passa devagar pelo lado (sem barulho).
	for x in range(200, 400, 4):
		player.global_position = Vector2(x, 168)
		await frames(1)
	check(not vigia.active and Game.has_flag("vigia_evitado") and sneaked.size() == 1, "passou em silêncio: ele não acordou (marca salva)")
	# Outro "turno": barulho perto acorda.
	Game.flags.erase("vigia_evitado")
	player.global_position = Vector2(250, 200)
	await frames(2)
	await tap(&"dash")
	await frames(2)
	check(vigia.active, "dash perto: ele acorda e luta")
	check(not Game.has_flag("vigia_evitado"), "depois de acordá-lo, passar não conta")
	# Bocejo: anel de sono.
	player.global_position = vigia.global_position + Vector2(-60, 0)
	player._iframes_left = 0.0
	vigia._start_yawn()
	await seconds(vigia.yawn_inhale + 0.6)
	check(player.drowsiness > 30.0 or player.is_asleep(), "o bocejo dá sono (%.0f)" % player.drowsiness)
	# Fugiu: ele volta a dormir.
	player.global_position = vigia.home_position + Vector2(-400, 0)
	await seconds(3.0)
	check(not vigia.active, "fugiu: ele volta a dormir no posto")


func test_spore_mother() -> void:
	var player := spawn_player(Vector2(140, 200))
	var mae := MAE_SCENE.instantiate() as MaeDosEsporos
	mae.position = Vector2(240, 200)
	_world.add_child(mae)
	await frames(3)
	check(mae.active, "viu o herói: acorda")
	await seconds(4.5)
	check(mae.my_flowers.size() >= 1, "faz brotar flores (%d)" % mae.my_flowers.size())
	# Cipó na linha.
	mae._start_vine(false)
	var hp := player.stats.health
	await seconds(1.2)
	check(player.stats.health < hp, "o cipó acerta quem fica na linha")
	await seconds(0.8)
	# Dormiu perto dela: cipó pesado.
	player.stats.revive()
	player._iframes_left = 0.0
	player.global_position = mae.global_position + Vector2(-90, 0)  # o cipó anterior empurrou o herói
	mae._set_mode(MaeDosEsporos.Mode.DECIDE)
	player._sleep_grace_left = 0.0
	player.add_drowsiness(200.0)
	await frames(3)
	check(mae.mode == MaeDosEsporos.Mode.VINE and mae._vine_heavy, "dormiu perto: o próximo cipó é o pesado")
	# Vencida: flores murcham, recompensa.
	var flowers := mae.my_flowers.duplicate()
	mae.stats.take_damage(9999.0)
	await seconds(0.8)
	var alive := 0
	for flower in flowers:
		if is_instance_valid(flower) and not flower.dead:
			alive += 1
	check(alive == 0, "as flores dela murcham junto")
	check(Game.is_boss_defeated("mae_esporos") and Game.item_count("fragmento_turvo") == 1, "vencida: registro e fragmento")


func test_forest_gate() -> void:
	var level := await open_level("res://scenes/world/teatro.tscn", "camara")
	check(find_npc("porta_bosque_fechada") != null, "antes do Aldir: a porta do Bosque está trancada")
	level.queue_free()
	await frames(2)
	Game.defeated_bosses.append("aldir")
	level = await open_level("res://scenes/world/teatro.tscn", "camara")
	var exits := []
	for node in level.entities.get_children():
		if node is AreaExit and (node as AreaExit).target_scene.contains("bosque"):
			exits.append(node)
	check(exits.size() == 2 and level.spawns.has("lateral"), "depois do Aldir: a porta abre (e há chegada 'lateral')")
	check(level.spawns["lateral"].x < 34 * 16, "quem volta do Bosque aparece para DENTRO do Teatro")
	level.queue_free()
	await frames(2)
	level = await open_level(BOSQUE, "porta")
	var back := false
	for node in level.entities.get_children():
		if node is AreaExit and (node as AreaExit).target_scene.contains("teatro") and (node as AreaExit).target_spawn == "lateral":
			back = true
	check(back, "o Bosque leva de volta à porta lateral do Teatro")
	check(find_npc("espinhos_nyssa") != null, "antes da Mãe dos Esporos: os espinhos fecham a trilha")
	level.queue_free()
	await frames(2)
	Game.defeated_bosses.append("mae_esporos")
	level = await open_level(BOSQUE, "porta")
	var thorns := false
	for node in level.entities.get_children():
		if node is AreaExit and (node as AreaExit).target_scene.contains("arena_nyssa"):
			thorns = true
	check(thorns and find_npc("espinhos_nyssa") == null, "vencida a Mãe: os espinhos abrem para a Clareira de Nyssa")
	check(level._dialogue_variant("fada") == "fada", "a Fada só muda depois de Nyssa")
	Game.defeated_bosses.append("nyssa")
	check(level._dialogue_variant("fada") == "fada_irma" and not DialogueData.get_entry("fada_irma").get("opcoes", []).is_empty(), "depois de Nyssa: a Fada fala da irmã (e ainda sobe nível)")
	level.queue_free()
	await frames(2)



func test_nyssa_fight() -> void:
	Game.defeated_bosses.assign(["aldir", "governanta", "mae_esporos"])
	var level := await open_level(ARENA_NYSSA, "porta")
	var nyssa := level.boss_arena.boss as NyssaLumevel
	var said := []
	nyssa.speech.connect(func(text: String): said.append(text))
	level.player.global_position = nyssa.global_position + Vector2(0, 50)
	await seconds(0.5)
	check(level.boss_arena.state == BossArena.State.FIGHTING and nyssa.active, "entrou na clareira: a luta começa")
	check(nyssa.sleepers.size() == 2, "o bosque luta por ela: 2 sonâmbulos (%d)" % nyssa.sleepers.size())
	await seconds(0.6)
	check(said.size() >= 1 and said[0] == NyssaLumevel.SPEECH_INTRO, "fala de abertura (sem ter passado escondido pelo Vigia)")
	# Parado = sono.
	level.player._iframes_left = 999.0
	# (As quedas nos buracos do sonho custam vida mesmo com i-frames; sem isto,
	# uma sequência azarada de buracos sob o herói o matava e o teste falhava.)
	level.player.fall_damage_ratio = 0.0
	level.player.fall_min_damage = 0.0
	await seconds(2.0)
	check(level.player.drowsiness > 15.0, "parado perto dela, a barra sobe (%.0f)" % level.player.drowsiness)
	check(level.player.velocity.length() < 1.0, "(o herói estava parado)")
	check(not get_tree().get_nodes_in_group("dream_bubbles").is_empty(), "solta bolhas de sono")
	# Colado nela batendo sem parar: ela vira de lado.
	var rings_before := 0
	for child in level.entities.get_children():
		if child is SleepRing:
			rings_before += 1
	for i in 4:
		nyssa.hurtbox.receive_hit(HitInfo.create(5.0, level.player.global_position, nyssa.global_position))
	await frames(2)
	var rings := 0
	for child in level.entities.get_children():
		if child is SleepRing:
			rings += 1
	check(rings > rings_before, "4 golpes seguidos: anel de sono")
	# Dano enorme de uma vez não pula o Pesadelo.
	nyssa.stats.take_damage(99999.0)
	await frames(2)
	check(nyssa.phase == 2 and is_equal_approx(nyssa.stats.health_ratio(), 0.5), "não pula a fase 2 (vida %.2f)" % nyssa.stats.health_ratio())
	check(nyssa.hurtbox.invulnerable and nyssa.sleepers.is_empty(), "transição: invulnerável e os sonâmbulos se desfazem")
	await seconds(2.4)
	check(level.canvas_modulate.color.b < level.darkness.b, "o Pesadelo escurece a clareira")
	check(not nyssa.hurtbox.invulnerable and nyssa.phase_label() == "O Pesadelo", "fase 2 começa")
	# O chão some... e volta.
	for node in get_tree().get_nodes_in_group("pits"):
		(node as ArenaPit).close(0.01)
	nyssa.pits.clear()
	nyssa._pit_timer = 99.0
	nyssa._echo_timer = 99.0
	nyssa.open_dream_pits()
	check(get_tree().get_nodes_in_group("pits").size() == 2, "duas manchas escuras")
	await seconds(1.2)
	var open := 0
	for node in get_tree().get_nodes_in_group("pits"):
		if (node as ArenaPit).is_open():
			open += 1
	check(open == 2, "viraram buraco (%d)" % open)
	await seconds(nyssa.pit_life + 0.3)
	check(get_tree().get_nodes_in_group("pits").is_empty(), "depois de um tempo o chão volta")
	# Ecos: só de quem foi vencido.
	check(nyssa.echo_pool() == ["governanta", "aldir", "mae_esporos"], "ecos possíveis: %s" % [nyssa.echo_pool()])
	var echo := nyssa.summon_echo()
	check(echo != null and echo.kind in ["governanta", "aldir", "mae_esporos"], "invoca um eco (%s)" % (echo.kind if echo else "?"))
	await seconds(2.0)
	# Vencida.
	nyssa.stats.take_damage(99999.0)
	await seconds(4.0)
	check(Game.is_boss_defeated("nyssa") and Game.has_item("lembranca_nyssa"), "vencida: registro e lembrança")
	check(get_tree().get_nodes_in_group("dream_echoes").is_empty() and get_tree().get_nodes_in_group("dream_bubbles").is_empty(), "o sonho acaba (ecos e bolhas somem)")
	await seconds(4.0)
	check(level.canvas_modulate.color.is_equal_approx(level.darkness), "a luz volta ao normal")
	check(find_npc("cama_de_nyssa") != null, "fica uma cama de flores onde ela dormia")
	level.queue_free()
	await frames(2)
	# Passou pelo Vigia em silêncio: outra fala.
	Game.defeated_bosses.erase("nyssa")
	Game.set_flag("vigia_evitado")
	level = await open_level(ARENA_NYSSA, "porta")
	nyssa = level.boss_arena.boss as NyssaLumevel
	said.clear()
	nyssa.speech.connect(func(text: String): said.append(text))
	level.player.global_position = nyssa.global_position + Vector2(0, 50)
	await seconds(1.4)
	check(said.size() >= 1 and said[0] == NyssaLumevel.SPEECH_INTRO_QUIET, "quem passou em silêncio ouve outra coisa")
	level.queue_free()
	await frames(2)


func test_dream_echoes() -> void:
	var player := spawn_player(Vector2(200, 200))
	player._iframes_left = 0.0
	await frames(2)
	# Estocada (Helena): na linha, acerta.
	var hp := player.stats.health
	DreamEcho.spawn(_world, Vector2(120, 200), "helena", null)
	await seconds(1.4)
	check(player.stats.health < hp, "eco da Helena: estocada na linha acerta")
	await seconds(0.6)
	# Martelada (Vigia): parado no círculo, acerta; com dash, passa.
	player.stats.revive()
	hp = player.stats.health
	DreamEcho.spawn(_world, Vector2(260, 200), "vigia", null)
	await seconds(1.3)
	check(player.stats.health < hp, "eco do Vigia: quem fica no círculo leva a martelada")
	await seconds(0.6)
	# Todos os tipos nascem e somem sem erro.
	for id in DreamEcho.KINDS:
		DreamEcho.spawn(_world, Vector2(140, 140), id, null)
	await seconds(2.5)
	check(get_tree().get_nodes_in_group("dream_echoes").is_empty(), "todos os ecos se desfazem depois do golpe")



## Regressão: o Pesadelo começava só quando o dano vinha por um GOLPE.
## Dano por outro caminho (direto na vida) deixava Nyssa presa na fase 1.
func test_nyssa_phase_from_any_damage() -> void:
	Game.defeated_bosses.assign(["aldir"])
	var level := await open_level(ARENA_NYSSA, "porta")
	var nyssa := level.boss_arena.boss as NyssaLumevel
	level.player.global_position = nyssa.global_position + Vector2(0, 50)
	await seconds(0.5)
	nyssa.stats.take_damage(nyssa.stats.max_health * 0.55)
	await frames(2)
	check(nyssa.phase == 2, "metade da vida (sem golpe): o Pesadelo começa")
	level.queue_free()
	await frames(2)



# --- Raízes da Fome ---------------------------------------------------------------------

## Bíblia: "O agarrão é um estado de 'preso': o jogador toca rápido no botão de
## ataque para escapar e, a cada segundo preso, perde uma parte das memórias."
func test_grab_and_escape() -> void:
	var player := spawn_player(Vector2(200, 200))
	var holder := Node2D.new()
	holder.position = Vector2(230, 200)
	_world.add_child(holder)
	var events := []
	player.grab_changed.connect(func(grabbed: bool, _taps: int): events.append(grabbed))
	await frames(2)
	Game.memories = 1000
	check(player.grab(holder, 4, Vector2.ZERO, 10.0, 0.05, 5), "agarra")
	check(player.is_grabbed_by(holder) and events == [true], "estado GRABBED + sinal")
	await seconds(1.1)
	check(Game.memories == 950, "1 s preso: perde 5%% das memórias (%d)" % Game.memories)
	check(player.stats.health < player.stats.max_health, "e um pouco de vida")
	check(player.global_position.distance_to(holder.global_position) < 3.0, "fica preso em quem agarrou")
	await tap(&"dash")
	check(player.state == Player.State.GRABBED, "preso: o dash não sai (vira toque de escape)")
	for i in 3:
		await tap(&"attack")
	check(player.state == Player.State.FREE and events == [true, false], "4 toques: escapou")
	check(player._iframes_left > 0.0, "respiro de invencibilidade ao escapar")
	check(player.get_collision_mask_value(3), "volta a colidir com inimigos")
	await seconds(0.8)
	# Esquivando (i-frames) não dá para agarrar.
	player._start_dash()
	await frames(2)
	check(not player.grab(holder, 4), "no meio do dash o agarrão erra")
	await seconds(0.5)
	# Quem agarrou sumiu: solta sozinho.
	check(player.grab(holder, 99, Vector2.ZERO, 0.0, 0.0, 0, true), "agarra de novo (engolido)")
	check(not player.visual.visible, "engolido: o herói some")
	holder.queue_free()
	await frames(3)
	check(player.state == Player.State.FREE and player.visual.visible, "o agarrador sumiu: solto e visível")
	# Diálogo no meio do agarrão também solta (nada fica "preso" escondido).
	var holder2 := Node2D.new()
	_world.add_child(holder2)
	player._iframes_left = 0.0
	player.grab(holder2, 99)
	player.lock_input(true)
	check(player.state == Player.State.LOCKED and player.visual.visible, "travar o controle encerra o agarrão")
	player.lock_input(false)


func test_root_mouth_ambush() -> void:
	var player := spawn_player(Vector2(120, 200))
	var boca := spawn_enemy_scene(BOCA_SCENE, Vector2(200, 200)) as BocaDeRaiz
	await frames(3)
	check(boca.ai == BocaDeRaiz.AI.BURIED and not boca.is_targetable() and boca.hurtbox.invulnerable, "enterrada: não é alvo e não leva dano")
	# Pisou em cima: sobe e agarra.
	player.global_position = boca.global_position + Vector2(4, 0)
	await seconds(0.7)
	check(player.is_grabbed_by(boca) and boca.ai == BocaDeRaiz.AI.HOLD, "subiu e agarrou quem estava em cima")
	for i in boca.grab_taps:
		await tap(&"attack")
	await frames(2)
	check(player.state == Player.State.FREE and boca.ai == BocaDeRaiz.AI.EXPOSED, "escapou: a boca fica exposta (tonta)")
	check(boca.is_targetable() and not boca.hurtbox.invulnerable, "exposta: dá para cortar")
	boca.stats.take_damage(9999.0)
	await frames(2)
	check(boca.dead, "cortada")
	# Dash na hora do aviso: ela morde o ar.
	var boca2 := spawn_enemy_scene(BOCA_SCENE, Vector2(300, 120)) as BocaDeRaiz
	await frames(3)
	player.global_position = boca2.global_position + Vector2(-6, 0)
	await seconds(0.3)
	check(boca2.ai == BocaDeRaiz.AI.RISING, "o monte incha (aviso)")
	player.global_position = boca2.global_position + Vector2(-60, 0)
	await seconds(0.4)
	check(not player.is_grabbed() and boca2.ai == BocaDeRaiz.AI.EXPOSED, "saiu a tempo: o bote erra")
	await seconds(boca2.exposed_time + boca2.sink_time + 0.3)
	check(boca2.ai == BocaDeRaiz.AI.BURIED, "depois de um tempo volta para a terra")


func test_bloated_explodes() -> void:
	var player := spawn_player(Vector2(200, 200))
	var inchado := spawn_enemy_scene(INCHADO_SCENE, Vector2(220, 200)) as Inchado
	var soldier := spawn_enemy_scene(SOLDIER_SCENE, Vector2(240, 210))
	await frames(3)
	player._iframes_left = 0.0
	var hp := player.stats.health
	var soldier_hp := soldier.stats.health
	inchado.stats.take_damage(9999.0)
	await frames(2)
	check(get_tree().get_nodes_in_group("flesh_bursts").size() == 1, "morreu: começa a inchar (círculo de aviso)")
	check(player.stats.health == hp, "ainda não estourou")
	await seconds(inchado.burst_delay + 0.2)
	check(player.stats.health < hp, "estourou no herói que ficou perto")
	check(soldier.stats.health < soldier_hp, "e nos inimigos em volta também")
	check(get_tree().get_nodes_in_group("flesh_bursts").is_empty(), "a explosão acaba")
	# Saiu do círculo: nada.
	await seconds(0.6)
	player.stats.revive()
	player._iframes_left = 0.0
	var other := spawn_enemy_scene(INCHADO_SCENE, Vector2(320, 120)) as Inchado
	await frames(2)
	hp = player.stats.health
	other.stats.take_damage(9999.0)
	await seconds(other.burst_delay + 0.2)
	check(player.stats.health == hp, "longe do círculo, não sente nada")


func test_reaper_scythe() -> void:
	var player := spawn_player(Vector2(200, 200))
	var reaper := spawn_enemy_scene(COLHEDOR_SCENE, Vector2(232, 200)) as Colhedor
	player._iframes_left = 0.0
	var hp := player.stats.health
	await seconds(1.8)
	check(player.stats.health < hp, "a foice alcança de longe (ponta da foice)")
	check(reaper.global_position.distance_to(player.global_position) > 18.0, "luta à distância da foice")
	# Colado nele: ele gira.
	var spun := [false]
	reaper._runner.phase_changed.connect(func(_p): if reaper._current_attack == reaper.spin: spun[0] = true)
	player.stats.revive()
	for i in 120:
		player.global_position = reaper.global_position + Vector2(8, 0)
		player._iframes_left = 999.0
		await frames(1)
		if spun[0]:
			break
	check(spun[0], "colado tempo demais: gira a foice em volta")


func test_sap_larva_steals_and_returns() -> void:
	var player := spawn_player(Vector2(200, 200))
	var larva := spawn_enemy_scene(LARVA_SCENE, Vector2(214, 200)) as LarvaSeiva
	Game.memories = 500
	player._iframes_left = 0.0
	for i in 150:
		await frames(1)
		if larva.stolen > 0:
			break
	check(larva.stolen > 0 and Game.memories == 500 - larva.stolen, "mordeu: roubou memórias (%d)" % larva.stolen)
	await seconds(0.7)
	check(larva.ai == LarvaSeiva.AI.FLEE, "e foge com elas")
	var stolen := larva.stolen
	larva.stats.take_damage(9999.0)
	await frames(2)
	check(Game.memories >= 500 - stolen + stolen, "matou: as memórias voltam (%d)" % Game.memories)
	check(Game.memories == 500 + larva.memory_reward, "(mais a recompensa normal)")
	# Escudo erguido: mordida no escudo não rouba.
	Game.add_item("escudo_remendado")
	Game.set_shield_equipped(true)
	var larva2 := spawn_enemy_scene(LARVA_SCENE, Vector2(186, 200)) as LarvaSeiva
	player.facing = Vector2.LEFT
	Input.action_press(&"block")
	await seconds(2.0)
	Input.action_release(&"block")
	check(larva2.stolen == 0, "mordeu o escudo: nada roubado")


func test_banqueteiro_serves_and_eats() -> void:
	var player := spawn_player(Vector2(140, 200))
	var cook := spawn_mini(BANQUETEIRO_SCENE, Vector2(220, 200)) as Banqueteiro
	player._iframes_left = 999.0
	await frames(3)
	check(cook.active, "viu o herói: acorda")
	cook.serve()
	await frames(2)
	check(cook.lackeys.size() >= 1, "serve lacaios (%d)" % cook.lackeys.size())
	for lackey in cook.lackeys:
		check(lackey.memory_reward == 0, "servido não paga memórias")
	# Ferido e com comida por perto: come e se cura.
	cook.stats.set_health(cook.stats.max_health * 0.6)
	var hp := cook.stats.health
	var before := cook.lackeys.size()
	cook._eat_timer = 0.0
	cook._set_mode(Banqueteiro.Mode.CHASE)
	for i in 400:
		await frames(1)
		if cook.lackeys.size() < before:
			break
	check(cook.lackeys.size() == before - 1 and cook.stats.health > hp, "comeu um lacaio e se curou (%.0f → %.0f)" % [hp, cook.stats.health])
	# Golpe forte no aviso interrompe.
	cook.serve()
	await frames(2)
	cook._eat_timer = 0.0
	cook._set_mode(Banqueteiro.Mode.CHASE)
	for i in 300:
		await frames(1)
		if cook.mode == Banqueteiro.Mode.EAT and cook._eat_started:
			break
	check(cook.mode == Banqueteiro.Mode.EAT and cook._eat_started, "vai comer (aviso)")
	var heavy := HitInfo.create(10.0, player.global_position, cook.global_position)
	heavy.is_heavy = true
	cook.hurtbox.receive_hit(heavy)
	await frames(1)
	check(cook.mode != Banqueteiro.Mode.EAT, "golpe forte: o garfo cai")
	# Vencido: os lacaios somem e a recompensa vem.
	var lackeys := cook.lackeys.duplicate()
	cook.stats.take_damage(99999.0)
	await seconds(0.6)
	var alive := 0
	for lackey in lackeys:
		if is_instance_valid(lackey) and not lackey.dead:
			alive += 1
	check(alive == 0, "os lacaios somem com ele")
	check(Game.is_boss_defeated("banqueteiro") and Game.item_count("fragmento_turvo") == 1, "vencido: registro e fragmento")


func test_ninhada_splits_and_engulfs() -> void:
	var player := spawn_player(Vector2(150, 200))
	var brood := spawn_mini(NINHADA_SCENE, Vector2(200, 200)) as Ninhada
	await frames(3)
	check(brood.active, "acorda")
	brood.hurtbox.receive_hit(HitInfo.create(brood.stats.max_health * 0.22, player.global_position, brood.global_position))
	await frames(2)
	check(brood.larvae.size() == brood.larvae_per_split, "perdeu um pedaço: soltou larvas (%d)" % brood.larvae.size())
	# Engolir: parado no círculo, preso.
	for larva in brood.larvae:
		larva.queue_free()
	brood.larvae.clear()
	player._iframes_left = 0.0
	brood._cooldown = 0.0
	brood._start_engulf()
	await seconds(brood.engulf_windup + 0.15)
	check(player.is_grabbed_by(brood) and brood.mode == Ninhada.Mode.HOLD, "caiu por cima: engolido")
	for i in brood.grab_taps:
		await tap(&"attack")
	await frames(2)
	check(not player.is_grabbed() and brood.mode == Ninhada.Mode.DAZED, "escapou: ela fica tonta")
	# Vencida: as larvas dela morrem junto.
	brood.split()
	await frames(1)
	var larvae := brood.larvae.duplicate()
	brood.stats.take_damage(99999.0)
	await seconds(0.5)
	var alive := 0
	for larva in larvae:
		if is_instance_valid(larva) and not larva.dead:
			alive += 1
	check(alive == 0 and Game.is_boss_defeated("ninhada"), "vencida: as larvas se desfazem")


func test_roots_gate() -> void:
	Game.defeated_bosses.assign(["aldir"])
	var level := await open_level("res://scenes/world/teatro.tscn", "camara")
	check(find_npc("raizes_fechadas") != null, "antes de Nyssa: raízes fecham a porta oeste")
	level.queue_free()
	await frames(2)
	Game.defeated_bosses.append("nyssa")
	level = await open_level("res://scenes/world/teatro.tscn", "camara")
	var exits := 0
	for node in level.entities.get_children():
		if node is AreaExit and (node as AreaExit).target_scene.contains("raizes"):
			exits += 1
	check(exits == 2 and level.spawns.has("oeste"), "depois de Nyssa: a porta oeste abre")
	check(level.spawns["oeste"].x > 16, "quem volta das Raízes aparece para dentro")
	level.queue_free()
	await frames(2)
	level = await open_level(RAIZES, "porta")
	var kinds := {}
	for node in level.entities.get_children():
		kinds[node.get_class() if node.get_script() == null else (node.get_script() as Script).get_global_name()] = true
	for name in ["BocaDeRaiz", "Inchado", "Colhedor", "LarvaSeiva", "Banqueteiro", "Ninhada", "RestChamber"]:
		check(kinds.has(name), "as Raízes têm %s" % name)
	check(not kinds.has("Sonambulo"), "o mesmo 'z' do Bosque aqui é outra coisa")
	check(find_npc("porta_cozinha") != null, "antes do Banqueteiro: a porta dos fundos está trancada")
	var back := false
	for node in level.entities.get_children():
		if node is AreaExit and (node as AreaExit).target_scene.contains("teatro") and (node as AreaExit).target_spawn == "oeste":
			back = true
	check(back, "volta para a porta oeste do Teatro")
	level.queue_free()
	await frames(2)
	Game.defeated_bosses.append("banqueteiro")
	level = await open_level(RAIZES, "porta")
	var to_mabel := false
	for node in level.entities.get_children():
		if node is AreaExit and (node as AreaExit).target_scene.contains("arena_mabel"):
			to_mabel = true
	check(to_mabel and find_npc("porta_cozinha") == null, "vencido o Banqueteiro: a porta de Mabel abre")
	check(level._dialogue_variant("vendedor") == "vendedor", "o Vendedor só fala dela depois")
	Game.defeated_bosses.append("mabel")
	check(level._dialogue_variant("vendedor") == "vendedor_mabel" and not DialogueData.get_entry("vendedor_mabel").get("opcoes", []).is_empty(), "depois de Mabel: o Vendedor lembra dela (e ainda vende)")
	level.queue_free()
	await frames(2)


func test_mabel_fight() -> void:
	Game.defeated_bosses.assign(["aldir", "nyssa", "banqueteiro"])
	var level := await open_level(ARENA_MABEL, "porta")
	var mabel := level.boss_arena.boss as MabelVoragine
	var said := []
	mabel.speech.connect(func(text: String): said.append(text))
	level.player.global_position = mabel.global_position + Vector2(0, 80)
	await seconds(0.5)
	check(level.boss_arena.state == BossArena.State.FIGHTING and mabel.active, "chegou perto da mesa: a luta começa")
	check(not said.is_empty() and said[0] == MabelVoragine.SPEECH_INTRO, "ela convida para a mesa")
	# Frutos de carne: círculos no chão.
	mabel.throw_fruits()
	await frames(2)
	check(get_tree().get_nodes_in_group("flesh_bursts").size() == mabel.fruit_count, "%d frutos a caminho" % mabel.fruit_count)
	await seconds(mabel.fruit_flight + 0.5)
	check(get_tree().get_nodes_in_group("flesh_bursts").is_empty(), "os frutos estouram")
	# Agarrão: na linha, engolido.
	level.player.stats.revive()
	level.player._iframes_left = 0.0
	level.player.global_position = mabel.global_position + Vector2(50, 0)
	Game.memories = 1000
	mabel._go_decide(99.0)
	mabel._start_reach()
	await seconds(mabel.reach_windup + 0.1)
	check(level.player.is_grabbed_by(mabel) and mabel.mode == MabelVoragine.Mode.SWALLOW, "na linha: engolido")
	check(not level.player.visual.visible, "o herói some dentro dela")
	var hp := mabel.stats.health
	mabel.stats.set_health(mabel.stats.max_health * 0.8)
	hp = mabel.stats.health
	await seconds(1.1)
	check(Game.memories < 1000 and mabel.stats.health > hp, "engolido: perde memórias e ela se cura")
	for i in mabel.grab_taps:
		await tap(&"attack")
	await frames(2)
	check(not level.player.is_grabbed() and mabel.mode == MabelVoragine.Mode.GAG, "escapou: ela engasga")
	var info := HitInfo.create(10.0, level.player.global_position, mabel.global_position)
	check(is_equal_approx(mabel._incoming_damage_multiplier(info), mabel.open_belly_multiplier), "engasgada: leva dano dobrado")
	# Metade da vida (por qualquer caminho): a Vorágine.
	mabel.stats.take_damage(99999.0)
	await frames(2)
	check(mabel.phase == 2 and is_equal_approx(mabel.stats.health_ratio(), 0.5), "não pula a fase 2")
	check(mabel.hurtbox.invulnerable and mabel.roots.size() == mabel.root_count, "transição: %d raízes brotam" % mabel.roots.size())
	await seconds(2.4)
	check(not mabel.hurtbox.invulnerable and mabel.phase_label() == "A Vorágine", "fase 2 começa")
	# As raízes curam.
	mabel._go_decide(99.0)
	hp = mabel.stats.health
	await seconds(1.0)
	check(mabel.stats.health > hp, "raízes vivas curam Mabel (%.0f → %.0f)" % [hp, mabel.stats.health])
	# Lacaios saem das raízes.
	mabel._lackey_timer = 0.0
	await frames(2)
	check(mabel.lackeys.size() == 1, "um lacaio saiu de uma raiz")
	# Ela come o lacaio: cura e cresce.
	var meal: Enemy = mabel.lackeys[0]
	hp = mabel.stats.health
	mabel.devour(meal)
	check(mabel.stats.health > hp and mabel.growth > 1.0, "comeu: cura e cresce (%.2f)" % mabel.growth)
	# Ventre: de frente dói mais; por trás, normal.
	mabel.facing = Vector2.RIGHT
	mabel._set_mode(MabelVoragine.Mode.DECIDE)
	var front := HitInfo.create(10.0, mabel.global_position + Vector2(30, 0), mabel.global_position)
	var back := HitInfo.create(10.0, mabel.global_position + Vector2(-30, 0), mabel.global_position)
	check(is_equal_approx(mabel._incoming_damage_multiplier(front), mabel.belly_multiplier), "de frente: o ventre (ponto fraco)")
	check(is_equal_approx(mabel._incoming_damage_multiplier(back), 1.0), "por trás: dano normal")
	# Cortar TODAS as raízes para a cura.
	for root in mabel.roots.duplicate():
		root.stats.take_damage(9999.0)
	await frames(3)
	check(mabel.living_roots() == 0, "raízes cortadas")
	hp = mabel.stats.health
	await seconds(1.0)
	check(is_equal_approx(mabel.stats.health, hp), "sem raízes, a cura para")
	check(said.has(MabelVoragine.SPEECH_ROOTS_CUT), "ela sente")
	# Vencida.
	mabel.stats.take_damage(99999.0)
	await seconds(4.5)
	check(Game.is_boss_defeated("mabel") and Game.has_item("lembranca_mabel"), "vencida: registro e lembrança")
	check(get_tree().get_nodes_in_group("flesh_bursts").is_empty(), "nada fica explodindo depois")
	check(find_npc("mesa_de_mabel") != null, "fica a mesa posta onde ela sentava")
	level.queue_free()
	await frames(2)



# --- Áreas novas: montagem, mapa fechado e TUDO alcançável --------------------------

## Caminho a pé (sem dash) da chegada até cada coisa importante do mapa.
## Pega erro de desenho: um mini-chefe ou um item num bolsão sem saída.
func _unreachable(level: Level, from: Vector2) -> Array:
	var start := Level.cell_at(from)
	var seen := {start: true}
	var queue: Array[Vector2i] = [start]
	while not queue.is_empty():
		var cell: Vector2i = queue.pop_front()
		for offset: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n := cell + offset
			if seen.has(n):
				continue
			var c := level._char_at(n.x, n.y)
			if c == " " or level._is_wall_char(c) or level.wall_layer.get_cell_source_id(n) != -1 and not level._is_floor_char(c):
				continue
			if level.THEMES[level.theme].get("solid", {}).has(c):
				continue
			seen[n] = true
			queue.append(n)
	var missing := []
	for y in range(level._height):
		for x in range(level._width):
			var c := level._char_at(x, y)
			if "UO0/@CD>'zs^?123456789".contains(c) and not seen.has(Vector2i(x, y)):
				missing.append("%s@%d,%d" % [c, x, y])
	return missing


func test_new_areas_build() -> void:
	Game.defeated_bosses.assign(["aldir", "nyssa", "mabel", "banqueteiro"])
	for path in [RAIZES, ARENA_MABEL, FORJAS, ARENA_DURGAN, MONTANHA, ARENA_RACHEL, DOMINIO, ARENA_CASSIAN, NUCLEO, CORACAO]:
		if path == NUCLEO:
			Game.defeated_bosses.assign(Game.SEVEN)
		if path == MONTANHA:
			Game.defeated_bosses.append("durgan")
		if path == DOMINIO:
			Game.defeated_bosses.append("rachel")
		var level := await open_level(path, "porta")
		check(level.player != null and level.spawns.has("porta"), "%s: herói chega pela porta" % path)
		var leaks := _find_open_edges(level)
		check(leaks.is_empty(), "%s: mapa fechado (%s)" % [path, leaks.slice(0, 5)])
		var missing := _unreachable(level, level.player.global_position)
		check(missing.is_empty(), "%s: tudo alcançável a pé (%s)" % [path, missing.slice(0, 6)])
		if path == FORJAS:
			check(level.plate_cells.size() > 60, "Forjas: placas de metal registradas (%d)" % level.plate_cells.size())
			var kinds := {}
			for node in level.entities.get_children():
				if node.get_script():
					kinds[(node.get_script() as Script).get_global_name()] = true
			for name in ["AutomatoBronze", "TorretaFaisca", "MineradorOco", "Imitador", "Prototipo", "GuardiaoAncora", "RestChamber"]:
				check(kinds.has(name), "Forjas: tem %s" % name)
		if path == MONTANHA:
			var found := {}
			for node in level.entities.get_children():
				if node.get_script():
					found[(node.get_script() as Script).get_global_name()] = true
			for name in ["DragonoideAtirador", "DragaoBestial", "DragaoAlado", "BrasaViva", "CapitaoDragonoide", "MatriarcaBestial", "RestChamber"]:
				check(found.has(name), "Montanha: tem %s" % name)
		if path == DOMINIO:
			check(level.ice_cells.size() > 300, "Domínio: gelo registrado (%d)" % level.ice_cells.size())
			var kinds_ice := {}
			for node in level.entities.get_children():
				if node.get_script():
					kinds_ice[(node.get_script() as Script).get_global_name()] = true
			for name in ["BibliotecarioGelo", "EstatuaViva", "AcaroCristal", "AprendizArcano", "CuradoraVitrines", "GolemArquivo", "RestChamber"]:
				check(kinds_ice.has(name), "Domínio: tem %s" % name)
			check(find_npc("estudioso") != null, "Domínio: o Estudioso congelado")
		if path == CORACAO:
			check(level.boss_arena != null and level.boss_arena.boss is CavaleiroDesolado, "O Coração: o Cavaleiro")
			check(get_tree().get_first_node_in_group(&"nucleo_core") != null, "O Coração: a mulher ligada ao núcleo")
		if path == ARENA_CASSIAN:
			check(level.boss_arena != null and level.boss_arena.boss is CassianVirel, "Sala do Arconte: Cassian")
		if path == ARENA_RACHEL:
			check(level.boss_arena != null and level.boss_arena.boss is RachelCaelis, "O Ninho: Rachel")
			check(get_tree().get_nodes_in_group("covers").size() == 6, "O Ninho: seis pilares de rocha")
		if path == ARENA_DURGAN:
			check(level.boss_arena != null and level.boss_arena.boss is DurganVell, "Forja do Eco: Durgan")
			check(not level.boss_arena.arena_rect.has_point(level.player.global_position), "Forja do Eco: chega no corredor")
		level.queue_free()
		await frames(2)


## Venceu o mini-chefe que guardava a porta: ela abre NA HORA (sem descansar).
func test_live_exit_unlock() -> void:
	Game.defeated_bosses.assign(["aldir", "nyssa"])
	var level := await open_level(RAIZES, "porta")
	check(find_npc("porta_cozinha") != null, "trancada")
	var cook: Banqueteiro = null
	for node in level.entities.get_children():
		if node is Banqueteiro:
			cook = node
	cook.start_fight()
	cook.stats.take_damage(99999.0)
	await frames(3)
	var open := false
	for node in level.entities.get_children():
		if node is AreaExit and (node as AreaExit).target_scene.contains("arena_mabel"):
			open = true
	check(open and level.spawns.has("lateral"), "a porta de Mabel abriu na hora")
	await frames(2)
	check(find_npc("porta_cozinha") == null, "o ponto 'trancado' sumiu")
	level.queue_free()
	await frames(2)


func test_plate_charge() -> void:
	var player := spawn_player(Vector2(200, 200))
	await frames(2)
	player._iframes_left = 0.0
	var hp := player.stats.health
	var cells: Array[Vector2i] = [Level.cell_at(player.global_position)]
	var charge := PlateCharge.spawn(_world, cells, 0.5, 20.0)
	await seconds(0.3)
	check(player.stats.health == hp and not charge.is_live(), "placa acesa: ainda é só aviso")
	await seconds(0.35)
	check(player.stats.health < hp, "o raio corre: quem está em cima leva o choque")
	await seconds(0.4)
	check(not is_instance_valid(charge), "a placa apaga")
	# Fora da placa: nada. Com escudo: o raio vem do chão, não segura.
	hp = player.stats.health
	player._iframes_left = 0.0
	var other: Array[Vector2i] = [Level.cell_at(player.global_position) + Vector2i(3, 0)]
	PlateCharge.spawn(_world, other, 0.2, 20.0)
	await seconds(0.6)
	check(player.stats.health == hp, "fora das placas acesas: nada")


func test_bronze_automaton() -> void:
	var player := spawn_player(Vector2(200, 200))
	var auto := spawn_enemy_scene(AUTOMATO_SCENE, Vector2(222, 200)) as AutomatoBronze
	await frames(3)
	var light := HitInfo.create(20.0, player.global_position, auto.global_position)
	var heavy := HitInfo.create(20.0, player.global_position, auto.global_position)
	heavy.is_heavy = true
	check(is_equal_approx(auto._incoming_damage_multiplier(light), auto.light_damage_ratio), "bronze: o corte leve perde força")
	check(is_equal_approx(auto._incoming_damage_multiplier(heavy), 1.0), "o golpe forte entra inteiro")
	player._iframes_left = 0.0
	var hp := player.stats.health
	await seconds(2.0)
	check(player.stats.health < hp, "o martelo lento acerta quem fica parado")


func test_spark_turret() -> void:
	var player := spawn_player(Vector2(200, 200))
	var turret := spawn_enemy_scene(TORRETA_SCENE, Vector2(120, 200)) as TorretaFaisca
	await frames(3)
	player._iframes_left = 0.0
	var hp := player.stats.health
	await seconds(turret.charge_time + 0.1)
	check(not get_tree().get_nodes_in_group("plate_charges").is_empty(), "mira, carrega e acende as placas até o herói")
	await seconds(turret.plate_warning + 0.2)
	check(player.stats.health < hp, "quem fica na trilha leva o raio")
	# Saindo da trilha a tempo: nada.
	player.stats.revive()
	await seconds(1.0)
	turret._set_ai(TorretaFaisca.AI.COOLDOWN)
	turret._ai_time = turret.fire_every
	await seconds(turret.charge_time + 0.15)
	player.global_position += Vector2(0, 60)
	player._iframes_left = 0.0
	hp = player.stats.health
	await seconds(turret.plate_warning + 0.3)
	check(player.stats.health == hp, "saiu das placas acesas: escapou")


func test_hollow_miner() -> void:
	var player := spawn_player(Vector2(200, 200))
	var miner := spawn_enemy_scene(MINERADOR_SCENE, Vector2(216, 200)) as MineradorOco
	player._iframes_left = 999.0
	var swings := [0]
	miner._runner.phase_changed.connect(func(p): if p == AttackRunner.Phase.ACTIVE: swings[0] += 1)
	await seconds(3.0)
	check(swings[0] >= 3, "sempre três picaretadas (%d)" % swings[0])
	check(miner.combo.size() == 3 and miner.combo[2].is_heavy, "a terceira é a pesada")


func test_imitator_copies() -> void:
	var player := spawn_player(Vector2(200, 200))
	var mimic := spawn_enemy_scene(IMITADOR_SCENE, Vector2(240, 200)) as Imitador
	player._iframes_left = 999.0
	await seconds(0.5)
	check(mimic.ai == Imitador.AI.STALK, "viu você: estuda de perto")
	player.facing = Vector2.RIGHT
	await tap(&"attack")
	await seconds(0.45)
	check(mimic.ai == Imitador.AI.ATTACK and mimic._current_attack == mimic.light_attack, "você cortou: ele corta igual")
	await seconds(1.0)
	player._start_dash()
	await seconds(0.35)
	check(mimic.ai == Imitador.AI.DASH and mimic.hurtbox.invulnerable, "você deu dash: ele também (com i-frames)")
	await seconds(0.6)
	# Escudo: só se VOCÊ usa um.
	check(not mimic.shield_sprite.visible, "sem escudo seu, sem escudo dele")
	Game.add_item("escudo_remendado")
	Game.set_shield_equipped(true)
	await frames(2)
	check(mimic.shield_sprite.visible, "com o seu escudo, ele aparece com um também")
	mimic.copy_action(&"escudo")
	var front := HitInfo.create(20.0, mimic.global_position + mimic.facing * 20.0, mimic.global_position)
	check(mimic._incoming_damage_multiplier(front) < 0.5, "escudo erguido: segura de frente")
	# Você bebe: ele "bebe" e se cura.
	mimic._set_ai(Imitador.AI.STALK)
	mimic.stats.set_health(mimic.stats.max_health * 0.5)
	mimic.copy_action(&"cura")
	await seconds(1.0)
	check(mimic.stats.health_ratio() > 0.6, "copiou a cura")


func test_prototype() -> void:
	var player := spawn_player(Vector2(140, 200))
	var proto := spawn_mini(PROTOTIPO_SCENE, Vector2(240, 200)) as Prototipo
	player._iframes_left = 999.0
	await frames(3)
	check(proto.active, "acorda")
	check(proto.basic_attack.resource_path.ends_with("player_light_1.tres"), "o golpe dele é o SEU corte leve")
	var dashed := [false]
	var attacked := [false]
	for i in 240:
		await frames(1)
		if proto.mode == Prototipo.Mode.DASH:
			dashed[0] = true
		if proto.mode == Prototipo.Mode.ATTACK:
			attacked[0] = true
		if dashed[0] and attacked[0]:
			break
	check(dashed[0] and attacked[0], "encurta com dash e corta")
	proto.stats.take_damage(99999.0)
	await seconds(0.5)
	check(Game.is_boss_defeated("prototipo") and Game.item_count("sucata_temperada") >= 4, "vencido: registro e sucata")


func test_anchor_guardian() -> void:
	var player := spawn_player(Vector2(165, 200))
	var guard := spawn_mini(GUARDIAO_SCENE, Vector2(220, 200)) as GuardiaoAncora
	await frames(3)
	check(guard.active, "acorda")
	var info := HitInfo.create(10.0, player.global_position, guard.global_position)
	check(is_equal_approx(guard._incoming_damage_multiplier(info), guard.shell_damage_ratio), "a carcaça segura quase tudo")
	player._iframes_left = 0.0
	var hp := player.stats.health
	guard._aim = (player.global_position - guard.global_position).normalized()
	guard._set_mode(GuardiaoAncora.Mode.SWEEP)
	await seconds(guard.windup + 0.2)
	check(player.stats.health < hp, "a corrente varre o leque")
	# Dois ataques → superaquece e o núcleo fica exposto.
	guard._attacks = 2
	guard._set_mode(GuardiaoAncora.Mode.DECIDE)
	await frames(2)
	check(guard.is_vented() and is_equal_approx(guard._incoming_damage_multiplier(info), guard.core_damage_ratio), "depois de dois ataques: núcleo exposto")
	guard.stats.take_damage(99999.0)
	await seconds(0.5)
	check(Game.is_boss_defeated("guardiao_ancora"), "vencido")


func test_forge_gate_and_smith() -> void:
	Game.defeated_bosses.assign(["aldir", "nyssa"])
	var level := await open_level(BOSQUE, "porta")
	check(find_npc("trilha_forjas") != null, "antes de Mabel: a trilha das Forjas está presa pelas raízes")
	level.queue_free()
	await frames(2)
	Game.defeated_bosses.append("mabel")
	level = await open_level(BOSQUE, "porta")
	var to_forge := false
	for node in level.entities.get_children():
		if node is AreaExit and (node as AreaExit).target_scene.contains("forjas"):
			to_forge = true
	check(to_forge and level.spawns.has("oeste"), "depois de Mabel: a trilha abre")
	level.queue_free()
	await frames(2)
	level = await open_level(FORJAS, "porta")
	var back := false
	for node in level.entities.get_children():
		if node is AreaExit and (node as AreaExit).target_scene.contains("bosque") and (node as AreaExit).target_spawn == "oeste":
			back = true
	check(back, "as Forjas levam de volta à trilha do Bosque")
	check(find_npc("porta_ancora") != null, "antes do Guardião: a porta da Forja do Eco está presa")
	check(level._dialogue_variant("ferreiro") == "ferreiro", "o Ferreiro só lembra do irmão depois")
	Game.defeated_bosses.append("durgan")
	check(level._dialogue_variant("ferreiro") == "ferreiro_irmao" and not DialogueData.get_entry("ferreiro_irmao").get("opcoes", []).is_empty(), "depois de Durgan: o Ferreiro lembra (e ainda forja)")
	check(Game.weapon_level_cap() == Game.WEAPON_LEVEL_CAP_AFTER_DURGAN, "e libera a arma até +5")
	level.queue_free()
	await frames(2)


func test_durgan_fight() -> void:
	Game.defeated_bosses.assign(["aldir", "nyssa", "mabel", "guardiao_ancora"])
	var level := await open_level(ARENA_DURGAN, "porta")
	var durgan := level.boss_arena.boss as DurganVell
	var said := []
	durgan.speech.connect(func(text: String): said.append(text))
	level.player.global_position = durgan.global_position + Vector2(0, 90)
	level.player._iframes_left = 999.0
	await seconds(0.5)
	check(durgan.active and not said.is_empty() and said[0] == DurganVell.SPEECH_INTRO, "a luta começa")
	# Ele conta tudo o que você faz.
	level.player.facing = Vector2.UP
	await tap(&"attack")
	await seconds(0.5)
	level.player._start_dash()
	await seconds(0.4)
	check(durgan.counts[&"leve"] >= 1 and durgan.counts[&"dash"] >= 1, "contou: %s" % durgan.counts)
	# Engenharia: torreta, autômato, placas acesas.
	var turret := durgan.build_turret()
	var automaton := durgan.call_automaton()
	check(turret is TorretaFaisca and automaton is AutomatoBronze and turret.memory_reward == 0, "constrói torreta e chama autômato (sem pagar memórias)")
	check(durgan.charge_field() != null, "acende as placas em volta do herói")
	# A martelada acende um anel de placas.
	var before := get_tree().get_nodes_in_group("plate_charges").size()
	durgan._go_decide(99.0)
	durgan._queue_combo([durgan.slam])
	await seconds(durgan.slam.windup_time + 0.25)
	check(get_tree().get_nodes_in_group("plate_charges").size() > before, "a martelada elétrica acende o anel de placas")
	await seconds(1.5)
	# Metade da vida: o Reflexo (sem pular, e os autômatos caem).
	durgan.stats.take_damage(99999.0)
	await frames(2)
	check(durgan.phase == 2 and is_equal_approx(durgan.stats.health_ratio(), 0.5), "não pula o Reflexo")
	await seconds(0.3)
	check(not is_instance_valid(automaton) or automaton.dead, "os rostos de bronze caem")
	await seconds(2.2)
	# (Não olha a invulnerabilidade: ele pode já estar no meio de um dash, com i-frames.)
	check(durgan.mode != DurganVell.Mode.TRANSITION and durgan.phase_label() == "O Reflexo", "fase 2 começa")
	# Peso = contagem + 1: quem só dá golpe forte, apanha de golpe forte.
	durgan.counts = {&"leve": 0, &"forte": 40, &"dash": 0, &"escudo": 0, &"cura": 0}
	var heavy := 0
	for i in 200:
		if durgan.pick_copy() == &"forte":
			heavy += 1
	check(heavy > 150, "quem abusa do golpe forte enfrenta golpe forte (%d/200)" % heavy)
	durgan.counts = {&"leve": 0, &"forte": 0, &"dash": 40, &"escudo": 0, &"cura": 0}
	check(durgan.dodge_chance() > 0.6, "quem abusa do dash enfrenta alguém que esquiva (%.2f)" % durgan.dodge_chance())
	durgan._go_decide(0.0)
	level.player.global_position = durgan.global_position + Vector2(0, 30)
	var dodged := false
	for i in 8:
		durgan._go_decide(0.0)
		durgan._on_player_action(&"leve")
		if durgan.mode == DurganVell.Mode.DODGE:
			dodged = true
			break
	check(dodged, "você bate: ele esquiva")
	await seconds(0.5)
	# Escudo espelhado: de frente quase nada entra — e ele revida.
	durgan._copy(&"escudo", 30.0)
	var front := HitInfo.create(20.0, durgan.global_position + durgan.facing * 20.0, durgan.global_position)
	check(durgan.mode == DurganVell.Mode.GUARD and durgan._incoming_damage_multiplier(front) < 0.5, "copiou o escudo")
	durgan.hurtbox.receive_hit(front)
	await frames(2)
	check(durgan.mode == DurganVell.Mode.ATTACK, "aparou: revida")
	await seconds(1.5)
	# Vencido.
	durgan.stats.take_damage(99999.0)
	await seconds(4.5)
	check(Game.is_boss_defeated("durgan") and Game.has_item("lembranca_durgan"), "vencido: registro e lembrança")
	check(get_tree().get_nodes_in_group("plate_charges").is_empty(), "as placas apagam")
	check(find_npc("chave_de_durgan") != null, "a chave-martelo fica onde ele caiu")
	level.queue_free()
	await frames(2)


# --- Montanha Carbonizada ------------------------------------------------------------

## Fogo no chão: queima aos poucos quem fica em cima; o dash (i-frames) passa ileso.
func test_fire_patch_and_ember_shot() -> void:
	var player := spawn_player(Vector2(200, 200))
	await frames(2)
	player._iframes_left = 0.0
	var hp := player.stats.health
	var patch := FirePatch.spawn(_world, player.global_position, 14.0, 1.2, 10.0)
	await seconds(0.6)
	check(player.stats.health < hp and player.state != Player.State.STAGGER, "em cima do fogo: queima (sem cambalear)")
	player.global_position += Vector2(80, 0)
	hp = player.stats.health
	await seconds(0.6)
	check(player.stats.health == hp, "fora do fogo: nada")
	await seconds(0.3)
	check(not is_instance_valid(patch), "a chama apaga sozinha")
	# A bola de fogo deixa chamas onde bate.
	var shot := Projectile.launch(_world, Vector2(100, 200), Vector2.RIGHT, null, 10.0, 200.0, 60.0, Projectile.FIRE)
	check(shot.element == Projectile.FIRE, "bola de fogo (brasa)")
	await seconds(0.5)
	check(not get_tree().get_nodes_in_group("fire_patches").is_empty(), "onde a bola de fogo para, o chão pega fogo")
	# Quem atirou morreu com a bola no ar (o soak achou este erro): ela cai e queima normalmente.
	var shooter := spawn_enemy_scene(ATIRADOR_DRAGAO_SCENE, Vector2(100, 300))
	await frames(2)
	var orphan := Projectile.launch(_world, Vector2(100, 300), Vector2.RIGHT, shooter, 10.0, 200.0, 60.0, Projectile.FIRE)
	shooter.free()
	var patches := get_tree().get_nodes_in_group("fire_patches").size()
	await seconds(0.5)
	check(not is_instance_valid(orphan) and get_tree().get_nodes_in_group("fire_patches").size() >= patches, "atirador morto: a bola cai sem erro")


func test_dragonoid_shooter() -> void:
	var player := spawn_player(Vector2(300, 200))
	var shooter := spawn_enemy_scene(ATIRADOR_DRAGAO_SCENE, Vector2(190, 200)) as DragonoideAtirador
	player._iframes_left = 999.0
	await seconds(0.3)
	check(shooter.ai == DragonoideAtirador.AI.AIM, "viu: mira (linha)")
	var embers := [0]
	for i in 90:
		await frames(1)
		for node in get_tree().get_nodes_in_group("projectiles"):
			if (node as Projectile).element == Projectile.FIRE:
				embers[0] = maxi(embers[0], get_tree().get_nodes_in_group("projectiles").size())
	check(embers[0] >= 2, "rajada de bolas de fogo (%d no ar)" % embers[0])
	# Colado nele: coronhada e pulo para trás.
	player.global_position = shooter.global_position + Vector2(14, 0)
	shooter._cooldown = 0.0
	shooter._set_ai(DragonoideAtirador.AI.KEEP)
	await frames(3)
	check(shooter.ai == DragonoideAtirador.AI.MELEE, "colado: coronhada")


func test_beast_charge_and_daze() -> void:
	var player := spawn_player(Vector2(260, 200))
	add_wall(Rect2(300, 120, 16, 160))
	var beast := spawn_enemy_scene(BESTIAL_SCENE, Vector2(160, 200)) as DragaoBestial
	await seconds(0.3)
	check(beast.ai == DragaoBestial.AI.AIM, "abaixa a cabeça: linha de investida")
	player._iframes_left = 0.0
	var hp := player.stats.health
	var deadline := 3.0
	while beast.ai != DragaoBestial.AI.DAZED and deadline > 0.0:
		await frames(2)
		deadline -= 2.0 / 60.0
	check(player.stats.health < hp, "a investida atropela quem fica na linha")
	check(beast.ai == DragaoBestial.AI.DAZED, "bateu na parede: tonto")
	check(beast.get_collision_mask_value(2), "depois da investida volta a colidir com o herói")


func test_wyvern_dive() -> void:
	var player := spawn_player(Vector2(200, 200))
	var wyvern := spawn_enemy_scene(ALADO_SCENE, Vector2(240, 180)) as DragaoAlado
	player._iframes_left = 999.0
	await seconds(0.3)
	check(wyvern.ai == DragaoAlado.AI.CIRCLE and not wyvern.is_targetable() and wyvern.hurtbox.invulnerable, "no ar: intocável")
	wyvern._ai_time = 99.0
	await frames(2)
	check(wyvern.ai == DragaoAlado.AI.DIVE and wyvern.telegraph.circle_visible, "mergulho anunciado (círculo)")
	await seconds(wyvern.dive_warning + 0.05)
	check(wyvern.ai == DragaoAlado.AI.GROUND and wyvern.is_targetable(), "pousou: a janela para cortar")
	await seconds(wyvern.ground_time * 0.5)
	check(not get_tree().get_nodes_in_group("fire_patches").is_empty(), "cospe fogo à frente")
	await seconds(wyvern.ground_time)
	check(wyvern.ai == DragaoAlado.AI.TAKEOFF or wyvern.ai == DragaoAlado.AI.CIRCLE, "levanta voo")


func test_living_ember() -> void:
	var player := spawn_player(Vector2(200, 200))
	var ember := spawn_enemy_scene(BRASA_SCENE, Vector2(260, 200)) as BrasaViva
	player._iframes_left = 0.0
	var hp := player.stats.health
	var deadline := 3.0
	while ember.ai != BrasaViva.AI.IGNITE and deadline > 0.0:
		await frames(1)
		deadline -= 1.0 / 60.0
	check(ember.ai == BrasaViva.AI.IGNITE, "chegou perto: incha")
	var bursts := get_tree().get_nodes_in_group("flesh_bursts")
	check(bursts.size() == 1 and (bursts[0] as FleshBurst).style == "fogo", "círculo de aviso (versão fogo)")
	await seconds(ember.ignite_time + 0.1)
	check(player.stats.health < hp and not is_instance_valid(ember), "estourou e sumiu")
	check(not get_tree().get_nodes_in_group("fire_patches").is_empty(), "deixou fogo no chão")
	# Apagada antes de estourar: sem explosão.
	for node in get_tree().get_nodes_in_group("fire_patches"):
		node.queue_free()
	player.stats.revive()
	var second := spawn_enemy_scene(BRASA_SCENE, Vector2(260, 200)) as BrasaViva
	deadline = 3.0
	while second.ai != BrasaViva.AI.IGNITE and deadline > 0.0:
		await frames(1)
		deadline -= 1.0 / 60.0
	second.stats.take_damage(999.0)
	await frames(3)
	check(get_tree().get_nodes_in_group("flesh_bursts").is_empty(), "apagada a golpe: a explosão é cancelada")


func test_dragonoid_captain() -> void:
	var player := spawn_player(Vector2(140, 200))
	var captain := spawn_mini(CAPITAO_SCENE, Vector2(220, 200)) as CapitaoDragonoide
	player._iframes_left = 999.0
	await seconds(0.3)
	check(captain.active and captain.mode == CapitaoDragonoide.Mode.SHIELD, "acorda de escudo")
	captain.facing = Vector2.LEFT
	var front := HitInfo.create(20.0, captain.global_position + Vector2(-20, 0), captain.global_position)
	var back := HitInfo.create(20.0, captain.global_position + Vector2(20, 0), captain.global_position)
	check(is_equal_approx(captain._incoming_damage_multiplier(front), captain.shield_ratio), "de frente: o escudo segura")
	check(is_equal_approx(captain._incoming_damage_multiplier(back), 1.0), "pelas costas: entra inteiro")
	captain._mode_time = captain.shield_time
	await frames(2)
	check(captain.mode == CapitaoDragonoide.Mode.SWAP and captain._can_be_staggered(), "a troca de postura: a janela")
	await seconds(captain.swap_time + 0.05)
	check(captain.mode == CapitaoDragonoide.Mode.FLAME, "lança-chamas")
	player.global_position = captain.global_position + Vector2(-50, 0)
	player._iframes_left = 0.0
	var hp := player.stats.health
	await seconds(0.8)
	check(captain.in_flame(player.global_position) and player.stats.health < hp, "no cone de fogo: queima")
	check(not get_tree().get_nodes_in_group("fire_patches").is_empty(), "o chão pega fogo")
	captain.stats.take_damage(99999.0)
	await seconds(0.5)
	check(Game.is_boss_defeated("capitao"), "vencido")


func test_beast_matriarch() -> void:
	var player := spawn_player(Vector2(176, 200))
	var mother := spawn_mini(MATRIARCA_SCENE, Vector2(200, 200)) as MatriarcaBestial
	player._iframes_left = 0.0
	await seconds(0.2)
	check(mother.active, "acorda")
	var hp := player.stats.health
	mother.stomp()
	await frames(2)
	check(player.stats.health < hp, "pisoteio: quem está perto apanha")
	check(mother.pits.size() == mother.pits_per_stomp, "o chão cede (%d buracos)" % mother.pits.size())
	# Investida contra a parede: tonta.
	player.stats.revive()
	player._iframes_left = 999.0
	add_wall(Rect2(330, 100, 16, 200))
	mother.global_position = Vector2(150, 200)
	player.global_position = Vector2(270, 200)
	mother._aim = Vector2.RIGHT
	mother._set_mode(MatriarcaBestial.Mode.AIM)
	var deadline := 3.0
	while mother.mode != MatriarcaBestial.Mode.DAZED and deadline > 0.0:
		await frames(2)
		deadline -= 2.0 / 60.0
	check(mother.mode == MatriarcaBestial.Mode.DAZED and mother._can_be_staggered(), "bateu na parede: tonta")
	mother.stats.take_damage(99999.0)
	await seconds(0.5)
	check(Game.is_boss_defeated("matriarca") and mother.pits.is_empty(), "vencida: os buracos fecham")


func test_mountain_gate() -> void:
	Game.defeated_bosses.assign(["aldir", "nyssa", "mabel"])
	var level := await open_level(CIDADE, "porta")
	check(find_npc("ponte_levadica") != null, "antes de Durgan: a ponte levadiça está erguida")
	level.queue_free()
	await frames(2)
	Game.defeated_bosses.append("durgan")
	level = await open_level(CIDADE, "porta")
	var to_mountain := false
	for node in level.entities.get_children():
		if node is AreaExit and (node as AreaExit).target_scene.contains("montanha"):
			to_mountain = true
	check(to_mountain and level.spawns.has("lateral"), "depois de Durgan: a ponte baixa")
	level.queue_free()
	await frames(2)
	level = await open_level(MONTANHA, "porta")
	var back := false
	for node in level.entities.get_children():
		if node is AreaExit and (node as AreaExit).target_scene.contains("cidade") and (node as AreaExit).target_spawn == "lateral":
			back = true
	check(back, "a Montanha leva de volta à ponte da Cidade")
	check(find_npc("porta_ninho") != null, "antes da Matriarca: a trilha do Ninho está fechada")
	check(level._dialogue_variant("vendedor") == "vendedor_mabel", "o Vendedor ainda fala de Mabel")
	Game.defeated_bosses.append("capitao")
	check(level._dialogue_variant("vendedor") == "vendedor_capitao", "depois do Capitão: o Vendedor lembra da tropa")
	Game.defeated_bosses.append("rachel")
	check(level._dialogue_variant("vendedor") == "vendedor_rachel" and not DialogueData.get_entry("vendedor_rachel").get("opcoes", []).is_empty(), "depois de Rachel: fala dela (e ainda vende)")
	level.queue_free()
	await frames(2)


func test_rachel_fight() -> void:
	Game.defeated_bosses.assign(["aldir", "nyssa", "mabel", "durgan", "matriarca"])
	var level := await open_level(ARENA_RACHEL, "porta")
	var rachel := level.boss_arena.boss as RachelCaelis
	check(rachel.mode == RachelCaelis.Mode.SLEEP, "ela dorme no ninho")
	var said := []
	rachel.speech.connect(func(text: String): said.append(text))
	level.player.global_position = rachel.global_position + Vector2(0, 110)
	level.player._iframes_left = 999.0
	await seconds(0.5)
	check(rachel.active and not said.is_empty() and said[0] == RachelCaelis.SPEECH_WAKE, "acordou")
	# O hálito para na pedra: atrás do pilar, seguro.
	var cover: DestructibleCover = null
	for node in get_tree().get_nodes_in_group("covers"):
		if cover == null or (node as Node2D).global_position.distance_to(rachel.global_position) < cover.global_position.distance_to(rachel.global_position):
			cover = node
	var dir := (cover.global_position - rachel._mouth()).normalized()
	var stop := rachel.breath_hit_point(dir)
	check(stop.distance_to(rachel._mouth()) < cover.global_position.distance_to(rachel._mouth()) + 8.0, "o fogo para na pedra")
	# Hálito em quem está na frente.
	level.player.global_position = rachel.global_position + Vector2(0, 70)
	level.player._iframes_left = 0.0
	var hp := level.player.stats.health
	rachel._go_decide(99.0)
	rachel.start_breath()
	rachel._breath_from = (level.player.global_position - rachel._mouth()).angle()
	rachel._breath_to = rachel._breath_from
	await seconds(rachel.breath_windup + 0.5)
	check(level.player.stats.health < hp, "o hálito queima")
	level.player.global_position = rachel.global_position + Vector2(-110, 90)  # sai da linha (senão morre)
	await seconds(rachel.breath_time)
	check(not get_tree().get_nodes_in_group("fire_patches").is_empty(), "o chão fica em chamas")
	# Rugido: as pedras caem.
	level.player.stats.revive()
	level.player._iframes_left = 999.0
	rachel._go_decide(99.0)
	var pillars := get_tree().get_nodes_in_group("covers")
	rachel.roar()
	await frames(3)
	var broken := 0
	for node in pillars:
		if (node as DestructibleCover).broken:
			broken += 1
	check(broken >= 1, "o rugido derruba pilares (%d)" % broken)
	# A cada quarto de vida, a borda desaba.
	rachel.stats.set_health(rachel.stats.max_health * 0.7)
	await frames(3)
	check(rachel.crumbled == 1 and not rachel.edge_pits.is_empty(), "a borda cede (%d buracos)" % rachel.edge_pits.size())
	# Cauda: quem está atrás.
	rachel.facing = Vector2.UP
	level.player.global_position = rachel.global_position + Vector2(0, 30)
	rachel._go_decide(0.0)
	await frames(2)
	check(rachel.mode == RachelCaelis.Mode.TAIL, "atrás dela: a cauda")
	rachel.stats.take_damage(99999.0)
	await seconds(1.0)
	check(Game.is_boss_defeated("rachel") and Game.has_item("lembranca_rachel"), "vencida: a Lembrança do Orgulho")
	level.queue_free()
	await frames(2)


# --- Domínio Congelado -------------------------------------------------------------

## O chão escorrega: no gelo, quem para de andar continua deslizando.
func test_ice_slides() -> void:
	var player := spawn_player(Vector2(200, 200))
	await frames(2)
	player.velocity = Vector2(80, 0)
	await seconds(0.2)
	check(not player.on_ice and player.velocity.length() < 5.0, "no chão normal: para na hora")
	FrostZone.spawn(_world, Rect2(Vector2(100, 150), Vector2(300, 100)), 0.01, 5.0, 0)
	await frames(3)
	check(player.on_ice, "em cima da geada: gelo")
	player.velocity = Vector2(80, 0)
	await seconds(0.2)
	check(player.velocity.length() > 40.0, "no gelo: continua deslizando (%.0f)" % player.velocity.length())


func test_frost_shard_chills() -> void:
	var player := spawn_player(Vector2(200, 200))
	await frames(2)
	player._iframes_left = 0.0
	Projectile.launch(_world, Vector2(150, 200), Vector2.RIGHT, null, 10.0, 300.0, 200.0, Projectile.FROST)
	await seconds(0.3)
	check(player.is_chilled(), "o estilhaço de gelo deixa lento")
	await seconds(Projectile.FROST_CHILL + 0.1)
	check(not player.is_chilled(), "e passa")


func test_ice_block_taps() -> void:
	var player := spawn_player(Vector2(200, 200))
	await frames(2)
	var block := IceBlock.trap(player, 4)
	check(block != null and player.is_grabbed_by(block), "preso no bloco de gelo")
	for i in 4:
		await tap(&"attack")
	await frames(3)
	check(not player.is_grabbed() and not is_instance_valid(block), "toques rápidos: o bloco quebra")
	# Sem tocar nada, derrete sozinho.
	await seconds(1.0)
	block = IceBlock.trap(player, 99, 0.6)
	await seconds(0.8)
	check(not player.is_grabbed(), "derrete sozinho")
	# O dash na hora certa escapa.
	player._iframes_left = 1.0
	check(IceBlock.trap(player, 4) == null, "de dash (i-frames): não prende")


func test_frost_zone_traps() -> void:
	var player := spawn_player(Vector2(200, 200))
	await frames(2)
	player._iframes_left = 0.0
	var hp := player.stats.health
	var zone := FrostZone.spawn(_world, Rect2(Vector2(180, 180), Vector2(40, 40)), 0.4, 2.0, 5)
	zone.damage = 10.0
	await seconds(0.2)
	check(not zone.is_frozen() and not player.is_grabbed(), "ainda é aviso")
	await seconds(0.3)
	check(zone.is_frozen() and player.is_grabbed() and player.stats.health < hp, "congelou com você dentro: preso (e dói)")
	player.release_grab(false)
	await seconds(1.0)
	var outside := FrostZone.spawn(_world, Rect2(Vector2(300, 300), Vector2(40, 40)), 0.2, 1.0, 5)
	await seconds(0.4)
	check(outside.is_frozen() and not player.is_grabbed(), "fora da área: nada")


func test_ice_librarian() -> void:
	var player := spawn_player(Vector2(300, 200))
	var librarian := spawn_enemy_scene(BIBLIOTECARIO_SCENE, Vector2(190, 200)) as BibliotecarioGelo
	player._iframes_left = 999.0
	await seconds(0.3)
	check(librarian.ai == BibliotecarioGelo.AI.AIM, "mira (linha)")
	var shards := [0]
	for i in 80:
		await frames(1)
		for node in get_tree().get_nodes_in_group("projectiles"):
			if (node as Projectile).element == Projectile.FROST:
				shards[0] += 1
	check(shards[0] > 0, "lança estilhaços de gelo")
	librarian._set_ai(BibliotecarioGelo.AI.KEEP)
	player.global_position = librarian.global_position + Vector2(20, 0)
	var start := librarian.global_position.distance_to(player.global_position)
	await seconds(0.6)
	check(librarian.global_position.distance_to(player.global_position) > start + 15.0, "chegou perto: ele foge")


func test_living_statue() -> void:
	var player := spawn_player(Vector2(200, 200))
	var statue := spawn_enemy_scene(ESTATUA_SCENE, Vector2(280, 200)) as EstatuaViva
	player._iframes_left = 999.0
	player.facing = Vector2.RIGHT  # olhando para ela
	await seconds(0.5)
	check(statue.is_stone() and statue.global_position.x > 279.0, "olhando: é pedra, não se mexe")
	var info := HitInfo.create(20.0, player.global_position, statue.global_position)
	check(is_equal_approx(statue._incoming_damage_multiplier(info), statue.stone_damage_ratio), "pedra: o golpe quase não entra")
	player.facing = Vector2.LEFT  # de costas
	await seconds(0.4)
	check(not statue.is_stone() and statue.global_position.x < 270.0, "de costas: ela anda")
	check(is_equal_approx(statue._incoming_damage_multiplier(info), 1.0), "andando: o golpe entra inteiro")
	player.facing = Vector2.RIGHT
	await frames(3)
	check(statue.is_stone(), "virou de novo: congela no meio do passo")
	player.facing = Vector2.LEFT
	player._iframes_left = 0.0
	var hp := player.stats.health
	await seconds(1.5)
	check(player.stats.health < hp, "de costas por tempo demais: o golpe chega")


func test_crystal_mite() -> void:
	var player := spawn_player(Vector2(200, 200))
	var mite := spawn_enemy_scene(ACARO_SCENE, Vector2(260, 200)) as AcaroCristal
	player._iframes_left = 0.0
	var deadline := 3.0
	while not mite.is_clinging() and deadline > 0.0:
		await frames(1)
		deadline -= 1.0 / 60.0
	check(mite.is_clinging(), "pulou e grudou")
	var stamina := player.stats.stamina
	var hp := player.stats.health
	await seconds(0.8)
	check(player.stats.stamina < stamina - 5.0 and player.stats.health == hp, "grudado: bebe estamina (não vida)")
	player._start_dash()
	await frames(2)
	check(not mite.is_clinging() and mite.ai == AcaroCristal.AI.FALLEN, "o dash sacode: cai tonto")


func test_arcane_apprentice() -> void:
	var player := spawn_player(Vector2(200, 200))
	var apprentice := spawn_enemy_scene(APRENDIZ_SCENE, Vector2(240, 200)) as AprendizArcano
	player._iframes_left = 999.0
	await frames(3)
	var hp := apprentice.stats.health
	var light := HitInfo.create(10.0, player.global_position, apprentice.global_position)
	apprentice._on_hit_received(light)
	check(apprentice.stats.health == hp and apprentice.has_shield(), "a bolha segura o corte leve")
	var heavy := HitInfo.create(20.0, player.global_position, apprentice.global_position)
	heavy.is_heavy = true
	apprentice._on_hit_received(heavy)
	check(not apprentice.has_shield() and apprentice.ai == AprendizArcano.AI.DAZED, "golpe forte: a bolha parte e ele fica atordoado")
	apprentice._on_hit_received(light)
	check(apprentice.stats.health < hp, "sem a bolha: o golpe entra")
	# O anel de gelo: perto, dano e lentidão.
	apprentice._set_ai(AprendizArcano.AI.APPROACH)
	apprentice._cooldown = 0.0
	player.global_position = apprentice.global_position + Vector2(-16, 0)
	player._iframes_left = 0.0
	var php := player.stats.health
	await seconds(apprentice.nova_windup + 0.3)
	check(player.stats.health < php and player.is_chilled(), "o anel de gelo acerta e gela")


func test_curator() -> void:
	var player := spawn_player(Vector2(160, 200))
	var curator := spawn_mini(CURADORA_SCENE, Vector2(230, 200)) as CuradoraVitrines
	await seconds(0.3)
	check(curator.active, "acorda")
	player._iframes_left = 0.0
	curator._go_decide(99.0)
	var case := curator.open_case()
	check(case.covers(player.global_position), "a vitrine em volta do herói")
	await seconds(curator.case_warning + 0.1)
	check(player.is_grabbed() and curator.mode == CuradoraVitrines.Mode.CATALOG, "ficou dentro: preso — ela vem catalogar")
	for i in curator.case_taps:
		await tap(&"attack")
	await frames(3)
	check(not player.is_grabbed(), "quebrou o bloco")
	await frames(3)
	check(curator.mode != CuradoraVitrines.Mode.CATALOG, "saiu antes da pancada: ela desiste")
	curator.stats.take_damage(99999.0)
	await seconds(0.5)
	check(Game.is_boss_defeated("curadora"), "vencida")


func test_archive_golem() -> void:
	Game.defeated_bosses.assign(["aldir", "nyssa", "mabel", "durgan", "rachel", "curadora"])
	var level := await open_level(DOMINIO, "porta")
	var golem: GolemArquivo = null
	for node in level.entities.get_children():
		if node is GolemArquivo:
			golem = node
	level.player.global_position = golem.global_position + Vector2(-30, 10)
	level.player._iframes_left = 0.0
	await seconds(0.4)
	check(golem.active, "acorda")
	var hp := level.player.stats.health
	golem._go_decide(99.0)
	golem.slam()
	await frames(3)
	check(level.player.stats.health < hp, "o pilão acerta quem está perto")
	check(not get_tree().get_nodes_in_group("frost_zones").is_empty(), "e o chão em volta congela")
	golem._aim = Vector2.LEFT
	golem.throw_books()
	var books := 0
	for node in get_tree().get_nodes_in_group("projectiles"):
		if (node as Projectile).element == Projectile.TOME:
			books += 1
	check(books == golem.book_count, "leque de livros (%d)" % books)
	golem.stats.take_damage(99999.0)
	await seconds(0.6)
	check(Game.is_boss_defeated("golem_arquivo") and find_npc("livro_do_arquivo") != null, "vencido: o livro do Arquivo fica no chão")
	var opened := false
	for node in level.entities.get_children():
		if node is AreaExit and (node as AreaExit).target_scene.contains("arena_cassian"):
			opened = true
	check(opened, "a porta do Arconte abre na hora")
	level.queue_free()
	await frames(2)
	level = await open_level(DOMINIO, "porta")
	check(find_npc("livro_do_arquivo") != null, "o livro continua lá depois de voltar")
	level.queue_free()
	await frames(2)


func test_frozen_domain_gate() -> void:
	Game.defeated_bosses.assign(["aldir", "nyssa", "mabel", "durgan"])
	var level := await open_level(MONTANHA, "porta")
	check(find_npc("tunel_de_gelo") != null, "antes de Rachel: o túnel de gelo está fechado")
	level.queue_free()
	await frames(2)
	Game.defeated_bosses.append("rachel")
	level = await open_level(MONTANHA, "porta")
	var to_ice := false
	for node in level.entities.get_children():
		if node is AreaExit and (node as AreaExit).target_scene.contains("dominio"):
			to_ice = true
	check(to_ice and level.spawns.has("oeste"), "depois de Rachel: o túnel abre")
	level.queue_free()
	await frames(2)
	level = await open_level(DOMINIO, "porta")
	var back := false
	for node in level.entities.get_children():
		if node is AreaExit and (node as AreaExit).target_scene.contains("montanha") and (node as AreaExit).target_spawn == "oeste":
			back = true
	check(back, "o Domínio leva de volta ao túnel da Montanha")
	check(find_npc("porta_arconte") != null, "antes do Golem: a porta do Arconte está fechada")
	check(level._dialogue_variant("estudioso") == "estudioso", "o Estudioso ainda está congelado")
	Game.defeated_bosses.append("curadora")
	check(level._dialogue_variant("estudioso") == "estudioso_livre", "a Curadora caiu: ele está livre")
	Game.defeated_bosses.append("golem_arquivo")
	check(level._dialogue_variant("estudioso") == "estudioso_livro", "depois do Golem: lê o relatório")
	Game.defeated_bosses.append("cassian")
	check(level._dialogue_variant("estudioso") == "estudioso_cassian", "depois de Cassian: o gelo pinga")
	level.queue_free()
	await frames(2)


func test_cassian_fight() -> void:
	Game.defeated_bosses.assign(["aldir", "nyssa", "mabel", "durgan", "rachel", "golem_arquivo"])
	var level := await open_level(ARENA_CASSIAN, "porta")
	var cassian := level.boss_arena.boss as CassianVirel
	var said := []
	cassian.speech.connect(func(text: String): said.append(text))
	level.player.global_position = cassian.global_position + Vector2(0, 100)
	level.player._iframes_left = 999.0
	await seconds(0.5)
	check(cassian.active and not said.is_empty() and said[0] == CassianVirel.SPEECH_INTRO, "a luta começa")
	check(level.ice_cells.size() > 40, "a sala tem faixas de gelo")
	# Geada em volta do herói.
	cassian._go_decide(99.0)
	cassian.frost()
	check(get_tree().get_nodes_in_group("frost_zones").size() >= cassian.frost_count, "geada: retângulos no chão")
	# Pilares de gelo que derretem sozinhos.
	var pillars := cassian.raise_walls()
	check(pillars.size() == cassian.wall_count and not pillars[0].broken, "pilares de gelo entre os dois")
	await seconds(cassian.wall_life + 0.3)
	check(pillars.all(func(p): return not is_instance_valid(p) or p.broken), "derretem sozinhos")
	# Colou nele: some e reaparece longe.
	cassian.global_position = level.player.global_position + Vector2(0, -20)
	var before := cassian.global_position
	cassian.blink()
	check(cassian.global_position.distance_to(level.player.global_position) > 60.0 and cassian.global_position != before, "piscou para longe")
	# Fase 2 sem pular.
	cassian.stats.take_damage(99999.0)
	await frames(2)
	check(cassian.phase == 2 and is_equal_approx(cassian.stats.health_ratio(), 0.5), "não pula o Colecionador")
	await seconds(2.3)
	check(cassian.mode != CassianVirel.Mode.TRANSITION and cassian.phase_label() == "O Colecionador", "fase 2 começa")
	# Congela metade da arena com o herói dentro.
	level.player._iframes_left = 0.0
	cassian._go_decide(99.0)
	var zone := cassian.freeze_half()
	check(zone.covers(level.player.global_position), "a metade congelada é a sua")
	await seconds(cassian.freeze_warning + 0.1)
	check(level.player.is_grabbed(), "ficou: vira peça da coleção")
	level.player.release_grab(false)
	await frames(2)
	# Estátuas da coleção (sem pagar memórias).
	cassian.summon()
	await frames(2)
	check(cassian.statues.size() == cassian.max_statues and cassian.statues[0].memory_reward == 0, "invoca as estátuas")
	# Roubo de estamina (sem as estátuas por perto: um golpe delas daria i-frames).
	for statue in cassian.statues:
		statue.stats.take_damage(99999.0)
	await seconds(1.0)
	level.player._iframes_left = 0.0
	cassian._go_decide(99.0)
	cassian.start_steal()
	await seconds(cassian.steal_aim + 0.1)
	check(level.player.stats.stamina < 1.0, "o raio rouba a estamina")
	await seconds(1.5)
	check(level.player.stats.stamina < 1.0, "e ela demora a voltar")
	cassian.stats.take_damage(99999.0)
	await seconds(1.0)
	check(Game.is_boss_defeated("cassian") and Game.has_item("lembranca_cassian"), "vencido: a Lembrança da Ganância")
	check(cassian.statues.all(func(st): return not is_instance_valid(st) or st.dead), "a coleção se desfaz com ele")
	level.queue_free()
	await frames(2)


# --- O Núcleo -------------------------------------------------------------------------

func test_seven_memories_gate() -> void:
	Game.defeated_bosses.assign(["aldir", "nyssa", "mabel", "durgan", "rachel", "cassian"])
	check(Game.seven_memories() == 6 and not Game.requirement_met("sete"), "seis memórias: ainda não")
	var level := await open_level(TEATRO, "porta")
	check(find_npc("escada_de_luz") != null, "o vão no palco ainda não leva a lugar nenhum")
	level.queue_free()
	await frames(2)
	Game.defeated_bosses.append("helena")
	check(Game.seven_memories() == 7 and Game.requirement_met("sete"), "as sete memórias")
	level = await open_level(TEATRO, "porta")
	var to_core := false
	for node in level.entities.get_children():
		if node is AreaExit and (node as AreaExit).target_scene.contains("nucleo"):
			to_core = true
	check(to_core and level.spawns.has("palco"), "a escada de luz se abre")
	level.queue_free()
	await frames(2)


func test_core_garden() -> void:
	Game.defeated_bosses.assign(Game.SEVEN)
	var level := await open_level(NUCLEO, "porta")
	for id in ["estatua_ira", "estatua_preguica", "estatua_gula", "estatua_inveja", "estatua_orgulho", "estatua_ganancia", "estatua_luxuria"]:
		check(find_npc(id) != null, "a estátua: %s" % id)
	check(get_tree().get_nodes_in_group("enemies").is_empty(), "o jardim é silencioso: nenhum inimigo")
	var back := false
	var forward := false
	for node in level.entities.get_children():
		if node is AreaExit:
			back = back or ((node as AreaExit).target_scene.contains("teatro") and (node as AreaExit).target_spawn == "palco")
			forward = forward or (node as AreaExit).target_scene.contains("coracao")
	check(back and forward, "volta ao palco do Teatro; segue para o Coração")
	level.queue_free()
	await frames(2)


func test_knight_fight() -> void:
	Game.defeated_bosses.assign(Game.SEVEN)
	var level := await open_level(CORACAO, "porta")
	var knight := level.boss_arena.boss as CavaleiroDesolado
	var woman := get_tree().get_first_node_in_group(&"nucleo_core") as Node2D
	var said := []
	knight.speech.connect(func(text: String): said.append(text))
	level.player.global_position = knight.global_position + Vector2(40, 100)
	level.player._iframes_left = 999.0
	await seconds(0.5)
	check(knight.active and not said.is_empty() and said[0] == CavaleiroDesolado.SPEECH_INTRO, "ele se levanta")
	check(knight.woman == woman, "sabe quem protege")
	var point := knight.guard_point()
	var her_to_you := (level.player.global_position - woman.global_position).normalized()
	check(her_to_you.dot((point - woman.global_position).normalized()) > 0.99, "o lugar dele: entre você e ela")
	# Três golpes seguidos: a guarda (de frente quase nada entra).
	knight._go_decide(99.0)
	for i in 3:
		var hit := HitInfo.create(5.0, knight.global_position + knight.facing * 20.0, knight.global_position)
		knight.hurtbox.receive_hit(hit)
	check(knight.mode == CavaleiroDesolado.Mode.GUARD, "apanhou três vezes: ergue a guarda")
	var front := HitInfo.create(10.0, knight.global_position + knight.facing * 20.0, knight.global_position)
	check(is_equal_approx(knight._incoming_damage_multiplier(front), knight.guard_ratio), "a guarda segura de frente")
	# A gravidade puxa quem está longe.
	knight._go_decide(99.0)
	level.player._iframes_left = 0.0
	level.player.global_position = knight.global_position + Vector2(0, 140)
	var far := level.player.global_position.distance_to(knight.global_position)
	knight.start_pull()
	await seconds(knight.pull_windup + 0.8)
	check(level.player.global_position.distance_to(knight.global_position) < far - 20.0, "a gravidade puxa você para perto")
	# Metade da vida: a Promessa (sem pular).
	level.player._iframes_left = 999.0
	knight.stats.take_damage(99999.0)
	await frames(2)
	check(knight.phase == 2 and is_equal_approx(knight.stats.health_ratio(), 0.5), "não pula a Promessa")
	await seconds(2.3)
	check(knight.mode != CavaleiroDesolado.Mode.TRANSITION and knight.phase_label() == "A Promessa", "fase 2 começa")
	knight._go_decide(99.0)
	knight.rain_stones()
	var stones := get_tree().get_nodes_in_group("flesh_bursts")
	# (>=: ele pode já ter chamado uma chuva sozinho logo depois da transição)
	check(stones.size() >= knight.stone_count and stones.all(func(b): return (b as FleshBurst).style == "pedra"), "pedras caem do alto")
	await seconds(1.8)
	# O elo: ajoelhado, ele se cura — a não ser que você fique no caminho da luz.
	knight.global_position = woman.global_position + Vector2(0, 30)
	knight.stats.set_health(knight.stats.max_health * 0.3)
	level.player.global_position = woman.global_position + Vector2(60, 60)
	knight.start_kneel()
	await seconds(1.4)
	var healed := knight.stats.health_ratio()
	check(healed > 0.3 and knight.is_kneeling(), "ajoelhado diante dela: a luz o cura")
	level.player.global_position = woman.global_position + Vector2(0, 15)
	await frames(2)
	check(knight.bond_blocked(), "você no caminho da luz")
	var before := knight.stats.health
	await seconds(0.8)
	check(knight.stats.health == before, "no caminho: a cura para")
	knight.stats.take_damage(99999.0)
	await seconds(1.0)
	check(Game.is_boss_defeated("cavaleiro") and is_instance_valid(knight), "vencido — e ele fica, ajoelhado")
	var choice := level._dialogue_variant("mulher_do_nucleo")
	check(choice == "a_escolha" and DialogueData.get_entry(choice).get("opcoes", []).size() == 3, "a escolha: proteger, destruir, ainda não")
	level.queue_free()
	await frames(2)


func test_endings() -> void:
	Game.defeated_bosses.assign(Game.SEVEN + ["cavaleiro"])
	var level := await open_level(CORACAO, "porta")
	# Como no jogo: a escolha chega com o diálogo aberto (mundo pausado).
	level._begin_modal()
	check(get_tree().paused, "o diálogo pausa o mundo")
	level._on_dialogue_action("final_destruir")
	await seconds(6.0)
	check(not get_tree().paused, "a cena final não fica congelada pela pausa do diálogo")
	check(Game.last_scene_request == Game.ENDING_SCENE and Game.flags.get("final") == "destruir", "romper o elo: o final Ruptura")
	check(Game.flags.get("finais_vistos", []).has("destruir"), "o save lembra quais finais você viu")
	level.queue_free()
	await frames(2)
	for kind in ["proteger", "destruir"]:
		Game.flags["final"] = kind
		var ending := ENDING_SCENE.instantiate()
		add_child(ending)
		await frames(2)
		check(ending.kind == kind and ending.LINES[kind].size() >= 5, "a tela final: %s" % kind)
		for i in 900:
			ending._skip = true
			await frames(1)
			if ending._done:
				break
		check(ending._done, "tocando na tela, chega aos créditos (%s)" % kind)
		ending.queue_free()
		await frames(2)

