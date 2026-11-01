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
const QUARTEL := "res://scenes/world/cidade_quartel.tscn"
const VIADUTO := "res://scenes/world/cidade_viaduto.tscn"
const TORRE := "res://scenes/world/cidade_torre.tscn"
const DORMITORIO := "res://scenes/world/bosque_dormitorio.tscn"
const SLEEPER_SCENE_FOR_TEST := preload("res://scenes/enemies/sonambulo.tscn")
const BORDA := "res://scenes/world/bosque_borda.tscn"
const SALA_SINO := "res://scenes/world/bosque_sino.tscn"
const FORNALHA := "res://scenes/world/forjas_fornalha.tscn"
const PASSARELA := "res://scenes/world/forjas_passarela.tscn"
const SALA_DANCARINA := "res://scenes/world/forjas_dancarina.tscn"
const DESPENSA := "res://scenes/world/raizes_despensa.tscn"
const VARANDA := "res://scenes/world/raizes_varanda.tscn"
const ENFERMARIA := "res://scenes/world/raizes_enfermaria.tscn"
const OSSARIO := "res://scenes/world/montanha_ossario.tscn"
const ENCOSTA := "res://scenes/world/montanha_encosta.tscn"
const FOSSO := "res://scenes/world/montanha_fosso.tscn"
const ARQUIVO := "res://scenes/world/dominio_arquivo.tscn"
const GALERIA := "res://scenes/world/dominio_galeria.tscn"
const AULA := "res://scenes/world/dominio_aula.tscn"
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
	Settings.persistence_enabled = false  # nunca grava opções no aparelho de quem roda os testes
	Game.save_path = TEST_SAVE
	Game.slot_prefix = "user://teste_slot_"  # os 3 saves dos testes nunca tocam nos seus
	for n in range(1, Game.SLOT_COUNT + 1):
		for suffix in ["", ".bak", ".tmp"]:
			DirAccess.remove_absolute(ProjectSettings.globalize_path(Game.slot_path(n) + suffix))
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
		"test_city_expansion",
		"test_corneteiro_silences_city",
		"test_arena_shift_fire_ring",
		"test_bosque_expansion",
		"test_breathing_flowers",
		"test_sino_despertar",
		"test_nyssa_nightmare_arena",
		"test_forjas_expansion",
		"test_dancarina",
		"test_durgan_replays_combo",
		"test_raizes_expansion",
		"test_feast_tables",
		"test_socorro",
		"test_mabel_inhale",
		"test_montanha_expansion",
		"test_ultimo_igual",
		"test_rachel_dive",
		"test_dominio_expansion",
		"test_still_trap",
		"test_mestre_arconte",
		"test_cassian_collects_flasks",
		"test_name_entry_screen",
		"test_name_in_anger_and_terminal",
		"test_name_reactions_and_ng_plus",
		"test_lucia_journey",
		"test_lucia_ally_falls_and_sleeps",
		"test_lucia_final",
		"test_galeno_journey",
		"test_brawlers_help",
		"test_bridge_fight_choices",
		"test_sebastioes_duel",
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
		"test_settings",
		"test_options_menu",
		"test_tutorial_hints",
		"test_release_secrets_stay_out",
		"test_version_consistency",
		"test_heitor_rescues",
		"test_helena_drunk_visits",
		"test_helena_fury_with_heitor",
		"test_helena_recognizes_ring",
		"test_title_souls_style",
		"test_controller_mode",
		"test_pad_mapping_and_interact",
		"test_appearance_atlas",
		"test_appearance_save_and_player",
		"test_character_creation_screen",
		"test_weapon_catalog",
		"test_weapon_forge_and_equip",
		"test_weapon_damage_matches_sheet",
		"test_weapon_skills_melee",
		"test_weapon_skills_ranged",
		"test_smith_forge_tab",
		"test_parryable_flags",
		"test_parry_and_riposte",
		"test_backstab",
		"test_hand_modes",
		"test_paired_and_dual_attacks",
		"test_two_hands",
		"test_touch_follows_hands",
		"test_pad_menus_never_stuck",
		"test_sprint_hold_circle",
		"test_rest_menu_and_travel",
		"test_rest_menu_pad_navigation",
		"test_stepper_rows_on_pad",
		"test_graphics_setting",
		"test_grid_menus_on_pad",
		"test_starting_bow_and_spear_attacks",
		"test_slain_enemies_stay_dead_until_rest",
		"test_sniper_friendly_fire",
		"test_conditions_language",
		"test_listed_exits_open_by_flag",
		"test_world_objects_remember",
		"test_zones_alarm_and_spawn_rules",
		"test_periodic_trap",
		"test_dialogue_conditions_and_name",
		"test_ally_base_levels_and_arena",
		"test_free_map_layout",
		"test_area_power",
		"test_second_capsule_per_island",
		"test_chests_open_and_break",
		"test_mimic",
		"test_lab_capsule_after_prologue",
		"test_armor_defense",
		"test_equip_load_and_roll",
		"test_save_slots",
		"test_title_with_slots",
		"test_weapon_drops",
		"test_shop_buy_and_sell",
		"test_clean_controls_mode",
		"test_pad_confirms_menus",
		"test_armor_rules",
		"test_armor_in_world_and_menu",
		"test_farm_calf_seven_hits",
		"test_farm_minotaur_cycle",
		"test_ng_weapon_on_the_floor",
		"test_ng_difficulty",
		"test_ng_new_journey",
		"test_ng_guardian_fight",
		"test_ng_ending_choices",
		"test_capsule_enter_and_exit",
		"test_opening_video",
		"test_pad_style",
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
	for action in ["move_left", "move_right", "move_up", "move_down", "attack", "attack_heavy", "dash", "heal", "sanity", "block", "special", "inventory"]:
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
	for path in ["res://scenes/world/teatro.tscn", "res://scenes/world/cidade.tscn", "res://scenes/world/arena_aldir.tscn", PROLOGO, BOSQUE, ARENA_NYSSA, QUARTEL, VIADUTO, TORRE, DORMITORIO, BORDA, SALA_SINO]:
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
			check(lore == 8, "Prólogo: 7 pontos de inspeção + a placa da cápsula (%d)" % lore)
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
		elif path == BOSQUE:
			var kinds := {}
			for node in level.get_tree().get_nodes_in_group("respawnable"):
				var kind: String = node.get_script().get_global_name()
				kinds[kind] = kinds.get(kind, 0) + 1
			check(kinds == {"Sonambulo": 5, "FlorDePolen": 5, "CervoDeMusgo": 2, "FadaMurcha": 2}, "Bosque: inimigos (%s)" % kinds)
			var minis := []
			for node in level.get_tree().get_nodes_in_group("minibosses"):
				minis.append(str(node.get_script().get_global_name()))
			minis.sort()
			# v0.35: o Vigia mudou para o Dormitório e a Mãe para a Borda.
			check(minis.is_empty(), "Margem: os mini-chefes saíram para as fases anexas (%s)" % [minis])
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
			check(lore == 5, "Margem: lore, a espinha trancada e a placa da cápsula (%d)" % lore)
			var items := 0
			for node in level.entities.get_children():
				if node is ItemPickup:
					items += 1
			check(items == 5, "Bosque: 4 itens + as botas do Arconte (%d)" % items)
		elif path.contains("teatro"):
			check(level.rest_chamber != null, "Teatro: tem a Câmara de descanso")
			check(level.spawns.has("camara"), "Teatro: spawn na Câmara")
			check(level.boss_arena != null and level.boss_arena.boss != null, "Teatro: arena da Helena montada")
			check(level._fog_walls.size() == 34, "Teatro: névoa com 34 células (%d)" % level._fog_walls.size())
			var npcs := level.get_tree().get_nodes_in_group("npcs").size()
			check(npcs >= 5, "Teatro: NPCs (Fada, Vendedor, Ferreiro, Orbe, Helena) = %d" % npcs)
			check(find_npc(Level.SPARED_CHILD_TALKS) == null, "Teatro: sem a Criança Poupada (ninguém foi poupado ainda)")
		elif path.contains("cidade_") or path.contains("bosque_"):
			pass  # Quartel, Viaduto e Torre: conteúdo em test_city_expansion
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
			# v0.35: o Sargento mudou para o Quartel e a Couraça para o Viaduto.
			check(minis.is_empty(), "Avenida: os mini-chefes saíram para as fases anexas (%s)" % [minis])
			check(kinds.get("CaoDeGuerra", 0) == 3 and kinds.get("AtiradorDeTelhado", 0) == 3 and kinds.get("CivilCinzento", 0) == 7, "Cidade: 3 cães, 3 atiradores, 7 civis (2 no quartel de bombeiros) (%s)" % kinds)
			check(level.rest_chamber != null and level.spawns.has("camara"), "Cidade: Câmara de descanso perto do portão")
			check(level.spawns.has("torre"), "Cidade: chegada de quem desce da Torre")
		var min_floor := 100 if path in [TORRE, SALA_SINO] else 300  # salas pequenas de propósito
		check(level.floor_layer.get_used_cells().size() > min_floor, "%s: piso desenhado" % path)
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
	while level.hud.dialogue.visible and guard < 200:
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
	level = await open_level(VIADUTO, "porta")
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
	Game.player_name = "Teste"  # v0.41: já tem nome (a pergunta com raiva é testada à parte)
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
	# v0.30.7: herói parado na BEIRADA (logo além da distância de desistir). O
	# chefe volta para casa passando perto dele — não pode acordar/desistir em loop.
	var starts := [0]
	sarge.fight_started.connect(func(_b): starts[0] += 1)
	var home: Vector2 = sarge.home_position
	player.global_position = home + Vector2(sarge.reset_distance + 20.0, 0)
	sarge.global_position = player.global_position + Vector2(-30, 0)  # estava perseguindo até ali
	await seconds(8.0)
	check(starts[0] == 0, "na beirada ele volta para o posto sem acordar de novo (acordou %d vezes)" % starts[0])
	player.global_position = home + Vector2(60, 0)
	await seconds(1.0)
	check(starts[0] == 1 and sarge.active, "chegou perto de verdade: a luta recomeça")


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
	var smith := level.hud.smith_menu
	check(smith.visible and smith._tab == 0 and not smith._slots.is_empty(), "forja aberta na aba Reforçar")
	await _pad_press(JOY_BUTTON_A)  # ✕ no espaço da espada = reforçar
	check(Game.weapon_level == 1 and Game.memories == 50, "melhorou pela forja (nível %d, memórias %d)" % [Game.weapon_level, Game.memories])
	check(not smith.upgrade() and Game.weapon_level == 1, "sem recursos: não reforça")
	check(smith.detail_status.text.contains("memórias") or smith.detail_status.text.contains("Sucata"), "e o Ferreiro diz o que falta")
	smith._close_button.pressed.emit()
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
	check(pickups.size() == 5, "5 itens (o pertence foi para o Quartel) (%d)" % pickups.size())
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
	check(left == 4, "sobram 4 itens (%d)" % left)
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
	# v0.31 (mapa livre): a porta do Bosque já começa aberta.
	var level := await open_level("res://scenes/world/teatro.tscn", "camara")
	check(find_npc("porta_bosque_fechada") == null, "mapa livre: a porta do Bosque não tem trava")
	var exits := []
	for node in level.entities.get_children():
		if node is AreaExit and (node as AreaExit).target_scene.contains("bosque"):
			exits.append(node)
	check(exits.size() == 2 and level.spawns.has("lateral"), "a porta do Bosque está aberta (e há chegada 'lateral')")
	check(level.spawns["lateral"].x < 34 * 16, "quem volta do Bosque aparece para DENTRO do Teatro")
	level.queue_free()
	await frames(2)
	level = await open_level(BOSQUE, "porta")
	var back := false
	for node in level.entities.get_children():
		if node is AreaExit and (node as AreaExit).target_scene.contains("teatro") and (node as AreaExit).target_spawn == "lateral":
			back = true
	check(back, "o Bosque leva de volta à porta lateral do Teatro")
	level.queue_free()
	await frames(2)
	level = await open_level(BORDA, "porta")  # v0.35: a trilha da Clareira fica na Borda
	check(find_npc("espinhos_nyssa") != null, "antes da Mãe dos Esporos: os espinhos fecham a trilha")
	level.queue_free()
	await frames(2)
	Game.defeated_bosses.append("mae_esporos")
	level = await open_level(BORDA, "porta")
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
	# v0.31 (mapa livre): as Raízes ficam embaixo das Forjas (descida) e o
	# túnel de raízes leva à Cidade. A porta oeste do Teatro vai às Forjas.
	# v0.35: a descida saiu do Salão e foi para a Passarela da Âncora.
	var level := await open_level(PASSARELA, "porta")
	var down := 0
	for node in level.entities.get_children():
		if node is AreaExit and (node as AreaExit).target_scene.contains("raizes"):
			down += 1
	check(down == 1 and level.spawns.has("descida"), "das Forjas, a descida para as Raízes")
	level.queue_free()
	await frames(2)
	level = await open_level(RAIZES, "porta")
	var kinds := {}
	for node in level.entities.get_children():
		kinds[node.get_class() if node.get_script() == null else (node.get_script() as Script).get_global_name()] = true
	# v0.35: o Banqueteiro mudou para a Despensa e a Ninhada para a Varanda.
	for name in ["BocaDeRaiz", "Inchado", "Colhedor", "LarvaSeiva", "RestChamber"]:
		check(kinds.has(name), "as Raízes têm %s" % name)
	check(not kinds.has("Sonambulo"), "o mesmo 'z' do Bosque aqui é outra coisa")
	var back := false
	for node in level.entities.get_children():
		if node is AreaExit and (node as AreaExit).target_scene.contains("forjas") and (node as AreaExit).target_spawn == "descida":
			back = true
	check(back, "as Raízes sobem de volta para a descida das Forjas")
	level.queue_free()
	await frames(2)
	level = await open_level(DESPENSA, "porta")
	check(find_npc("porta_cozinha") != null, "antes do Banqueteiro: a porta dos fundos está trancada")
	level.queue_free()
	await frames(2)
	Game.defeated_bosses.append("banqueteiro")
	level = await open_level(DESPENSA, "porta")
	var to_porch := _exit_to(VARANDA) != null
	check(to_porch and find_npc("porta_cozinha") == null, "vencido o Banqueteiro: a porta da Varanda abre")
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
	for path in [RAIZES, DESPENSA, VARANDA, ENFERMARIA, ARENA_MABEL, FORJAS, FORNALHA, PASSARELA, SALA_DANCARINA, ARENA_DURGAN, MONTANHA, OSSARIO, ENCOSTA, FOSSO, ARENA_RACHEL, DOMINIO, ARQUIVO, GALERIA, AULA, ARENA_CASSIAN, NUCLEO, CORACAO]:
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
			# v0.35: o Protótipo mudou para a Fornalha e o Guardião para a Passarela.
			for name in ["AutomatoBronze", "TorretaFaisca", "MineradorOco", "Imitador", "RestChamber"]:
				check(kinds.has(name), "Forjas: tem %s" % name)
		if path == MONTANHA:
			var found := {}
			for node in level.entities.get_children():
				if node.get_script():
					found[(node.get_script() as Script).get_global_name()] = true
			# v0.35: a Matriarca mudou para o Ossário e o Capitão para a Encosta.
			for name in ["DragonoideAtirador", "DragaoBestial", "DragaoAlado", "BrasaViva", "CouracaAndante", "RestChamber"]:
				check(found.has(name), "Montanha: tem %s" % name)
		if path == DOMINIO:
			check(level.ice_cells.size() > 300, "Domínio: gelo registrado (%d)" % level.ice_cells.size())
			var kinds_ice := {}
			for node in level.entities.get_children():
				if node.get_script():
					kinds_ice[(node.get_script() as Script).get_global_name()] = true
			# v0.35: o Golem mudou para o Arquivo e a Curadora (com o Estudioso) para a Galeria.
			for name in ["BibliotecarioGelo", "EstatuaViva", "AcaroCristal", "AprendizArcano", "RestChamber"]:
				check(kinds_ice.has(name), "Domínio: tem %s" % name)
			check(find_npc("mesa_de_cha") != null, "Domínio: a mesa de chá, junto da Câmara")
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
	var level := await open_level(DESPENSA, "porta")  # v0.35: o Banqueteiro mora na Despensa
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
		if node is AreaExit and (node as AreaExit).target_scene == VARANDA:
			open = true
	check(open and level.spawns.has("lateral"), "a porta da Varanda abriu na hora")
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
	# v0.31 (mapa livre): as Forjas ficam a uma porta do Teatro (a oeste).
	var level := await open_level("res://scenes/world/teatro.tscn", "camara")
	var to_forge := false
	for node in level.entities.get_children():
		if node is AreaExit and (node as AreaExit).target_scene.contains("forjas"):
			to_forge = true
	check(to_forge and level.spawns.has("oeste"), "a porta oeste do Teatro leva às Forjas")
	level.queue_free()
	await frames(2)
	level = await open_level(FORJAS, "porta")
	var back := false
	for node in level.entities.get_children():
		if node is AreaExit and (node as AreaExit).target_scene.contains("teatro") and (node as AreaExit).target_spawn == "oeste":
			back = true
	check(back, "as Forjas levam de volta à porta oeste do Teatro")
	level.queue_free()
	await frames(2)
	level = await open_level(PASSARELA, "porta")  # v0.35: a porta da Forja do Eco fica na Passarela
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
	# v0.31 (mapa livre): a escalada no fim do Viaduto já começa livre.
	# v0.35: a escalada saiu da Avenida e foi para o fim do Viaduto Partido.
	Game.defeated_bosses.assign(["aldir", "nyssa", "mabel"])
	var level := await open_level(VIADUTO, "porta")
	check(find_npc("ponte_levadica") == null, "mapa livre: nada trava a subida para a Montanha")
	var to_mountain := false
	for node in level.entities.get_children():
		if node is AreaExit and (node as AreaExit).target_scene.contains("montanha"):
			to_mountain = true
	check(to_mountain and level.spawns.has("escalada"), "a subida para a Montanha está aberta")
	level.queue_free()
	await frames(2)
	level = await open_level(MONTANHA, "porta")
	var back := false
	for node in level.entities.get_children():
		if node is AreaExit and (node as AreaExit).target_scene == VIADUTO and (node as AreaExit).target_spawn == "escalada":
			back = true
	check(back, "a Montanha leva de volta à ponte da Cidade")
	level.queue_free()
	await frames(2)
	level = await open_level(ENCOSTA, "porta")  # v0.35: a trilha do Ninho sai da Encosta
	check(find_npc("porta_ninho") != null, "antes do Capitão: a trilha do Ninho está fechada")
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
	var level := await open_level(ARQUIVO, "porta")  # v0.35: o Golem mora no Arquivo Profundo
	for trap in get_tree().get_nodes_in_group(&"still_traps"):
		trap.queue_free()  # o teste não anda: sem as vitrines que fecham
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
		if node is AreaExit and (node as AreaExit).target_scene == GALERIA:
			opened = true
	check(opened, "a porta da Galeria abre na hora")
	level.queue_free()
	await frames(2)
	level = await open_level(ARQUIVO, "porta")
	check(find_npc("livro_do_arquivo") != null, "o livro continua lá depois de voltar")
	level.queue_free()
	await frames(2)


func test_frozen_domain_gate() -> void:
	# v0.31 (mapa livre): o Domínio fica no alto das Forjas (cascata de gelo).
	Game.defeated_bosses.assign(["aldir", "nyssa", "mabel", "durgan"])
	var level := await open_level(PASSARELA, "porta")  # v0.35: a cascata sai da Passarela
	var to_ice := false
	for node in level.entities.get_children():
		if node is AreaExit and (node as AreaExit).target_scene.contains("dominio"):
			to_ice = true
	check(to_ice and level.spawns.has("cascata"), "a cascata de gelo das Forjas sobe ao Domínio")
	level.queue_free()
	await frames(2)
	level = await open_level(DOMINIO, "porta")
	var back := false
	for node in level.entities.get_children():
		if node is AreaExit and (node as AreaExit).target_scene.contains("forjas") and (node as AreaExit).target_spawn == "cascata":
			back = true
	check(back, "do Domínio, a queda leva de volta às Forjas")
	level.queue_free()
	await frames(2)
	level = await open_level(GALERIA, "porta")  # v0.35: a porta do Arconte (e o Estudioso) na Galeria
	check(find_npc("porta_arconte") != null, "antes da Curadora: a porta do Arconte está fechada")
	check(find_npc("estudioso") != null, "o Estudioso congelado, na Galeria")
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


# --- Polimento: opções e dicas ------------------------------------------------------------

func test_settings() -> void:
	var saved := [Settings.sfx_volume, Settings.ambience_volume, Settings.vibration, Settings.button_size, Settings.hints]
	var bus := AudioServer.get_bus_index(Settings.SFX_BUS)
	check(bus != -1 and AudioServer.get_bus_index(Settings.AMBIENCE_BUS) != -1, "barramentos Efeitos e Ambiente existem")
	Settings.sfx_volume = 0.5
	Settings.step_sfx(0.1)
	check(is_equal_approx(Settings.sfx_volume, 0.6) and is_equal_approx(AudioServer.get_bus_volume_db(bus), linear_to_db(0.6)), "volume dos efeitos sobe 10% e vale no barramento")
	for i in 10:
		Settings.step_sfx(-0.1)
	check(Settings.sfx_volume == 0.0 and AudioServer.is_bus_mute(bus), "zero = mudo")
	Settings.step_sfx(5.0)
	check(Settings.sfx_volume == 1.0, "não passa de 100%")
	Settings.button_size = "Médios"
	Settings.cycle_button_size()
	check(Settings.button_size == "Grandes" and is_equal_approx(Settings.button_scale(), 1.2), "botões grandes")
	var vib := Settings.vibration
	Settings.toggle_vibration()
	check(Settings.vibration != vib, "vibração liga e desliga")
	Settings.sfx_volume = saved[0]
	Settings.ambience_volume = saved[1]
	Settings.vibration = saved[2]
	Settings.button_size = saved[3]
	Settings.hints = saved[4]
	Settings.apply()


func test_options_menu() -> void:
	var saved_size := Settings.button_size
	var level := await open_level(TEATRO, "camara")
	var hud := level.hud
	var touch := hud.touch
	var base := float(touch.attack_button.get_meta(&"base_radius"))
	Settings.button_size = "Grandes"
	Settings.apply()
	await frames(2)
	check(is_equal_approx(touch.attack_button.radius, base * 1.2), "Opções → os botões de toque crescem")
	Settings.button_size = saved_size
	Settings.apply()
	hud.pause_menu.open()
	await frames(2)
	var labels := []
	for node in hud.pause_menu.find_children("*", "Button", true, false):
		labels.append((node as Button).text)
	check(labels.has("Opções"), "a pausa tem Opções (%s)" % [labels])
	hud.pause_menu._open_options()
	await frames(2)
	var options := hud.pause_menu._options as OptionsMenu
	check(options.is_open() and not hud.pause_menu.visible, "as opções abrem por cima da pausa")
	check((options._rows["efeitos"] as Label).text.ends_with("%"), "mostra o volume em %")
	options.close()
	await frames(2)
	check(hud.pause_menu.visible and get_tree().paused, "fechou: volta para a pausa")
	hud.pause_menu.close()
	level.queue_free()
	await frames(2)


func test_tutorial_hints() -> void:
	var saved := Settings.hints
	Settings.hints = true
	var level := await open_level(CIDADE, "porta")
	var hints := level.hud.hints
	await seconds(2.0)
	check(hints.seen("andar"), "primeira dica: andar")
	var enemy := spawn_enemy_scene(SOLDIER_SCENE, level.player.global_position + Vector2(60, 0))
	await seconds(6.0)
	check(hints.seen("atacar"), "inimigo perto: como atacar")
	enemy.queue_free()
	level.player.hurt.emit(5.0)
	await seconds(6.0)
	check(hints.seen("esquivar"), "levou um golpe: como esquivar")
	var count: int = (Game.flags.get("dicas", []) as Array).size()
	hints.want("andar")
	await seconds(6.0)
	check((Game.flags.get("dicas", []) as Array).size() == count, "cada dica aparece uma vez só")
	Settings.hints = false
	level.player.stats.set_health(level.player.stats.max_health * 0.3)
	await seconds(6.0)
	check(not hints.seen("curar"), "dicas desligadas nas Opções: nenhuma")
	Settings.hints = saved
	level.queue_free()
	await frames(2)


# --- Publicação ------------------------------------------------------------------------

## A chave de PUBLICAÇÃO e a senha dela nunca podem morar no projeto (nem no
## Git, nem no zip). Só a chave de depuração do projeto (pública) pode.
func test_release_secrets_stay_out() -> void:
	var keys: Array[String] = []
	_collect_keys("res://", keys)
	check(keys == ["res://keystore/debug.keystore"], "só a chave de depuração está no projeto (%s)" % [keys])
	var presets := FileAccess.get_file_as_string("res://export_presets.cfg")
	for line in presets.split("\n"):
		var clean := line.strip_edges()
		if clean.begins_with("keystore/release") and not clean.ends_with("=\"\""):
			check(false, "export_presets.cfg guarda a chave/senha de publicação: %s" % clean.get_slice("=", 0))
	check(presets.contains("name=\"Android AAB\"") and presets.contains("gradle_build/export_format=1"), "existe o preset do AAB (Play Store)")


func _collect_keys(path: String, out: Array[String]) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	dir.include_hidden = false
	for sub in dir.get_directories():
		if sub in [".godot", ".git", "build", "android"]:
			continue
		_collect_keys(path.path_join(sub), out)
	for file in dir.get_files():
		if file.ends_with(".keystore") or file.ends_with(".jks"):
			out.append(path.path_join(file).replace("res:///", "res://"))


## A versão do jogo aparece em três lugares; os três têm de concordar.
func test_version_consistency() -> void:
	var version := str(ProjectSettings.get_setting("application/config/version"))
	var presets := FileAccess.get_file_as_string("res://export_presets.cfg")
	var names := []
	var codes := []
	for line in presets.split("\n"):
		if line.begins_with("version/name="):
			names.append(line.get_slice("=", 1).trim_prefix("\"").trim_suffix("\""))
		if line.begins_with("version/code="):
			codes.append(int(line.get_slice("=", 1)))
	check(names.size() == 2 and names.all(func(n): return n == version), "versão igual no projeto e nos presets (%s / %s)" % [version, names])
	# versionCode = meio × 10 + correção (0.21.1 → 211, 0.22.0 → 220): SEMPRE sobe,
	# e o Android só instala por cima se o número subir.
	var expected := int(version.get_slice(".", 1)) * 10 + int(version.get_slice(".", 2))
	check(codes.size() == 2 and codes[0] == codes[1] and codes[0] == expected, "versionCode acompanha a versão (%s, esperado %d)" % [codes, expected])


# --- v0.45 (Etapa 8): Heitor e Helena ---------------------------------------------------

## Poço → estátua → gelo: cada resgate liga uma flag e abre o próximo encontro.
func test_heitor_rescues() -> void:
	var level := await open_level(CIDADE, "porta")
	check(find_npc("poco_heitor") != null, "na Avenida, o poço (onde ficava o guarda antigo)")
	check(level.resolve_dialogue("poco_heitor") == "poco_heitor", "lá do fundo, alguém cantarola")
	level._begin_modal()
	await level._on_dialogue_action("flag:heitor_poco;ganhar:licor_da_vigilia")
	level._end_modal()
	check(Game.has_flag("heitor_poco") and Game.has_item("licor_da_vigilia"), "salvo do poço: ele dá o Licor da Vigília")
	check(level.resolve_dialogue("poco_heitor") == "poco_vazio", "o poço fica vazio")
	level.queue_free()
	await frames(2)
	Game.flags.erase("heitor_poco")
	level = await open_level(FORJAS, "porta")
	check(find_npc("estatua_heitor") == null, "sem o poço, ninguém debaixo da estátua")
	level.queue_free()
	await frames(2)
	Game.set_flag("heitor_poco")
	level = await open_level(FORJAS, "porta")
	check(find_npc("estatua_heitor") != null, "depois do poço: preso debaixo da estátua nas Forjas")
	level.queue_free()
	await frames(2)
	level = await open_level(DOMINIO, "porta")
	check(find_npc("gelo_heitor") == null and find_npc("heitor_dominio") == null, "o gelo ainda espera a estátua")
	level.queue_free()
	await frames(2)
	Game.set_flag("heitor_estatua")
	level = await open_level(DOMINIO, "porta")
	check(find_npc("gelo_heitor") != null, "depois da estátua: preso no gelo do lago")
	level.queue_free()
	await frames(2)
	Game.set_flag("heitor_gelo")
	level = await open_level(DOMINIO, "porta")
	check(find_npc("gelo_heitor") == null and find_npc("heitor_dominio") != null, "solto: ele fica no lago, cantarolando")
	check(level.resolve_dialogue("heitor_dominio") == "heitor_dominio", "sem a história da flor, ele só canta")
	Game.set_flag("helena_contou_flor")
	check(level.resolve_dialogue("heitor_dominio") == "heitor_flor", "ela contou da flor: ele dá a Flor de Pedra")
	await level._on_dialogue_action("flag:heitor_deu_flor;ganhar:flor_de_pedra")
	check(Game.has_item("flor_de_pedra") and level.resolve_dialogue("heitor_dominio") == "heitor_dominio", "uma flor só")
	level.queue_free()
	await frames(2)
	# O guarda antigo saiu do jogo (a Etapa 8 o substitui).
	check(not Ally.REGISTRY.has("guarda") and Ally.REGISTRY.has("heitor"), "o aliado agora é o Heitor")
	for id in ["guarda_cidade", "guarda_1", "posto_vazio"]:
		check(DialogueData.get_entry(id).is_empty(), "sem a fala antiga %s" % id)


## A Helena bêbada: uma fala nova por visita; sóbria com 6 memórias.
func test_helena_drunk_visits() -> void:
	var level := await open_level(TEATRO, "camara")
	check(find_npc("helena") != null, "ela está na plateia")
	check(level.resolve_dialogue("helena") == "helena", "1ª visita: o marido 'morreu'")
	level._after_talk("helena")
	check(level.resolve_dialogue("helena") == "helena_2", "2ª visita: a música horrível")
	level._after_talk("helena")
	check(Game.has_flag("helena_contou_flor") and level.resolve_dialogue("helena") == "helena_3", "3ª: ela contou da flor de pedra")
	var texts := func() -> Array:
		return DialogueBox.expand_options(DialogueData.get_entry("helena_3").get("opcoes", [])).map(func(o): return o["texto"])
	check(not texts.call().has("Mostrar a Flor de Pedra") and not texts.call().has("Oferecer o Licor"), "sem os itens, só 'Deixá-la em paz'")
	Game.add_item("licor_da_vigilia")
	Game.add_item("flor_de_pedra")
	check(texts.call().has("Mostrar a Flor de Pedra") and texts.call().has("Oferecer o Licor"), "com os itens, as opções aparecem")
	await level._on_dialogue_action("dar:licor_da_vigilia")
	check(not Game.has_item("licor_da_vigilia"), "o licor vai para ela")
	Game.defeated_bosses.assign(["aldir", "nyssa", "mabel", "durgan", "rachel", "cassian"])
	check(level.resolve_dialogue("helena") == "helena_sobria", "seis memórias: 'Só falta eu.'")
	var actions := (DialogueData.get_entry("helena_sobria").get("opcoes", []) as Array).map(func(o): return o["acao"])
	check(actions.has("desafiar_helena"), "sóbria, ela aceita a luta")
	var flor := DialogueData.get_entry("helena_pela_flor")
	check((flor.get("falas", []) as Array).size() == 4 and str(flor["opcoes"][0]["acao"]).contains("desafiar_helena"), "a flor: quatro falas e a fúria")
	level.queue_free()
	await frames(2)


## A fúria pela flor: ela grita no começo, e o Heitor (salvo três vezes) entra junto.
func test_helena_fury_with_heitor() -> void:
	Game.set_flag("heitor_gelo")
	var level := await open_level(TEATRO, "camara")
	check(get_tree().get_nodes_in_group(&"allies").is_empty(), "no Teatro, antes da luta, ninguém luta")
	var said := []
	var helena := level._boss as HelenaAltiva
	helena.speech.connect(func(text: String): said.append(text))
	level.player._iframes_left = 999.0
	level._begin_modal()
	await level._on_dialogue_action("flag:helena_pela_flor;desafiar_helena")
	level._end_modal()  # no jogo, a caixa de diálogo fecha e o mundo volta a andar
	await seconds(0.5)
	var allies := get_tree().get_nodes_in_group(&"allies")
	check(allies.size() == 1 and allies[0] is HeitorAliado, "o Heitor entra na arena com você")
	check(level.boss_arena.state != BossArena.State.IDLE, "a luta começa")
	await seconds(3.0)
	level.player.global_position = level.boss_arena.arena_rect.get_center()  # entra na arena
	await seconds(6.0)
	check(said.has(HelenaAltiva.SPEECH_FLOR), "'Eu fiquei no posto! EU! Por você!'")
	level.queue_free()
	await frames(2)
	Game.set_flag("heitor_morto")
	level = await open_level(TEATRO, "camara")
	level._begin_modal()
	level._on_dialogue_action("desafiar_helena")
	await seconds(0.5)
	check(get_tree().get_nodes_in_group(&"allies").is_empty(), "morto, ele não volta")
	level.queue_free()
	await frames(2)


func test_helena_recognizes_ring() -> void:
	Game.add_item("anel_do_guarda")
	var player := spawn_player(Vector2(200, 300))
	var helena := HELENA_SCENE.instantiate() as HelenaAltiva
	helena.position = Vector2(200, 200)
	_world.add_child(helena)
	await frames(2)
	var said := []
	helena.speech.connect(func(text: String): said.append(text))
	helena.visible = true
	helena.start_fight()
	player.hurtbox.invulnerable = true
	player.set_physics_process(false)
	helena.stats.take_damage(9999.0)
	await seconds(1.6)
	helena.stats.take_damage(9999.0)
	await seconds(3.8)
	check(helena.phase == 3 and said.has(HelenaAltiva.SPEECH_RING), "fase 3: ela vê o anel")
	check(helena.is_hesitating() and is_equal_approx(helena._incoming_damage_multiplier(HitInfo.new()), HelenaAltiva.RING_DAMAGE_MULTIPLIER), "e para — o golpe dói mais")
	await seconds(HelenaAltiva.RING_HESITATION + 0.2)
	check(not helena.is_hesitating(), "depois ela volta a lutar")


# --- v0.18: título soulslike e modo controle ----------------------------------------------

func test_title_souls_style() -> void:
	var title := (load("res://scenes/ui/title_screen.tscn") as PackedScene).instantiate()
	add_child(title)
	await frames(2)
	check(not title._menu.visible and title._press_any.visible, "começa em 'Pressione qualquer botão'")
	var key := InputEventKey.new()
	key.pressed = true
	key.keycode = KEY_ENTER
	title._input(key)
	await frames(2)
	check(title._menu.visible and not title._press_any.visible, "qualquer botão abre o menu")
	var focused := get_viewport().gui_get_focus_owner()
	check(focused is DSMenuButton, "o menu é de itens só-texto com foco (DSMenuButton)")
	title.queue_free()
	await frames(2)


func test_controller_mode() -> void:
	var saved := Settings.controller_mode
	var level := await open_level(CIDADE, "porta")
	var touch := level.hud.touch
	Settings.controller_mode = false
	Settings.apply()
	check(touch._root.visible and not touch.pad_hints.visible, "toque: botões na tela, sem legenda do controle")
	Settings.controller_mode = true
	Settings.apply()
	check(not touch._root.visible and touch.pad_hints.visible, "modo controle: os botões somem, a legenda aparece")
	touch.set_enabled(false)
	check(not touch.visible, "em cena/diálogo, nada aparece")
	touch.set_enabled(true)
	check(touch.visible and touch.pad_hints.visible, "e volta a legenda depois")
	check(TutorialHints.text_for("esquivar").contains(PadStyle.face_long("circle")), "as dicas falam dos botões do controle (o que estiver ligado)")
	Settings.controller_mode = saved
	Settings.apply()
	level.queue_free()
	await frames(2)


func test_pad_mapping_and_interact() -> void:
	var expect := {&"attack": JOY_BUTTON_RIGHT_SHOULDER, &"dash": JOY_BUTTON_B, &"heal": JOY_BUTTON_X,
		&"sanity": JOY_BUTTON_Y, &"interact": JOY_BUTTON_A, &"block": JOY_BUTTON_LEFT_SHOULDER}
	for action in expect:
		var found := false
		for event in InputMap.action_get_events(action):
			if event is InputEventJoypadButton and (event as InputEventJoypadButton).button_index == expect[action]:
				found = true
		check(found, "controle: %s no botão %d" % [action, expect[action]])
	var heavy_on_r2 := InputMap.action_get_events(&"attack_heavy").any(func(e): return e is InputEventJoypadMotion and (e as InputEventJoypadMotion).axis == JOY_AXIS_TRIGGER_RIGHT)
	check(heavy_on_r2, "golpe forte no R2")
	# ✕ conversa com quem está perto (sem beber frasco por engano).
	var level := await open_level(TEATRO, "camara")
	var fairy := find_npc("fada")
	level.player.global_position = fairy.global_position + Vector2(0, 14)
	await frames(4)
	var flasks := level.player.health_flasks
	level.player._buffer(&"interact")
	await frames(4)
	check(level.hud.dialogue.visible and level.player.health_flasks == flasks, "✕ conversa com a Fada")
	level.hud.dialogue.visible = false
	get_tree().paused = false
	level.queue_free()
	await frames(2)



func test_appearance_atlas() -> void:
	var atlas: Texture2D = load(Appearance.ATLAS_PATH)
	check(atlas.get_width() == Appearance.FRAMES_PER_ROW * 24, "atlas: 4 quadros por linha")
	check(atlas.get_height() == Appearance.row_count() * 24, "atlas: uma linha por combinação (%d)" % Appearance.row_count())
	check(Appearance.row_count() == 90, "2 sexos x 3 corpos x 3 rostos x 5 cabelos = 90")
	var last := {"sexo": 1, "corpo": 2, "rosto": 2, "cabelo": 4}
	check(Appearance.row(last) == Appearance.row_count() - 1, "a última combinação é a última linha (mesma fórmula do Python)")
	check(Appearance.row({"sexo": 0, "corpo": 1, "rosto": 0, "cabelo": 0}) == 15, "corpo pula 15 linhas")
	var broken := Appearance.sanitized({"sexo": 9, "corpo": -3, "rosto": "x", "cabelo": 99})
	check(broken["sexo"] == 1 and broken["corpo"] == 0 and broken["cabelo"] == 4, "valores absurdos são corrigidos")
	check(Appearance.sanitized(null) == Appearance.default_data(), "lixo vira a aparência padrão")
	var frames := Appearance.sprite_frames(last)
	check(frames.has_animation(&"idle") and frames.get_frame_count(&"walk") == 4, "mesmas animações do player_frames.tres")
	check(Appearance.sprite_frames(last) == frames, "SpriteFrames reaproveitado (cache)")
	# Cada combinação tem que ser DIFERENTE das outras (nenhuma linha repetida).
	var image := atlas.get_image()
	var seen := {}
	for r in Appearance.row_count():
		var digest := image.get_region(Rect2i(0, r * 24, 24, 24)).get_data().hex_encode().md5_text()
		seen[digest] = true
	check(seen.size() == Appearance.row_count(), "as 90 aparências são todas diferentes (%d)" % seen.size())
	# O cabelo usa a cor-chave do shader (embranquece com a perda de sanidade).
	var hair_key := Color8(59, 43, 36)
	var has_key := false
	var sample := image.get_region(Rect2i(0, (Appearance.row_count() - 1) * 24, 24, 24))
	for y in 24:
		for x in 24:
			if sample.get_pixel(x, y).is_equal_approx(hair_key):
				has_key = true
	check(has_key, "o cabelo usa a cor-chave do shader sprite_fx")


func test_appearance_save_and_player() -> void:
	var look := {"sexo": 1, "corpo": 2, "rosto": 1, "cabelo": 3}
	Game.reset_progress()
	Game.appearance = Appearance.sanitized(look)
	var data := Game._to_dict()
	Game.reset_progress()
	check(Game.appearance == Appearance.default_data(), "reset volta à aparência padrão")
	Game._from_dict(data)
	check(Game.appearance == look, "a aparência sobrevive ao save")
	Game._from_dict({"version": 3})
	check(Game.appearance == Appearance.default_data(), "save antigo (sem aparência) usa a padrão")
	Game.appearance = Appearance.sanitized(look)
	var level := await open_level(CIDADE, "porta")
	var body: AnimatedSprite2D = level.player.body_sprite
	check(body.sprite_frames == Appearance.sprite_frames(look), "o herói nasce com a aparência escolhida")
	check(body.material != null, "o shader de sanidade continua no corpo")
	level.queue_free()
	await frames(2)
	Game.reset_progress()


func test_character_creation_screen() -> void:
	var creation := CharacterCreation.new()
	add_child(creation)
	await frames(2)
	check(get_viewport().gui_get_focus_owner() is DSMenuButton, "criação começa com foco (dá para usar o controle)")
	creation.step("sexo", 1)
	check(creation.look["sexo"] == 1 and creation._values["sexo"].text == "Mulher", "troca o sexo")
	check(creation._values["rosto"].text == "Serena", "rostos de mulher aparecem")
	creation.step("cabelo", -1)
	check(creation.look["cabelo"] == 4, "‹ no primeiro cabelo dá a volta para o último")
	check(creation._preview.sprite_frames == Appearance.sprite_frames(creation.look), "a prévia acompanha a escolha")
	for i in 20:
		creation.randomize_look()
		check(Appearance.sanitized(creation.look) == creation.look, "aleatório sempre gera combinação válida")
	var got: Array = []
	creation.confirmed.connect(func(l): got.append(l))
	creation._confirm()
	check(got.size() == 1 and Appearance.sanitized(got[0]) == creation.look and got[0].get("arma") == creation.weapon,
		"Despertar devolve a aparência escolhida (e a arma)")
	got[0]["sexo"] = 99
	check(creation.look["sexo"] != 99, "devolve uma CÓPIA (mexer nela não muda a tela)")
	creation.queue_free()
	var title := (load("res://scenes/ui/title_screen.tscn") as PackedScene).instantiate()
	add_child(title)
	await frames(2)
	title.show_menu()
	title.open_creation()
	await frames(2)
	check(title._creation != null and title._creation.is_inside_tree(), "Novo jogo abre a criação")
	title._creation.cancelled.emit()
	await frames(2)
	check(title._creation == null and title._slots != null, "Voltar retorna à escolha de save")
	title._slots.picked.emit(0)
	await frames(2)
	check(title._slots == null and title._menu.visible, "e dali ao menu")
	title.queue_free()
	await frames(2)


# --- v0.20: armas de chefe, forja e inventário soulslike -----------------------------------

## A tabela do TXT: classe e letras de cada arma.
func test_weapon_catalog() -> void:
	var expect := {
		"lamina_desolada": ["Espada", {"destreza": "A"}, "helena"],
		"pilar_estilhacada": ["Martelo", {"forca": "S"}, "aldir"],
		"presa_caelis": ["Espada Grande", {"forca": "B", "magia": "C"}, "rachel"],
		"fuso_arconte": ["Lança", {"magia": "A", "destreza": "C"}, "cassian"],
		"replicador_bronze": ["Besta", {"fe": "B", "destreza": "B"}, "durgan"],
		"presas_voragem": ["Adagas", {"sorte": "A", "destreza": "B"}, "mabel"],
		"arco_sono": ["Arco", {"fe": "S"}, "nyssa"],
		"ancora_gravidade": ["Machado", {"forca": "A", "fe": "A"}, "cavaleiro"],
	}
	check(Game.forgeable_weapons().size() == 8, "8 armas de chefe")
	for id: String in expect:
		var weapon := Items.get_weapon(id)
		check(weapon != null and weapon.kind == ItemData.Kind.EQUIPAMENTO, "%s é arma e item" % id)
		check(weapon.weapon_class == expect[id][0], "%s: classe %s" % [id, weapon.weapon_class])
		check(weapon.scaling == expect[id][1], "%s: escalas %s" % [id, weapon.scaling])
		check(weapon.boss_id == expect[id][2] and Items.exists(weapon.memory_item), "%s: forjada com a Lembrança de %s" % [id, weapon.boss_id])
		check(weapon.icon != null and weapon.hand_texture != null, "%s: ícone e desenho na mão" % id)
		check(not weapon.skill.is_empty() and not weapon.skill_text.is_empty(), "%s: tem habilidade descrita" % id)
		check(WeaponSkills.create(weapon).get_script() != WeaponSkill, "%s: habilidade própria (não a nula)" % id)
	check(Items.get_weapon("espada") != null, "a espada inicial também é WeaponData")
	check(Items.get_weapon("replicador_bronze").ranged and Items.get_weapon("arco_sono").ranged, "besta e arco atiram")
	# Letras → números: A = 3,5% por ponto; acima de 25 rende metade.
	var lamina := Items.get_weapon("lamina_desolada")
	check(is_equal_approx(lamina.scaling_multiplier({"destreza": 20}), 1.35), "DES A com 20 pontos = +35%")
	check(is_equal_approx(lamina.scaling_multiplier({"destreza": 35}), 1.0 + 15 * 0.035 + 10 * 0.0175), "retorno decrescente depois de 25")
	check(is_equal_approx(lamina.scaling_multiplier({"forca": 40}), 1.0), "força não mexe numa arma só de destreza")


func test_weapon_forge_and_equip() -> void:
	Game.reset_progress()
	Game.memories = 10000
	Game.add_item("sucata_temperada", 10, false)
	check(Game.forge_block_reason("lamina_desolada") == "lembranca", "sem a Lembrança da Helena: não forja")
	Game.add_item("lembranca_helena", 1, false)
	check(Game.forge_block_reason("lamina_desolada") == "", "com a Lembrança: pode forjar")
	check(Game.try_forge_weapon("lamina_desolada"), "forjou")
	check(Game.has_item("lembranca_helena"), "a Lembrança NÃO é gasta (ela abre o Núcleo)")
	check(Game.memories == 8500 and Game.item_count("sucata_temperada") == 7, "cobrou memórias e sucata")
	check(Game.owned_weapons() == ["espada", "lamina_desolada", Game.FISTS], "armas (e os punhos, sempre): %s" % [Game.owned_weapons()])
	check(Game.try_forge_weapon("lamina_desolada") and Game.weapon_count("lamina_desolada") == 2, "forja uma CÓPIA (uma para cada mão)")
	check(Game.forge_block_reason("lamina_desolada") == "owned" and not Game.try_forge_weapon("lamina_desolada"), "mas não uma terceira")
	Game.remove_item("lamina_desolada", 1)
	check(not Game.equip_weapon("arco_sono"), "não equipa o que não tem")
	var player := spawn_player()
	await frames(2)
	check(player.weapon.id == "espada", "começa com a espada")
	var sword_heavy := player.heavy_attack
	check(Game.equip_weapon("lamina_desolada"), "equipou")
	await frames(1)
	check(player.weapon.id == "lamina_desolada", "o herói troca de arma na hora")
	check(player.heavy_attack == sword_heavy, "R2 continua o golpe forte comum")
	check(player.weapon.special_attack.active_during_lunge, "o especial (L2 em duas mãos) é a estocada")
	check(player.sword.texture == player.weapon.hand_texture, "e o desenho na mão")
	var data := Game._to_dict()
	Game.reset_progress()
	Game._from_dict(data)
	check(Game.equipped_weapon == "lamina_desolada", "a arma equipada fica no save")
	data["equipped_weapon"] = "arco_sono"
	Game._from_dict(data)
	check(Game.equipped_weapon == "espada", "save com arma que não tem volta para a espada")
	Game.equip_weapon("espada")
	# Save antigo de quem já venceu o Cavaleiro ganha a Lembrança nova.
	Game._from_dict({"version": 3, "defeated_bosses": ["cavaleiro", "aldir"], "inventory": {}})
	check(Game.has_item("lembranca_cavaleiro") and Game.has_item("lembranca_aldir"), "Lembranças que faltavam são devolvidas")
	check(Game.forge_block_reason("ancora_gravidade") == "", "a Âncora (pós-final) é forjável")
	Game.reset_progress()


func test_weapon_damage_matches_sheet() -> void:
	Game.reset_progress()
	Game.attributes["forca"] = 20
	Game.add_item("lembranca_aldir", 1, false)
	Game.add_item("pilar_estilhacada", 1, false)
	Game.equip_weapon("pilar_estilhacada")
	var player := spawn_player()
	await frames(2)
	var power := Game.weapon_power(player.weapon)
	player._current_attack = player.heavy_attack
	player._activate_hitbox()
	check(roundi(player.hitbox._damage) == power.y, "o golpe bate o que a ficha mostra (%d)" % power.y)
	check(power.y > Game.weapon_power(Items.get_weapon("espada")).y, "FOR S com 20 de força bate mais que a espada")
	# Custo de estamina: o martelo pesa mais.
	var before := player.stats.stamina
	player._start_attack(player.light_combo[0], 0)
	check(is_equal_approx(before - player.stats.stamina, player.light_combo[0].stamina_cost * 1.25), "martelo gasta 25% mais estamina")
	check(player._runner.time_scale > 1.0, "e é mais lento")
	Game.reset_progress()


func _skill_setup(weapon_id: String) -> Array:
	_reset_world()  # cada arma num mundo limpo (sem os soldados do teste anterior)
	Game.reset_progress()
	Game.add_item(weapon_id, 1, false)
	Game.equip_weapon(weapon_id)
	var player := spawn_player(Vector2(200, 200))
	var enemy := spawn_enemy_scene(SOLDIER_SCENE, Vector2(222, 200))
	await frames(2)
	player._iframes_left = 0.0
	return [player, enemy]


func test_weapon_skills_melee() -> void:
	# Lâmina Desolada: a estocada que acerta devolve fôlego (e no vazio, não).
	var setup: Array = await _skill_setup("lamina_desolada")
	var player: Player = setup[0]
	var enemy: Enemy = setup[1]
	player.stats.stamina = 10.0
	var info := HitInfo.create(10.0, player.global_position, enemy.global_position)
	player._skill.on_hit(player, enemy.hurtbox, info, player.weapon.special_attack)
	check(player.stats.stamina > 30.0, "Lâmina: acertou a estocada, recuperou estamina")
	var nobody := Hurtbox.new()
	player.stats.stamina = 10.0
	player._skill.on_hit(player, nobody, info, player.weapon.special_attack)
	check(is_equal_approx(player.stats.stamina, 10.0), "Lâmina: sem inimigo, nada (não vira dash infinito)")
	nobody.free()
	# Pilar: a onda derruba a guarda de quem está perto.
	setup = await _skill_setup("pilar_estilhacada")
	player = setup[0]
	enemy = setup[1]
	var health := enemy.stats.health
	player.hitbox_pivot.rotation = 0.0
	player._skill.on_active(player, player.weapon.special_attack, 40.0)
	await frames(2)
	check(enemy.stats.health < health, "Pilar: a onda machuca em volta")
	check((enemy as SoldadoRemendado).ai == SoldadoRemendado.AI.STAGGER, "Pilar: e faz cambalear (postura 999)")
	# Presa de Caelis: o golpe forte custa mais e deixa fogo que queima INIMIGOS.
	setup = await _skill_setup("presa_caelis")
	player = setup[0]
	enemy = setup[1]
	enemy.set_physics_process(false)  # o soldado parado: quem queima é o fogo, não a espada dele
	check(player._skill.extra_stamina(player.weapon.special_attack) > 0.0 and player._skill.extra_stamina(player.light_combo[0]) == 0.0, "Caelis: só o forte custa a 'mana'")
	player.hitbox_pivot.rotation = 0.0
	player._skill.on_active(player, player.weapon.special_attack, 40.0)
	var patches := get_tree().get_nodes_in_group("fire_patches")
	check(patches.size() == 3, "Caelis: três chamas no rastro")
	health = enemy.stats.health
	var player_health := player.stats.health
	await seconds(1.1)
	check(enemy.stats.health < health, "Caelis: o fogo queima o inimigo")
	check(is_equal_approx(player.stats.health, player_health), "Caelis: e não queima o herói")
	for patch in patches:
		patch.queue_free()
	# Fuso do Arconte: rouba fôlego e o próximo golpe do inimigo demora.
	setup = await _skill_setup("fuso_arconte")
	player = setup[0]
	enemy = setup[1]
	player.stats.stamina = 10.0
	player._skill.on_hit(player, enemy.hurtbox, info, player.light_combo[0])
	check(player.stats.stamina > 10.0, "Fuso: roubou estamina")
	check(EnemyStatus.find(enemy).drain_left > 0.0, "Fuso: inimigo exausto")
	enemy.start_attack(enemy._current_attack if enemy._current_attack else player.light_combo[0], Vector2.LEFT)
	check(is_equal_approx(enemy._runner.time_scale, EnemyStatus.DRAIN_ATTACK_DELAY), "Fuso: o golpe dele sai 60% mais devagar")
	check(EnemyStatus.find(enemy).drain_left == 0.0, "Fuso: vale para UM golpe")
	enemy._runner.cancel()
	# Presas da Vorágine: cura FIXA (2 + Sorte × 0,2) e sangramento que estoura.
	setup = await _skill_setup("presas_voragem")
	player = setup[0]
	enemy = setup[1]
	Game.attributes["sorte"] = 20
	player.stats.set_health(50.0)
	player._skill.on_hit(player, enemy.hurtbox, info, player.light_combo[0])
	check(is_equal_approx(player.stats.health, 56.0), "Vorágine: curou 2 + 20 × 0,2 = 6")
	health = enemy.stats.health
	for i in 4:  # 22 × 5 > 100
		player._skill.on_hit(player, enemy.hurtbox, info, player.light_combo[0])
	check(enemy.stats.health < health - 9.0, "Vorágine: o sangramento estourou")
	# Âncora: puxa os comuns, chefes ficam.
	setup = await _skill_setup("ancora_gravidade")
	player = setup[0]
	enemy = setup[1]
	enemy.set_physics_process(false)  # parado: só o vórtice mexe nele
	var center := enemy.global_position + Vector2(0, -45)  # acima dele: nada no caminho
	GravityVortex.spawn(_world, center, 72.0, 0.6, 30.0, player)
	var start := enemy.global_position.distance_to(center)
	await seconds(0.4)
	check(enemy.global_position.distance_to(center) < start - 8.0, "Âncora: o vórtice puxa o inimigo")
	var knight_like := Boss.new()
	check(WeaponSkill.is_heavyweight(knight_like), "Âncora: chefes não são puxados")
	knight_like.free()
	Game.reset_progress()


func test_weapon_skills_ranged() -> void:
	# Replicador de Bronze: o virote acerta e o raio salta para o vizinho.
	var setup: Array = await _skill_setup("replicador_bronze")
	var player: Player = setup[0]
	var first: Enemy = setup[1]
	var second := spawn_enemy_scene(SOLDIER_SCENE, Vector2(240, 230))
	await frames(2)
	var h1 := first.stats.health
	var h2 := second.stats.health
	player.facing = Vector2.RIGHT
	check(player._start_attack(player.light_combo[0], 0), "atirou")
	var shot_out := await wait_for(func(): return first.stats.health < h1, 60)
	check(shot_out, "Replicador: o virote acertou o primeiro")
	check(not player.hitbox.active, "Replicador: arma de longe não liga a hitbox")
	check(second.stats.health < h2, "Replicador: o raio saltou para o segundo")
	# Arco do Sono Eterno: a flecha forte abre a nuvem; a nuvem deixa lento.
	setup = await _skill_setup("arco_sono")
	player = setup[0]
	var enemy: Enemy = setup[1]
	enemy.set_physics_process(false)  # parado: não interrompe a flecha carregada do herói
	var speed := enemy.move_speed
	SlumberPollen.spawn(_world, enemy.global_position, 34.0, 0.6)
	await seconds(0.3)
	check(EnemyStatus.find(enemy) != null and EnemyStatus.find(enemy).is_slowed(), "Arco: no pólen, fica lento")
	check(is_equal_approx(enemy.move_speed, speed * 0.5), "Arco: anda na metade")
	await seconds(1.4)
	check(is_equal_approx(enemy.move_speed, speed), "Arco: saiu/acabou, volta ao normal")
	player.facing = Vector2.RIGHT
	check(player._start_attack(player.weapon.special_attack, -1), "flecha de pólen")
	var cloud := await wait_for(func(): return not get_tree().get_nodes_in_group("slumber_pollen").is_empty(), 180)
	check(cloud, "Arco: a flecha forte abre a nuvem onde cai")
	Game.reset_progress()


func test_inventory_menu() -> void:
	Game.add_item("sucata_temperada", 3)
	Game.add_item("escudo_remendado")
	Game.add_item("lembranca_aldir")
	Game.add_item("pilar_estilhacada")
	var level := await open_level("res://scenes/world/teatro.tscn", "camara")
	var hud := level.hud
	var menu := hud.inventory_menu
	hud.open_inventory()
	await frames(2)
	check(menu.visible and get_tree().paused, "I/Tab: inventário abre e pausa")
	var ids := menu.entries(0).map(func(e): return e["id"])
	check(ids == ["espada", "pilar_estilhacada", Game.FISTS], "aba Armas (punhos no fim): %s" % [ids])
	check(menu.entries(1).map(func(e): return e["id"]) == ["escudo_remendado"], "aba Escudos")
	check(menu.entries(3).map(func(e): return e["id"]) == ["frasco_vida", "frasco_sanidade"], "aba Frascos")
	check(menu.entries(4).map(func(e): return e["id"]) == ["sucata_temperada"], "aba Materiais")
	check(menu.entries(5).map(func(e): return e["id"]).has("lembranca_aldir"), "aba Lembranças")
	check(get_viewport().gui_get_focus_owner() in menu._slots, "o foco começa na grade (controle)")
	# Ficha da arma: letras de escala e habilidade.
	menu._select("pilar_estilhacada")
	check(menu._scaling_box.get_child_count() == 5, "ficha: FOR DES MAG FÉ SOR")
	check(menu._detail_skill.text.contains("Onda"), "ficha: habilidade")
	menu._activate("pilar_estilhacada")
	await frames(1)
	check(Game.equipped_weapon == "pilar_estilhacada" and level.player.weapon.id == "pilar_estilhacada", "equipar pelo inventário")
	check(menu._equip_rows["direita"].text.contains("Pilar"), "a coluna EQUIPADO atualiza")
	# L1/R1 trocam a aba.
	var r1 := InputEventJoypadButton.new()
	r1.button_index = JOY_BUTTON_RIGHT_SHOULDER
	r1.pressed = true
	menu._unhandled_input(r1)
	check(menu._tab == 1, "R1: próxima aba")
	menu._activate("escudo_remendado")
	await frames(1)
	check(not Game.shield_ready(), "guardou o escudo pelo menu")
	menu.set_tab(5)
	menu._select("lembranca_aldir")
	check(menu._detail_text.text.contains("impotência"), "lembrança mostra a lore")
	hud.propagate_notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	await frames(2)
	check(not menu.visible and not get_tree().paused, "Voltar fecha o inventário e despausa")
	# Pela pausa: abre por cima e volta para a pausa.
	hud.pause_menu.open()
	hud.pause_menu._inventory_button.pressed.emit()
	await frames(2)
	check(menu.visible and not hud.pause_menu.visible, "inventário pela pausa")
	menu.close()
	await frames(2)
	check(hud.pause_menu.visible and get_tree().paused, "fechou: volta para a pausa")
	hud.pause_menu.close()
	level.queue_free()
	await frames(2)
	Game.reset_progress()


func test_smith_forge_tab() -> void:
	Game.reset_progress()
	Game.memories = 5000
	Game.add_item("sucata_temperada", 5, false)
	Game.add_item("lembranca_nyssa", 1, false)
	var menu := SmithMenu.new()
	add_child(menu)
	var player := spawn_player()
	await frames(2)
	menu.run(player)
	await frames(1)
	menu.set_tab(1)
	var ids := menu._slots.map(func(b): return b.get_meta("id"))
	check(ids.size() == Game.BASIC_WEAPONS.size() + 8 and ids[0] == "espada", "aba Forjar: as armas comuns (cópia) e as 8 de chefe")
	menu.select("lamina_desolada")
	check(menu.detail_name.text == "???" and not menu.forge("lamina_desolada"), "sem a Lembrança: arma desconhecida e não forja")
	menu.select("arco_sono")
	check(menu.detail_name.text == "Arco do Sono Eterno" and menu.detail_extra.get_child_count() >= 2, "com a Lembrança da Nyssa: ficha com escalas e custos")
	check(menu.forge("arco_sono"), "forjou")
	check(Game.has_item("arco_sono") and Game.has_item("lembranca_nyssa"), "forjou o arco (a Lembrança fica)")
	check(menu.detail_name.text.contains("cópia"), "a próxima seria a cópia (uma para cada mão)")
	menu._closed.emit()
	await frames(1)
	menu.queue_free()
	Game.reset_progress()



# --- v0.21: parry, crítico, duas armas e duas mãos -------------------------------------------

func test_parryable_flags() -> void:
	check((load("res://data/attacks/soldado_golpe.tres") as AttackData).parryable, "cassetete do soldado: dá para aparar")
	check((load("res://data/attacks/helena_corte_1.tres") as AttackData).parryable, "cortes da Helena: dá para aparar")
	check(not (load("res://data/attacks/aldir_martelada.tres") as AttackData).parryable, "martelo do Aldir: não")
	check(not (load("res://data/attacks/governanta_abraco.tres") as AttackData).parryable, "agarrão: não")
	check(not (load("res://data/attacks/rachel_garra.tres") as AttackData).parryable, "garra da Rachel: não")
	check(not (load("res://data/attacks/cavaleiro_corte_3.tres") as AttackData).parryable, "A Promessa do Cavaleiro: não")
	check((load("res://data/attacks/cavaleiro_corte_1.tres") as AttackData).parryable, "Espadão I: sim")
	check(not HitInfo.new().parryable, "HitInfo montado na mão (tiro, onda) não é aparável")


## Golpe de verdade do soldado contra o herói (passa pela Hitbox, como no jogo).
func _soldier_hit(soldier: Enemy) -> HitInfo:
	var info := HitInfo.create(16.0, soldier.global_position, Vector2(200, 200))
	info.parryable = true
	info.source = soldier
	info.attack_name = "Golpe de cassetete"
	return info


func test_parry_and_riposte() -> void:
	Game.reset_progress()
	Game.add_item("escudo_remendado", 1, false)
	check(Game.hand_mode() == "escudo", "pegou o escudo: ele vai para a esquerda")
	var player := spawn_player(Vector2(200, 200))
	var soldier := spawn_enemy_scene(SOLDIER_SCENE, Vector2(220, 200))
	await frames(2)
	soldier.set_physics_process(false)
	player.facing = Vector2.RIGHT
	player._iframes_left = 0.0
	var got := []
	player.parried.connect(func(e): got.append(e))
	# L2 com escudo = aparar. Golpe dentro da janela: desvia e abre a guarda.
	player._buffer(&"l2")
	player._consume_buffer()
	check(player.state == Player.State.PARRY, "L2 com escudo: aparar")
	var health := player.stats.health
	player._on_hit_received(_soldier_hit(soldier))
	check(is_equal_approx(player.stats.health, health), "aparou: nenhum dano")
	check(got.size() == 1 and soldier.is_guard_open(), "a guarda do soldado ABRIU")
	check((soldier as SoldadoRemendado).ai == SoldadoRemendado.AI.STAGGER, "e ele cambaleia")
	# R1 perto da guarda aberta = crítico.
	var crits := []
	player.critical_landed.connect(func(e, kind): crits.append(kind))
	var before := soldier.stats.health
	var expected := player.critical_damage(soldier)
	player._buffer(&"light")
	player._consume_buffer()
	check(player.state == Player.State.CRITICAL, "R1 na guarda aberta: crítico")
	check(player._is_invulnerable(), "invencível durante o crítico")
	await seconds(0.7)
	check(crits == [&"riposte"], "foi um riposte")
	check(soldier.dead or is_equal_approx(before - soldier.stats.health, expected), "dano do crítico = 3× o golpe leve (%d)" % expected)
	check(expected >= player.attack_damage(player.light_combo[0]) * 2.9, "crítico ≈ 3× o golpe leve")
	# Fora da janela: apanha normal.
	var soldier2 := spawn_enemy_scene(SOLDIER_SCENE, Vector2(180, 200))
	await frames(2)
	soldier2.set_physics_process(false)
	player.facing = Vector2.LEFT
	player._iframes_left = 0.0
	player._start_parry()
	await seconds(0.3)
	health = player.stats.health
	player._on_hit_received(_soldier_hit(soldier2))
	check(player.stats.health < health and not soldier2.is_guard_open(), "atrasado: apanhou e a guarda dele não abriu")
	# Golpe que não dá para aparar: apanha mesmo na janela.
	await seconds(0.6)
	player._iframes_left = 0.0
	player._set_state(Player.State.FREE)
	player._start_parry()
	health = player.stats.health
	var grab := _soldier_hit(soldier2)
	grab.parryable = false
	player._on_hit_received(grab)
	check(player.stats.health < health, "agarrão/martelo gigante: o parry não segura")
	# Chefe: crítico pela metade.
	var boss := Boss.new()
	check(is_equal_approx(player.critical_damage(boss), player.critical_damage(soldier2) * player.critical_boss_ratio), "em chefe o crítico rende metade")
	boss.free()
	# Sorte aumenta o crítico.
	var normal := player.critical_damage(soldier2)
	Game.attributes["sorte"] = 30
	check(player.critical_damage(soldier2) > normal, "Sorte aumenta o crítico")
	Game.reset_progress()


func test_backstab() -> void:
	Game.reset_progress()
	var player := spawn_player(Vector2(200, 200))
	var soldier := spawn_enemy_scene(SOLDIER_SCENE, Vector2(218, 200))
	await frames(2)
	soldier.set_physics_process(false)
	soldier.facing = Vector2.LEFT  # olhando para o herói
	player.facing = Vector2.RIGHT
	check(not player._try_critical(), "de frente, sem parry: nada de crítico")
	soldier.facing = Vector2.RIGHT  # de costas
	check(soldier.can_be_backstabbed(player.global_position), "de costas: dá")
	var kinds := []
	player.critical_landed.connect(func(_e, kind): kinds.append(kind))
	check(player._try_critical(), "R1 pelas costas: crítico")
	await seconds(0.7)
	check(kinds == [&"costas"], "foi pelas costas")
	var boss := Boss.new()
	check(not boss.can_be_backstabbed(Vector2.ZERO), "chefe não toma ataque pelas costas")
	boss.free()


func test_hand_modes() -> void:
	Game.reset_progress()
	check(Game.hand_mode() == "vazia", "começa com a esquerda vazia")
	Game.add_item("lembranca_helena", 1, false)
	Game.add_item("lamina_desolada", 1, false)
	Game.add_item("lembranca_aldir", 1, false)
	Game.add_item("pilar_estilhacada", 1, false)
	check(Game.equip_weapon("lamina_desolada", "esquerda") and Game.hand_mode() == "par", "espada + Lâmina: duas do mesmo tipo")
	check(Game.equip_weapon("pilar_estilhacada", "esquerda") and Game.hand_mode() == "dupla", "espada + martelo: tipos diferentes")
	check(not Game.equip_weapon("espada", "esquerda"), "só uma espada: não vai nas duas mãos")
	Game.add_item("espada", 1, false)  # a cópia do Ferreiro
	check(Game.weapon_count("espada") == 2 and Game.equip_weapon("espada", "esquerda"), "com a cópia, vai")
	Game.equip_weapon("pilar_estilhacada", "esquerda")
	Game.equip_weapon("pilar_estilhacada", "direita")
	check(Game.equipped_weapon == "pilar_estilhacada" and Game.left_hand == "", "uma só: ela MUDA de mão")
	Game.add_item("escudo_remendado", 1, false)
	Game.set_shield_equipped(true)
	check(Game.hand_mode() == "escudo" and Game.shield_ready(), "escudo na esquerda")
	check(not Game.equip_weapon("escudo_remendado", "direita"), "escudo não vai na direita")
	Game.set_two_handing(true)
	check(Game.hand_mode() == "duas_maos" and not Game.shield_ready() and Game.shield_equipped(), "duas mãos: o escudo vai para as costas")
	var data := Game._to_dict()
	Game.reset_progress()
	Game._from_dict(data)
	check(Game.left_hand == "escudo_remendado" and Game.two_handing, "mãos ficam no save")
	# Save da v0.20: "escudo equipado" vira escudo na mão esquerda.
	Game._from_dict({"version": 3, "inventory": {"escudo_remendado": 1}, "shield_equipped": true})
	check(Game.left_hand == "escudo_remendado" and not Game.two_handing, "migração do escudo antigo")
	Game.reset_progress()


func test_paired_and_dual_attacks() -> void:
	Game.reset_progress()
	Game.add_item("lembranca_helena", 1, false)
	Game.add_item("lamina_desolada", 1, false)
	Game.equip_weapon("lamina_desolada", "esquerda")
	var player := spawn_player(Vector2(200, 200))
	await frames(2)
	check(player.left_weapon != null and player.left_weapon.id == "lamina_desolada", "herói com a Lâmina na esquerda")
	check(player.off_pivot.visible, "e ela aparece na mão")
	var attack := player.light_combo[0]
	var right := player.attack_damage(attack, &"direita")
	var left := Game.weapon_hit_damage(player.left_weapon, attack)
	check(is_equal_approx(player.attack_damage(attack, &"ambas"), (right + left) * 0.75), "L1 com duas iguais: 75% da soma")
	# R1 só com a direita.
	player._buffer(&"light")
	player._consume_buffer()
	check(player._attack_hand == &"direita", "R1: só a direita")
	await seconds(0.8)
	var before := player.stats.stamina
	player._buffer(&"left_light")
	player._consume_buffer()
	check(player._attack_hand == &"ambas", "L1: as duas juntas")
	var avg := (attack.stamina_cost * player.weapon.stamina_scale + attack.stamina_cost * player.left_weapon.stamina_scale) * 0.5
	check(is_equal_approx(before - player.stats.stamina, avg * 1.25), "estamina: média das duas + 25%")
	await seconds(0.8)
	player._buffer(&"l2")
	player._consume_buffer()
	check(player._attack_hand == &"esquerda" and player._current_attack.is_heavy, "L2: forte só com a esquerda")
	await seconds(1.2)
	# Tipos diferentes: L1 é o golpe fraco da arma da esquerda.
	Game.add_item("lembranca_aldir", 1, false)
	Game.add_item("pilar_estilhacada", 1, false)
	Game.equip_weapon("pilar_estilhacada", "esquerda")
	await frames(1)
	player._buffer(&"left_light")
	player._consume_buffer()
	check(player._attack_hand == &"esquerda", "dupla: L1 bate com a da esquerda")
	check(is_equal_approx(player.attack_damage(player._current_attack, &"esquerda"), Game.weapon_hit_damage(player.left_weapon, player._current_attack)), "com o dano do martelo")
	Game.reset_progress()


func test_two_hands() -> void:
	Game.reset_progress()
	Game.add_item("escudo_remendado", 1, false)
	Game.vision_loss = 1
	var player := spawn_player(Vector2(200, 200))
	await frames(2)
	var light := player.light_combo[0]
	var one_hand := player.attack_damage(light)
	# Segurar △: duas mãos (e NÃO gasta a Humanidade).
	var flasks := Game.sanity_flasks
	Input.action_press(&"sanity")
	await seconds(0.65)
	Input.action_release(&"sanity")
	await frames(3)
	check(Game.two_handing, "segurar △: duas mãos")
	check(Game.sanity_flasks == flasks and player.state != Player.State.SANITY, "segurar não usa a Humanidade")
	check(is_equal_approx(player.attack_damage(light), one_hand * 1.5), "duas mãos: +50% de dano")
	var before := player.stats.stamina
	player._start_attack(light, 0)
	check(is_equal_approx(before - player.stats.stamina, light.stamina_cost * player.weapon.stamina_scale * 1.5), "e +50% de estamina")
	await seconds(0.8)
	# L2 em duas mãos: o especial da arma.
	player._buffer(&"l2")
	player._consume_buffer()
	check(player._current_attack == player.weapon.special_attack, "L2: ataque especial (Giro da Cobaia)")
	await seconds(1.2)
	# L1: guarda com a arma, segura 75%.
	Input.action_press(&"block")
	await frames(3)
	check(player.state == Player.State.BLOCK and player._weapon_guard(), "L1: guarda com a própria arma")
	var health := player.stats.health
	var hit := HitInfo.create(20.0, Vector2(240, 200), player.global_position)
	player.facing = Vector2.RIGHT
	player._on_hit_received(hit)
	check(is_equal_approx(health - player.stats.health, 20.0 * 0.25), "a arma segura 75% (passam 25%)")
	Input.action_release(&"block")
	await frames(2)
	# Toque rápido no △: Humanidade normal.
	Input.action_press(&"sanity")
	await frames(3)
	Input.action_release(&"sanity")
	await frames(3)
	check(player.state == Player.State.SANITY or Game.sanity_flasks == flasks - 1, "toque rápido: Humanidade")
	await seconds(1.4)
	# Arco em duas mãos: sem o bônus (atirar já é com as duas).
	Game.add_item("lembranca_nyssa", 1, false)
	Game.add_item("arco_sono", 1, false)
	Game.equip_weapon("arco_sono")
	await frames(1)
	var arrow := player.light_combo[0]
	check(is_equal_approx(player.attack_damage(arrow), Game.weapon_hit_damage(player.weapon, arrow)), "arco: duas mãos não muda o dano")
	Game.reset_progress()


func test_touch_follows_hands() -> void:
	Game.reset_progress()
	var level := await open_level(CIDADE, "porta")
	var touch := level.hud.touch
	check(not touch.block_button.visible and touch.special_button.label_text == "Aparar", "mão vazia: sem L1; L2 apara")
	Game.add_item("escudo_remendado", 1, false)
	await frames(1)
	check(touch.block_button.visible and touch.special_button.label_text == "Aparar", "escudo: L1 defende, L2 apara")
	Game.set_two_handing(true)
	await frames(1)
	check(touch.block_button.label_text == "Guarda" and touch.special_button.label_text == "Especial", "duas mãos: guarda e especial")
	check(touch.pad_hints.l1_label == "Guarda" and touch.pad_hints.l2_label == "Especial", "a legenda do controle acompanha")
	level.queue_free()
	await frames(2)
	Game.reset_progress()



## Bug da v0.21 (achado jogando no controle): o ✕ não escolhia nada nos menus,
## porque o "ui_accept" padrão do Godot 4 só tem teclado.
func _pad_press(button: JoyButton) -> void:
	for pressed in [true, false]:
		var event := InputEventJoypadButton.new()
		event.button_index = button
		event.pressed = pressed
		Input.parse_input_event(event)
		await frames(2)


func test_pad_confirms_menus() -> void:
	var cross := InputEventJoypadButton.new()
	cross.button_index = JOY_BUTTON_A
	var circle := InputEventJoypadButton.new()
	circle.button_index = JOY_BUTTON_B
	check(InputMap.action_has_event(&"ui_accept", cross), "✕ confirma nos menus")
	check(InputMap.action_has_event(&"ui_cancel", circle), "○ volta nos menus")
	var enter := InputEventKey.new()
	enter.physical_keycode = KEY_ENTER
	check(InputMap.action_has_event(&"ui_accept", enter), "Enter continua confirmando")
	# Título de verdade: ✕ passa o "pressione qualquer botão" e ✕ de novo escolhe o item.
	var title := (load("res://scenes/ui/title_screen.tscn") as PackedScene).instantiate()
	add_child(title)
	await frames(2)
	await _pad_press(JOY_BUTTON_A)
	check(title._menu.visible, "✕: passa o 'pressione qualquer botão'")
	var picked := []
	var options_button: Button = null
	for child in title._menu.get_children():
		if child is Button and child.text == "Opções":
			options_button = child
	options_button.pressed.connect(func(): picked.append("opcoes"))
	options_button.grab_focus()
	await _pad_press(JOY_BUTTON_A)
	check(picked == ["opcoes"] and title._options.is_open(), "✕ escolhe o item focado (abriu as Opções)")
	await _pad_press(JOY_BUTTON_B)
	check(not title._options.is_open(), "○ fecha as Opções")
	title.queue_free()
	await frames(2)



## O defeito do celular: o menu abre SEM item selecionado e o ✕ não fazia nada.
func test_pad_menus_never_stuck() -> void:
	var title := (load("res://scenes/ui/title_screen.tscn") as PackedScene).instantiate()
	add_child(title)
	await frames(3)
	await _pad_press(JOY_BUTTON_A)
	check(title._menu.visible, "✕ passa do 'Pressione qualquer botão'")
	get_viewport().gui_release_focus()  # simula o celular perdendo a seleção
	check(get_viewport().gui_get_focus_owner() == null, "menu sem nada selecionado")
	await _pad_press(JOY_BUTTON_DPAD_DOWN)
	var focus := get_viewport().gui_get_focus_owner()
	check(focus is DSMenuButton and title._menu.is_ancestor_of(focus), "qualquer botão do controle seleciona o primeiro item")
	UIStyle.focus_first([title._new_game_button])
	await _pad_press(JOY_BUTTON_A)
	check(title._slots != null, "✕ confirma: 'Novo jogo' abre a escolha de save")
	await _pad_press(JOY_BUTTON_A)  # slot 1 (vazio)
	check(title._cutscene != null and title._creation == null, "✕ no slot vazio: primeiro a abertura em vídeo")
	await seconds(CutscenePlayer.SKIP_GRACE + 0.1)
	await _pad_press(JOY_BUTTON_A)  # pula a abertura
	await frames(2)
	check(title._cutscene == null and title._creation != null, "✕ pula o vídeo: criação de personagem")
	get_viewport().gui_release_focus()
	await _pad_press(JOY_BUTTON_A)
	await _pad_press(JOY_BUTTON_A)
	check(title._creation != null and title._creation.look["sexo"] != 0 or get_viewport().gui_get_focus_owner() != null, "na criação o ✕ também funciona")
	# ○ volta (ui_cancel).
	await _pad_press(JOY_BUTTON_B)
	check(title._creation == null and title._slots != null, "○ volta da criação para a escolha de save")
	await _pad_press(JOY_BUTTON_B)
	check(title._slots == null and title._menu.visible, "○ de novo volta ao menu")
	title.queue_free()
	await frames(2)
	# No jogo, sem menu aberto, o PadMenus não rouba o ✕ (ele é "interagir").
	check(PadMenus.active_menu() == null, "jogo sem menu: nenhum menu ativo")
	# Inventário: perdeu a seleção, ✕ seleciona e ✕ de novo equipa.
	Game.reset_progress()
	Game.add_item("escudo_remendado", 1, false)
	var level := await open_level(CIDADE, "porta")
	level.hud.open_inventory()
	await frames(2)
	get_viewport().gui_release_focus()
	await _pad_press(JOY_BUTTON_A)
	check(get_viewport().gui_get_focus_owner() != null, "inventário: o ✕ 'acorda' a seleção")
	level.hud.inventory_menu.set_tab(1)  # Escudos
	await frames(1)
	var before := Game.shield_equipped()
	await _pad_press(JOY_BUTTON_A)
	check(Game.shield_equipped() != before, "inventário: ✕ equipa/guarda")
	await _pad_press(JOY_BUTTON_B)
	check(not level.hud.inventory_menu.visible, "inventário: ○ fecha")
	level.queue_free()
	await frames(2)
	Game.reset_progress()



# --- v0.22: correr e viajar entre Câmaras ------------------------------------------------------

func test_sprint_hold_circle() -> void:
	Game.reset_progress()
	var player := spawn_player(Vector2(200, 200))
	await frames(2)
	# Toque rápido: esquiva (sai ao soltar).
	await tap(&"dash")
	await frames(1)
	check(player.state == Player.State.DASH, "toque rápido no ○: esquiva")
	await seconds(0.6)
	# Segurar + andar: corre.
	Input.action_press(&"move_right")
	Input.action_press(&"dash")
	await seconds(0.5)
	var stamina := player.stats.stamina  # já correndo (a esquiva de antes não conta)
	await seconds(0.5)
	check(player.sprinting and player.state == Player.State.FREE, "segurar o ○: corre (sem esquivar)")
	check(player.velocity.length() > player.move_speed * 1.4, "correndo: mais rápido (%d)" % player.velocity.length())
	check(player.stats.stamina < stamina, "correr gasta estamina (e não regenera)")
	Input.action_release(&"dash")
	await frames(3)
	check(not player.sprinting and player.state == Player.State.FREE, "soltou: para de correr (e não esquiva)")
	await seconds(0.5)
	check(player.velocity.length() <= player.move_speed + 1.0, "volta à velocidade normal")
	# Sem estamina: a corrida acaba sozinha.
	Input.action_press(&"dash")
	await seconds(0.4)
	player.stats.drain_stamina(player.stats.max_stamina)
	await seconds(0.4)
	check(player.velocity.length() <= player.move_speed * player.exhausted_speed_multiplier + 2.0, "exausto: não corre mais")
	Input.action_release(&"dash")
	Input.action_release(&"move_right")
	await frames(2)


func test_rest_menu_and_travel() -> void:
	Game.reset_progress()
	Game.prologue_done = true
	check(Game.unlocked_capsules().map(func(c): return c["thumb"]) == ["teatro", "prologo"], "depois do Prólogo: Teatro e laboratório")
	var level := await open_level("res://scenes/world/teatro.tscn", "camara")
	var menu := level.hud.rest_menu
	level._on_rest_requested(level.rest_chamber)  # o que acontece ao apertar ✕ na cápsula
	var opened := await wait_for(func(): return menu.visible, 420)
	check(opened and get_tree().paused, "descansar abre o menu da Câmara (com o jogo pausado)")
	check(menu._hero.sprite_frames == Appearance.sprite_frames(Game.appearance), "a descida usa a aparência do SEU personagem")
	var start_y := menu._hero.position.y
	await seconds(1.5)
	check(menu._hero.position.y > start_y + 40.0, "o herói desce para dentro da cápsula")
	check(menu._capsule.texture == RestMenu.CAPSULE_CLOSED, "e a tampa fecha")
	var real := func() -> Array: return menu.cards().filter(func(c): return not c.has_meta("gap"))
	check(real.call().size() == 2 and real.call()[0].disabled, "a Câmara de onde está (marcada 'você está aqui') e a do laboratório")
	check(Game.rest_scene == "res://scenes/world/teatro.tscn", "descansar salvou o ponto")
	# ○ = Levantar.
	var cancel := InputEventAction.new()
	cancel.action = &"ui_cancel"
	cancel.pressed = true
	menu._unhandled_input(cancel)
	await frames(3)
	check(not menu.visible and not get_tree().paused, "○: levanta e o jogo segue")
	await wait_for(func(): return level.player.state == Player.State.FREE, 300)  # sai da cápsula
	# Desbloqueia a Cidade e viaja até ela.
	Game.unlock_capsule("res://scenes/world/cidade.tscn")
	Game.unlock_capsule("res://scenes/world/cidade_quartel.tscn")
	level._on_rest_requested(level.rest_chamber)
	await wait_for(func(): return menu.visible, 420)
	var names: Array = real.call().map(func(c): return c.get_meta("scene"))
	check(names == ["res://scenes/world/teatro.tscn", "res://scenes/world/prologo.tscn", "res://scenes/world/cidade.tscn",
		"res://scenes/world/cidade_quartel.tscn"], "uma linha por ilha, na ordem do mapa (%s)" % [names])
	check(menu.cards()[1].has_meta("gap") and menu.cards()[4].get_meta("scene") == "res://scenes/world/cidade.tscn",
		"o Teatro sozinho na linha: um espaço completa, a Cidade começa na esquerda")
	var city: Button = real.call()[2]
	check(not city.disabled and city.icon != null, "a Cidade tem miniatura e dá para escolher")
	Game.last_scene_request = ""
	city.pressed.emit()
	await frames(3)
	check(Game.last_scene_request == "res://scenes/world/cidade.tscn", "viaja para a Cidade")
	check(Game.rest_scene == "res://scenes/world/cidade.tscn" and Game.pending_spawn == "camara", "e renasce lá (na Câmara)")
	check(Game.wake_from_capsule, "o herói vai sair de dentro da cápsula")
	check(not get_tree().paused, "o mundo despausa para a viagem")
	# Save: as Câmaras ficam guardadas; save antigo ganha a do último descanso.
	var data := Game._to_dict()
	Game.reset_progress()
	Game._from_dict(data)
	check(Game.is_capsule_unlocked("res://scenes/world/cidade.tscn"), "Câmaras desbloqueadas ficam no save")
	check(Game.is_capsule_unlocked("res://scenes/world/cidade_quartel.tscn"), "a 2ª Câmara da Cidade também")
	Game._from_dict({"version": 3, "prologue_done": true, "rest_scene": "res://scenes/world/cidade.tscn", "rest_spawn": "camara_2",
		"capsules": ["res://scenes/world/cidade.tscn#camara_2"]})
	check(Game.rest_scene == Game.NEW_CITY_SECOND and Game.rest_spawn == "camara" and Game.is_capsule_unlocked(Game.NEW_CITY_SECOND),
		"migração v0.35: a 2ª Câmara da Cidade vira a do Quartel")
	Game._from_dict({"version": 3, "prologue_done": true, "rest_scene": "res://scenes/world/bosque.tscn", "rest_spawn": "camara_2",
		"capsules": ["res://scenes/world/bosque.tscn#camara_2"]})
	check(Game.rest_scene == DORMITORIO and Game.is_capsule_unlocked(DORMITORIO), "migração v0.35: a 2ª Câmara do Bosque vira a do Dormitório")
	Game._from_dict({"version": 3, "prologue_done": true, "rest_scene": "res://scenes/world/forjas.tscn", "rest_spawn": "camara"})
	check(Game.is_capsule_unlocked("res://scenes/world/forjas.tscn") and Game.is_capsule_unlocked(Game.HUB_SCENE), "migração: a última Câmara e o Teatro")
	Game.wake_from_capsule = false
	level.queue_free()
	await frames(2)
	Game.reset_progress()



## Bug da v0.22: com menos de 4 Câmaras (uma linha só), o → no controle pulava
## para o "Levantar" e não dava para escolher as outras.
func test_rest_menu_pad_navigation() -> void:
	Game.reset_progress()
	Game.prologue_done = true
	Game.unlock_capsule("res://scenes/world/cidade.tscn")
	Game.unlock_capsule("res://scenes/world/cidade_quartel.tscn")
	Game.unlock_capsule("res://scenes/world/bosque.tscn")
	var level := await open_level("res://scenes/world/teatro.tscn", "camara")
	var menu := level.hud.rest_menu
	level._on_rest_requested(level.rest_chamber)
	await wait_for(func(): return menu.visible, 420)
	await frames(2)
	var focused := func() -> String:
		var f := get_viewport().gui_get_focus_owner() as Button
		return f.get_meta("scene", "levantar") if f else ""
	# Grade (uma linha por ilha): [Teatro(aqui) -] / [Laboratório -] / [Cidade Cidade2] / [Bosque -].
	check(focused.call() == "res://scenes/world/prologo.tscn", "abre com a primeira Câmara de destino selecionada (%s)" % focused.call())
	check(menu.cards()[0].focus_mode == Control.FOCUS_NONE, "'você está aqui' nem recebe foco")
	await _pad_press(JOY_BUTTON_DPAD_RIGHT)
	check(focused.call() == "res://scenes/world/prologo.tscn", "sozinha na linha: → não sai dela")
	await _pad_press(JOY_BUTTON_DPAD_DOWN)
	check(focused.call() == "res://scenes/world/cidade.tscn", "↓ desce para a linha da Cidade")
	var seen := []
	for i in 2:
		await _pad_press(JOY_BUTTON_DPAD_RIGHT)
		seen.append(focused.call())
	check(seen == ["res://scenes/world/cidade_quartel.tscn", "res://scenes/world/cidade.tscn"],
		"→ dá a volta NA MESMA LINHA (as duas Câmaras da ilha): %s" % [seen])
	await _pad_press(JOY_BUTTON_DPAD_LEFT)
	check(focused.call() == "res://scenes/world/cidade_quartel.tscn", "← também fica na linha")
	await _pad_press(JOY_BUTTON_DPAD_DOWN)
	check(focused.call() == "res://scenes/world/bosque.tscn", "↓ desce para a linha do Bosque")
	await _pad_press(JOY_BUTTON_DPAD_DOWN)
	check(focused.call() == "levantar", "↓ vai para o Levantar")
	await _pad_press(JOY_BUTTON_DPAD_UP)
	check(focused.call() == "res://scenes/world/prologo.tscn", "↑ volta para as Câmaras")
	await _pad_press(JOY_BUTTON_DPAD_DOWN)
	await _pad_press(JOY_BUTTON_DPAD_RIGHT)
	Game.last_scene_request = ""
	await _pad_press(JOY_BUTTON_A)
	check(Game.last_scene_request == "res://scenes/world/cidade_quartel.tscn" and Game.rest_spawn == "camara",
		"✕ viaja para a 2ª Câmara da Cidade (%s, %s)" % [Game.last_scene_request, Game.rest_spawn])
	Game.wake_from_capsule = false
	level.queue_free()
	await frames(2)
	Game.reset_progress()



## v0.30.2 (feedback): nas linhas ‹ valor ›, ←/→ TROCAM o valor e o foco não pula.
func test_stepper_rows_on_pad() -> void:
	var creation := CharacterCreation.new()
	add_child(creation)
	await frames(2)
	var first := get_viewport().gui_get_focus_owner()
	var before: int = creation.look["sexo"]
	await _pad_press(JOY_BUTTON_DPAD_RIGHT)
	check(creation.look["sexo"] != before, "→ troca o valor da linha")
	check(get_viewport().gui_get_focus_owner() == first, "e o foco fica na mesma linha")
	await _pad_press(JOY_BUTTON_DPAD_LEFT)
	check(creation.look["sexo"] == before and get_viewport().gui_get_focus_owner() == first, "← volta o valor, foco parado")
	await _pad_press(JOY_BUTTON_DPAD_DOWN)
	var cabelo_antes: int = creation.look["corpo"]
	await _pad_press(JOY_BUTTON_DPAD_RIGHT)
	check(creation.look["corpo"] != cabelo_antes, "↓ desce para a próxima linha (Corpo) e → muda ela")
	var stick := InputEventJoypadMotion.new()
	stick.axis = JOY_AXIS_LEFT_X
	var corpo: int = creation.look["corpo"]
	for value in [0.7, 0.8, 0.9, 0.85]:  # o analógico parado para o lado manda vários eventos
		stick.axis_value = value
		Input.parse_input_event(stick)
		await frames(1)
	stick.axis_value = 0.0
	Input.parse_input_event(stick)
	await frames(2)
	check(creation.look["corpo"] == posmod(corpo + 1, Appearance.option_count("corpo", creation.look["sexo"])),
		"analógico inclinado conta UMA vez (não dispara sozinho)")
	creation.queue_free()
	await frames(2)
	var options := OptionsMenu.new()
	add_child(options)
	options.open()
	await frames(2)
	var saved := Settings.sfx_volume
	Settings.sfx_volume = 0.5
	options._focus_chain[0].grab_focus()
	await frames(1)
	await _pad_press(JOY_BUTTON_DPAD_RIGHT)
	check(is_equal_approx(Settings.sfx_volume, 0.6), "Opções: → aumenta o volume (%.1f)" % Settings.sfx_volume)
	check(get_viewport().gui_get_focus_owner() == options._focus_chain[0], "Opções: o foco não pulou de linha")
	var toggle: Control = options._rows["dicas"]
	toggle.grab_focus()
	await _pad_press(JOY_BUTTON_DPAD_RIGHT)
	check(get_viewport().gui_get_focus_owner() == toggle, "Opções: → num botão comum não leva para outra linha")
	Settings.sfx_volume = saved
	Settings.apply()
	options.queue_free()
	await frames(2)


## v0.30.4 (feedback): na grade do inventário/loja o direcional não foge da grade.
func test_grid_menus_on_pad() -> void:
	Game.reset_progress()
	Game.memories = 3000
	var level := await open_level("res://scenes/world/teatro.tscn", "camara")
	level._on_dialogue_action("loja")
	await frames(2)
	var shop := level.hud.shop_menu
	var slots: Array[Button] = shop._slots
	check(slots.size() == 3, "loja: 3 itens numa linha (%d)" % slots.size())
	slots[2].grab_focus()
	await frames(1)
	await _pad_press(JOY_BUTTON_DPAD_RIGHT)
	check(get_viewport().gui_get_focus_owner() == slots[0], "loja: → na última coluna volta para a 1ª (não vai para o Sair)")
	await _pad_press(JOY_BUTTON_DPAD_UP)
	check(get_viewport().gui_get_focus_owner() == slots[0], "loja: ↑ na 1ª linha fica parado")
	await _pad_press(JOY_BUTTON_DPAD_DOWN)
	check(get_viewport().gui_get_focus_owner() == shop._close_button, "loja: ↓ sai para o Sair")
	await _pad_press(JOY_BUTTON_DPAD_UP)
	check(get_viewport().gui_get_focus_owner() == slots[0], "loja: ↑ no Sair volta para a grade")
	shop.close()
	await frames(3)
	# Inventório com a aba Armadura cheia (várias linhas).
	for id in ArmorSets.pieces("vigilia") + ArmorSets.pieces("detentor"):
		Game.add_item(id)
	level.hud.open_inventory()
	await frames(2)
	var menu := level.hud.inventory_menu
	menu.set_tab(2)
	await frames(2)
	var grid: Array[Button] = menu._slots
	var columns: int = menu.COLUMNS
	check(grid.size() > columns, "inventário: mais de uma linha (%d itens)" % grid.size())
	grid[columns - 1].grab_focus()
	await frames(1)
	await _pad_press(JOY_BUTTON_DPAD_RIGHT)
	check(get_viewport().gui_get_focus_owner() == grid[0], "inventário: → na última coluna dá a volta na linha")
	await _pad_press(JOY_BUTTON_DPAD_DOWN)
	check(get_viewport().gui_get_focus_owner() == grid[columns], "inventário: ↓ desce uma linha")
	await _pad_press(JOY_BUTTON_DPAD_LEFT)
	check(get_viewport().gui_get_focus_owner() == menu._equip_rows["direita"], "inventário: ← na 1ª coluna vai para o EQUIPADO")
	await _pad_press(JOY_BUTTON_DPAD_RIGHT)
	check(get_viewport().gui_get_focus_owner() == grid[0], "inventário: → no EQUIPADO volta para a grade")
	menu.close()
	level.queue_free()
	await frames(2)
	Game.reset_progress()


## v0.30.6 (teste de um amigo): arco e lança escolhidos na criação. O arco tem
## que ATIRAR (flecha de verdade) e nenhum dos dois pode "dar lapada" — a arma
## fica apontada para o alvo, sem o balanço de lado dos cortes.
func test_starting_bow_and_spear_attacks() -> void:
	for id in ["arco_cobaia", "lanca_cobaia"]:
		Game.reset_progress()
		Game.new_game({"arma": id})
		Game.scene_changes_enabled = false
		var level := await open_level("res://scenes/world/prologo.tscn", "camara")
		var player := level.player
		await wait_for(func(): return player.state == Player.State.FREE, 900)  # acorda da cápsula
		check(player.state == Player.State.FREE, "%s: herói livre depois de acordar" % id)
		var pickups := level.entities.get_children().filter(func(n): return n is ItemPickup and n.item_id == id)
		(pickups[0] as ItemPickup).take()
		await frames(2)
		check(player.weapon.id == id, "%s: pegou do chão e está na mão" % id)
		for enemy in get_tree().get_nodes_in_group("enemies"):
			enemy.queue_free()  # sem mira assistida puxando para outro lado
		await frames(2)
		player.facing = Vector2.RIGHT
		player.stats.stamina = player.stats.max_stamina
		var count_shots := func() -> int:
			return level.find_children("*", "", true, false).filter(func(n): return n is PlayerShot).size()
		var shots_before: int = count_shots.call()
		Input.action_press(&"attack")
		await frames(3)
		Input.action_release(&"attack")
		var worst_turn := 0.0
		var shot_seen := false
		for i in 50:
			await frames(1)
			if player.state == Player.State.ATTACK:
				worst_turn = maxf(worst_turn, absf(angle_difference(player.weapon_pivot.rotation, player._swing_from)))
			if count_shots.call() > shots_before:
				shot_seen = true
		check(worst_turn >= 0.0 and player._current_attack != null, "%s: o golpe saiu" % id)
		check(worst_turn < 0.05, "%s: a arma não balança de lado (desvio máx %.2f rad)" % [id, worst_turn])
		if id == "arco_cobaia":
			check(shot_seen, "arco: o golpe solta uma FLECHA")
		level.queue_free()
		await frames(2)
	Game.reset_progress()


## v0.30.7 (feedback): inimigo morto fica morto ao trocar de área; volta ao
## descansar ou ao morrer (regra do Dark Souls). E o save avisa na tela.
func test_slain_enemies_stay_dead_until_rest() -> void:
	Game.reset_progress()
	var level := await open_level(CIDADE, "camara")
	var enemies := get_tree().get_nodes_in_group("respawnable").filter(func(n): return n is Enemy and not (n is Boss))
	var total := enemies.size()
	check(total >= 3, "a Cidade tem inimigos (%d)" % total)
	for i in 2:
		(enemies[i] as Enemy).stats.take_damage(99999.0)
	await frames(3)
	check((Game.slain.get(CIDADE, []) as Array).size() == 2, "o jogo anotou os 2 mortos")
	var saves := [0]
	var count_save := func(): saves[0] += 1
	Game.saved.connect(count_save)
	Game.persistence_enabled = true
	var keep_path := Game.save_path
	Game.save_path = "user://teste_abatidos.json"
	Game.save_game()
	check(saves[0] == 1, "salvar emite o aviso para o HUD")
	Game.slain = {}
	Game.load_game()
	check((Game.slain.get(CIDADE, []) as Array).size() == 2, "os mortos ficam no save")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Game.save_path))
	Game.save_path = keep_path
	Game.persistence_enabled = false
	Game.saved.disconnect(count_save)
	level.queue_free()
	await frames(3)
	# Volta à área: os 2 continuam mortos.
	level = await open_level(CIDADE, "camara")
	var alive := get_tree().get_nodes_in_group("respawnable").filter(func(n): return n is Enemy and not (n is Boss) and not n.is_queued_for_deletion()).size()
	check(alive == total - 2, "voltou à área: os mortos não voltaram (%d de %d)" % [alive, total])
	# Descansou: todo mundo de volta.
	level._respawn_enemies()
	await frames(2)
	alive = get_tree().get_nodes_in_group("respawnable").filter(func(n): return n is Enemy and not (n is Boss) and not n.is_queued_for_deletion()).size()
	check(alive == total and Game.slain.is_empty(), "descansou: os inimigos voltam (%d de %d)" % [alive, total])
	level.queue_free()
	await frames(2)
	# Morrer também traz de volta.
	Game.mark_slain(CIDADE, 0)
	Game.respawn()
	check(Game.slain.is_empty(), "morrer também traz os inimigos de volta")
	Game.wake_from_capsule = false
	Game.reset_progress()


## v0.30.7 (ideia do testador): o tiro do atirador acerta inimigo no caminho.
func test_sniper_friendly_fire() -> void:
	var player := spawn_player(Vector2(400, 200))
	player._iframes_left = 9999.0
	var soldier := spawn_enemy_scene(SOLDIER_SCENE, Vector2(300, 200))
	await frames(2)
	var hp := soldier.stats.health
	var shot := Projectile.launch(self, Vector2(200, 200), Vector2.RIGHT, null, 20.0, 300.0, 400.0)
	shot.friendly_fire = true
	await seconds(0.8)
	check(soldier.stats.health < hp, "tiro de atirador acerta o soldado no caminho (%.0f → %.0f)" % [hp, soldier.stats.health])
	hp = soldier.stats.health
	var boss_shot := Projectile.launch(self, Vector2(200, 200), Vector2.RIGHT, null, 20.0, 300.0, 400.0)
	await seconds(0.8)
	check(is_equal_approx(soldier.stats.health, hp), "tiro de chefe (sem fogo amigo) passa pelo inimigo")
	if is_instance_valid(boss_shot):
		boss_shot.queue_free()
	soldier.queue_free()
	player.queue_free()
	await frames(2)


# --- v0.31 · Etapa 1 do Pacote de Expansão: ajustes de base ----------------------------

## Abre uma fase com as listas novas do Inspector (saídas, zonas, objetos,
## armadilhas) montadas em volta da Câmara. 1ª passada só para achar a Câmara.
func _open_level_with(path: String, build_defs: Callable) -> Level:
	Game.pending_spawn = "camara"
	var probe := (load(path) as PackedScene).instantiate() as Level
	_world.add_child(probe)
	await frames(2)
	var home := Level.cell_at(probe.spawns["camara"])
	probe.free()
	await frames(2)
	Game.pending_spawn = "camara"
	var level := (load(path) as PackedScene).instantiate() as Level
	build_defs.call(level, home)
	_world.add_child(level)
	await frames(5)
	return level


func test_conditions_language() -> void:
	Game.reset_progress()
	check(Game.requirement_met("") and not Game.requirement_met("aldir"), "vazio = sempre; chefe não vencido = não")
	Game.defeated_bosses.assign(["aldir", "nyssa"])
	check(Game.requirement_met("aldir") and Game.requirement_met("chefe:nyssa"), "chefe (jeito antigo e por extenso)")
	check(Game.requirement_met("memorias:2") and not Game.requirement_met("memorias:3"), "memorias:N conta as memórias de chefe")
	check(not Game.requirement_met("flag:atalho_galho") and Game.requirement_met("!flag:atalho_galho"), "flag e o contrário (!)")
	Game.set_flag("atalho_galho")
	check(Game.requirement_met("flag:atalho_galho"), "flag ligada")
	check(not Game.requirement_met("item:flor_de_pedra") and Game.requirement_met("memorias:6|chefe:aldir"), "item que não tem; OU (|)")
	check(not Game.requirement_met("chefe:aldir+item:flor_de_pedra"), "E (+) exige todas")
	Game.set_world_state("bau_teste")
	check(Game.requirement_met("estado:bau_teste"), "estado de objeto do mundo")
	Game.reset_progress()


func test_listed_exits_open_by_flag() -> void:
	Game.reset_progress()
	var level := await _open_level_with(CIDADE, func(l: Level, home: Vector2i):
		l.exits = [{"cell": home + Vector2i(2, 0), "scene": TEATRO, "spawn": "porta",
			"requires": "flag:atalho_teste", "locked_dialogue": "borda", "arrival": "atalho_teste"}])
	var mine := func() -> int:
		return level._locked_exits.filter(func(lock): return lock["requires"] == "flag:atalho_teste").size()
	check(mine.call() == 1 and not level.spawns.has("atalho_teste"), "saída da lista começa trancada (flag desligada)")
	Game.set_flag("atalho_teste")
	await frames(2)
	check(mine.call() == 0 and level.spawns.has("atalho_teste"), "ligou a flag: abre NA HORA")
	level.queue_free()
	await frames(2)
	Game.reset_progress()


func test_world_objects_remember() -> void:
	Game.reset_progress()
	var level := await _open_level_with(CIDADE, func(l: Level, home: Vector2i):
		l.objects = [
			{"kind": "bau", "cell": home + Vector2i(2, -1), "key": "bau_teste", "item": "sucata_temperada", "count": 2},
			{"kind": "atalho", "cell": home + Vector2i(-2, -1), "key": "atalho_teste", "abre_de": "oeste", "locked_dialogue": "borda"},
		])
	var found := get_tree().get_nodes_in_group("world_objects")
	check(found.size() == 2, "baú e porta de atalho no mapa")
	var chest: WorldObject = found.filter(func(o): return o.kind == "bau")[0]
	var door: WorldObject = found.filter(func(o): return o.kind == "atalho")[0]
	chest.activate()
	check(Game.item_count("sucata_temperada") == 2 and Game.world_flag("bau_teste"), "abriu o baú: item e estado")
	check(not door.can_open_from(door.global_position + Vector2(20, -8)), "atalho: do lado de lá não abre")
	check(door.can_open_from(door.global_position + Vector2(-20, -8)), "atalho: do lado certo (oeste) abre")
	door.activate()
	check(Game.has_flag("atalho_teste"), "atalho aberto liga a flag de mesmo nome")
	level._respawn_enemies()  # descansar
	Game.respawn()  # morrer
	Game.wake_from_capsule = false
	check(Game.world_flag("bau_teste") and Game.world_flag("atalho_teste"), "nem descanso nem morte fecham")
	var keep_path := Game.save_path
	Game.persistence_enabled = true
	Game.save_path = "user://teste_mundo.json"
	Game.save_game()
	Game.world_state = {}
	Game.load_game()
	check(Game.world_flag("bau_teste") and Game.world_flag("atalho_teste"), "o estado vai no save")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Game.save_path))
	Game.save_path = keep_path
	Game.persistence_enabled = false
	level.queue_free()
	await frames(2)
	Game.reset_progress()


func test_zones_alarm_and_spawn_rules() -> void:
	Game.reset_progress()
	var probe := await _open_level_with(CIDADE, func(_l: Level, _home: Vector2i): pass)
	var points: Array = probe._enemy_spawns.map(func(sp): return Level.cell_at(sp["at"]))
	probe.queue_free()
	await frames(2)
	var first: Vector2i = points[0]
	var rect := Rect2i(first - Vector2i(1, 1), Vector2i(3, 3))
	var inside := points.filter(func(c): return rect.has_point(c)).size()
	var level := await _open_level_with(CIDADE, func(l: Level, home: Vector2i):
		l.zones = [{"id": "alarme_teste", "rect": rect, "triggers": [home + Vector2i(1, 1)]}])
	var tagged := get_tree().get_nodes_in_group("respawnable").filter(func(e): return e.get_meta(&"zona", "") == "alarme_teste")
	check(tagged.size() == inside and inside >= 1, "inimigos da zona levam a marca (%d)" % tagged.size())
	var trigger := get_tree().get_first_node_in_group("zone_triggers") as ZoneTrigger
	var called := trigger.fire()
	check(called == inside and (tagged[0] as Enemy).is_alerted(), "o alarme chama a zona inteira (%d)" % called)
	check((tagged[0] as Enemy).can_see(Vector2(-9999, -9999)), "alarmado: enxerga você de qualquer lugar")
	check(trigger.fire() == 0, "o alarme toca uma vez por visita")
	level.queue_free()
	await frames(2)
	# Grupo que some para sempre depois de uma flag.
	Game.set_flag("corneteiro_teste")
	level = await _open_level_with(CIDADE, func(l: Level, _home: Vector2i):
		l.zones = [{"id": "grupo_teste", "rect": rect, "requires": "!flag:corneteiro_teste"}])
	var still := get_tree().get_nodes_in_group("respawnable").filter(func(e): return e.get_meta(&"zona", "") == "grupo_teste")
	check(still.is_empty(), "flag ligada: o grupo da zona não nasce mais")
	level.queue_free()
	await frames(2)
	Game.reset_progress()


func test_periodic_trap() -> void:
	var player := spawn_player(Vector2(200, 200))
	var cell := Level.cell_at(player.global_position)
	var trap := PeriodicTrap.spawn(self, {"kind": "pilao", "cells": [cell], "period": 1.0, "warning": 0.4, "damage": 15})
	check(trap.phase() == "descanso", "começa em descanso")
	var hp := player.stats.health
	await seconds(1.05)
	check(player.stats.health < hp, "no golpe, quem está em cima leva dano (%.0f → %.0f)" % [hp, player.stats.health])
	hp = player.stats.health
	player.global_position += Vector2(48, 0)
	await seconds(1.0)
	check(is_equal_approx(player.stats.health, hp), "fora da armadilha: nada")
	trap.queue_free()
	player.queue_free()
	await frames(2)


func test_dialogue_conditions_and_name() -> void:
	Game.reset_progress()
	DialogueData.get_entry("fada")  # carrega o arquivo
	DialogueData._entries["teste_base"] = {"falas": ["Oi, ratinho."], "variantes": [{"quando": "flag:teste_v", "usar": "teste_outra"}],
		"opcoes": [{"tipo": "nome", "personagem": "teste", "sim": "flag:teste_disse", "nao": ""}, {"texto": "Sair", "acao": "", "quando": "!flag:teste_v"}]}
	DialogueData._entries["teste_outra"] = {"falas": ["Outra."]}
	check(DialogueData.variant("teste_base") == "teste_base", "sem a flag: a fala de sempre")
	check(DialogueData.fill("Cobaia: {nome}") == "Cobaia: ...", "texto escrito sem nome: \"...\"")
	Game.set_player_name("  Alexandre  ")
	check(DialogueData.fill("Cobaia: {nome}") == "Cobaia: Alexandre", "{nome} vira o nome no texto ESCRITO")
	# Jogo DUBLADO: nenhuma fala do dialogos.json pode usar o nome do jogador.
	var spoken_with_name := []
	for id: String in DialogueData._entries:
		var entry: Variant = DialogueData._entries[id]
		if entry is Dictionary and not (entry as Dictionary).get("escrito", false):  # texto lido (terminal) pode
			for line: Variant in (entry as Dictionary).get("falas", []):
				if str(line).contains("{nome}"):
					spoken_with_name.append(id)
	check(spoken_with_name.is_empty(), "nenhuma FALA diz o nome do jogador (dublagem): %s" % [spoken_with_name])
	var options := DialogueBox.expand_options(DialogueData.get_entry("teste_base")["opcoes"])
	check(options.size() == 3 and options[0]["texto"] == "Não lembro" and options[1]["texto"] == "Alexandre",
		"opção de nome: \"Não lembro\" e o nome")
	Game.set_flag("teste_v")
	check(DialogueData.variant("teste_base") == "teste_outra", "flag ligada: a variante do .json")
	check(DialogueBox.expand_options(DialogueData.get_entry("teste_base")["opcoes"]).size() == 2, "\"quando\" esconde opção")
	var level := await open_level(TEATRO, "camara")
	await level._on_dialogue_action(options[1]["acao"])
	check(Game.has_flag("nome_dito_teste") and Game.has_flag("teste_disse"), "disse o nome: nome_dito_<personagem> + a ação junto")
	check(level.resolve_dialogue("teste_base") == "teste_outra" and level.resolve_dialogue("fada") == "fada",
		"Level usa as variantes do .json e mantém as antigas")
	level.queue_free()
	await frames(2)
	DialogueData._entries.erase("teste_base")
	DialogueData._entries.erase("teste_outra")
	Game.reset_progress()


func test_ally_base_levels_and_arena() -> void:
	Game.reset_progress()
	Game.flags["tiao_acompanha"] = true
	var level := await open_level(CIDADE, "porta")
	var guard := get_tree().get_first_node_in_group(&"allies") as Ally
	check(guard is TiaoAliado and guard.ally_id == "tiao", "o Tião é um Ally")
	var base_hp := guard.max_health
	level._reward_allies(true)
	check(Game.ally_level("tiao") == 2, "venceram juntos: nível 2")
	guard.fall()
	check(Game.ally_level("tiao") == 2, "cair não tira nível")
	level.queue_free()
	await frames(2)
	Game.flags["tiao_acompanha"] = true
	level = await open_level(CIDADE, "porta")
	guard = get_tree().get_first_node_in_group(&"allies") as Ally
	check(is_equal_approx(guard.max_health, base_hp * (1.0 + Ally.LEVEL_BONUS)), "nível 2: mais vida (%.0f)" % guard.max_health)
	level.queue_free()
	await frames(2)
	Game.flags["tiao_acompanha"] = false
	level = await open_level(TEATRO, "camara")
	await level._on_dialogue_action("lute_comigo:tiao")
	level.queue_free()
	await frames(2)
	level = await open_level("res://scenes/world/arena_aldir.tscn", "porta")
	var in_arena := get_tree().get_nodes_in_group(&"allies").filter(func(a): return not a.is_queued_for_deletion())
	check(in_arena.size() == 1, "\"Lute comigo\": ele entra na arena do Pecado")
	level._reward_allies(false)
	check(not Game.flags.has("tiao_na_arena"), "a chamada vale para uma luta")
	level.queue_free()
	await frames(2)
	Game.reset_progress()


# --- v0.31 · Etapa 2: mapa livre e atalhos ------------------------------------------------

## Os destinos abertos de uma fase: cena → número de saídas para ela.
func _open_destinations() -> Array:
	var result: Array = []
	for exit in _world.find_children("*", "AreaExit", true, false):
		result.append((exit as AreaExit).target_scene.get_file().get_basename())
	return result


func test_free_map_layout() -> void:
	Game.reset_progress()
	Game.prologue_done = true
	var level := await open_level(TEATRO, "camara")
	var open := _open_destinations()
	for area in ["cidade", "bosque", "forjas"]:
		check(open.has(area), "Teatro: o caminho para %s já começa aberto (%s)" % [area, open])
	check(not open.has("nucleo"), "o Núcleo continua pedindo as sete memórias")
	level.queue_free()
	await frames(2)
	var expected := {
		# v0.35: a Cidade virou Avenida → Quartel → Viaduto → Montanha (e a Torre ao lado).
		"cidade": ["teatro", "cidade_quartel", "cidade_torre"], "forjas": ["teatro", "forjas_fornalha", "forjas_dancarina"],
		"raizes": ["forjas_passarela", "raizes_despensa", "raizes_enfermaria"], "dominio": ["forjas_passarela", "dominio_arquivo", "dominio_aula"], "montanha": ["cidade_viaduto", "montanha_ossario", "montanha_fosso"],
		"bosque": ["teatro", "bosque_dormitorio", "bosque_sino"],
	}
	for area: String in expected:
		level = await open_level("res://scenes/world/%s.tscn" % area, "camara")
		open = _open_destinations()
		for target: String in expected[area]:
			check(open.has(target), "%s → %s livre (%s)" % [area, target, open])
		level.queue_free()
		await frames(2)
	# Atalhos: trancados do lado de cá, abertos para sempre por quem passa do lado de lá.
	level = await open_level("res://scenes/world/bosque.tscn", "camara")
	open = _open_destinations()
	check(not open.has("dominio") and not open.has("montanha_encosta"), "Bosque: galho e espinha começam trancados")
	level.queue_free()
	await frames(2)
	level = await open_level(ENCOSTA, "porta")  # v0.35: a espinha fica na Encosta
	var spine: AreaExit = _world.find_children("*", "AreaExit", true, false).filter(
		func(e): return e.target_scene.ends_with("bosque.tscn"))[0]
	check(spine.opens_flag == "atalho_espinha", "a espinha, do lado da Montanha, abre o atalho")
	Game.scene_changes_enabled = false
	spine._armed = true
	spine._on_body_entered(level.player)
	check(Game.has_flag("atalho_espinha"), "passou pela espinha: atalho aberto")
	level.queue_free()
	await frames(2)
	level = await open_level("res://scenes/world/bosque.tscn", "camara")
	open = _open_destinations()
	check(open.has("montanha_encosta") and not open.has("dominio"), "no Bosque, a espinha abriu e o galho continua trancado")
	level.queue_free()
	await frames(2)
	Game.respawn()
	Game.wake_from_capsule = false
	check(Game.has_flag("atalho_espinha"), "atalho aberto nunca fecha (nem morrendo)")
	Game.reset_progress()


## As áreas difíceis batem e aguentam mais, mesmo para quem chega cedo.
func test_area_power() -> void:
	var expected := {"cidade": 1.0, "raizes": 1.15, "montanha": 1.3, "dominio": 1.45}
	for area: String in expected:
		var level := await open_level("res://scenes/world/%s.tscn" % area, "camara")
		var enemies := get_tree().get_nodes_in_group("respawnable").filter(func(e): return e is Enemy and not (e is Boss))
		check(not enemies.is_empty() and is_equal_approx((enemies[0] as Enemy).area_power, expected[area]),
			"%s: força %.2f" % [area, expected[area]])
		if area == "dominio" and not enemies.is_empty():
			var enemy := enemies[0] as Enemy
			var info := HitInfo.create(10.0, enemy.global_position, level.player.global_position)
			info.source = enemy
			var hp := level.player.stats.health
			level.player._iframes_left = 0.0
			level.player._on_hit_received(info)
			check(is_equal_approx(hp - level.player.stats.health, 14.5), "Domínio: golpe de 10 vira 14,5 (%.1f)" % (hp - level.player.stats.health))
		level.queue_free()
		await frames(2)


# --- v0.33 · Etapa 3: cápsulas, baús e mímicos ---------------------------------------------

func test_second_capsule_per_island() -> void:
	Game.reset_progress()
	Game.prologue_done = true
	# A Cidade e o Bosque (v0.35) guardam a 2ª Câmara numa fase anexa: testadas à parte.
	# v0.35: TODAS as ilhas guardam a 2ª Câmara numa fase anexa (depois do 1º mini-chefe).
	var archive := await open_level(ARQUIVO, "camara")
	check(archive.chamber_for("camara") != null and find_npc("placa_dominio_arquivo_1") != null, "Arquivo: a 2ª Câmara do Domínio, com placa")
	check(archive.entities.get_children().filter(func(n): return n is ItemPickup and n.item_id == Level.KEEPSAKES["dominio"]).size() == 1,
		"Arquivo: o pertence do Domínio")
	archive.queue_free()
	await frames(2)
	check(Game.capsule_info(FORNALHA)["place"] == "Fornalha", "a 2ª das Forjas é a Fornalha")
	var bones := await open_level(OSSARIO, "camara")
	check(bones.chamber_for("camara") != null and find_npc("placa_montanha_ossario_1") != null, "Ossário: a 2ª Câmara da Montanha, com placa")
	check(bones.entities.get_children().filter(func(n): return n is ItemPickup and n.item_id == Level.KEEPSAKES["montanha"]).size() == 1,
		"Ossário: o pertence da Montanha")
	bones.queue_free()
	await frames(2)
	var pantry := await open_level(DESPENSA, "camara")
	check(pantry.chamber_for("camara") != null and find_npc("placa_raizes_despensa_1") != null, "Despensa: a 2ª Câmara das Raízes, com placa")
	check(pantry.entities.get_children().filter(func(n): return n is ItemPickup and n.item_id == Level.KEEPSAKES["raizes"]).size() == 1,
		"Despensa: o pertence das Raízes")
	pantry.queue_free()
	await frames(2)
	var furnace := await open_level(FORNALHA, "camara")
	check(furnace.chamber_for("camara") != null and find_npc("placa_forjas_fornalha_1") != null, "Fornalha: a 2ª Câmara das Forjas, com placa")
	check(furnace.entities.get_children().filter(func(n): return n is ItemPickup and n.item_id == Level.KEEPSAKES["forjas"]).size() == 1,
		"Fornalha: o pertence das Forjas")
	furnace.queue_free()
	await frames(2)
	check(Game.CAPSULES.size() == 15, "15 Câmaras no jogo (%d)" % Game.CAPSULES.size())
	# Bosque: uma Câmara na Margem, a outra (com placa e pertence) no Dormitório.
	var shore := await open_level(BOSQUE, "camara")
	check(shore.rest_chambers.size() == 1, "Margem: uma Câmara")
	shore.queue_free()
	await frames(2)
	var dorm := await open_level(DORMITORIO, "camara")
	check(dorm.chamber_for("camara") != null and find_npc("placa_bosque_dormitorio_1") != null, "Dormitório: a 2ª Câmara do Bosque, com placa")
	check(dorm.entities.get_children().filter(func(n): return n is ItemPickup and n.item_id == Level.KEEPSAKES["bosque"]).size() == 1,
		"Dormitório: o pertence do Bosque")
	dorm.queue_free()
	await frames(2)
	# Cidade: uma Câmara na Avenida, a outra (com placa e pertence) no Quartel.
	var avenue := await open_level("res://scenes/world/cidade.tscn", "camara")
	check(avenue.rest_chambers.size() == 1, "Avenida: uma Câmara")
	avenue.queue_free()
	await frames(2)
	Game.wake_from_capsule = true
	var level := await open_level("res://scenes/world/cidade_quartel.tscn", "camara")
	var second := level.chamber_for("camara")
	check(second != null, "Quartel: a 2ª Câmara da Cidade")
	var plaques := get_tree().get_nodes_in_group("npcs").filter(func(n): return (n as NPC).dialogue_id == "placa_cidade_quartel_1")
	check(plaques.size() == 1, "Quartel: a placa da Câmara")
	var keepsake := level.entities.get_children().filter(func(n): return n is ItemPickup and n.item_id == Level.KEEPSAKES["cidade"])
	check(keepsake.size() == 1, "Quartel: o pertence da Cidade")
	# Descansar nela e morrer: renasce NELA (e sai dela).
	await wait_for(func(): return level.player.state == Player.State.FREE, 600)
	check(level.player.global_position.distance_to(second.front_point()) < 12.0, "acorda saindo da 2ª Câmara")
	Game.set_rest_point(level.scene_file_path, "camara")
	check(Game.rest_spawn == "camara" and Game.is_capsule_unlocked("res://scenes/world/cidade_quartel.tscn"),
		"a 2ª vira ponto de renascer e destino de viagem")
	level.queue_free()
	await frames(2)
	Game.reset_progress()


func test_chests_open_and_break() -> void:
	Game.reset_progress()
	var level := await open_level(CIDADE, "camara")
	var chests := get_tree().get_nodes_in_group("world_objects").filter(func(o): return o.kind == "bau")
	check(chests.size() == 2, "a Cidade tem 2 baús (%d)" % chests.size())
	var first: WorldObject = chests[0]
	var second: WorldObject = chests[1]
	first.activate()
	check(Game.item_count(first.item) >= 1 and first.chest_state() == "aberto", "abriu: o item e o estado")
	check(not first.interactable.enabled, "aberto fica aberto (sem botão)")
	var lost := second.item
	for i in WorldObject.HITS_TO_BREAK:
		second.hurtbox.receive_hit(HitInfo.create(10.0, second.global_position + Vector2(10, 0), second.global_position))
	await frames(2)
	check(second.chest_state() == "quebrado" and Game.item_count(lost) == 0, "3 golpes: quebrou e o que tinha dentro se perdeu")
	var broken := level.entities.get_children().filter(func(n): return n is ItemPickup and n.item_id == "algo_quebrado")
	check(broken.size() == 1, "no lugar, cai o Algo Quebrado")
	check(second.interactable.prompt == "Examinar" and Game.world_count("quebrado") == 1 and Game.world_count("aberto") == 1,
		"o baú quebrado vira Examinar; o jogo conta abertos e quebrados")
	level.queue_free()
	await frames(2)
	level = await open_level(CIDADE, "camara")
	chests = get_tree().get_nodes_in_group("world_objects").filter(func(o): return o.kind == "bau")
	check(chests.all(func(o): return not o.chest_state().is_empty()), "voltando à área, os dois continuam como ficaram")
	level.queue_free()
	await frames(2)
	Game.reset_progress()


func test_mimic() -> void:
	Game.reset_progress()
	var level := await open_level(CIDADE, "camara")
	var mimics := level.entities.get_children().filter(func(n): return n is Mimico)
	check(mimics.size() == 1, "um mímico na Cidade")
	var mimic: Mimico = mimics[0]
	var chest: WorldObject = get_tree().get_nodes_in_group("world_objects").filter(func(o): return o.kind == "bau")[0]
	check(mimic.body_sprite.flip_h and mimic.body_sprite.sprite_frames.get_frame_texture(&"fechado", 0) == WorldObject.CHEST_CLOSED,
		"o mímico é o baú comum ESPELHADO")
	check(not mimic.is_in_group("enemies") and mimic.interactable.prompt == chest.interactable.prompt, "dormindo: parece um baú (\"Abrir\")")
	# Abrir = agarrão + mordida.
	var player := level.player
	await wait_for(func(): return player.state == Player.State.FREE, 300)
	await seconds(1.0)
	player._iframes_left = 0.0
	player.hurtbox.invulnerable = false
	var hp := player.stats.health
	mimic.global_position = player.global_position + Vector2(14, 0)
	mimic._on_opened(player)
	check(player.is_grabbed_by(mimic) and player.stats.health < hp, "abriu: ele agarra e morde")
	player.release_grab()
	await frames(3)
	check(mimic.ai == Mimico.AI.AWAKE and mimic.is_in_group("enemies"), "solto: ele está acordado")
	mimic.stats.take_damage(99999.0)
	await frames(3)
	check(Game.world_state.get("mimico_cidade", "") == "morto", "vencido fica vencido (no save)")
	var dropped := level.entities.get_children().filter(func(n): return n is ItemPickup and n.item_id == "fragmento_turvo")
	check(dropped.size() >= 1, "deixa o que guardava")
	level.queue_free()
	await frames(2)
	level = await open_level(CIDADE, "camara")
	check(level.entities.get_children().filter(func(n): return n is Mimico).is_empty(), "não volta, nem descansando")
	level.queue_free()
	await frames(2)
	# Um golpe basta para acordar.
	Game.reset_progress()
	level = await open_level(CIDADE, "camara")
	mimic = level.entities.get_children().filter(func(n): return n is Mimico)[0]
	mimic.hurtbox.receive_hit(HitInfo.create(5.0, mimic.global_position + Vector2(10, 0), mimic.global_position))
	await frames(2)
	check(mimic.ai == Mimico.AI.AWAKE, "um golpe e ele acorda")
	level.queue_free()
	await frames(2)
	Game.reset_progress()


func test_lab_capsule_after_prologue() -> void:
	Game.reset_progress()
	check(not Game.is_capsule_unlocked(Game.START_SCENE), "antes do Prólogo acabar, o laboratório não é destino")
	Game.prologue_done = true
	check(Game.is_capsule_unlocked(Game.START_SCENE), "depois, a cápsula do laboratório vira destino")
	Game.scene_changes_enabled = false
	var level := await open_level(Game.START_SCENE, "camara") as Prologo
	await wait_for(func(): return level.player.state == Player.State.FREE, 600)
	Game.last_scene_request = ""
	level.start_fall()
	await wait_for(func(): return not Game.last_scene_request.is_empty(), 300)
	check(Game.last_scene_request == Game.HUB_SCENE and Game.prologue_done, "cair de novo leva ao Teatro, sem refazer o fim do prólogo")
	Game.wake_from_capsule = false
	level.queue_free()
	await frames(2)
	Game.reset_progress()


# --- v0.34 · Etapa 4: armaduras com defesa e peso ------------------------------------------

func test_armor_defense() -> void:
	Game.reset_progress()
	check(is_zero_approx(Game.armor_defense("fisico")), "sem armadura: nada protege")
	_wear_set("detentor")
	check(is_equal_approx(Game.armor_defense("fisico"), 0.32 * 1.1), "Detentor inteiro: 32%% físico +10%% de corpo completo (%.3f)" % Game.armor_defense("fisico"))
	Game.unequip_armor("botas")
	check(Game.armor_defense("fisico") < 0.32, "faltou uma parte: sem o bônus de corpo completo")
	Game.equip_armor("botas_caelis")
	Game.add_item("botas_caelis", 1, false)
	Game.equip_armor("botas_caelis")
	var mixed := Game.armor_defense("fisico")
	check(mixed > 0.25 and mixed < 0.352, "misturando conjuntos o bônus também vale (%.3f)" % mixed)
	for set_id: String in ArmorSets.PROFILES:
		for kind in ArmorSets.DAMAGE_TYPES:
			var full := 0.0
			for slot in ArmorData.SLOTS:
				full += ArmorSets.piece_defense(set_id, slot, kind)
			check(full * 1.1 <= ArmorSets.DEFENSE_CAP, "%s/%s abaixo do teto" % [set_id, kind])
	# O golpe de verdade, no herói.
	Game.reset_progress()
	_wear_set("caelis")
	var player := spawn_player(Vector2(200, 200))
	await frames(2)
	var fire := HitInfo.create(100.0, Vector2(180, 200), player.global_position)
	fire.damage_type = "fogo"
	var hp := player.stats.health
	player._on_hit_received(fire)
	check(is_equal_approx(hp - player.stats.health, 100.0 * (1.0 - 0.34 * 1.1)), "Caelis segura fogo (%.1f)" % (hp - player.stats.health))
	player.stats.health = player.stats.max_health
	player._iframes_left = 0.0
	player._set_state(Player.State.FREE)
	var cut := HitInfo.create(100.0, Vector2(180, 200), player.global_position)
	hp = player.stats.health
	player._on_hit_received(cut)
	check(is_equal_approx(hp - player.stats.health, 100.0 * (1.0 - 0.18 * 1.1)), "e menos o físico (%.1f)" % (hp - player.stats.health))
	player.queue_free()
	await frames(2)
	Game.reset_progress()


func test_equip_load_and_roll() -> void:
	Game.reset_progress()
	Game.equipped_weapon = "espada"
	check(Game.load_tier() == "rapido", "quase nada no corpo: rolamento rápido (%.0f%%)" % (Game.load_ratio() * 100.0))
	_wear_set("detentor")
	Game.add_item("escudo_remendado", 1, false)
	Game.left_hand = "escudo_remendado"
	check(is_equal_approx(Game.equip_load(), 27.0 + 3.0 + Game.SHIELD_WEIGHT), "carga = armadura + espada + escudo (%.1f)" % Game.equip_load())
	check(Game.load_tier() == "lento", "Detentor inteiro com Força 10: lento (%.0f%%)" % (Game.load_ratio() * 100.0))
	Game.attributes["forca"] = 30
	check(Game.load_tier() == "normal", "mais Força, mais carga: normal")
	Game.attributes["forca"] = 1
	check(Game.load_tier() == "pesado", "Força baixa: pesado demais")
	var player := spawn_player(Vector2(200, 200))
	await frames(2)
	player.stats.stamina = player.stats.max_stamina
	check(not player._start_dash(), "pesado demais: não rola")
	Game.attributes["forca"] = 10
	for slot in ArmorData.SLOTS:
		Game.unequip_armor(slot)
	Game.left_hand = ""
	check(player._start_dash() and is_equal_approx(player._dash_speed_scale, 1.1), "leve: rolamento rápido e longo")
	player.queue_free()
	await frames(2)
	Game.reset_progress()


## v0.30.2: "Gráficos: Leve" desenha a 480x270 e amplia (bem mais rápido).
func test_graphics_setting() -> void:
	var saved := Settings.graphics
	Settings.graphics = "leve"
	Settings.apply()
	check(get_window().content_scale_mode == Window.CONTENT_SCALE_MODE_VIEWPORT, "leve: desenha na resolução do jogo")
	Settings.toggle_graphics()
	check(Settings.graphics == "nitido" and get_window().content_scale_mode == Window.CONTENT_SCALE_MODE_CANVAS_ITEMS,
		"nítido: desenha na resolução da tela")
	Settings.graphics = saved
	Settings.apply()

# --- v0.23: 3 saves, armas no chão, loja e Ferreiro novos -------------------------------------

func _clear_test_slots() -> void:
	for n in range(1, Game.SLOT_COUNT + 1):
		for suffix in ["", ".bak", ".tmp"]:
			DirAccess.remove_absolute(ProjectSettings.globalize_path(Game.slot_path(n) + suffix))


func test_save_slots() -> void:
	_clear_test_slots()
	var keep_path := Game.save_path
	Game.persistence_enabled = true
	Settings.persistence_enabled = false
	check(not Game.any_save() and Game.slot_summary(1).is_empty(), "sem saves: os 3 slots vazios")
	# Slot 2: um personagem.
	Game.reset_progress()
	Game.use_slot(2)
	Game.memories = 777
	Game.deaths = 3
	Game.attributes["forca"] = 15
	Game.appearance = {"sexo": 1, "corpo": 2, "rosto": 0, "cabelo": 3}
	Game.rest_scene = "res://scenes/world/cidade.tscn"
	Game.defeated_bosses.append("aldir")
	Game.play_seconds = 3725.0
	Game.save_game()
	# Slot 3: outro personagem.
	Game.reset_progress()
	Game.use_slot(3)
	Game.memories = 5
	Game.save_game()
	check(Game.any_save() and not Game.slot_has_save(1) and Game.slot_has_save(2) and Game.slot_has_save(3), "cada slot é um arquivo")
	var info := Game.slot_summary(2)
	check(info["memorias"] == 777 and info["mortes"] == 3 and info["nivel"] == 6, "resumo do slot 2 (sem carregar o jogo)")
	check(info["area"] == "Cidade Estilhaçada" and info["pecados"] == 1, "onde parou e quantos Pecados caíram")
	check(Game.format_play_time(info["tempo"]) == "1:02", "tempo de jogo 1:02")
	check(info["aparencia"]["sexo"] == 1, "a aparência do personagem daquele save")
	# Carregar o slot 2 não mexe no 3.
	Game.use_slot(2)
	Game.load_game()
	check(Game.memories == 777, "carregou o slot 2")
	Game.use_slot(3)
	Game.load_game()
	check(Game.memories == 5, "o slot 3 continua o dele")
	Game.delete_save()
	check(not Game.slot_has_save(3) and Game.slot_has_save(2), "apagar um slot não apaga os outros")
	# Migração: o save único das versões antigas vira o slot 1.
	var legacy := ProjectSettings.globalize_path("user://teste_legado.json")
	var file := FileAccess.open(legacy, FileAccess.WRITE)
	file.store_string(JSON.stringify({"version": 3, "memories": 42}))
	file.close()
	check(Game.slot_summary(1).is_empty(), "slot 1 vazio antes da migração")
	DirAccess.rename_absolute(legacy, ProjectSettings.globalize_path(Game.slot_path(1)))  # o que _migrate_single_save faz
	check(Game.slot_summary(1)["memorias"] == 42, "o save antigo aparece no slot 1")
	Game.persistence_enabled = false
	_clear_test_slots()
	Game.save_path = keep_path
	Game.reset_progress()


func test_title_with_slots() -> void:
	_clear_test_slots()
	Game.persistence_enabled = true
	Game.reset_progress()
	Game.use_slot(2)
	Game.memories = 900
	Game.save_game()
	Game.persistence_enabled = false
	var title := (load("res://scenes/ui/title_screen.tscn") as PackedScene).instantiate()
	add_child(title)
	await frames(2)
	title.show_menu()
	var labels: Array = title._menu.get_children().map(func(b): return (b as Button).text)
	check(labels.has("Carregar") and labels.has("Novo jogo"), "título com Carregar: %s" % [labels])
	title.open_slots("carregar")
	await frames(2)
	var slots: SlotMenu = title._slots
	check(slots._cards[0].disabled and not slots._cards[1].disabled and slots._cards[2].disabled, "Carregar: só o slot com save")
	check(get_viewport().gui_get_focus_owner() == slots._cards[1], "o foco vai direto no save que existe")
	slots._cancel()
	await frames(2)
	# Novo jogo num slot OCUPADO pede confirmação.
	title.open_slots("novo")
	await frames(2)
	slots = title._slots
	check(not slots._cards[0].disabled and get_viewport().gui_get_focus_owner() == slots._cards[0], "Novo jogo: começa no primeiro slot livre")
	slots._cards[1].pressed.emit()
	await frames(1)
	check(title._slots != null and title._creation == null and slots._hint.text.contains("APAGADO"), "slot ocupado: avisa que vai apagar")
	slots._cards[1].pressed.emit()
	await frames(2)
	if title._cutscene:
		title._cutscene.skip()
		await frames(2)
	check(title._creation != null and title._new_slot == 2, "apertou de novo: vai criar no slot 2")
	title.queue_free()
	await frames(2)
	_clear_test_slots()
	Game.save_path = TEST_SAVE
	Game.reset_progress()


func test_weapon_drops() -> void:
	Game.reset_progress()
	var chance := Enemy.weapon_drop_chance
	check(is_equal_approx(chance, 0.03), "3% de chance por inimigo comum")
	Enemy.weapon_drop_chance = 1.0  # sorte garantida, só para o teste
	var soldier := spawn_enemy_scene(SOLDIER_SCENE, Vector2(200, 200))
	await frames(2)
	soldier.stats.take_damage(9999.0)
	await frames(3)
	var drops := _world.get_children().filter(func(n): return n is ItemPickup and Items.get_weapon(n.item_id) != null)
	check(drops.size() == 1 and Game.forgeable_weapons().has(drops[0].item_id), "o soldado deixou uma arma de chefe: %s" % [drops.map(func(d): return d.item_id)])
	(drops[0] as ItemPickup).take()
	check(Game.owns_weapon(drops[0].item_id), "pegou: a arma vai para o inventário")
	# Chefe não deixa arma por sorte (já deixa Lembrança).
	var boss := Boss.new()
	check(boss is Boss, "chefes ficam de fora")
	boss.free()
	# Já tem duas de todas: nada para sortear.
	for id in Game.forgeable_weapons():
		Game.add_item(id, 2, false)
	check(Enemy.pick_weapon_drop() == "", "com duas de cada, nenhuma arma cai")
	Enemy.weapon_drop_chance = chance
	Game.reset_progress()


func test_shop_buy_and_sell() -> void:
	Game.reset_progress()
	Game.memories = 3000
	var level := await open_level("res://scenes/world/teatro.tscn", "camara")
	check(DialogueData.get_entry("vendedor")["opcoes"][0]["acao"] == "loja", "o Vendedor oferece 'Negociar'")
	level._on_dialogue_action("loja")
	await frames(2)
	var shop := level.hud.shop_menu
	check(shop.visible, "a loja abre")
	var ids := shop._slots.map(func(b): return b.get_meta("id"))
	check(ids == ["frasco_sanidade", "sucata_temperada", "fragmento_turvo"], "estoque com imagem: %s" % [ids])
	check(shop._slots[0].icon != null and shop.detail_icon.texture != null, "cada item tem imagem (na grade e na ficha)")
	var flasks := Game.sanity_flasks
	shop.select("frasco_sanidade")
	shop._activate("frasco_sanidade")
	check(Game.sanity_flasks == flasks + 1 and Game.memories == 3000 - Game.SANITY_FLASK_PRICE, "comprou Frasco de Sanidade")
	shop._activate("fragmento_turvo")
	shop._activate("fragmento_turvo")
	shop._activate("fragmento_turvo")
	check(Game.shop_left("fragmento_turvo") == 0 and Game.shop_block_reason("fragmento_turvo") in ["esgotado", "memories"], "fragmentos têm limite")
	Game.memories = 5000
	check(Game.shop_block_reason("fragmento_turvo") == "esgotado" and not Game.buy_from_shop("fragmento_turvo"), "esgotou: não vende mais")
	# Vender.
	shop.set_tab(1)
	var sell_ids := shop._slots.map(func(b): return b.get_meta("id"))
	check(sell_ids.has("fragmento_turvo"), "aba Vender: o que dá para vender")
	var before := Game.memories
	shop._activate("fragmento_turvo")
	check(Game.memories == before + Game.sell_price("fragmento_turvo") and Game.item_count("fragmento_turvo") == 2, "vendeu um fragmento")
	Game.add_item("lembranca_aldir", 1, false)
	Game.add_item("pilar_estilhacada", 1, false)
	Game.equip_weapon("pilar_estilhacada")
	check(Game.sell_price("lembranca_aldir") == 0 and not Game.sell_to_shop("lembranca_aldir"), "Lembranças não se vendem")
	check(not Game.sell_to_shop("pilar_estilhacada"), "a arma na mão não se vende")
	Game.add_item("pilar_estilhacada", 1, false)
	check(Game.sell_to_shop("pilar_estilhacada") and Game.weapon_count("pilar_estilhacada") == 1, "a cópia que sobra, sim")
	# Desconto depois da Rachel.
	Game.defeated_bosses.append("rachel")
	check(Game.shop_price("sucata_temperada") == int(round(Game.SUCATA_PRICE * 0.8)), "depois da Rachel, ele vende mais barato")
	shop.close()
	await frames(2)
	check(not shop.visible and not get_tree().paused, "Sair fecha a loja")
	level.queue_free()
	await frames(2)
	Game.reset_progress()



## Terceiro jeito de jogar (v0.24): Limpo — controle sem NADA na tela.
func test_clean_controls_mode() -> void:
	var saved := [Settings.controller_mode, Settings.pad_legend]
	Settings.controller_mode = false
	Settings.pad_legend = true
	var level := await open_level(CIDADE, "porta")
	var touch := level.hud.touch
	check(Settings.controls_mode() == "toque" and touch._root.visible, "começa no Toque")
	Settings.cycle_controls()
	check(Settings.controls_mode() == "controle" and touch.pad_hints.visible and not touch._root.visible, "Controle: legenda do PlayStation")
	Settings.cycle_controls()
	check(Settings.controls_mode() == "limpo", "Limpo")
	check(not touch._root.visible and not touch.pad_hints.visible, "Limpo: nem botões de toque nem legenda")
	check(not level.hud.pause_button.visible, "Limpo: nem o botão de pausa")
	check(Settings.controller_mode and TutorialHints.text_for("esquivar").contains(PadStyle.face_long("circle")), "as dicas continuam falando do controle (com o botão dele)")
	var options := OptionsMenu.new()
	add_child(options)
	await frames(1)
	options._refresh()
	check((options._rows["controle"] as Button).text.contains("Limpo"), "as Opções mostram o modo: %s" % (options._rows["controle"] as Button).text)
	options.queue_free()
	Settings.cycle_controls()
	check(Settings.controls_mode() == "toque" and touch._root.visible and level.hud.pause_button.visible, "e volta para o Toque")
	level.queue_free()
	await frames(2)
	Settings.controller_mode = saved[0]
	Settings.pad_legend = saved[1]
	Settings.apply()


# --- Armaduras (v0.25) ------------------------------------------------------------------

func _wear_set(set_id: String) -> void:
	for id in ArmorSets.pieces(set_id):
		Game.add_item(id, 1, false)
		Game.equip_armor(id)


func test_armor_rules() -> void:
	Game.reset_progress()
	check(ArmorSets.SETS.size() == 7, "sete conjuntos")
	for set_id: String in ArmorSets.SETS:
		for id in ArmorSets.pieces(set_id):
			var piece := Items.get_armor(id)
			check(piece != null and piece.set_id == set_id and piece.icon != null, "peça no catálogo, com ícone: %s" % id)
	check(not Game.equip_armor("peitoral_detentor"), "não veste o que não tem")
	# Força (Detentor): +4% por peça, vale para qualquer arma.
	var weapon := Game.current_weapon()
	var attack: AttackData = Game.BASE_LIGHT
	var plain := Game.weapon_hit_damage(weapon, attack)
	_wear_set("detentor")
	check(Game.armor_pieces("detentor") == 5 and is_equal_approx(Game.armor_bonus("forca"), 0.2), "5 peças: força +20%")
	check(is_equal_approx(Game.weapon_hit_damage(weapon, attack), plain * 1.2), "o dano do golpe sobe 20%")
	# Trocar uma peça: o espaço só tem uma.
	Game.add_item("luvas_caelis", 1, false)
	Game.equip_armor("luvas_caelis")
	check(Game.armor["luvas"] == "luvas_caelis" and Game.armor_pieces("detentor") == 4, "luvas novas tiram as antigas")
	check(is_equal_approx(Game.armor_bonus("forca"), 0.16) and is_equal_approx(Game.armor_bonus("passo"), 0.12), "misturar conjuntos soma cada um")
	Game.unequip_armor("luvas")
	check(Game.armor["luvas"] == "" and Game.armor_in("luvas") == null, "tirar deixa o espaço vazio")
	# Save: volta igual; peça trocada de espaço ou que você não tem é ignorada.
	var data := Game._to_dict()
	Game._from_dict(data)
	check(Game.armor["peitoral"] == "peitoral_detentor" and Game.armor_pieces("detentor") == 4, "o save guarda a armadura")
	data["armor"] = {"capacete": "calca_detentor", "botas": "botas_arconte", "peitoral": "peitoral_detentor"}
	Game._from_dict(data)
	check(Game.armor["capacete"] == "" and Game.armor["botas"] == "" and Game.armor["peitoral"] == "peitoral_detentor",
		"save estranho não veste calça na cabeça nem peça que você não tem")
	var old := {"version": 3, "inventory": {"espada": 1}}
	Game._from_dict(old)
	check(Game.armor.size() == 5 and Game.armor_bonus("forca") == 0.0, "save antigo (sem armadura) abre sem nada vestido")
	# Herói: vida (Vigília) e fôlego (Sono Leve).
	Game.reset_progress()
	var player := spawn_player()
	await frames(2)
	var base_health := player.stats.max_health
	player.stats.health = 30.0
	_wear_set("vigilia")
	await frames(1)
	check(is_equal_approx(player.stats.max_health, base_health * 1.3), "Vigília: vida máxima +30%% (%.1f → %.1f)" % [base_health, player.stats.max_health])
	check(is_equal_approx(player.stats.health, 30.0), "vestir não enche a vida (não é frasco)")
	_wear_set("sono")
	await frames(1)
	check(is_equal_approx(player.stats.regen_bonus, 1.6) and is_equal_approx(player.stats.health_scale, 1.0), "Sono Leve no lugar: estamina +60%, a vida volta ao normal")
	player.stats.regen_scale = 0.35  # escudo erguido...
	player.stats.regen_scale = 1.0   # ...e abaixado: a armadura continua
	check(is_equal_approx(player.stats.regen_bonus, 1.6), "abaixar o escudo não apaga o bônus da armadura")
	# Passo (Caelis): andar = correr sem armadura; correr fica mais rápido ainda.
	_wear_set("caelis")
	check(is_equal_approx(player.walk_multiplier(), player.sprint_speed_multiplier), "5 peças: andar = correr")
	check(player.sprint_multiplier() > player.sprint_speed_multiplier + 0.4, "e correr passa do correr normal")
	Input.action_press("move_right")
	await frames(40)
	var walking := player.velocity.length()
	Input.action_release("move_right")
	check(absf(walking - player.move_speed * 1.6) < 3.0, "andando a %.0f (normal %.0f)" % [walking, player.move_speed])
	# Alcance (Eco): o golpe sai mais longe.
	_wear_set("eco")
	await frames(10)
	player.stats.stamina = player.stats.max_stamina
	player._start_attack(Game.BASE_LIGHT, 0)
	check(is_equal_approx(player.hitbox_shape.position.x, Game.BASE_LIGHT.reach * 1.3), "Eco: alcance +30%")
	player.queue_free()
	await frames(2)
	# Memórias (Arconte) e drops (Banquete) nos inimigos.
	Game.reset_progress()
	_wear_set("arconte")
	var chance := Enemy.weapon_drop_chance
	Enemy.weapon_drop_chance = 0.0  # aqui só as memórias importam
	var soldier := spawn_enemy_scene(SOLDIER_SCENE, Vector2(200, 200))
	await frames(2)
	var expected := int(round(soldier.memory_reward * 1.4))
	soldier.stats.take_damage(9999.0)
	await frames(3)
	check(Game.memories == expected, "Arconte: +40%% de memórias (%d, esperado %d)" % [Game.memories, expected])
	_wear_set("banquete")
	Enemy.weapon_drop_chance = 0.58  # × 1.75 = mais de 100%: só cai se o Banquete contar
	var other := spawn_enemy_scene(SOLDIER_SCENE, Vector2(260, 200))
	await frames(2)
	other.stats.take_damage(9999.0)
	await frames(3)
	var drops := _world.get_children().filter(func(n): return n is ItemPickup and Items.get_weapon(n.item_id) != null)
	check(drops.size() == 1, "Banquete: +75% de chance de drop")
	Enemy.weapon_drop_chance = chance
	Game.reset_progress()


func test_armor_in_world_and_menu() -> void:
	Game.reset_progress()
	# v0.34 (Etapa 4): cada peça dos 6 conjuntos de chefe está em UM lugar só —
	# baú (capacete, luvas), mímico (peitoral), 1º mini-chefe (calça) e outra
	# ilha (botas). A Vigília continua inteira no Teatro.
	var regions := ["teatro", "cidade", "bosque", "raizes", "forjas", "montanha", "dominio",
		"cidade_quartel", "cidade_viaduto", "bosque_dormitorio", "bosque_borda", "forjas_fornalha", "forjas_passarela",
		"raizes_despensa", "raizes_varanda", "montanha_ossario", "montanha_encosta", "dominio_arquivo", "dominio_galeria"]  # v0.35: as fases anexas também
	var found := {}
	for region in regions:
		var level := (load("res://scenes/world/%s.tscn" % region) as PackedScene).instantiate() as Level
		for spec in level.item_points:
			if spec.begins_with("conjunto:"):
				for id in ArmorSets.pieces(spec.trim_prefix("conjunto:")):
					found[id] = found.get(id, 0) + 1
		for def in level.objects + level.pickups:
			var id := str(def.get("item", ""))
			if Items.get_armor(id):
				found[id] = found.get(id, 0) + 1
		level.free()
	for boss: String in Game.BOSS_REWARDS:
		for id: String in Game.BOSS_REWARDS[boss]:
			if Items.get_armor(id):
				found[id] = found.get(id, 0) + 1
	var missing := []
	for set_id: String in ArmorSets.SETS:
		for id in ArmorSets.pieces(set_id):
			if found.get(id, 0) != 1:
				missing.append("%s=%d" % [id, found.get(id, 0)])
	check(missing.is_empty(), "as 35 peças, cada uma num lugar só (%s)" % [missing])
	check(found.size() == 35, "nenhuma peça a mais (%d)" % found.size())
	# No chão: as 5 peças em volta do ponto, cada uma com a própria chave.
	var level := await open_level("res://scenes/world/teatro.tscn", "camara")
	var pile := level.entities.get_children().filter(func(n): return n is ItemPickup and Items.get_armor(n.item_id) != null)
	check(pile.size() == 5, "o Traje da Vigília está no Teatro (%d peças)" % pile.size())
	for pickup: ItemPickup in pile:
		pickup.take()
	check(Game.owned_armor().size() == 5, "pegou as 5 peças")
	level.queue_free()
	await frames(2)
	level = await open_level("res://scenes/world/teatro.tscn", "camara")
	pile = level.entities.get_children().filter(func(n): return n is ItemPickup and Items.get_armor(n.item_id) != null)
	check(pile.is_empty(), "pegou, está pego: não volta")
	# Inventário: aba Armadura, vestir e tirar.
	var hud := level.hud
	var menu := hud.inventory_menu
	hud.open_inventory()
	await frames(2)
	var tab := InventoryMenu.TABS.find("Armadura")
	check(menu.entries(tab).size() == 5, "aba Armadura lista as peças")
	menu.set_tab(tab)
	menu._activate("peitoral_vigilia")
	await frames(1)
	check(Game.is_armor_equipped("peitoral_vigilia") and menu._hands_holding("peitoral_vigilia") == ["V"], "✕ veste (selo V)")
	check(menu._detail_skill.text.contains("Agora: +6%"), "a ficha diz quanto rende agora: %s" % menu._detail_skill.text)
	check(menu._equip_rows["armadura"].text == "1/5", "a coluna EQUIPADO mostra 1/5")
	check(is_equal_approx(level.player.stats.health_scale, 1.06), "o herói sente na hora")
	menu._activate("peitoral_vigilia")
	await frames(1)
	check(not Game.is_armor_equipped("peitoral_vigilia"), "✕ de novo tira")
	menu.close()
	await frames(2)
	Game.reset_progress()


# --- Farm da Montanha (v0.26) -------------------------------------------------------------

func _hit_calf(calf: BezerroDourado, damage: float) -> void:
	var info := HitInfo.create(damage, calf.global_position + Vector2(-20, 0), calf.global_position)
	calf.hurtbox.receive_hit(info)


func _kill_calf(calf: BezerroDourado) -> void:
	for i in BezerroDourado.HITS_TO_KILL:
		_hit_calf(calf, 30.0)


func test_farm_calf_seven_hits() -> void:
	Game.reset_progress()
	var level := await open_level(ENCOSTA, "porta")  # v0.35: o farm fica na Encosta
	var farm := level.get_node_or_null("Farm") as FarmSpot
	check(farm != null and is_instance_valid(farm.calf), "a Montanha tem o farm, com o Bezerro pastando")
	var calf := farm.calf
	check(level.farm_field_tiles.has_point(Vector2i(calf.global_position / 16.0)), "ele nasce dentro do campo")
	# Calmo: anda devagar pela rota.
	await frames(30)
	check(not calf.fleeing and calf.velocity.length() <= calf.graze_speed + 1.0, "pastando: passo lento (%.0f)" % calf.velocity.length())
	# Um pouco mais rápido que o herói mais rápido possível (5 Escamas de Caelis, correndo).
	for id in ArmorSets.pieces("caelis"):
		Game.add_item(id, 1, false)
		Game.equip_armor(id)
	var fastest := level.player.move_speed * level.player.sprint_multiplier()
	check(calf.flee_speed > fastest and calf.flee_speed < fastest * 1.15,
		"fugindo: %.0f contra %.0f do herói de Caelis correndo (um pouco mais)" % [calf.flee_speed, fastest])
	# Dano não importa: são 7 golpes, nem mais nem menos.
	for i in 6:
		_hit_calf(calf, 99999.0 if i % 2 == 0 else 1.0)
	await frames(6)
	check(not calf.dead and calf.hits == 6, "6 golpes (até de 99999 de dano): ainda de pé")
	check(calf.fleeing and absf(calf.velocity.length() - calf.flee_speed) < 2.0, "apanhou: dispara pela rota (%.0f)" % calf.velocity.length())
	var before := calf.global_position
	await frames(30)
	var route_ok := false
	for point in calf.route:
		route_ok = route_ok or point.distance_to(calf.global_position) < 200.0
	check(calf.global_position.distance_to(before) > 60.0 and route_ok, "corre de verdade, sem sair da volta")
	check(not calf.can_be_backstabbed(calf.global_position - calf.facing * 20.0), "sem crítico pelas costas")
	_hit_calf(calf, 1.0)
	await frames(2)
	check(calf.dead, "o 7º golpe derruba, mesmo com 1 de dano")
	level.queue_free()
	await frames(2)
	Game.reset_progress()


func test_farm_minotaur_cycle() -> void:
	Game.reset_progress()
	var level := await open_level(ENCOSTA, "porta")
	var farm := level.get_node("Farm") as FarmSpot
	level.player.global_position = farm.field.get_center()  # v0.35: o campo fica do outro lado do rio, na Encosta
	_kill_calf(farm.calf)
	var came := await wait_for(func(): return farm.is_minotaur_active() and farm.minotaur.active, 300)
	check(came, "o bezerro caiu: o Minotauro despenca e a luta começa")
	var mino := farm.minotaur
	check(level.hud._boss_bar.visible and level.hud._boss_bar.boss_name == "O Minotauro", "a barra de chefe aparece")
	var inside := true
	for i in 40:
		inside = inside and farm.field.has_point(mino._clamp_to_field(mino._random_point()))
	check(inside, "os pulos ficam dentro do campo")
	# Deixa ele lutar um pouco (pulos de verdade, sem travar).
	level.player.stats.health = 99999.0
	await seconds(4.0)
	check(is_instance_valid(mino) and not mino.dead and farm.field.grow(32.0).has_point(mino.global_position), "pulou pelo campo e continua nele")
	# Vence: 4000 memórias e 10 Sucata no chão. NÃO fica salvo como vencido.
	var memories := Game.memories
	mino.stats.take_damage(999999.0)
	await frames(4)
	check(Game.memories == memories + Minotauro.REWARD_MEMORIES, "+4000 memórias (%d)" % (Game.memories - memories))
	var sucata := level.entities.get_children().filter(func(n): return n is ItemPickup and n.item_id == "sucata_temperada" and n.count == Minotauro.REWARD_SUCATA)
	check(sucata.size() == 1, "10 Sucata Temperada no chão")
	check(Game.defeated_bosses.is_empty(), "não entra no save como chefe vencido (ele volta)")
	var back := await wait_for(func(): return is_instance_valid(farm.calf) and not farm.calf.dead, 300)
	check(back and farm.calf.hits == 0, "o bezerro volta a pastar, como se nada tivesse acontecido")
	# Desistir no meio (descansar na Câmara): o Minotauro some e o bezerro volta.
	_kill_calf(farm.calf)
	await wait_for(func(): return farm.is_minotaur_active() and farm.minotaur.active, 300)
	var second := farm.minotaur
	level._respawn_enemies()  # o que o descanso faz
	await frames(60)
	check(not is_instance_valid(second) or second.modulate.a < 0.1, "descansou: o Minotauro some")
	check(is_instance_valid(farm.calf) and not farm.calf.dead, "e o bezerro já está lá")
	check(not level.hud._boss_bar.visible or level.hud._boss_bar.modulate.a < 1.0, "a barra sai")
	level.queue_free()
	await frames(2)
	# Morreu? A fase recarrega e começa com o bezerro.
	level = await open_level(ENCOSTA, "porta")
	farm = level.get_node("Farm") as FarmSpot
	check(is_instance_valid(farm.calf) and not farm.is_minotaur_active(), "fase nova: só o bezerro")
	level.queue_free()
	await frames(2)
	Game.reset_progress()


# --- NG+ (v0.27) ---------------------------------------------------------------------------

func test_ng_weapon_on_the_floor() -> void:
	Game.reset_progress()
	# A criação devolve a arma escolhida junto com a aparência.
	var creation := CharacterCreation.new()
	add_child(creation)
	await frames(2)
	var got := []
	creation.confirmed.connect(func(choice: Dictionary): got.append(choice))
	check(creation.weapon == Game.START_WEAPON, "começa na Espada de Cobaia")
	for i in 2:
		creation.step_weapon(1)
	creation._confirm()
	check(got.size() == 1 and got[0]["arma"] == Game.BASIC_WEAPONS[2], "Confirmar leva a arma: %s" % [got])
	creation.step_weapon(-3)
	check(creation.weapon == Game.BASIC_WEAPONS[-1], "dá a volta na lista")
	creation.queue_free()
	# Novo jogo: mãos vazias, a arma está no chão do Prólogo.
	Game.new_game({"arma": "lanca_cobaia"})
	check(Game.equipped_weapon == Game.FISTS and not Game.owns_weapon("espada"), "acorda de punhos (sem a espada de graça)")
	check(Game.chosen_weapon == "lanca_cobaia", "lembra a arma escolhida")
	Game.scene_changes_enabled = false
	var level := await open_level("res://scenes/world/prologo.tscn", "camara")
	check(level.player.weapon.id == Game.FISTS, "o herói luta no soco")
	var pickups := level.entities.get_children().filter(func(n): return n is ItemPickup and n.item_id == "lanca_cobaia")
	check(pickups.size() == 1, "a lança está no chão perto da cápsula")
	if pickups.size() == 1:
		check(pickups[0].global_position.distance_to(level.spawns["camara"]) < 220.0, "perto de onde acorda")
		(pickups[0] as ItemPickup).take()
		await frames(2)
		check(Game.equipped_weapon == "lanca_cobaia" and level.player.weapon.id == "lanca_cobaia", "pegou: já está na mão")
	level.player.stats.stamina = level.player.stats.max_stamina
	check(level.player._start_attack(level.player.light_combo[0], 0), "a lança bate")
	level.queue_free()
	await frames(2)
	# Todas as armas comuns existem e batem (golpes, ícone, desenho na mão).
	for id in Game.BASIC_WEAPONS:
		var weapon := Items.get_weapon(id)
		check(weapon and weapon.icon and weapon.hand_texture and weapon.special_attack, "arma comum completa: %s" % id)
	check(Items.get_weapon("arco_cobaia").ranged and WeaponSkills.create(Items.get_weapon("arco_cobaia")).fires_projectile(null), "o arco atira")
	# Ferreiro: só copia a arma comum que você tem.
	Game.memories = 9999
	Game.add_item("sucata_temperada", 10, false)
	check(Game.forge_block_reason("martelo_cobaia") == "basica", "não inventa arma comum")
	check(Game.forge_block_reason("lanca_cobaia") == "", "copia a lança que você tem")
	check(Game.sell_price(Game.FISTS) == 0, "punho não se vende")
	# Save antigo: a espada continua vindo de graça.
	Game._from_dict({"version": 3, "inventory": {}})
	check(Game.owns_weapon("espada") and Game.equipped_weapon == "espada" and Game.cycle == 0, "save antigo: espada na mão, primeira jornada")
	Game.reset_progress()


func test_ng_difficulty() -> void:
	Game.reset_progress()
	var expected := {0: 1.0, 1: 1.5, 2: 1.75, 3: 2.0, 7: 3.0, 12: 3.0}
	for n: int in expected:
		Game.cycle = n
		check(is_equal_approx(Game.difficulty(), expected[n]), "ciclo %d: ×%.2f (%.2f)" % [n, expected[n], Game.difficulty()])
	check(Game.cycle_label(1) == "NG+" and Game.cycle_label(2) == "NG++" and Game.cycle_label(4) == "NG+4", "nomes dos ciclos")
	Game.cycle = 1
	Game.memories = 0
	Game.earn_memories(100)
	check(Game.memories == 150, "memórias dos inimigos ×1,5 no NG+")
	Game.cycle = 2
	var soldier := spawn_enemy_scene(SOLDIER_SCENE, Vector2(300, 200))
	await frames(2)
	var plain := SOLDIER_SCENE.instantiate() as Enemy
	var base: float = (plain.get_node("Stats") as StatsComponent).base_health
	plain.free()
	check(soldier.stats.max_health > base * 1.7, "vida do soldado ×1,75 no NG++ (%.0f)" % soldier.stats.max_health)
	var player := spawn_player(Vector2(100, 100))
	await frames(2)
	var before := player.stats.health
	var hit := HitInfo.create(10.0, Vector2(90, 100), player.global_position)
	hit.source = soldier
	player.hurtbox.receive_hit(hit)
	check(is_equal_approx(before - player.stats.health, 17.5) and is_equal_approx(hit.damage, 10.0),
		"o golpe dói ×1,75 (e o pacote original não muda)")
	var child := (load("res://scenes/enemies/crianca.tscn") as PackedScene).instantiate() as Enemy
	_world.add_child(child)
	await frames(2)
	check(is_equal_approx(child.stats.health_scale, 1.0), "as crianças do Prólogo não mudam")
	Game.reset_progress()


func test_ng_new_journey() -> void:
	Game.reset_progress()
	Game.scene_changes_enabled = false
	Game.attributes["forca"] = 30
	Game.attributes["vitalidade"] = 25
	Game.memories = 8000
	Game.weapon_level = 4
	Game.add_item("pilar_estilhacada", 1, false)
	Game.add_item("escudo_remendado", 1, false)
	Game.equip_weapon("pilar_estilhacada")
	Game.set_shield_equipped(true)
	for id in ArmorSets.pieces("detentor"):
		Game.add_item(id, 1, false)
		Game.equip_armor(id)
	Game.defeated_bosses.assign(Game.SEVEN + ["cavaleiro"])
	# Proteger: este experimento vira o guardião do próximo ciclo.
	Game.show_ending("proteger")
	check(Game.journey_complete(), "a jornada terminou")
	var g := Game.guardian
	check(g.get("direita") == "pilar_estilhacada" and g.get("esquerda") == Game.SHIELD, "a foto guarda as mãos")
	check((g.get("armadura", {}) as Dictionary).get("peitoral") == "peitoral_detentor", "...e a armadura")
	check(int((g.get("atributos", {}) as Dictionary).get("forca", 0)) == 30, "...e os atributos")
	var level := Game.level()
	# Nova jornada: só o nível passa.
	Game.start_new_journey({"sexo": 1, "arma": "adaga_cobaia"})
	check(Game.cycle == 1 and Game.level() == level and Game.attributes["forca"] == 30, "herda o nível (NG+)")
	check(Game.memories == 0 and Game.weapon_level == 0 and Game.owned_armor().is_empty(), "o resto recomeça")
	check(not Game.owns_weapon("pilar_estilhacada") and not Game.has_shield() and Game.equipped_weapon == Game.FISTS, "corpo novo, mãos vazias")
	check(Game.chosen_weapon == "adaga_cobaia" and Game.appearance["sexo"] == 1, "a aparência e a arma novas")
	check(Game.defeated_bosses.is_empty() and not Game.journey_complete(), "os Pecados estão de volta")
	check(Game.guardian.get("direita") == "pilar_estilhacada", "o anterior espera no Núcleo")
	check(Game.flags.get("finais_vistos", []).has("proteger"), "os finais vistos continuam")
	check(Game.last_scene_request == Game.START_SCENE, "acorda no Prólogo")
	# Save e volta.
	var data := Game._to_dict()
	Game._from_dict(data)
	check(Game.cycle == 1 and Game.guardian.get("direita") == "pilar_estilhacada" and not Game.starter_sword, "o save guarda o ciclo e o guardião")
	check(Game.flags.get("finais_vistos", []).has("proteger"), "marcas de texto e lista sobrevivem ao save")
	check(int(Game.slot_summary(Game.slot).get("ciclo", -1)) in [-1, 0, 1], "o cartão do save sabe o ciclo")
	# Destruir: o próximo chefe volta a ser o Cavaleiro.
	Game.show_ending("destruir")
	check(Game.guardian.is_empty(), "Destruir: sem guardião (o Cavaleiro volta)")
	Game.start_new_journey({})
	check(Game.cycle == 2 and is_equal_approx(Game.difficulty(), 1.75), "NG++")
	Game.reset_progress()


func _guardian_build(right: String, left: String, armor_set: String) -> Dictionary:
	var worn := {}
	if not armor_set.is_empty():
		for slot in ArmorData.SLOTS:
			worn[slot] = ArmorSets.piece_id(slot, armor_set)
	return {"aparencia": {"sexo": 1, "corpo": 1}, "direita": right, "esquerda": left, "duas_maos": false,
		"armadura": worn, "atributos": {"forca": 25, "destreza": 20}, "frascos": 3, "ciclo": 0}


func test_ng_guardian_fight() -> void:
	Game.reset_progress()
	Game.cycle = 1
	Game.guardian = _guardian_build("lamina_desolada", Game.SHIELD, "vigilia")
	Game.defeated_bosses.assign(Game.SEVEN)
	Game.flags["experimento_perguntou"] = true  # v0.41: a pergunta do nome é testada à parte
	var level := await open_level(CORACAO, "porta")
	var boss := level.boss_arena.boss as ExperimentoAnterior
	check(boss != null, "NG+ depois de Proteger: no lugar do Cavaleiro, o experimento anterior")
	if boss == null:
		level.queue_free()
		await frames(2)
		Game.reset_progress()
		return
	check(boss.right.id == "lamina_desolada" and boss.has_shield, "as mesmas mãos (Lâmina + escudo)")
	check(is_equal_approx(boss.stats.max_health, 1700.0 * 1.3 * 1.5), "vida: base × Vigília (+30%%) × NG+ (%.0f)" % boss.stats.max_health)
	var tuned := 1.0 + ExperimentoAnterior.WEAPON_DAMAGE_PER_LEVEL * Game.WEAPON_UPGRADES.size()
	var light: AttackData = boss.right.light_combo[0] if not boss.right.light_combo.is_empty() else ExperimentoAnterior.BASE_COMBO[0]
	var expected := light.damage * boss.right.damage_scale * boss.right.scaling_multiplier(boss.attributes) * ExperimentoAnterior.DAMAGE_RATIO * tuned
	check(is_equal_approx(boss.attack_damage(light), expected), "a arma dele está no reforço máximo")
	var said := []
	boss.speech.connect(func(text: String): said.append(text))
	level.player.global_position = boss.global_position + Vector2(0, 90)
	level.player._iframes_left = 999.0
	await seconds(0.8)
	check(boss.active and said.has(ExperimentoAnterior.SPEECH_INTRO), "ele se levanta e fala")
	check(level.hud._boss_bar.boss_name == "O Experimento Anterior", "a barra mostra quem ele é")
	# Desvia: você começa um golpe perto dele.
	boss.dodge_chance = 1.0
	boss._go_decide(0.0)
	boss._roll_cd = 0.0
	level.player.global_position = boss.global_position + Vector2(0, 30)
	level.player.stats.stamina = level.player.stats.max_stamina
	level.player._start_attack(level.player.light_combo[0], 0)
	await frames(2)
	check(boss.mode == ExperimentoAnterior.Mode.ROLL and boss.hurtbox.invulnerable, "viu o golpe: rola (invencível)")
	await seconds(0.6)
	# Cura: pouca vida e longe de você.
	boss._go_decide(0.0)
	boss._heal_cd = 0.0
	boss.stats.set_health(boss.stats.max_health * 0.6)
	level.player.global_position = boss.global_position + Vector2(0, 120)
	var flasks := boss.flasks
	await seconds(1.4)
	check(boss.flasks == flasks - 1 and boss.stats.health_ratio() > 0.8, "bebeu um frasco (%.2f)" % boss.stats.health_ratio())
	# Metade da vida: o Núcleo o escolhe (não dá para pular a fase 2).
	boss.stats.take_damage(999999.0)
	await frames(2)
	check(boss.phase == 2 and is_equal_approx(boss.stats.health_ratio(), 0.5), "metade da vida: fase 2")
	check(boss.flasks == flasks, "o Núcleo devolve um frasco")
	await seconds(2.4)
	check(boss.phase_label() == "O Núcleo o escolhe" and boss.mode != ExperimentoAnterior.Mode.TRANSITION, "fase 2 começa")
	boss._go_decide(99.0)
	boss._rain_light()
	check(get_tree().get_nodes_in_group("flesh_bursts").size() >= boss.stone_count, "pedras de luz caem")
	await seconds(1.6)
	boss.stats.take_damage(999999.0)
	await seconds(1.0)
	check(Game.is_boss_defeated("cavaleiro"), "vencido: a escolha diante dela se abre")
	check(level._dialogue_variant("mulher_do_nucleo") == "a_escolha", "proteger ou destruir, de novo")
	level.queue_free()
	await frames(2)
	# Cada tipo de mão funciona (arco atira; punhos e duas mãos).
	for build in [_guardian_build("arco_cobaia", "", ""), _guardian_build(Game.FISTS, "", "caelis"),
			_guardian_build("presas_voragem", "presas_voragem", "eco")]:
		Game.guardian = build
		Game.defeated_bosses.assign(Game.SEVEN)
		level = await open_level(CORACAO, "porta")
		var other := level.boss_arena.boss as ExperimentoAnterior
		level.player.global_position = other.global_position + Vector2(0, 100)
		level.player._iframes_left = 999.0
		await seconds(3.0)
		check(other.active and not other.dead, "luta com %s" % build["direita"])
		level.queue_free()
		await frames(2)
	# Sem guardião (final Destruir): o Cavaleiro de sempre.
	Game.guardian = {}
	Game.defeated_bosses.assign(Game.SEVEN)
	level = await open_level(CORACAO, "porta")
	check(level.boss_arena.boss is CavaleiroDesolado, "sem guardião: o Cavaleiro")
	level.queue_free()
	await frames(2)
	Game.reset_progress()


func test_ng_ending_choices() -> void:
	Game.reset_progress()
	Game.scene_changes_enabled = false
	Game.attributes["forca"] = 22
	Game.flags["final"] = "proteger"
	var ending := ENDING_SCENE.instantiate()
	add_child(ending)
	await frames(2)
	for i in 900:
		ending._skip = true
		await frames(1)
		if ending._done:
			break
	check(ending._done and ending.choices.visible, "depois dos créditos: as duas escolhas")
	check(ending.new_journey_button.text.contains("nova jornada") and ending.explore_button.text.contains("Explorar"), "Iniciar nova jornada / Explorar o mundo atual")
	ending.open_new_journey()
	await frames(2)
	check(is_instance_valid(ending.creation) and ending.creation.journey_cycle == 1, "vai direto para a criação do novo experimento")
	ending.creation._cancel()
	await frames(2)
	check(ending.choices.visible, "Voltar: as escolhas de novo")
	ending.open_new_journey()
	await frames(2)
	ending.creation._confirm()
	await frames(2)
	check(Game.cycle == 1 and Game.attributes["forca"] == 22 and Game.last_scene_request == Game.START_SCENE, "confirmou: NG+ no Prólogo")
	ending.queue_free()
	await frames(2)
	# Explorar: volta para a última Câmara, e de lá dá para começar depois.
	Game.reset_progress()
	Game.flags["final"] = "destruir"
	Game.rest_scene = "res://scenes/world/teatro.tscn"
	Game.explore_after_ending()
	check(Game.last_scene_request == Game.rest_scene, "Explorar: volta para a Câmara")
	var level := await open_level("res://scenes/world/teatro.tscn", "camara")
	level.hud.rest_menu.run(level.scene_file_path)
	await frames(2)
	check(level.hud.rest_menu.journey_button.visible, "na Câmara: Iniciar nova jornada")
	level.hud.rest_menu.journey_button.pressed.emit()
	await frames(2)
	level.queue_free()
	await frames(2)
	Game.reset_progress()


# --- Câmara animada (v0.28) -----------------------------------------------------------------

func test_capsule_enter_and_exit() -> void:
	Game.reset_progress()
	Game.prologue_done = true
	Game.appearance = {"sexo": 1, "corpo": 2, "rosto": 1, "cabelo": 3}
	var level := await open_level("res://scenes/world/teatro.tscn", "camara")
	var chamber := level.rest_chamber
	check(not chamber.is_occupied() and chamber.lid.position == Vector2.ZERO, "parada: vazia e fechada")
	level.player.global_position = chamber.front_point() + Vector2(30, 10)
	level._on_rest_requested(chamber)
	var opened := await wait_for(func(): return chamber.lid.position.y < -4.0, 120)
	check(opened, "a tampa sobe")
	check(level.player.global_position.distance_to(chamber.front_point()) < 2.0, "foi até a frente da cápsula")
	var lying := await wait_for(func(): return chamber.is_occupied() and absf(chamber.sleeper.rotation + PI * 0.5) < 0.05, 120)
	check(lying and not level.player.visual.visible, "deitou lá dentro (o sprite de verdade some)")
	check(chamber.sleeper.sprite_frames == Appearance.sprite_frames(Game.appearance), "quem deita é o SEU personagem")
	await wait_for(func(): return level.hud.rest_menu.visible, 300)
	check(chamber.lid.position == Vector2.ZERO and chamber.lid.modulate != Color.WHITE, "tampa fechada e vidro embaçado durante o descanso")
	# Levantar: sai da cápsula.
	level.hud.rest_menu._leave_button.pressed.emit()
	await frames(4)
	check(level.player.state == Player.State.LOCKED, "saindo: ainda travado")
	var out := await wait_for(func(): return level.player.state == Player.State.FREE, 300)
	check(out and level.player.visual.visible and not chamber.is_occupied(), "pulou para fora e o controle volta")
	check(level.player.global_position.distance_to(chamber.front_point()) < 2.0, "de pé na frente da cápsula")
	check(chamber.lid.position == Vector2.ZERO and chamber.lid.modulate == Color.WHITE, "a tampa fecha vazia")
	level.queue_free()
	await frames(2)
	# Morrer também acorda na cápsula.
	Game.respawn()
	check(Game.wake_from_capsule, "renascer: sai da cápsula")
	Game.wake_from_capsule = false
	Game.reset_progress()


# --- Abertura em vídeo (v0.29) ----------------------------------------------------------

func test_opening_video() -> void:
	check(ResourceLoader.exists(TitleScreen.OPENING_VIDEO), "o vídeo da abertura está no jogo")
	var stream := load(TitleScreen.OPENING_VIDEO) as VideoStream
	check(stream != null, "e o Godot consegue abrir (Ogg Theora)")
	var cutscene := CutscenePlayer.create(TitleScreen.OPENING_VIDEO)
	add_child(cutscene)
	var ended := []
	cutscene.finished.connect(func(): ended.append(true))
	await seconds(1.0)
	check(cutscene.video.is_playing() and ended.is_empty(), "toca (e não acaba sozinho num segundo)")
	var tap := InputEventScreenTouch.new()
	tap.pressed = true
	cutscene._input(tap)
	await frames(2)
	check(ended.size() == 1 and not cutscene.video.is_playing(), "um toque pula")
	cutscene._input(tap)
	check(ended.size() == 1, "pular duas vezes não avisa duas vezes")
	cutscene.queue_free()
	# Arquivo que não existe: não trava o jogo, só segue em frente.
	var missing := CutscenePlayer.create("res://assets/cutscenes/nao_existe.ogv")
	add_child(missing)
	var skipped := []
	missing.finished.connect(func(): skipped.append(true))
	await frames(3)
	check(skipped.size() == 1, "vídeo faltando: pula direto")
	missing.queue_free()
	await frames(2)


# --- Botões de qualquer controle (v0.30) -----------------------------------------------------

func test_pad_style() -> void:
	var saved := Settings.pad_style
	# O nome do controle diz a família (nomes reais que o SDL/Android entregam).
	var names := {
		"PS5 Controller": "playstation", "DualSense Wireless Controller": "playstation",
		"Wireless Controller": "playstation", "Sony Interactive Entertainment Controller": "playstation",
		"Xbox Series X Controller": "xbox", "XInput Controller": "xbox", "Microsoft X-Box 360 pad": "xbox",
		"Nintendo Switch Pro Controller": "nintendo", "Joy-Con (L/R)": "nintendo",
		"Generic USB Joystick": "generico", "8BitDo SN30": "generico", "": "generico",
	}
	for joy_name: String in names:
		check(PadStyle.from_name(joy_name) == names[joy_name], "'%s' → %s (%s)" % [joy_name, names[joy_name], PadStyle.from_name(joy_name)])
	# Botão de BAIXO em cada família (a mesma posição, nomes diferentes).
	var bottom := {"playstation": "✕", "xbox": "A", "nintendo": "B", "generico": "↓"}
	var right := {"playstation": "○", "xbox": "B", "nintendo": "A", "generico": "→"}
	var l1 := {"playstation": "L1", "xbox": "LB", "nintendo": "L", "generico": "L1"}
	for family: String in bottom:
		Settings.pad_style = family
		check(PadStyle.family() == family, "forçado: %s" % family)
		check(PadStyle.face("cross") == bottom[family] and PadStyle.face("circle") == right[family], "%s: baixo %s, direita %s" % [family, PadStyle.face("cross"), PadStyle.face("circle")])
		check(PadStyle.shoulder("L1") == l1[family], "%s: ombro %s" % [family, PadStyle.shoulder("L1")])
		var line := PadStyle.text("{R1} ataca. {circle_long} esquiva. L1/R1 trocam a aba.")
		check(not line.contains("{") and line.contains(PadStyle.shoulder("R1")), "%s: %s" % [family, line])
	Settings.pad_style = "xbox"
	check(PadStyle.text("{cross} pular") == "A pular", "texto da cutscene no Xbox")
	Settings.pad_style = "playstation"
	check(PadStyle.text("{circle_long}") == "○ (Bola)", "no PlayStation as frases dizem o nome do símbolo")
	# Automático: segue o controle detectado.
	Settings.pad_style = "auto"
	PadStyle.detected = "nintendo"
	check(PadStyle.family() == "nintendo" and PadStyle.face("cross") == "B", "automático: usa o controle detectado")
	# Os desenhos das 4 famílias rodam sem erro (num Control de verdade).
	var canvas := Control.new()
	canvas.size = Vector2(80, 20)
	add_child(canvas)
	var drawn := []
	canvas.draw.connect(func():
		for family in PadStyle.FAMILIES:
			Settings.pad_style = family
			for kind in ["cross", "circle", "square", "triangle"]:
				PadStyle.glyph(canvas, Vector2(10, 10), kind, 5.0)
			drawn.append(family))
	canvas.queue_redraw()
	await frames(2)
	check(drawn.size() == 4, "desenha PlayStation, Xbox, Nintendo e genérico")
	canvas.queue_free()
	# Opções: o ciclo passa por todas e volta ao automático.
	Settings.pad_style = "auto"
	var seen := []
	for i in Settings.PAD_STYLES.size():
		Settings.cycle_pad_style()
		seen.append(Settings.pad_style)
	check(seen.back() == "auto" and seen.size() == 5, "Opções: Automático → PlayStation → Xbox → Nintendo → Genérico → Automático")
	Settings.pad_style = saved
	PadStyle.detected = "generico"


# --- v0.35 · Etapa 6: a Cidade expandida ----------------------------------------------

func _minis_named(kind: String) -> Array:
	return get_tree().get_nodes_in_group("minibosses").filter(func(n): return n.get_script().get_global_name() == kind)


func test_city_expansion() -> void:
	Game.reset_progress()
	Game.prologue_done = true
	# Avenida → Quartel (livre) e → Torre.
	var level := await open_level(CIDADE, "porta")
	var targets := {}
	for node in level.entities.get_children():
		if node is AreaExit:
			targets[(node as AreaExit).target_scene] = (node as AreaExit).target_spawn
	check(targets.get(QUARTEL, "") == "porta", "Avenida: o quartel está aberto (%s)" % [targets])
	check(targets.get(TORRE, "") == "porta", "Avenida: a porta da Torre")
	check(find_npc("portao_aldir") == null, "o portão do Aldir saiu da Avenida")
	level.queue_free()
	await frames(2)
	# Quartel: Sargento, fio de alarme, portão para o Viaduto fechado até ele cair.
	level = await open_level(QUARTEL, "porta")
	check(_minis_named("SargentoSemPelotao").size() == 1, "Quartel: o Sargento mora aqui")
	check(find_npc("quartel_portao_fechado") != null, "Quartel: o portão para o Viaduto está fechado")
	check(find_npc("portao_viaduto_trancado") != null, "Quartel: o atalho do Viaduto abre do outro lado")
	check(find_npc("escala_de_guarda") != null, "Quartel: a escala de guarda")
	var wires := get_tree().get_nodes_in_group("zone_triggers")
	check(wires.size() == 1, "Quartel: um fio de alarme (%d)" % wires.size())
	var called := (wires[0] as ZoneTrigger).fire()
	check(called == 2, "o fio chama os dois soldados do alojamento (%d)" % called)
	level.queue_free()
	await frames(2)
	Game.defeated_bosses.append("sargento")
	level = await open_level(QUARTEL, "porta")
	var to_bridge := false
	for node in level.entities.get_children():
		if node is AreaExit and (node as AreaExit).target_scene == VIADUTO:
			to_bridge = true
	check(to_bridge and find_npc("quartel_portao_fechado") == null, "vencido o Sargento: o portão abre")
	level.queue_free()
	await frames(2)
	# Viaduto: a Couraça na ponte, o portão do Aldir guardado.
	level = await open_level(VIADUTO, "porta")
	var armors := _minis_named("CouracaAndante")
	check(armors.size() == 1, "Viaduto: a Couraça na ponte")
	check(level.resolve_dialogue("portao_aldir") == "portao_aldir_guardado", "o portão fica do outro lado da Couraça")
	var collapse: Array = level.get_children().filter(func(n): return n is CollapsingFloor)
	check(collapse.size() == 1, "Viaduto: a ponte pode desabar")
	var floor_node := collapse[0] as CollapsingFloor
	var armor := armors[0] as MiniBoss
	armor.fight_started.emit(armor)
	check(floor_node.active, "a luta começa: a ponte racha")
	await seconds(4.5)
	var pits := get_tree().get_nodes_in_group("pits").filter(func(p): return (p as ArenaPit).is_active())
	check(pits.size() >= 1, "abriram buracos na ponte (%d)" % pits.size())
	check(pits.all(func(p): return floor_node.rect.has_point((p as Node2D).global_position)), "só na ponte")
	armor.fight_won.emit(armor)
	check(not floor_node.active and get_tree().get_nodes_in_group("pits").all(func(p): return not (p as ArenaPit).is_active()),
		"fim da luta: o entulho tapa os buracos")
	Game.defeated_bosses.append("couraca")
	check(level.resolve_dialogue("portao_aldir") == "portao_aldir", "sem a Couraça, o portão chama")
	var shortcut := false
	for node in level.entities.get_children():
		if node is AreaExit and (node as AreaExit).target_scene == QUARTEL and (node as AreaExit).opens_flag == "atalho_viaduto":
			shortcut = true
	check(shortcut and level.spawns.has("escalada"), "Viaduto: o atalho para o Quartel e a escalada da Montanha")
	level.queue_free()
	await frames(2)
	Game.reset_progress()


func test_corneteiro_silences_city() -> void:
	Game.reset_progress()
	Game.prologue_done = true
	var level := await open_level(TORRE, "porta")
	var horns := _minis_named("Corneteiro")
	check(horns.size() == 1, "Torre: o Corneteiro lá em cima")
	var horn := horns[0] as Corneteiro
	check(horn.reinforcements_per_whistle == 3, "a corneta chama três")
	horn.target = level.player
	horn.start_fight()
	horn._start_whistle()
	await seconds(1.2)
	var rings := 0
	for node in level.get_children() + level.entities.get_children():
		if node is ScreamRing:
			rings += 1
	check(rings >= 1 and horn.summoned.size() == 3, "o toque é um anel e chama três (%d anéis, %d)" % [rings, horn.summoned.size()])
	horn.stats.take_damage(99999.0)
	await frames(3)
	check(Game.is_boss_defeated("corneteiro") and Game.has_flag("corneteiro_morto"), "vencido: a Cidade fica sem toque")
	level.queue_free()
	await frames(2)
	# Daí em diante, soldado da Cidade morto não volta mais.
	level = await open_level(CIDADE, "porta")
	var soldier: SoldadoRemendado = null
	for node in get_tree().get_nodes_in_group("respawnable"):
		if node is SoldadoRemendado:
			soldier = node
			break
	var index: int = (soldier.defeated.get_connections()[0]["callable"] as Callable).get_bound_arguments()[0]
	check(index >= 0, "o índice do inimigo no mapa")
	level._on_enemy_slain(soldier, index)
	var dog: CaoDeGuerra = null
	for node in get_tree().get_nodes_in_group("respawnable"):
		if node is CaoDeGuerra:
			dog = node
			break
	var dog_index: int = (dog.defeated.get_connections()[0]["callable"] as Callable).get_bound_arguments()[0]
	check(dog_index >= 0, "o índice do inimigo no mapa")
	level._on_enemy_slain(dog, dog_index)
	Game.slain = {}  # descansou
	var data := Game._to_dict()
	Game._from_dict(data)
	check(Game.is_slain(CIDADE, index), "o soldado não volta no descanso (nem depois de carregar)")
	check(not Game.is_slain(CIDADE, dog_index), "o cão volta (só os soldados obedeciam à corneta)")
	level.queue_free()
	await frames(2)
	Game.reset_progress()


func test_arena_shift_fire_ring() -> void:
	Game.reset_progress()
	var player := spawn_player(Vector2(100, 100))
	player.set_physics_process(false)
	await frames(2)
	var shift := ArenaShift.apply(_world, Rect2(0, 0, 320, 240), {"fogo_borda": 2, "cresce": 0.5, "max": 3, "dps": 20.0})
	check(shift.burns(Vector2(10, 10)) and not shift.burns(Vector2(160, 120)), "a borda queima, o meio não")
	player.global_position = Vector2(8, 120)
	var hp := player.stats.health
	await seconds(1.2)
	check(player.stats.health < hp, "quem fica no fogo queima (%.0f → %.0f)" % [hp, player.stats.health])
	check(shift.border_tiles == 3.0, "o anel cresce até o máximo (%.0f)" % shift.border_tiles)
	var aldir := spawn_aldir(Vector2(160, 120))
	await frames(2)
	check(aldir.phase_arena.has(2), "o Aldir tem a praça em chamas na fase 2")
	aldir.arena_rect = Rect2(0, 0, 320, 240)
	var made := aldir.shift_arena(2)
	check(made != null and made.border_tiles == 2.0, "a fase 2 acende o anel de fogo")
	shift.queue_free()
	made.queue_free()
	aldir.queue_free()
	player.queue_free()
	await frames(2)


# --- v0.35 · Etapa 6: o Bosque expandido ----------------------------------------------

func _exit_to(scene: String) -> AreaExit:
	for node in _world.find_children("*", "AreaExit", true, false):
		if (node as AreaExit).target_scene == scene:
			return node
	return null


func test_bosque_expansion() -> void:
	Game.reset_progress()
	Game.prologue_done = true
	# Margem → Dormitório (livre) e a sala escondida do Sino.
	var level := await open_level(BOSQUE, "porta")
	check(_exit_to(DORMITORIO) != null, "Margem: a descida para o Dormitório está aberta")
	check(_exit_to(SALA_SINO) != null and level.spawns.has("sino"), "Margem: a sala do Sino")
	check(find_npc("galho_trancado") == null, "o galho congelado saiu da Margem")
	level.queue_free()
	await frames(2)
	# Dormitório: Vigia, flores que respiram, porta da Borda fechada até passar por ele.
	level = await open_level(DORMITORIO, "porta")
	check(_minis_named("VigiaQueDormiu").size() == 1, "Dormitório: o Vigia")
	check(get_tree().get_nodes_in_group("breathing_flowers").size() == 6, "Dormitório: 6 flores que respiram")
	check(find_npc("cama_quente") != null, "Dormitório: a cama ainda quente")
	check(find_npc("dormitorio_porta_fechada") != null and _exit_to(BORDA) == null, "a Borda fecha até passar pelo Vigia")
	check(find_npc("raiz_trancada") != null, "a raiz da Borda abre do outro lado")
	Game.set_flag("vigia_evitado")
	await frames(2)
	check(_exit_to(BORDA) != null, "passou escondido pelo Vigia: a porta abre na hora")
	level.queue_free()
	await frames(2)
	Game.clear_flag("vigia_evitado")
	Game.defeated_bosses.append("vigia")
	level = await open_level(DORMITORIO, "porta")
	check(_exit_to(BORDA) != null, "vencido o Vigia: também abre")
	level.queue_free()
	await frames(2)
	# Borda: a Mãe, o galho trancado, a raiz que abre o atalho.
	level = await open_level(BORDA, "porta")
	check(_minis_named("MaeDosEsporos").size() == 1, "Borda: a Mãe dos Esporos")
	check(find_npc("galho_trancado") != null, "Borda: o lado trancado do galho congelado")
	var root := _exit_to(DORMITORIO)
	var root_shortcut: AreaExit = null
	for node in _world.find_children("*", "AreaExit", true, false):
		if (node as AreaExit).opens_flag == "atalho_raiz":
			root_shortcut = node
	check(root_shortcut != null and root != null, "Borda: a raiz desce até o Dormitório")
	Game.scene_changes_enabled = false
	root_shortcut._armed = true
	root_shortcut._on_body_entered(level.player)
	check(Game.has_flag("atalho_raiz"), "desceu pela raiz: atalho aberto")
	level.queue_free()
	await frames(2)
	level = await open_level(DORMITORIO, "raiz")
	check(find_npc("raiz_trancada") == null and level.spawns.has("raiz"), "o Dormitório chega na Borda pela raiz")
	level.queue_free()
	await frames(2)
	# Domínio e Clareira apontam para a Borda.
	check((load("res://scenes/world/arena_nyssa.tscn") as PackedScene).instantiate().get("exit_scene") == BORDA, "a Clareira volta para a Borda")
	Game.reset_progress()


func test_breathing_flowers() -> void:
	Game.reset_progress()
	var player := spawn_player(Vector2(200, 200))
	player.set_physics_process(false)
	var flowers := BreathingFlower.spawn_all(_world, {"cells": [Vector2i(12, 12)]})
	var flower := flowers[0]
	await frames(2)
	player.global_position = flower.global_position + Vector2(20, 0)
	player.sprinting = false
	check(not flower.disturbed_by(player), "andando devagar perto: nada")
	player.sprinting = true
	check(flower.disturbed_by(player), "correndo perto: a flor sente o ar mexer")
	await frames(2)
	var clouds := get_tree().get_nodes_in_group("pollen_clouds").size()
	check(clouds >= 1, "ela solta pólen (%d nuvens)" % clouds)
	await frames(10)
	check(get_tree().get_nodes_in_group("pollen_clouds").size() == clouds, "e respira de novo só depois de um tempo")
	player.sprinting = false
	player.global_position = flower.global_position + Vector2(200, 0)
	player.sprinting = true
	check(not flower.disturbed_by(player), "longe dela, correr não importa")
	for cloud in get_tree().get_nodes_in_group("pollen_clouds"):
		cloud.queue_free()
	flower.queue_free()
	player.queue_free()
	await frames(2)


func test_sino_despertar() -> void:
	Game.reset_progress()
	Game.prologue_done = true
	check(is_equal_approx(SinoDespertar.bosque_aggro_scale(), SinoDespertar.AGGRO_RINGING), "o Sino toca: o Bosque enxerga mais longe")
	var level := await open_level(SALA_SINO, "porta")
	var bells := _minis_named("SinoDespertar")
	check(bells.size() == 1 and find_npc("placa_sino") != null, "a sala do Sino, com a placa")
	var bell := bells[0] as SinoDespertar
	var sleepers_before := get_tree().get_nodes_in_group("respawnable").filter(func(n): return n is Enemy and not n.dead)
	bell.target = level.player
	bell.start_fight()
	bell._ring()
	await frames(3)
	check(bell.sleepers.size() == 1, "o toque chama um Sonâmbulo")
	check(sleepers_before.all(func(e): return (e as Enemy).is_alerted()), "e acorda os da sala")
	var rings := level.entities.get_children().filter(func(n): return n is ScreamRing).size()
	check(rings >= 1, "o toque é um anel de som")
	bell.stats.take_damage(bell.stats.max_health * 0.55)
	bell._fight(0.016)
	check(bell.phase == 2, "metade da vida: toca mais rápido")
	bell.stats.take_damage(99999.0)
	await frames(3)
	check(Game.is_boss_defeated("sino") and Game.has_flag("sino_silenciado"), "silenciado")
	check(is_equal_approx(SinoDespertar.bosque_aggro_scale(), SinoDespertar.AGGRO_SILENCED), "o Bosque passa a enxergar menos")
	level.queue_free()
	await frames(2)
	level = await open_level(BOSQUE, "porta")
	var sleeper := SLEEPER_SCENE_FOR_TEST.instantiate() as Enemy
	var base := sleeper.aggro_range
	sleeper.free()
	var shore_enemy: Enemy = get_tree().get_nodes_in_group("respawnable").filter(func(n): return n is Sonambulo)[0]
	check(is_equal_approx(shore_enemy.aggro_range, base * SinoDespertar.AGGRO_SILENCED), "um Sonâmbulo da Margem enxerga menos (%.0f)" % shore_enemy.aggro_range)
	level.queue_free()
	await frames(2)
	Game.reset_progress()


func test_nyssa_nightmare_arena() -> void:
	Game.reset_progress()
	var level := await open_level(ARENA_NYSSA, "porta")
	var nyssa := level.boss_arena.boss as NyssaLumevel
	check(nyssa.phase_arena.has(2), "Nyssa tem a clareira no escuro")
	var shift := nyssa.shift_arena(2)
	check(shift != null, "a fase 2 muda a arena")
	await frames(2)
	check(is_equal_approx(level.player.drowsiness_scale, 1.5), "o sono enche 1,5× mais rápido")
	var lights := get_tree().get_nodes_in_group("flower_lights").size()
	check(lights >= 2, "as flores acendem no escuro (%d)" % lights)
	nyssa.fight_won.emit(nyssa)
	await frames(2)
	check(is_equal_approx(level.player.drowsiness_scale, 1.0), "vencida: o sono volta ao normal")
	level.queue_free()
	await frames(2)
	Game.reset_progress()


# --- v0.35 · Etapa 6: as Forjas expandidas --------------------------------------------

func test_forjas_expansion() -> void:
	Game.reset_progress()
	Game.prologue_done = true
	var level := await open_level(FORJAS, "porta")
	check(_exit_to(FORNALHA) != null, "Salão: a descida para a Fornalha está aberta")
	check(_exit_to(SALA_DANCARINA) != null and level.spawns.has("dancarina"), "Salão: o salão de cima, da Dançarina")
	check(find_npc("estatua_sem_rosto") != null, "a estátua sem rosto, na frente da 1ª Câmara")
	level.queue_free()
	await frames(2)
	level = await open_level(FORNALHA, "porta")
	check(_minis_named("Prototipo").size() == 1, "Fornalha: o Protótipo")
	var hammers := get_tree().get_nodes_in_group("traps").filter(func(t): return t is PeriodicTrap and t.kind == "pilao")
	check(hammers.size() == 3, "Fornalha: três fileiras de marteletes (%d)" % hammers.size())
	check(find_npc("martelo_de_crianca") != null, "o martelo pequeno, de criança")
	check(find_npc("fornalha_porta_fechada") != null and _exit_to(PASSARELA) == null, "a Passarela fecha até o Protótipo cair")
	check(find_npc("elevador_parado") != null, "o elevador está parado lá em cima")
	level.queue_free()
	await frames(2)
	Game.defeated_bosses.append("prototipo")
	level = await open_level(FORNALHA, "porta")
	check(_exit_to(PASSARELA) != null, "vencido o Protótipo: a Passarela abre")
	level.queue_free()
	await frames(2)
	level = await open_level(PASSARELA, "porta")
	check(_minis_named("GuardiaoAncora").size() == 1 and find_npc("placa_ancora") != null, "Passarela: o Guardião e a placa ÂNCORA 5")
	check(_exit_to("res://scenes/world/dominio.tscn") != null and _exit_to("res://scenes/world/raizes.tscn") != null,
		"Passarela: a subida para o Domínio e a descida para as Raízes")
	var lift: AreaExit = null
	for node in _world.find_children("*", "AreaExit", true, false):
		if (node as AreaExit).opens_flag == "atalho_elevador":
			lift = node
	check(lift != null, "Passarela: o elevador desce até a Fornalha")
	Game.scene_changes_enabled = false
	lift._armed = true
	lift._on_body_entered(level.player)
	check(Game.has_flag("atalho_elevador"), "desceu de elevador: atalho aberto")
	level.queue_free()
	await frames(2)
	level = await open_level(FORNALHA, "elevador")
	check(find_npc("elevador_parado") == null and level.spawns.has("elevador"), "a Fornalha sobe de elevador até a Passarela")
	level.queue_free()
	await frames(2)
	Game.reset_progress()


func test_dancarina() -> void:
	Game.reset_progress()
	Game.prologue_done = true
	var level := await open_level(SALA_DANCARINA, "porta")
	var dancers := _minis_named("DancarinaEngrenagem")
	check(dancers.size() == 1 and find_npc("palco_da_dancarina") != null, "o salão da Dançarina, com o palco")
	var dancer := dancers[0] as DancarinaEngrenagem
	dancer.target = level.player
	dancer.start_fight()
	dancer._on_wake()
	check(dancer.mode == DancarinaEngrenagem.Mode.SPIN, "acorda girando")
	var gaps: Array[float] = []
	var guard := 0
	while dancer.mode == DancarinaEngrenagem.Mode.SPIN and guard < 50:
		gaps.append(dancer._note_gap)
		dancer.play_note()
		guard += 1
	check(gaps.size() >= 7 and gaps[-1] < gaps[0], "a música acelera (%.2f → %.2f s)" % [gaps[0], gaps[-1]])
	check(dancer.mode == DancarinaEngrenagem.Mode.SILENCE and dancer.darts_left == 1, "a música para: silêncio, um disparo")
	dancer.start_dart()
	check(dancer.mode == DancarinaEngrenagem.Mode.DART and dancer.hitbox.active, "dispara (e machuca)")
	# Fase 2: dois ou três disparos.
	dancer.stats.take_damage(dancer.stats.max_health * 0.55)
	dancer._start_song()
	dancer._fight(0.016)
	check(dancer.phase == 2, "metade da vida: fase 2")
	dancer.notes_played = dancer.notes_this_song - 1
	dancer.play_note()
	check(dancer.darts_left >= 2, "fase 2: %d disparos seguidos" % dancer.darts_left)
	dancer.stats.take_damage(99999.0)
	await frames(3)
	check(Game.is_boss_defeated("dancarina") and Game.has_item("caixa_musica_bronze"), "vencida: a Caixa de Música de Bronze")
	level.queue_free()
	await frames(2)
	# A caixa para o Ferreiro: a fala muda se Durgan já caiu.
	check(DialogueData.variant("ferreiro_caixa") == "ferreiro_caixa", "Durgan vivo: '...Ele fazia isso?'")
	Game.defeated_bosses.append("durgan")
	check(DialogueData.variant("ferreiro_caixa") == "ferreiro_caixa_durgan", "Durgan morto: 'Ele fez para mim.'")
	var options := DialogueBox.expand_options(DialogueData.get_entry("ferreiro_irmao").get("opcoes", []))
	check(options.any(func(o): return str(o.get("acao", "")).begins_with("dar:caixa_musica_bronze")), "o Ferreiro aceita a caixa")
	level = await open_level(TEATRO, "camara")
	await level._on_dialogue_action("dar:caixa_musica_bronze")
	check(not Game.has_item("caixa_musica_bronze") and Game.has_flag("dado_caixa_musica_bronze"), "entregue: sai da bolsa")
	level.queue_free()
	await frames(2)
	Game.reset_progress()


func test_durgan_replays_combo() -> void:
	Game.reset_progress()
	var durgan := (load("res://scenes/bosses/durgan.tscn") as PackedScene).instantiate() as DurganVell
	_world.add_child(durgan)
	await frames(2)
	for action in [&"leve", &"leve", &"forte", &"dash"]:
		durgan._on_player_action(action)
	check(durgan.last_player_combo == [&"leve", &"leve", &"forte", &"dash"], "guarda o combo inteiro (%s)" % [durgan.last_player_combo])
	var attacks := durgan.combo_as_attacks(durgan.last_player_combo)
	check(attacks == [durgan.copy_light[0], durgan.copy_light[1], durgan.copy_heavy, durgan.dash_strike], "e traduz golpe por golpe")
	durgan._clock += 2.0
	durgan._on_player_action(&"forte")
	check(durgan.last_player_combo.size() == 4, "um golpe solto depois de uma pausa não apaga o último combo")
	check(durgan.phase_arena.has(2), "a forja escurece na fase 2")
	durgan.queue_free()
	await frames(2)


# --- v0.35 · Etapa 6: as Raízes expandidas --------------------------------------------

func test_raizes_expansion() -> void:
	Game.reset_progress()
	Game.prologue_done = true
	var level := await open_level(RAIZES, "porta")
	check(_exit_to(DESPENSA) != null, "Estufa: a descida para a Despensa está aberta")
	check(_exit_to(ENFERMARIA) != null and level.spawns.has("enfermaria"), "Estufa: o corredor da Enfermaria")
	check(find_npc("placa_estufa") != null, "a placa da Estufa 3")
	level.queue_free()
	await frames(2)
	level = await open_level(DESPENSA, "porta")
	check(_minis_named("Banqueteiro").size() == 1, "Despensa: o Banqueteiro")
	check(find_npc("mesa_posta_1") != null and find_npc("mesa_posta_2") != null, "Despensa: duas mesas postas")
	check(find_npc("veia_trancada") != null, "a veia abre do outro lado")
	level.queue_free()
	await frames(2)
	Game.defeated_bosses.append("banqueteiro")
	level = await open_level(VARANDA, "porta")
	check(_minis_named("Ninhada").size() == 1, "Varanda: a Ninhada")
	var hungry: Array = get_tree().get_nodes_in_group("respawnable").filter(func(n): return n is MaeFaminta)
	check(hungry.size() == 1 and not (hungry[0] as MiniBoss).shows_boss_bar, "Varanda: a Mãe Faminta, inimiga comum (sem barra de chefe)")
	check(_minis_named("MaeFaminta").is_empty(), "ela não entra na lista de mini-chefes")
	var hungry_index: int = ((hungry[0] as Enemy).defeated.get_connections()[0]["callable"] as Callable).get_bound_arguments()[0]
	(hungry[0] as Enemy).stats.take_damage(99999.0)
	await frames(3)
	check(Game.is_slain(VARANDA, hungry_index) and not Game.is_boss_defeated("mae_faminta"), "morta: fica morta até descansar (e não vira 'chefe vencido')")
	Game.slain = {}
	check(not Game.is_slain(VARANDA, hungry_index), "descansou: ela volta")
	check(find_npc("varanda_porta_fechada") != null and _exit_to(ARENA_MABEL) == null, "o salão de Mabel fecha até a Ninhada cair")
	var tunnel := false
	var vein: AreaExit = null
	for node in _world.find_children("*", "AreaExit", true, false):
		if (node as AreaExit).opens_flag == "atalho_tunel":
			tunnel = true
		if (node as AreaExit).opens_flag == "atalho_veia":
			vein = node
	check(tunnel, "Varanda: a entrada do túnel de raízes (abre a Cidade)")
	Game.scene_changes_enabled = false
	vein._armed = true
	vein._on_body_entered(level.player)
	check(Game.has_flag("atalho_veia"), "desceu pela veia: atalho aberto")
	level.queue_free()
	await frames(2)
	Game.defeated_bosses.append("ninhada")
	level = await open_level(VARANDA, "porta")
	check(_exit_to(ARENA_MABEL) != null, "vencida a Ninhada: o salão abre")
	level.queue_free()
	await frames(2)
	level = await open_level(DESPENSA, "veia")
	check(find_npc("veia_trancada") == null and level.spawns.has("veia"), "a Despensa sobe pela veia até a Varanda")
	level.queue_free()
	await frames(2)
	check((load(ARENA_MABEL) as PackedScene).instantiate().get("exit_scene") == VARANDA, "o salão de Mabel volta para a Varanda")
	Game.reset_progress()


func test_feast_tables() -> void:
	Game.reset_progress()
	Game.prologue_done = true
	var level := await open_level(DESPENSA, "porta")
	var bloated := get_tree().get_nodes_in_group("enemies").filter(func(e): return str(e.get_meta(&"zona", "")) == "mesa_1")
	check(bloated.size() == 2, "dois Inchados na cozinha da mesa 1 (%d)" % bloated.size())
	level.player.stats.take_damage(level.player.stats.max_health * 0.6)
	var healed := level.eat_at_table("mesa_1")
	check(healed > 0.0, "comer cura (%.0f)" % healed)
	check(bloated.all(func(e): return (e as Enemy).is_alerted()), "mas a sineta chama os Inchados da mesa")
	var others := get_tree().get_nodes_in_group("enemies").filter(func(e): return str(e.get_meta(&"zona", "")) == "mesa_2")
	check(not others.is_empty() and others.all(func(e): return not (e as Enemy).is_alerted()), "a outra cozinha nem ouve")
	check(level.eat_at_table("mesa_1") == 0.0, "o prato está vazio (até a fase recarregar)")
	var entry := DialogueData.get_entry("mesa_posta_2")
	check(str(entry["falas"][0]) == "Ainda quente. Ninguém sabe de quem é.", "examinar o prato")
	level.queue_free()
	await frames(2)
	Game.reset_progress()


func test_socorro() -> void:
	Game.reset_progress()
	Game.prologue_done = true
	var level := await open_level(ENFERMARIA, "porta")
	var nurses := _minis_named("Socorro")
	check(nurses.size() == 1, "a Enfermaria, com a Socorro")
	var nurse := nurses[0] as Socorro
	nurse.target = level.player
	nurse.start_fight()
	nurse._on_wake()
	nurse.stats.take_damage(100.0)
	var hp := nurse.stats.health
	var info := HitInfo.create(14.0, nurse.global_position, level.player.global_position)
	check(is_equal_approx(nurse.feed(info, false), 21.0) and is_equal_approx(nurse.stats.health, hp + 21.0), "golpe que entra: cura 150%")
	check(is_equal_approx(nurse.feed(info, true), 10.5), "com bloqueio: metade disso")
	nurse.stats.take_damage(nurse.stats.max_health * 0.6)
	nurse._fight(0.016)
	check(nurse.phase == 2, "Ronda da Noite")
	nurse.stats.take_damage(99999.0)
	await frames(3)
	check(Game.is_boss_defeated("socorro") and Game.has_item("botao_socorro"), "vencida: o Botão de Socorro")
	# O Botão de Socorro: cada golpe devolve vida; a morte cobra mais memórias.
	Game.memories = 1000
	var lost := Game.register_death()
	check(lost == int(floor(1000 * Game.MEMORY_LOSS_RATIO * Game.SOCORRO_LOSS_MULTIPLIER)), "com o Botão de Socorro, a morte cobra mais (%d)" % lost)
	level.queue_free()
	await frames(2)
	Game.reset_progress()


func test_mabel_inhale() -> void:
	Game.defeated_bosses.assign(["aldir", "nyssa", "banqueteiro", "ninhada"])
	var level := await open_level(ARENA_MABEL, "porta")
	var mabel := level.boss_arena.boss as MabelVoragine
	check(mabel.phase_arena.has(2), "a arena de Mabel muda na fase 2")
	check(get_tree().get_nodes_in_group("mesas").size() == 2, "duas mesas no salão")
	mabel.target = level.player
	var shift := mabel.shift_arena(2)
	await seconds(1.0)
	check(shift != null and shift.is_roots() and get_tree().get_nodes_in_group("mesas").is_empty(), "fase 2: as mesas somem e as raízes fecham a borda")
	level.player.global_position = mabel.global_position + Vector2(0, 90)
	await seconds(0.5)  # chegou perto da mesa: a luta começa (senão o início da luta interrompe a inspiração)
	mabel.phase = 2
	level.player.global_position = mabel.global_position + Vector2(0, 90)
	var start := level.player.global_position.distance_to(mabel.global_position)
	mabel.start_inhale()
	await seconds(mabel.inhale_windup + 0.6)
	var now := level.player.global_position.distance_to(mabel.global_position)
	check(now < start - 10.0, "ela inspira: o herói é puxado (%.0f → %.0f px)" % [start, now])
	level.player.global_position = mabel.global_position + Vector2(0, 10)
	await seconds(0.2)
	check(level.player.is_grabbed_by(mabel), "chegou na boca: o bocado (engolido)")
	level.player.release_grab()
	shift.queue_free()
	level.queue_free()
	await frames(2)
	Game.reset_progress()


# --- v0.35 · Etapa 6: a Montanha expandida --------------------------------------------

func test_montanha_expansion() -> void:
	Game.reset_progress()
	Game.prologue_done = true
	var level := await open_level(MONTANHA, "porta")
	check(_exit_to(OSSARIO) != null, "Floresta: a descida para o Ossário está aberta")
	check(_exit_to(FOSSO) != null and level.spawns.has("fosso"), "Floresta: o Fosso das Correntes")
	check(find_npc("soldado_queimado") != null, "o soldado queimado, com o escudo")
	var burnt: Array = get_tree().get_nodes_in_group("respawnable").filter(func(n): return n.get_script().get_global_name() == "CouracaAndante")
	check(burnt.size() == 2 and burnt.all(func(c): return not (c as MiniBoss).shows_boss_bar), "duas Couraças Queimadas, inimigas comuns (%d)" % burnt.size())
	level.queue_free()
	await frames(2)
	level = await open_level(OSSARIO, "porta")
	check(_minis_named("MatriarcaBestial").size() == 1, "Ossário: a Matriarca")
	var cracks := get_tree().get_nodes_in_group("traps").filter(func(t): return t is PeriodicTrap and t.kind == "lava")
	check(cracks.size() == 3, "Ossário: três fileiras de fendas de lava (%d)" % cracks.size())
	check(find_npc("ossario_porta_fechada") != null and _exit_to(ENCOSTA) == null, "a Encosta fecha até a Matriarca cair")
	check(find_npc("trilha_trancada") != null, "a trilha abre do outro lado")
	level.queue_free()
	await frames(2)
	Game.defeated_bosses.append("matriarca")
	level = await open_level(ENCOSTA, "porta")
	check(_minis_named("CapitaoDragonoide").size() == 1, "Encosta: o Capitão")
	check(level.get_node_or_null("Farm") != null, "Encosta: o Bezerro e o Minotauro")
	check(level.entities.get_children().any(func(n): return n is ItemPickup and n.item_id == "botas_caelis"), "as botas de Caelis, na espinha")
	var trail: AreaExit = null
	var spine := false
	for node in _world.find_children("*", "AreaExit", true, false):
		if (node as AreaExit).opens_flag == "atalho_trilha":
			trail = node
		if (node as AreaExit).opens_flag == "atalho_espinha":
			spine = true
	check(spine and trail != null, "Encosta: a espinha de dragão e a trilha até o Ossário")
	Game.scene_changes_enabled = false
	trail._armed = true
	trail._on_body_entered(level.player)
	check(Game.has_flag("atalho_trilha"), "desceu pela trilha: atalho aberto")
	level.queue_free()
	await frames(2)
	level = await open_level(OSSARIO, "trilha")
	check(find_npc("trilha_trancada") == null and level.spawns.has("trilha"), "o Ossário sobe pela trilha até a Encosta")
	level.queue_free()
	await frames(2)
	check((load(ARENA_RACHEL) as PackedScene).instantiate().get("exit_scene") == ENCOSTA, "o Ninho volta para a Encosta")
	Game.reset_progress()


func test_ultimo_igual() -> void:
	Game.reset_progress()
	Game.prologue_done = true
	var level := await open_level(FOSSO, "porta")
	var dragons := _minis_named("UltimoIgual")
	check(dragons.size() == 1, "o Fosso, com O Último Igual")
	var dragon := dragons[0] as UltimoIgual
	dragon.target = level.player
	dragon.start_fight()
	check(dragon.chained, "acorrentado")
	dragon.global_position = dragon.home_position + Vector2(dragon.chain_radius + 60.0, 0)
	dragon.clamp_to_chain()
	check(dragon.global_position.distance_to(dragon.home_position) <= dragon.chain_radius + 0.5, "não passa do raio da corrente")
	dragon.stats.take_damage(dragon.stats.max_health * 0.55)
	dragon._fight(0.016)
	check(not dragon.chained, "metade da vida: a corrente arrebenta")
	dragon.global_position = dragon.home_position + Vector2(dragon.chain_radius + 60.0, 0)
	dragon.clamp_to_chain()
	check(dragon.global_position.distance_to(dragon.home_position) > dragon.chain_radius + 30.0, "livre: vai aonde quiser")
	dragon.stats.take_damage(99999.0)
	await frames(3)
	check(Game.is_boss_defeated("ultimo_igual") and Game.has_item("corrente_igual"), "vencido: a Corrente do Igual")
	var whip := Items.get_weapon("corrente_igual")
	check(whip != null and whip.weapon_class == "Chicote" and whip.weight() >= 7.0, "uma arma-chicote pesada")
	level.queue_free()
	await frames(2)
	Game.reset_progress()


func test_rachel_dive() -> void:
	Game.defeated_bosses.assign(["aldir", "nyssa", "mabel", "durgan", "capitao"])
	var level := await open_level(ARENA_RACHEL, "porta")
	var rachel := level.boss_arena.boss as RachelCaelis
	level.player.global_position = rachel.global_position + Vector2(0, 90)
	await seconds(0.6)
	rachel.stats.take_damage(rachel.stats.max_health * 0.55)
	await frames(3)
	check(rachel.phase == 2 and rachel.crumbled >= 2, "metade da vida: fase 2 (e a borda já cedeu)")
	level.player.hurtbox.invulnerable = true
	rachel.start_dive()
	await seconds(rachel.dive_fly_time + 0.2)
	check(rachel.mode == RachelCaelis.Mode.UNDER and not rachel.visual.visible and rachel.hurtbox.invulnerable, "mergulhou pela borda: some")
	var near_edge := rachel.edge_pits.any(func(p): return is_instance_valid(p) and p.global_position.distance_to(rachel.emerge_at) < 1.0)
	check(near_edge, "vai sair por uma beirada desabada")
	check(rachel.telegraph.circle_visible, "o círculo no chão avisa onde")
	await seconds(rachel.dive_under_time + 0.1)
	check(rachel.visual.visible and not rachel.hurtbox.invulnerable and rachel.global_position.distance_to(rachel.emerge_at) < 1.0, "irrompe de baixo")
	level.player.hurtbox.invulnerable = false
	level.queue_free()
	await frames(2)
	Game.reset_progress()


# --- v0.35 · Etapa 6: o Domínio expandido ---------------------------------------------

func test_dominio_expansion() -> void:
	Game.reset_progress()
	Game.prologue_done = true
	var level := await open_level(DOMINIO, "porta")
	check(_exit_to(ARQUIVO) != null, "Lago: a descida para o Arquivo está aberta")
	check(_exit_to(AULA) != null and level.spawns.has("aula"), "Lago: a sala de aula congelada")
	check(find_npc("mesa_de_cha") != null and level.rest_chamber != null, "a mesa de chá, junto da Câmara, do outro lado do lago")
	check(level.rest_chamber.global_position.x > 60 * 16, "a Câmara fica do outro lado do lago")
	level.queue_free()
	await frames(2)
	level = await open_level(ARQUIVO, "porta")
	check(_minis_named("GolemArquivo").size() == 1, "Arquivo: o Golem")
	check(get_tree().get_nodes_in_group(&"still_traps").size() == 1, "Arquivo: as vitrines que fecham")
	check(find_npc("arquivo_porta_fechada") != null and _exit_to(GALERIA) == null, "a Galeria fecha até o Golem cair")
	check(level.entities.get_children().any(func(n): return n is ItemPickup and n.item_id == "botas_eco"), "as botas do Eco, catalogadas no Arquivo")
	level.queue_free()
	await frames(2)
	Game.defeated_bosses.append("golem_arquivo")
	level = await open_level(GALERIA, "porta")
	check(_minis_named("CuradoraVitrines").size() == 1, "Galeria: a Curadora")
	check(find_npc("estudioso") != null and find_npc("vitrine_risada") != null, "Galeria: o Estudioso e a vitrine da primeira risada")
	var frozen: Array = get_tree().get_nodes_in_group("respawnable").filter(func(n): return n.get_script().get_global_name() == "Prototipo")
	check(frozen.size() == 1 and not (frozen[0] as MiniBoss).shows_boss_bar, "Galeria: o Protótipo numa vitrine (inimigo comum)")
	var ice := level.entities.get_children().filter(func(n): return n is ItemPickup and n.item_id == "gelo_perpetuo")
	var fake := get_tree().get_nodes_in_group("covers").filter(func(c): return (c as Node2D).global_position.distance_to((ice[0] as Node2D).global_position) < 40.0) if not ice.is_empty() else []
	check(ice.size() == 1 and fake.size() == 1, "o Gelo Perpétuo, atrás de uma vitrine falsa")
	var stairs: AreaExit = null
	var branch := false
	for node in _world.find_children("*", "AreaExit", true, false):
		if (node as AreaExit).opens_flag == "atalho_escada":
			stairs = node
		if (node as AreaExit).opens_flag == "atalho_galho":
			branch = true
	check(branch and stairs != null, "Galeria: o galho congelado e a escada até o Arquivo")
	Game.scene_changes_enabled = false
	stairs._armed = true
	stairs._on_body_entered(level.player)
	check(Game.has_flag("atalho_escada"), "desceu pela escada: atalho aberto")
	level.queue_free()
	await frames(2)
	level = await open_level(ARQUIVO, "escada")
	check(find_npc("escada_trancada") == null and level.spawns.has("escada"), "o Arquivo sobe pela escada até a Galeria")
	level.queue_free()
	await frames(2)
	check((load(ARENA_CASSIAN) as PackedScene).instantiate().get("exit_scene") == GALERIA, "a Sala do Arconte volta para a Galeria")
	Game.reset_progress()


func test_still_trap() -> void:
	Game.reset_progress()
	var player := spawn_player(Vector2(200, 200))
	var trap := StillTrap.attach(_world, 1.0)
	await frames(2)
	player.velocity = Vector2.ZERO
	await seconds(0.6)
	check(trap.still_time > 0.4 and not player.is_grabbed(), "parado: a conta corre (e o vidro avisa)")
	await seconds(0.6)
	check(player.is_grabbed(), "parado demais: a vitrine fecha")
	player.release_grab()
	trap.still_time = 0.5
	player.velocity = Vector2(60, 0)
	trap._physics_process(0.016)
	check(trap.still_time == 0.0, "andar zera a conta")
	trap.queue_free()
	for block in get_tree().get_nodes_in_group(&"ice_blocks"):
		block.queue_free()
	player.queue_free()
	await frames(2)


func test_mestre_arconte() -> void:
	Game.reset_progress()
	Game.prologue_done = true
	var level := await open_level(AULA, "porta")
	var masters := _minis_named("MestreArconte")
	check(masters.size() == 1, "a sala de aula, com o Mestre")
	var master := masters[0] as MestreArconte
	var said := []
	master.speech.connect(func(t: String): said.append(t))
	master.target = level.player
	master.start_fight()
	master.announce()
	check(said[-1] == "Lição um: o gelo guarda!", "anuncia a lição antes do feitiço")
	master.cast_spell(0, true)
	check(not get_tree().get_nodes_in_group("frost_zones").is_empty(), "lição um: geada no chão")
	master.announce()
	check(said[-1] == "Lição dois: o que é guardado não muda!", "lição dois")
	master.cast_spell(1, true)
	master.announce()
	check(said[-1] == "Lição três...", "lição três...")
	master.forget()
	check(said[-1] == "...Lição três. Qual era a lição três?" and master._can_be_staggered(), "esquece: a janela para bater")
	master.stats.take_damage(master.stats.max_health * 0.55)
	master._fight(0.016)
	check(master.phase == 2, "fase 2: feitiços sem aviso")
	master.stats.take_damage(99999.0)
	await frames(3)
	check(Game.is_boss_defeated("mestre_arconte"), "vencido")
	level.queue_free()
	await frames(2)
	Game.reset_progress()


func test_cassian_collects_flasks() -> void:
	Game.defeated_bosses.assign(["aldir", "nyssa", "mabel", "durgan", "rachel", "golem_arquivo", "curadora"])
	var level := await open_level(ARENA_CASSIAN, "porta")
	for trap in get_tree().get_nodes_in_group(&"still_traps"):
		trap.queue_free()
	check(level.still_trap > 0.0, "na Sala do Arconte, ficar parado também conta")
	var cassian := level.boss_arena.boss as CassianVirel
	cassian.target = level.player
	var before := level.player.health_flasks
	var case := cassian.collect_flask()
	check(case != null and level.player.health_flasks == before - 1, "fase 2: um Frasco de Vida vai para a vitrine")
	await frames(2)
	case.take_damage(9999.0)
	await frames(3)
	check(level.player.health_flasks == before, "quebrou a vitrine: o frasco volta")
	level.queue_free()
	await frames(2)
	Game.reset_progress()


# --- v0.41 · Etapa 5: o nome do personagem --------------------------------------------

func test_name_entry_screen() -> void:
	Game.reset_progress()
	var creation := CharacterCreation.new()
	_world.add_child(creation)
	await frames(2)
	check(creation.name_value.text == "???", "na criação, o nome aparece como ???")
	creation.queue_free()
	var entry := NameEntry.new()
	_world.add_child(entry)
	await frames(2)
	var got := [""]
	entry.submitted.connect(func(t: String): got[0] = t)
	entry.field.text = ""
	entry.confirm()
	check(got[0] == "", "nome vazio não passa (é obrigatório)")
	entry.field.text = "   "
	entry.confirm()
	check(got[0] == "", "só espaços também não")
	entry.field.text = ""
	for letter in ["A", "L", "E", "X"]:
		entry.type_letter(letter)
	entry.toggle_case()
	entry.type_letter("a")
	entry.backspace()
	check(entry.field.text == "ALEX", "a grade de letras digita e apaga (controle)")
	check(entry.field.virtual_keyboard_enabled, "no celular, o campo abre o teclado do aparelho")
	entry.field.text = "  Ana   Clara  "
	entry.confirm()
	check(got[0] == "Ana Clara", "o nome sai limpo (%s)" % got[0])
	entry.field.text = "x".repeat(40)
	check(NameEntry.clean(entry.field.text).length() <= NameEntry.MAX_LENGTH, "tem limite de tamanho")
	entry.queue_free()
	await frames(2)
	# Pela ação de diálogo "pedir_nome" (o caminho pacífico, Etapa 9, vai usar).
	var level := await open_level(TEATRO, "camara")
	var ask := func(): await level._on_dialogue_action("pedir_nome")
	ask.call()
	await frames(2)
	check(level.hud.name_entry.visible, "\"pedir_nome\" abre a tela")
	level.hud.name_entry.field.text = "Cobaia"
	level.hud.name_entry.confirm()
	await frames(2)
	check(Game.player_name == "Cobaia" and not level.hud.name_entry.visible, "salvo em player_name")
	level.queue_free()
	await frames(2)
	Game.reset_progress()


func test_name_in_anger_and_terminal() -> void:
	Game.reset_progress()
	Game.criancas_feridas = 1
	var level := await open_level(PROLOGO, "camara")
	var prologo := level as Prologo
	var done := [false]
	var run := func():
		await prologo.ask_name_in_anger()
		done[0] = true
	run.call()
	await frames(3)
	check(level.hud.dialogue.visible, "caminho violento: ela pergunta com raiva antes de morrer")
	var guard := 0
	while level.hud.dialogue.visible and guard < 40:
		level.hud.dialogue._advance.emit()
		await frames(2)
		guard += 1
	check(level.hud.name_entry.visible, "QUAL É O SEU NOME? — a tela de digitar")
	level.hud.name_entry.field.text = "Rato"
	level.hud.name_entry.confirm()
	await frames(3)
	guard = 0
	while level.hud.dialogue.visible and guard < 40:
		level.hud.dialogue._advance.emit()
		await frames(2)
		guard += 1
	await frames(3)
	check(done[0] and Game.player_name == "Rato" and Game.has_flag("nome_violento"), "...Agora eu sei quem riscar.")
	check(DialogueData.variant("terminal") == "terminal_riscado", "o terminal mostra o nome riscado duas vezes")
	var lines: Array = DialogueData.get_entry("terminal_riscado")["falas"]
	check(DialogueData.fill(str(lines[1])).contains("Rato"), "o nome aparece no fim da lista (texto escrito)")
	Game.clear_flag("nome_violento")
	check(DialogueData.variant("terminal") == "terminal_nome", "caminho pacífico: o nome com o número da tentativa")
	Game.player_name = ""
	check(DialogueData.variant("terminal") == "terminal", "sem nome: o terminal de antes")
	level.queue_free()
	await frames(2)
	Game.reset_progress()


func test_name_reactions_and_ng_plus() -> void:
	Game.reset_progress()
	for who in ["lucia", "galeno", "helena", "amaro", "experimento"]:
		check(not DialogueData.get_entry("%s_nome_sim" % who).is_empty() and not DialogueData.get_entry("%s_nome_nao" % who).is_empty(),
			"%s reage ao nome (disse / não lembro)" % who)
	check(str(DialogueData.get_entry("lucia_nome_sim")["falas"][0]) == "Pronto. Agora eu guardo o seu também.", "a fala da Lúcia")
	Game.set_player_name("Tito")
	var snapshot := Game._guardian_snapshot()
	check(snapshot.get("nome", "") == "Tito", "NG+: o nome antigo vai junto com o guardião")
	Game.guardian = snapshot
	Game.start_new_journey({})
	check(Game.player_name.is_empty(), "o novo experimento acorda sem nome")
	var guardian := (load("res://scenes/bosses/experimento_anterior.tscn") as PackedScene).instantiate() as ExperimentoAnterior
	_world.add_child(guardian)
	await frames(2)
	check(guardian.display_name() == "Tito, O Experimento Anterior", "a barra: \"{nome antigo}, O Experimento Anterior\" (%s)" % guardian.display_name())
	guardian.queue_free()
	await frames(2)
	Game.reset_progress()


# --- v0.42 · Etapa 7: Lúcia ---------------------------------------------------------------

func test_lucia_journey() -> void:
	Game.reset_progress()
	Game.prologue_done = true
	var level := await open_level(VIADUTO, "porta")
	check(find_npc("lucia_ponte") != null, "Cidade: Lúcia sentada na ponte do Viaduto")
	var entry := DialogueData.get_entry("lucia_ponte")
	check(str(entry["falas"][2]).begins_with("Meu nome é Lúcia. Repita."), "ela pede que você repita o nome dela")
	await level._on_dialogue_action("flag:lucia_conhecida;lute_comigo:lucia")
	check(Game.has_flag("lucia_na_arena"), "\"Lute comigo\": ela vai na próxima luta")
	level.queue_free()
	await frames(2)
	level = await open_level("res://scenes/world/arena_aldir.tscn", "porta")
	var allies := get_tree().get_nodes_in_group(&"allies").filter(func(a): return a is LuciaAliada)
	check(allies.size() == 1, "na Praça do Detentor, Lúcia luta ao seu lado")
	level._reward_allies(true)
	check(Game.ally_level("lucia") == 2 and not Game.has_flag("lucia_na_arena"), "venceram juntos: ela sobe de nível")
	level.queue_free()
	await frames(2)
	Game.defeated_bosses.append("aldir")
	level = await open_level(VIADUTO, "porta")
	check(find_npc("lucia_ponte") == null, "depois do Aldir, ela sai da ponte")
	level.queue_free()
	await frames(2)
	level = await open_level(BORDA, "porta")
	check(find_npc("lucia_bosque") != null, "Bosque: \"Se eu dormir, acordo menos.\"")
	level.queue_free()
	await frames(2)
	level = await open_level(GALERIA, "porta")
	check(find_npc("lucia_dominio") != null and find_npc("vitrine_lucia") == null, "Domínio: ela espera na antessala do Cassian")
	await level._on_dialogue_action("flag:lucia_congelada")
	level.queue_free()
	await frames(2)
	level = await open_level(GALERIA, "porta")
	check(find_npc("lucia_dominio") == null and find_npc("vitrine_lucia") != null, "\"Vá\": ela vira peça de vitrine")
	check(str(DialogueData.get_entry("vitrine_lucia")["falas"][0]) == "Mulher que lembrava. Peça rara. Não exibir.", "a placa da vitrine")
	level.queue_free()
	await frames(2)
	Game.reset_progress()


func test_lucia_ally_falls_and_sleeps() -> void:
	Game.reset_progress()
	var player := spawn_player(Vector2(200, 200))
	var lucia := Ally.spawn_by_id("lucia", _world, player) as LuciaAliada
	await frames(2)
	check(lucia != null and lucia.display_name.contains("Lúcia"), "a Lúcia é uma aliada (base Ally)")
	player.add_drowsiness(60.0)
	player.add_drowsiness(45.0)
	await frames(2)
	check(lucia.is_asleep(), "o sono que chega em você chega nela: dormiu")
	await seconds(LuciaAliada.SLEEP_TIME + 0.2)
	check(not lucia.is_asleep(), "e acorda depois")
	lucia.fall()
	check(int(Game.flags.get("lucia_quedas", 0)) == 1 and Game.ally_level("lucia") == 1, "caiu: perde memória (lucia_quedas), não força")
	check(DialogueData.variant("lucia_ponte") == "lucia_depois_de_cair", "\"Quem... Desculpe.\"")
	player.queue_free()
	await frames(2)
	Game.reset_progress()


func test_lucia_final() -> void:
	Game.reset_progress()
	Game.prologue_done = true
	Game.defeated_bosses.assign(["cassian"])
	Game.set_flag("lucia_conhecida")
	var level := await open_level(TEATRO, "camara")
	check(find_npc("lucia_teatro") != null, "depois do Cassian: Lúcia no Teatro, sem máscara")
	var order := level.lucia_name_order()
	check(order.size() == 3 and order.has("Lúcia") and level.lucia_name_order() == order, "três nomes, embaralhados uma vez por jogo")
	var run := func(): await level.lucia_final()
	run.call()
	await frames(2)
	check(level.hud.dialogue.visible, "\"Qual é o meu nome?\"")
	level.hud.dialogue._advance.emit()
	await frames(2)
	var right: Button = null
	for button in level.hud.dialogue.find_children("*", "Button", true, false):
		if (button as Button).text == "Lúcia":
			right = button
	check(right != null, "o nome certo está entre as opções")
	right.pressed.emit()
	for i in 10:
		await frames(2)
		if level.hud.dialogue.visible:
			level.hud.dialogue._advance.emit()
	check(Game.has_flag("lucia_lembrada") and not Game.has_flag("lucia_esquecida"), "certo: \"...É isso. Obrigada por guardar.\"")
	level.queue_free()
	await frames(2)
	level = await open_level(TEATRO, "camara")
	check(find_npc("lucia_teatro") == null and find_npc("lucia_mascara") != null, "ela some em paz; ficam a máscara e a espada")
	level.queue_free()
	await frames(2)
	Game.clear_flag("lucia_lembrada")
	Game.flags["lucia_quedas"] = 3
	check(DialogueData.variant("lucia_teatro") == "lucia_teatro_esqueceu", "caiu demais: ela nem pergunta")
	Game.set_flag("lucia_esquecida")
	level = await open_level(TEATRO, "camara")
	check(find_npc("lucia_cinzenta") != null and find_npc("lucia_teatro") == null, "esquecida: vira uma Civil Cinzenta no Teatro")
	level.queue_free()
	await frames(2)
	Game.reset_progress()


# --- v0.42 · Etapa 7: Galeno --------------------------------------------------------------

func test_galeno_journey() -> void:
	Game.reset_progress()
	Game.prologue_done = true
	var level := await open_level(FORJAS, "porta")
	check(find_npc("galeno_forjas") != null, "Forjas: Galeno diante da estátua sem rosto")
	check(str(DialogueData.get_entry("galeno_forjas")["falas"][2]) == "Coitado. Nem cara tem. Eu pelo menos tenho barba!", "\"Nem cara tem.\"")
	var options := DialogueBox.expand_options(DialogueData.get_entry("galeno_forjas")["opcoes"])
	check(options[0]["texto"] == "Não lembro", "ele pergunta o nome (\"Não lembro\" / o nome)")
	await level._on_dialogue_action(options[0]["acao"].get_slice(";", 0))
	check(DialogueData.variant("galeno_forjas") == "galeno_de_novo", "depois de conhecer: \"Não lembro o que eu protegia...\"")
	await level._on_dialogue_action("lute_comigo:galeno")
	level.queue_free()
	await frames(2)
	level = await open_level(ARENA_DURGAN, "porta")
	var galeno := get_tree().get_nodes_in_group(&"allies").filter(func(a): return a is GalenoAliado)
	check(galeno.size() == 1, "na Forja do Eco, Galeno luta ao seu lado")
	level._reward_allies(true)
	check(int(Game.flags.get("galeno_fragmentos", 0)) == 1, "venceram: um fragmento volta")
	check(DialogueData.variant("galeno_de_novo") == "galeno_giz", "\"...Giz. Por que eu lembro de giz?\"")
	level.queue_free()
	await frames(2)
	# Cair: esquece um fragmento e fica mais feliz.
	var player := spawn_player(Vector2(200, 200))
	var big := Ally.spawn_by_id("galeno", _world, player) as GalenoAliado
	await frames(2)
	var hp := big.health
	var hit := HitInfo.create(40.0, Vector2(180, 200), big.global_position)
	big._on_hit(hit)
	check(is_equal_approx(hp - big.health, 40.0 * 0.5 * 0.7), "o escudo gigante segura metade")
	big.fall()
	check(int(Game.flags.get("galeno_fragmentos", 0)) == 0 and Game.has_flag("galeno_caiu"), "caiu: esqueceu um fragmento")
	check(DialogueData.variant("galeno_raizes") == "galeno_depois_de_cair", "\"Ha! Já nos conhecemos? Que ótimo!\"")
	player.queue_free()
	await frames(2)
	Game.clear_flag("galeno_caiu")
	Game.flags["galeno_fragmentos"] = 2
	check(DialogueData.variant("galeno_raizes") == "galeno_raizes_depois", "Raízes, mais fragmentos: \"Pequeno. Era pequeno.\"")
	Game.add_item("espada_madeira_pequena")
	var sword := DialogueBox.expand_options(DialogueData.get_entry("galeno_raizes_depois")["opcoes"])
	check(sword.any(func(o): return str(o.get("acao", "")) == "falar:galeno_espadinha"), "a espadinha de madeira tem resposta")
	# O final: Lembre / Esqueça.
	Game.flags["galeno_fragmentos"] = 3
	level = await open_level(TEATRO, "camara")
	check(find_npc("galeno_teatro") != null, "o último fragmento: Galeno no Teatro, sem rir")
	await level._on_dialogue_action("flag:galeno_esqueceu;ganhar:desenho_a_giz")
	check(Game.has_item("desenho_a_giz"), "\"Esqueça\": ele entrega o Desenho a Giz")
	level.queue_free()
	await frames(2)
	level = await open_level(TEATRO, "camara")
	check(find_npc("galeno_teatro") == null, "e volta a andar sem rumo")
	level.queue_free()
	await frames(2)
	Game.reset_progress()


# --- v0.43 · Etapa 7: Tião e Bastião ------------------------------------------------------

func test_brawlers_help() -> void:
	Game.reset_progress()
	Game.prologue_done = true
	var level := await open_level(QUARTEL, "porta")
	check(find_npc("tiao_cidade_quartel") != null, "Cidade: o Tião ajuda contra o Sargento")
	var came := level.call_brawler("tiao")
	check(came.size() == 1 and came[0] is TiaoAliado, "\"Me ajuda aqui?\": ele entra na hora")
	level._reward_allies(true)
	check(int(Game.flags.get("tiao_ajudas", 0)) == 1 and not Game.flags.get("tiao_acompanha", false), "venceram: conta a ajuda, e ele volta para o canto")
	level.queue_free()
	await frames(2)
	level = await open_level(DORMITORIO, "porta")
	check(str(DialogueData.get_entry("tiao_bosque_dormitorio")["falas"][0]).begins_with("AH! Caramba"), "o Tião dormindo no Dormitório")
	level.queue_free()
	await frames(2)
	for spot in ["bastiao_cidade_viaduto", "bastiao_bosque_borda", "tiao_raizes_despensa", "bastiao_forjas_fornalha",
			"tiao_montanha_encosta", "bastiao_montanha_ossario", "tiao_dominio_arquivo", "bastiao_dominio_galeria"]:
		check(not DialogueData.get_entry(spot).is_empty(), "%s: pronto ao lado do mini-chefe" % spot)
	Game.set_flag("brigoes_juntos")
	level = await open_level(QUARTEL, "porta")
	came = level.call_brawler("tiao")
	check(came.size() == 2, "juntos: chamar um traz os dois")
	level.queue_free()
	await frames(2)
	Game.reset_progress()


func test_bridge_fight_choices() -> void:
	Game.reset_progress()
	Game.prologue_done = true
	Game.defeated_bosses.assign(["matriarca", "capitao"])
	var level := await open_level(ENCOSTA, "porta")
	check(find_npc("briga_ponte") == null, "sem conversar com os dois: nada de briga")
	level.queue_free()
	await frames(2)
	Game.set_flag("tiao_conversou")
	Game.set_flag("bastiao_conversou")
	level = await open_level(ENCOSTA, "porta")
	check(find_npc("briga_ponte") != null, "conversou com os dois: a briga na espinha de dragão")
	await level._on_dialogue_action("flag:bastiao_cinzento")
	level.queue_free()
	await frames(2)
	level = await open_level(ENCOSTA, "porta")
	check(find_npc("briga_ponte") == null and find_npc("bastiao_cinzento_ponte") != null, "ajudou o Tião: o Bastião vira cinzento na ponte")
	level.queue_free()
	await frames(2)
	check(DialogueData.variant("tiao_cidade_quartel") == "tiao_quieto", "o Tião, mais quieto: \"Pesa mais.\"")
	level = await open_level(VIADUTO, "porta")
	check(find_npc("bastiao_cidade_viaduto") == null, "o Bastião não ajuda mais ninguém")
	check(level.call_brawler("bastiao").is_empty(), "nem se chamar")
	level.queue_free()
	await frames(2)
	Game.reset_progress()


func test_sebastioes_duel() -> void:
	Game.reset_progress()
	Game.prologue_done = true
	Game.defeated_bosses.assign(["matriarca", "capitao"])
	Game.set_flag("tiao_conversou")
	Game.set_flag("bastiao_conversou")
	var level := await open_level(ENCOSTA, "porta")
	var duo := level.start_sebastioes_duel()
	await frames(3)
	check(find_npc("briga_ponte") == null, "entrou no meio: os dois viram um só mini-chefe")
	check(duo.partner != null and is_instance_valid(duo.partner), "dois corpos (Tião e Bastião)")
	duo.target = level.player
	duo.start_fight()
	duo._on_wake()
	level._on_miniboss_started(duo)
	await frames(2)
	check(level.hud._boss_bar.visible and level.hud._partner_bar.visible, "duas barras, uma em cima da outra (Dark Souls)")
	check(level.hud._boss_bar.boss_name == "Tião" and level.hud._partner_bar.boss_name == "Bastião", "uma do Tião, outra do Bastião")
	var hp := duo.stats.health
	duo.partner._on_hit(HitInfo.create(30.0, level.player.global_position, duo.partner.global_position))
	await frames(2)
	check(duo.stats.health == hp and duo.partner.health_ratio() < 1.0, "bater no Bastião desce a barra DELE")
	duo.stats.take_damage(99999.0)
	await frames(3)
	check(duo.downed and not duo.dead and not Game.has_flag("brigoes_juntos"), "o Tião caiu, mas o Bastião ainda luta")
	check(duo.partner.speed > duo.partner_speed, "e o Bastião fica com raiva")
	duo.partner._on_hit(HitInfo.create(99999.0, level.player.global_position, duo.partner.global_position))
	await frames(3)
	check(Game.has_flag("brigoes_juntos") and Game.is_boss_defeated("sebastioes"), "os dois no chão: \"Sebastião e Sebastião.\" (brigoes_juntos)")
	level.queue_free()
	await frames(2)
	Game.reset_progress()

