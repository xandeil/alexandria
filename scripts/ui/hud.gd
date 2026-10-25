class_name HUD
extends CanvasLayer
## Interface do jogo: barras, frascos, memórias, barra de chefe, títulos de área,
## tela de morte ("VOCÊ ESQUECEU"), vitória e o efeito de perda de visão.
##
## O HUD só ESCUTA sinais (do Player, do Game, do chefe). Ninguém chama
## "hud.atualizar_vida()" — se amanhã o HUD sumir, o jogo continua funcionando.

const VISION_SHADER := preload("res://shaders/vision.gdshader")
const ICON_HEAL := preload("res://assets/ui/icon_heal.png")
const ICON_SANITY := preload("res://assets/ui/icon_sanity.png")
const ICON_MEMORY := preload("res://assets/ui/icon_memory.png")
const ICON_PAUSE := preload("res://assets/ui/icon_pause.png")

var dialogue: DialogueBox
var level_up_menu: LevelUpMenu
var smith_menu: SmithMenu
var pause_menu: PauseMenu
var inventory_menu: InventoryMenu
var touch: TouchControls
## Cena curta rodando (acordar, lembrança, queda): sem pausa por cima dela.
var cutscene := false
var hints: TutorialHints

var _player: Player
var _bars: StatusBars
var _health_flask_label: Label
var _sanity_label: Label
var _memory_label: Label
var _boss_bar: BossBar
var _speech: Label
var _area_title: Label
var _area_subtitle: Label
var _toast: Label
var _hurt_flash: ColorRect
var _vision_layer: CanvasLayer
var _vision_rect: ColorRect
var _vision_material: ShaderMaterial
var _overlay: ColorRect
var _big_title: Label
var _big_subtitle: Label
var _boss: Boss
var _shown_memories := 0.0
var _toast_tween: Tween
var _speech_tween: Tween
## "+ Sucata Temperada x2": a lista de itens ganhos, no canto esquerdo.
var _item_log: VBoxContainer
var _area_tween: Tween
## "PRESO! Toque ATAQUE" + os toques que faltam (agarrão).
var _grab_label: Label
var _grab_tween: Tween


func _ready() -> void:
	layer = 10
	_build_vision()
	_build_status()
	_build_boss_bar()
	_build_texts()
	_build_overlay()
	touch = TouchControls.new()
	add_child(touch)
	dialogue = DialogueBox.new()
	add_child(dialogue)
	level_up_menu = LevelUpMenu.new()
	add_child(level_up_menu)
	smith_menu = SmithMenu.new()
	add_child(smith_menu)
	pause_menu = PauseMenu.new()
	add_child(pause_menu)
	inventory_menu = InventoryMenu.new()
	add_child(inventory_menu)
	pause_menu.inventory_menu = inventory_menu
	_build_item_log()
	Game.item_added.connect(show_item_gained)
	Game.sanity_flasks_changed.connect(func(count: int): _sanity_label.text = "x%d" % count)
	Game.vision_changed.connect(func(_l: int): _update_vision_strength())
	_shown_memories = Game.memories
	_sanity_label.text = "x%d" % Game.sanity_flasks
	_update_vision_strength()


func bind_player(player: Player) -> void:
	_player = player
	var stats := player.stats
	stats.health_changed.connect(_bars.set_health)
	stats.stamina_changed.connect(_bars.set_stamina)
	stats.exhaustion_changed.connect(_bars.set_exhausted)
	_bars.set_health(stats.health, stats.max_health)
	_bars.hp_trail = stats.health
	_bars.set_stamina(stats.stamina, stats.max_stamina)
	player.stamina_denied.connect(_bars.flash_denied)
	player.drowsiness_changed.connect(_bars.set_drowsiness)
	player.sleep_changed.connect(_bars.set_asleep)
	player.health_flasks_changed.connect(func(current: int, _max: int): _health_flask_label.text = "x%d" % current)
	_health_flask_label.text = "x%d" % player.health_flasks
	player.hurt.connect(func(_amount: float): _flash_hurt())
	player.grab_changed.connect(_on_grab_changed)
	player.grab_progress.connect(_on_grab_progress)
	touch.bind_player(player)
	pause_menu.player = player
	hints = TutorialHints.new()
	hints.show_hint = _toast_after_title
	add_child(hints)
	hints.bind(player)


func _process(delta: float) -> void:
	# Contador de memórias "rolando" até o valor real.
	if absf(_shown_memories - Game.memories) > 0.5:
		_shown_memories = move_toward(_shown_memories, Game.memories, maxf(40.0, absf(Game.memories - _shown_memories) * 4.0) * delta)
	else:
		_shown_memories = Game.memories
	_memory_label.text = str(int(_shown_memories))
	if _vision_layer.visible and is_instance_valid(_player):
		var screen_pos := _player.get_global_transform_with_canvas().origin + Vector2(0, -8)
		var view := get_viewport().get_visible_rect().size
		_vision_material.set_shader_parameter("center", screen_pos / view)
		_vision_material.set_shader_parameter("aspect", view.x / view.y)
	if is_instance_valid(_boss) and _boss_bar.visible:
		_boss_bar.set_ratio(_boss.stats.health_ratio())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause") and can_pause():
		pause_menu.open()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"inventory") and can_pause():
		get_viewport().set_input_as_handled()
		open_inventory()


## Atalho (tecla I / Tab / Select): abre o inventário direto, pausando o jogo.
func open_inventory() -> void:
	touch.release_all()
	get_tree().paused = true
	inventory_menu.open(_player)
	await inventory_menu.closed
	get_tree().paused = false


func _notification(what: int) -> void:
	# Android: o botão "voltar" abre/fecha a pausa (quit_on_go_back=false no
	# project.godot). O HUD é o ÚNICO dono dessa tecla — se a pausa também
	# tratasse, o mesmo toque abriria e fecharia o menu no mesmo quadro.
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if inventory_menu.visible:
			inventory_menu.close()
		elif pause_menu.visible:
			pause_menu.close()
		elif can_pause():
			pause_menu.open()


## Só pausa no meio do jogo "normal": nunca por cima de diálogo, menu da Fada,
## descanso, troca de cena ou com o herói morto (a morte já foi registrada,
## mas abrir o menu por cima da tela "VOCÊ ESQUECEU" só confunde).
func can_pause() -> bool:
	if cutscene or get_tree().paused or Fader.busy or dialogue.visible or level_up_menu.visible or smith_menu.visible or inventory_menu.visible:
		return false
	return is_instance_valid(_player) and not _player.is_dead()


# --- Construção -------------------------------------------------------------------

func _build_vision() -> void:
	# Camada ABAIXO do HUD: escurece o mundo pelas bordas a cada morte.
	_vision_layer = CanvasLayer.new()
	_vision_layer.layer = 5
	add_child(_vision_layer)
	_vision_rect = ColorRect.new()
	_vision_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_vision_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vision_material = ShaderMaterial.new()
	_vision_material.shader = VISION_SHADER
	_vision_rect.material = _vision_material
	_vision_layer.add_child(_vision_rect)


func _update_vision_strength() -> void:
	var loss := Game.vision_loss_ratio()
	_vision_layer.visible = loss > 0.0
	_vision_material.set_shader_parameter("loss", loss)


func _build_status() -> void:
	_bars = StatusBars.new()
	_bars.position = Vector2(10, 9)
	add_child(_bars)
	var flasks := HBoxContainer.new()
	flasks.position = Vector2(8, 26)
	flasks.add_theme_constant_override("separation", 1)
	flasks.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flasks)
	flasks.add_child(_icon(ICON_HEAL))
	_health_flask_label = UIStyle.label("x3", 9, UIStyle.TEXT, UIStyle.FONT_NUMBERS)
	flasks.add_child(_health_flask_label)
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(6, 0)
	flasks.add_child(spacer)
	flasks.add_child(_icon(ICON_SANITY))
	_sanity_label = UIStyle.label("x1", 9, UIStyle.TEXT, UIStyle.FONT_NUMBERS)
	flasks.add_child(_sanity_label)

	var right := HBoxContainer.new()
	right.anchor_left = 1.0
	right.anchor_right = 1.0
	right.offset_left = -140
	right.offset_right = -34
	right.offset_top = 7
	right.alignment = BoxContainer.ALIGNMENT_END
	right.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(right)
	right.add_child(_icon(ICON_MEMORY))
	_memory_label = UIStyle.label("0", 11, UIStyle.TEXT, UIStyle.FONT_NUMBERS)
	right.add_child(_memory_label)

	var pause := TextureButton.new()
	pause.texture_normal = ICON_PAUSE
	pause.anchor_left = 1.0
	pause.anchor_right = 1.0
	pause.offset_left = -28
	pause.offset_right = -6
	pause.offset_top = 4
	pause.offset_bottom = 26
	pause.ignore_texture_size = true
	pause.stretch_mode = TextureButton.STRETCH_KEEP_CENTERED
	pause.focus_mode = Control.FOCUS_NONE  # é um atalho de toque; não rouba o foco dos menus
	pause.pressed.connect(func():
		if can_pause():
			pause_menu.open())
	add_child(pause)


func _icon(texture: Texture2D) -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = texture
	rect.custom_minimum_size = Vector2(14, 14)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect


func _build_boss_bar() -> void:
	# No celular a parte de baixo é dos polegares: a barra do chefe fica no topo.
	_boss_bar = BossBar.new()
	_boss_bar.anchor_left = 0.5
	_boss_bar.anchor_right = 0.5
	_boss_bar.offset_left = -92
	_boss_bar.offset_right = 92
	_boss_bar.offset_top = 6
	_boss_bar.offset_bottom = 40
	_boss_bar.visible = false
	add_child(_boss_bar)
	_speech = UIStyle.label("", 9, Color(0.95, 0.88, 0.85))
	_speech.anchor_left = 0.5
	_speech.anchor_right = 0.5
	_speech.offset_left = -150
	_speech.offset_right = 150
	_speech.offset_top = 44
	_speech.offset_bottom = 64
	_speech.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_speech.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_speech.modulate.a = 0.0
	add_child(_speech)


func _build_texts() -> void:
	_area_title = UIStyle.label("", 18, UIStyle.TEXT, UIStyle.TITLE_FONT)
	_area_title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_area_title.offset_left = -200
	_area_title.offset_right = 200
	_area_title.offset_top = 78
	_area_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_area_title.modulate.a = 0.0
	add_child(_area_title)
	_area_subtitle = UIStyle.label("", 8, UIStyle.TEXT_DIM)
	_area_subtitle.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_area_subtitle.offset_left = -200
	_area_subtitle.offset_right = 200
	_area_subtitle.offset_top = 104
	_area_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_area_subtitle.modulate.a = 0.0
	add_child(_area_subtitle)
	_toast = UIStyle.label("", 9, UIStyle.TEXT)
	_toast.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_toast.offset_left = -180
	_toast.offset_right = 180
	_toast.offset_top = 70
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_toast.modulate.a = 0.0
	add_child(_toast)
	_grab_label = UIStyle.label("", 11, Color(1.0, 0.8, 0.75), UIStyle.TITLE_FONT)
	_grab_label.set_anchors_preset(Control.PRESET_CENTER)
	_grab_label.offset_left = -200
	_grab_label.offset_right = 200
	_grab_label.offset_top = 34
	_grab_label.offset_bottom = 70
	_grab_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_grab_label.visible = false
	add_child(_grab_label)
	_hurt_flash = ColorRect.new()
	_hurt_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_hurt_flash.color = Color(0.7, 0.05, 0.08, 0.0)
	_hurt_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_hurt_flash)


func _build_overlay() -> void:
	_overlay = ColorRect.new()
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.color = Color(0.02, 0.015, 0.03, 0.0)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay)
	_big_title = UIStyle.label("", 26, Color(0.85, 0.82, 0.8), UIStyle.TITLE_FONT)
	_big_title.set_anchors_preset(Control.PRESET_CENTER)
	_big_title.offset_left = -240
	_big_title.offset_right = 240
	_big_title.offset_top = -30
	_big_title.offset_bottom = 6
	_big_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_big_title.modulate.a = 0.0
	add_child(_big_title)
	_big_subtitle = UIStyle.label("", 9, UIStyle.TEXT_DIM)
	_big_subtitle.set_anchors_preset(Control.PRESET_CENTER)
	_big_subtitle.offset_left = -240
	_big_subtitle.offset_right = 240
	_big_subtitle.offset_top = 10
	_big_subtitle.offset_bottom = 40
	_big_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_big_subtitle.modulate.a = 0.0
	add_child(_big_subtitle)


# --- API usada pela fase ------------------------------------------------------------------

func show_area_title(title: String, subtitle: String = "") -> void:
	_area_title.text = title
	_area_subtitle.text = subtitle
	var tween := create_tween()
	_area_tween = tween
	tween.tween_interval(0.5)
	tween.tween_property(_area_title, "modulate:a", 1.0, 1.0)
	tween.parallel().tween_property(_area_subtitle, "modulate:a", 1.0, 1.0)
	tween.tween_interval(2.0)
	tween.tween_property(_area_title, "modulate:a", 0.0, 1.0)
	tween.parallel().tween_property(_area_subtitle, "modulate:a", 0.0, 1.0)


# --- Itens ganhos ------------------------------------------------------------------

func _build_item_log() -> void:
	_item_log = VBoxContainer.new()
	_item_log.position = Vector2(10, 64)
	_item_log.add_theme_constant_override("separation", 2)
	_item_log.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_item_log)


## Uma linha "+ [ícone] Nome x2" que aparece e some sozinha. Roda mesmo com o
## jogo pausado (comprar no Vendedor pausa o mundo, mas o recibo aparece na hora).
func show_item_gained(item_id: String, count: int) -> void:
	var item := Items.get_item(item_id)
	if item == null:
		return
	while _item_log.get_child_count() >= 4:
		var oldest := _item_log.get_child(0)
		_item_log.remove_child(oldest)
		oldest.queue_free()
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 3)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var icon := TextureRect.new()
	icon.texture = item.icon
	icon.custom_minimum_size = Vector2(14, 14)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	row.add_child(icon)
	var text := "+ %s" % item.display_name
	if count > 1:
		text += " x%d" % count
	row.add_child(UIStyle.label(text, 9, UIStyle.TEXT))
	row.modulate.a = 0.0
	_item_log.add_child(row)
	var tween := row.create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(row, "modulate:a", 1.0, 0.2)
	tween.tween_interval(2.8)
	tween.tween_property(row, "modulate:a", 0.0, 0.6)
	tween.tween_callback(row.queue_free)
	if item_id == "escudo_remendado":
		_toast_after_title("Mão esquerda: SEGURE o botão do escudo para defender. Cada golpe segurado custa estamina.")


## Dica que não pode brigar com o nome da área (os dois ocupam o topo da tela):
## se o título ainda está na tela, espera ele sumir.
func _toast_after_title(text: String) -> void:
	if _area_tween and _area_tween.is_running():
		await _area_tween.finished
	toast(text)


func toast(text: String) -> void:
	_toast.text = text
	if _toast_tween and _toast_tween.is_valid():
		_toast_tween.kill()
	_toast_tween = create_tween()
	_toast_tween.tween_property(_toast, "modulate:a", 1.0, 0.25)
	_toast_tween.tween_interval(2.4)
	_toast_tween.tween_property(_toast, "modulate:a", 0.0, 0.6)


func show_boss(boss: Boss) -> void:
	_boss = boss
	_boss_bar.boss_name = boss.display_name()
	_boss_bar.boss_title = boss.display_title()
	_boss_bar.phase_text = boss.phase_label()  # polimorfismo: cada chefe diz a sua fase
	_boss_bar.ratio = 1.0
	_boss_bar.trail = 1.0
	_boss_bar.armor = boss.armor_ratio()
	_boss_bar.visible = true
	_boss_bar.modulate.a = 0.0
	create_tween().tween_property(_boss_bar, "modulate:a", 1.0, 0.6)
	if boss.has_meta("hud_bound"):
		return  # mini-chefe que acordou de novo: os sinais já estão ligados
	boss.set_meta("hud_bound", true)
	boss.phase_changed.connect(func(text: String): _boss_bar.phase_text = text)
	boss.armor_ratio_changed.connect(func(ratio: float): _boss_bar.armor = ratio)
	boss.title_changed.connect(func(new_name: String, new_title: String):
		_boss_bar.boss_name = new_name
		_boss_bar.boss_title = new_title
		_boss_bar.armor = -1.0
		_boss_bar.trail = 1.0)
	boss.speech.connect(_show_speech)


func hide_boss() -> void:
	var tween := create_tween()
	tween.tween_property(_boss_bar, "modulate:a", 0.0, 0.8)
	tween.tween_callback(func(): _boss_bar.visible = false)
	_boss = null


func _show_speech(text: String) -> void:
	_speech.text = "“%s”" % text
	if _speech_tween and _speech_tween.is_valid():
		_speech_tween.kill()
	_speech_tween = create_tween()
	_speech_tween.tween_property(_speech, "modulate:a", 1.0, 0.3)
	_speech_tween.tween_interval(3.0)
	_speech_tween.tween_property(_speech, "modulate:a", 0.0, 0.8)


## "Morrer não é o problema; esquecer é."
func show_death(lost_memories: int, deaths: int) -> void:
	touch.set_enabled(false)
	_boss_bar.visible = false
	_speech.visible = false
	_big_title.text = "VOCÊ ESQUECEU"
	_big_title.add_theme_color_override("font_color", Color(0.78, 0.2, 0.22))
	var lines := "−%d memórias   ·   %dª morte" % [lost_memories, deaths]
	if Game.vision_loss >= Game.MAX_VISION_LOSS:
		lines += "\nQuase não há mais o que ver."
	else:
		lines += "\nA visão escurece pelas bordas."
	_big_subtitle.text = lines
	var tween := create_tween()
	tween.tween_property(_overlay, "color:a", 0.78, 0.8)
	tween.parallel().tween_property(_big_title, "modulate:a", 1.0, 1.2)
	tween.tween_property(_big_subtitle, "modulate:a", 1.0, 0.6)


func show_victory(title: String, subtitle: String) -> void:
	_big_title.text = title
	_big_title.add_theme_color_override("font_color", UIStyle.GOLD)
	_big_subtitle.text = subtitle
	Sfx.play(&"rest")
	var tween := create_tween()
	tween.tween_property(_big_title, "modulate:a", 1.0, 1.0)
	tween.parallel().tween_property(_big_subtitle, "modulate:a", 1.0, 1.0)
	tween.tween_interval(3.0)
	tween.tween_property(_big_title, "modulate:a", 0.0, 1.2)
	tween.parallel().tween_property(_big_subtitle, "modulate:a", 0.0, 1.2)


# --- Agarrão ---------------------------------------------------------------------------

func _on_grab_changed(grabbed: bool, taps_needed: int) -> void:
	_grab_label.visible = grabbed
	if _grab_tween and _grab_tween.is_valid():
		_grab_tween.kill()
	if not grabbed:
		return
	_on_grab_progress(0, taps_needed)
	_grab_tween = create_tween().set_loops()
	_grab_tween.tween_property(_grab_label, "scale", Vector2(1.08, 1.08), 0.12)
	_grab_tween.tween_property(_grab_label, "scale", Vector2.ONE, 0.12)


func _on_grab_progress(taps: int, taps_needed: int) -> void:
	var bar := "■".repeat(mini(taps, taps_needed)) + "□".repeat(maxi(taps_needed - taps, 0))
	var press := "Aperte R1 rápido" if Settings.controller_mode else "Toque ATAQUE rápido"
	_grab_label.text = "PRESO!  %s\n%s" % [press, bar]
	_grab_label.pivot_offset = _grab_label.size * 0.5


func _flash_hurt() -> void:
	var tween := create_tween()
	_hurt_flash.color.a = 0.28
	tween.tween_property(_hurt_flash, "color:a", 0.0, 0.35)
