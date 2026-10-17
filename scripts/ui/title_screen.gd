extends Control
## Tela de título: o mapa das ilhas (arte conceitual da Bíblia) ao fundo,
## "ALEXANDRIA — A Ilha Que Não Cai" e o texto de abertura ao começar.

const MAP := preload("res://assets/ui/title_map.jpg")

var _background: TextureRect
var _menu: VBoxContainer
var _new_game_button: Button
var _continue_button: Button
var _notice: Label
var _options: OptionsMenu
var _confirm_new := false
var _time := 0.0


func _ready() -> void:
	_build()
	Sfx.play_ambience(&"tema_alexandria", -8.0)


func _build() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var black := ColorRect.new()
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	black.color = Color(0.03, 0.025, 0.04)
	black.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(black)
	_background = TextureRect.new()
	_background.texture = MAP
	_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_background.set_anchors_preset(Control.PRESET_FULL_RECT)
	_background.modulate = Color(0.55, 0.55, 0.62)
	_background.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_background)
	var shade := TextureRect.new()
	var gradient := Gradient.new()
	gradient.set_color(0, Color(0.02, 0.015, 0.03, 0.15))
	gradient.set_color(1, Color(0.02, 0.015, 0.03, 0.9))
	var gradient_texture := GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.fill_from = Vector2(0, 0)
	gradient_texture.fill_to = Vector2(0, 1)
	shade.texture = gradient_texture
	shade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var title := UIStyle.label("ALEXANDRIA", 34, Color(0.92, 0.9, 0.86), UIStyle.TITLE_FONT)
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.offset_left = -240
	title.offset_right = 240
	title.offset_top = 46
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)
	var subtitle := UIStyle.label("A Ilha Que Não Cai", 12, UIStyle.GOLD, UIStyle.TITLE_FONT)
	subtitle.set_anchors_preset(Control.PRESET_CENTER_TOP)
	subtitle.offset_left = -240
	subtitle.offset_right = 240
	subtitle.offset_top = 92
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(subtitle)

	_menu = VBoxContainer.new()
	_menu.set_anchors_preset(Control.PRESET_CENTER)
	_menu.offset_left = -75
	_menu.offset_right = 75
	_menu.offset_top = 10
	_menu.offset_bottom = 80
	_menu.add_theme_constant_override("separation", 6)
	add_child(_menu)
	if Game.has_save():
		_continue_button = UIStyle.button("Continuar", 11)
		_continue_button.pressed.connect(_on_continue)
		_menu.add_child(_continue_button)
	_new_game_button = UIStyle.button("Novo jogo", 11)
	_new_game_button.pressed.connect(_on_new_game)
	_menu.add_child(_new_game_button)
	var options_button := UIStyle.button("Opções", 11)
	options_button.pressed.connect(_open_options)
	_menu.add_child(options_button)
	UIStyle.focus_first(_menu.get_children())
	_options = OptionsMenu.new()
	add_child(_options)
	_options.closed.connect(func(): options_button.grab_focus())

	_notice = UIStyle.label("", 8, Color(0.95, 0.6, 0.55))
	_notice.set_anchors_preset(Control.PRESET_CENTER)
	_notice.offset_left = -200
	_notice.offset_right = 200
	_notice.offset_top = 84
	_notice.offset_bottom = 110
	_notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_notice)

	var footer := UIStyle.label(_footer_text(), 7, UIStyle.TEXT_DIM)
	footer.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	footer.offset_left = -240
	footer.offset_right = 240
	footer.offset_top = -16
	footer.offset_bottom = -4
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(footer)


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
	# Movimento lento de câmera sobre o mapa (efeito Ken Burns).
	_time += delta
	var drift := Vector2(sin(_time * 0.05), cos(_time * 0.04)) * 10.0
	_background.position = drift - Vector2(10, 10)
	_background.size = get_viewport_rect().size + Vector2(20, 20)


func _on_continue() -> void:
	Sfx.play(&"ui_click")
	if Game.continue_game():
		return
	# Save ilegível: o Game guardou uma cópia (".corrompido") e NÃO apagou nada.
	_continue_button.queue_free()
	_continue_button = null
	_confirm_new = true  # não há mais progresso para "apagar"
	_notice.text = "Não foi possível ler o save (uma cópia foi guardada). Comece um novo jogo."
	_new_game_button.grab_focus()


func _notification(what: int) -> void:
	# Android: "voltar" na tela de título fecha o jogo (quit_on_go_back=false
	# no projeto, então cada tela decide o que o botão faz).
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		Game.quit_game()


func _on_new_game() -> void:
	Sfx.play(&"ui_click")
	if Game.has_save() and not _confirm_new:
		_confirm_new = true
		_new_game_button.text = "Apagar progresso? Toque de novo"
		return
	_menu.visible = false
	await _play_intro()
	Game.delete_save()
	Game.new_game()


## Texto de abertura (Anexo da Bíblia): o despertar. Toque para avançar.
## O resto ("A porta se abriu. E o chão desapareceu.") só vem no fim do Prólogo.
func _play_intro() -> void:
	var lines: Array = DialogueData.get_entry("intro").get("falas", [])
	var dim := create_tween()
	dim.tween_property(_background, "modulate", Color(0.12, 0.12, 0.15), 1.2)
	await dim.finished
	var narration := Narration.new()
	add_child(narration)
	await narration.play(lines, Narration.Style.SCREEN, Color(0, 0, 0, 0))
