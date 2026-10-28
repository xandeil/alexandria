extends Node
## Menus no CONTROLE, à prova de celular (autoload "PadMenus").
##
## O defeito: no Android, um menu podia abrir (ou voltar) SEM nenhum item
## selecionado — um toque na tela, o app perdendo o foco, uma janela fechando...
## Sem item com foco, o ✕ não tem o que apertar e o jogador fica preso.
##
## A regra, num lugar só (em vez de remendar cada menu):
##   1. Apertou algo no controle e nenhum item do menu está selecionado?
##      Seleciona o primeiro (esse aperto só "acorda" o menu, como nos soulslike).
##   2. ✕ confirma o item selecionado NA HORA de apertar (sem esperar soltar).
##   3. ○ continua sendo "voltar" (ui_cancel) — cada menu decide o que é voltar.
##
## Quem é menu? Os nós no grupo "pad_menu" (título, criação, pausa, opções,
## inventário, forja, Fada, escolhas do diálogo). O jogo em si NÃO entra: com o
## menu fechado, o ✕ volta a ser "interagir" e o direcional volta a andar.

const GROUP := &"pad_menu"
const CONFIRM := JOY_BUTTON_A  # o botão de BAIXO (✕ no PlayStation, A no Xbox, B no Nintendo)
const NAV_BUTTONS := [JOY_BUTTON_A, JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_DOWN, JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_RIGHT]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # menus quase sempre abrem com o jogo pausado
	# Qual controle está ligado (PadStyle): ao abrir e a cada liga/desliga.
	PadStyle.refresh()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)


func _on_joy_connection_changed(_device: int, _connected: bool) -> void:
	PadStyle.refresh()
	Settings.changed.emit()  # legendas e menus redesenham com os botões certos


func _input(event: InputEvent) -> void:
	if (event is InputEventJoypadButton or event is InputEventJoypadMotion) and PadStyle.note_device(event.device):
		Settings.changed.emit()  # outro controle assumiu: troca os desenhos
	if not _is_pad_press(event):
		return
	var menu := active_menu()
	if menu == null:
		return  # nenhum menu aberto: é jogo, não mexe em nada
	var focus := get_viewport().gui_get_focus_owner()
	if focus == null or not focus.is_visible_in_tree() or not menu.is_ancestor_of(focus):
		var first := first_button(menu)
		if first:
			first.grab_focus()
			get_viewport().set_input_as_handled()
		return
	if event is InputEventJoypadButton and event.button_index == CONFIRM:
		var button := focus as BaseButton
		if button and not button.disabled:
			get_viewport().set_input_as_handled()
			press(button)


## Um aperto (não soltura) de botão do direcional/✕, ou o analógico saindo do centro.
func _is_pad_press(event: InputEvent) -> bool:
	if event is InputEventJoypadButton:
		return event.pressed and event.button_index in NAV_BUTTONS
	if event is InputEventJoypadMotion:
		return event.axis in [JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y] and absf(event.axis_value) > 0.6
	return false


## O menu aberto mais "de cima" (maior camada; empate = o mais novo).
func active_menu() -> Node:
	var best: Node = null
	var best_layer := -INF
	for node in get_tree().get_nodes_in_group(GROUP):
		if not _menu_visible(node) or first_button(node) == null:
			continue
		var layer := _layer_of(node)
		# Mesma camada: vale o mais "de dentro" (a criação de personagem dentro do título).
		if layer > best_layer or (layer == best_layer and best != null and best.is_ancestor_of(node)):
			best = node
			best_layer = layer
	return best


func _menu_visible(node: Node) -> bool:
	if node is CanvasLayer:
		return (node as CanvasLayer).visible
	if node is CanvasItem:
		return (node as CanvasItem).is_visible_in_tree()
	return false


func _layer_of(node: Node) -> float:
	var current := node
	while current:
		if current is CanvasLayer:
			return float((current as CanvasLayer).layer)
		current = current.get_parent()
	return 0.0


## O primeiro botão visível, ligado e focável dentro do menu (busca em profundidade,
## na ordem da tela — a mesma que o jogador lê).
func first_button(root: Node) -> BaseButton:
	for child in root.get_children():
		var button := child as BaseButton
		if button and button.is_visible_in_tree() and not button.disabled and button.focus_mode != Control.FOCUS_NONE:
			return button
		var canvas := child as CanvasItem
		if canvas and not canvas.visible:
			continue
		var found := first_button(child)
		if found:
			return found
	return null


## Aperta o botão como se fosse um clique (som e sinal "pressed").
func press(button: BaseButton) -> void:
	if button.toggle_mode:
		button.button_pressed = not button.button_pressed
	else:
		button.pressed.emit()
