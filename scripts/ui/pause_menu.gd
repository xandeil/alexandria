class_name PauseMenu
extends CanvasLayer
## Menu de pausa: continuar, inventário, opções, voltar ao título.

## O HUD entrega o inventário e o herói (a pausa não cria nem procura nada).
var inventory_menu: InventoryMenu
var player: Player

var _options_button: Button
var _options: OptionsMenu
var _resume_button: Button
var _inventory_button: Button


func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.82)  # escurece o jogo como nos soulslike
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.offset_left = -80
	box.offset_right = 80
	box.offset_top = -72
	box.offset_bottom = 72
	box.add_theme_constant_override("separation", 6)
	add_child(box)
	var title := UIStyle.label("Pausa", 16, UIStyle.TEXT, UIStyle.TITLE_FONT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	_resume_button = DSMenuButton.make("Continuar")
	_resume_button.pressed.connect(close)
	box.add_child(_resume_button)
	_inventory_button = DSMenuButton.make("Inventário")
	_inventory_button.pressed.connect(_open_inventory)
	box.add_child(_inventory_button)
	_options_button = DSMenuButton.make("Opções")
	_options_button.pressed.connect(_open_options)
	box.add_child(_options_button)
	var title_button := DSMenuButton.make("Voltar ao título")
	title_button.pressed.connect(func():
		close()
		Game.go_to_title())
	box.add_child(title_button)
	visible = false


func open() -> void:
	visible = true
	get_tree().paused = true
	_resume_button.grab_focus()  # teclado/controle: Enter já continua
	Sfx.play(&"ui_open")


func close() -> void:
	if not visible:
		return
	visible = false
	get_tree().paused = false


## O inventário abre POR CIMA da pausa; fechando, volta para cá.
func _open_inventory() -> void:
	if inventory_menu == null:
		return
	visible = false
	inventory_menu.open(player)
	await inventory_menu.closed
	if get_tree().paused:  # ainda pausado = o jogador volta para o menu de pausa
		visible = true
		_inventory_button.grab_focus()


## As opções abrem por cima da pausa; fechando, volta para cá.
## (Criadas na primeira vez, ao lado da pausa — não DENTRO dela: esconder a
## pausa não pode esconder as opções.)
func _open_options() -> void:
	if _options == null:
		_options = OptionsMenu.new()
		get_parent().add_child(_options)
	visible = false
	_options.open()
	await _options.closed
	visible = true
	_options_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if visible and not (_options and _options.is_open()) and event.is_action_pressed(&"pause"):
		close()
		get_viewport().set_input_as_handled()
