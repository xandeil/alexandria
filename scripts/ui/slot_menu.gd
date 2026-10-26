class_name SlotMenu
extends Control
## Escolha de save (3 slots), no estilo dos soulslike: cada slot mostra o SEU
## personagem (a aparência da criação), o nível, onde parou, memórias, mortes,
## quantos Pecados já caíram e o tempo de jogo.
##
## Dois modos:
##   "carregar" — só os slots com save dão para escolher;
##   "novo"     — qualquer slot; num slot ocupado, é preciso confirmar (apertar
##                de novo), porque começar ali APAGA aquele save.
## A tela só devolve o número escolhido (sinal `picked`, 0 = voltar). Quem
## carrega ou cria o jogo é o título — a mesma ideia da criação de personagem.

signal picked(slot: int)

var mode := "carregar"
var _cards: Array[Button] = []
var _confirm_slot := 0
var _hint: Label
var _back: Button


static func create(menu_mode: String) -> SlotMenu:
	var menu := SlotMenu.new()
	menu.mode = menu_mode
	return menu


func _ready() -> void:
	add_to_group(&"pad_menu")  # PadMenus: ✕ confirma e o foco nunca se perde no controle
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var background := ColorRect.new()
	background.color = Color(0, 0, 0)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var title := UIStyle.label("CARREGAR" if mode == "carregar" else "NOVO JOGO", 16, Color(0.9, 0.88, 0.84), UIStyle.TITLE_FONT)
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.offset_left = -200
	title.offset_right = 200
	title.offset_top = 12
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.offset_left = -170
	box.offset_right = 170
	box.offset_top = -86
	box.offset_bottom = 110
	box.add_theme_constant_override("separation", 6)
	add_child(box)
	for n in range(1, Game.SLOT_COUNT + 1):
		var card := _make_card(n)
		box.add_child(card)
		_cards.append(card)
	_hint = UIStyle.label("", 8, Color(0.95, 0.6, 0.55))
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_hint)
	_back = DSMenuButton.make("Voltar", 11)
	_back.pressed.connect(_cancel)
	box.add_child(_back)
	_link_focus()
	_first_focus().grab_focus()


func _make_card(n: int) -> Button:
	var info := Game.slot_summary(n)
	var card := Button.new()
	card.custom_minimum_size = Vector2(340, 48)
	card.set_meta("slot", n)
	for state in ["normal", "pressed", "disabled"]:
		card.add_theme_stylebox_override(state, _card_style(false))
	for state in ["hover", "focus", "hover_pressed"]:
		card.add_theme_stylebox_override(state, _card_style(true))
	card.disabled = info.is_empty() and mode == "carregar"
	card.focus_mode = Control.FOCUS_NONE if card.disabled else Control.FOCUS_ALL
	card.mouse_entered.connect(func():
		if not card.disabled:
			card.grab_focus())
	card.pressed.connect(func(): _choose(n, not info.is_empty()))
	# Conteúdo desenhado por cima do botão (o Button do Godot só tem 1 texto e 1 ícone).
	var row := HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 8
	row.add_theme_constant_override("separation", 10)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(row)
	var portrait := Control.new()
	portrait.custom_minimum_size = Vector2(36, 44)
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(portrait)
	var lines := VBoxContainer.new()
	lines.alignment = BoxContainer.ALIGNMENT_CENTER
	lines.add_theme_constant_override("separation", 0)
	lines.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(lines)
	var head := UIStyle.label("SAVE %d" % n, 11, Color(0.92, 0.88, 0.8), UIStyle.TITLE_FONT)
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lines.add_child(head)
	if info.is_empty():
		var empty := UIStyle.label("— vazio —", 9, UIStyle.TEXT_DIM)
		empty.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lines.add_child(empty)
		return card
	var hero := AnimatedSprite2D.new()
	hero.sprite_frames = Appearance.sprite_frames(info["aparencia"])
	hero.play(&"idle")
	hero.scale = Vector2(2, 2)
	hero.position = Vector2(18, 22)
	hero.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	portrait.add_child(hero)
	head.text = "SAVE %d   ·   Nível %d" % [n, int(info["nivel"])]
	var where := UIStyle.label(str(info["area"]), 8, UIStyle.GOLD)
	where.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lines.add_child(where)
	var stats := UIStyle.label("Memórias %d  ·  Mortes %d  ·  Pecados %d/7  ·  %s" % [
		int(info["memorias"]), int(info["mortes"]), int(info["pecados"]), Game.format_play_time(float(info["tempo"]))],
		7, UIStyle.TEXT_DIM, UIStyle.FONT_NUMBERS)
	stats.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lines.add_child(stats)
	return card


func _card_style(lit: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.05) if not lit else Color(0.14, 0.13, 0.1)
	style.border_color = Color(0.98, 0.94, 0.82) if lit else Color(0.25, 0.23, 0.2)
	style.set_border_width_all(1)
	if lit:
		style.shadow_color = Color(1.0, 0.92, 0.7, 0.22)
		style.shadow_size = 3
	return style


## ↑/↓ entre os slots (pulando os vazios no "carregar") e o Voltar no fim.
func _link_focus() -> void:
	var chain: Array[Control] = []
	for card in _cards:
		if card.focus_mode != Control.FOCUS_NONE:
			chain.append(card)
	chain.append(_back)
	for i in chain.size():
		var current := chain[i]
		current.focus_neighbor_top = current.get_path_to(chain[posmod(i - 1, chain.size())])
		current.focus_neighbor_bottom = current.get_path_to(chain[posmod(i + 1, chain.size())])
		current.focus_neighbor_left = current.get_path_to(current)
		current.focus_neighbor_right = current.get_path_to(current)


func _first_focus() -> Control:
	# Carregar: o último save usado, se ele existir. Novo: o primeiro slot LIVRE.
	if mode == "carregar" and not _cards[Game.slot - 1].disabled:
		return _cards[Game.slot - 1]
	for card in _cards:
		if not card.disabled and (mode == "carregar" or Game.slot_summary(card.get_meta("slot")).is_empty()):
			return card
	for card in _cards:
		if not card.disabled:
			return card
	return _back


func _choose(n: int, occupied: bool) -> void:
	if mode == "novo" and occupied and _confirm_slot != n:
		_confirm_slot = n
		Sfx.play(&"ui_click")
		_hint.text = "O SAVE %d será APAGADO. Aperte de novo para começar nele." % n
		return
	Sfx.play(&"ui_open")
	picked.emit(n)


func _cancel() -> void:
	Sfx.play(&"ui_click")
	picked.emit(0)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		_cancel()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and is_visible_in_tree():
		_cancel()
