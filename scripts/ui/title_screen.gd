class_name TitleScreen
extends Control
## Tela de título no estilo dos soulslike: fundo preto, cinzas subindo devagar,
## o nome do jogo e "Pressione qualquer botão". Depois, o menu: só texto branco,
## sem caixas; o item escolhido clareia com uma faixa de luz atrás (DSMenuButton).

## Cinzas/brasas que sobem devagar no escuro (desenhadas, sem arquivo de imagem).
const ASH_COUNT := 42

var _background: ColorRect
var _menu: VBoxContainer
var _new_game_button: Button
var _continue_button: Button
var _notice: Label
var _press_any: Label
var _options: OptionsMenu
var _creation: CharacterCreation
var _cutscene: CutscenePlayer
## A abertura do "Novo jogo" (vídeo em Ogg Theora).
const OPENING_VIDEO := "res://assets/cutscenes/abertura.ogv"
var _slots: SlotMenu
## Em qual slot o novo jogo vai começar (escolhido antes da criação de personagem).
var _new_slot := 0
var _time := 0.0
var _waiting_any_key := true
var _ash: Array[Vector3] = []  # x, y, velocidade (em fração da tela)


func _ready() -> void:
	add_to_group(&"pad_menu")  # PadMenus: ✕ confirma e o foco nunca se perde no controle
	_build()
	Sfx.play_ambience(&"tema_alexandria", -8.0)


func _build() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_background = ColorRect.new()
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_background.color = Color(0.0, 0.0, 0.0)
	_background.set_anchors_preset(Control.PRESET_FULL_RECT)
	_background.show_behind_parent = true  # as cinzas (o _draw daqui) ficam por cima do preto
	add_child(_background)
	for i in ASH_COUNT:
		_ash.append(Vector3(randf(), randf(), randf_range(0.01, 0.035)))

	var title := UIStyle.label("ALEXANDRIA", 30, Color(0.9, 0.88, 0.84), UIStyle.TITLE_FONT)
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.offset_left = -240
	title.offset_right = 240
	title.offset_top = 58
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)
	var subtitle := UIStyle.label("A Ilha Que Não Cai", 10, Color(0.6, 0.58, 0.55), UIStyle.TITLE_FONT)
	subtitle.set_anchors_preset(Control.PRESET_CENTER_TOP)
	subtitle.offset_left = -240
	subtitle.offset_right = 240
	subtitle.offset_top = 100
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(subtitle)

	_press_any = UIStyle.label("PRESSIONE QUALQUER BOTÃO", 9, Color(0.78, 0.76, 0.72), UIStyle.TITLE_FONT)
	_press_any.set_anchors_preset(Control.PRESET_CENTER)
	_press_any.offset_left = -200
	_press_any.offset_right = 200
	_press_any.offset_top = 40
	_press_any.offset_bottom = 60
	_press_any.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_press_any)

	_menu = VBoxContainer.new()
	_menu.set_anchors_preset(Control.PRESET_CENTER)
	_menu.offset_left = -90
	_menu.offset_right = 90
	_menu.offset_top = 6
	_menu.offset_bottom = 110
	_menu.add_theme_constant_override("separation", 2)
	_menu.visible = false
	_menu.modulate.a = 0.0
	add_child(_menu)
	if Game.has_save():
		_continue_button = DSMenuButton.make("Continuar")
		_continue_button.pressed.connect(_on_continue)
		_menu.add_child(_continue_button)
	if Game.any_save():
		var load_button := DSMenuButton.make("Carregar")
		load_button.pressed.connect(func(): open_slots("carregar"))
		_menu.add_child(load_button)
	_new_game_button = DSMenuButton.make("Novo jogo")
	_new_game_button.pressed.connect(_on_new_game)
	_menu.add_child(_new_game_button)
	var options_button := DSMenuButton.make("Opções")
	options_button.pressed.connect(_open_options)
	_menu.add_child(options_button)
	if not OS.has_feature("web"):
		var quit_button := DSMenuButton.make("Sair")
		quit_button.pressed.connect(func(): Game.quit_game())
		_menu.add_child(quit_button)
	_options = OptionsMenu.new()
	add_child(_options)
	_options.closed.connect(func(): options_button.grab_focus())

	_notice = UIStyle.label("", 8, Color(0.95, 0.6, 0.55))
	_notice.set_anchors_preset(Control.PRESET_CENTER)
	_notice.offset_left = -200
	_notice.offset_right = 200
	_notice.offset_top = 112
	_notice.offset_bottom = 132
	_notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_notice)

	var footer := UIStyle.label(_footer_text(), 7, Color(0.4, 0.39, 0.37))
	footer.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	footer.offset_left = -240
	footer.offset_right = 240
	footer.offset_top = -16
	footer.offset_bottom = -4
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(footer)


## "Pressione qualquer botão": tecla, clique, toque ou botão do controle.
func _input(event: InputEvent) -> void:
	if not _waiting_any_key:
		return
	var pressed: bool = (event is InputEventKey and event.pressed and not event.echo) \
		or (event is InputEventMouseButton and event.pressed) \
		or (event is InputEventScreenTouch and event.pressed) \
		or (event is InputEventJoypadButton and event.pressed)
	if pressed:
		get_viewport().set_input_as_handled()
		show_menu()


func show_menu() -> void:
	if not _waiting_any_key:
		return
	_waiting_any_key = false
	Sfx.play(&"ui_open", -6.0)
	_press_any.visible = false
	_menu.visible = true
	var fade := create_tween()
	fade.tween_property(_menu, "modulate:a", 1.0, 0.5)
	UIStyle.focus_first(_menu.get_children())


func _open_options() -> void:
	_options.open()


## Versão do jogo e, para quem já terminou, quais finais viu (lidos do save).
func _footer_text() -> String:
	var text := "Alexandria %s · Godot 4" % str(ProjectSettings.get_setting("application/config/version", ""))
	var seen: Array = Game.endings_seen()
	if not seen.is_empty():
		var names := seen.map(func(k): return {"proteger": "Proteger", "destruir": "Destruir"}.get(k, k))
		text += " · Finais vistos: %s" % ", ".join(names)
	return text


func _process(delta: float) -> void:
	_time += delta
	for i in _ash.size():
		var a := _ash[i]
		a.y -= a.z * delta
		a.x += sin(_time * 0.6 + i) * 0.0006
		if a.y < -0.02:
			a = Vector3(randf(), 1.02, randf_range(0.01, 0.035))
		_ash[i] = a
	if _waiting_any_key:
		_press_any.modulate.a = 0.45 + 0.45 * sin(_time * 2.2)  # pisca devagar
	queue_redraw()


## As cinzas: pontinhos claros e algumas brasas, subindo e sumindo no alto.
func _draw() -> void:
	var view := size
	for i in _ash.size():
		var a := _ash[i]
		var alpha := clampf(a.y * 1.2, 0.0, 1.0) * 0.5
		var ember := i % 7 == 0
		var color := Color(1.0, 0.55, 0.25, alpha) if ember else Color(0.85, 0.83, 0.8, alpha * 0.6)
		draw_rect(Rect2(Vector2(a.x * view.x, a.y * view.y), Vector2.ONE * (2.0 if ember else 1.0)), color)


func _on_continue() -> void:
	Sfx.play(&"ui_click")
	if Game.continue_game():
		return
	# Save ilegível: o Game guardou uma cópia (".corrompido") e NÃO apagou nada.
	_continue_button.queue_free()
	_continue_button = null
	_notice.text = "Não foi possível ler o save (uma cópia foi guardada). Comece um novo jogo."
	_new_game_button.grab_focus()


func _notification(what: int) -> void:
	# Android: "voltar" na tela de título fecha o jogo (quit_on_go_back=false
	# no projeto, então cada tela decide o que o botão faz).
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and _creation == null and _slots == null and _cutscene == null:
		Game.quit_game()


## Novo jogo → escolher o slot → criação de personagem → abertura → Prólogo.
## A confirmação de "apagar" agora é na tela de saves (só se o slot estiver ocupado).
func _on_new_game() -> void:
	Sfx.play(&"ui_click")
	open_slots("novo")


## Tela de saves por cima do título ("carregar" ou "novo").
func open_slots(mode: String) -> void:
	_menu.visible = false
	_slots = SlotMenu.create(mode)
	add_child(_slots)
	_slots.picked.connect(func(n: int): _on_slot_picked(mode, n))


func _on_slot_picked(mode: String, n: int) -> void:
	_slots.queue_free()
	_slots = null
	if n == 0:  # Voltar
		_menu.visible = true
		UIStyle.focus_first(_menu.get_children())
		return
	if mode == "carregar":
		Game.use_slot(n)
		if Game.continue_game():
			return
		_notice.text = "Não foi possível ler o SAVE %d (uma cópia foi guardada)." % n
		_menu.visible = true
		_new_game_button.grab_focus()
		return
	_new_slot = n
	await play_opening()
	open_creation()


## A abertura em vídeo (v0.29): toca antes da criação de personagem.
## Para trocar o vídeo, basta substituir o arquivo OPENING_VIDEO (mesmo nome).
func play_opening() -> void:
	_cutscene = CutscenePlayer.create(OPENING_VIDEO)
	add_child(_cutscene)
	await _cutscene.finished
	_cutscene.queue_free()
	_cutscene = null
	Sfx.play_ambience(&"tema_alexandria", -8.0)


## Novo jogo → criação de personagem → texto de abertura → Prólogo.
## (Como nos soulslike: primeiro você escolhe quem é, depois desperta.)
func open_creation() -> void:
	_creation = CharacterCreation.new()
	add_child(_creation)
	_creation.confirmed.connect(_on_creation_confirmed)
	_creation.cancelled.connect(_on_creation_cancelled)


func _on_creation_cancelled() -> void:
	_creation.queue_free()
	_creation = null
	open_slots("novo")  # Voltar da criação volta para a escolha do save


func _on_creation_confirmed(look: Dictionary) -> void:
	_creation.queue_free()
	_creation = null
	await _play_intro()
	Game.use_slot(_new_slot if _new_slot > 0 else Game.slot)
	Game.delete_save()  # só o save DESTE slot (os outros dois ficam intactos)
	Game.new_game(look)


## Texto de abertura (Anexo da Bíblia): o despertar. Toque para avançar.
## O resto ("A porta se abriu. E o chão desapareceu.") só vem no fim do Prólogo.
func _play_intro() -> void:
	var lines: Array = DialogueData.get_entry("intro").get("falas", [])
	var narration := Narration.new()
	add_child(narration)
	await narration.play(lines, Narration.Style.SCREEN, Color(0, 0, 0, 0))
